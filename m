Date: Mon, 23 Jul 2007 22:48:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab API: Remove useless ctor parameter and reorder parameters
Message-ID: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Slab constructors currently have a flags parameter that is never used. And
the order of the arguments is opposite to other slab functions. The object
pointer is placed before the kmem_cache pointer.

Convert

	ctor(void *object, struct kmem_cache *s, unsigned long flags)

to

	ctor(struct kmem_cache *s, void *object)

throughout the kernel

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/arm/plat-s3c24xx/dma.c      |    2 +-
 arch/arm26/mm/memc.c             |    4 ++--
 arch/i386/mm/pgtable.c           |    2 +-
 arch/powerpc/kernel/rtas_flash.c |    2 +-
 arch/powerpc/mm/hugetlbpage.c    |    2 +-
 arch/powerpc/mm/init_64.c        |    2 +-
 arch/sh/mm/pmb.c                 |    3 +--
 drivers/mtd/ubi/eba.c            |    3 +--
 drivers/usb/mon/mon_text.c       |    4 ++--
 fs/block_dev.c                   |    2 +-
 fs/cifs/cifsfs.c                 |    2 +-
 fs/ext2/super.c                  |    2 +-
 fs/ext3/super.c                  |    2 +-
 fs/fuse/inode.c                  |    3 +--
 fs/inode.c                       |    2 +-
 fs/isofs/inode.c                 |    2 +-
 fs/locks.c                       |    2 +-
 fs/nfs/inode.c                   |    2 +-
 fs/proc/inode.c                  |    2 +-
 fs/reiserfs/super.c              |    2 +-
 fs/udf/super.c                   |    2 +-
 fs/xfs/linux-2.6/kmem.h          |    2 +-
 fs/xfs/linux-2.6/xfs_super.c     |    3 +--
 include/linux/slub_def.h         |    2 +-
 ipc/mqueue.c                     |    2 +-
 kernel/fork.c                    |    3 +--
 lib/idr.c                        |    3 +--
 lib/radix-tree.c                 |    2 +-
 mm/rmap.c                        |    3 +--
 mm/shmem.c                       |    3 +--
 mm/slab.c                        |   11 +++++------
 mm/slob.c                        |    6 +++---
 mm/slub.c                        |    8 ++++----
 net/socket.c                     |    2 +-
 34 files changed, 45 insertions(+), 54 deletions(-)

Index: linux-2.6.23-rc1/drivers/mtd/ubi/eba.c
===================================================================
--- linux-2.6.23-rc1.orig/drivers/mtd/ubi/eba.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/drivers/mtd/ubi/eba.c	2007-07-23 22:30:20.000000000 -0700
@@ -937,8 +937,7 @@ write_error:
  * @cache: the lock tree entry slab cache
  * @flags: constructor flags
  */
