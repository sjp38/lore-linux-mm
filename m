Date: Tue, 24 Jul 2007 00:26:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
In-Reply-To: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0707240025070.3295@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

There are more ctors that are called *init_once*

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 arch/powerpc/platforms/cell/spufs/inode.c |    2 +-
 fs/adfs/super.c                           |    2 +-
 fs/affs/super.c                           |    2 +-
 fs/afs/super.c                            |    6 ++----
 fs/befs/linuxvfs.c                        |    2 +-
 fs/bfs/inode.c                            |    2 +-
 fs/coda/inode.c                           |    2 +-
 fs/ecryptfs/main.c                        |    2 +-
 fs/efs/super.c                            |    2 +-
 fs/ext4/super.c                           |    2 +-
 fs/fat/cache.c                            |    2 +-
 fs/fat/inode.c                            |    2 +-
 fs/gfs2/main.c                            |    4 ++--
 fs/hfs/super.c                            |    2 +-
 fs/hfsplus/super.c                        |    2 +-
 fs/hpfs/super.c                           |    2 +-
 fs/hugetlbfs/inode.c                      |    2 +-
 fs/jffs2/super.c                          |    2 +-
 fs/jfs/jfs_metapage.c                     |    2 +-
 fs/jfs/super.c                            |    2 +-
 fs/minix/inode.c                          |    2 +-
 fs/ncpfs/inode.c                          |    2 +-
 fs/ntfs/super.c                           |    3 +--
 fs/ocfs2/dlm/dlmfs.c                      |    5 ++---
 fs/ocfs2/super.c                          |    4 +---
 fs/openpromfs/inode.c                     |    2 +-
 fs/qnx4/inode.c                           |    3 +--
 fs/romfs/inode.c                          |    2 +-
 fs/smbfs/inode.c                          |    2 +-
 fs/sysv/inode.c                           |    2 +-
 fs/ufs/super.c                            |    2 +-
 net/sunrpc/rpc_pipe.c                     |    2 +-
 32 files changed, 35 insertions(+), 42 deletions(-)

Index: linux-2.6.23-rc1/arch/powerpc/platforms/cell/spufs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/arch/powerpc/platforms/cell/spufs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/arch/powerpc/platforms/cell/spufs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -67,7 +67,7 @@ spufs_destroy_inode(struct inode *inode)
 }
 
 static void
-spufs_init_once(void *p, struct kmem_cache * cachep, unsigned long flags)
+spufs_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct spufs_inode_info *ei = p;
 
