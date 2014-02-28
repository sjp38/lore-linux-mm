Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id DA7186B0073
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:15:36 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so644817wib.5
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:15:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g6si1756779wjb.159.2014.02.28.06.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 06:15:34 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/6] mm: add set_pageblock_migratetype_nolock() for calls outside zone->lock
Date: Fri, 28 Feb 2014 15:15:02 +0100
Message-Id: <1393596904-16537-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

To prevent races, set_pageblock_migratetype() should be called with zone->lock
held. This patch adds a debugging assertion and introduces a _nolock variant
for zone init functions.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index de5b419..fd6a64c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -232,7 +232,7 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-void set_pageblock_migratetype(struct page *page, int migratetype)
+static void set_pageblock_migratetype_nolock(struct page *page, int migratetype)
 {
 	if (unlikely(page_group_by_mobility_disabled &&
 		     migratetype < MIGRATE_PCPTYPES))
@@ -242,6 +242,13 @@ void set_pageblock_migratetype(struct page *page, int migratetype)
 					PB_migrate, PB_migrate_end);
 }
 
+void set_pageblock_migratetype(struct page *page, int migratetype)
+{
+	VM_BUG_ON(!spin_is_locked(&page_zone(page)->lock));
+
+	set_pageblock_migratetype_nolock(page, migratetype);
+}
+
 bool oom_killer_disabled __read_mostly;
 
 #ifdef CONFIG_DEBUG_VM
@@ -803,7 +810,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
 	} while (++p, --i);
 
 	set_page_refcounted(page);
-	set_pageblock_migratetype(page, MIGRATE_CMA);
+	set_pageblock_migratetype_nolock(page, MIGRATE_CMA);
 	__free_pages(page, pageblock_order);
 	adjust_managed_page_count(page, pageblock_nr_pages);
 }
@@ -4100,7 +4107,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if ((z->zone_start_pfn <= pfn)
 		    && (pfn < zone_end_pfn(z))
 		    && !(pfn & (pageblock_nr_pages - 1)))
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			set_pageblock_migratetype_nolock(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
