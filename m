Date: Fri, 27 Jul 2007 16:27:53 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-ID: <20070727232753.GA10311@localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Don't go into zone_reclaim if there are no reclaimable pages.

While using RAMFS as scratch space for some tests, we found one of the
processes got into zone reclaim, and got stuck trying to reclaim pages
from a zone.  On examination of the code, we found that the VM was fooled
into believing that the zone had reclaimable pages, when it actually had
RAMFS backed pages, which could not be written back to the disk.

Fix this by adding a zvc "NR_PSEUDO_FS_PAGES" for file pages with no
backing store, and using this counter to determine if reclaim is possible.

Patch tested,on 2.6.22.  Fixes the above mentioned problem.

Comments?

Signed-off-by: Alok Kataria <alok.kataria@calsoftinc.com>
Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
Signed-off-by: Shai Fultheim <shai@scalex86.org>

Index: linux-2.6.22/drivers/base/node.c
===================================================================
--- linux-2.6.22.orig/drivers/base/node.c
+++ linux-2.6.22/drivers/base/node.c
@@ -61,6 +61,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Mapped:       %8lu kB\n"
 		       "Node %d AnonPages:    %8lu kB\n"
 		       "Node %d PageTables:   %8lu kB\n"
+		       "Node %d PseudoFS:     %8lu kB\n"
 		       "Node %d NFS_Unstable: %8lu kB\n"
 		       "Node %d Bounce:       %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n"
@@ -83,6 +84,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
+		       nid, K(node_page_state(nid, NR_PSEUDO_FS_PAGES)),
 		       nid, K(node_page_state(nid, NR_UNSTABLE_NFS)),
 		       nid, K(node_page_state(nid, NR_BOUNCE)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
Index: linux-2.6.22/include/linux/mmzone.h
===================================================================
--- linux-2.6.22.orig/include/linux/mmzone.h
+++ linux-2.6.22/include/linux/mmzone.h
@@ -55,6 +55,7 @@ enum zone_stat_item {
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
+	NR_PSEUDO_FS_PAGES, /* FS pages witn no backing store eg. ramfs */
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
 	/* Second 128 byte cacheline */
Index: linux-2.6.22/mm/filemap.c
===================================================================
--- linux-2.6.22.orig/mm/filemap.c
+++ linux-2.6.22/mm/filemap.c
@@ -119,6 +119,8 @@ void __remove_from_page_cache(struct pag
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
+	if (mapping->backing_dev_info->capabilities & BDI_CAP_NO_WRITEBACK)
+		__dec_zone_page_state(page, NR_PSEUDO_FS_PAGES);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 }
 
@@ -448,6 +450,9 @@ int add_to_page_cache(struct page *page,
 			page->mapping = mapping;
 			page->index = offset;
 			mapping->nrpages++;
+			if (mapping->backing_dev_info->capabilities
+				& BDI_CAP_NO_WRITEBACK)
+				__inc_zone_page_state(page, NR_PSEUDO_FS_PAGES);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
 		write_unlock_irq(&mapping->tree_lock);
Index: linux-2.6.22/mm/migrate.c
===================================================================
--- linux-2.6.22.orig/mm/migrate.c
+++ linux-2.6.22/mm/migrate.c
@@ -346,6 +346,11 @@ static int migrate_page_move_mapping(str
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
+	if (mapping->backing_dev_info->capabilities & BDI_CAP_NO_WRITEBACK) {
+		__dec_zone_page_state(page, NR_PSEUDO_FS_PAGES);
+		__inc_zone_page_state(newpage, NR_PSEUDO_FS_PAGES);
+	}
+
 	write_unlock_irq(&mapping->tree_lock);
 
 	return 0;
Index: linux-2.6.22/mm/vmscan.c
===================================================================
--- linux-2.6.22.orig/mm/vmscan.c
+++ linux-2.6.22/mm/vmscan.c
@@ -1627,6 +1627,7 @@ static int __zone_reclaim(struct zone *z
 		.swappiness = vm_swappiness,
 	};
 	unsigned long slab_reclaimable;
+	long unmapped_reclaimable;
 
 	disable_swap_token();
 	cond_resched();
@@ -1639,9 +1640,10 @@ static int __zone_reclaim(struct zone *z
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	if (zone_page_state(zone, NR_FILE_PAGES) -
-		zone_page_state(zone, NR_FILE_MAPPED) >
-		zone->min_unmapped_pages) {
+	unmapped_reclaimable = zone_page_state(zone, NR_FILE_PAGES) -
+				zone_page_state(zone, NR_PSEUDO_FS_PAGES) -
+				zone_page_state(zone, NR_FILE_MAPPED);
+	if (unmapped_reclaimable > (long) zone->min_unmapped_pages) {
 		/*
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
@@ -1688,6 +1690,7 @@ int zone_reclaim(struct zone *zone, gfp_
 {
 	cpumask_t mask;
 	int node_id;
+	long unmapped_reclaimable;
 
 	/*
 	 * Zone reclaim reclaims unmapped file backed pages and
@@ -1699,8 +1702,10 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * if less than a specified percentage of the zone is used by
 	 * unmapped file backed pages.
 	 */
-	if (zone_page_state(zone, NR_FILE_PAGES) -
-	    zone_page_state(zone, NR_FILE_MAPPED) <= zone->min_unmapped_pages
+	unmapped_reclaimable = zone_page_state(zone, NR_FILE_PAGES) -
+				zone_page_state(zone, NR_PSEUDO_FS_PAGES) -
+				zone_page_state(zone, NR_FILE_MAPPED);
+	if (unmapped_reclaimable <= (long) zone->min_unmapped_pages
 	    && zone_page_state(zone, NR_SLAB_RECLAIMABLE)
 			<= zone->min_slab_pages)
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
