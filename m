Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B16F882F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:07:58 -0500 (EST)
Received: by lfbn126 with SMTP id n126so85004530lfb.2
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:07:58 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l136si4499398lfl.145.2015.11.07.12.07.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 12:07:56 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 5/5] Account certain kmem allocations to memcg
Date: Sat, 7 Nov 2015 23:07:09 +0300
Message-ID: <60b4d1631e3a302246859d6a39ac7c6d6cbf3af3.1446924358.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1446924358.git.vdavydov@virtuozzo.com>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patch marks those kmem allocations that are known to be easily
triggered from userspace as __GFP_ACCOUNT, which makes them accounted to
memcg. For the list, see below:

 - threadinfo
 - task_struct
 - task_delay_info
 - pid
 - cred
 - mm_struct
 - vm_area_struct and vm_region (nommu)
 - anon_vma and anon_vma_chain
 - signal_struct
 - sighand_struct
 - fs_struct
 - files_struct
 - fdtable and fdtable->full_fds_bits
 - dentry and external_name
 - inode for all filesystems. This is the most tedious part, because
   most filesystems overwrite the alloc_inode method. Looks like using
   __GFP_ACCOUNT in alloc_inode is going to become a new rule, like
   passing SLAB_RECLAIM_ACCOUNT on inode cache creation.

