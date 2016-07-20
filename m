Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5FB6B025E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 11:21:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so36299913wme.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:21:56 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id gf19si1355344wjc.286.2016.07.20.08.21.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 08:21:52 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 48C609902C
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 15:21:52 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/5] mm, vmscan: Remove highmem_file_pages
Date: Wed, 20 Jul 2016 16:21:49 +0100
Message-Id: <1469028111-1622-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

With the reintroduction of per-zone LRU stats, highmem_file_pages is
redundant so remove it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm_inline.h | 17 -----------------
 mm/page-writeback.c       | 12 ++++--------
 2 files changed, 4 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 9cc130f5feb2..71613e8a720f 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -4,22 +4,6 @@
 #include <linux/huge_mm.h>
 #include <linux/swap.h>
 
-#ifdef CONFIG_HIGHMEM
-extern atomic_t highmem_file_pages;
-
-static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
-							int nr_pages)
-{
-	if (is_highmem_idx(zid) && is_file_lru(lru))
-		atomic_add(nr_pages, &highmem_file_pages);
-}
-#else
-static inline void acct_highmem_file_pages(int zid, enum lru_list lru,
-							int nr_pages)
-{
-}
-#endif
-
 /**
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
@@ -47,7 +31,6 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
 	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
 	__mod_zone_page_state(&pgdat->node_zones[zid],
 				NR_ZONE_LRU_BASE + lru, nr_pages);
-	acct_highmem_file_pages(zid, lru, nr_pages);
 }
 
 static __always_inline void update_lru_size(struct lruvec *lruvec,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 573d138fa7a5..cfa78124c3c2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -299,17 +299,13 @@ static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
 
 	return nr_pages;
 }
-#ifdef CONFIG_HIGHMEM
-atomic_t highmem_file_pages;
-#endif
 
 static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
 	int node;
-	unsigned long x;
+	unsigned long x = 0;
 	int i;
-	unsigned long dirtyable = 0;
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
 		for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
@@ -326,12 +322,12 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 			nr_pages = zone_page_state(z, NR_FREE_PAGES);
 			/* watch for underflows */
 			nr_pages -= min(nr_pages, high_wmark_pages(z));
-			dirtyable += nr_pages;
+			nr_pages += zone_page_state(z, NR_INACTIVE_FILE);
+			nr_pages += zone_page_state(z, NR_ACTIVE_FILE);
+			x += nr_pages;
 		}
 	}
 
-	x = dirtyable + atomic_read(&highmem_file_pages);
-
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
 	 * without swap) can bring down the dirtyable pages below
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
