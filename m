Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D8B036B0035
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 02:37:30 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2143638pde.10
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 23:37:30 -0700 (PDT)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zm8si3013387pac.317.2014.03.13.23.37.29
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 23:37:30 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 4/6] mm: add stat about lazyfree pages
Date: Fri, 14 Mar 2014 15:37:48 +0900
Message-Id: <1394779070-8545-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch adds new vmstat for lazyfree pages so that admin
could check how many of lazyfree pages remains each zone
and how many of lazyfree pages purged until now.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm.h            | 4 ++++
 include/linux/mmzone.h        | 1 +
 include/linux/vm_event_item.h | 1 +
 mm/page_alloc.c               | 5 ++++-
 mm/vmscan.c                   | 1 +
 mm/vmstat.c                   | 2 ++
 6 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9b048cabce27..498613946991 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -975,6 +975,8 @@ static inline void SetPageLazyFree(struct page *page)
 
 	page->mapping = (void *)((unsigned long)page->mapping |
 			PAGE_MAPPING_LZFREE);
+
+	__inc_zone_page_state(page, NR_LAZYFREE_PAGES);
 }
 
 static inline void ClearPageLazyFree(struct page *page)
@@ -984,6 +986,8 @@ static inline void ClearPageLazyFree(struct page *page)
 
 	page->mapping = (void *)((unsigned long)page->mapping &
 				~PAGE_MAPPING_LZFREE);
+
+	__dec_zone_page_state(page, NR_LAZYFREE_PAGES);
 }
 
 static inline int PageLazyFree(struct page *page)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5f2052c83154..7366ec56ea73 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -113,6 +113,7 @@ enum zone_stat_item {
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
+	NR_LAZYFREE_PAGES,	/* freeable pages at memory pressure */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3a712e2e7d76..6b5b870895da 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,6 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		PGFREE, PGACTIVATE, PGDEACTIVATE,
 		PGFAULT, PGMAJFAULT,
+		PGLAZYFREE,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3bac76ae4b30..596f24ecf397 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -731,8 +731,11 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
+		if (PageLazyFree(page))
+			__dec_zone_page_state(page, NR_LAZYFREE_PAGES);
 		page->mapping = NULL;
+	}
 	for (i = 0; i < (1 << order); i++)
 		bad += free_pages_check(page + i);
 	if (bad)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0ab38faebe98..98a1c3ffcaab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -832,6 +832,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				if (!page_freeze_refs(page, 1))
 					goto keep_locked;
 				unlock_page(page);
+				count_vm_event(PGLAZYFREE);
 				goto free_it;
 			}
 		}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index def5dd2fbe61..4235aeb9b96e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -742,6 +742,7 @@ const char * const vmstat_text[] = {
 	"nr_active_file",
 	"nr_unevictable",
 	"nr_mlock",
+	"nr_lazyfree_pages",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
@@ -789,6 +790,7 @@ const char * const vmstat_text[] = {
 
 	"pgfault",
 	"pgmajfault",
+	"pglazyfree",
 
 	TEXTS_FOR_ZONES("pgrefill")
 	TEXTS_FOR_ZONES("pgsteal_kswapd")
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
