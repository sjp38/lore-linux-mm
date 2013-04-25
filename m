Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id DCAB76B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 17:41:19 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id 14so492510pdj.27
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 14:41:19 -0700 (PDT)
Date: Thu, 25 Apr 2013 14:41:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: add anon_hugepage stat
Message-ID: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

This exports the amount of anonymous transparent hugepages for each memcg
via memory.stat in bytes.

This is helpful to determine the hugepage utilization for individual jobs
on the system in comparison to rss and opportunities where MADV_HUGEPAGE
may be helpful.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |  3 ++-
 mm/huge_memory.c           |  2 ++
 mm/memcontrol.c            | 13 +++++++++----
 mm/rmap.c                  | 18 +++++++++++++++---
 4 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -32,7 +32,8 @@ struct kmem_cache;
 
 /* Stats that can be updated by kernel. */
 enum mem_cgroup_page_stat_item {
-	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+	MEMCG_NR_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEMCG_NR_ANON_HUGEPAGE,	/* # of anon transparent hugepages */
 };
 
 struct mem_cgroup_reclaim_cookie {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1651,6 +1651,8 @@ static void __split_huge_page_refcount(struct page *page)
 	atomic_sub(tail_count, &page->_count);
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
+	mem_cgroup_update_page_stat(page, MEMCG_NR_ANON_HUGEPAGE,
+				    -HPAGE_PMD_NR);
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
 	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -91,10 +91,11 @@ enum mem_cgroup_stat_index {
 	/*
 	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
 	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
+	MEM_CGROUP_STAT_ANON_HUGEPAGE,	/* # of anon transparent hugepages */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -103,6 +104,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"rss",
 	"mapped_file",
 	"swap",
+	"anon_hugepage",
 };
 
 enum mem_cgroup_events_index {
@@ -2217,6 +2219,9 @@ void mem_cgroup_update_page_stat(struct page *page,
 	case MEMCG_NR_FILE_MAPPED:
 		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
+	case MEMCG_NR_ANON_HUGEPAGE:
+		idx = MEM_CGROUP_STAT_ANON_HUGEPAGE;
+		break;
 	default:
 		BUG();
 	}
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1057,9 +1057,13 @@ void do_page_add_anon_rmap(struct page *page,
 	if (first) {
 		if (!PageTransHuge(page))
 			__inc_zone_page_state(page, NR_ANON_PAGES);
-		else
+		else {
+			mem_cgroup_update_page_stat(page,
+						    MEMCG_NR_ANON_HUGEPAGE,
+						    HPAGE_PMD_NR);
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+		}
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1090,8 +1094,12 @@ void page_add_new_anon_rmap(struct page *page,
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (!PageTransHuge(page))
 		__inc_zone_page_state(page, NR_ANON_PAGES);
-	else
+	else {
+		mem_cgroup_update_page_stat(page,
+					    MEMCG_NR_ANON_HUGEPAGE,
+					    HPAGE_PMD_NR);
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	}
 	__page_set_anon_rmap(page, vma, address, 1);
 	if (!mlocked_vma_newpage(vma, page))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
@@ -1152,9 +1160,13 @@ void page_remove_rmap(struct page *page)
 		mem_cgroup_uncharge_page(page);
 		if (!PageTransHuge(page))
 			__dec_zone_page_state(page, NR_ANON_PAGES);
-		else
+		else {
+			mem_cgroup_update_page_stat(page,
+						    MEMCG_NR_ANON_HUGEPAGE,
+						    -HPAGE_PMD_NR);
 			__dec_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+		}
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
