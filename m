From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301100309.29753.51339.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
References: <20070301100229.29753.86342.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/12] Add __GFP_MOVABLE for callers to flag allocations from high memory that may be migrated
Date: Thu,  1 Mar 2007 10:03:10 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It is often known at allocation time whether a page may be migrated or
not. This patch adds a flag called __GFP_MOVABLE and a new mask called
GFP_HIGH_MOVABLE. Allocations using the __GFP_MOVABLE can be either migrated
using the page migration mechanism or reclaimed by syncing with backing
storage and discarding.

An API function very similar to alloc_zeroed_user_highpage() is added for
__GFP_MOVABLE allocations called alloc_zeroed_user_highpage_movable(). The
flags used by alloc_zeroed_user_highpage() are not changed because it would
change the semantics of an existing API. After this patch is applied there
are no in-kernel users of alloc_zeroed_user_highpage() so it probably should
be marked deprecated if this patch is merged.

Note that this patch includes a minor cleanup to the use of __GFP_ZERO
in shmem.c to keep all flag modifications to inode->mapping in the
shmem_dir_alloc() helper function. This clean-up suggestion is courtesy of
Hugh Dickens.

Additional credit goes to Christoph Lameter and Linus Torvalds for shaping
the concept. Credit to Hugh Dickens for catching issues with shmem swap
vector and ramfs allocations.

[hugh@veritas.com: __GFP_ZERO cleanup]

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 fs/inode.c                |   10 ++++++--
 fs/ramfs/inode.c          |    1 
 include/asm-alpha/page.h  |    3 +-
 include/asm-cris/page.h   |    3 +-
 include/asm-h8300/page.h  |    3 +-
 include/asm-i386/page.h   |    3 +-
 include/asm-ia64/page.h   |    5 ++--
 include/asm-m32r/page.h   |    3 +-
 include/asm-s390/page.h   |    3 +-
 include/asm-x86_64/page.h |    3 +-
 include/linux/gfp.h       |   10 +++++++-
 include/linux/highmem.h   |   51 +++++++++++++++++++++++++++++++++++++++--
 mm/memory.c               |    8 +++---
 mm/mempolicy.c            |    4 +--
 mm/migrate.c              |    2 -
 mm/shmem.c                |    7 ++++-
 mm/swap_prefetch.c        |    2 -
 mm/swap_state.c           |    2 -
 18 files changed, 98 insertions(+), 25 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/fs/inode.c linux-2.6.20-mm2-002_clustering_flags/fs/inode.c
--- linux-2.6.20-mm2-001_pageblock_bits/fs/inode.c	2007-02-19 01:21:38.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/fs/inode.c	2007-02-20 18:25:33.000000000 +0000
@@ -145,7 +145,7 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
-		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
+		mapping_set_gfp_mask(mapping, GFP_HIGH_MOVABLE);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
 
@@ -521,7 +521,13 @@ repeat:
  *	new_inode 	- obtain an inode
  *	@sb: superblock
  *
- *	Allocates a new inode for given superblock.
+ *	Allocates a new inode for given superblock. The default gfp_mask
+ *	for allocations related to inode->i_mapping is GFP_HIGH_MOVABLE. If
+ *	HIGHMEM pages are unsuitable or it is known that pages allocated
+ *	for the page cache are not reclaimable or migratable,
+ *	mapping_set_gfp_mask() must be called with suitable flags on the
+ *	newly created inode's mapping
+ *
  */
 struct inode *new_inode(struct super_block *sb)
 {
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/fs/ramfs/inode.c linux-2.6.20-mm2-002_clustering_flags/fs/ramfs/inode.c
--- linux-2.6.20-mm2-001_pageblock_bits/fs/ramfs/inode.c	2007-02-19 01:21:42.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/fs/ramfs/inode.c	2007-02-20 18:25:33.000000000 +0000
@@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
 		inode->i_blocks = 0;
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
+		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-alpha/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-alpha/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-alpha/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-alpha/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -17,7 +17,8 @@
 extern void clear_page(void *page);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vmaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vmaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 extern void copy_page(void * _to, void * _from);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-cris/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-cris/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-cris/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-cris/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -20,7 +20,8 @@
 #define clear_user_page(page, vaddr, pg)    clear_page(page)
 #define copy_user_page(to, from, vaddr, pg) copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-h8300/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-h8300/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-h8300/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-h8300/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -22,7 +22,8 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-i386/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-i386/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-i386/page.h	2007-02-19 01:21:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-i386/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -34,7 +34,8 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-ia64/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-ia64/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-ia64/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-ia64/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -87,9 +87,10 @@ do {						\
 } while (0)
 
 
