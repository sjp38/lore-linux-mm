From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070517101143.3113.60295.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070517101022.3113.15456.sendpatchset@skynet.skynet.ie>
References: <20070517101022.3113.15456.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/5] Rename GFP_HIGH_MOVABLE to GFP_HIGHUSER_MOVABLE
Date: Thu, 17 May 2007 11:11:43 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

__GFP_HIGH are used to flag allocations that can access emergency
pools. GFP_HIGH_MOVABLE has little to do with __GFP_HIGH and the name is
misleading. This patch renames GFP_HIGH_MOVABLE to GFP_HIGHUSER_MOVABLE so
that it is clearer.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Christoph Lameter <clameter@sgi.com>
---

 fs/inode.c          |    6 +++---
 include/linux/gfp.h |    2 +-
 mm/hugetlb.c        |    2 +-
 mm/memory.c         |    5 +++--
 mm/mempolicy.c      |    5 +++--
 mm/migrate.c        |    3 ++-
 mm/page_alloc.c     |    2 +-
 mm/swap_prefetch.c  |    2 +-
 mm/swap_state.c     |    3 ++-
 9 files changed, 17 insertions(+), 13 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/fs/inode.c linux-2.6.22-rc1-mm1-025_gfphighuser/fs/inode.c
--- linux-2.6.22-rc1-mm1-020_temporary/fs/inode.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/fs/inode.c	2007-05-16 23:05:45.000000000 +0100
@@ -154,7 +154,7 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
-		mapping_set_gfp_mask(mapping, GFP_HIGH_MOVABLE);
+		mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
 
@@ -535,8 +535,8 @@ repeat:
  *	@sb: superblock
  *
  *	Allocates a new inode for given superblock. The default gfp_mask
- *	for allocations related to inode->i_mapping is GFP_HIGH_MOVABLE. If
- *	HIGHMEM pages are unsuitable or it is known that pages allocated
+ *	for allocations related to inode->i_mapping is GFP_HIGHUSER_MOVABLE.
+ *	If HIGHMEM pages are unsuitable or it is known that pages allocated
  *	for the page cache are not reclaimable or migratable,
  *	mapping_set_gfp_mask() must be called with suitable flags on the
  *	newly created inode's mapping
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/include/linux/gfp.h linux-2.6.22-rc1-mm1-025_gfphighuser/include/linux/gfp.h
--- linux-2.6.22-rc1-mm1-020_temporary/include/linux/gfp.h	2007-05-16 23:04:06.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/include/linux/gfp.h	2007-05-16 23:05:45.000000000 +0100
@@ -76,7 +76,7 @@ struct vm_area_struct;
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
-#define GFP_HIGH_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+#define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/hugetlb.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/hugetlb.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/hugetlb.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/hugetlb.c	2007-05-16 23:05:45.000000000 +0100
@@ -267,7 +267,7 @@ int hugetlb_treat_movable_handler(struct
 {
 	proc_dointvec(table, write, file, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
-		htlb_alloc_mask = GFP_HIGH_MOVABLE;
+		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
 	else
 		htlb_alloc_mask = GFP_HIGHUSER;
 	return 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/memory.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/memory.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/memory.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/memory.c	2007-05-16 23:05:45.000000000 +0100
@@ -1746,7 +1746,7 @@ gotten:
 		if (!new_page)
 			goto oom;
 	} else {
-		new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
+		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 		if (!new_page)
 			goto oom;
 		cow_user_page(new_page, old_page, address, vma);
@@ -2392,7 +2392,8 @@ static int __do_fault(struct mm_struct *
 				fdata.type = VM_FAULT_OOM;
 				goto out;
 			}
-			page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
+			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
+								vma, address);
 			if (!page) {
 				fdata.type = VM_FAULT_OOM;
 				goto out;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/mempolicy.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/mempolicy.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/mempolicy.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/mempolicy.c	2007-05-16 23:05:45.000000000 +0100
@@ -594,7 +594,7 @@ static void migrate_page_add(struct page
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_node(node, GFP_HIGH_MOVABLE, 0);
+	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
@@ -710,7 +710,8 @@ static struct page *new_vma_page(struct 
 {
 	struct vm_area_struct *vma = (struct vm_area_struct *)private;
 
-	return alloc_page_vma(GFP_HIGH_MOVABLE, vma, page_address_in_vma(page, vma));
+	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
+					page_address_in_vma(page, vma));
 }
 #else
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/migrate.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/migrate.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/migrate.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/migrate.c	2007-05-16 23:05:45.000000000 +0100
@@ -761,7 +761,8 @@ static struct page *new_page_node(struct
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node, GFP_HIGH_MOVABLE | GFP_THISNODE, 0);
+	return alloc_pages_node(pm->node,
+				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/page_alloc.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/page_alloc.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/page_alloc.c	2007-05-16 10:54:18.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/page_alloc.c	2007-05-16 23:05:46.000000000 +0100
@@ -1844,7 +1844,7 @@ unsigned int nr_free_buffer_pages(void)
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-	return nr_free_zone_pages(gfp_zone(GFP_HIGH_MOVABLE));
+	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
 }
 
 static inline void show_node(struct zone *zone)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/swap_prefetch.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/swap_prefetch.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/swap_prefetch.c	2007-05-16 10:54:19.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/swap_prefetch.c	2007-05-16 23:05:46.000000000 +0100
@@ -208,7 +208,7 @@ static enum trickle_return trickle_swap_
 	 * Get a new page to read from swap. We have already checked the
 	 * watermarks so __alloc_pages will not call on reclaim.
 	 */
-	page = alloc_pages_node(node, GFP_HIGH_MOVABLE & ~__GFP_WAIT, 0);
+	page = alloc_pages_node(node, GFP_HIGHUSER_MOVABLE & ~__GFP_WAIT, 0);
 	if (unlikely(!page)) {
 		ret = TRICKLE_DELAY;
 		goto out;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc1-mm1-020_temporary/mm/swap_state.c linux-2.6.22-rc1-mm1-025_gfphighuser/mm/swap_state.c
--- linux-2.6.22-rc1-mm1-020_temporary/mm/swap_state.c	2007-05-16 10:54:19.000000000 +0100
+++ linux-2.6.22-rc1-mm1-025_gfphighuser/mm/swap_state.c	2007-05-16 23:05:46.000000000 +0100
@@ -341,7 +341,8 @@ struct page *read_swap_cache_async(swp_e
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, addr);
+			new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
+								vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
