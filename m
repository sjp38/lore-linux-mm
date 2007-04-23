Message-Id: <20070423062131.611972880@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:23 -0700
From: clameter@sgi.com
Subject: [RFC 16/16] Variable Order Page Cache: Alternate implementation of page cache macros
Content-Disposition: inline; filename=var_pc_alternate
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

Implement the page cache macros in a more efficient way by storing key
values in the mapping. This reduces code size but increases inode size.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/fs.h      |    4 +++-
 include/linux/pagemap.h |   13 +++++++------
 2 files changed, 10 insertions(+), 7 deletions(-)

Index: linux-2.6.21-rc7/include/linux/fs.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/fs.h	2007-04-22 19:43:01.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/fs.h	2007-04-22 19:44:29.000000000 -0700
@@ -435,7 +435,9 @@ struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
 	rwlock_t		tree_lock;	/* and rwlock protecting it */
-	unsigned int		order;		/* Page order in this space */
+	unsigned int		shift;		/* Shift for to get to the page number */
+	unsigned int		order;		/* Page order for allocations */
+	loff_t			offset_mask;	/* To mask out offset in page */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
Index: linux-2.6.21-rc7/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/pagemap.h	2007-04-22 19:44:16.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/pagemap.h	2007-04-22 19:46:23.000000000 -0700
@@ -42,7 +42,8 @@ static inline void mapping_set_gfp_mask(
 static inline void set_mapping_order(struct address_space *m, int order)
 {
 	m->order = order;
-
+	m->shift = order + PAGE_SHIFT;
+	m->offset_mask = (1UL << m->shift) -1;
 	if (order)
 		m->flags |= __GFP_COMP;
 	else
@@ -64,23 +65,23 @@ static inline void set_mapping_order(str
 
 static inline int page_cache_shift(struct address_space *a)
 {
-	return a->order + PAGE_SHIFT;
+	return a->shift;
 }
 
 static inline unsigned int page_cache_size(struct address_space *a)
 {
-	return PAGE_SIZE << a->order;
+	return a->offset_mask + 1;
 }
 
 static inline loff_t page_cache_mask(struct address_space *a)
 {
-	return (loff_t)PAGE_MASK << a->order;
+	return ~(loff_t)a->offset_mask;
 }
 
 static inline unsigned int page_cache_offset(struct address_space *a,
 		loff_t pos)
 {
-	return pos & ~(PAGE_MASK << a->order);
+	return pos & a->offset_mask;
 }
 
 static inline pgoff_t page_cache_index(struct address_space *a,
@@ -95,7 +96,7 @@ static inline pgoff_t page_cache_index(s
 static inline pgoff_t page_cache_next(struct address_space *a,
 		loff_t pos)
 {
-	return page_cache_index(a, pos + page_cache_size(a) - 1);
+	return page_cache_index(a, pos + a->offset_mask);
 }
 
 static inline loff_t page_cache_pos(struct address_space *a,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