The list is by far not complete, so feel free to add more objects.
Nevertheless, it should be close to "account everything" approach and
keep most workloads within bounds. Malevolent users will be able to
breach the limit, but this was possible even with the former "account
everything" approach (simply because it did not account everything in
fact).

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 arch/powerpc/platforms/cell/spufs/inode.c     |  2 +-
 drivers/staging/lustre/lustre/llite/super25.c |  3 ++-
 fs/9p/vfs_inode.c                             |  2 +-
 fs/adfs/super.c                               |  2 +-
 fs/affs/super.c                               |  2 +-
 fs/afs/super.c                                |  2 +-
 fs/befs/linuxvfs.c                            |  2 +-
 fs/bfs/inode.c                                |  2 +-
 fs/block_dev.c                                |  3 ++-
 fs/btrfs/inode.c                              |  2 +-
 fs/ceph/inode.c                               |  2 +-
 fs/cifs/cifsfs.c                              |  2 +-
 fs/coda/inode.c                               |  2 +-
 fs/dcache.c                                   |  5 +++--
 fs/ecryptfs/super.c                           |  3 ++-
 fs/efs/super.c                                |  2 +-
 fs/exec.c                                     |  5 +++--
 fs/exofs/super.c                              |  2 +-
 fs/ext2/super.c                               |  2 +-
 fs/ext4/super.c                               |  2 +-
 fs/f2fs/super.c                               |  2 +-
 fs/fat/inode.c                                |  2 +-
 fs/file.c                                     |  9 +++++----
 fs/fs_struct.c                                |  2 +-
 fs/fuse/inode.c                               |  4 ++--
 fs/gfs2/super.c                               |  2 +-
 fs/hfs/super.c                                |  2 +-
 fs/hfsplus/super.c                            |  2 +-
 fs/hostfs/hostfs_kern.c                       |  2 +-
 fs/hpfs/super.c                               |  2 +-
 fs/hugetlbfs/inode.c                          |  2 +-
 fs/inode.c                                    |  2 +-
 fs/isofs/inode.c                              |  2 +-
 fs/jffs2/super.c                              |  2 +-
 fs/jfs/super.c                                |  3 ++-
 fs/logfs/inode.c                              |  2 +-
 fs/minix/inode.c                              |  2 +-
 fs/ncpfs/inode.c                              |  3 ++-
 fs/nfs/inode.c                                |  2 +-
 fs/nilfs2/super.c                             |  2 +-
 fs/ntfs/inode.c                               |  2 +-
 fs/ocfs2/dlmfs/dlmfs.c                        |  2 +-
 fs/ocfs2/super.c                              |  2 +-
 fs/openpromfs/inode.c                         |  2 +-
 fs/proc/inode.c                               |  3 ++-
 fs/qnx4/inode.c                               |  2 +-
 fs/qnx6/inode.c                               |  2 +-
 fs/reiserfs/super.c                           |  2 +-
 fs/romfs/super.c                              |  2 +-
 fs/squashfs/super.c                           |  2 +-
 fs/sysv/inode.c                               |  2 +-
 fs/ubifs/super.c                              |  2 +-
 fs/udf/super.c                                |  2 +-
 fs/ufs/super.c                                |  2 +-
 fs/xfs/kmem.h                                 |  7 ++++++-
 fs/xfs/xfs_icache.c                           |  2 +-
 include/linux/thread_info.h                   |  5 +++--
 ipc/mqueue.c                                  |  2 +-
 kernel/cred.c                                 |  4 ++--
 kernel/delayacct.c                            |  2 +-
 kernel/fork.c                                 | 11 ++++++-----
 kernel/pid.c                                  |  2 +-
 mm/mmap.c                                     | 10 +++++-----
 mm/nommu.c                                    |  8 ++++----
 mm/rmap.c                                     |  4 ++--
 mm/shmem.c                                    |  2 +-
 net/socket.c                                  |  4 ++--
 net/sunrpc/rpc_pipe.c                         |  2 +-
 68 files changed, 105 insertions(+), 89 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index 11634fa7ab3c..b2dfa9d0c58e 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -60,7 +60,7 @@ spufs_alloc_inode(struct super_block *sb)
 {
 	struct spufs_inode_info *ei;
 
-	ei = kmem_cache_alloc(spufs_inode_cache, GFP_KERNEL);
+	ei = kmem_cache_alloc(spufs_inode_cache, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 013136860664..2189934d1c8b 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -53,7 +53,8 @@ static struct inode *ll_alloc_inode(struct super_block *sb)
 	struct ll_inode_info *lli;
 
 	ll_stats_ops_tally(ll_s2sbi(sb), LPROC_LL_ALLOC_INODE, 1);
-	lli = kmem_cache_alloc(ll_inode_cachep, GFP_NOFS | __GFP_ZERO);
+	lli = kmem_cache_alloc(ll_inode_cachep,
+			       GFP_NOFS | __GFP_ACCOUNT | __GFP_ZERO);
 	if (lli == NULL)
 		return NULL;
 
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index b1dc51888048..c71eb84b0b65 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -239,7 +239,7 @@ struct inode *v9fs_alloc_inode(struct super_block *sb)
 {
 	struct v9fs_inode *v9inode;
 	v9inode = (struct v9fs_inode *)kmem_cache_alloc(v9fs_inode_cache,
-							GFP_KERNEL);
+							GFP_KERNEL_ACCOUNT);
 	if (!v9inode)
 		return NULL;
 #ifdef CONFIG_9P_FSCACHE
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index 4d4a0df8344f..0cc39f7b7c44 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -242,7 +242,7 @@ static struct kmem_cache *adfs_inode_cachep;
 static struct inode *adfs_alloc_inode(struct super_block *sb)
 {
 	struct adfs_inode_info *ei;
-	ei = kmem_cache_alloc(adfs_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(adfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/affs/super.c b/fs/affs/super.c
index 5b50c4ca43a7..45b74d8e5dc0 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -95,7 +95,7 @@ static struct inode *affs_alloc_inode(struct super_block *sb)
 {
 	struct affs_inode_info *i;
 
-	i = kmem_cache_alloc(affs_inode_cachep, GFP_KERNEL);
+	i = kmem_cache_alloc(affs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!i)
 		return NULL;
 
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 1fb4a5129f7d..a3c606f06dcb 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -481,7 +481,7 @@ static struct inode *afs_alloc_inode(struct super_block *sb)
 {
 	struct afs_vnode *vnode;
 
-	vnode = kmem_cache_alloc(afs_inode_cachep, GFP_KERNEL);
+	vnode = kmem_cache_alloc(afs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!vnode)
 		return NULL;
 
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 46aedacfa6a8..dd1c42f61aed 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -270,7 +270,7 @@ befs_alloc_inode(struct super_block *sb)
 {
 	struct befs_inode_info *bi;
 
-	bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL);
+	bi = kmem_cache_alloc(befs_inode_cachep, GFP_KERNEL_ACCOUNT);
         if (!bi)
                 return NULL;
         return &bi->vfs_inode;
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index fdcb4d69f430..92d525bfb42e 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -241,7 +241,7 @@ static struct kmem_cache *bfs_inode_cachep;
 static struct inode *bfs_alloc_inode(struct super_block *sb)
 {
 	struct bfs_inode_info *bi;
-	bi = kmem_cache_alloc(bfs_inode_cachep, GFP_KERNEL);
+	bi = kmem_cache_alloc(bfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!bi)
 		return NULL;
 	return &bi->vfs_inode;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 0a793c7930eb..f914fe74c755 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -479,7 +479,8 @@ static struct kmem_cache * bdev_cachep __read_mostly;
 
 static struct inode *bdev_alloc_inode(struct super_block *sb)
 {
-	struct bdev_inode *ei = kmem_cache_alloc(bdev_cachep, GFP_KERNEL);
+	struct bdev_inode *ei = kmem_cache_alloc(bdev_cachep,
+						 GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 4439fbb4ff45..61d3bd937790 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -9003,7 +9003,7 @@ struct inode *btrfs_alloc_inode(struct super_block *sb)
 	struct btrfs_inode *ei;
 	struct inode *inode;
 
-	ei = kmem_cache_alloc(btrfs_inode_cachep, GFP_NOFS);
+	ei = kmem_cache_alloc(btrfs_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 96d2bd829902..6a2688e6173f 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -377,7 +377,7 @@ struct inode *ceph_alloc_inode(struct super_block *sb)
 	struct ceph_inode_info *ci;
 	int i;
 
-	ci = kmem_cache_alloc(ceph_inode_cachep, GFP_NOFS);
+	ci = kmem_cache_alloc(ceph_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ci)
 		return NULL;
 
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index e739950ca084..44c93a832e68 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -249,7 +249,7 @@ static struct inode *
 cifs_alloc_inode(struct super_block *sb)
 {
 	struct cifsInodeInfo *cifs_inode;
-	cifs_inode = kmem_cache_alloc(cifs_inode_cachep, GFP_KERNEL);
+	cifs_inode = kmem_cache_alloc(cifs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!cifs_inode)
 		return NULL;
 	cifs_inode->cifsAttrs = 0x20;	/* default */
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index cac1390b87a3..731116ca38b4 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -42,7 +42,7 @@ static struct kmem_cache * coda_inode_cachep;
 static struct inode *coda_alloc_inode(struct super_block *sb)
 {
 	struct coda_inode_info *ei;
-	ei = kmem_cache_alloc(coda_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(coda_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	memset(&ei->c_fid, 0, sizeof(struct CodaFid));
diff --git a/fs/dcache.c b/fs/dcache.c
index 5c33aeb0f68f..f71b374d27ab 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1558,7 +1558,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL);
+	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL_ACCOUNT);
 	if (!dentry)
 		return NULL;
 
@@ -1571,7 +1571,8 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	dentry->d_iname[DNAME_INLINE_LEN-1] = 0;
 	if (name->len > DNAME_INLINE_LEN-1) {
 		size_t size = offsetof(struct external_name, name[1]);
-		struct external_name *p = kmalloc(size + name->len, GFP_KERNEL);
+		struct external_name *p = kmalloc(size + name->len,
+						  GFP_KERNEL_ACCOUNT);
 		if (!p) {
 			kmem_cache_free(dentry_cache, dentry); 
 			return NULL;
diff --git a/fs/ecryptfs/super.c b/fs/ecryptfs/super.c
index afa1b81c3418..ee30c18cac1f 100644
--- a/fs/ecryptfs/super.c
+++ b/fs/ecryptfs/super.c
@@ -53,7 +53,8 @@ static struct inode *ecryptfs_alloc_inode(struct super_block *sb)
 	struct ecryptfs_inode_info *inode_info;
 	struct inode *inode = NULL;
 
-	inode_info = kmem_cache_alloc(ecryptfs_inode_info_cache, GFP_KERNEL);
+	inode_info = kmem_cache_alloc(ecryptfs_inode_info_cache,
+				      GFP_KERNEL_ACCOUNT);
 	if (unlikely(!inode_info))
 		goto out;
 	ecryptfs_init_crypt_stat(&inode_info->crypt_stat);
diff --git a/fs/efs/super.c b/fs/efs/super.c
index c8411a30f7da..02bae40ba9ee 100644
--- a/fs/efs/super.c
+++ b/fs/efs/super.c
@@ -67,7 +67,7 @@ static struct kmem_cache * efs_inode_cachep;
 static struct inode *efs_alloc_inode(struct super_block *sb)
 {
 	struct efs_inode_info *ei;
-	ei = kmem_cache_alloc(efs_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(efs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/exec.c b/fs/exec.c
index b06623a9347f..ab78366b3852 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -258,7 +258,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = bprm->mm;
 
-	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!vma)
 		return -ENOMEM;
 
@@ -1026,7 +1026,8 @@ no_thread_group:
 		 * This ->sighand is shared with the CLONE_SIGHAND
 		 * but not CLONE_THREAD task, switch to the new one.
 		 */
-		newsighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+		newsighand = kmem_cache_alloc(sighand_cachep,
+					      GFP_KERNEL_ACCOUNT);
 		if (!newsighand)
 			return -ENOMEM;
 
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index b795c567b5e1..0361a742dc40 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -155,7 +155,7 @@ static struct inode *exofs_alloc_inode(struct super_block *sb)
 {
 	struct exofs_i_info *oi;
 
-	oi = kmem_cache_alloc(exofs_inode_cachep, GFP_KERNEL);
+	oi = kmem_cache_alloc(exofs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!oi)
 		return NULL;
 
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 900e19cf9ef6..2c76dd2138d3 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -160,7 +160,7 @@ static struct kmem_cache * ext2_inode_cachep;
 static struct inode *ext2_alloc_inode(struct super_block *sb)
 {
 	struct ext2_inode_info *ei;
-	ei = kmem_cache_alloc(ext2_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(ext2_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	ei->i_block_alloc_info = NULL;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 04d0f1b33409..c551163cb4c6 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -885,7 +885,7 @@ static struct inode *ext4_alloc_inode(struct super_block *sb)
 {
 	struct ext4_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext4_inode_cachep, GFP_NOFS);
+	ei = kmem_cache_alloc(ext4_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 3a65e0132352..f5486eb5c549 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -420,7 +420,7 @@ static struct inode *f2fs_alloc_inode(struct super_block *sb)
 {
 	struct f2fs_inode_info *fi;
 
-	fi = kmem_cache_alloc(f2fs_inode_cachep, GFP_F2FS_ZERO);
+	fi = kmem_cache_alloc(f2fs_inode_cachep, GFP_F2FS_ZERO | __GFP_ACCOUNT);
 	if (!fi)
 		return NULL;
 
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 509411dd3698..3ae3ddde833a 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -640,7 +640,7 @@ static struct kmem_cache *fat_inode_cachep;
 static struct inode *fat_alloc_inode(struct super_block *sb)
 {
 	struct msdos_inode_info *ei;
-	ei = kmem_cache_alloc(fat_inode_cachep, GFP_NOFS);
+	ei = kmem_cache_alloc(fat_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/fs/file.c b/fs/file.c
index 39f8f15921da..67f4aaf5808f 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -37,11 +37,12 @@ static void *alloc_fdmem(size_t size)
 	 * vmalloc() if the allocation size will be considered "large" by the VM.
 	 */
 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
-		void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
+		void *data = kmalloc(size, GFP_KERNEL_ACCOUNT |
+				     __GFP_NOWARN | __GFP_NORETRY);
 		if (data != NULL)
 			return data;
 	}
-	return vmalloc(size);
+	return __vmalloc(size, GFP_KERNEL_ACCOUNT | __GFP_HIGHMEM, PAGE_KERNEL);
 }
 
 static void __free_fdtable(struct fdtable *fdt)
@@ -126,7 +127,7 @@ static struct fdtable * alloc_fdtable(unsigned int nr)
 	if (unlikely(nr > sysctl_nr_open))
 		nr = ((sysctl_nr_open - 1) | (BITS_PER_LONG - 1)) + 1;
 
-	fdt = kmalloc(sizeof(struct fdtable), GFP_KERNEL);
+	fdt = kmalloc(sizeof(struct fdtable), GFP_KERNEL_ACCOUNT);
 	if (!fdt)
 		goto out;
 	fdt->max_fds = nr;
@@ -294,7 +295,7 @@ struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 	struct fdtable *old_fdt, *new_fdt;
 
 	*errorp = -ENOMEM;
-	newf = kmem_cache_alloc(files_cachep, GFP_KERNEL);
+	newf = kmem_cache_alloc(files_cachep, GFP_KERNEL_ACCOUNT);
 	if (!newf)
 		goto out;
 
diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 7dca743b2ce1..e4ecb7f5d486 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -109,7 +109,7 @@ void exit_fs(struct task_struct *tsk)
 
 struct fs_struct *copy_fs_struct(struct fs_struct *old)
 {
-	struct fs_struct *fs = kmem_cache_alloc(fs_cachep, GFP_KERNEL);
+	struct fs_struct *fs = kmem_cache_alloc(fs_cachep, GFP_KERNEL_ACCOUNT);
 	/* We don't need to lock fs - think why ;-) */
 	if (fs) {
 		fs->users = 1;
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 2913db2a5b99..6839e13107b3 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -73,7 +73,7 @@ struct fuse_mount_data {
 
 struct fuse_forget_link *fuse_alloc_forget(void)
 {
-	return kzalloc(sizeof(struct fuse_forget_link), GFP_KERNEL);
+	return kzalloc(sizeof(struct fuse_forget_link), GFP_KERNEL_ACCOUNT);
 }
 
 static struct inode *fuse_alloc_inode(struct super_block *sb)
@@ -81,7 +81,7 @@ static struct inode *fuse_alloc_inode(struct super_block *sb)
 	struct inode *inode;
 	struct fuse_inode *fi;
 
-	inode = kmem_cache_alloc(fuse_inode_cachep, GFP_KERNEL);
+	inode = kmem_cache_alloc(fuse_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!inode)
 		return NULL;
 
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index 894fb01a91da..228f7e40f46f 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -1627,7 +1627,7 @@ static struct inode *gfs2_alloc_inode(struct super_block *sb)
 {
 	struct gfs2_inode *ip;
 
-	ip = kmem_cache_alloc(gfs2_inode_cachep, GFP_KERNEL);
+	ip = kmem_cache_alloc(gfs2_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (ip) {
 		ip->i_flags = 0;
 		ip->i_gl = NULL;
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index 4574fdd3d421..71e72f10d301 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -163,7 +163,7 @@ static struct inode *hfs_alloc_inode(struct super_block *sb)
 {
 	struct hfs_inode_info *i;
 
-	i = kmem_cache_alloc(hfs_inode_cachep, GFP_KERNEL);
+	i = kmem_cache_alloc(hfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	return i ? &i->vfs_inode : NULL;
 }
 
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 7302d96ae8bf..ec1dba62113b 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -618,7 +618,7 @@ static struct inode *hfsplus_alloc_inode(struct super_block *sb)
 {
 	struct hfsplus_inode_info *i;
 
-	i = kmem_cache_alloc(hfsplus_inode_cachep, GFP_KERNEL);
+	i = kmem_cache_alloc(hfsplus_inode_cachep, GFP_KERNEL_ACCOUNT);
 	return i ? &i->vfs_inode : NULL;
 }
 
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 2ac99db3750e..a4cf6b11a142 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -223,7 +223,7 @@ static struct inode *hostfs_alloc_inode(struct super_block *sb)
 {
 	struct hostfs_inode_info *hi;
 
-	hi = kmalloc(sizeof(*hi), GFP_KERNEL);
+	hi = kmalloc(sizeof(*hi), GFP_KERNEL_ACCOUNT);
 	if (hi == NULL)
 		return NULL;
 	hi->fd = -1;
diff --git a/fs/hpfs/super.c b/fs/hpfs/super.c
index a561591896bd..ec65d9ccdbce 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -231,7 +231,7 @@ static struct kmem_cache * hpfs_inode_cachep;
 static struct inode *hpfs_alloc_inode(struct super_block *sb)
 {
 	struct hpfs_inode_info *ei;
-	ei = kmem_cache_alloc(hpfs_inode_cachep, GFP_NOFS);
+	ei = kmem_cache_alloc(hpfs_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ei)
 		return NULL;
 	ei->vfs_inode.i_version = 1;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb968b65..7decd4c04416 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -925,7 +925,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
 
 	if (unlikely(!hugetlbfs_dec_free_inodes(sbinfo)))
 		return NULL;
-	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
+	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (unlikely(!p)) {
 		hugetlbfs_inc_free_inodes(sbinfo);
 		return NULL;
diff --git a/fs/inode.c b/fs/inode.c
index 78a17b8859e1..71f8bf50d788 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -197,7 +197,7 @@ static struct inode *alloc_inode(struct super_block *sb)
 	if (sb->s_op->alloc_inode)
 		inode = sb->s_op->alloc_inode(sb);
 	else
-		inode = kmem_cache_alloc(inode_cachep, GFP_KERNEL);
+		inode = kmem_cache_alloc(inode_cachep, GFP_KERNEL_ACCOUNT);
 
 	if (!inode)
 		return NULL;
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index d67a16f2a45d..b1c99c236bea 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -65,7 +65,7 @@ static struct kmem_cache *isofs_inode_cachep;
 static struct inode *isofs_alloc_inode(struct super_block *sb)
 {
 	struct iso_inode_info *ei;
-	ei = kmem_cache_alloc(isofs_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(isofs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index d86c5e3176a1..d5fb8de88453 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -38,7 +38,7 @@ static struct inode *jffs2_alloc_inode(struct super_block *sb)
 {
 	struct jffs2_inode_info *f;
 
-	f = kmem_cache_alloc(jffs2_inode_cachep, GFP_KERNEL);
+	f = kmem_cache_alloc(jffs2_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!f)
 		return NULL;
 	return &f->vfs_inode;
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 4cd9798f4948..ed8ea15842dd 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -114,7 +114,8 @@ static struct inode *jfs_alloc_inode(struct super_block *sb)
 {
 	struct jfs_inode_info *jfs_inode;
 
-	jfs_inode = kmem_cache_alloc(jfs_inode_cachep, GFP_NOFS);
+	jfs_inode = kmem_cache_alloc(jfs_inode_cachep,
+				     GFP_NOFS | __GFP_ACCOUNT);
 	if (!jfs_inode)
 		return NULL;
 #ifdef CONFIG_QUOTA
diff --git a/fs/logfs/inode.c b/fs/logfs/inode.c
index af49e2d6941a..7fddc9e2e90e 100644
--- a/fs/logfs/inode.c
+++ b/fs/logfs/inode.c
@@ -227,7 +227,7 @@ static struct inode *logfs_alloc_inode(struct super_block *sb)
 {
 	struct logfs_inode *li;
 
-	li = kmem_cache_alloc(logfs_inode_cache, GFP_NOFS);
+	li = kmem_cache_alloc(logfs_inode_cache, GFP_NOFS | __GFP_ACCOUNT);
 	if (!li)
 		return NULL;
 	logfs_init_inode(sb, &li->vfs_inode);
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 086cd0a61e80..9d9e8d81266f 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -62,7 +62,7 @@ static struct kmem_cache * minix_inode_cachep;
 static struct inode *minix_alloc_inode(struct super_block *sb)
 {
 	struct minix_inode_info *ei;
-	ei = kmem_cache_alloc(minix_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(minix_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 9605a2f63549..bc160ce558f4 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -52,7 +52,8 @@ static struct kmem_cache * ncp_inode_cachep;
 static struct inode *ncp_alloc_inode(struct super_block *sb)
 {
 	struct ncp_inode_info *ei;
-	ei = (struct ncp_inode_info *)kmem_cache_alloc(ncp_inode_cachep, GFP_KERNEL);
+	ei = (struct ncp_inode_info *)kmem_cache_alloc(ncp_inode_cachep,
+						       GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e10d833..31f11639ec35 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1847,7 +1847,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
-	nfsi = kmem_cache_alloc(nfs_inode_cachep, GFP_KERNEL);
+	nfsi = kmem_cache_alloc(nfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!nfsi)
 		return NULL;
 	nfsi->flags = 0UL;
diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index f47585bfeb01..e3b1a95d55e0 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -159,7 +159,7 @@ struct inode *nilfs_alloc_inode(struct super_block *sb)
 {
 	struct nilfs_inode_info *ii;
 
-	ii = kmem_cache_alloc(nilfs_inode_cachep, GFP_NOFS);
+	ii = kmem_cache_alloc(nilfs_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ii)
 		return NULL;
 	ii->i_bh = NULL;
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index d284f07eda77..c437ab99f5f2 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -323,7 +323,7 @@ struct inode *ntfs_alloc_big_inode(struct super_block *sb)
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_big_inode_cache, GFP_NOFS);
+	ni = kmem_cache_alloc(ntfs_big_inode_cache, GFP_NOFS | __GFP_ACCOUNT);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return VFS_I(ni);
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index b5cf27dcb18a..8e027cf65c90 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -343,7 +343,7 @@ static struct inode *dlmfs_alloc_inode(struct super_block *sb)
 {
 	struct dlmfs_inode_private *ip;
 
-	ip = kmem_cache_alloc(dlmfs_inode_cache, GFP_NOFS);
+	ip = kmem_cache_alloc(dlmfs_inode_cache, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ip)
 		return NULL;
 
diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 2de4c8a9340c..510104231c3b 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -567,7 +567,7 @@ static struct inode *ocfs2_alloc_inode(struct super_block *sb)
 {
 	struct ocfs2_inode_info *oi;
 
-	oi = kmem_cache_alloc(ocfs2_inode_cachep, GFP_NOFS);
+	oi = kmem_cache_alloc(ocfs2_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!oi)
 		return NULL;
 
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index 15e4500cda3e..5bba56246c3d 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -329,7 +329,7 @@ static struct inode *openprom_alloc_inode(struct super_block *sb)
 {
 	struct op_inode_info *oi;
 
-	oi = kmem_cache_alloc(op_inode_cachep, GFP_KERNEL);
+	oi = kmem_cache_alloc(op_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!oi)
 		return NULL;
 
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index bd95b9fdebb0..0a2f1555d048 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -57,7 +57,8 @@ static struct inode *proc_alloc_inode(struct super_block *sb)
 	struct proc_inode *ei;
 	struct inode *inode;
 
-	ei = (struct proc_inode *)kmem_cache_alloc(proc_inode_cachep, GFP_KERNEL);
+	ei = (struct proc_inode *)kmem_cache_alloc(proc_inode_cachep,
+						   GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	ei->pid = NULL;
diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index c4bcb778886e..ef5b2cff3c04 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -335,7 +335,7 @@ static struct kmem_cache *qnx4_inode_cachep;
 static struct inode *qnx4_alloc_inode(struct super_block *sb)
 {
 	struct qnx4_inode_info *ei;
-	ei = kmem_cache_alloc(qnx4_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(qnx4_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 32d2e1a9774c..0caa3b22cedf 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -595,7 +595,7 @@ static struct kmem_cache *qnx6_inode_cachep;
 static struct inode *qnx6_alloc_inode(struct super_block *sb)
 {
 	struct qnx6_inode_info *ei;
-	ei = kmem_cache_alloc(qnx6_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(qnx6_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 4a62fe8cc3bf..4690b8604de6 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -589,7 +589,7 @@ static struct kmem_cache *reiserfs_inode_cachep;
 static struct inode *reiserfs_alloc_inode(struct super_block *sb)
 {
 	struct reiserfs_inode_info *ei;
-	ei = kmem_cache_alloc(reiserfs_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(reiserfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	atomic_set(&ei->openers, 0);
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 268733cda397..c15bce01f3da 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -390,7 +390,7 @@ static struct inode *romfs_alloc_inode(struct super_block *sb)
 {
 	struct romfs_inode_info *inode;
 
-	inode = kmem_cache_alloc(romfs_inode_cachep, GFP_KERNEL);
+	inode = kmem_cache_alloc(romfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 	return inode ? &inode->vfs_inode : NULL;
 }
 
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 5056babe00df..381583472fdf 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -466,7 +466,7 @@ static void __exit exit_squashfs_fs(void)
 static struct inode *squashfs_alloc_inode(struct super_block *sb)
 {
 	struct squashfs_inode_info *ei =
-		kmem_cache_alloc(squashfs_inode_cachep, GFP_KERNEL);
+		kmem_cache_alloc(squashfs_inode_cachep, GFP_KERNEL_ACCOUNT);
 
 	return ei ? &ei->vfs_inode : NULL;
 }
diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index 590ad9206e3f..bb5a1d08ed99 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -314,7 +314,7 @@ static struct inode *sysv_alloc_inode(struct super_block *sb)
 {
 	struct sysv_inode_info *si;
 
-	si = kmem_cache_alloc(sysv_inode_cachep, GFP_KERNEL);
+	si = kmem_cache_alloc(sysv_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!si)
 		return NULL;
 	return &si->vfs_inode;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 9547a27868ad..a7e941796152 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -259,7 +259,7 @@ static struct inode *ubifs_alloc_inode(struct super_block *sb)
 {
 	struct ubifs_inode *ui;
 
-	ui = kmem_cache_alloc(ubifs_inode_slab, GFP_NOFS);
+	ui = kmem_cache_alloc(ubifs_inode_slab, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ui)
 		return NULL;
 
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 81155b9b445b..f2556d265568 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -139,7 +139,7 @@ static struct kmem_cache *udf_inode_cachep;
 static struct inode *udf_alloc_inode(struct super_block *sb)
 {
 	struct udf_inode_info *ei;
-	ei = kmem_cache_alloc(udf_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(udf_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index f6390eec02ca..821b67999008 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1394,7 +1394,7 @@ static struct inode *ufs_alloc_inode(struct super_block *sb)
 {
 	struct ufs_inode_info *ei;
 
-	ei = kmem_cache_alloc(ufs_inode_cachep, GFP_NOFS);
+	ei = kmem_cache_alloc(ufs_inode_cachep, GFP_NOFS | __GFP_ACCOUNT);
 	if (!ei)
 		return NULL;
 
diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index cc6b768fc068..da166d919a77 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -33,6 +33,7 @@ typedef unsigned __bitwise xfs_km_flags_t;
 #define KM_NOFS		((__force xfs_km_flags_t)0x0004u)
 #define KM_MAYFAIL	((__force xfs_km_flags_t)0x0008u)
 #define KM_ZERO		((__force xfs_km_flags_t)0x0010u)
+#define KM_ACCOUNT	((__force xfs_km_flags_t)0x0020u)
 
 /*
  * We use a special process flag to avoid recursive callbacks into
@@ -44,7 +45,8 @@ kmem_flags_convert(xfs_km_flags_t flags)
 {
 	gfp_t	lflags;
 
-	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO));
+	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO|
+			 KM_ACCOUNT));
 
 	if (flags & KM_NOSLEEP) {
 		lflags = GFP_ATOMIC | __GFP_NOWARN;
@@ -57,6 +59,9 @@ kmem_flags_convert(xfs_km_flags_t flags)
 	if (flags & KM_ZERO)
 		lflags |= __GFP_ZERO;
 
+	if (flags & KM_ACCOUNT)
+		lflags |= __GFP_ACCOUNT;
+
 	return lflags;
 }
 
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 0a326bd64d4e..18b840e64ab5 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -55,7 +55,7 @@ xfs_inode_alloc(
 	 * KM_MAYFAIL and return NULL here on ENOMEM. Set the
 	 * code up to do this anyway.
 	 */
-	ip = kmem_zone_alloc(xfs_inode_zone, KM_SLEEP);
+	ip = kmem_zone_alloc(xfs_inode_zone, KM_SLEEP | KM_ACCOUNT);
 	if (!ip)
 		return NULL;
 	if (inode_init_always(mp->m_super, VFS_I(ip))) {
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index ff307b548ed3..b4c2a485b28a 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -56,9 +56,10 @@ extern long do_no_restart_syscall(struct restart_block *parm);
 #ifdef __KERNEL__
 
 #ifdef CONFIG_DEBUG_STACK_USAGE
-# define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
+# define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | \
+				 __GFP_ZERO)
 #else
-# define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
+# define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK)
 #endif
 
 /*
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 161a1807e6ef..d40450232e40 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -350,7 +350,7 @@ static struct inode *mqueue_alloc_inode(struct super_block *sb)
 {
 	struct mqueue_inode_info *ei;
 
-	ei = kmem_cache_alloc(mqueue_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(mqueue_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
diff --git a/kernel/cred.c b/kernel/cred.c
index 71179a09c1d6..fd2986fe091e 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -207,7 +207,7 @@ struct cred *cred_alloc_blank(void)
 {
 	struct cred *new;
 
-	new = kmem_cache_zalloc(cred_jar, GFP_KERNEL);
+	new = kmem_cache_zalloc(cred_jar, GFP_KERNEL_ACCOUNT);
 	if (!new)
 		return NULL;
 
@@ -248,7 +248,7 @@ struct cred *prepare_creds(void)
 
 	validate_process_creds();
 
-	new = kmem_cache_alloc(cred_jar, GFP_KERNEL);
+	new = kmem_cache_alloc(cred_jar, GFP_KERNEL_ACCOUNT);
 	if (!new)
 		return NULL;
 
diff --git a/kernel/delayacct.c b/kernel/delayacct.c
index ef90b04d783f..84fa553c364d 100644
--- a/kernel/delayacct.c
+++ b/kernel/delayacct.c
@@ -40,7 +40,7 @@ void delayacct_init(void)
 
 void __delayacct_tsk_init(struct task_struct *tsk)
 {
-	tsk->delays = kmem_cache_zalloc(delayacct_cache, GFP_KERNEL);
+	tsk->delays = kmem_cache_zalloc(delayacct_cache, GFP_KERNEL_ACCOUNT);
 	if (tsk->delays)
 		spin_lock_init(&tsk->delays->lock);
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index f97f2c449f5c..f08d88ed9857 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -138,7 +138,8 @@ static struct kmem_cache *task_struct_cachep;
 
 static inline struct task_struct *alloc_task_struct_node(int node)
 {
-	return kmem_cache_alloc_node(task_struct_cachep, GFP_KERNEL, node);
+	return kmem_cache_alloc_node(task_struct_cachep,
+				     GFP_KERNEL_ACCOUNT, node);
 }
 
 static inline void free_task_struct(struct task_struct *tsk)
@@ -444,7 +445,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 				goto fail_nomem;
 			charge = len;
 		}
-		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
@@ -552,7 +553,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
-#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
+#define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL_ACCOUNT))
 #define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
 
 static unsigned long default_dump_filter = MMF_DUMP_FILTER_DEFAULT;
@@ -1071,7 +1072,7 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
 		atomic_inc(&current->sighand->count);
 		return 0;
 	}
-	sig = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	sig = kmem_cache_alloc(sighand_cachep, GFP_KERNEL_ACCOUNT);
 	rcu_assign_pointer(tsk->sighand, sig);
 	if (!sig)
 		return -ENOMEM;
@@ -1119,7 +1120,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	if (clone_flags & CLONE_THREAD)
 		return 0;
 
-	sig = kmem_cache_zalloc(signal_cachep, GFP_KERNEL);
+	sig = kmem_cache_zalloc(signal_cachep, GFP_KERNEL_ACCOUNT);
 	tsk->signal = sig;
 	if (!sig)
 		return -ENOMEM;
diff --git a/kernel/pid.c b/kernel/pid.c
index ca368793808e..03e2b553009d 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -303,7 +303,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	struct upid *upid;
 	int retval = -ENOMEM;
 
-	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL);
+	pid = kmem_cache_alloc(ns->pid_cachep, GFP_KERNEL_ACCOUNT);
 	if (!pid)
 		return ERR_PTR(retval);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..9741c91cf4b2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1590,7 +1590,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * specific mapper. the address has already been validated, but
 	 * not unmapped, but the maps are removed from the list.
 	 */
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!vma) {
 		error = -ENOMEM;
 		goto unacct_error;
@@ -2463,7 +2463,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 					~(huge_page_mask(hstate_vma(vma)))))
 		return -EINVAL;
 
-	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!new)
 		return -ENOMEM;
 
@@ -2778,7 +2778,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	/*
 	 * create a vma struct for an anonymous mapping
 	 */
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!vma) {
 		vm_unacct_memory(len >> PAGE_SHIFT);
 		return -ENOMEM;
@@ -2953,7 +2953,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		}
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
 	} else {
-		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 		if (!new_vma)
 			goto out;
 		*new_vma = *vma;
@@ -3058,7 +3058,7 @@ static struct vm_area_struct *__install_special_mapping(
 	int ret;
 	struct vm_area_struct *vma;
 
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (unlikely(vma == NULL))
 		return ERR_PTR(-ENOMEM);
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 92be862c859b..d14179e1f371 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1266,11 +1266,11 @@ unsigned long do_mmap(struct file *file,
 	vm_flags |= determine_vm_flags(file, prot, flags, capabilities);
 
 	/* we're going to need to record the mapping */
-	region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL);
+	region = kmem_cache_zalloc(vm_region_jar, GFP_KERNEL_ACCOUNT);
 	if (!region)
 		goto error_getting_region;
 
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!vma)
 		goto error_getting_vma;
 
@@ -1524,11 +1524,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (mm->map_count >= sysctl_max_map_count)
 		return -ENOMEM;
 
-	region = kmem_cache_alloc(vm_region_jar, GFP_KERNEL);
+	region = kmem_cache_alloc(vm_region_jar, GFP_KERNEL_ACCOUNT);
 	if (!region)
 		return -ENOMEM;
 
-	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
+	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL_ACCOUNT);
 	if (!new) {
 		kmem_cache_free(vm_region_jar, region);
 		return -ENOMEM;
diff --git a/mm/rmap.c b/mm/rmap.c
index b577fbb98d4b..3d56eac5dad9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -74,7 +74,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 {
 	struct anon_vma *anon_vma;
 
-	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL_ACCOUNT);
 	if (anon_vma) {
 		atomic_set(&anon_vma->refcount, 1);
 		anon_vma->degree = 1;	/* Reference for first vma */
@@ -121,7 +121,7 @@ static inline void anon_vma_free(struct anon_vma *anon_vma)
 
 static inline struct anon_vma_chain *anon_vma_chain_alloc(gfp_t gfp)
 {
-	return kmem_cache_alloc(anon_vma_chain_cachep, gfp);
+	return kmem_cache_alloc(anon_vma_chain_cachep, gfp | __GFP_ACCOUNT);
 }
 
 static void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
diff --git a/mm/shmem.c b/mm/shmem.c
index 3b8b73928398..f1904224cbbf 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3078,7 +3078,7 @@ static struct kmem_cache *shmem_inode_cachep;
 static struct inode *shmem_alloc_inode(struct super_block *sb)
 {
 	struct shmem_inode_info *info;
-	info = kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL);
+	info = kmem_cache_alloc(shmem_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!info)
 		return NULL;
 	return &info->vfs_inode;
diff --git a/net/socket.c b/net/socket.c
index 9963a0b53a64..62282a95c3ac 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -247,10 +247,10 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 	struct socket_alloc *ei;
 	struct socket_wq *wq;
 
-	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
+	ei = kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!ei)
 		return NULL;
-	wq = kmalloc(sizeof(*wq), GFP_KERNEL);
+	wq = kmalloc(sizeof(*wq), GFP_KERNEL_ACCOUNT);
 	if (!wq) {
 		kmem_cache_free(sock_inode_cachep, ei);
 		return NULL;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index d81186d34558..c64403939239 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -195,7 +195,7 @@ static struct inode *
 rpc_alloc_inode(struct super_block *sb)
 {
 	struct rpc_inode *rpci;
-	rpci = kmem_cache_alloc(rpc_inode_cachep, GFP_KERNEL);
+	rpci = kmem_cache_alloc(rpc_inode_cachep, GFP_KERNEL_ACCOUNT);
 	if (!rpci)
 		return NULL;
 	return &rpci->vfs_inode;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