-#define alloc_zeroed_user_highpage(vma, vaddr) \
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
 ({						\
-	struct page *page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr); \
+	struct page *page = alloc_page_vma(
+		GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr); \
 	if (page)				\
  		flush_dcache_page(page);	\
 	page;					\
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-m32r/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-m32r/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-m32r/page.h	2007-02-19 01:21:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-m32r/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -15,7 +15,8 @@ extern void copy_page(void *to, void *fr
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-s390/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-s390/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-s390/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-s390/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -64,7 +64,8 @@ static inline void copy_page(void *to, v
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/asm-x86_64/page.h linux-2.6.20-mm2-002_clustering_flags/include/asm-x86_64/page.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/asm-x86_64/page.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/asm-x86_64/page.h	2007-02-20 18:25:33.000000000 +0000
@@ -51,7 +51,8 @@ void copy_page(void *, void *);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 /*
  * These are used to make use of C type-checking..
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/linux/gfp.h linux-2.6.20-mm2-002_clustering_flags/include/linux/gfp.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/linux/gfp.h	2007-02-19 01:22:30.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/linux/gfp.h	2007-02-20 18:25:33.000000000 +0000
@@ -30,6 +30,9 @@ struct vm_area_struct;
  * cannot handle allocation failures.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely.
+ *
+ * __GFP_MOVABLE: Flag that this page will be movable by the page migration
+ * mechanism or reclaimed
  */
 #define __GFP_WAIT	((__force gfp_t)0x10u)	/* Can wait and reschedule? */
 #define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
@@ -46,6 +49,7 @@ struct vm_area_struct;
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_MOVABLE	((__force gfp_t)0x80000u) /* Page is movable */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -54,7 +58,8 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
+			__GFP_MOVABLE)
 
 /* This equals 0, but use constants in case they ever change */
 #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
@@ -66,6 +71,9 @@ struct vm_area_struct;
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
+#define GFP_HIGH_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_HIGHMEM | \
+				 __GFP_MOVABLE)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/include/linux/highmem.h linux-2.6.20-mm2-002_clustering_flags/include/linux/highmem.h
--- linux-2.6.20-mm2-001_pageblock_bits/include/linux/highmem.h	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/include/linux/highmem.h	2007-02-20 18:25:33.000000000 +0000
@@ -62,10 +62,27 @@ static inline void clear_user_highpage(s
 }
 
 #ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
+/**
+ * __alloc_zeroed_user_highpage - Allocate a zeroed HIGHMEM page for a VMA with caller-specified movable GFP flags
+ * @movableflags: The GFP flags related to the pages future ability to move like __GFP_MOVABLE
+ * @vma: The VMA the page is to be allocated for
+ * @vaddr: The virtual address the page will be inserted into
+ *
+ * This function will allocate a page for a VMA but the caller is expected
+ * to specify via movableflags whether the page will be movable in the
+ * future or not
+ *
+ * An architecture may override this function by defining
+ * __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE and providing their own
+ * implementation.
+ */
 static inline struct page *
-alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+__alloc_zeroed_user_highpage(gfp_t movableflags,
+			struct vm_area_struct *vma,
+			unsigned long vaddr)
 {
-	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
+	struct page *page = alloc_page_vma(GFP_HIGHUSER | movableflags,
+			vma, vaddr);
 
 	if (page)
 		clear_user_highpage(page, vaddr);
@@ -74,6 +91,36 @@ alloc_zeroed_user_highpage(struct vm_are
 }
 #endif
 
+/**
+ * alloc_zeroed_user_highpage - Allocate a zeroed HIGHMEM page for a VMA
+ * @vma: The VMA the page is to be allocated for
+ * @vaddr: The virtual address the page will be inserted into
+ *
+ * This function will allocate a page for a VMA that the caller knows will
+ * not be able to move in the future using move_pages() or reclaim. If it
+ * is known that the page can move, use alloc_zeroed_user_highpage_movable
+ */
+static inline struct page *
+alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	return __alloc_zeroed_user_highpage(0, vma, vaddr);
+}
+
+/**
+ * alloc_zeroed_user_highpage_movable - Allocate a zeroed HIGHMEM page for a VMA that the caller knows can move
+ * @vma: The VMA the page is to be allocated for
+ * @vaddr: The virtual address the page will be inserted into
+ *
+ * This function will allocate a page for a VMA that the caller knows will
+ * be able to migrate in the future using move_pages() or reclaimed
+ */
+static inline struct page *
+alloc_zeroed_user_highpage_movable(struct vm_area_struct *vma,
+					unsigned long vaddr)
+{
+	return __alloc_zeroed_user_highpage(__GFP_MOVABLE, vma, vaddr);
+}
+
 static inline void clear_highpage(struct page *page)
 {
 	void *kaddr = kmap_atomic(page, KM_USER0);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/memory.c linux-2.6.20-mm2-002_clustering_flags/mm/memory.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/memory.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/memory.c	2007-02-20 18:25:33.000000000 +0000
@@ -1761,11 +1761,11 @@ gotten:
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	if (old_page == ZERO_PAGE(address)) {
-		new_page = alloc_zeroed_user_highpage(vma, address);
+		new_page = alloc_zeroed_user_highpage_movable(vma, address);
 		if (!new_page)
 			goto oom;
 	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
+		new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
 		if (!new_page)
 			goto oom;
 		cow_user_page(new_page, old_page, address, vma);
@@ -2283,7 +2283,7 @@ static int do_anonymous_page(struct mm_s
 
 		if (unlikely(anon_vma_prepare(vma)))
 			goto oom;
-		page = alloc_zeroed_user_highpage(vma, address);
+		page = alloc_zeroed_user_highpage_movable(vma, address);
 		if (!page)
 			goto oom;
 
@@ -2384,7 +2384,7 @@ retry:
 
 			if (unlikely(anon_vma_prepare(vma)))
 				goto oom;
-			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
+			page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
 			if (!page)
 				goto oom;
 			copy_user_highpage(page, new_page, address, vma);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/mempolicy.c linux-2.6.20-mm2-002_clustering_flags/mm/mempolicy.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/mempolicy.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/mempolicy.c	2007-02-20 18:25:33.000000000 +0000
@@ -603,7 +603,7 @@ static void migrate_page_add(struct page
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_node(node, GFP_HIGHUSER, 0);
+	return alloc_pages_node(node, GFP_HIGH_MOVABLE, 0);
 }
 
 /*
@@ -719,7 +719,7 @@ static struct page *new_vma_page(struct 
 {
 	struct vm_area_struct *vma = (struct vm_area_struct *)private;
 
-	return alloc_page_vma(GFP_HIGHUSER, vma, page_address_in_vma(page, vma));
+	return alloc_page_vma(GFP_HIGH_MOVABLE, vma, page_address_in_vma(page, vma));
 }
 #else
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/migrate.c linux-2.6.20-mm2-002_clustering_flags/mm/migrate.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/migrate.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/migrate.c	2007-02-20 18:25:33.000000000 +0000
@@ -755,7 +755,7 @@ static struct page *new_page_node(struct
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node, GFP_HIGHUSER | GFP_THISNODE, 0);
+	return alloc_pages_node(pm->node, GFP_HIGH_MOVABLE | GFP_THISNODE, 0);
 }
 
 /*
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/shmem.c linux-2.6.20-mm2-002_clustering_flags/mm/shmem.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/shmem.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/shmem.c	2007-02-20 18:25:33.000000000 +0000
@@ -93,8 +93,11 @@ static inline struct page *shmem_dir_all
 	 * The above definition of ENTRIES_PER_PAGE, and the use of
 	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
 	 * might be reconsidered if it ever diverges from PAGE_SIZE.
+	 *
+	 * __GFP_MOVABLE is masked out as swap vectors cannot move
 	 */
-	return alloc_pages(gfp_mask, PAGE_CACHE_SHIFT-PAGE_SHIFT);
+	return alloc_pages((gfp_mask & ~__GFP_MOVABLE) | __GFP_ZERO,
+				PAGE_CACHE_SHIFT-PAGE_SHIFT);
 }
 
 static inline void shmem_dir_free(struct page *page)
@@ -371,7 +374,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 		}
 
 		spin_unlock(&info->lock);
-		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping) | __GFP_ZERO);
+		page = shmem_dir_alloc(mapping_gfp_mask(inode->i_mapping));
 		if (page)
 			set_page_private(page, 0);
 		spin_lock(&info->lock);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/swap_prefetch.c linux-2.6.20-mm2-002_clustering_flags/mm/swap_prefetch.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/swap_prefetch.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/swap_prefetch.c	2007-02-20 18:25:33.000000000 +0000
@@ -204,7 +204,7 @@ static enum trickle_return trickle_swap_
 	 * Get a new page to read from swap. We have already checked the
 	 * watermarks so __alloc_pages will not call on reclaim.
 	 */
-	page = alloc_pages_node(node, GFP_HIGHUSER & ~__GFP_WAIT, 0);
+	page = alloc_pages_node(node, GFP_HIGH_MOVABLE & ~__GFP_WAIT, 0);
 	if (unlikely(!page)) {
 		ret = TRICKLE_DELAY;
 		goto out;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-001_pageblock_bits/mm/swap_state.c linux-2.6.20-mm2-002_clustering_flags/mm/swap_state.c
--- linux-2.6.20-mm2-001_pageblock_bits/mm/swap_state.c	2007-02-19 01:22:35.000000000 +0000
+++ linux-2.6.20-mm2-002_clustering_flags/mm/swap_state.c	2007-02-20 18:25:33.000000000 +0000
@@ -340,7 +340,7 @@ struct page *read_swap_cache_async(swp_e
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
+			new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
