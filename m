Received: by fg-out-1718.google.com with SMTP id 19so1195670fgg.4
        for <linux-mm@kvack.org>; Wed, 09 Jul 2008 18:14:26 -0700 (PDT)
Date: Thu, 10 Jul 2008 05:11:32 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: SL*B: drop kmem cache argument from constructor
Message-ID: <20080710011132.GA8327@martell.zuzino.mipt.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Kmem cache passed to constructor is only needed for constructors that are
themselves multiplexeres. Nobody uses this "feature", nor does anybody uses
passed kmem cache in non-trivial way, so pass only pointer to object.

Non-trivial places are:
	arch/powerpc/mm/init_64.c
	arch/powerpc/mm/hugetlbpage.c

This is flag day, yes.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/arm/plat-s3c24xx/dma.c               |    2 +-
 arch/powerpc/kernel/rtas_flash.c          |    2 +-
 arch/powerpc/mm/hugetlbpage.c             |    4 ++--
 arch/powerpc/mm/init_64.c                 |   24 +++++++++---------------
 arch/powerpc/platforms/cell/spufs/inode.c |    2 +-
 arch/sh/mm/pmb.c                          |    2 +-
 arch/xtensa/mm/init.c                     |    2 +-
 drivers/usb/mon/mon_text.c                |    4 ++--
 fs/adfs/super.c                           |    2 +-
 fs/affs/super.c                           |    2 +-
 fs/afs/super.c                            |    4 ++--
 fs/befs/linuxvfs.c                        |    2 +-
 fs/bfs/inode.c                            |    2 +-
 fs/block_dev.c                            |    2 +-
 fs/buffer.c                               |    2 +-
 fs/cifs/cifsfs.c                          |    2 +-
 fs/coda/inode.c                           |    2 +-
 fs/ecryptfs/main.c                        |    4 ++--
 fs/efs/super.c                            |    2 +-
 fs/ext2/super.c                           |    2 +-
 fs/ext3/super.c                           |    2 +-
 fs/ext4/super.c                           |    2 +-
 fs/fat/cache.c                            |    2 +-
 fs/fat/inode.c                            |    2 +-
 fs/fuse/inode.c                           |    2 +-
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
 fs/ntfs/super.c                           |    2 +-
 fs/ocfs2/dlm/dlmfs.c                      |    3 +--
 fs/ocfs2/super.c                          |    2 +-
 fs/openpromfs/inode.c                     |    2 +-
 fs/proc/inode.c                           |    2 +-
 fs/qnx4/inode.c                           |    2 +-
 fs/reiserfs/super.c                       |    2 +-
 fs/romfs/inode.c                          |    2 +-
 fs/smbfs/inode.c                          |    2 +-
 fs/sysv/inode.c                           |    2 +-
 fs/udf/super.c                            |    2 +-
 fs/ufs/super.c                            |    2 +-
 fs/xfs/linux-2.6/kmem.h                   |    2 +-
 fs/xfs/linux-2.6/xfs_super.c              |    1 -
 include/linux/slab.h                      |    2 +-
 include/linux/slub_def.h                  |    2 +-
 ipc/mqueue.c                              |    2 +-
 kernel/fork.c                             |    2 +-
 lib/idr.c                                 |    2 +-
 lib/radix-tree.c                          |    2 +-
 mm/rmap.c                                 |    2 +-
 mm/shmem.c                                |    2 +-
 mm/slab.c                                 |    7 +++----
 mm/slob.c                                 |    7 +++----
 mm/slub.c                                 |   13 ++++++-------
 net/socket.c                              |    2 +-
 net/sunrpc/rpc_pipe.c                     |    2 +-
 66 files changed, 87 insertions(+), 98 deletions(-)

