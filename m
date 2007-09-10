From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112211.3097.86408.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/13] Group short-lived and reclaimable kernel allocations
Date: Mon, 10 Sep 2007 12:22:11 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Group short-lived and reclaimable kernel allocations
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch marks a number of allocations that are either short-lived such as
network buffers or are reclaimable such as inode allocations.  When something
like updatedb is called, long-lived and unmovable kernel allocations tend to
be spread throughout the address space which increases fragmentation.

This patch groups these allocations together as much as possible by adding a
new MIGRATE_TYPE.  The MIGRATE_RECLAIMABLE type is for allocations that can be
reclaimed on demand, but not moved.  i.e.  they can be migrated by deleting
them and re-reading the information from elsewhere.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/buffer.c                     |    3 ++-
 fs/jbd/journal.c                |    4 ++--
 fs/jbd/revoke.c                 |    6 ++++--
 fs/proc/base.c                  |   13 +++++++------
 fs/proc/generic.c               |    2 +-
 include/linux/gfp.h             |   15 ++++++++++++---
 include/linux/mmzone.h          |    5 +++--
 include/linux/pageblock-flags.h |    2 +-
 include/linux/slab.h            |    4 +++-
 kernel/cpuset.c                 |    2 +-
 lib/radix-tree.c                |    6 ++++--
 mm/page_alloc.c                 |   10 +++++++---
 mm/shmem.c                      |    4 ++--
 mm/slab.c                       |    2 ++
 mm/slub.c                       |    3 +++
 15 files changed, 54 insertions(+), 27 deletions(-)

