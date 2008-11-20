Date: Thu, 20 Nov 2008 01:16:16 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/7] mm: remove GFP_HIGHUSER_PAGECACHE
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200115050.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

GFP_HIGHUSER_PAGECACHE is just an alias for GFP_HIGHUSER_MOVABLE,
making that harder to track down: remove it, and its out-of-work
brothers GFP_NOFS_PAGECACHE and GFP_USER_PAGECACHE.

Since we're making that improvement to hotremove_migrate_alloc(),
I think we can now also remove one of the "o"s from its comment.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 fs/inode.c          |    4 ++--
 include/linux/gfp.h |    6 ------
 mm/memory_hotplug.c |    9 +++------
 3 files changed, 5 insertions(+), 14 deletions(-)

--- mmclean2/fs/inode.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean3/fs/inode.c	2008-11-19 15:26:16.000000000 +0000
@@ -164,7 +164,7 @@ struct inode *inode_init_always(struct s
 	mapping->a_ops = &empty_aops;
 	mapping->host = inode;
 	mapping->flags = 0;
-	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_PAGECACHE);
+	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
 	mapping->assoc_mapping = NULL;
 	mapping->backing_dev_info = &default_backing_dev_info;
 	mapping->writeback_index = 0;
@@ -599,7 +599,7 @@ EXPORT_SYMBOL_GPL(inode_add_to_lists);
  *	@sb: superblock
  *
  *	Allocates a new inode for given superblock. The default gfp_mask
- *	for allocations related to inode->i_mapping is GFP_HIGHUSER_PAGECACHE.
+ *	for allocations related to inode->i_mapping is GFP_HIGHUSER_MOVABLE.
  *	If HIGHMEM pages are unsuitable or it is known that pages allocated
  *	for the page cache are not reclaimable or migratable,
  *	mapping_set_gfp_mask() must be called with suitable flags on the
--- mmclean2/include/linux/gfp.h	2008-11-19 15:25:12.000000000 +0000
+++ mmclean3/include/linux/gfp.h	2008-11-19 15:26:16.000000000 +0000
@@ -70,12 +70,6 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
-#define GFP_NOFS_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_MOVABLE)
-#define GFP_USER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
-				 __GFP_HARDWALL | __GFP_MOVABLE)
-#define GFP_HIGHUSER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
-				 __GFP_HARDWALL | __GFP_HIGHMEM | \
-				 __GFP_MOVABLE)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
--- mmclean2/mm/memory_hotplug.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean3/mm/memory_hotplug.c	2008-11-19 15:26:16.000000000 +0000
@@ -626,15 +626,12 @@ int scan_lru_pages(unsigned long start, 
 }
 
 static struct page *
-hotremove_migrate_alloc(struct page *page,
-			unsigned long private,
-			int **x)
+hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
 {
-	/* This should be improoooooved!! */
-	return alloc_page(GFP_HIGHUSER_PAGECACHE);
+	/* This should be improooooved!! */
+	return alloc_page(GFP_HIGHUSER_MOVABLE);
 }
 
-
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
 static int
 do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