--- a/arch/arm/plat-s3c24xx/dma.c
+++ b/arch/arm/plat-s3c24xx/dma.c
@@ -1304,7 +1304,7 @@ struct sysdev_class dma_sysclass = {
 
 /* kmem cache implementation */
 
-static void s3c2410_dma_cache_ctor(struct kmem_cache *c, void *p)
+static void s3c2410_dma_cache_ctor(void *p)
 {
 	memset(p, 0, sizeof(struct s3c2410_dma_buf));
 }
--- a/arch/powerpc/kernel/rtas_flash.c
+++ b/arch/powerpc/kernel/rtas_flash.c
@@ -286,7 +286,7 @@ static ssize_t rtas_flash_read(struct file *file, char __user *buf,
 }
 
 /* constructor for flash_block_cache */
-void rtas_block_ctor(struct kmem_cache *cache, void *ptr)
+void rtas_block_ctor(void *ptr)
 {
 	memset(ptr, 0, RTAS_BLK_SIZE);
 }
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -595,9 +595,9 @@ static int __init hugepage_setup_sz(char *str)
 }
 __setup("hugepagesz=", hugepage_setup_sz);
 
-static void zero_ctor(struct kmem_cache *cache, void *addr)
+static void zero_ctor(void *addr)
 {
-	memset(addr, 0, kmem_cache_size(cache));
+	memset(addr, 0, HUGEPTE_TABLE_SIZE);
 }
 
 static int __init hugetlbpage_init(void)
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -136,9 +136,14 @@ static int __init setup_kcore(void)
 module_init(setup_kcore);
 #endif
 
-static void zero_ctor(struct kmem_cache *cache, void *addr)
+static void pgd_ctor(void *addr)
 {
-	memset(addr, 0, kmem_cache_size(cache));
+	memset(addr, 0, PGD_TABLE_SIZE);
+}
+
+static void pmd_ctor(void *addr)
+{
+	memset(addr, 0, PMD_TABLE_SIZE);
 }
 
 static const unsigned int pgtable_cache_size[2] = {
@@ -163,19 +168,8 @@ struct kmem_cache *pgtable_cache[ARRAY_SIZE(pgtable_cache_size)];
 
 void pgtable_cache_init(void)
 {
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(pgtable_cache_size); i++) {
-		int size = pgtable_cache_size[i];
-		const char *name = pgtable_cache_name[i];
-
-		pr_debug("Allocating page table cache %s (#%d) "
-			"for size: %08x...\n", name, i, size);
-		pgtable_cache[i] = kmem_cache_create(name,
-						     size, size,
-						     SLAB_PANIC,
-						     zero_ctor);
-	}
+	pgtable_cache[0] = kmem_cache_create(pgtable_cache_name[0], PGD_TABLE_SIZE, PGD_TABLE_SIZE, SLAB_PANIC, pgd_ctor);
+	pgtable_cache[1] = kmem_cache_create(pgtable_cache_name[1], PMD_TABLE_SIZE, PMD_TABLE_SIZE, SLAB_PANIC, pmd_ctor);
 }
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -69,7 +69,7 @@ spufs_destroy_inode(struct inode *inode)
 }
 
 static void
-spufs_init_once(struct kmem_cache *cachep, void *p)
+spufs_init_once(void *p)
 {
 	struct spufs_inode_info *ei = p;
 
--- a/arch/sh/mm/pmb.c
+++ b/arch/sh/mm/pmb.c
@@ -293,7 +293,7 @@ void pmb_unmap(unsigned long addr)
 	} while (pmbe);
 }
 