Index: linux-2.6.23-rc4-mm1-redropped/fs/buffer.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/fs/buffer.c	2007-09-09 18:23:34.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/fs/buffer.c	2007-09-09 18:26:16.000000000 +0100
@@ -3100,7 +3100,8 @@
 	
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep, gfp_flags);
+	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep,
+				set_migrateflags(gfp_flags, __GFP_RECLAIMABLE));
 	if (ret) {
 		INIT_LIST_HEAD(&ret->b_assoc_buffers);
 		get_cpu_var(bh_accounting).nr++;
Index: linux-2.6.23-rc4-mm1-redropped/fs/jbd/journal.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/fs/jbd/journal.c	2007-08-28 02:32:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/fs/jbd/journal.c	2007-09-09 18:26:17.000000000 +0100
@@ -1710,7 +1710,7 @@
 	journal_head_cache = kmem_cache_create("journal_head",
 				sizeof(struct journal_head),
 				0,		/* offset */
-				0,		/* flags */
+				SLAB_TEMPORARY,	/* flags */
 				NULL);		/* ctor */
 	retval = 0;
 	if (journal_head_cache == 0) {
@@ -2006,7 +2006,7 @@
 	jbd_handle_cache = kmem_cache_create("journal_handle",
 				sizeof(handle_t),
 				0,		/* offset */
-				0,		/* flags */
+				SLAB_TEMPORARY,	/* flags */
 				NULL);		/* ctor */
 	if (jbd_handle_cache == NULL) {
 		printk(KERN_EMERG "JBD: failed to create handle cache\n");
Index: linux-2.6.23-rc4-mm1-redropped/fs/jbd/revoke.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/fs/jbd/revoke.c	2007-08-28 02:32:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/fs/jbd/revoke.c	2007-09-09 18:23:35.000000000 +0100
@@ -170,13 +170,15 @@
 {
 	revoke_record_cache = kmem_cache_create("revoke_record",
 					   sizeof(struct jbd_revoke_record_s),
-					   0, SLAB_HWCACHE_ALIGN, NULL);
+					   0,
+					   SLAB_HWCACHE_ALIGN|SLAB_TEMPORARY,
+					   NULL);
 	if (revoke_record_cache == 0)
 		return -ENOMEM;
 
 	revoke_table_cache = kmem_cache_create("revoke_table",
 					   sizeof(struct jbd_revoke_table_s),
-					   0, 0, NULL);
+					   0, SLAB_TEMPORARY, NULL);
 	if (revoke_table_cache == 0) {
 		kmem_cache_destroy(revoke_record_cache);
 		revoke_record_cache = NULL;
Index: linux-2.6.23-rc4-mm1-redropped/fs/proc/base.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/fs/proc/base.c	2007-08-28 02:32:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/fs/proc/base.c	2007-09-09 18:27:51.000000000 +0100
@@ -492,7 +492,7 @@
 		count = PROC_BLOCK_SIZE;
 
 	length = -ENOMEM;
-	if (!(page = __get_free_page(GFP_KERNEL)))
+	if (!(page = __get_free_page(GFP_TEMPORARY)))
 		goto out;
 
 	length = PROC_I(inode)->op.proc_read(task, (char*)page);
@@ -532,7 +532,7 @@
 		goto out;
 
 	ret = -ENOMEM;
-	page = (char *)__get_free_page(GFP_USER);
+	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
@@ -602,7 +602,7 @@
 		goto out;
 
 	copied = -ENOMEM;
-	page = (char *)__get_free_page(GFP_USER);
+	page = (char *)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
@@ -788,7 +788,7 @@
 		/* No partial writes. */
 		return -EINVAL;
 	}
-	page = (char*)__get_free_page(GFP_USER);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		return -ENOMEM;
 	length = -EFAULT;
@@ -954,7 +954,8 @@
 			    char __user *buffer, int buflen)
 {
 	struct inode * inode;
-	char *tmp = (char*)__get_free_page(GFP_KERNEL), *path;
+	char *tmp = (char*)__get_free_page(GFP_TEMPORARY);
+	char *path;
 	int len;
 
 	if (!tmp)
@@ -1726,7 +1727,7 @@
 		goto out;
 
 	length = -ENOMEM;
-	page = (char*)__get_free_page(GFP_USER);
+	page = (char*)__get_free_page(GFP_TEMPORARY);
 	if (!page)
 		goto out;
 
Index: linux-2.6.23-rc4-mm1-redropped/fs/proc/generic.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/fs/proc/generic.c	2007-08-28 02:32:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/fs/proc/generic.c	2007-09-09 18:23:35.000000000 +0100
@@ -74,7 +74,7 @@
 		nbytes = MAX_NON_LFS - pos;
 
 	dp = PDE(inode);
-	if (!(page = (char*) __get_free_page(GFP_KERNEL)))
+	if (!(page = (char*) __get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	while ((nbytes > 0) && !eof) {
Index: linux-2.6.23-rc4-mm1-redropped/include/linux/gfp.h
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/include/linux/gfp.h	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/include/linux/gfp.h	2007-09-09 18:28:08.000000000 +0100
@@ -48,9 +48,10 @@
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
-#define __GFP_MOVABLE	((__force gfp_t)0x80000u) /* Page is movable */
+#define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
+#define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
 
-#define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
@@ -60,6 +61,8 @@
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
+#define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
 #define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
 			 __GFP_HIGHMEM)
@@ -80,7 +83,7 @@
 #endif
 
 /* This mask makes up all the page movable related flags */
-#define GFP_MOVABLE_MASK (__GFP_MOVABLE)
+#define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
@@ -129,6 +132,12 @@
 	return base + ZONE_NORMAL;
 }
 
+static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
+{
+	BUG_ON((gfp & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+	return (gfp & ~(GFP_MOVABLE_MASK)) | migrate_flags;
+}
+
 /*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such
Index: linux-2.6.23-rc4-mm1-redropped/include/linux/mmzone.h
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/include/linux/mmzone.h	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/include/linux/mmzone.h	2007-09-09 18:27:53.000000000 +0100
@@ -34,8 +34,9 @@
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
 #define MIGRATE_UNMOVABLE     0
-#define MIGRATE_MOVABLE       1
-#define MIGRATE_TYPES         2
+#define MIGRATE_RECLAIMABLE   1
+#define MIGRATE_MOVABLE       2
+#define MIGRATE_TYPES         3
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
Index: linux-2.6.23-rc4-mm1-redropped/include/linux/pageblock-flags.h
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/include/linux/pageblock-flags.h	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/include/linux/pageblock-flags.h	2007-09-09 18:27:49.000000000 +0100
@@ -31,7 +31,7 @@
 
 /* Bit indices that affect a whole block of pages */
 enum pageblock_bits {
-	PB_range(PB_migrate, 1), /* 1 bit required for migrate types */
+	PB_range(PB_migrate, 2), /* 2 bits required for migrate types */
 	NR_PAGEBLOCK_BITS
 };
 
Index: linux-2.6.23-rc4-mm1-redropped/include/linux/slab.h
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/include/linux/slab.h	2007-08-28 02:32:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/include/linux/slab.h	2007-09-09 18:23:35.000000000 +0100
@@ -24,12 +24,14 @@
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
-#define SLAB_RECLAIM_ACCOUNT	0x00020000UL	/* Objects are reclaimable */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
 #define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
+/* The following flags affect the page allocator grouping pages by mobility */
+#define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
+#define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
Index: linux-2.6.23-rc4-mm1-redropped/kernel/cpuset.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/kernel/cpuset.c	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/kernel/cpuset.c	2007-09-09 18:27:30.000000000 +0100
@@ -1463,7 +1463,7 @@
 	ssize_t retval = 0;
 	char *s;
 
-	if (!(page = (char *)__get_free_page(GFP_KERNEL)))
+	if (!(page = (char *)__get_free_page(GFP_TEMPORARY)))
 		return -ENOMEM;
 
 	s = page;
Index: linux-2.6.23-rc4-mm1-redropped/lib/radix-tree.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/lib/radix-tree.c	2007-09-09 18:23:33.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/lib/radix-tree.c	2007-09-09 18:23:35.000000000 +0100
@@ -98,7 +98,8 @@
 	struct radix_tree_node *ret;
 	gfp_t gfp_mask = root_gfp_mask(root);
 
-	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
+	ret = kmem_cache_alloc(radix_tree_node_cachep,
+				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
 	if (ret == NULL && !(gfp_mask & __GFP_WAIT)) {
 		struct radix_tree_preload *rtp;
 
@@ -142,7 +143,8 @@
 	rtp = &__get_cpu_var(radix_tree_preloads);
 	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 		preempt_enable();
-		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
+		node = kmem_cache_alloc(radix_tree_node_cachep,
+				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
 		if (node == NULL)
 			goto out;
 		preempt_disable();
Index: linux-2.6.23-rc4-mm1-redropped/mm/page_alloc.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/mm/page_alloc.c	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/mm/page_alloc.c	2007-09-09 18:27:53.000000000 +0100
@@ -175,7 +175,10 @@
 
 static inline int allocflags_to_migratetype(gfp_t gfp_flags)
 {
-	return ((gfp_flags & __GFP_MOVABLE) != 0);
+	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
+
+	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
+		((gfp_flags & __GFP_RECLAIMABLE) != 0);
 }
 
 #ifdef CONFIG_DEBUG_VM
@@ -662,8 +665,9 @@
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE] = { MIGRATE_MOVABLE   },
-	[MIGRATE_MOVABLE]   = { MIGRATE_UNMOVABLE },
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE   },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE   },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE },
 };
 
 /* Remove an element from the buddy allocator from the fallback list */
Index: linux-2.6.23-rc4-mm1-redropped/mm/shmem.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/mm/shmem.c	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/mm/shmem.c	2007-09-09 18:27:48.000000000 +0100
@@ -95,9 +95,9 @@
 	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
 	 * might be reconsidered if it ever diverges from PAGE_SIZE.
 	 *
-	 * __GFP_MOVABLE is masked out as swap vectors cannot move
+	 * Mobility flags are masked out as swap vectors cannot move
 	 */
-	return alloc_pages((gfp_mask & ~__GFP_MOVABLE) | __GFP_ZERO,
+	return alloc_pages((gfp_mask & ~GFP_MOVABLE_MASK) | __GFP_ZERO,
 				PAGE_CACHE_SHIFT-PAGE_SHIFT);
 }
 
Index: linux-2.6.23-rc4-mm1-redropped/mm/slab.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/mm/slab.c	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/mm/slab.c	2007-09-09 18:26:54.000000000 +0100
@@ -1643,6 +1643,8 @@
 #endif
 
 	flags |= cachep->gfpflags;
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+		flags |= __GFP_RECLAIMABLE;
 
 	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
 	if (!page)
Index: linux-2.6.23-rc4-mm1-redropped/mm/slub.c
===================================================================
--- linux-2.6.23-rc4-mm1-redropped.orig/mm/slub.c	2007-09-09 18:23:35.000000000 +0100
+++ linux-2.6.23-rc4-mm1-redropped/mm/slub.c	2007-09-09 18:27:50.000000000 +0100
@@ -1046,6 +1046,9 @@
 	if (s->flags & SLAB_CACHE_DMA)
 		flags |= SLUB_DMA;
 
+	if (s->flags & SLAB_RECLAIM_ACCOUNT)
+		flags |= __GFP_RECLAIMABLE;
+
 	if (node == -1)
 		page = alloc_pages(flags, s->order);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
