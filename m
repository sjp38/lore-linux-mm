Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B47E26B0027
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 11:32:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c16so4312857pgv.8
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 08:32:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d23si4538667pgn.3.2018.03.22.08.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 08:32:14 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 8/8] page_frag: Account allocations
Date: Thu, 22 Mar 2018 08:31:57 -0700
Message-Id: <20180322153157.10447-9-willy@infradead.org>
In-Reply-To: <20180322153157.10447-1-willy@infradead.org>
References: <20180322153157.10447-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, netdev@vger.kernel.org, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Note the number of pages currently used in page_frag allocations.
This may help diagnose leaks in page_frag users.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mmzone.h |  3 ++-
 mm/page_alloc.c        | 10 +++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7522a6987595..ed6be33dcc7a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -139,10 +139,10 @@ enum zone_stat_item {
 	NR_ZONE_ACTIVE_FILE,
 	NR_ZONE_UNEVICTABLE,
 	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
+	/* Second 128 byte cacheline */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_PAGETABLE,		/* used for pagetables */
 	NR_KERNEL_STACK_KB,	/* measured in KiB */
-	/* Second 128 byte cacheline */
 	NR_BOUNCE,
 #if IS_ENABLED(CONFIG_ZSMALLOC)
 	NR_ZSPAGES,		/* allocated in zsmalloc */
@@ -175,6 +175,7 @@ enum node_stat_item {
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
 	NR_ANON_THPS,
+	NR_PAGE_FRAG,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b9beafa5d2a5..5a9441b46604 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4382,6 +4382,7 @@ static void *__page_frag_cache_refill(struct page_frag_cache *pfc,
 		return NULL;
 	}
 
+	inc_node_page_state(page, NR_PAGE_FRAG);
 	/* Using atomic_set() would break get_page_unless_zero() users. */
 	page_ref_add(page, size - 1);
 reset:
@@ -4460,8 +4461,10 @@ void page_frag_free(void *addr)
 {
 	struct page *page = virt_to_head_page(addr);
 
-	if (unlikely(put_page_testzero(page)))
+	if (unlikely(put_page_testzero(page))) {
+		dec_node_page_state(page, NR_PAGE_FRAG);
 		__free_pages_ok(page, compound_order(page));
+	}
 }
 EXPORT_SYMBOL(page_frag_free);
 
@@ -4769,7 +4772,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free:%lu free_pcp:%lu free_cma:%lu\n",
+		" free:%lu free_pcp:%lu free_cma:%lu page_frag:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
 		global_node_page_state(NR_ISOLATED_ANON),
@@ -4788,7 +4791,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_zone_page_state(NR_BOUNCE),
 		global_zone_page_state(NR_FREE_PAGES),
 		free_pcp,
-		global_zone_page_state(NR_FREE_CMA_PAGES));
+		global_zone_page_state(NR_FREE_CMA_PAGES),
+		global_node_page_state(NR_PAGE_FRAG));
 
 	for_each_online_pgdat(pgdat) {
 		if (show_mem_node_skip(filter, pgdat->node_id, nodemask))
-- 
2.16.2
