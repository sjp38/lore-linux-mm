Date: Fri, 14 Sep 2007 15:17:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab API: Remove useless ctor parameter and reorder parameters
Message-ID: <Pine.LNX.4.64.0709141516480.14837@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
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
 arch/arm/plat-s3c24xx/dma.c               |    2 +-
 arch/i386/mm/pgtable.c                    |    2 +-
 arch/powerpc/kernel/rtas_flash.c          |    2 +-
 arch/powerpc/mm/hugetlbpage.c             |    2 +-
 arch/powerpc/mm/init_64.c                 |    2 +-
 arch/powerpc/platforms/cell/spufs/inode.c |    2 +-
 arch/sh/mm/pmb.c                          |    3 +--
 drivers/mtd/ubi/eba.c                     |    3 +--
 drivers/usb/mon/mon_text.c                |    4 ++--
 fs/adfs/super.c                           |    2 +-
 fs/affs/super.c                           |    2 +-
 fs/afs/super.c                            |    6 ++----
 fs/befs/linuxvfs.c                        |    2 +-
 fs/bfs/inode.c                            |    2 +-
 fs/block_dev.c                            |    2 +-
 fs/cifs/cifsfs.c                          |    2 +-
 fs/coda/inode.c                           |    2 +-
 fs/ecryptfs/main.c                        |    2 +-
 fs/efs/super.c                            |    2 +-
 fs/ext2/super.c                           |    2 +-
 fs/ext3/super.c                           |    2 +-
 fs/ext4/super.c                           |    2 +-
 fs/fat/cache.c                            |    2 +-
 fs/fat/inode.c                            |    2 +-
 fs/fuse/inode.c                           |    3 +--
 fs/gfs2/main.c                            |    4 ++--
 fs/hfs/super.c                            |    2 +-
 fs/hfsplus/super.c                        |    2 +-
 fs/hpfs/super.c                           |    2 +-
 fs/hugetlbfs/inode.c                      |    2 +-
 fs/inode.c                                |    2 +-
 fs/isofs/inode.c                          |    2 +-
 fs/jffs2/super.c                          |    2 +-
 fs/jfs/jfs_metapage.c                     |    2 +-
 fs/jfs/super.c                            |    2 +-
 fs/locks.c                                |    2 +-
 fs/minix/inode.c                          |    2 +-
 fs/ncpfs/inode.c                          |    2 +-
 fs/nfs/inode.c                            |    2 +-
 fs/ntfs/super.c                           |    3 +--
 fs/ocfs2/dlm/dlmfs.c                      |    5 ++---
 fs/ocfs2/super.c                          |    4 +---
 fs/openpromfs/inode.c                     |    2 +-
 fs/proc/inode.c                           |    2 +-
 fs/qnx4/inode.c                           |    3 +--
 fs/reiserfs/super.c                       |    2 +-
 fs/romfs/inode.c                          |    2 +-
 fs/smbfs/inode.c                          |    2 +-
 fs/sysv/inode.c                           |    2 +-
 fs/udf/super.c                            |    2 +-
 fs/ufs/super.c                            |    2 +-
 fs/xfs/linux-2.6/kmem.h                   |    2 +-
 fs/xfs/linux-2.6/xfs_super.c              |    3 +--
 include/asm-i386/pgtable.h                |    2 +-
 include/linux/slab.h                      |    2 +-
 include/linux/slub_def.h                  |    2 +-
 ipc/mqueue.c                              |    2 +-
 kernel/fork.c                             |    3 +--
 lib/idr.c                                 |    3 +--
 lib/radix-tree.c                          |    2 +-
 mm/rmap.c                                 |    3 +--
 mm/shmem.c                                |    3 +--
 mm/slab.c                                 |   11 +++++------
 mm/slob.c                                 |    6 +++---
 mm/slub.c                                 |    8 ++++----
 net/socket.c                              |    2 +-
 net/sunrpc/rpc_pipe.c                     |    2 +-
 67 files changed, 80 insertions(+), 96 deletions(-)

