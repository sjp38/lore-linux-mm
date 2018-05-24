Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86AD36B0010
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 74-v6so9996032wme.0
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q31-v6si5122734eda.207.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 4/5] mm: rename and change semantics of nr_indirectly_reclaimable_bytes
Date: Thu, 24 May 2018 13:00:10 +0200
Message-Id: <20180524110011.1940-5-vbabka@suse.cz>
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
References: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

The vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES was introduced by commit
eb59254608bc ("mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES") with the goal of
accounting objects that can be reclaimed, but cannot be allocated via a
SLAB_RECLAIM_ACCOUNT cache. This is now possible via kmalloc() with
__GFP_RECLAIMABLE flag, and the dcache external names user is converted.

The counter is however still useful for accounting direct page allocations
(i.e. not slab) with a shrinker, such as the ION page pool. So keep it, and:

- change granularity to pages to be more like other counters; sub-page
  allocations should be able to use kmalloc
- rename the counter to NR_RECLAIMABLE
- expose the counter again in vmstat as "nr_reclaimable"; we can again remove
  the check for not printing "hidden" counters
- make the counter include also SLAB_RECLAIM_ACCOUNT, so it covers all
  shrinker-based (i.e. not page cache) reclaimable pages

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/staging/android/ion/ion_page_pool.c |  4 ++--
 include/linux/mmzone.h                      |  2 +-
 mm/page_alloc.c                             | 15 ++++-----------
 mm/slab.c                                   | 12 ++++++++----
 mm/util.c                                   | 16 +++++-----------
 mm/vmstat.c                                 |  6 +-----
 6 files changed, 21 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/android/ion/ion_page_pool.c b/drivers/staging/android/ion/ion_page_pool.c
index 9bc56eb48d2a..11e6e694f425 100644
--- a/drivers/staging/android/ion/ion_page_pool.c
+++ b/drivers/staging/android/ion/ion_page_pool.c
@@ -33,8 +33,8 @@ static void ion_page_pool_add(struct ion_page_pool *pool, struct page *page)
 		pool->low_count++;
 	}
 
-	mod_node_page_state(page_pgdat(page), NR_INDIRECTLY_RECLAIMABLE_BYTES,
-			    (1 << (PAGE_SHIFT + pool->order)));
+	mod_node_page_state(page_pgdat(page), NR_RECLAIMABLE,
+							1 << pool->order);
 	mutex_unlock(&pool->mutex);
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..4343948f33e5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -180,7 +180,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
-	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
+	NR_RECLAIMABLE,         /* all reclaimable pages, including slab */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 249546393bd6..6f22fec0df54 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4708,6 +4708,7 @@ long si_mem_available(void)
 	unsigned long pagecache;
 	unsigned long wmark_low = 0;
 	unsigned long pages[NR_LRU_LISTS];
+	unsigned long reclaimable;
 	struct zone *zone;
 	int lru;
 
@@ -4733,19 +4734,11 @@ long si_mem_available(void)
 	available += pagecache;
 
 	/*
-	 * Part of the reclaimable slab consists of items that are in use,
+	 * Part of the reclaimable pages consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
 	 */
-	available += global_node_page_state(NR_SLAB_RECLAIMABLE) -
-		     min(global_node_page_state(NR_SLAB_RECLAIMABLE) / 2,
-			 wmark_low);
-
-	/*
-	 * Part of the kernel memory, which can be released under memory
-	 * pressure.
-	 */
-	available += global_node_page_state(NR_INDIRECTLY_RECLAIMABLE_BYTES) >>
-		PAGE_SHIFT;
+	reclaimable = global_node_page_state(NR_RECLAIMABLE);
+	available += reclaimable - min(reclaimable / 2,  wmark_low);
 
 	if (available < 0)
 		available = 0;
diff --git a/mm/slab.c b/mm/slab.c
index 4dd7d73a1972..a2a8c0802253 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1420,10 +1420,12 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	}
 
 	nr_pages = (1 << cachep->gfporder);
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT) {
 		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, nr_pages);
-	else
+		mod_node_page_state(page_pgdat(page), NR_RECLAIMABLE, nr_pages);
+	} else {
 		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, nr_pages);
+	}
 
 	__SetPageSlab(page);
 	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
@@ -1441,10 +1443,12 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	int order = cachep->gfporder;
 	unsigned long nr_freed = (1 << order);
 
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT) {
 		mod_lruvec_page_state(page, NR_SLAB_RECLAIMABLE, -nr_freed);
-	else
+		mod_node_page_state(page_pgdat(page), NR_RECLAIMABLE, -nr_freed);
+	} else {
 		mod_lruvec_page_state(page, NR_SLAB_UNRECLAIMABLE, -nr_freed);
+	}
 
 	BUG_ON(!PageSlab(page));
 	__ClearPageSlabPfmemalloc(page);
diff --git a/mm/util.c b/mm/util.c
index 98180a994895..3ffd92a9778a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -662,19 +662,13 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		free += get_nr_swap_pages();
 
 		/*
-		 * Any slabs which are created with the
+		 * Pages accounted as reclaimable.
+		 * This includes any slabs which are created with the
 		 * SLAB_RECLAIM_ACCOUNT flag claim to have contents
-		 * which are reclaimable, under pressure.  The dentry
-		 * cache and most inode caches should fall into this
+		 * which are reclaimable, under pressure. The dentry
+		 * cache and most inode caches should fall into this.
 		 */
-		free += global_node_page_state(NR_SLAB_RECLAIMABLE);
-
-		/*
-		 * Part of the kernel memory, which can be released
-		 * under memory pressure.
-		 */
-		free += global_node_page_state(
-			NR_INDIRECTLY_RECLAIMABLE_BYTES) >> PAGE_SHIFT;
+		free += global_node_page_state(NR_RECLAIMABLE);
 
 		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 75eda9c2b260..21d571da9d5a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1161,7 +1161,7 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
-	"", /* nr_indirectly_reclaimable */
+	"nr_reclaimable",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
@@ -1704,10 +1704,6 @@ static int vmstat_show(struct seq_file *m, void *arg)
 	unsigned long *l = arg;
 	unsigned long off = l - (unsigned long *)m->private;
 
-	/* Skip hidden vmstat items. */
-	if (*vmstat_text[off] == '\0')
-		return 0;
-
 	seq_puts(m, vmstat_text[off]);
 	seq_put_decimal_ull(m, " ", *l);
 	seq_putc(m, '\n');
-- 
2.17.0