-static void ltree_entry_ctor(void *obj, struct kmem_cache *cache,
-			     unsigned long flags)
+static void ltree_entry_ctor(struct kmem_cache *cache, void *obj)
 {
 	struct ltree_entry *le = obj;
 
Index: linux-2.6.23-rc1/drivers/usb/mon/mon_text.c
===================================================================
--- linux-2.6.23-rc1.orig/drivers/usb/mon/mon_text.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/drivers/usb/mon/mon_text.c	2007-07-23 22:30:20.000000000 -0700
@@ -84,7 +84,7 @@ struct mon_reader_text {
 
 static struct dentry *mon_dir;		/* Usually /sys/kernel/debug/usbmon */
 
-static void mon_text_ctor(void *, struct kmem_cache *, unsigned long);
+static void mon_text_ctor(struct kmem_cache *, void *);
 
 struct mon_text_ptr {
 	int cnt, limit;
@@ -718,7 +718,7 @@ void mon_text_del(struct mon_bus *mbus)
 /*
  * Slab interface: constructor.
  */
-static void mon_text_ctor(void *mem, struct kmem_cache *slab, unsigned long sflags)
+static void mon_text_ctor(struct kmem_cache *slab, void *mem)
 {
 	/*
 	 * Nothing to initialize. No, really!
Index: linux-2.6.23-rc1/fs/block_dev.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/block_dev.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/block_dev.c	2007-07-23 22:30:20.000000000 -0700
@@ -453,7 +453,7 @@ static void bdev_destroy_inode(struct in
 	kmem_cache_free(bdev_cachep, bdi);
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct bdev_inode *ei = (struct bdev_inode *) foo;
 	struct block_device *bdev = &ei->bdev;
Index: linux-2.6.23-rc1/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/cifs/cifsfs.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/cifs/cifsfs.c	2007-07-23 22:30:20.000000000 -0700
@@ -704,7 +704,7 @@ const struct file_operations cifs_dir_op
 };
 
 static void
-cifs_init_once(void *inode, struct kmem_cache *cachep, unsigned long flags)
+cifs_init_once(struct kmem_cache *cachep, void *inode)
 {
 	struct cifsInodeInfo *cifsi = inode;
 
Index: linux-2.6.23-rc1/fs/ext2/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ext2/super.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/ext2/super.c	2007-07-23 22:30:20.000000000 -0700
@@ -157,7 +157,7 @@ static void ext2_destroy_inode(struct in
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ext2_inode_info *ei = (struct ext2_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/ext3/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ext3/super.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/ext3/super.c	2007-07-23 22:30:20.000000000 -0700
@@ -472,7 +472,7 @@ static void ext3_destroy_inode(struct in
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ext3_inode_info *ei = (struct ext3_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/fuse/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/fuse/inode.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/fuse/inode.c	2007-07-23 22:30:20.000000000 -0700
@@ -683,8 +683,7 @@ static inline void unregister_fuseblk(vo
 static decl_subsys(fuse, NULL, NULL);
 static decl_subsys(connections, NULL, NULL);
 
-static void fuse_inode_init_once(void *foo, struct kmem_cache *cachep,
-				 unsigned long flags)
+static void fuse_inode_init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct inode * inode = foo;
 
Index: linux-2.6.23-rc1/fs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/inode.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/inode.c	2007-07-23 22:30:20.000000000 -0700
@@ -209,7 +209,7 @@ void inode_init_once(struct inode *inode
 
 EXPORT_SYMBOL(inode_init_once);
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct inode * inode = (struct inode *) foo;
 
Index: linux-2.6.23-rc1/fs/isofs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/isofs/inode.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/isofs/inode.c	2007-07-23 22:30:20.000000000 -0700
@@ -73,7 +73,7 @@ static void isofs_destroy_inode(struct i
 	kmem_cache_free(isofs_inode_cachep, ISOFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct iso_inode_info *ei = foo;
 
Index: linux-2.6.23-rc1/fs/locks.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/locks.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/locks.c	2007-07-23 22:30:20.000000000 -0700
@@ -199,7 +199,7 @@ EXPORT_SYMBOL(locks_init_lock);
  * Initialises the fields of the file lock which are invariant for
  * free file_locks.
  */
-static void init_once(void *foo, struct kmem_cache *cache, unsigned long flags)
+static void init_once(struct kmem_cache *cache, void *foo)
 {
 	struct file_lock *lock = (struct file_lock *) foo;
 
Index: linux-2.6.23-rc1/fs/nfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/nfs/inode.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/nfs/inode.c	2007-07-23 22:30:20.000000000 -0700
@@ -1151,7 +1151,7 @@ static inline void nfs4_init_once(struct
 #endif
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct nfs_inode *nfsi = (struct nfs_inode *) foo;
 
Index: linux-2.6.23-rc1/fs/proc/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/proc/inode.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/proc/inode.c	2007-07-23 22:30:20.000000000 -0700
@@ -106,7 +106,7 @@ static void proc_destroy_inode(struct in
 	kmem_cache_free(proc_inode_cachep, PROC_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct proc_inode *ei = (struct proc_inode *) foo;
 
Index: linux-2.6.23-rc1/fs/reiserfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/reiserfs/super.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/reiserfs/super.c	2007-07-23 22:30:20.000000000 -0700
@@ -508,7 +508,7 @@ static void reiserfs_destroy_inode(struc
 	kmem_cache_free(reiserfs_inode_cachep, REISERFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct reiserfs_inode_info *ei = (struct reiserfs_inode_info *)foo;
 
Index: linux-2.6.23-rc1/fs/udf/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/udf/super.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/udf/super.c	2007-07-23 22:30:20.000000000 -0700
@@ -134,7 +134,7 @@ static void udf_destroy_inode(struct ino
 	kmem_cache_free(udf_inode_cachep, UDF_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct udf_inode_info *ei = (struct udf_inode_info *)foo;
 
Index: linux-2.6.23-rc1/ipc/mqueue.c
===================================================================
--- linux-2.6.23-rc1.orig/ipc/mqueue.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/ipc/mqueue.c	2007-07-23 22:30:20.000000000 -0700
@@ -211,7 +211,7 @@ static int mqueue_get_sb(struct file_sys
 	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct mqueue_inode_info *p = (struct mqueue_inode_info *) foo;
 
Index: linux-2.6.23-rc1/kernel/fork.c
===================================================================
--- linux-2.6.23-rc1.orig/kernel/fork.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/kernel/fork.c	2007-07-23 22:30:20.000000000 -0700
@@ -1432,8 +1432,7 @@ long do_fork(unsigned long clone_flags,
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
 
-static void sighand_ctor(void *data, struct kmem_cache *cachep,
-			unsigned long flags)
+static void sighand_ctor(struct kmem_cache *cachep, void *data)
 {
 	struct sighand_struct *sighand = data;
 
Index: linux-2.6.23-rc1/mm/rmap.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/rmap.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/mm/rmap.c	2007-07-23 22:30:20.000000000 -0700
@@ -137,8 +137,7 @@ void anon_vma_unlink(struct vm_area_stru
 		anon_vma_free(anon_vma);
 }
 
-static void anon_vma_ctor(void *data, struct kmem_cache *cachep,
-			  unsigned long flags)
+static void anon_vma_ctor(struct kmem_cache *cachep, void *data)
 {
 	struct anon_vma *anon_vma = data;
 
Index: linux-2.6.23-rc1/mm/shmem.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/shmem.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/mm/shmem.c	2007-07-23 22:30:20.000000000 -0700
@@ -2306,8 +2306,7 @@ static void shmem_destroy_inode(struct i
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep,
-		      unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
 
Index: linux-2.6.23-rc1/mm/slab.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/slab.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/mm/slab.c	2007-07-23 22:30:27.000000000 -0700
@@ -408,7 +408,7 @@ struct kmem_cache {
 	unsigned int dflags;		/* dynamic flags */
 
 	/* constructor func */
-	void (*ctor) (void *, struct kmem_cache *, unsigned long);
+	void (*ctor)(struct kmem_cache *, void *);
 
 /* 5) cache creation/removal */
 	const char *name;
@@ -2124,7 +2124,7 @@ static int __init_refok setup_cpu_cache(
 struct kmem_cache *
 kmem_cache_create (const char *name, size_t size, size_t align,
 	unsigned long flags,
-	void (*ctor)(void*, struct kmem_cache *, unsigned long))
+	void (*ctor)(struct kmem_cache *, void *))
 {
 	size_t left_over, slab_size, ralign;
 	struct kmem_cache *cachep = NULL, *pc;
@@ -2631,8 +2631,7 @@ static void cache_init_objs(struct kmem_
 		 * They must also be threaded.
 		 */
 		if (cachep->ctor && !(cachep->flags & SLAB_POISON))
-			cachep->ctor(objp + obj_offset(cachep), cachep,
-				     0);
+			cachep->ctor(cachep, objp + obj_offset(cachep));
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
@@ -2648,7 +2647,7 @@ static void cache_init_objs(struct kmem_
 					 cachep->buffer_size / PAGE_SIZE, 0);
 #else
 		if (cachep->ctor)
-			cachep->ctor(objp, cachep, 0);
+			cachep->ctor(cachep, objp);
 #endif
 		slab_bufctl(slabp)[i] = i + 1;
 	}
@@ -3073,7 +3072,7 @@ static void *cache_alloc_debugcheck_afte
 #endif
 	objp += obj_offset(cachep);
 	if (cachep->ctor && cachep->flags & SLAB_POISON)
-		cachep->ctor(objp, cachep, 0);
+		cachep->ctor(cachep, objp);
 #if ARCH_SLAB_MINALIGN
 	if ((u32)objp & (ARCH_SLAB_MINALIGN-1)) {
 		printk(KERN_ERR "0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
Index: linux-2.6.23-rc1/mm/slob.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/slob.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/mm/slob.c	2007-07-23 22:30:20.000000000 -0700
@@ -498,12 +498,12 @@ struct kmem_cache {
 	unsigned int size, align;
 	unsigned long flags;
 	const char *name;
-	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	void (*ctor)(struct kmem_cache *, void *);
 };
 
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 	size_t align, unsigned long flags,
-	void (*ctor)(void*, struct kmem_cache *, unsigned long))
+	void (*ctor)(struct kmem_cache *, void *))
 {
 	struct kmem_cache *c;
 
@@ -547,7 +547,7 @@ void *kmem_cache_alloc_node(struct kmem_
 		b = slob_new_page(flags, get_order(c->size), node);
 
 	if (c->ctor)
-		c->ctor(b, c, 0);
+		c->ctor(c, b);
 
 	return b;
 }
Index: linux-2.6.23-rc1/mm/slub.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/slub.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/mm/slub.c	2007-07-23 22:30:20.000000000 -0700
@@ -1066,7 +1066,7 @@ static void setup_object(struct kmem_cac
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
-		s->ctor(object, s, 0);
+		s->ctor(s, object);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -2073,7 +2073,7 @@ static int calculate_sizes(struct kmem_c
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	memset(s, 0, kmem_size);
 	s->name = name;
@@ -2627,7 +2627,7 @@ static int slab_unmergeable(struct kmem_
 
 static struct kmem_cache *find_mergeable(size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	struct kmem_cache *s;
 
@@ -2668,7 +2668,7 @@ static struct kmem_cache *find_mergeable
 
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	struct kmem_cache *s;
 
Index: linux-2.6.23-rc1/include/linux/slub_def.h
===================================================================
--- linux-2.6.23-rc1.orig/include/linux/slub_def.h	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/include/linux/slub_def.h	2007-07-23 22:30:20.000000000 -0700
@@ -41,7 +41,7 @@ struct kmem_cache {
 	/* Allocation and freeing of slabs */
 	int objects;		/* Number of objects in slab */
 	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	void (*ctor)(struct kmem_cache *, void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */
Index: linux-2.6.23-rc1/arch/arm26/mm/memc.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/arm26/mm/memc.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/arch/arm26/mm/memc.c	2007-07-23 22:30:20.000000000 -0700
@@ -162,12 +162,12 @@ void __init create_memmap_holes(struct m
 {
 }
 
-static void pte_cache_ctor(void *pte, struct kmem_cache *cache, unsigned long flags)
+static void pte_cache_ctor(struct kmem_cache *cache, void *pte)
 {
 	memzero(pte, sizeof(pte_t) * PTRS_PER_PTE);
 }
 
-static void pgd_cache_ctor(void *pgd, struct kmem_cache *cache, unsigned long flags)
+static void pgd_cache_ctor(struct kmem_cache *cache, void *pgd)
 {
 	memzero(pgd + MEMC_TABLE_SIZE, USER_PTRS_PER_PGD * sizeof(pgd_t));
 }
Index: linux-2.6.23-rc1/arch/powerpc/kernel/rtas_flash.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/powerpc/kernel/rtas_flash.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/arch/powerpc/kernel/rtas_flash.c	2007-07-23 22:30:20.000000000 -0700
@@ -286,7 +286,7 @@ static ssize_t rtas_flash_read(struct fi
 }
 
 /* constructor for flash_block_cache */
-void rtas_block_ctor(void *ptr, struct kmem_cache *cache, unsigned long flags)
+void rtas_block_ctor(struct kmem_cache *cache, void *ptr)
 {
 	memset(ptr, 0, RTAS_BLK_SIZE);
 }
Index: linux-2.6.23-rc1/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/powerpc/mm/hugetlbpage.c	2007-07-23 22:30:04.000000000 -0700
+++ linux-2.6.23-rc1/arch/powerpc/mm/hugetlbpage.c	2007-07-23 22:30:20.000000000 -0700
@@ -528,7 +528,7 @@ repeat:
 	return err;
 }
 
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
+static void zero_ctor(struct kmem_cache *cache, void *addr)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
Index: linux-2.6.23-rc1/arch/powerpc/mm/init_64.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/powerpc/mm/init_64.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/arch/powerpc/mm/init_64.c	2007-07-23 22:30:20.000000000 -0700
@@ -140,7 +140,7 @@ static int __init setup_kcore(void)
 }
 module_init(setup_kcore);
 
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
+static void zero_ctor(struct kmem_cache *cache, void *addr)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
Index: linux-2.6.23-rc1/fs/xfs/linux-2.6/kmem.h
===================================================================
--- linux-2.6.23-rc1.orig/fs/xfs/linux-2.6/kmem.h	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/fs/xfs/linux-2.6/kmem.h	2007-07-23 22:30:20.000000000 -0700
@@ -79,7 +79,7 @@ kmem_zone_init(int size, char *zone_name
 
 static inline kmem_zone_t *
 kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
-		     void (*construct)(void *, kmem_zone_t *, unsigned long))
+		     void (*construct)(kmem_zone_t *, void *))
 {
 	return kmem_cache_create(zone_name, size, 0, flags, construct);
 }
Index: linux-2.6.23-rc1/lib/idr.c
===================================================================
--- linux-2.6.23-rc1.orig/lib/idr.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/lib/idr.c	2007-07-23 22:30:20.000000000 -0700
@@ -580,8 +580,7 @@ void *idr_replace(struct idr *idp, void 
 }
 EXPORT_SYMBOL(idr_replace);
 
-static void idr_cache_ctor(void * idr_layer, struct kmem_cache *idr_layer_cache,
-		unsigned long flags)
+static void idr_cache_ctor(struct kmem_cache *idr_layer_cache, void *idr_layer)
 {
 	memset(idr_layer, 0, sizeof(struct idr_layer));
 }
Index: linux-2.6.23-rc1/lib/radix-tree.c
===================================================================
--- linux-2.6.23-rc1.orig/lib/radix-tree.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/lib/radix-tree.c	2007-07-23 22:30:20.000000000 -0700
@@ -974,7 +974,7 @@ int radix_tree_tagged(struct radix_tree_
 EXPORT_SYMBOL(radix_tree_tagged);
 
 static void
-radix_tree_node_ctor(void *node, struct kmem_cache *cachep, unsigned long flags)
+radix_tree_node_ctor(struct kmem_cache *cachep, void *node)
 {
 	memset(node, 0, sizeof(struct radix_tree_node));
 }
Index: linux-2.6.23-rc1/arch/arm/plat-s3c24xx/dma.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/arm/plat-s3c24xx/dma.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/arch/arm/plat-s3c24xx/dma.c	2007-07-23 22:30:20.000000000 -0700
@@ -1272,7 +1272,7 @@ struct sysdev_class dma_sysclass = {
 
 /* kmem cache implementation */
 
-static void s3c2410_dma_cache_ctor(void *p, struct kmem_cache *c, unsigned long f)
+static void s3c2410_dma_cache_ctor(struct kmem_cache *c, void *p)
 {
 	memset(p, 0, sizeof(struct s3c2410_dma_buf));
 }
Index: linux-2.6.23-rc1/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/i386/mm/pgtable.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/arch/i386/mm/pgtable.c	2007-07-23 22:30:20.000000000 -0700
@@ -193,7 +193,7 @@ struct page *pte_alloc_one(struct mm_str
 	return pte;
 }
 
-void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
+void pmd_ctor(struct kmem_cache *cache, void *pmd)
 {
 	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
 }
Index: linux-2.6.23-rc1/arch/sh/mm/pmb.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/sh/mm/pmb.c	2007-07-23 22:30:03.000000000 -0700
+++ linux-2.6.23-rc1/arch/sh/mm/pmb.c	2007-07-23 22:30:20.000000000 -0700
@@ -292,8 +292,7 @@ void pmb_unmap(unsigned long addr)
 	} while (pmbe);
 }
 
-static void pmb_cache_ctor(void *pmb, struct kmem_cache *cachep,
-			   unsigned long flags)
+static void pmb_cache_ctor(struct kmem_cache *cachep, void *pmb)
 {
 	struct pmb_entry *pmbe = pmb;
 
Index: linux-2.6.23-rc1/net/socket.c
===================================================================
--- linux-2.6.23-rc1.orig/net/socket.c	2007-07-23 22:30:49.000000000 -0700
+++ linux-2.6.23-rc1/net/socket.c	2007-07-23 22:31:05.000000000 -0700
@@ -257,7 +257,7 @@ static void sock_destroy_inode(struct in
 			container_of(inode, struct socket_alloc, vfs_inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct socket_alloc *ei = (struct socket_alloc *)foo;
 
Index: linux-2.6.23-rc1/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/xfs/linux-2.6/xfs_super.c	2007-07-23 22:33:16.000000000 -0700
+++ linux-2.6.23-rc1/fs/xfs/linux-2.6/xfs_super.c	2007-07-23 22:33:55.000000000 -0700
@@ -356,9 +356,8 @@ xfs_fs_destroy_inode(
 
 STATIC void
 xfs_fs_inode_init_once(
-	void			*vnode,
 	kmem_zone_t		*zonep,
-	unsigned long		flags)
+	void			*vnode)
 {
 	inode_init_once(vn_to_inode((bhv_vnode_t *)vnode));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
