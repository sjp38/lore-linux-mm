Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6C46B026B
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:18:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f65-v6so5153832wmd.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:18:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m52-v6si6715926edc.418.2018.06.18.02.18.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:18:28 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 5/7] mm: rename and change semantics of nr_indirectly_reclaimable_bytes
Date: Mon, 18 Jun 2018 11:18:06 +0200
Message-Id: <20180618091808.4419-6-vbabka@suse.cz>
In-Reply-To: <20180618091808.4419-1-vbabka@suse.cz>
References: <20180618091808.4419-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

The vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES was introduced by commit
eb59254608bc ("mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES") with the goal of
accounting objects that can be reclaimed, but cannot be allocated via a
SLAB_RECLAIM_ACCOUNT cache. This is now possible via kmalloc() with
__GFP_RECLAIMABLE flag, and the dcache external names user is converted.

The counter is however still useful for accounting direct page allocations
(i.e. not slab) with a shrinker, such as the ION page pool. So keep it, and:

- change granularity to pages to be more like other counters; sub-page
  allocations should be able to use kmalloc
- rename the counter to NR_KERNEL_MISC_RECLAIMABLE
- expose the counter again in vmstat as "nr_kernel_misc_reclaimable"; we can
  again remove the check for not printing "hidden" counters

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Vijayanand Jitta <vjitta@codeaurora.org>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>
---
 drivers/staging/android/ion/ion_page_pool.c |  4 ++--
 include/linux/mmzone.h                      |  2 +-
 mm/page_alloc.c                             | 19 +++++++------------
 mm/util.c                                   |  3 +--
 mm/vmstat.c                                 |  6 +-----
 5 files changed, 12 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/android/ion/ion_page_pool.c b/drivers/staging/android/ion/ion_page_pool.c
index 9bc56eb48d2a..b7ad2d2449ac 100644
--- a/drivers/staging/android/ion/ion_page_pool.c
+++ b/drivers/staging/android/ion/ion_page_pool.c
@@ -33,8 +33,8 @@ static void ion_page_pool_add(struct ion_page_pool *pool, struct page *page)
 		pool->low_count++;
 	}
 
-	mod_node_page_state(page_pgdat(page), NR_INDIRECTLY_RECLAIMABLE_BYTES,
-			    (1 << (PAGE_SHIFT + pool->order)));
+	mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
+							1 << pool->order);
 	mutex_unlock(&pool->mutex);
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2dc52a..c2f6bc4c9e8a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -180,7 +180,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
-	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
+	NR_KERNEL_MISC_RECLAIMABLE,	/* reclaimable non-slab kernel pages */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..8ceb45e11b97 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4704,6 +4704,7 @@ long si_mem_available(void)
 	unsigned long pagecache;
 	unsigned long wmark_low = 0;
 	unsigned long pages[NR_LRU_LISTS];
+	unsigned long reclaimable;
 	struct zone *zone;
 	int lru;
 
@@ -4729,19 +4730,13 @@ long si_mem_available(void)
 	available += pagecache;
 
 	/*
-	 * Part of the reclaimable slab consists of items that are in use,
-	 * and cannot be freed. Cap this estimate at the low watermark.
+	 * Part of the reclaimable slab and other kernel memory consists of
+	 * items that are in use, and cannot be freed. Cap this estimate at the
+	 * low watermark.
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
+	reclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE) +
+			global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
+	available += reclaimable - min(reclaimable / 2, wmark_low);
 
 	if (available < 0)
 		available = 0;
diff --git a/mm/util.c b/mm/util.c
index 3351659200e6..891f0654e7b5 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -675,8 +675,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * Part of the kernel memory, which can be released
 		 * under memory pressure.
 		 */
-		free += global_node_page_state(
-			NR_INDIRECTLY_RECLAIMABLE_BYTES) >> PAGE_SHIFT;
+		free += global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
 
 		/*
 		 * Leave reserved pages. The pages are not for anonymous pages.
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 75eda9c2b260..7c677d3a61ec 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1161,7 +1161,7 @@ const char * const vmstat_text[] = {
 	"nr_vmscan_immediate_reclaim",
 	"nr_dirtied",
 	"nr_written",
-	"", /* nr_indirectly_reclaimable */
+	"nr_kernel_misc_reclaimable",
 
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
2.17.1
