Date: Fri, 16 Feb 2007 14:38:37 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: per-CPU replicated pagecache (for testing)
Message-ID: <20070216133837.GD3036@wotan.suse.de>
References: <20070216133748.GC3036@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070216133748.GC3036@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Trial the replicated pagecache on non-NUMA machines by doing per-CPU
replication. Actually there is a slight change in one algorithm because
there is no such thing as page_to_cpuid.

To minimise the code change, this just pretends smp_processor_id returns
a node id. Technically this will blow up if you have more CPUs than
MAX_NUMNODES.

 mm/replication.c |   29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

Index: linux-2.6/mm/replication.c
===================================================================
--- linux-2.6.orig/mm/replication.c
+++ linux-2.6/mm/replication.c
@@ -98,9 +98,6 @@ static int should_replicate_pcache(struc
 	if (unlikely(PageSwapCache(page)))
 		return 0;
 
-	if (nid == page_to_nid(page))
-		return 0;
-
 	if (page_count(page) != 2 + page_mapcount(page))
 		return 0;
 	smp_rmb();
@@ -133,7 +130,7 @@ static int try_to_replicate_pcache(struc
 	if (!pcd)
 		goto out;
 
-	page_node = page_to_nid(page);
+	page_node = smp_processor_id();
 	pcd->master = page;
 	node_set(page_node, pcd->nodes_present);
 	if (radix_tree_insert(&pcd->page_tree, page_node, page))
@@ -143,7 +140,7 @@ static int try_to_replicate_pcache(struc
 
 	/* The non-racy check */
 	if (unlikely(!should_replicate_pcache(page, mapping, offset,
-							numa_node_id())))
+							smp_processor_id())))
 		goto out_lock;
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree, offset);
@@ -269,13 +266,18 @@ failed:
 static void __remove_replicated_page(struct pcache_desc *pcd, struct page *page,
 			struct address_space *mapping, unsigned long offset)
 {
-	int nid = page_to_nid(page);
+	int nid;
 	BUG_ON(page == pcd->master);
-	/* XXX: page->mapping = NULL; ? */
-	BUG_ON(!node_isset(nid, pcd->nodes_present));
-	BUG_ON(radix_tree_delete(&pcd->page_tree, nid) != page);
-	node_clear(nid, pcd->nodes_present);
-	__dec_zone_page_state(page, NR_REPL_PAGES);
+	for_each_node_mask(nid, pcd->nodes_present) {
+		/* XXX: page->mapping = NULL; ? */
+		if (radix_tree_lookup(&pcd->page_tree, nid) != page)
+			continue;
+		BUG_ON(radix_tree_delete(&pcd->page_tree, nid) != page);
+		node_clear(nid, pcd->nodes_present);
+		__dec_zone_page_state(page, NR_REPL_PAGES);
+		return;
+	}
+	BUG();
 }
 
 /*
@@ -309,8 +311,7 @@ static struct page *try_to_create_replic
 {
 	struct page *repl_page;
 
-	repl_page = alloc_pages_node(nid, mapping_gfp_mask(mapping) |
-					  __GFP_THISNODE | __GFP_NORETRY, 0);
+	repl_page = page_cache_alloc(mapping);
 	if (!repl_page)
 		return page; /* failed alloc, just return the master */
 
@@ -343,7 +344,7 @@ struct page * find_get_page_readonly(str
 
 retry:
 	read_lock_irq(&mapping->tree_lock);
-	nid = numa_node_id();
+	nid = smp_processor_id();
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (is_pcache_desc(page)) {
 		struct pcache_desc *pcd;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