Index: linux-2.6.23-rc1/fs/adfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/adfs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/adfs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -228,7 +228,7 @@ static void adfs_destroy_inode(struct in
 	kmem_cache_free(adfs_inode_cachep, ADFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct adfs_inode_info *ei = (struct adfs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/affs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/affs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/affs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -84,7 +84,7 @@ static void affs_destroy_inode(struct in
 	kmem_cache_free(affs_inode_cachep, AFFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct affs_inode_info *ei = (struct affs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/afs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/afs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/afs/super.c	2007-07-24 00:10:30.000000000 -0700
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
 
Index: linux-2.6.23-rc1/fs/befs/linuxvfs.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/befs/linuxvfs.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/befs/linuxvfs.c	2007-07-24 00:10:30.000000000 -0700
@@ -289,7 +289,7 @@ befs_destroy_inode(struct inode *inode)
         kmem_cache_free(befs_inode_cachep, BEFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
         struct befs_inode_info *bi = (struct befs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/bfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/bfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/bfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -244,7 +244,7 @@ static void bfs_destroy_inode(struct ino
 	kmem_cache_free(bfs_inode_cachep, BFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct bfs_inode_info *bi = foo;
 
Index: linux-2.6.23-rc1/fs/coda/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/coda/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/coda/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -58,7 +58,7 @@ static void coda_destroy_inode(struct in
 	kmem_cache_free(coda_inode_cachep, ITOC(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct coda_inode_info *ei = (struct coda_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/ecryptfs/main.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ecryptfs/main.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ecryptfs/main.c	2007-07-24 00:10:30.000000000 -0700
@@ -579,7 +579,7 @@ static struct file_system_type ecryptfs_
  * Initializes the ecryptfs_inode_info_cache when it is created
  */
 static void
-inode_info_init_once(void *vptr, struct kmem_cache *cachep, unsigned long flags)
+inode_info_init_once(struct kmem_cache *cachep, void *vptr)
 {
 	struct ecryptfs_inode_info *ei = (struct ecryptfs_inode_info *)vptr;
 
Index: linux-2.6.23-rc1/fs/efs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/efs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/efs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -69,7 +69,7 @@ static void efs_destroy_inode(struct ino
 	kmem_cache_free(efs_inode_cachep, INODE_INFO(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct efs_inode_info *ei = (struct efs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/ext4/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ext4/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ext4/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -523,7 +523,7 @@ static void ext4_destroy_inode(struct in
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct ext4_inode_info *ei = (struct ext4_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/fat/cache.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/fat/cache.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/fat/cache.c	2007-07-24 00:10:30.000000000 -0700
@@ -36,7 +36,7 @@ static inline int fat_max_cache(struct i
 
 static struct kmem_cache *fat_cache_cachep;
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct fat_cache *cache = (struct fat_cache *)foo;
 
Index: linux-2.6.23-rc1/fs/fat/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/fat/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/fat/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -496,7 +496,7 @@ static void fat_destroy_inode(struct ino
 	kmem_cache_free(fat_inode_cachep, MSDOS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct msdos_inode_info *ei = (struct msdos_inode_info *)foo;
 
Index: linux-2.6.23-rc1/fs/gfs2/main.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/gfs2/main.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/gfs2/main.c	2007-07-24 00:10:30.000000000 -0700
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
 
Index: linux-2.6.23-rc1/fs/hfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/hfs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/hfs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -430,7 +430,7 @@ static struct file_system_type hfs_fs_ty
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfs_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void hfs_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct hfs_inode_info *i = p;
 
Index: linux-2.6.23-rc1/fs/hfsplus/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/hfsplus/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/hfsplus/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -466,7 +466,7 @@ static struct file_system_type hfsplus_f
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void hfsplus_init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void hfsplus_init_once(struct kmem_cache *cachep, void *p)
 {
 	struct hfsplus_inode_info *i = p;
 
Index: linux-2.6.23-rc1/fs/hpfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/hpfs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/hpfs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -173,7 +173,7 @@ static void hpfs_destroy_inode(struct in
 	kmem_cache_free(hpfs_inode_cachep, hpfs_i(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct hpfs_inode_info *ei = (struct hpfs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/hugetlbfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/hugetlbfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -570,7 +570,7 @@ static const struct address_space_operat
 };
 
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct hugetlbfs_inode_info *ei = (struct hugetlbfs_inode_info *)foo;
 
Index: linux-2.6.23-rc1/fs/jffs2/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/jffs2/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/jffs2/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -43,7 +43,7 @@ static void jffs2_destroy_inode(struct i
 	kmem_cache_free(jffs2_inode_cachep, JFFS2_INODE_INFO(inode));
 }
 
-static void jffs2_i_init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void jffs2_i_init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct jffs2_inode_info *ei = (struct jffs2_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/jfs/jfs_metapage.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/jfs/jfs_metapage.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/jfs/jfs_metapage.c	2007-07-24 00:10:30.000000000 -0700
@@ -180,7 +180,7 @@ static inline void remove_metapage(struc
 
 #endif
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct metapage *mp = (struct metapage *)foo;
 
Index: linux-2.6.23-rc1/fs/jfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/jfs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/jfs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -750,7 +750,7 @@ static struct file_system_type jfs_fs_ty
 	.fs_flags	= FS_REQUIRES_DEV,
 };
 
-static void init_once(void *foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct jfs_inode_info *jfs_ip = (struct jfs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/minix/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/minix/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/minix/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -69,7 +69,7 @@ static void minix_destroy_inode(struct i
 	kmem_cache_free(minix_inode_cachep, minix_i(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct minix_inode_info *ei = (struct minix_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/ncpfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ncpfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ncpfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -56,7 +56,7 @@ static void ncp_destroy_inode(struct ino
 	kmem_cache_free(ncp_inode_cachep, NCP_FINFO(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct ncp_inode_info *ei = (struct ncp_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/ntfs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ntfs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ntfs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -3080,8 +3080,7 @@ struct kmem_cache *ntfs_inode_cache;
 struct kmem_cache *ntfs_big_inode_cache;
 
 /* Init once constructor for the inode slab cache. */
-static void ntfs_big_inode_init_once(void *foo, struct kmem_cache *cachep,
-		unsigned long flags)
+static void ntfs_big_inode_init_once(struct kmem_cache *cachep, void *foo)
 {
 	ntfs_inode *ni = (ntfs_inode *)foo;
 
Index: linux-2.6.23-rc1/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ocfs2/dlm/dlmfs.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ocfs2/dlm/dlmfs.c	2007-07-24 00:10:30.000000000 -0700
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
Index: linux-2.6.23-rc1/fs/ocfs2/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ocfs2/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ocfs2/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -946,9 +946,7 @@ bail:
 	return status;
 }
 
-static void ocfs2_inode_init_once(void *data,
-				  struct kmem_cache *cachep,
-				  unsigned long flags)
+static void ocfs2_inode_init_once(struct kmem_cache *cachep, void *data)
 {
 	struct ocfs2_inode_info *oi = data;
 
Index: linux-2.6.23-rc1/fs/openpromfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/openpromfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/openpromfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -415,7 +415,7 @@ static struct file_system_type openprom_
 	.kill_sb	= kill_anon_super,
 };
 
-static void op_inode_init_once(void *data, struct kmem_cache * cachep, unsigned long flags)
+static void op_inode_init_once(struct kmem_cache * cachep, void *data)
 {
 	struct op_inode_info *oi = (struct op_inode_info *) data;
 
Index: linux-2.6.23-rc1/fs/qnx4/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/qnx4/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/qnx4/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -531,8 +531,7 @@ static void qnx4_destroy_inode(struct in
 	kmem_cache_free(qnx4_inode_cachep, qnx4_i(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache * cachep,
-		      unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct qnx4_inode_info *ei = (struct qnx4_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/romfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/romfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/romfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -566,7 +566,7 @@ static void romfs_destroy_inode(struct i
 	kmem_cache_free(romfs_inode_cachep, ROMFS_I(inode));
 }
 
-static void init_once(void *foo, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct romfs_inode_info *ei = foo;
 
Index: linux-2.6.23-rc1/fs/smbfs/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/smbfs/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/smbfs/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -67,7 +67,7 @@ static void smb_destroy_inode(struct ino
 	kmem_cache_free(smb_inode_cachep, SMB_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *foo)
 {
 	struct smb_inode_info *ei = (struct smb_inode_info *) foo;
 
Index: linux-2.6.23-rc1/fs/sysv/inode.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/sysv/inode.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/sysv/inode.c	2007-07-24 00:10:30.000000000 -0700
@@ -318,7 +318,7 @@ static void sysv_destroy_inode(struct in
 	kmem_cache_free(sysv_inode_cachep, SYSV_I(inode));
 }
 
-static void init_once(void *p, struct kmem_cache *cachep, unsigned long flags)
+static void init_once(struct kmem_cache *cachep, void *p)
 {
 	struct sysv_inode_info *si = (struct sysv_inode_info *)p;
 
Index: linux-2.6.23-rc1/fs/ufs/super.c
===================================================================
--- linux-2.6.23-rc1.orig/fs/ufs/super.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/fs/ufs/super.c	2007-07-24 00:10:30.000000000 -0700
@@ -1234,7 +1234,7 @@ static void ufs_destroy_inode(struct ino
 	kmem_cache_free(ufs_inode_cachep, UFS_I(inode));
 }
 
-static void init_once(void * foo, struct kmem_cache * cachep, unsigned long flags)
+static void init_once(struct kmem_cache * cachep, void *foo)
 {
 	struct ufs_inode_info *ei = (struct ufs_inode_info *) foo;
 
Index: linux-2.6.23-rc1/net/sunrpc/rpc_pipe.c
===================================================================
--- linux-2.6.23-rc1.orig/net/sunrpc/rpc_pipe.c	2007-07-24 00:10:08.000000000 -0700
+++ linux-2.6.23-rc1/net/sunrpc/rpc_pipe.c	2007-07-24 00:10:30.000000000 -0700
@@ -841,7 +841,7 @@ static struct file_system_type rpc_pipe_
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
