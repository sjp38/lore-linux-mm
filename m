Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6585F6B006E
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:49:42 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id hi2so4441511wib.15
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:49:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si1541576wiw.91.2014.10.02.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:49:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/4] mm, memory_hotplug/failure: drain single zone pcplists
Date: Thu,  2 Oct 2014 17:49:00 +0200
Message-Id: <1412264940-15738-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
References: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Memory hotplug and failure mechanisms have several places where pcplists are
drained so that pages are returned to the buddy allocator and can be e.g.
prepared for offlining. This is always done in the context of a single zone,
we can reduce the pcplists drain to the single zone, which is now possible.

The change should make memory offlining due to hotremove or failure faster and
not disturbing unrelated pcplists anymore.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/memory-failure.c | 4 ++--
 mm/memory_hotplug.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 851b4d7..84e7ded 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -233,7 +233,7 @@ void shake_page(struct page *p, int access)
 		lru_add_drain_all();
 		if (PageLRU(p))
 			return;
-		drain_all_pages(NULL);
+		drain_all_pages(page_zone(p));
 		if (PageLRU(p) || is_free_buddy_page(p))
 			return;
 	}
@@ -1661,7 +1661,7 @@ static int __soft_offline_page(struct page *page, int flags)
 			if (!is_free_buddy_page(page))
 				lru_add_drain_all();
 			if (!is_free_buddy_page(page))
-				drain_all_pages(NULL);
+				drain_all_pages(page_zone(page));
 			SetPageHWPoison(page);
 			if (!is_free_buddy_page(page))
 				pr_info("soft offline: %#lx: page leaked\n",
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 55a5441..7b67053 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1699,7 +1699,7 @@ repeat:
 	if (drain) {
 		lru_add_drain_all();
 		cond_resched();
-		drain_all_pages(NULL);
+		drain_all_pages(zone);
 	}
 
 	pfn = scan_movable_pages(start_pfn, end_pfn);
@@ -1721,7 +1721,7 @@ repeat:
 	lru_add_drain_all();
 	yield();
 	/* drain pcp pages, this is synchronous. */
-	drain_all_pages(NULL);
+	drain_all_pages(zone);
 	/*
 	 * dissolve free hugepages in the memory block before doing offlining
 	 * actually in order to make hugetlbfs's object counting consistent.
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