Index: linux-2.6/arch/arm/plat-s3c24xx/dma.c
===================================================================
--- linux-2.6.orig/arch/arm/plat-s3c24xx/dma.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/arm/plat-s3c24xx/dma.c	2007-09-14 13:54:51.000000000 -0700
@@ -1272,7 +1272,7 @@ struct sysdev_class dma_sysclass = {
 
 /* kmem cache implementation */
 
-static void s3c2410_dma_cache_ctor(void *p, struct kmem_cache *c, unsigned long f)
+static void s3c2410_dma_cache_ctor(struct kmem_cache *c, void *p)
 {
 	memset(p, 0, sizeof(struct s3c2410_dma_buf));
 }
Index: linux-2.6/arch/i386/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/pgtable.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/i386/mm/pgtable.c	2007-09-14 13:54:51.000000000 -0700
@@ -193,7 +193,7 @@ struct page *pte_alloc_one(struct mm_str
 	return pte;
 }
 
-void pmd_ctor(void *pmd, struct kmem_cache *cache, unsigned long flags)
+void pmd_ctor(struct kmem_cache *cache, void *pmd)
 {
 	memset(pmd, 0, PTRS_PER_PMD*sizeof(pmd_t));
 }
Index: linux-2.6/arch/powerpc/kernel/rtas_flash.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/rtas_flash.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/powerpc/kernel/rtas_flash.c	2007-09-14 13:54:51.000000000 -0700
@@ -286,7 +286,7 @@ static ssize_t rtas_flash_read(struct fi
 }
 
 /* constructor for flash_block_cache */
-void rtas_block_ctor(void *ptr, struct kmem_cache *cache, unsigned long flags)
+void rtas_block_ctor(struct kmem_cache *cache, void *ptr)
 {
 	memset(ptr, 0, RTAS_BLK_SIZE);
 }
Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c	2007-09-14 13:54:51.000000000 -0700
@@ -528,7 +528,7 @@ repeat:
 	return err;
 }
 
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
+static void zero_ctor(struct kmem_cache *cache, void *addr)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
Index: linux-2.6/arch/powerpc/mm/init_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/init_64.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/powerpc/mm/init_64.c	2007-09-14 13:54:51.000000000 -0700
@@ -140,7 +140,7 @@ static int __init setup_kcore(void)
 }
 module_init(setup_kcore);
 
-static void zero_ctor(void *addr, struct kmem_cache *cache, unsigned long flags)
+static void zero_ctor(struct kmem_cache *cache, void *addr)
 {
 	memset(addr, 0, kmem_cache_size(cache));
 }
Index: linux-2.6/arch/powerpc/platforms/cell/spufs/inode.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -67,7 +67,7 @@ spufs_destroy_inode(struct inode *inode)
 }
 
 static void
-spufs_init_once(void *p, struct kmem_cache * cachep, unsigned long flags)
+spufs_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct spufs_inode_info *ei = p;
 
Index: linux-2.6/arch/sh/mm/pmb.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/pmb.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/arch/sh/mm/pmb.c	2007-09-14 13:54:51.000000000 -0700
@@ -292,8 +292,7 @@ void pmb_unmap(unsigned long addr)
 	} while (pmbe);
 }
 
