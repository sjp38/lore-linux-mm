Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A42516B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 06:31:04 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 20:19:57 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id EDAFA357805A
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:59 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7NAUmNO6357350
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:48 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7NAUwLx025982
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 20:30:59 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 5/7] mm/hwpoison: don't set migration type twice to avoid hold heavy contend zone->lock
Date: Fri, 23 Aug 2013 18:30:39 +0800
Message-Id: <1377253841-17620-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

v1 -> v2:
	* add more explanation in patch description.

Set pageblock migration type will hold zone->lock which is heavy contended
in system to avoid race. However, soft offline page will set pageblock
migration type twice during get page if the page is in used, not hugetlbfs
page and not on lru list. There is unnecessary to set the pageblock migration
type and hold heavy contended zone->lock again if the first round get page
have already set the pageblock to right migration type.

The trick here is migration type is MIGRATE_ISOLATE. There are other two parts 
can change MIGRATE_ISOLATE except hwpoison. One is memory hoplug, however, we 
hold lock_memory_hotplug() which avoid race. The second is CMA which umovable 
page allocation requst can't fallback to. So it's safe here.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 297965e..f357c91 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1426,7 +1426,8 @@ static int __get_any_page(struct page *p, unsigned long pfn, int flags)
 	 * was free. This flag should be kept set until the source page
 	 * is freed and PG_hwpoison on it is set.
 	 */
-	set_migratetype_isolate(p, true);
+	if (get_pageblock_migratetype(p) == MIGRATE_ISOLATE)
+		set_migratetype_isolate(p, true);
 	/*
 	 * When the target page is a free hugepage, just remove it
 	 * from free hugepage list.
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
