Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id F18CB9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 08:29:11 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so161184626wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 05:29:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fz6si24471949wic.116.2015.07.22.05.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 05:29:10 -0700 (PDT)
Message-ID: <55AF8C94.6020406@suse.cz>
Date: Wed, 22 Jul 2015 14:29:08 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: rename and move get/set_freepage_migratetype
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz> <1437483218-18703-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437483218-18703-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On 07/21/2015 02:53 PM, Vlastimil Babka wrote:
> The pair of get/set_freepage_migratetype() functions are used to cache
> pageblock migratetype for a page put on a pcplist, so that it does not have
> to be retrieved again when the page is put on a free list (e.g. when pcplists
> become full). Historically it was also assumed that the value is accurate for
> pages on freelists (as the functions' names unfortunately suggest), but that
> cannot be guaranteed without affecting various allocator fast paths. It is in
> fact not needed and all such uses have been removed.
> 
> The last remaining (but pointless) usage related to pages of freelists is in
> move_freepages(), which this patch removes.

I realized there's one more callsite that can be removed. Here's
whole updated patch due to different changelog and to cope with
context changed by the fixlet to patch 1/2.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 2 Jul 2015 16:37:06 +0200
Subject: mm: rename and move get/set_freepage_migratetype

The pair of get/set_freepage_migratetype() functions are used to cache
pageblock migratetype for a page put on a pcplist, so that it does not have
to be retrieved again when the page is put on a free list (e.g. when pcplists
become full). Historically it was also assumed that the value is accurate for
pages on freelists (as the functions' names unfortunately suggest), but that
cannot be guaranteed without affecting various allocator fast paths. It is in
fact not needed and all such uses have been removed.

The last two remaining (but pointless) usages related to pages of freelists
are removed by this patch:
- move_freepages() which operates on pages already on freelists
- __free_pages_ok() which puts a page directly to freelist, bypassing pcplists

To prevent further confusion, rename the functions to
get/set_pcppage_migratetype() and expand their description. Since all the
users are now in mm/page_alloc.c, move the functions there from the shared
header.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Laura Abbott <lauraa@codeaurora.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm.h | 12 ------------
 mm/page_alloc.c    | 41 ++++++++++++++++++++++++++++-------------
 2 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c3a2b37..ce36145 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -310,18 +310,6 @@ struct inode;
 #define page_private(page)		((page)->private)
 #define set_page_private(page, v)	((page)->private = (v))
 
-/* It's valid only if the page is free path or free_list */
-static inline void set_freepage_migratetype(struct page *page, int migratetype)
-{
-	page->index = migratetype;
-}
-
-/* It's valid only if the page is free path or free_list */
-static inline int get_freepage_migratetype(struct page *page)
-{
-	return page->index;
-}
-
 /*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c61fef8..4b220cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -125,6 +125,24 @@ unsigned long dirty_balance_reserve __read_mostly;
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
+/*
+ * A cached value of the page's pageblock's migratetype, used when the page is
+ * put on a pcplist. Used to avoid the pageblock migratetype lookup when
+ * freeing from pcplists in most cases, at the cost of possibly becoming stale.
+ * Also the migratetype set in the page does not necessarily match the pcplist
+ * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
+ * other index - this ensures that it will be put on the correct CMA freelist.
+ */
+static inline int get_pcppage_migratetype(struct page *page)
+{
+	return page->index;
+}
+
+static inline void set_pcppage_migratetype(struct page *page, int migratetype)
+{
+	page->index = migratetype;
+}
+
 #ifdef CONFIG_PM_SLEEP
 /*
  * The following functions are used by the suspend/hibernate code to temporarily
@@ -790,7 +808,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 
-			mt = get_freepage_migratetype(page);
+			mt = get_pcppage_migratetype(page);
 			/* MIGRATE_ISOLATE page should not go to pcplists */
 			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
 			/* Pageblock could have been isolated meanwhile */
@@ -963,7 +981,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	local_irq_save(flags);
 	__count_vm_events(PGFREE, 1 << order);
-	set_freepage_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
 }
@@ -1384,7 +1401,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
-		set_freepage_migratetype(page, migratetype);
+		set_pcppage_migratetype(page, migratetype);
 		return page;
 	}
 
@@ -1461,7 +1478,6 @@ int move_freepages(struct zone *zone,
 		order = page_order(page);
 		list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
-		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -1631,14 +1647,13 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 		expand(zone, page, order, current_order, area,
 					start_migratetype);
 		/*
-		 * The freepage_migratetype may differ from pageblock's
+		 * The pcppage_migratetype may differ from pageblock's
 		 * migratetype depending on the decisions in
-		 * try_to_steal_freepages(). This is OK as long as it
-		 * does not differ for MIGRATE_CMA pageblocks. For CMA
-		 * we need to make sure unallocated pages flushed from
-		 * pcp lists are returned to the correct freelist.
+		 * find_suitable_fallback(). This is OK as long as it does not
+		 * differ for MIGRATE_CMA pageblocks. Those can be used as
+		 * fallback only via special __rmqueue_cma_fallback() function
 		 */
-		set_freepage_migratetype(page, start_migratetype);
+		set_pcppage_migratetype(page, start_migratetype);
 
 		trace_mm_page_alloc_extfrag(page, order, current_order,
 			start_migratetype, fallback_mt);
@@ -1714,7 +1729,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_freepage_migratetype(page)))
+		if (is_migrate_cma(get_pcppage_migratetype(page)))
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
 	}
@@ -1911,7 +1926,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-	set_freepage_migratetype(page, migratetype);
+	set_pcppage_migratetype(page, migratetype);
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 
@@ -2116,7 +2131,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		if (!page)
 			goto failed;
 		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_freepage_migratetype(page));
+					  get_pcppage_migratetype(page));
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
-- 
2.4.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