-static void pmb_cache_ctor(void *pmb, struct kmem_cache *cachep,
-			   unsigned long flags)
+static void pmb_cache_ctor(struct kmem_cache *cachep, void *pmb)
 {
 	struct pmb_entry *pmbe = pmb;
 
Index: linux-2.6/drivers/mtd/ubi/eba.c
===================================================================
--- linux-2.6.orig/drivers/mtd/ubi/eba.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/drivers/mtd/ubi/eba.c	2007-09-14 13:54:51.000000000 -0700
@@ -937,8 +937,7 @@ write_error:
  * @cache: the lock tree entry slab cache
  * @flags: constructor flags
  */
-static void ltree_entry_ctor(void *obj, struct kmem_cache *cache,
-			     unsigned long flags)
+static void ltree_entry_ctor(struct kmem_cache *cache, void *obj)
 {
 	struct ltree_entry *le = obj;
 
Index: linux-2.6/drivers/usb/mon/mon_text.c
===================================================================
--- linux-2.6.orig/drivers/usb/mon/mon_text.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/drivers/usb/mon/mon_text.c	2007-09-14 13:54:51.000000000 -0700
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
Index: linux-2.6/fs/adfs/super.c
===================================================================
--- linux-2.6.orig/fs/adfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/adfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -228,7 +228,7 @@ static void adfs_destroy_inode(struct in
 	kmem_cache_free(adfs_inode_cachep, ADFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct adfs_inode_info *ei = (struct adfs_inode_info *) foo;
 
Index: linux-2.6/fs/affs/super.c
===================================================================
--- linux-2.6.orig/fs/affs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/affs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -84,7 +84,7 @@ static void affs_destroy_inode(struct in
 	kmem_cache_free(affs_inode_cachep, AFFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct affs_inode_info *ei = (struct affs_inode_info *) foo;
 
Index: linux-2.6/fs/afs/super.c
===================================================================
--- linux-2.6.orig/fs/afs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/afs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -27,8 +27,7 @@
 
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
 
-static void afs_i_init_once(void *foo, struct kmem_cache *cachep,
-			    unsigned long flags);
+static void afs_i_init_once(struct kmem_cache *cachep, void *foo);
 static int afs_get_sb(struct file_system_type *fs_type,
 		      int flags, const char *dev_name,
 		      void *data, struct vfsmount *mnt);
@@ -446,8 +445,7 @@ static void afs_put_super(struct super_b
 /*
  * initialise an inode cache slab element prior to any use
  */
-static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
-			    unsigned long flags)
+static void afs_i_init_once(struct kmem_cache *cachep, void *_vnode)
 {
 	struct afs_vnode *vnode = _vnode;
 
Index: linux-2.6/fs/befs/linuxvfs.c
===================================================================
--- linux-2.6.orig/fs/befs/linuxvfs.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/befs/linuxvfs.c	2007-09-14 13:54:51.000000000 -0700
@@ -289,7 +289,7 @@ befs_destroy_inode(struct inode *inode)
         kmem_cache_free(befs_inode_cachep, BEFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
         struct befs_inode_info *bi = (struct befs_inode_info *) foo;
 
Index: linux-2.6/fs/bfs/inode.c
===================================================================
--- linux-2.6.orig/fs/bfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/bfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -244,7 +244,7 @@ static void bfs_destroy_inode(struct ino
 	kmem_cache_free(bfs_inode_cachep, BFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct bfs_inode_info *bi = foo;
 
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/block_dev.c	2007-09-14 13:54:51.000000000 -0700
@@ -453,7 +453,7 @@ static void bdev_destroy_inode(struct in
 	kmem_cache_free(bdev_cachep, bdi);
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct bdev_inode *ei = (struct bdev_inode *) foo;
 	struct block_device *bdev = &ei->bdev;
Index: linux-2.6/fs/cifs/cifsfs.c
===================================================================
--- linux-2.6.orig/fs/cifs/cifsfs.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/cifs/cifsfs.c	2007-09-14 13:54:51.000000000 -0700
@@ -704,7 +704,7 @@ const struct file_operations cifs_dir_op
 };
 
 static void
-cifs_init_once(void *inode, struct kmem_cache *cachep, unsigned long flags)
+cifs_init_once(struct kmem_cache *cachep, void *inode)
 {
 	struct cifsInodeInfo *cifsi = inode;
 
Index: linux-2.6/fs/coda/inode.c
===================================================================
--- linux-2.6.orig/fs/coda/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/coda/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -58,7 +58,7 @@ static void coda_destroy_inode(struct in
 	kmem_cache_free(coda_inode_cachep, ITOC(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct coda_inode_info *ei = (struct coda_inode_info *) foo;
 
Index: linux-2.6/fs/ecryptfs/main.c
===================================================================
--- linux-2.6.orig/fs/ecryptfs/main.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ecryptfs/main.c	2007-09-14 13:54:51.000000000 -0700
@@ -579,7 +579,7 @@ static struct file_system_type ecryptfs_
  * Initializes the ecryptfs_inode_info_cache when it is created
  */
 static void
-inode_info_init_once(void *vptr, struct kmem_cache *cachep, unsigned long flags)
+inode_info_init_once(struct kmem_cache *cachep, void *vptr)
 {
 	struct ecryptfs_inode_info *ei = (struct ecryptfs_inode_info *)vptr;
 
Index: linux-2.6/fs/efs/super.c
===================================================================
--- linux-2.6.orig/fs/efs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/efs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -69,7 +69,7 @@ static void efs_destroy_inode(struct ino
 	kmem_cache_free(efs_inode_cachep, INODE_INFO(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct efs_inode_info *ei = (struct efs_inode_info *) foo;
 
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ext2/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -157,7 +157,7 @@ static void ext2_destroy_inode(struct in
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ext2_inode_info *ei = (struct ext2_inode_info *) foo;
 
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ext3/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -472,7 +472,7 @@ static void ext3_destroy_inode(struct in
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ext3_inode_info *ei = (struct ext3_inode_info *) foo;
 
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ext4/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -523,7 +523,7 @@ static void ext4_destroy_inode(struct in
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct ext4_inode_info *ei = (struct ext4_inode_info *) foo;
 
Index: linux-2.6/fs/fat/cache.c
===================================================================
--- linux-2.6.orig/fs/fat/cache.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/fat/cache.c	2007-09-14 13:54:51.000000000 -0700
@@ -36,7 +36,7 @@ static inline int fat_max_cache(struct i
 
 static struct kmem_cache *fat_cache_cachep;
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct fat_cache *cache = (struct fat_cache *)foo;
 
Index: linux-2.6/fs/fat/inode.c
===================================================================
--- linux-2.6.orig/fs/fat/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/fat/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -496,7 +496,7 @@ static void fat_destroy_inode(struct ino
 	kmem_cache_free(fat_inode_cachep, MSDOS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct msdos_inode_info *ei = (struct msdos_inode_info *)foo;
 
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/fuse/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -683,8 +683,7 @@ static inline void unregister_fuseblk(vo
 static decl_subsys(fuse, NULL, NULL);
 static decl_subsys(connections, NULL, NULL);
 
-static void fuse_inode_init_once(void *foo, struct kmem_cache *cachep,
-				 unsigned long flags)
+static void fuse_inode_init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct inode * inode = foo;
 
Index: linux-2.6/fs/gfs2/main.c
===================================================================
--- linux-2.6.orig/fs/gfs2/main.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/gfs2/main.c	2007-09-14 13:54:51.000000000 -0700
@@ -24,7 +24,7 @@
 #include "util.h"
 #include "glock.h"
 
-static void gfs2_init_inode_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void gfs2_init_inode_once(struct kmem_cache *cachep, void *foo)
 {
 	struct gfs2_inode *ip = foo;
 
@@ -34,7 +34,7 @@ static void gfs2_init_inode_once(void *f
 	memset(ip->i_cache, 0, sizeof(ip->i_cache));
 }
 
-static void gfs2_init_glock_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void gfs2_init_glock_once(struct kmem_cache *cachep, void *foo)
 {
 	struct gfs2_glock *gl = foo;
 
Index: linux-2.6/fs/hfs/super.c
===================================================================
--- linux-2.6.orig/fs/hfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/hfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -430,7 +430,7 @@ static struct file_system_type hfs_fs_ty
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfs_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void hfs_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct hfs_inode_info *i = p;
 
Index: linux-2.6/fs/hfsplus/super.c
===================================================================
--- linux-2.6.orig/fs/hfsplus/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/hfsplus/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -466,7 +466,7 @@ static struct file_system_type hfsplus_f
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfsplus_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void hfsplus_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct hfsplus_inode_info *i = p;
 
Index: linux-2.6/fs/hpfs/super.c
===================================================================
--- linux-2.6.orig/fs/hpfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/hpfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -173,7 +173,7 @@ static void hpfs_destroy_inode(struct in
 	kmem_cache_free(hpfs_inode_cachep, hpfs_i(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct hpfs_inode_info *ei = (struct hpfs_inode_info *) foo;
 
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/hugetlbfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -575,7 +575,7 @@ static const struct address_space_operat
 };
 
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
 
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -209,7 +209,7 @@ void inode_init_once(struct inode *inode
 
 EXPORT_SYMBOL(inode_init_once);
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct inode * inode = (struct inode *) foo;
 
Index: linux-2.6/fs/isofs/inode.c
===================================================================
--- linux-2.6.orig/fs/isofs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/isofs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -73,7 +73,7 @@ static void isofs_destroy_inode(struct i
 	kmem_cache_free(isofs_inode_cachep, ISOFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct iso_inode_info *ei = foo;
 
Index: linux-2.6/fs/jffs2/super.c
===================================================================
--- linux-2.6.orig/fs/jffs2/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/jffs2/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -43,7 +43,7 @@ static void jffs2_destroy_inode(struct i
 	kmem_cache_free(jffs2_inode_cachep, JFFS2_INODE_INFO(inode));
 }
 
-static void jffs2_i_init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void jffs2_i_init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct jffs2_inode_info *ei = (struct jffs2_inode_info *) foo;
 
Index: linux-2.6/fs/jfs/jfs_metapage.c
===================================================================
--- linux-2.6.orig/fs/jfs/jfs_metapage.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/jfs/jfs_metapage.c	2007-09-14 13:54:51.000000000 -0700
@@ -180,7 +180,7 @@ static inline void remove_metapage(struc
 
 #endif
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct metapage *mp = (struct metapage *)foo;
 
Index: linux-2.6/fs/jfs/super.c
===================================================================
--- linux-2.6.orig/fs/jfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/jfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -750,7 +750,7 @@ static struct file_system_type jfs_fs_ty
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct jfs_inode_info *jfs_ip = (struct jfs_inode_info *) foo;
 
Index: linux-2.6/fs/locks.c
===================================================================
--- linux-2.6.orig/fs/locks.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/locks.c	2007-09-14 13:54:51.000000000 -0700
@@ -199,7 +199,7 @@ EXPORT_SYMBOL(locks_init_lock);
  * Initialises the fields of the file lock which are invariant for
  * free file_locks.
  */
-static void init_once(void *foo, struct kmem_cache *cache, unsigned long flags)
+static void init_once(struct kmem_cache *cache, void *foo)
 {
 	struct file_lock *lock = (struct file_lock *) foo;
 
Index: linux-2.6/fs/minix/inode.c
===================================================================
--- linux-2.6.orig/fs/minix/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/minix/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -69,7 +69,7 @@ static void minix_destroy_inode(struct i
 	kmem_cache_free(minix_inode_cachep, minix_i(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct minix_inode_info *ei = (struct minix_inode_info *) foo;
 
Index: linux-2.6/fs/ncpfs/inode.c
===================================================================
--- linux-2.6.orig/fs/ncpfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ncpfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -56,7 +56,7 @@ static void ncp_destroy_inode(struct ino
 	kmem_cache_free(ncp_inode_cachep, NCP_FINFO(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct ncp_inode_info *ei = (struct ncp_inode_info *) foo;
 
Index: linux-2.6/fs/nfs/inode.c
===================================================================
--- linux-2.6.orig/fs/nfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/nfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -1143,7 +1143,7 @@ static inline void nfs4_init_once(struct
 #endif
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct nfs_inode *nfsi = (struct nfs_inode *) foo;
 
Index: linux-2.6/fs/ntfs/super.c
===================================================================
--- linux-2.6.orig/fs/ntfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ntfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -3080,8 +3080,7 @@ struct kmem_cache *ntfs_inode_cache;
 struct kmem_cache *ntfs_big_inode_cache;
 
 /* Init once constructor for the inode slab cache. */
-static void ntfs_big_inode_init_once(void *foo, struct kmem_cache *cachep,
-		unsigned long flags)
+static void ntfs_big_inode_init_once(struct kmem_cache *cachep, void *foo)
 {
 	ntfs_inode *ni = (ntfs_inode *)foo;
 
Index: linux-2.6/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/dlm/dlmfs.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ocfs2/dlm/dlmfs.c	2007-09-14 13:54:51.000000000 -0700
@@ -255,9 +255,8 @@ static ssize_t dlmfs_file_write(struct f
 	return writelen;
 }
 
-static void dlmfs_init_once(void *foo,
-			    struct kmem_cache *cachep,
-			    unsigned long flags)
+static void dlmfs_init_once(struct kmem_cache *cachep,
+			    void *foo)
 {
 	struct dlmfs_inode_private *ip =
 		(struct dlmfs_inode_private *) foo;
Index: linux-2.6/fs/ocfs2/super.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ocfs2/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -963,9 +963,7 @@ bail:
 	return status;
 }
 
-static void ocfs2_inode_init_once(void *data,
-				  struct kmem_cache *cachep,
-				  unsigned long flags)
+static void ocfs2_inode_init_once(struct kmem_cache *cachep, void *data)
 {
 	struct ocfs2_inode_info *oi = data;
 
Index: linux-2.6/fs/openpromfs/inode.c
===================================================================
--- linux-2.6.orig/fs/openpromfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/openpromfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -415,7 +415,7 @@ static struct file_system_type openprom_
 	.kill_sb	= kill_anon_super,
 };
 
-static void op_inode_init_once(void *data, struct kmem_cache * cachep, unsigned long flags)
+static void op_inode_init_once(struct kmem_cache * cachep, void *data)
 {
 	struct op_inode_info *oi = (struct op_inode_info *) data;
 
Index: linux-2.6/fs/proc/inode.c
===================================================================
--- linux-2.6.orig/fs/proc/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/proc/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -107,7 +107,7 @@ static void proc_destroy_inode(struct in
 	kmem_cache_free(proc_inode_cachep, PROC_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct proc_inode *ei = (struct proc_inode *) foo;
 
Index: linux-2.6/fs/qnx4/inode.c
===================================================================
--- linux-2.6.orig/fs/qnx4/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/qnx4/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -531,8 +531,7 @@ static void qnx4_destroy_inode(struct in
 	kmem_cache_free(qnx4_inode_cachep, qnx4_i(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep,
-		      unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct qnx4_inode_info *ei = (struct qnx4_inode_info *) foo;
 
Index: linux-2.6/fs/reiserfs/super.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/reiserfs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -508,7 +508,7 @@ static void reiserfs_destroy_inode(struc
 	kmem_cache_free(reiserfs_inode_cachep, REISERFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct reiserfs_inode_info *ei = (struct reiserfs_inode_info *)foo;
 
Index: linux-2.6/fs/romfs/inode.c
===================================================================
--- linux-2.6.orig/fs/romfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/romfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -566,7 +566,7 @@ static void romfs_destroy_inode(struct i
 	kmem_cache_free(romfs_inode_cachep, ROMFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct romfs_inode_info *ei = foo;
 
Index: linux-2.6/fs/smbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/smbfs/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/smbfs/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -67,7 +67,7 @@ static void smb_destroy_inode(struct ino
 	kmem_cache_free(smb_inode_cachep, SMB_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct smb_inode_info *ei = (struct smb_inode_info *) foo;
 
Index: linux-2.6/fs/sysv/inode.c
===================================================================
--- linux-2.6.orig/fs/sysv/inode.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/sysv/inode.c	2007-09-14 13:54:51.000000000 -0700
@@ -318,7 +318,7 @@ static void sysv_destroy_inode(struct in
 	kmem_cache_free(sysv_inode_cachep, SYSV_I(inode));
 }
 
-static void init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *p)
 {
 	struct sysv_inode_info *si = (struct sysv_inode_info *)p;
 
Index: linux-2.6/fs/udf/super.c
===================================================================
--- linux-2.6.orig/fs/udf/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/udf/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -134,7 +134,7 @@ static void udf_destroy_inode(struct ino
 	kmem_cache_free(udf_inode_cachep, UDF_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct udf_inode_info *ei = (struct udf_inode_info *)foo;
 
Index: linux-2.6/fs/ufs/super.c
===================================================================
--- linux-2.6.orig/fs/ufs/super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/ufs/super.c	2007-09-14 13:54:51.000000000 -0700
@@ -1234,7 +1234,7 @@ static void ufs_destroy_inode(struct ino
 	kmem_cache_free(ufs_inode_cachep, UFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ufs_inode_info *ei = (struct ufs_inode_info *) foo;
 
Index: linux-2.6/fs/xfs/linux-2.6/kmem.h
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/kmem.h	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/xfs/linux-2.6/kmem.h	2007-09-14 13:54:51.000000000 -0700
@@ -79,7 +79,7 @@ kmem_zone_init(int size, char *zone_name
 
 static inline kmem_zone_t *
 kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
-		     void (*construct)(void *, kmem_zone_t *, unsigned long))
+		     void (*construct)(kmem_zone_t *, void *))
 {
 	return kmem_cache_create(zone_name, size, 0, flags, construct);
 }
Index: linux-2.6/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_super.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/fs/xfs/linux-2.6/xfs_super.c	2007-09-14 13:54:51.000000000 -0700
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
Index: linux-2.6/include/asm-i386/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-i386/pgtable.h	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/include/asm-i386/pgtable.h	2007-09-14 13:54:51.000000000 -0700
@@ -40,7 +40,7 @@ extern spinlock_t pgd_lock;
 extern struct page *pgd_list;
 void check_pgt_cache(void);
 
-void pmd_ctor(void *, struct kmem_cache *, unsigned long);
+void pmd_ctor(struct kmem_cache *, void *);
 void pgtable_cache_init(void);
 void paging_init(void);
 
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/include/linux/slab.h	2007-09-14 13:54:51.000000000 -0700
@@ -51,7 +51,7 @@ int slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
-			void (*)(void *, struct kmem_cache *, unsigned long));
+			void (*)(struct kmem_cache *, void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/include/linux/slub_def.h	2007-09-14 13:54:51.000000000 -0700
@@ -49,7 +49,7 @@ struct kmem_cache {
 	/* Allocation and freeing of slabs */
 	int objects;		/* Number of objects in slab */
 	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	void (*ctor)(struct kmem_cache *, void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */
Index: linux-2.6/ipc/mqueue.c
===================================================================
--- linux-2.6.orig/ipc/mqueue.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/ipc/mqueue.c	2007-09-14 13:54:51.000000000 -0700
@@ -211,7 +211,7 @@ static int mqueue_get_sb(struct file_sys
 	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct mqueue_inode_info *p = (struct mqueue_inode_info *) foo;
 
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/kernel/fork.c	2007-09-14 13:54:51.000000000 -0700
@@ -1432,8 +1432,7 @@ long do_fork(unsigned long clone_flags,
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
 
-static void sighand_ctor(void *data, struct kmem_cache *cachep,
-			unsigned long flags)
+static void sighand_ctor(struct kmem_cache *cachep, void *data)
 {
 	struct sighand_struct *sighand = data;
 
Index: linux-2.6/lib/idr.c
===================================================================
--- linux-2.6.orig/lib/idr.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/lib/idr.c	2007-09-14 13:54:51.000000000 -0700
@@ -580,8 +580,7 @@ void *idr_replace(struct idr *idp, void 
 }
 EXPORT_SYMBOL(idr_replace);
 
-static void idr_cache_ctor(void * idr_layer, struct kmem_cache *idr_layer_cache,
-		unsigned long flags)
+static void idr_cache_ctor(struct kmem_cache *idr_layer_cache, void *idr_layer)
 {
 	memset(idr_layer, 0, sizeof(struct idr_layer));
 }
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/lib/radix-tree.c	2007-09-14 13:54:51.000000000 -0700
@@ -974,7 +974,7 @@ int radix_tree_tagged(struct radix_tree_
 EXPORT_SYMBOL(radix_tree_tagged);
 
 static void
-radix_tree_node_ctor(void *node, struct kmem_cache *cachep, unsigned long flags)
+radix_tree_node_ctor(struct kmem_cache *cachep, void *node)
 {
 	memset(node, 0, sizeof(struct radix_tree_node));
 }
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/mm/rmap.c	2007-09-14 13:54:51.000000000 -0700
@@ -137,8 +137,7 @@ void anon_vma_unlink(struct vm_area_stru
 		anon_vma_free(anon_vma);
 }
 
-static void anon_vma_ctor(void *data, struct kmem_cache *cachep,
-			  unsigned long flags)
+static void anon_vma_ctor(struct kmem_cache *cachep, void *data)
 {
 	struct anon_vma *anon_vma = data;
 
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/mm/shmem.c	2007-09-14 13:54:51.000000000 -0700
@@ -2306,8 +2306,7 @@ static void shmem_destroy_inode(struct i
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep,
-		      unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/mm/slab.c	2007-09-14 13:54:51.000000000 -0700
@@ -408,7 +408,7 @@ struct kmem_cache {
 	unsigned int dflags;		/* dynamic flags */
 
 	/* constructor func */
-	void (*ctor) (void *, struct kmem_cache *, unsigned long);
+	void (*ctor)(struct kmem_cache *, void *);
 
 /* 5) cache creation/removal */
 	const char *name;
@@ -2127,7 +2127,7 @@ static int __init_refok setup_cpu_cache(
 struct kmem_cache *
 kmem_cache_create (const char *name, size_t size, size_t align,
 	unsigned long flags,
-	void (*ctor)(void*, struct kmem_cache *, unsigned long))
+	void (*ctor)(struct kmem_cache *, void *))
 {
 	size_t left_over, slab_size, ralign;
 	struct kmem_cache *cachep = NULL, *pc;
@@ -2634,8 +2634,7 @@ static void cache_init_objs(struct kmem_
 		 * They must also be threaded.
 		 */
 		if (cachep->ctor && !(cachep->flags & SLAB_POISON))
-			cachep->ctor(objp + obj_offset(cachep), cachep,
-				     0);
+			cachep->ctor(cachep, objp + obj_offset(cachep));
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
@@ -2651,7 +2650,7 @@ static void cache_init_objs(struct kmem_
 					 cachep->buffer_size / PAGE_SIZE, 0);
 #else
 		if (cachep->ctor)
-			cachep->ctor(objp, cachep, 0);
+			cachep->ctor(cachep, objp);
 #endif
 		slab_bufctl(slabp)[i] = i + 1;
 	}
@@ -3076,7 +3075,7 @@ static void *cache_alloc_debugcheck_afte
 #endif
 	objp += obj_offset(cachep);
 	if (cachep->ctor && cachep->flags & SLAB_POISON)
-		cachep->ctor(objp, cachep, 0);
+		cachep->ctor(cachep, objp);
 #if ARCH_SLAB_MINALIGN
 	if ((u32)objp & (ARCH_SLAB_MINALIGN-1)) {
 		printk(KERN_ERR "0x%p: not aligned to ARCH_SLAB_MINALIGN=%d\n",
Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/mm/slob.c	2007-09-14 13:54:51.000000000 -0700
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
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-09-14 13:54:47.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-09-14 13:54:51.000000000 -0700
@@ -980,7 +980,7 @@ __setup("slub_debug", setup_slub_debug);
 
 static unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
-	void (*ctor)(void *, struct kmem_cache *, unsigned long))
+	void (*ctor)(struct kmem_cache *, void *))
 {
 	/*
 	 * Enable debugging if selected on the kernel commandline.
@@ -1049,7 +1049,7 @@ static void setup_object(struct kmem_cac
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
-		s->ctor(object, s, 0);
+		s->ctor(s, object);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -2189,7 +2189,7 @@ static int calculate_sizes(struct kmem_c
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	memset(s, 0, kmem_size);
 	s->name = name;
@@ -2779,7 +2779,7 @@ static int slab_unmergeable(struct kmem_
 
 static struct kmem_cache *find_mergeable(size_t size,
 		size_t align, unsigned long flags, const char *name,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	struct kmem_cache *s;
 
@@ -2820,7 +2820,7 @@ static struct kmem_cache *find_mergeable
 
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(void *, struct kmem_cache *, unsigned long))
+		void (*ctor)(struct kmem_cache *, void *))
 {
 	struct kmem_cache *s;
 
Index: linux-2.6/net/socket.c
===================================================================
--- linux-2.6.orig/net/socket.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/net/socket.c	2007-09-14 13:54:51.000000000 -0700
@@ -257,7 +257,7 @@ static void sock_destroy_inode(struct in
 			container_of(inode, struct socket_alloc, vfs_inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct socket_alloc *ei = (struct socket_alloc *)foo;
 
Index: linux-2.6/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.orig/net/sunrpc/rpc_pipe.c	2007-09-14 13:54:45.000000000 -0700
+++ linux-2.6/net/sunrpc/rpc_pipe.c	2007-09-14 13:54:51.000000000 -0700
@@ -840,7 +840,7 @@ static struct file_system_type rpc_pipe_
 };
 
 static void
-init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct rpc_inode *rpci = (struct rpc_inode *) foo;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
