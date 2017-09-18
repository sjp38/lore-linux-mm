Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60B166B025E
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:10:15 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so8393345wrc.5
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 00:10:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d83sor1571392wmc.11.2017.09.18.00.10.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 00:10:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
Date: Mon, 18 Sep 2017 09:08:33 +0200
Message-Id: <20170918070834.13083-2-mhocko@kernel.org>
In-Reply-To: <20170918070834.13083-1-mhocko@kernel.org>
References: <20170918070834.13083-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Memory offlining can fail just too eagerly under a heavy memory pressure.

[ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
[ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
[ 5410.336811] page dumped because: isolation failed
[ 5410.336813] page->mem_cgroup:ffff8801cd662000
[ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed

Isolation has failed here because the page is not on LRU. Most probably
because it was on the pcp LRU cache or it has been removed from the LRU
already but it hasn't been freed yet. In both cases the page doesn't look
non-migrable so retrying more makes sense.

__offline_pages seems rather cluttered when it comes to the retry
logic. We have 5 retries at maximum and a timeout. We could argue
whether the timeout makes sense but failing just because of a race when
somebody isoltes a page from LRU or puts it on a pcp LRU lists is just
wrong. It only takes it to race with a process which unmaps some pages
and remove them from the LRU list and we can fail the whole offline
because of something that is a temporary condition and actually not
harmful for the offline.

Please note that unmovable pages should be already excluded during
start_isolate_page_range. We could argue that has_unmovable_pages is
racy and MIGRATE_MOVABLE check doesn't provide any hard guarantee either
but kernel zones (aka < ZONE_MOVABLE) will very likely detect unmovable
pages in most cases and movable zone shouldn't contain unmovable pages
at all. Some of those pages might be pinned but not for ever because
that would be a bug on its own. In any case the context is still
interruptible and so the userspace can easily bail out when the
operation takes too long. This is certainly better behavior than a
hardcoded retry loop which is racy.

Fix this by removing the max retry count and only rely on the timeout
resp. interruption by a signal from the userspace. Also retry rather
than fail when check_pages_isolated sees some !free pages because those
could be a result of the race as well.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 40 ++++++++++------------------------------
 1 file changed, 10 insertions(+), 30 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 459bbc182d10..c9dcbe6d2ac6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1597,7 +1597,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages, expire;
 	long offlined_pages;
-	int ret, drain, retry_max, node;
+	int ret, node;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
@@ -1634,43 +1634,25 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	pfn = start_pfn;
 	expire = jiffies + timeout;
-	drain = 0;
-	retry_max = 5;
 repeat:
 	/* start memory hot removal */
-	ret = -EAGAIN;
+	ret = -EBUSY;
 	if (time_after(jiffies, expire))
 		goto failed_removal;
 	ret = -EINTR;
 	if (signal_pending(current))
 		goto failed_removal;
-	ret = 0;
-	if (drain) {
-		lru_add_drain_all_cpuslocked();
-		cond_resched();
-		drain_all_pages(zone);
-	}
+
+	cond_resched();
+	lru_add_drain_all_cpuslocked();
+	drain_all_pages(zone);
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
 	if (pfn) { /* We have movable pages */
 		ret = do_migrate_range(pfn, end_pfn);
-		if (!ret) {
-			drain = 1;
-			goto repeat;
-		} else {
-			if (ret < 0)
-				if (--retry_max == 0)
-					goto failed_removal;
-			yield();
-			drain = 1;
-			goto repeat;
-		}
+		goto repeat;
 	}
-	/* drain all zone's lru pagevec, this is asynchronous... */
-	lru_add_drain_all_cpuslocked();
-	yield();
-	/* drain pcp pages, this is synchronous. */
-	drain_all_pages(zone);
+
 	/*
 	 * dissolve free hugepages in the memory block before doing offlining
 	 * actually in order to make hugetlbfs's object counting consistent.
@@ -1680,10 +1662,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal;
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
-	if (offlined_pages < 0) {
-		ret = -EBUSY;
-		goto failed_removal;
-	}
+	if (offlined_pages < 0)
+		goto repeat;
 	pr_info("Offlined Pages %ld\n", offlined_pages);
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
