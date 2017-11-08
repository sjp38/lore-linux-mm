Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 379B24403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 06:12:52 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t139so2173911wmt.7
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 03:12:52 -0800 (PST)
Received: from techadventures.net ([62.201.165.239])
        by mx.google.com with ESMTP id 64si3330595wrk.548.2017.11.08.03.12.50
        for <linux-mm@kvack.org>;
        Wed, 08 Nov 2017 03:12:51 -0800 (PST)
Date: Wed, 8 Nov 2017 12:12:50 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH] mm: move alloc_node_mem_map within CONFIG_FLAT_NODE_MEM_MAP
 block
Message-ID: <20171108111250.GA5401@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I was checking free_area_init_node() and I saw that it calls
alloc_node_mem_map(), but this function does nothing unless
we have CONFIG_FLAT_NODE_MEM_MAP, so we might want to:

a) move the call within the #ifdef CONFIG_FLAT_NODE_MEM_MAP block
that follows afterwards.
b) now, alloc_node_mem_map() has the bulk of its code within #ifdef CONFIG_FLAT_NODE_MEM_MAP,
so I guess we can put the whole function within an #ifdef CONFIG_FLAT_NODE_MEM_MAP block.

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..36c501971b28 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6126,6 +6126,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	}
 }
 
+#ifdef CONFIG_FLAT_NODE_MEM_MAP
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 {
 	unsigned long __maybe_unused start = 0;
@@ -6135,7 +6136,6 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 	if (!pgdat->node_spanned_pages)
 		return;
 
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
 	start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
 	offset = pgdat->node_start_pfn - start;
 	/* ia64 gets its own node_mem_map, before this, without bootmem */
@@ -6169,8 +6169,8 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 	}
 #endif
-#endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
+#endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
@@ -6196,8 +6196,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
 				  zones_size, zholes_size);
 
-	alloc_node_mem_map(pgdat);
 #ifdef CONFIG_FLAT_NODE_MEM_MAP
+	alloc_node_mem_map(pgdat);
 	printk(KERN_DEBUG "free_area_init_node: node %d, pgdat %08lx, node_mem_map %08lx\n",
 		nid, (unsigned long)pgdat,
 		(unsigned long)pgdat->node_mem_map);
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
