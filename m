Message-ID: <3CB3BA80.3B2FA724@zip.com.au>
Date: Tue, 09 Apr 2002 21:07:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: [patch] Velikov/Hellwig radix-tree pagecache
References: <20020409104753.A490@infradead.org> <3CB3A44C.C9884437@zip.com.au>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

It was tested for a couple of hours under heavy load, 4 CPU.
It works fine.   Here's the rolled-up diff against -pre3.

Before the mempool was added, the VM was getting many, many
0-order allocation failures due to the atomic ratnode
allocations inside swap_out.  That monster mempool is
doing its job - drove a 256meg machine a gigabyte into
swap with no ratnode allocation failures at all.

So we do need to trim that pool a bit, and also handle
the case where swap_out fails, and not just keep
pointlessly calling it.


--- 2.5.8-pre3/drivers/block/rd.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/drivers/block/rd.c	Tue Apr  9 20:35:31 2002
@@ -156,7 +156,6 @@ static int rd_blkdev_pagecache_IO(int rw
 
 	do {
 		int count;
-		struct page ** hash;
 		struct page * page;
 		char * src, * dst;
 		int unlock = 0;
@@ -166,8 +165,7 @@ static int rd_blkdev_pagecache_IO(int rw
 			count = size;
 		size -= count;
 
-		hash = page_hash(mapping, index);
-		page = __find_get_page(mapping, index, hash);
+		page = find_get_page(mapping, index);
 		if (!page) {
 			page = grab_cache_page(mapping, index);
 			err = -ENOMEM;
--- 2.5.8-pre3/fs/inode.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/fs/inode.c	Tue Apr  9 20:35:31 2002
@@ -143,6 +143,8 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_dirty_data_buffers);
 	INIT_LIST_HEAD(&inode->i_devices);
 	sema_init(&inode->i_sem, 1);
+	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
+	rwlock_init(&inode->i_data.page_lock);
 	spin_lock_init(&inode->i_data.i_shared_lock);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap);
 	INIT_LIST_HEAD(&inode->i_data.i_mmap_shared);
--- 2.5.8-pre3/include/linux/fs.h~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/include/linux/fs.h	Tue Apr  9 20:35:31 2002
@@ -21,6 +21,7 @@
 #include <linux/cache.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
+#include <linux/radix-tree.h>
 
 #include <asm/atomic.h>
 #include <asm/bitops.h>
@@ -370,6 +371,8 @@ struct address_space_operations {
 };
 
 struct address_space {
+	struct radix_tree_root	page_tree;	/* radix tree of all pages */
+	rwlock_t		page_lock;	/* and rwlock protecting it */
 	struct list_head	clean_pages;	/* list of clean pages */
 	struct list_head	dirty_pages;	/* list of dirty pages */
 	struct list_head	locked_pages;	/* list of locked pages */
--- 2.5.8-pre3/include/linux/mm.h~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/include/linux/mm.h	Tue Apr  9 20:35:31 2002
@@ -149,14 +149,11 @@ typedef struct page {
 	struct list_head list;		/* ->mapping has some page lists. */
 	struct address_space *mapping;	/* The inode (or ...) we belong to. */
 	unsigned long index;		/* Our offset within mapping. */
-	struct page *next_hash;		/* Next page sharing our hash bucket in
-					   the pagecache hash table. */
 	atomic_t count;			/* Usage count, see below. */
 	unsigned long flags;		/* atomic flags, some possibly
 					   updated asynchronously */
 	struct list_head lru;		/* Pageout list, eg. active_list;
 					   protected by pagemap_lru_lock !! */
-	struct page **pprev_hash;	/* Complement to *next_hash. */
 	struct buffer_head * buffers;	/* Buffer maps us to a disk block. */
 
 	/*
@@ -236,9 +233,8 @@ typedef struct page {
  * using the page->list list_head. These fields are also used for
  * freelist managemet (when page->count==0).
  *
- * There is also a hash table mapping (mapping,index) to the page
- * in memory if present. The lists for this hash table use the fields
- * page->next_hash and page->pprev_hash.
+ * There is also a per-mapping radix tree mapping index to the page
+ * in memory if present. The tree is rooted at mapping->root.  
  *
  * All process pages can do I/O:
  * - inode pages may need to be read from disk,
--- 2.5.8-pre3/include/linux/pagemap.h~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/include/linux/pagemap.h	Tue Apr  9 20:35:31 2002
@@ -41,53 +41,39 @@ static inline struct page *page_cache_al
  */
 #define page_cache_entry(x)	virt_to_page(x)
 
-extern unsigned int page_hash_bits;
-#define PAGE_HASH_BITS (page_hash_bits)
-#define PAGE_HASH_SIZE (1 << PAGE_HASH_BITS)
-
-extern atomic_t page_cache_size; /* # of pages currently in the hash table */
-extern struct page **page_hash_table;
-
-extern void page_cache_init(unsigned long);
-
-/*
- * We use a power-of-two hash table to avoid a modulus,
- * and get a reasonable hash by knowing roughly how the
- * inode pointer and indexes are distributed (ie, we
- * roughly know which bits are "significant")
- *
- * For the time being it will work for struct address_space too (most of
- * them sitting inside the inodes). We might want to change it later.
- */
-static inline unsigned long _page_hashfn(struct address_space * mapping, unsigned long index)
-{
-#define i (((unsigned long) mapping)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
-#define s(x) ((x)+((x)>>PAGE_HASH_BITS))
-	return s(i+index) & (PAGE_HASH_SIZE-1);
-#undef i
-#undef s
-}
+extern atomic_t page_cache_size; /* # of pages currently in the page cache */
 
-#define page_hash(mapping,index) (page_hash_table+_page_hashfn(mapping,index))
-
-extern struct page * __find_get_page(struct address_space *mapping,
-				unsigned long index, struct page **hash);
-#define find_get_page(mapping, index) \
-	__find_get_page(mapping, index, page_hash(mapping, index))
-extern struct page * __find_lock_page (struct address_space * mapping,
-				unsigned long index, struct page **hash);
+extern struct page * find_get_page(struct address_space *mapping,
+				unsigned long index);
+extern struct page * find_lock_page(struct address_space *mapping,
+				unsigned long index);
+extern struct page * find_trylock_page(struct address_space *mapping,
+				unsigned long index);
 extern struct page * find_or_create_page(struct address_space *mapping,
 				unsigned long index, unsigned int gfp_mask);
 
+extern struct page * grab_cache_page(struct address_space *mapping,
+				unsigned long index);
+extern struct page * grab_cache_page_nowait(struct address_space *mapping,
+				unsigned long index);
+
+extern int add_to_page_cache(struct page *page,
+		struct address_space *mapping, unsigned long index);
+extern int add_to_page_cache_unique(struct page *page,
+		struct address_space *mapping, unsigned long index);
+static inline void ___add_to_page_cache(struct page *page,
+		struct address_space *mapping, unsigned long index)
+{
+	list_add(&page->list, &mapping->clean_pages);
+	page->mapping = mapping;
+	page->index = index;
+
+	mapping->nrpages++;
+	atomic_inc(&page_cache_size);
+}
+
 extern void FASTCALL(lock_page(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
-#define find_lock_page(mapping, index) \
-	__find_lock_page(mapping, index, page_hash(mapping, index))
-extern struct page *find_trylock_page(struct address_space *, unsigned long);
-
-extern void add_to_page_cache(struct page * page, struct address_space *mapping, unsigned long index);
-extern void add_to_page_cache_locked(struct page * page, struct address_space *mapping, unsigned long index);
-extern int add_to_page_cache_unique(struct page * page, struct address_space *mapping, unsigned long index, struct page **hash);
 
 extern void ___wait_on_page(struct page *);
 
@@ -99,9 +85,6 @@ static inline void wait_on_page(struct p
 
 extern void wake_up_page(struct page *);
 
-extern struct page * grab_cache_page (struct address_space *, unsigned long);
-extern struct page * grab_cache_page_nowait (struct address_space *, unsigned long);
-
 typedef int filler_t(void *, struct page*);
 
 extern struct page *read_cache_page(struct address_space *, unsigned long,
--- /dev/null	Thu Aug 30 13:30:55 2001
+++ 2.5.8-pre3-akpm/include/linux/radix-tree.h	Tue Apr  9 20:35:31 2002
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2001 Momchil Velikov
+ * Portions Copyright (C) 2001 Christoph Hellwig
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2, or (at
+ * your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _LINUX_RADIX_TREE_H
+#define _LINUX_RADIX_TREE_H
+
+struct radix_tree_node;
+
+#define RADIX_TREE_SLOT_RESERVED ((void *)~0UL)
+
+struct radix_tree_root {
+	unsigned int		height;
+	int			gfp_mask;
+	struct radix_tree_node	*rnode;
+};
+
+#define RADIX_TREE_INIT(mask)	{0, (mask), NULL}
+
+#define RADIX_TREE(name, mask) \
+	struct radix_tree_root name = RADIX_TREE_INIT(mask)
+
+#define INIT_RADIX_TREE(root, mask)	\
+do {					\
+	(root)->height = 0;		\
+	(root)->gfp_mask = (mask);	\
+	(root)->rnode = NULL;		\
+} while (0)
+
+extern int radix_tree_reserve(struct radix_tree_root *, unsigned long, void ***);
+extern int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
+extern void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
+extern int radix_tree_delete(struct radix_tree_root *, unsigned long);
+
+#endif /* _LINUX_RADIX_TREE_H */
--- 2.5.8-pre3/include/linux/swap.h~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/include/linux/swap.h	Tue Apr  9 20:35:31 2002
@@ -109,7 +109,7 @@ extern void __remove_inode_page(struct p
 struct task_struct;
 struct vm_area_struct;
 struct sysinfo;
-
+struct address_space;
 struct zone_t;
 
 /* linux/mm/swap.c */
@@ -139,6 +139,9 @@ extern void show_swap_cache_info(void);
 extern int add_to_swap_cache(struct page *, swp_entry_t);
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
+extern int move_to_swap_cache(struct page *page, swp_entry_t entry);
+extern int move_from_swap_cache(struct page *page, unsigned long index,
+		struct address_space *mapping);
 extern void free_page_and_swap_cache(struct page *page);
 extern struct page * lookup_swap_cache(swp_entry_t);
 extern struct page * read_swap_cache_async(swp_entry_t);
--- 2.5.8-pre3/init/main.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/init/main.c	Tue Apr  9 20:35:31 2002
@@ -69,6 +69,7 @@ extern void sbus_init(void);
 extern void sysctl_init(void);
 extern void signals_init(void);
 
+extern void radix_tree_init(void);
 extern void free_initmem(void);
 
 #ifdef CONFIG_TC
@@ -392,7 +393,7 @@ asmlinkage void __init start_kernel(void
 	proc_caches_init();
 	vfs_caches_init(mempages);
 	buffer_init(mempages);
-	page_cache_init(mempages);
+	radix_tree_init();
 #if defined(CONFIG_ARCH_S390)
 	ccwcache_init();
 #endif
--- 2.5.8-pre3/kernel/ksyms.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/kernel/ksyms.c	Tue Apr  9 20:35:31 2002
@@ -224,8 +224,6 @@ EXPORT_SYMBOL(generic_file_write);
 EXPORT_SYMBOL(generic_file_mmap);
 EXPORT_SYMBOL(generic_ro_fops);
 EXPORT_SYMBOL(generic_buffer_fdatasync);
-EXPORT_SYMBOL(page_hash_bits);
-EXPORT_SYMBOL(page_hash_table);
 EXPORT_SYMBOL(file_lock_list);
 EXPORT_SYMBOL(locks_init_lock);
 EXPORT_SYMBOL(locks_copy_lock);
@@ -266,8 +264,8 @@ EXPORT_SYMBOL(no_llseek);
 EXPORT_SYMBOL(__pollwait);
 EXPORT_SYMBOL(poll_freewait);
 EXPORT_SYMBOL(ROOT_DEV);
-EXPORT_SYMBOL(__find_get_page);
-EXPORT_SYMBOL(__find_lock_page);
+EXPORT_SYMBOL(find_get_page);
+EXPORT_SYMBOL(find_lock_page);
 EXPORT_SYMBOL(grab_cache_page);
 EXPORT_SYMBOL(grab_cache_page_nowait);
 EXPORT_SYMBOL(read_cache_page);
--- 2.5.8-pre3/lib/Makefile~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/lib/Makefile	Tue Apr  9 20:35:31 2002
@@ -8,9 +8,11 @@
 
 L_TARGET := lib.a
 
-export-objs := cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o crc32.o rbtree.o
+export-objs := cmdline.o dec_and_lock.o rwsem-spinlock.o rwsem.o \
+	       crc32.o rbtree.o radix-tree.o
 
-obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o bust_spinlocks.o rbtree.o
+obj-y := errno.o ctype.o string.o vsprintf.o brlock.o cmdline.o \
+	 bust_spinlocks.o rbtree.o radix-tree.o
 
 obj-$(CONFIG_RWSEM_GENERIC_SPINLOCK) += rwsem-spinlock.o
 obj-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
--- /dev/null	Thu Aug 30 13:30:55 2001
+++ 2.5.8-pre3-akpm/lib/radix-tree.c	Tue Apr  9 20:35:31 2002
@@ -0,0 +1,296 @@
+/*
+ * Copyright (C) 2001 Momchil Velikov
+ * Portions Copyright (C) 2001 Christoph Hellwig
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2, or (at
+ * your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mempool.h>
+#include <linux/module.h>
+#include <linux/radix-tree.h>
+#include <linux/slab.h>
+
+/*
+ * Radix tree node definition.
+ */
+#define RADIX_TREE_MAP_SHIFT  7
+#define RADIX_TREE_MAP_SIZE  (1UL << RADIX_TREE_MAP_SHIFT)
+#define RADIX_TREE_MAP_MASK  (RADIX_TREE_MAP_SIZE-1)
+
+struct radix_tree_node {
+	unsigned int	count;
+	void		*slots[RADIX_TREE_MAP_SIZE];
+};
+
+struct radix_tree_path {
+	struct radix_tree_node *node, **slot;
+};
+
+#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
+
+/*
+ * Radix tree node cache.
+ */
+static kmem_cache_t *radix_tree_node_cachep;
+static mempool_t *radix_tree_node_pool;
+
+#define radix_tree_node_alloc(root) \
+	mempool_alloc(radix_tree_node_pool, (root)->gfp_mask)
+#define radix_tree_node_free(node) \
+	mempool_free((node), radix_tree_node_pool);
+
+
+/*
+ *	Return the maximum key which can be store into a
+ *	radix tree with height HEIGHT.
+ */
+static inline unsigned long radix_tree_maxindex(unsigned int height)
+{
+	unsigned int tmp = height * RADIX_TREE_MAP_SHIFT;
+	unsigned long index = (~0UL >> (RADIX_TREE_INDEX_BITS - tmp - 1)) >> 1;
+
+	if (tmp >= RADIX_TREE_INDEX_BITS)
+		index = ~0UL;
+	return index;
+}
+
+
+/*
+ *	Extend a radix tree so it can store key @index.
+ */
+static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
+{
+	struct radix_tree_node *node;
+	unsigned int height;
+
+	/* Figure out what the height should be.  */
+	height = root->height + 1;
+	while (index > radix_tree_maxindex(height))
+		height++;
+
+	if (root->rnode) {
+		do {
+			if (!(node = radix_tree_node_alloc(root)))
+				return -ENOMEM;
+
+			/* Increase the height.  */
+			node->slots[0] = root->rnode;
+			if (root->rnode)
+				node->count = 1;
+			root->rnode = node;
+			root->height++;
+		} while (height > root->height);
+	} else 
+		root->height = height;
+
+	return 0;
+}
+
+
+/**
+ *	radix_tree_reserve    -    reserve space in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@pslot:		pointer to reserved slot
+ *
+ *	Reserve a slot in a radix tree for the key @index.
+ */
+int radix_tree_reserve(struct radix_tree_root *root, unsigned long index, void ***pslot)
+{
+	struct radix_tree_node *node = NULL, *tmp, **slot;
+	unsigned int height, shift;
+	int error;
+
+	/* Make sure the tree is high enough.  */
+	if (index > radix_tree_maxindex(root->height)) {
+		error = radix_tree_extend(root, index);
+		if (error)
+			return error;
+	}
+    
+	slot = &root->rnode;
+	height = root->height;
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+
+	while (height > 0) {
+		if (*slot == NULL) {
+			/* Have to add a child node.  */
+			if (!(tmp = radix_tree_node_alloc(root)))
+				return -ENOMEM;
+			*slot = tmp;
+			if (node)
+				node->count++;
+		}
+
+		/* Go a level down.  */
+		node = *slot;
+		slot = (struct radix_tree_node **)
+			(node->slots + ((index >> shift) & RADIX_TREE_MAP_MASK));
+		shift -= RADIX_TREE_MAP_SHIFT;
+		height--;
+	}
+
+	if (*slot != NULL)
+		return -EEXIST;
+	if (node)
+		node->count++;
+
+	*pslot = (void **)slot;
+	**pslot = RADIX_TREE_SLOT_RESERVED;
+	return 0;
+}
+
+EXPORT_SYMBOL(radix_tree_reserve);
+
+
+/**
+ *	radix_tree_insert    -    insert into a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@item:		item to insert
+ *
+ *	Insert an item into the radix tree at position @index.
+ */
+int radix_tree_insert(struct radix_tree_root *root, unsigned long index, void *item)
+{
+	void **slot;
+	int error;
+
+	error = radix_tree_reserve(root, index, &slot);
+	if (!error)
+		*slot = item;
+	return error;
+}
+
+EXPORT_SYMBOL(radix_tree_insert);
+
+
+/**
+ *	radix_tree_lookup    -    perform lookup operation on a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Lookup them item at the position @index in the radix tree @root.
+ */
+void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
+{
+	unsigned int height, shift;
+	struct radix_tree_node **slot;
+
+	height = root->height;
+	if (index > radix_tree_maxindex(height))
+		return NULL;
+
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	slot = &root->rnode;
+
+	while (height > 0) {
+		if (*slot == NULL)
+			return NULL;
+
+		slot = (struct radix_tree_node **)
+			((*slot)->slots + ((index >> shift) & RADIX_TREE_MAP_MASK));
+		shift -= RADIX_TREE_MAP_SHIFT;
+		height--;
+	}
+
+	return (void *) *slot;
+}
+
+EXPORT_SYMBOL(radix_tree_lookup);
+
+
+/**
+ *	radix_tree_delete    -    delete an item from a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Remove the item at @index from the radix tree rooted at @root.
+ */
+int radix_tree_delete(struct radix_tree_root *root, unsigned long index)
+{
+	struct radix_tree_path path[RADIX_TREE_INDEX_BITS/RADIX_TREE_MAP_SHIFT + 2], *pathp = path;
+	unsigned int height, shift;
+
+	height = root->height;
+	if (index > radix_tree_maxindex(height))
+		return -ENOENT;
+
+	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	pathp->node = NULL;
+	pathp->slot = &root->rnode;
+
+	while (height > 0) {
+		if (*pathp->slot == NULL)
+			return -ENOENT;
+
+		pathp[1].node = *pathp[0].slot;
+		pathp[1].slot = (struct radix_tree_node **)
+		    (pathp[1].node->slots + ((index >> shift) & RADIX_TREE_MAP_MASK));
+		pathp++;
+		shift -= RADIX_TREE_MAP_SHIFT;
+		height--;
+	}
+
+	if (*pathp[0].slot == NULL)
+		return -ENOENT;
+
+	*pathp[0].slot = NULL;
+	while (pathp[0].node && --pathp[0].node->count == 0) {
+		pathp--;
+		*pathp[0].slot = NULL;
+		radix_tree_node_free(pathp[1].node);
+	}
+
+	return 0;
+}
+
+EXPORT_SYMBOL(radix_tree_delete);
+
+static void radix_tree_node_ctor(void *node, kmem_cache_t *cachep, unsigned long flags)
+{
+	memset(node, 0, sizeof(struct radix_tree_node));
+}
+
+static void *radix_tree_node_pool_alloc(int gfp_mask, void *data)
+{
+	return kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
+}
+
+static void radix_tree_node_pool_free(void *node, void *data)
+{
+	kmem_cache_free(radix_tree_node_cachep, node);
+}
+
+/*
+ * FIXME!  512 nodes is 200-300k of memory.  This needs to be
+ * scaled by the amount of available memory, and hopefully
+ * reduced also.
+ */
+void __init radix_tree_init(void)
+{
+	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
+			sizeof(struct radix_tree_node), 0,
+			SLAB_HWCACHE_ALIGN, radix_tree_node_ctor, NULL);
+	if (!radix_tree_node_cachep)
+		panic ("Failed to create radix_tree_node cache\n");
+	radix_tree_node_pool = mempool_create(512, radix_tree_node_pool_alloc,
+			radix_tree_node_pool_free, NULL);
+	if (!radix_tree_node_pool)
+		panic ("Failed to create radix_tree_node pool\n");
+}
--- 2.5.8-pre3/mm/filemap.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/filemap.c	Tue Apr  9 20:35:43 2002
@@ -46,89 +46,46 @@
  */
 
 atomic_t page_cache_size = ATOMIC_INIT(0);
-unsigned int page_hash_bits;
-struct page **page_hash_table;
 
-spinlock_t pagecache_lock __cacheline_aligned_in_smp = SPIN_LOCK_UNLOCKED;
 /*
- * NOTE: to avoid deadlocking you must never acquire the pagemap_lru_lock 
- *	with the pagecache_lock held.
- *
- * Ordering:
- *	swap_lock ->
- *		pagemap_lru_lock ->
- *			pagecache_lock
+ * Lock ordering:
+ *	pagemap_lru_lock ==> page_lock ==> i_shared_lock
  */
 spinlock_t pagemap_lru_lock __cacheline_aligned_in_smp = SPIN_LOCK_UNLOCKED;
 
 #define CLUSTER_PAGES		(1 << page_cluster)
 #define CLUSTER_OFFSET(x)	(((x) >> page_cluster) << page_cluster)
 
-static void FASTCALL(add_page_to_hash_queue(struct page * page, struct page **p));
-static void add_page_to_hash_queue(struct page * page, struct page **p)
-{
-	struct page *next = *p;
-
-	*p = page;
-	page->next_hash = next;
-	page->pprev_hash = p;
-	if (next)
-		next->pprev_hash = &page->next_hash;
-	if (page->buffers)
-		PAGE_BUG(page);
-	atomic_inc(&page_cache_size);
-}
-
-static inline void add_page_to_inode_queue(struct address_space *mapping, struct page * page)
+/*
+ * Remove a page from the page cache and free it. Caller has to make
+ * sure the page is locked and that nobody else uses it - or that usage
+ * is safe.  The caller must hold a write_lock on the mapping's page_lock.
+ */
+void __remove_inode_page(struct page *page)
 {
-	struct list_head *head = &mapping->clean_pages;
-
-	mapping->nrpages++;
-	list_add(&page->list, head);
-	page->mapping = mapping;
-}
+	struct address_space *mapping = page->mapping;
 
-static inline void remove_page_from_inode_queue(struct page * page)
-{
-	struct address_space * mapping = page->mapping;
+	if (unlikely(PageDirty(page)))
+		BUG();
 
-	mapping->nrpages--;
+	radix_tree_delete(&page->mapping->page_tree, page->index);
 	list_del(&page->list);
 	page->mapping = NULL;
-}
-
-static inline void remove_page_from_hash_queue(struct page * page)
-{
-	struct page *next = page->next_hash;
-	struct page **pprev = page->pprev_hash;
 
-	if (next)
-		next->pprev_hash = pprev;
-	*pprev = next;
-	page->pprev_hash = NULL;
+	mapping->nrpages--;
 	atomic_dec(&page_cache_size);
 }
 
-/*
- * Remove a page from the page cache and free it. Caller has to make
- * sure the page is locked and that nobody else uses it - or that usage
- * is safe.
- */
-void __remove_inode_page(struct page *page)
-{
-	if (PageDirty(page)) BUG();
-	remove_page_from_inode_queue(page);
-	remove_page_from_hash_queue(page);
-}
-
 void remove_inode_page(struct page *page)
 {
-	if (!PageLocked(page))
+	struct address_space *mapping = page->mapping;
+
+	if (unlikely(!PageLocked(page)))
 		PAGE_BUG(page);
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 	__remove_inode_page(page);
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 }
 
 static inline int sync_page(struct page *page)
@@ -149,10 +106,10 @@ void set_page_dirty(struct page *page)
 		struct address_space *mapping = page->mapping;
 
 		if (mapping) {
-			spin_lock(&pagecache_lock);
+			write_lock(&mapping->page_lock);
 			list_del(&page->list);
 			list_add(&page->list, &mapping->dirty_pages);
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 
 			if (mapping->host)
 				mark_inode_dirty_pages(mapping->host);
@@ -172,11 +129,12 @@ void invalidate_inode_pages(struct inode
 {
 	struct list_head *head, *curr;
 	struct page * page;
+	struct address_space *mapping = inode->i_mapping;
 
-	head = &inode->i_mapping->clean_pages;
+	head = &mapping->clean_pages;
 
 	spin_lock(&pagemap_lru_lock);
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 	curr = head->next;
 
 	while (curr != head) {
@@ -207,7 +165,7 @@ unlock:
 		continue;
 	}
 
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 	spin_unlock(&pagemap_lru_lock);
 }
 
@@ -246,8 +204,8 @@ static void truncate_complete_page(struc
 	page_cache_release(page);
 }
 
-static int FASTCALL(truncate_list_pages(struct list_head *, unsigned long, unsigned *));
-static int truncate_list_pages(struct list_head *head, unsigned long start, unsigned *partial)
+static int truncate_list_pages(struct address_space *mapping,
+	struct list_head *head, unsigned long start, unsigned *partial)
 {
 	struct list_head *curr;
 	struct page * page;
@@ -276,7 +234,7 @@ static int truncate_list_pages(struct li
 				/* Restart on this page */
 				list_add(head, curr);
 
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			unlocked = 1;
 
  			if (!failed) {
@@ -297,7 +255,7 @@ static int truncate_list_pages(struct li
 				schedule();
 			}
 
-			spin_lock(&pagecache_lock);
+			write_lock(&mapping->page_lock);
 			goto restart;
 		}
 		curr = curr->prev;
@@ -321,24 +279,28 @@ void truncate_inode_pages(struct address
 	unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
 	int unlocked;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 	do {
-		unlocked = truncate_list_pages(&mapping->clean_pages, start, &partial);
-		unlocked |= truncate_list_pages(&mapping->dirty_pages, start, &partial);
-		unlocked |= truncate_list_pages(&mapping->locked_pages, start, &partial);
+		unlocked = truncate_list_pages(mapping,
+				&mapping->clean_pages, start, &partial);
+		unlocked |= truncate_list_pages(mapping,
+				&mapping->dirty_pages, start, &partial);
+		unlocked |= truncate_list_pages(mapping,
+				&mapping->locked_pages, start, &partial);
 	} while (unlocked);
 	/* Traversed all three lists without dropping the lock */
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 }
 
-static inline int invalidate_this_page2(struct page * page,
+static inline int invalidate_this_page2(struct address_space * mapping,
+					struct page * page,
 					struct list_head * curr,
 					struct list_head * head)
 {
 	int unlocked = 1;
 
 	/*
-	 * The page is locked and we hold the pagecache_lock as well
+	 * The page is locked and we hold the mapping lock as well
 	 * so both page_count(page) and page->buffers stays constant here.
 	 */
 	if (page_count(page) == 1 + !!page->buffers) {
@@ -347,7 +309,7 @@ static inline int invalidate_this_page2(
 		list_add_tail(head, curr);
 
 		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 		truncate_complete_page(page);
 	} else {
 		if (page->buffers) {
@@ -356,7 +318,7 @@ static inline int invalidate_this_page2(
 			list_add_tail(head, curr);
 
 			page_cache_get(page);
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			block_invalidate_page(page);
 		} else
 			unlocked = 0;
@@ -368,8 +330,8 @@ static inline int invalidate_this_page2(
 	return unlocked;
 }
 
-static int FASTCALL(invalidate_list_pages2(struct list_head *));
-static int invalidate_list_pages2(struct list_head *head)
+static int invalidate_list_pages2(struct address_space * mapping,
+				  struct list_head * head)
 {
 	struct list_head *curr;
 	struct page * page;
@@ -383,7 +345,7 @@ static int invalidate_list_pages2(struct
 		if (!TryLockPage(page)) {
 			int __unlocked;
 
-			__unlocked = invalidate_this_page2(page, curr, head);
+			__unlocked = invalidate_this_page2(mapping, page, curr, head);
 			UnlockPage(page);
 			unlocked |= __unlocked;
 			if (!__unlocked) {
@@ -396,7 +358,7 @@ static int invalidate_list_pages2(struct
 			list_add(head, curr);
 
 			page_cache_get(page);
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			unlocked = 1;
 			wait_on_page(page);
 		}
@@ -407,7 +369,7 @@ static int invalidate_list_pages2(struct
 			schedule();
 		}
 
-		spin_lock(&pagecache_lock);
+		write_lock(&mapping->page_lock);
 		goto restart;
 	}
 	return unlocked;
@@ -422,41 +384,27 @@ void invalidate_inode_pages2(struct addr
 {
 	int unlocked;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 	do {
-		unlocked = invalidate_list_pages2(&mapping->clean_pages);
-		unlocked |= invalidate_list_pages2(&mapping->dirty_pages);
-		unlocked |= invalidate_list_pages2(&mapping->locked_pages);
+		unlocked = invalidate_list_pages2(mapping,
+				&mapping->clean_pages);
+		unlocked |= invalidate_list_pages2(mapping,
+				&mapping->dirty_pages);
+		unlocked |= invalidate_list_pages2(mapping,
+				&mapping->locked_pages);
 	} while (unlocked);
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 }
 
-static inline struct page * __find_page_nolock(struct address_space *mapping, unsigned long offset, struct page *page)
-{
-	goto inside;
-
-	for (;;) {
-		page = page->next_hash;
-inside:
-		if (!page)
-			goto not_found;
-		if (page->mapping != mapping)
-			continue;
-		if (page->index == offset)
-			break;
-	}
-
-not_found:
-	return page;
-}
-
-static int do_buffer_fdatasync(struct list_head *head, unsigned long start, unsigned long end, int (*fn)(struct page *))
+static int do_buffer_fdatasync(struct address_space *mapping,
+		struct list_head *head, unsigned long start,
+		unsigned long end, int (*fn)(struct page *))
 {
 	struct list_head *curr;
 	struct page *page;
 	int retval = 0;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 	curr = head->next;
 	while (curr != head) {
 		page = list_entry(curr, struct page, list);
@@ -469,7 +417,7 @@ static int do_buffer_fdatasync(struct li
 			continue;
 
 		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 		lock_page(page);
 
 		/* The buffers could have been free'd while we waited for the page lock */
@@ -477,11 +425,11 @@ static int do_buffer_fdatasync(struct li
 			retval |= fn(page);
 
 		UnlockPage(page);
-		spin_lock(&pagecache_lock);
+		write_lock(&mapping->page_lock);
 		curr = page->list.next;
 		page_cache_release(page);
 	}
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 
 	return retval;
 }
@@ -492,17 +440,24 @@ static int do_buffer_fdatasync(struct li
  */
 int generic_buffer_fdatasync(struct inode *inode, unsigned long start_idx, unsigned long end_idx)
 {
+	struct address_space *mapping = inode->i_mapping;
 	int retval;
 
 	/* writeout dirty buffers on pages from both clean and dirty lists */
-	retval = do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx, end_idx, writeout_one_page);
-	retval |= do_buffer_fdatasync(&inode->i_mapping->clean_pages, start_idx, end_idx, writeout_one_page);
-	retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx, end_idx, writeout_one_page);
+	retval = do_buffer_fdatasync(mapping, &mapping->dirty_pages,
+			start_idx, end_idx, writeout_one_page);
+	retval |= do_buffer_fdatasync(mapping, &mapping->clean_pages,
+			start_idx, end_idx, writeout_one_page);
+	retval |= do_buffer_fdatasync(mapping, &mapping->locked_pages,
+			start_idx, end_idx, writeout_one_page);
 
 	/* now wait for locked buffers on pages from both clean and dirty lists */
-	retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx, end_idx, waitfor_one_page);
-	retval |= do_buffer_fdatasync(&inode->i_mapping->clean_pages, start_idx, end_idx, waitfor_one_page);
-	retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx, end_idx, waitfor_one_page);
+	retval |= do_buffer_fdatasync(mapping, &mapping->dirty_pages,
+			start_idx, end_idx, waitfor_one_page);
+	retval |= do_buffer_fdatasync(mapping, &mapping->clean_pages,
+			start_idx, end_idx, waitfor_one_page);
+	retval |= do_buffer_fdatasync(mapping, &mapping->locked_pages,
+			start_idx, end_idx, waitfor_one_page);
 
 	return retval;
 }
@@ -548,7 +503,7 @@ int filemap_fdatasync(struct address_spa
 	int ret = 0;
 	int (*writepage)(struct page *) = mapping->a_ops->writepage;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 
         while (!list_empty(&mapping->dirty_pages)) {
 		struct page *page = list_entry(mapping->dirty_pages.prev, struct page, list);
@@ -560,7 +515,7 @@ int filemap_fdatasync(struct address_spa
 			continue;
 
 		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 
 		lock_page(page);
 
@@ -574,9 +529,9 @@ int filemap_fdatasync(struct address_spa
 			UnlockPage(page);
 
 		page_cache_release(page);
-		spin_lock(&pagecache_lock);
+		write_lock(&mapping->page_lock);
 	}
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 	return ret;
 }
 
@@ -591,7 +546,7 @@ int filemap_fdatawait(struct address_spa
 {
 	int ret = 0;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
 
         while (!list_empty(&mapping->locked_pages)) {
 		struct page *page = list_entry(mapping->locked_pages.next, struct page, list);
@@ -603,86 +558,69 @@ int filemap_fdatawait(struct address_spa
 			continue;
 
 		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 
 		___wait_on_page(page);
 		if (PageError(page))
 			ret = -EIO;
 
 		page_cache_release(page);
-		spin_lock(&pagecache_lock);
+		write_lock(&mapping->page_lock);
 	}
-	spin_unlock(&pagecache_lock);
+	write_unlock(&mapping->page_lock);
 	return ret;
 }
 
 /*
- * Add a page to the inode page cache.
- *
- * The caller must have locked the page and 
- * set all the page flags correctly..
- */
-void add_to_page_cache_locked(struct page * page, struct address_space *mapping, unsigned long index)
-{
-	if (!PageLocked(page))
-		BUG();
-
-	page->index = index;
-	page_cache_get(page);
-	spin_lock(&pagecache_lock);
-	add_page_to_inode_queue(mapping, page);
-	add_page_to_hash_queue(page, page_hash(mapping, index));
-	spin_unlock(&pagecache_lock);
-
-	lru_cache_add(page);
-}
-
-/*
  * This adds a page to the page cache, starting out as locked,
  * owned by us, but unreferenced, not uptodate and with no errors.
+ * The caller must hold a write_lock on the mapping->page_lock.
  */
-static inline void __add_to_page_cache(struct page * page,
-	struct address_space *mapping, unsigned long offset,
-	struct page **hash)
+static int __add_to_page_cache(struct page *page,
+		struct address_space *mapping, unsigned long offset)
 {
 	unsigned long flags;
 
+	page_cache_get(page);
+	if (radix_tree_insert(&mapping->page_tree, offset, page) < 0)
+		goto nomem;
 	flags = page->flags & ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_dirty | 1 << PG_referenced | 1 << PG_arch_1 | 1 << PG_checked);
 	page->flags = flags | (1 << PG_locked);
-	page_cache_get(page);
-	page->index = offset;
-	add_page_to_inode_queue(mapping, page);
-	add_page_to_hash_queue(page, hash);
+	___add_to_page_cache(page, mapping, offset);
+	return 0;
+ nomem:
+	page_cache_release(page);
+	return -ENOMEM;
 }
 
-void add_to_page_cache(struct page * page, struct address_space * mapping, unsigned long offset)
+int add_to_page_cache(struct page *page,
+		struct address_space *mapping, unsigned long offset)
 {
-	spin_lock(&pagecache_lock);
-	__add_to_page_cache(page, mapping, offset, page_hash(mapping, offset));
-	spin_unlock(&pagecache_lock);
+	write_lock(&mapping->page_lock);
+	if (__add_to_page_cache(page, mapping, offset) < 0)
+		goto nomem;
+	write_unlock(&mapping->page_lock);
 	lru_cache_add(page);
+	return 0;
+nomem:
+	write_unlock(&mapping->page_lock);
+	return -ENOMEM;
 }
 
-int add_to_page_cache_unique(struct page * page,
-	struct address_space *mapping, unsigned long offset,
-	struct page **hash)
+int add_to_page_cache_unique(struct page *page,
+		struct address_space *mapping, unsigned long offset)
 {
-	int err;
 	struct page *alias;
+	int error = -EEXIST;
 
-	spin_lock(&pagecache_lock);
-	alias = __find_page_nolock(mapping, offset, *hash);
-
-	err = 1;
-	if (!alias) {
-		__add_to_page_cache(page,mapping,offset,hash);
-		err = 0;
-	}
+	write_lock(&mapping->page_lock);
+	if (!(alias = radix_tree_lookup(&mapping->page_tree, offset)))
+		error = __add_to_page_cache(page, mapping, offset);
+	write_unlock(&mapping->page_lock);
 
-	spin_unlock(&pagecache_lock);
-	if (!err)
+	if (!error)
 		lru_cache_add(page);
-	return err;
+	return error;
 }
 
 /*
@@ -693,12 +631,12 @@ static int FASTCALL(page_cache_read(stru
 static int page_cache_read(struct file * file, unsigned long offset)
 {
 	struct address_space *mapping = file->f_dentry->d_inode->i_mapping;
-	struct page **hash = page_hash(mapping, offset);
 	struct page *page; 
+	int error;
 
-	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
-	spin_unlock(&pagecache_lock);
+	read_lock(&mapping->page_lock);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
+	read_unlock(&mapping->page_lock);
 	if (page)
 		return 0;
 
@@ -706,17 +644,20 @@ static int page_cache_read(struct file *
 	if (!page)
 		return -ENOMEM;
 
-	if (!add_to_page_cache_unique(page, mapping, offset, hash)) {
-		int error = mapping->a_ops->readpage(file, page);
+	error = add_to_page_cache_unique(page, mapping, offset);
+	if (!error) {
+		error = mapping->a_ops->readpage(file, page);
 		page_cache_release(page);
 		return error;
 	}
+
 	/*
 	 * We arrive here in the unlikely event that someone 
-	 * raced with us and added our page to the cache first.
+	 * raced with us and added our page to the cache first
+	 * or we are out of memory for radix-tree nodes.
 	 */
 	page_cache_release(page);
-	return 0;
+	return error == -EEXIST ? 0 : error;
 }
 
 /*
@@ -842,8 +783,7 @@ void lock_page(struct page *page)
  * a rather lightweight function, finding and getting a reference to a
  * hashed page atomically.
  */
-struct page * __find_get_page(struct address_space *mapping,
-			      unsigned long offset, struct page **hash)
+struct page * find_get_page(struct address_space *mapping, unsigned long offset)
 {
 	struct page *page;
 
@@ -851,11 +791,11 @@ struct page * __find_get_page(struct add
 	 * We scan the hash list read-only. Addition to and removal from
 	 * the hash-list needs a held write-lock.
 	 */
-	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
+	read_lock(&mapping->page_lock);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page)
 		page_cache_get(page);
-	spin_unlock(&pagecache_lock);
+	read_unlock(&mapping->page_lock);
 	return page;
 }
 
@@ -865,15 +805,12 @@ struct page * __find_get_page(struct add
 struct page *find_trylock_page(struct address_space *mapping, unsigned long offset)
 {
 	struct page *page;
-	struct page **hash = page_hash(mapping, offset);
 
-	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
-	if (page) {
-		if (TryLockPage(page))
-			page = NULL;
-	}
-	spin_unlock(&pagecache_lock);
+	read_lock(&mapping->page_lock);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
+	if (page && TryLockPage(page))
+		page = NULL;
+	read_unlock(&mapping->page_lock);
 	return page;
 }
 
@@ -882,9 +819,8 @@ struct page *find_trylock_page(struct ad
  * will return with it held (but it may be dropped
  * during blocking operations..
  */
-static struct page * FASTCALL(__find_lock_page_helper(struct address_space *, unsigned long, struct page *));
-static struct page * __find_lock_page_helper(struct address_space *mapping,
-					unsigned long offset, struct page *hash)
+static struct page *__find_lock_page(struct address_space *mapping,
+					unsigned long offset)
 {
 	struct page *page;
 
@@ -893,13 +829,13 @@ static struct page * __find_lock_page_he
 	 * the hash-list needs a held write-lock.
 	 */
 repeat:
-	page = __find_page_nolock(mapping, offset, hash);
+	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
 		if (TryLockPage(page)) {
-			spin_unlock(&pagecache_lock);
+			read_unlock(&mapping->page_lock);
 			lock_page(page);
-			spin_lock(&pagecache_lock);
+			read_lock(&mapping->page_lock);
 
 			/* Has the page been re-allocated while we slept? */
 			if (page->mapping != mapping || page->index != offset) {
@@ -916,46 +852,50 @@ repeat:
  * Same as the above, but lock the page too, verifying that
  * it's still valid once we own it.
  */
-struct page * __find_lock_page (struct address_space *mapping,
-				unsigned long offset, struct page **hash)
+struct page * find_lock_page(struct address_space *mapping, unsigned long offset)
 {
 	struct page *page;
 
-	spin_lock(&pagecache_lock);
-	page = __find_lock_page_helper(mapping, offset, *hash);
-	spin_unlock(&pagecache_lock);
+	read_lock(&mapping->page_lock);
+	page = __find_lock_page(mapping, offset);
+	read_unlock(&mapping->page_lock);
+
 	return page;
 }
 
 /*
  * Same as above, but create the page if required..
  */
-struct page * find_or_create_page(struct address_space *mapping, unsigned long index, unsigned int gfp_mask)
+struct page * find_or_create_page(struct address_space *mapping,
+		unsigned long index, unsigned int gfp_mask)
 {
 	struct page *page;
-	struct page **hash = page_hash(mapping, index);
 
-	spin_lock(&pagecache_lock);
-	page = __find_lock_page_helper(mapping, index, *hash);
-	spin_unlock(&pagecache_lock);
+	page = find_lock_page(mapping, index);
 	if (!page) {
 		struct page *newpage = alloc_page(gfp_mask);
 		if (newpage) {
-			spin_lock(&pagecache_lock);
-			page = __find_lock_page_helper(mapping, index, *hash);
+			write_lock(&mapping->page_lock);
+			page = __find_lock_page(mapping, index);
 			if (likely(!page)) {
 				page = newpage;
-				__add_to_page_cache(page, mapping, index, hash);
+				if (__add_to_page_cache(page, mapping, index)) {
+					write_unlock(&mapping->page_lock);
+					page_cache_release(page);
+					page = NULL;
+					goto out;
+				}
 				newpage = NULL;
 			}
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			if (newpage == NULL)
 				lru_cache_add(page);
 			else 
 				page_cache_release(newpage);
 		}
 	}
-	return page;	
+out:
+	return page;
 }
 
 /*
@@ -975,10 +915,9 @@ struct page *grab_cache_page(struct addr
  */
 struct page *grab_cache_page_nowait(struct address_space *mapping, unsigned long index)
 {
-	struct page *page, **hash;
+	struct page *page;
 
-	hash = page_hash(mapping, index);
-	page = __find_get_page(mapping, index, hash);
+	page = find_get_page(mapping, index);
 
 	if ( page ) {
 		if ( !TryLockPage(page) ) {
@@ -1000,11 +939,14 @@ struct page *grab_cache_page_nowait(stru
 	}
 
 	page = page_cache_alloc(mapping);
-	if ( unlikely(!page) )
+	if (unlikely(!page))
 		return NULL;	/* Failed to allocate a page */
 
-	if ( unlikely(add_to_page_cache_unique(page, mapping, index, hash)) ) {
-		/* Someone else grabbed the page already. */
+	if (unlikely(add_to_page_cache_unique(page, mapping, index))) {
+		/*
+		 * Someone else grabbed the page already, or
+		 * failed to allocate a radix-tree node
+		 */
 		page_cache_release(page);
 		return NULL;
 	}
@@ -1319,7 +1261,7 @@ void do_generic_file_read(struct file * 
 	}
 
 	for (;;) {
-		struct page *page, **hash;
+		struct page *page;
 		unsigned long end_index, nr, ret;
 
 		end_index = inode->i_size >> PAGE_CACHE_SHIFT;
@@ -1338,15 +1280,14 @@ void do_generic_file_read(struct file * 
 		/*
 		 * Try to find the data in the page cache..
 		 */
-		hash = page_hash(mapping, index);
 
-		spin_lock(&pagecache_lock);
-		page = __find_page_nolock(mapping, index, *hash);
+		write_lock(&mapping->page_lock);
+		page = radix_tree_lookup(&mapping->page_tree, index);
 		if (!page)
 			goto no_cached_page;
 found_page:
 		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 
 		if (!Page_Uptodate(page))
 			goto page_not_up_to_date;
@@ -1440,7 +1381,7 @@ no_cached_page:
 		 * We get here with the page cache lock held.
 		 */
 		if (!cached_page) {
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			cached_page = page_cache_alloc(mapping);
 			if (!cached_page) {
 				desc->error = -ENOMEM;
@@ -1451,8 +1392,8 @@ no_cached_page:
 			 * Somebody may have added the page while we
 			 * dropped the page cache lock. Check for that.
 			 */
-			spin_lock(&pagecache_lock);
-			page = __find_page_nolock(mapping, index, *hash);
+			write_lock(&mapping->page_lock);
+			page = radix_tree_lookup(&mapping->page_tree, index);
 			if (page)
 				goto found_page;
 		}
@@ -1460,9 +1401,13 @@ no_cached_page:
 		/*
 		 * Ok, add the new page to the hash-queues...
 		 */
+		if (__add_to_page_cache(cached_page, mapping, index) < 0) {
+			write_unlock(&mapping->page_lock);
+			desc->error = -ENOMEM;
+			break;
+		}
 		page = cached_page;
-		__add_to_page_cache(page, mapping, index, hash);
-		spin_unlock(&pagecache_lock);
+		write_unlock(&mapping->page_lock);
 		lru_cache_add(page);		
 		cached_page = NULL;
 
@@ -1902,7 +1847,7 @@ struct page * filemap_nopage(struct vm_a
 	struct file *file = area->vm_file;
 	struct address_space *mapping = file->f_dentry->d_inode->i_mapping;
 	struct inode *inode = mapping->host;
-	struct page *page, **hash;
+	struct page *page;
 	unsigned long size, pgoff, endoff;
 
 	pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
@@ -1924,9 +1869,8 @@ retry_all:
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	hash = page_hash(mapping, pgoff);
 retry_find:
-	page = __find_get_page(mapping, pgoff, hash);
+	page = find_get_page(mapping, pgoff);
 	if (!page)
 		goto no_cached_page;
 
@@ -2418,20 +2362,25 @@ struct page *__read_cache_page(struct ad
 				int (*filler)(void *,struct page*),
 				void *data)
 {
-	struct page **hash = page_hash(mapping, index);
 	struct page *page, *cached_page = NULL;
 	int err;
 repeat:
-	page = __find_get_page(mapping, index, hash);
+	page = find_get_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
 			cached_page = page_cache_alloc(mapping);
 			if (!cached_page)
 				return ERR_PTR(-ENOMEM);
 		}
-		page = cached_page;
-		if (add_to_page_cache_unique(page, mapping, index, hash))
+		err = add_to_page_cache_unique(cached_page, mapping, index);
+		if (err == -EEXIST)
 			goto repeat;
+		if (err < 0) {
+			/* Presumably ENOMEM for radix tree node */
+			page_cache_release(cached_page);
+			return ERR_PTR(err);
+		}
+		page = cached_page;
 		cached_page = NULL;
 		err = filler(data, page);
 		if (err < 0) {
@@ -2486,19 +2435,23 @@ retry:
 static inline struct page * __grab_cache_page(struct address_space *mapping,
 				unsigned long index, struct page **cached_page)
 {
-	struct page *page, **hash = page_hash(mapping, index);
+	int err;
+	struct page *page;
 repeat:
-	page = __find_lock_page(mapping, index, hash);
+	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!*cached_page) {
 			*cached_page = page_cache_alloc(mapping);
 			if (!*cached_page)
 				return NULL;
 		}
-		page = *cached_page;
-		if (add_to_page_cache_unique(page, mapping, index, hash))
+		err = add_to_page_cache_unique(*cached_page, mapping, index);
+		if (err == -EEXIST)
 			goto repeat;
-		*cached_page = NULL;
+		if (err == 0) {
+			page = *cached_page;
+			*cached_page = NULL;
+		}
 	}
 	return page;
 }
@@ -2772,30 +2725,3 @@ o_direct:
 		status = generic_osync_inode(inode, OSYNC_METADATA);
 	goto out_status;
 }
-
-void __init page_cache_init(unsigned long mempages)
-{
-	unsigned long htable_size, order;
-
-	htable_size = mempages;
-	htable_size *= sizeof(struct page *);
-	for(order = 0; (PAGE_SIZE << order) < htable_size; order++)
-		;
-
-	do {
-		unsigned long tmp = (PAGE_SIZE << order) / sizeof(struct page *);
-
-		page_hash_bits = 0;
-		while((tmp >>= 1UL) != 0UL)
-			page_hash_bits++;
-
-		page_hash_table = (struct page **)
-			__get_free_pages(GFP_ATOMIC, order);
-	} while(page_hash_table == NULL && --order > 0);
-
-	printk("Page-cache hash table entries: %d (order: %ld, %ld bytes)\n",
-	       (1 << page_hash_bits), order, (PAGE_SIZE << order));
-	if (!page_hash_table)
-		panic("Failed to allocate page hash table\n");
-	memset((void *)page_hash_table, 0, PAGE_HASH_SIZE * sizeof(struct page *));
-}
--- 2.5.8-pre3/mm/mincore.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/mincore.c	Tue Apr  9 20:35:31 2002
@@ -27,9 +27,9 @@ static unsigned char mincore_page(struct
 {
 	unsigned char present = 0;
 	struct address_space * as = vma->vm_file->f_dentry->d_inode->i_mapping;
-	struct page * page, ** hash = page_hash(as, pgoff);
+	struct page * page;
 
-	page = __find_get_page(as, pgoff, hash);
+	page = find_get_page(as, pgoff);
 	if (page) {
 		present = Page_Uptodate(page);
 		page_cache_release(page);
--- 2.5.8-pre3/mm/shmem.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/shmem.c	Tue Apr  9 20:35:31 2002
@@ -370,9 +370,10 @@ static int shmem_unuse_inode (struct shm
 	swp_entry_t *ptr;
 	unsigned long idx;
 	int offset;
-	
-	idx = 0;
+
 	spin_lock (&info->lock);
+repeat:
+	idx = 0;
 	offset = shmem_clear_swp (entry, info->i_direct, SHMEM_NR_DIRECT);
 	if (offset >= 0)
 		goto found;
@@ -389,13 +390,16 @@ static int shmem_unuse_inode (struct shm
 	spin_unlock (&info->lock);
 	return 0;
 found:
-	delete_from_swap_cache(page);
-	add_to_page_cache(page, info->vfs_inode.i_mapping, offset + idx);
-	SetPageDirty(page);
-	SetPageUptodate(page);
-	info->swapped--;
-	spin_unlock(&info->lock);
-	return 1;
+	if (!move_from_swap_cache (page, offset+idx, info->vfs_inode.i_mapping)) {
+		info->swapped--;
+		SetPageUptodate (page);
+		spin_unlock (&info->lock);
+		return 1;
+	}
+
+	/* Yield for kswapd, and try again */
+	yield();
+	goto repeat;
 }
 
 /*
@@ -425,6 +429,7 @@ void shmem_unuse(swp_entry_t entry, stru
  */
 static int shmem_writepage(struct page * page)
 {
+	int err;
 	struct shmem_inode_info *info;
 	swp_entry_t *entry, swap;
 	struct address_space *mapping;
@@ -442,7 +447,6 @@ static int shmem_writepage(struct page *
 	info = SHMEM_I(inode);
 	if (info->locked)
 		return fail_writepage(page);
-getswap:
 	swap = get_swap_page();
 	if (!swap.val)
 		return fail_writepage(page);
@@ -455,29 +459,20 @@ getswap:
 	if (entry->val)
 		BUG();
 
-	/* Remove it from the page cache */
-	remove_inode_page(page);
-	page_cache_release(page);
-
-	/* Add it to the swap cache */
-	if (add_to_swap_cache(page, swap) != 0) {
-		/*
-		 * Raced with "speculative" read_swap_cache_async.
-		 * Add page back to page cache, unref swap, try again.
-		 */
-		add_to_page_cache_locked(page, mapping, index);
+	err = move_to_swap_cache(page, swap);
+	if (!err) {
+		*entry = swap;
+		info->swapped++;
 		spin_unlock(&info->lock);
-		swap_free(swap);
-		goto getswap;
+		SetPageUptodate(page);
+		set_page_dirty(page);
+		UnlockPage(page);
+		return 0;
 	}
 
-	*entry = swap;
-	info->swapped++;
 	spin_unlock(&info->lock);
-	SetPageUptodate(page);
-	set_page_dirty(page);
-	UnlockPage(page);
-	return 0;
+	swap_free(swap);
+	return fail_writepage(page);
 }
 
 /*
@@ -493,10 +488,11 @@ getswap:
  */
 static struct page * shmem_getpage_locked(struct shmem_inode_info *info, struct inode * inode, unsigned long idx)
 {
-	struct address_space * mapping = inode->i_mapping;
+	struct address_space *mapping = inode->i_mapping;
 	struct shmem_sb_info *sbinfo;
-	struct page * page;
+	struct page *page;
 	swp_entry_t *entry;
+	int error;
 
 repeat:
 	page = find_lock_page(mapping, idx);
@@ -524,8 +520,6 @@ repeat:
 	
 	shmem_recalc_inode(inode);
 	if (entry->val) {
-		unsigned long flags;
-
 		/* Look it up and read it in.. */
 		page = find_get_page(&swapper_space, entry->val);
 		if (!page) {
@@ -550,16 +544,18 @@ repeat:
 			goto repeat;
 		}
 
-		/* We have to this with page locked to prevent races */
+		/* We have to do this with page locked to prevent races */
 		if (TryLockPage(page)) 
 			goto wait_retry;
 
+		error = move_from_swap_cache(page, idx, mapping);
+		if (error < 0) {
+			UnlockPage(page);
+			return ERR_PTR(error);
+		}
+
 		swap_free(*entry);
 		*entry = (swp_entry_t) {0};
-		delete_from_swap_cache(page);
-		flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_referenced) | (1 << PG_arch_1));
-		page->flags = flags | (1 << PG_dirty);
-		add_to_page_cache_locked(page, mapping, idx);
 		info->swapped--;
 		spin_unlock (&info->lock);
 	} else {
@@ -581,9 +577,13 @@ repeat:
 		page = page_cache_alloc(mapping);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
+		error = add_to_page_cache(page, mapping, idx);
+		if (error < 0) {
+			page_cache_release(page);
+			return ERR_PTR(-ENOMEM);
+		}
 		clear_highpage(page);
 		inode->i_blocks += BLOCKS_PER_PAGE;
-		add_to_page_cache (page, mapping, idx);
 	}
 
 	/* We have the page */
--- 2.5.8-pre3/mm/swapfile.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/swapfile.c	Tue Apr  9 20:35:31 2002
@@ -239,10 +239,10 @@ static int exclusive_swap_page(struct pa
 		/* Is the only swap cache user the cache itself? */
 		if (p->swap_map[SWP_OFFSET(entry)] == 1) {
 			/* Recheck the page count with the pagecache lock held.. */
-			spin_lock(&pagecache_lock);
+			read_lock(&swapper_space.page_lock);
 			if (page_count(page) - !!page->buffers == 2)
 				retval = 1;
-			spin_unlock(&pagecache_lock);
+			read_unlock(&swapper_space.page_lock);
 		}
 		swap_info_put(p);
 	}
@@ -307,13 +307,13 @@ int remove_exclusive_swap_page(struct pa
 	retval = 0;
 	if (p->swap_map[SWP_OFFSET(entry)] == 1) {
 		/* Recheck the page count with the pagecache lock held.. */
-		spin_lock(&pagecache_lock);
+		read_lock(&swapper_space.page_lock);
 		if (page_count(page) - !!page->buffers == 2) {
 			__delete_from_swap_cache(page);
 			SetPageDirty(page);
 			retval = 1;
 		}
-		spin_unlock(&pagecache_lock);
+		read_unlock(&swapper_space.page_lock);
 	}
 	swap_info_put(p);
 
--- 2.5.8-pre3/mm/swap_state.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/swap_state.c	Tue Apr  9 20:35:31 2002
@@ -37,11 +37,13 @@ static struct address_space_operations s
 };
 
 struct address_space swapper_space = {
-	LIST_HEAD_INIT(swapper_space.clean_pages),
-	LIST_HEAD_INIT(swapper_space.dirty_pages),
-	LIST_HEAD_INIT(swapper_space.locked_pages),
-	0,				/* nrpages	*/
-	&swap_aops,
+	page_tree:	RADIX_TREE_INIT(GFP_ATOMIC),
+	page_lock:	RW_LOCK_UNLOCKED,
+	clean_pages:	LIST_HEAD_INIT(swapper_space.clean_pages),
+	dirty_pages:	LIST_HEAD_INIT(swapper_space.dirty_pages),
+	locked_pages:	LIST_HEAD_INIT(swapper_space.locked_pages),
+	a_ops:		&swap_aops,
+	i_shared_lock:	SPIN_LOCK_UNLOCKED,
 };
 
 #ifdef SWAP_CACHE_INFO
@@ -69,17 +71,21 @@ void show_swap_cache_info(void)
 
 int add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
+	int error;
+
 	if (page->mapping)
 		BUG();
 	if (!swap_duplicate(entry)) {
 		INC_CACHE_INFO(noent_race);
 		return -ENOENT;
 	}
-	if (add_to_page_cache_unique(page, &swapper_space, entry.val,
-			page_hash(&swapper_space, entry.val)) != 0) {
+
+	error = add_to_page_cache_unique(page, &swapper_space, entry.val);
+	if (error != 0) {
 		swap_free(entry);
-		INC_CACHE_INFO(exist_race);
-		return -EEXIST;
+		if (error == -EEXIST)
+			INC_CACHE_INFO(exist_race);
+		return error;
 	}
 	if (!PageLocked(page))
 		BUG();
@@ -121,14 +127,96 @@ void delete_from_swap_cache(struct page 
 
 	entry.val = page->index;
 
-	spin_lock(&pagecache_lock);
+	write_lock(&swapper_space.page_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock(&pagecache_lock);
+	write_unlock(&swapper_space.page_lock);
 
 	swap_free(entry);
 	page_cache_release(page);
 }
 
+int move_to_swap_cache(struct page *page, swp_entry_t entry)
+{
+	struct address_space *mapping = page->mapping;
+	void **pslot;
+	int err;
+
+	if (!mapping)
+		BUG();
+
+	if (!swap_duplicate(entry)) {
+		INC_CACHE_INFO(noent_race);
+		return -ENOENT;
+	}
+
+	write_lock(&swapper_space.page_lock);
+	write_lock(&mapping->page_lock);
+
+	err = radix_tree_reserve(&swapper_space.page_tree, entry.val, &pslot);
+	if (!err) {
+		/* Remove it from the page cache */
+		__remove_inode_page (page);
+
+		/* Add it to the swap cache */
+		*pslot = page;
+		page->flags = ((page->flags & ~(1 << PG_uptodate | 1 << PG_error
+						| 1 << PG_dirty  | 1 << PG_referenced
+						| 1 << PG_arch_1 | 1 << PG_checked))
+			       | (1 << PG_locked));
+		___add_to_page_cache(page, &swapper_space, entry.val);
+	}
+
+	write_unlock(&mapping->page_lock);
+	write_unlock(&swapper_space.page_lock);
+
+	if (!err) {
+		INC_CACHE_INFO(add_total);
+		return 0;
+	}
+
+	swap_free(entry);
+
+	if (err == -EEXIST)
+		INC_CACHE_INFO(exist_race);
+
+	return err;
+}
+
+int move_from_swap_cache(struct page *page, unsigned long index,
+		struct address_space *mapping)
+{
+	void **pslot;
+	int err;
+
+	if (!PageLocked(page))
+		BUG();
+
+	write_lock(&swapper_space.page_lock);
+	write_lock(&mapping->page_lock);
+
+	err = radix_tree_reserve(&mapping->page_tree, index, &pslot);
+	if (!err) {
+		swp_entry_t entry;
+
+		block_flushpage(page, 0);
+		entry.val = page->index;
+		__delete_from_swap_cache(page);
+		swap_free(entry);
+
+		*pslot = page;
+		page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
+				 1 << PG_referenced | 1 << PG_arch_1 |
+				 1 << PG_checked);
+		page->flags |= (1 << PG_dirty);
+		___add_to_page_cache(page, mapping, index);
+	}
+
+	write_unlock(&mapping->page_lock);
+	write_unlock(&swapper_space.page_lock);
+
+	return err;
+}
+
 /* 
  * Perform a free_page(), also freeing any swap cache associated with
  * this page if it is the last user of the page. Can not do a lock_page,
@@ -213,6 +301,7 @@ struct page * read_swap_cache_async(swp_
 		 * swap cache: added by a racing read_swap_cache_async,
 		 * or by try_to_swap_out (or shmem_writepage) re-using
 		 * the just freed swap entry for an existing page.
+		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
 		err = add_to_swap_cache(new_page, entry);
 		if (!err) {
@@ -222,7 +311,7 @@ struct page * read_swap_cache_async(swp_
 			rw_swap_page(READ, new_page);
 			return new_page;
 		}
-	} while (err != -ENOENT);
+	} while (err != -ENOENT && err != -ENOMEM);
 
 	if (new_page)
 		page_cache_release(new_page);
--- 2.5.8-pre3/mm/vmscan.c~dallocbase-05-new_ratcache	Tue Apr  9 20:35:31 2002
+++ 2.5.8-pre3-akpm/mm/vmscan.c	Tue Apr  9 20:35:43 2002
@@ -138,10 +138,16 @@ drop_pte:
 		 * (adding to the page cache will clear the dirty
 		 * and uptodate bits, so we need to do it again)
 		 */
-		if (add_to_swap_cache(page, entry) == 0) {
+		switch (add_to_swap_cache(page, entry)) {
+		case 0:				/* Success */
 			SetPageUptodate(page);
 			set_page_dirty(page);
 			goto set_swap_pte;
+		case -ENOMEM:			/* radix-tree allocation */
+			swap_free(entry);
+			goto preserve;
+		default:			/* ENOENT: raced */
+			break;
 		}
 		/* Raced with "speculative" read_swap_cache_async */
 		swap_free(entry);
@@ -341,6 +347,7 @@ static int FASTCALL(shrink_cache(int nr_
 static int shrink_cache(int nr_pages, zone_t * classzone, unsigned int gfp_mask, int priority)
 {
 	struct list_head * entry;
+	struct address_space *mapping;
 	int max_scan = nr_inactive_pages / priority;
 	int max_mapped = nr_pages << (9 - priority);
 
@@ -395,7 +402,9 @@ static int shrink_cache(int nr_pages, zo
 			continue;
 		}
 
-		if (PageDirty(page) && is_page_cache_freeable(page) && page->mapping) {
+		mapping = page->mapping;
+
+		if (PageDirty(page) && is_page_cache_freeable(page) && mapping) {
 			/*
 			 * It is not critical here to write it only if
 			 * the page is unmapped beause any direct writer
@@ -406,7 +415,7 @@ static int shrink_cache(int nr_pages, zo
 			 */
 			int (*writepage)(struct page *);
 
-			writepage = page->mapping->a_ops->writepage;
+			writepage = mapping->a_ops->writepage;
 			if ((gfp_mask & __GFP_FS) && writepage) {
 				ClearPageDirty(page);
 				SetPageLaunder(page);
@@ -433,7 +442,7 @@ static int shrink_cache(int nr_pages, zo
 			page_cache_get(page);
 
 			if (try_to_release_page(page, gfp_mask)) {
-				if (!page->mapping) {
+				if (!mapping) {
 					/*
 					 * We must not allow an anon page
 					 * with no buffers to be visible on
@@ -470,33 +479,35 @@ static int shrink_cache(int nr_pages, zo
 			}
 		}
 
-		spin_lock(&pagecache_lock);
-
 		/*
-		 * this is the non-racy check for busy page.
+		 * This is the non-racy check for busy page.
 		 */
-		if (!page->mapping || !is_page_cache_freeable(page)) {
-			spin_unlock(&pagecache_lock);
-			UnlockPage(page);
+		if (mapping) {
+			write_lock(&mapping->page_lock);
+			if (is_page_cache_freeable(page))
+				goto page_freeable;
+			write_unlock(&mapping->page_lock);
+		}
+		UnlockPage(page);
 page_mapped:
-			if (--max_mapped >= 0)
-				continue;
+		if (--max_mapped >= 0)
+			continue;
 
-			/*
-			 * Alert! We've found too many mapped pages on the
-			 * inactive list, so we start swapping out now!
-			 */
-			spin_unlock(&pagemap_lru_lock);
-			swap_out(priority, gfp_mask, classzone);
-			return nr_pages;
-		}
+		/*
+		 * Alert! We've found too many mapped pages on the
+		 * inactive list, so we start swapping out now!
+		 */
+		spin_unlock(&pagemap_lru_lock);
+		swap_out(priority, gfp_mask, classzone);
+		return nr_pages;
 
+page_freeable:
 		/*
 		 * It is critical to check PageDirty _after_ we made sure
 		 * the page is freeable* so not in use by anybody.
 		 */
 		if (PageDirty(page)) {
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			UnlockPage(page);
 			continue;
 		}
@@ -504,12 +515,12 @@ page_mapped:
 		/* point of no return */
 		if (likely(!PageSwapCache(page))) {
 			__remove_inode_page(page);
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 		} else {
 			swp_entry_t swap;
 			swap.val = page->index;
 			__delete_from_swap_cache(page);
-			spin_unlock(&pagecache_lock);
+			write_unlock(&mapping->page_lock);
 			swap_free(swap);
 		}
 


-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
