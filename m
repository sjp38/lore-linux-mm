Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8D5E66B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 23:58:00 -0400 (EDT)
Received: by qafk30 with SMTP id k30so3713939qaf.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:57:59 -0700 (PDT)
Date: Tue, 18 Sep 2012 20:57:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/4] mm: remove free_page_mlock
In-Reply-To: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1209182055290.11632@eggly.anvils>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We should not be seeing non-0 unevictable_pgs_mlockfreed any longer.
So remove free_page_mlock() from the page freeing paths: __PG_MLOCKED
is already in PAGE_FLAGS_CHECK_AT_FREE, so free_pages_check() will now
be checking it, reporting "BUG: Bad page state" if it's ever found set.
Comment UNEVICTABLE_MLOCKFREED and unevictable_pgs_mlockfreed always 0.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ying Han <yinghan@google.com>
---
 include/linux/vm_event_item.h |    2 +-
 mm/page_alloc.c               |   17 -----------------
 mm/vmstat.c                   |    2 +-
 3 files changed, 2 insertions(+), 19 deletions(-)

--- 3.6-rc6.orig/include/linux/vm_event_item.h	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/include/linux/vm_event_item.h	2012-09-18 20:04:42.516625261 -0700
@@ -52,7 +52,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGMUNLOCKED,
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
-		UNEVICTABLE_MLOCKFREED,
+		UNEVICTABLE_MLOCKFREED,	/* no longer useful: always zero */
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		THP_FAULT_ALLOC,
 		THP_FAULT_FALLBACK,
--- 3.6-rc6.orig/mm/page_alloc.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/page_alloc.c	2012-09-18 20:04:42.520625316 -0700
@@ -597,17 +597,6 @@ out:
 	zone->free_area[order].nr_free++;
 }
 
-/*
- * free_page_mlock() -- clean up attempts to free and mlocked() page.
- * Page should not be on lru, so no need to fix that up.
- * free_pages_check() will verify...
- */
-static inline void free_page_mlock(struct page *page)
-{
-	__dec_zone_page_state(page, NR_MLOCK);
-	__count_vm_event(UNEVICTABLE_MLOCKFREED);
-}
-
 static inline int free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
@@ -721,14 +710,11 @@ static bool free_pages_prepare(struct pa
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
-	int wasMlocked = __TestClearPageMlocked(page);
 
 	if (!free_pages_prepare(page, order))
 		return;
 
 	local_irq_save(flags);
-	if (unlikely(wasMlocked))
-		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, order,
 					get_pageblock_migratetype(page));
@@ -1296,7 +1282,6 @@ void free_hot_cold_page(struct page *pag
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
 	int migratetype;
-	int wasMlocked = __TestClearPageMlocked(page);
 
 	if (!free_pages_prepare(page, 0))
 		return;
@@ -1304,8 +1289,6 @@ void free_hot_cold_page(struct page *pag
 	migratetype = get_pageblock_migratetype(page);
 	set_page_private(page, migratetype);
 	local_irq_save(flags);
-	if (unlikely(wasMlocked))
-		free_page_mlock(page);
 	__count_vm_event(PGFREE);
 
 	/*
--- 3.6-rc6.orig/mm/vmstat.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/vmstat.c	2012-09-18 20:04:42.524625352 -0700
@@ -781,7 +781,7 @@ const char * const vmstat_text[] = {
 	"unevictable_pgs_munlocked",
 	"unevictable_pgs_cleared",
 	"unevictable_pgs_stranded",
-	"unevictable_pgs_mlockfreed",
+	"unevictable_pgs_mlockfreed",	/* no longer useful: always zero */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	"thp_fault_alloc",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
