Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD39E6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 06:19:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u97so10945914wrc.3
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 03:19:36 -0800 (PST)
Received: from techadventures.net ([62.201.165.239])
        by mx.google.com with ESMTP id 46si16470747wrw.433.2017.11.14.03.19.35
        for <linux-mm@kvack.org>;
        Tue, 14 Nov 2017 03:19:35 -0800 (PST)
Date: Tue, 14 Nov 2017 12:19:35 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v1] mm: make alloc_node_mem_map a voidcall if we don't have
 CONFIG_FLAT_NODE_MEM_MAP
Message-ID: <20171114111935.GA11758@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@kernel.org, mgorman@techsingularity.net, vbabka@suse.cz

free_area_init_node() calls alloc_node_mem_map(), but this function
does nothing unless we have CONFIG_FLAT_NODE_MEM_MAP.

As a cleanup, we can move the "#ifdef CONFIG_FLAT_NODE_MEM_MAP" within
alloc_node_mem_map() out of the function, and define a
alloc_node_mem_map() { } when CONFIG_FLAT_NODE_MEM_MAP is not present.

This also moves the printk, that lays within the "#ifdef CONFIG_FLAT_NODE_MEM_MAP" block,
from free_area_init_node() to alloc_node_mem_map(), getting rid of the
"#ifdef CONFIG_FLAT_NODE_MEM_MAP" in free_area_init_node().

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_alloc.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c5c57b..56400b5d3183 100644
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
@@ -6157,6 +6157,9 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 							       pgdat->node_id);
 		pgdat->node_mem_map = map + offset;
 	}
+	printk(KERN_DEBUG "alloc_node_mem_map: node %d, pgdat %08lx, node_mem_map %08lx\n",
+							pgdat->node_id, (unsigned long)pgdat,
+							(unsigned long)pgdat->node_mem_map);
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 	/*
 	 * With no DISCONTIG, the global mem_map is just set as node 0's
@@ -6169,8 +6172,10 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 	}
 #endif
-#endif /* CONFIG_FLAT_NODE_MEM_MAP */
 }
+#else
+static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
+#endif /* CONFIG_FLAT_NODE_MEM_MAP */
 
 void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		unsigned long node_start_pfn, unsigned long *zholes_size)
@@ -6197,11 +6202,6 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 				  zones_size, zholes_size);
 
 	alloc_node_mem_map(pgdat);
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
-	printk(KERN_DEBUG "free_area_init_node: node %d, pgdat %08lx, node_mem_map %08lx\n",
-		nid, (unsigned long)pgdat,
-		(unsigned long)pgdat->node_mem_map);
-#endif
 
 	reset_deferred_meminit(pgdat);
 	free_area_init_core(pgdat);
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