-static void pmb_cache_ctor(struct kmem_cache *cachep, void *pmb)
+static void pmb_cache_ctor(void *pmb)
 {
 	struct pmb_entry *pmbe = pmb;
 
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -309,7 +309,7 @@ void show_mem(void)
 
 struct kmem_cache *pgtable_cache __read_mostly;
 
-static void pgd_ctor(struct kmem_cache *cache, void* addr)
+static void pgd_ctor(void* addr)
 {
 	pte_t* ptep = (pte_t*)addr;
 	int i;
--- a/drivers/usb/mon/mon_text.c
+++ b/drivers/usb/mon/mon_text.c
@@ -87,7 +87,7 @@ struct mon_reader_text {
 
 static struct dentry *mon_dir;		/* Usually /sys/kernel/debug/usbmon */
 
-static void mon_text_ctor(struct kmem_cache *, void *);
+static void mon_text_ctor(void *);
 
 struct mon_text_ptr {
 	int cnt, limit;
@@ -720,7 +720,7 @@ void mon_text_del(struct mon_bus *mbus)
 /*
  * Slab interface: constructor.
  */
-static void mon_text_ctor(struct kmem_cache *slab, void *mem)
+static void mon_text_ctor(void *mem)
 {
 	/*
 	 * Nothing to initialize. No, really!
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -249,7 +249,7 @@ static void adfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(adfs_inode_cachep, ADFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct adfs_inode_info *ei = (struct adfs_inode_info *) foo;
 
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -90,7 +90,7 @@ static void affs_destroy_inode(struct inode *inode)
 	kmem_cache_free(affs_inode_cachep, AFFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct affs_inode_info *ei = (struct affs_inode_info *) foo;
 
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -27,7 +27,7 @@
 
 #define AFS_FS_MAGIC 0x6B414653 /* 'kAFS' */
 
-static void afs_i_init_once(struct kmem_cache *cachep, void *foo);
+static void afs_i_init_once(void *foo);
 static int afs_get_sb(struct file_system_type *fs_type,
 		      int flags, const char *dev_name,
 		      void *data, struct vfsmount *mnt);
@@ -449,7 +449,7 @@ static void afs_put_super(struct super_block *sb)
 /*
  * initialise an inode cache slab element prior to any use
  */
-static void afs_i_init_once(struct kmem_cache *cachep, void *_vnode)
+static void afs_i_init_once(void *_vnode)
 {
 	struct afs_vnode *vnode = _vnode;
 
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -289,7 +289,7 @@ befs_destroy_inode(struct inode *inode)
         kmem_cache_free(befs_inode_cachep, BEFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
         struct befs_inode_info *bi = (struct befs_inode_info *) foo;
 
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -259,7 +259,7 @@ static void bfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(bfs_inode_cachep, BFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct bfs_inode_info *bi = foo;
 
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -271,7 +271,7 @@ static void bdev_destroy_inode(struct inode *inode)
 	kmem_cache_free(bdev_cachep, bdi);
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct bdev_inode *ei = (struct bdev_inode *) foo;
 	struct block_device *bdev = &ei->bdev;
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3259,7 +3259,7 @@ int bh_submit_read(struct buffer_head *bh)
 EXPORT_SYMBOL(bh_submit_read);
 
 static void
-init_buffer_head(struct kmem_cache *cachep, void *data)
+init_buffer_head(void *data)
 {
 	struct buffer_head *bh = data;
 
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -766,7 +766,7 @@ const struct file_operations cifs_dir_ops = {
 };
 
 static void
-cifs_init_once(struct kmem_cache *cachep, void *inode)
+cifs_init_once(void *inode)
 {
 	struct cifsInodeInfo *cifsi = inode;
 
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -58,7 +58,7 @@ static void coda_destroy_inode(struct inode *inode)
 	kmem_cache_free(coda_inode_cachep, ITOC(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct coda_inode_info *ei = (struct coda_inode_info *) foo;
 
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -605,7 +605,7 @@ static struct file_system_type ecryptfs_fs_type = {
  * Initializes the ecryptfs_inode_info_cache when it is created
  */
 static void
-inode_info_init_once(struct kmem_cache *cachep, void *vptr)
+inode_info_init_once(void *vptr)
 {
 	struct ecryptfs_inode_info *ei = (struct ecryptfs_inode_info *)vptr;
 
@@ -616,7 +616,7 @@ static struct ecryptfs_cache_info {
 	struct kmem_cache **cache;
 	const char *name;
 	size_t size;
-	void (*ctor)(struct kmem_cache *cache, void *obj);
+	void (*ctor)(void *obj);
 } ecryptfs_cache_infos[] = {
 	{
 		.cache = &ecryptfs_auth_tok_list_item_cache,
--- a/fs/efs/super.c
+++ b/fs/efs/super.c
@@ -70,7 +70,7 @@ static void efs_destroy_inode(struct inode *inode)
 	kmem_cache_free(efs_inode_cachep, INODE_INFO(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct efs_inode_info *ei = (struct efs_inode_info *) foo;
 
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -158,7 +158,7 @@ static void ext2_destroy_inode(struct inode *inode)
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct ext2_inode_info *ei = (struct ext2_inode_info *) foo;
 
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -472,7 +472,7 @@ static void ext3_destroy_inode(struct inode *inode)
 	kmem_cache_free(ext3_inode_cachep, EXT3_I(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct ext3_inode_info *ei = (struct ext3_inode_info *) foo;
 
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -587,7 +587,7 @@ static void ext4_destroy_inode(struct inode *inode)
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct ext4_inode_info *ei = (struct ext4_inode_info *) foo;
 
--- a/fs/fat/cache.c
+++ b/fs/fat/cache.c
@@ -36,7 +36,7 @@ static inline int fat_max_cache(struct inode *inode)
 
 static struct kmem_cache *fat_cache_cachep;
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct fat_cache *cache = (struct fat_cache *)foo;
 
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -496,7 +496,7 @@ static void fat_destroy_inode(struct inode *inode)
 	kmem_cache_free(fat_inode_cachep, MSDOS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct msdos_inode_info *ei = (struct msdos_inode_info *)foo;
 
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -781,7 +781,7 @@ static inline void unregister_fuseblk(void)
 }
 #endif
 
-static void fuse_inode_init_once(struct kmem_cache *cachep, void *foo)
+static void fuse_inode_init_once(void *foo)
 {
 	struct inode * inode = foo;
 
--- a/fs/gfs2/main.c
+++ b/fs/gfs2/main.c
@@ -24,7 +24,7 @@
 #include "util.h"
 #include "glock.h"
 
-static void gfs2_init_inode_once(struct kmem_cache *cachep, void *foo)
+static void gfs2_init_inode_once(void *foo)
 {
 	struct gfs2_inode *ip = foo;
 
@@ -33,7 +33,7 @@ static void gfs2_init_inode_once(struct kmem_cache *cachep, void *foo)
 	ip->i_alloc = NULL;
 }
 
-static void gfs2_init_glock_once(struct kmem_cache *cachep, void *foo)
+static void gfs2_init_glock_once(void *foo)
 {
 	struct gfs2_glock *gl = foo;
 
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -432,7 +432,7 @@ static struct file_system_type hfs_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfs_init_once(struct kmem_cache *cachep, void *p)
+static void hfs_init_once(void *p)
 {
 	struct hfs_inode_info *i = p;
 
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -485,7 +485,7 @@ static struct file_system_type hfsplus_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfsplus_init_once(struct kmem_cache *cachep, void *p)
+static void hfsplus_init_once(void *p)
 {
 	struct hfsplus_inode_info *i = p;
 
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -173,7 +173,7 @@ static void hpfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(hpfs_inode_cachep, hpfs_i(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct hpfs_inode_info *ei = (struct hpfs_inode_info *) foo;
 
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -696,7 +696,7 @@ static const struct address_space_operations hugetlbfs_aops = {
 };
 
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
 
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -224,7 +224,7 @@ void inode_init_once(struct inode *inode)
 
 EXPORT_SYMBOL(inode_init_once);
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct inode * inode = (struct inode *) foo;
 
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -73,7 +73,7 @@ static void isofs_destroy_inode(struct inode *inode)
 	kmem_cache_free(isofs_inode_cachep, ISOFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct iso_inode_info *ei = foo;
 
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -44,7 +44,7 @@ static void jffs2_destroy_inode(struct inode *inode)
 	kmem_cache_free(jffs2_inode_cachep, JFFS2_INODE_INFO(inode));
 }
 
-static void jffs2_i_init_once(struct kmem_cache *cachep, void *foo)
+static void jffs2_i_init_once(void *foo)
 {
 	struct jffs2_inode_info *f = foo;
 
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -180,7 +180,7 @@ static inline void remove_metapage(struct page *page, struct metapage *mp)
 
 #endif
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct metapage *mp = (struct metapage *)foo;
 
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -760,7 +760,7 @@ static struct file_system_type jfs_fs_type = {
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct jfs_inode_info *jfs_ip = (struct jfs_inode_info *) foo;
 
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -201,7 +201,7 @@ EXPORT_SYMBOL(locks_init_lock);
  * Initialises the fields of the file lock which are invariant for
  * free file_locks.
  */
-static void init_once(struct kmem_cache *cache, void *foo)
+static void init_once(void *foo)
 {
 	struct file_lock *lock = (struct file_lock *) foo;
 
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -68,7 +68,7 @@ static void minix_destroy_inode(struct inode *inode)
 	kmem_cache_free(minix_inode_cachep, minix_i(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct minix_inode_info *ei = (struct minix_inode_info *) foo;
 
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -64,7 +64,7 @@ static void ncp_destroy_inode(struct inode *inode)
 	kmem_cache_free(ncp_inode_cachep, NCP_FINFO(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct ncp_inode_info *ei = (struct ncp_inode_info *) foo;
 
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1193,7 +1193,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 #endif
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct nfs_inode *nfsi = (struct nfs_inode *) foo;
 
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -3080,7 +3080,7 @@ struct kmem_cache *ntfs_inode_cache;
 struct kmem_cache *ntfs_big_inode_cache;
 
 /* Init once constructor for the inode slab cache. */
-static void ntfs_big_inode_init_once(struct kmem_cache *cachep, void *foo)
+static void ntfs_big_inode_init_once(void *foo)
 {
 	ntfs_inode *ni = (ntfs_inode *)foo;
 
--- a/fs/ocfs2/dlm/dlmfs.c
+++ b/fs/ocfs2/dlm/dlmfs.c
@@ -267,8 +267,7 @@ static ssize_t dlmfs_file_write(struct file *filp,
 	return writelen;
 }
 
-static void dlmfs_init_once(struct kmem_cache *cachep,
-			    void *foo)
+static void dlmfs_init_once(void *foo)
 {
 	struct dlmfs_inode_private *ip =
 		(struct dlmfs_inode_private *) foo;
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -1118,7 +1118,7 @@ bail:
 	return status;
 }
 
-static void ocfs2_inode_init_once(struct kmem_cache *cachep, void *data)
+static void ocfs2_inode_init_once(void *data)
 {
 	struct ocfs2_inode_info *oi = data;
 
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -430,7 +430,7 @@ static struct file_system_type openprom_fs_type = {
 	.kill_sb	= kill_anon_super,
 };
 
-static void op_inode_init_once(struct kmem_cache * cachep, void *data)
+static void op_inode_init_once(void *data)
 {
 	struct op_inode_info *oi = (struct op_inode_info *) data;
 
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -94,7 +94,7 @@ static void proc_destroy_inode(struct inode *inode)
 	kmem_cache_free(proc_inode_cachep, PROC_I(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct proc_inode *ei = (struct proc_inode *) foo;
 
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -553,7 +553,7 @@ static void qnx4_destroy_inode(struct inode *inode)
 	kmem_cache_free(qnx4_inode_cachep, qnx4_i(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct qnx4_inode_info *ei = (struct qnx4_inode_info *) foo;
 
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -520,7 +520,7 @@ static void reiserfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(reiserfs_inode_cachep, REISERFS_I(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct reiserfs_inode_info *ei = (struct reiserfs_inode_info *)foo;
 
--- a/fs/romfs/inode.c
+++ b/fs/romfs/inode.c
@@ -577,7 +577,7 @@ static void romfs_destroy_inode(struct inode *inode)
 	kmem_cache_free(romfs_inode_cachep, ROMFS_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct romfs_inode_info *ei = foo;
 
--- a/fs/smbfs/inode.c
+++ b/fs/smbfs/inode.c
@@ -67,7 +67,7 @@ static void smb_destroy_inode(struct inode *inode)
 	kmem_cache_free(smb_inode_cachep, SMB_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct smb_inode_info *ei = (struct smb_inode_info *) foo;
 
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -326,7 +326,7 @@ static void sysv_destroy_inode(struct inode *inode)
 	kmem_cache_free(sysv_inode_cachep, SYSV_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *p)
+static void init_once(void *p)
 {
 	struct sysv_inode_info *si = (struct sysv_inode_info *)p;
 
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -148,7 +148,7 @@ static void udf_destroy_inode(struct inode *inode)
 	kmem_cache_free(udf_inode_cachep, UDF_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct udf_inode_info *ei = (struct udf_inode_info *)foo;
 
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1301,7 +1301,7 @@ static void ufs_destroy_inode(struct inode *inode)
 	kmem_cache_free(ufs_inode_cachep, UFS_I(inode));
 }
 
-static void init_once(struct kmem_cache * cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct ufs_inode_info *ei = (struct ufs_inode_info *) foo;
 
--- a/fs/xfs/linux-2.6/kmem.h
+++ b/fs/xfs/linux-2.6/kmem.h
@@ -79,7 +79,7 @@ kmem_zone_init(int size, char *zone_name)
 
 static inline kmem_zone_t *
 kmem_zone_init_flags(int size, char *zone_name, unsigned long flags,
-		     void (*construct)(kmem_zone_t *, void *))
+		     void (*construct)(void *))
 {
 	return kmem_cache_create(zone_name, size, 0, flags, construct);
 }
--- a/fs/xfs/linux-2.6/xfs_super.c
+++ b/fs/xfs/linux-2.6/xfs_super.c
@@ -843,7 +843,6 @@ xfs_fs_destroy_inode(
 
 STATIC void
 xfs_fs_inode_init_once(
-	kmem_zone_t		*zonep,
 	void			*vnode)
 {
 	inode_init_once(vn_to_inode((bhv_vnode_t *)vnode));
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -58,7 +58,7 @@ int slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
-			void (*)(struct kmem_cache *, void *));
+			void (*)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -85,7 +85,7 @@ struct kmem_cache {
 	struct kmem_cache_order_objects min;
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
-	void (*ctor)(struct kmem_cache *, void *);
+	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	const char *name;	/* Name (only for display!) */
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -207,7 +207,7 @@ static int mqueue_get_sb(struct file_system_type *fs_type,
 	return get_sb_single(fs_type, flags, data, mqueue_fill_super, mnt);
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct mqueue_inode_info *p = (struct mqueue_inode_info *) foo;
 
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1403,7 +1403,7 @@ long do_fork(unsigned long clone_flags,
 #define ARCH_MIN_MMSTRUCT_ALIGN 0
 #endif
 
-static void sighand_ctor(struct kmem_cache *cachep, void *data)
+static void sighand_ctor(void *data)
 {
 	struct sighand_struct *sighand = data;
 
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -580,7 +580,7 @@ void *idr_replace(struct idr *idp, void *ptr, int id)
 }
 EXPORT_SYMBOL(idr_replace);
 
-static void idr_cache_ctor(struct kmem_cache *idr_layer_cache, void *idr_layer)
+static void idr_cache_ctor(void *idr_layer)
 {
 	memset(idr_layer, 0, sizeof(struct idr_layer));
 }
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1051,7 +1051,7 @@ int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag)
 EXPORT_SYMBOL(radix_tree_tagged);
 
 static void
-radix_tree_node_ctor(struct kmem_cache *cachep, void *node)
+radix_tree_node_ctor(void *node)
 {
 	memset(node, 0, sizeof(struct radix_tree_node));
 }
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -138,7 +138,7 @@ void anon_vma_unlink(struct vm_area_struct *vma)
 		anon_vma_free(anon_vma);
 }
 
-static void anon_vma_ctor(struct kmem_cache *cachep, void *data)
+static void anon_vma_ctor(void *data)
 {
 	struct anon_vma *anon_vma = data;
 
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2330,7 +2330,7 @@ static void shmem_destroy_inode(struct inode *inode)
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
 
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -406,7 +406,7 @@ struct kmem_cache {
 	unsigned int dflags;		/* dynamic flags */
 
 	/* constructor func */
-	void (*ctor)(struct kmem_cache *, void *);
+	void (*ctor)(void *);
 
 /* 5) cache creation/removal */
 	const char *name;
@@ -2145,8 +2145,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep)
  */
 struct kmem_cache *
 kmem_cache_create (const char *name, size_t size, size_t align,
-	unsigned long flags,
-	void (*ctor)(struct kmem_cache *, void *))
+	unsigned long flags, void (*ctor)(void *))
 {
 	size_t left_over, slab_size, ralign;
 	struct kmem_cache *cachep = NULL, *pc;
@@ -2677,7 +2676,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 					 cachep->buffer_size / PAGE_SIZE, 0);
 #else
 		if (cachep->ctor)
-			cachep->ctor(cachep, objp);
+			cachep->ctor(objp);
 #endif
 		slab_bufctl(slabp)[i] = i + 1;
 	}
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -525,12 +525,11 @@ struct kmem_cache {
 	unsigned int size, align;
 	unsigned long flags;
 	const char *name;
-	void (*ctor)(struct kmem_cache *, void *);
+	void (*ctor)(void *);
 };
 
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
-	size_t align, unsigned long flags,
-	void (*ctor)(struct kmem_cache *, void *))
+	size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *c;
 
@@ -575,7 +574,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 		b = slob_new_page(flags, get_order(c->size), node);
 
 	if (c->ctor)
-		c->ctor(c, b);
+		c->ctor(b);
 
 	return b;
 }
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1045,7 +1045,7 @@ __setup("slub_debug", setup_slub_debug);
 
 static unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
-	void (*ctor)(struct kmem_cache *, void *))
+	void (*ctor)(void *))
 {
 	/*
 	 * Enable debugging if selected on the kernel commandline.
@@ -1073,7 +1073,7 @@ static inline int check_object(struct kmem_cache *s, struct page *page,
 static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
-	void (*ctor)(struct kmem_cache *, void *))
+	void (*ctor)(void *))
 {
 	return flags;
 }
@@ -1136,7 +1136,7 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
-		s->ctor(s, object);
+		s->ctor(object);
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -2324,7 +2324,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
-		void (*ctor)(struct kmem_cache *, void *))
+		void (*ctor)(void *))
 {
 	memset(s, 0, kmem_size);
 	s->name = name;
@@ -3079,7 +3079,7 @@ static int slab_unmergeable(struct kmem_cache *s)
 
 static struct kmem_cache *find_mergeable(size_t size,
 		size_t align, unsigned long flags, const char *name,
-		void (*ctor)(struct kmem_cache *, void *))
+		void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
@@ -3119,8 +3119,7 @@ static struct kmem_cache *find_mergeable(size_t size,
 }
 
 struct kmem_cache *kmem_cache_create(const char *name, size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(struct kmem_cache *, void *))
+		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
--- a/net/socket.c
+++ b/net/socket.c
@@ -262,7 +262,7 @@ static void sock_destroy_inode(struct inode *inode)
 			container_of(inode, struct socket_alloc, vfs_inode));
 }
 
-static void init_once(struct kmem_cache *cachep, void *foo)
+static void init_once(void *foo)
 {
 	struct socket_alloc *ei = (struct socket_alloc *)foo;
 
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -897,7 +897,7 @@ static struct file_system_type rpc_pipe_fs_type = {
 };
 
 static void
-init_once(struct kmem_cache * cachep, void *foo)
+init_once(void *foo)
 {
 	struct rpc_inode *rpci = (struct rpc_inode *) foo;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
