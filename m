Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 09C486B0259
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 13:35:02 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so4473707pab.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:35:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id jx8si6571201pbc.233.2015.11.10.10.35.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 10:35:00 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 6/6] Account certain kmem allocations to memcg
Date: Tue, 10 Nov 2015 21:34:07 +0300
Message-ID: <3af491b9661b97708ec38e9f9a4f0cccb69ade5c.1447172835.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1447172835.git.vdavydov@virtuozzo.com>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

This patch marks those kmem allocations that are known to be easily
triggered from userspace as __GFP_ACCOUNT/SLAB_ACCOUNT, which makes them
accounted to memcg. For the list, see below:

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
   most filesystems overwrite the alloc_inode method.

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
 fs/9p/v9fs.c                                  |  2 +-
 fs/adfs/super.c                               |  2 +-
 fs/affs/super.c                               |  2 +-
 fs/afs/super.c                                |  2 +-
 fs/befs/linuxvfs.c                            |  2 +-
 fs/bfs/inode.c                                |  2 +-
 fs/block_dev.c                                |  2 +-
 fs/btrfs/inode.c                              |  3 ++-
 fs/ceph/super.c                               |  4 ++--
 fs/cifs/cifsfs.c                              |  2 +-
 fs/coda/inode.c                               |  6 +++---
 fs/dcache.c                                   |  5 +++--
 fs/ecryptfs/main.c                            |  6 ++++--
 fs/efs/super.c                                |  6 +++---
 fs/exofs/super.c                              |  4 ++--
 fs/ext2/super.c                               |  2 +-
 fs/ext4/super.c                               |  2 +-
 fs/f2fs/super.c                               |  5 +++--
 fs/fat/inode.c                                |  2 +-
 fs/file.c                                     |  7 ++++---
 fs/fuse/inode.c                               |  4 ++--
 fs/gfs2/main.c                                |  3 ++-
 fs/hfs/super.c                                |  4 ++--
 fs/hfsplus/super.c                            |  2 +-
 fs/hostfs/hostfs_kern.c                       |  2 +-
 fs/hpfs/super.c                               |  2 +-
 fs/hugetlbfs/inode.c                          |  2 +-
 fs/inode.c                                    |  2 +-
 fs/isofs/inode.c                              |  2 +-
 fs/jffs2/super.c                              |  2 +-
 fs/jfs/super.c                                |  2 +-
 fs/logfs/inode.c                              |  3 ++-
 fs/minix/inode.c                              |  2 +-
 fs/ncpfs/inode.c                              |  2 +-
 fs/nfs/inode.c                                |  2 +-
 fs/nilfs2/super.c                             |  3 ++-
 fs/ntfs/super.c                               |  4 ++--
 fs/ocfs2/dlmfs/dlmfs.c                        |  2 +-
 fs/ocfs2/super.c                              |  2 +-
 fs/openpromfs/inode.c                         |  2 +-
 fs/proc/inode.c                               |  3 ++-
 fs/qnx4/inode.c                               |  2 +-
 fs/qnx6/inode.c                               |  2 +-
 fs/reiserfs/super.c                           |  3 ++-
 fs/romfs/super.c                              |  4 ++--
 fs/squashfs/super.c                           |  3 ++-
 fs/sysv/inode.c                               |  2 +-
 fs/ubifs/super.c                              |  4 ++--
 fs/udf/super.c                                |  3 ++-
 fs/ufs/super.c                                |  2 +-
 fs/xfs/kmem.h                                 |  1 +
 fs/xfs/xfs_super.c                            |  4 ++--
 include/linux/thread_info.h                   |  5 +++--
 ipc/mqueue.c                                  |  2 +-
 kernel/cred.c                                 |  4 ++--
 kernel/delayacct.c                            |  2 +-
 kernel/fork.c                                 | 22 +++++++++++++---------
 kernel/pid.c                                  |  2 +-
 mm/nommu.c                                    |  2 +-
 mm/rmap.c                                     |  6 ++++--
 mm/shmem.c                                    |  2 +-
 net/socket.c                                  |  2 +-
 net/sunrpc/rpc_pipe.c                         |  2 +-
 65 files changed, 114 insertions(+), 92 deletions(-)

diff --git a/arch/powerpc/platforms/cell/spufs/inode.c b/arch/powerpc/platforms/cell/spufs/inode.c
index 11634fa7ab3c..ad4840f86be1 100644
--- a/arch/powerpc/platforms/cell/spufs/inode.c
+++ b/arch/powerpc/platforms/cell/spufs/inode.c
@@ -767,7 +767,7 @@ static int __init spufs_init(void)
 	ret = -ENOMEM;
 	spufs_inode_cache = kmem_cache_create("spufs_inode_cache",
 			sizeof(struct spufs_inode_info), 0,
-			SLAB_HWCACHE_ALIGN, spufs_init_once);
+			SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT, spufs_init_once);
 
 	if (!spufs_inode_cache)
 		goto out;
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 013136860664..60828d692db4 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -106,7 +106,8 @@ static int __init init_lustre_lite(void)
 	rc = -ENOMEM;
 	ll_inode_cachep = kmem_cache_create("lustre_inode_cache",
 					    sizeof(struct ll_inode_info),
-					    0, SLAB_HWCACHE_ALIGN, NULL);
+					    0, SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
+					    NULL);
 	if (ll_inode_cachep == NULL)
 		goto out_cache;
 
diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index 6caca025019d..072e7599583a 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -575,7 +575,7 @@ static int v9fs_init_inode_cache(void)
 	v9fs_inode_cache = kmem_cache_create("v9fs_inode_cache",
 					  sizeof(struct v9fs_inode),
 					  0, (SLAB_RECLAIM_ACCOUNT|
-					      SLAB_MEM_SPREAD),
+					      SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					  v9fs_inode_init_once);
 	if (!v9fs_inode_cache)
 		return -ENOMEM;
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index 4d4a0df8344f..c9fdfb112933 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -271,7 +271,7 @@ static int __init init_inodecache(void)
 	adfs_inode_cachep = kmem_cache_create("adfs_inode_cache",
 					     sizeof(struct adfs_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (adfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/affs/super.c b/fs/affs/super.c
index 5b50c4ca43a7..84a84fcb5f5a 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -132,7 +132,7 @@ static int __init init_inodecache(void)
 	affs_inode_cachep = kmem_cache_create("affs_inode_cache",
 					     sizeof(struct affs_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (affs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 1fb4a5129f7d..81afefe7d8a6 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -91,7 +91,7 @@ int __init afs_fs_init(void)
 	afs_inode_cachep = kmem_cache_create("afs_inode_cache",
 					     sizeof(struct afs_vnode),
 					     0,
-					     SLAB_HWCACHE_ALIGN,
+					     SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
 					     afs_i_init_once);
 	if (!afs_inode_cachep) {
 		printk(KERN_NOTICE "kAFS: Failed to allocate inode cache\n");
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 46aedacfa6a8..2a23edf5703e 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -434,7 +434,7 @@ befs_init_inodecache(void)
 	befs_inode_cachep = kmem_cache_create("befs_inode_cache",
 					      sizeof (struct befs_inode_info),
 					      0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					      init_once);
 	if (befs_inode_cachep == NULL) {
 		pr_err("%s: Couldn't initialize inode slabcache\n", __func__);
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index fdcb4d69f430..1e5c896f6b79 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -270,7 +270,7 @@ static int __init init_inodecache(void)
 	bfs_inode_cachep = kmem_cache_create("bfs_inode_cache",
 					     sizeof(struct bfs_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (bfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 0a793c7930eb..29ce98bfe04f 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -567,7 +567,7 @@ void __init bdev_cache_init(void)
 
 	bdev_cachep = kmem_cache_create("bdev_cache", sizeof(struct bdev_inode),
 			0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-				SLAB_MEM_SPREAD|SLAB_PANIC),
+				SLAB_MEM_SPREAD|SLAB_ACCOUNT|SLAB_PANIC),
 			init_once);
 	err = register_filesystem(&bd_type);
 	if (err)
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 4439fbb4ff45..c24d4cd9c14f 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -9157,7 +9157,8 @@ int btrfs_init_cachep(void)
 {
 	btrfs_inode_cachep = kmem_cache_create("btrfs_inode",
 			sizeof(struct btrfs_inode), 0,
-			SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD, init_once);
+			SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD | SLAB_ACCOUNT,
+			init_once);
 	if (!btrfs_inode_cachep)
 		goto fail;
 
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index f446afada328..ca4d5e8457f1 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -639,8 +639,8 @@ static int __init init_caches(void)
 	ceph_inode_cachep = kmem_cache_create("ceph_inode_info",
 				      sizeof(struct ceph_inode_info),
 				      __alignof__(struct ceph_inode_info),
-				      (SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD),
-				      ceph_inode_init_once);
+				      SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+				      SLAB_ACCOUNT, ceph_inode_init_once);
 	if (ceph_inode_cachep == NULL)
 		return -ENOMEM;
 
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index e739950ca084..7f2e2639d1d1 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1040,7 +1040,7 @@ cifs_init_inodecache(void)
 	cifs_inode_cachep = kmem_cache_create("cifs_inode_cache",
 					      sizeof(struct cifsInodeInfo),
 					      0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					      cifs_init_once);
 	if (cifs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index cac1390b87a3..57e81cbba0fa 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -74,9 +74,9 @@ static void init_once(void *foo)
 int __init coda_init_inodecache(void)
 {
 	coda_inode_cachep = kmem_cache_create("coda_inode_cache",
-				sizeof(struct coda_inode_info),
-				0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-				init_once);
+				sizeof(struct coda_inode_info), 0,
+				SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+				SLAB_ACCOUNT, init_once);
 	if (coda_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/dcache.c b/fs/dcache.c
index 5c33aeb0f68f..7ac590912106 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
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
@@ -3415,7 +3416,7 @@ static void __init dcache_init(void)
 	 * of the dcache. 
 	 */
 	dentry_cache = KMEM_CACHE(dentry,
-		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
+		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/fs/ecryptfs/main.c b/fs/ecryptfs/main.c
index 4f4d0474bee9..e25b6b06bacf 100644
--- a/fs/ecryptfs/main.c
+++ b/fs/ecryptfs/main.c
@@ -663,6 +663,7 @@ static struct ecryptfs_cache_info {
 	struct kmem_cache **cache;
 	const char *name;
 	size_t size;
+	unsigned long flags;
 	void (*ctor)(void *obj);
 } ecryptfs_cache_infos[] = {
 	{
@@ -684,6 +685,7 @@ static struct ecryptfs_cache_info {
 		.cache = &ecryptfs_inode_info_cache,
 		.name = "ecryptfs_inode_cache",
 		.size = sizeof(struct ecryptfs_inode_info),
+		.flags = SLAB_ACCOUNT,
 		.ctor = inode_info_init_once,
 	},
 	{
@@ -755,8 +757,8 @@ static int ecryptfs_init_kmem_caches(void)
 		struct ecryptfs_cache_info *info;
 
 		info = &ecryptfs_cache_infos[i];
-		*(info->cache) = kmem_cache_create(info->name, info->size,
-				0, SLAB_HWCACHE_ALIGN, info->ctor);
+		*(info->cache) = kmem_cache_create(info->name, info->size, 0,
+				SLAB_HWCACHE_ALIGN | info->flags, info->ctor);
 		if (!*(info->cache)) {
 			ecryptfs_free_kmem_caches();
 			ecryptfs_printk(KERN_WARNING, "%s: "
diff --git a/fs/efs/super.c b/fs/efs/super.c
index c8411a30f7da..cb68dac4f9d3 100644
--- a/fs/efs/super.c
+++ b/fs/efs/super.c
@@ -94,9 +94,9 @@ static void init_once(void *foo)
 static int __init init_inodecache(void)
 {
 	efs_inode_cachep = kmem_cache_create("efs_inode_cache",
-				sizeof(struct efs_inode_info),
-				0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-				init_once);
+				sizeof(struct efs_inode_info), 0,
+				SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+				SLAB_ACCOUNT, init_once);
 	if (efs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index b795c567b5e1..6658a50530a0 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -194,8 +194,8 @@ static int init_inodecache(void)
 {
 	exofs_inode_cachep = kmem_cache_create("exofs_inode_cache",
 				sizeof(struct exofs_i_info), 0,
-				SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD,
-				exofs_init_once);
+				SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD |
+				SLAB_ACCOUNT, exofs_init_once);
 	if (exofs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 900e19cf9ef6..973092a32b98 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -200,7 +200,7 @@ static int __init init_inodecache(void)
 	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
 					     sizeof(struct ext2_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (ext2_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 04d0f1b33409..c4a5c415b881 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -966,7 +966,7 @@ static int __init init_inodecache(void)
 	ext4_inode_cachep = kmem_cache_create("ext4_inode_cache",
 					     sizeof(struct ext4_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 3a65e0132352..862916c7e3f8 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1424,8 +1424,9 @@ MODULE_ALIAS_FS("f2fs");
 
 static int __init init_inodecache(void)
 {
-	f2fs_inode_cachep = f2fs_kmem_cache_create("f2fs_inode_cache",
-			sizeof(struct f2fs_inode_info));
+	f2fs_inode_cachep = kmem_cache_create("f2fs_inode_cache",
+			sizeof(struct f2fs_inode_info), 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_ACCOUNT, NULL);
 	if (!f2fs_inode_cachep)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 509411dd3698..6aece96df19f 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -677,7 +677,7 @@ static int __init fat_init_inodecache(void)
 	fat_inode_cachep = kmem_cache_create("fat_inode_cache",
 					     sizeof(struct msdos_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (fat_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/file.c b/fs/file.c
index 39f8f15921da..7d76c929d557 100644
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
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 2913db2a5b99..4d69d5c0bedc 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1255,8 +1255,8 @@ static int __init fuse_fs_init(void)
 	int err;
 
 	fuse_inode_cachep = kmem_cache_create("fuse_inode",
-					      sizeof(struct fuse_inode),
-					      0, SLAB_HWCACHE_ALIGN,
+					      sizeof(struct fuse_inode), 0,
+					      SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
 					      fuse_inode_init_once);
 	err = -ENOMEM;
 	if (!fuse_inode_cachep)
diff --git a/fs/gfs2/main.c b/fs/gfs2/main.c
index 241a399bf83d..6ee38e210602 100644
--- a/fs/gfs2/main.c
+++ b/fs/gfs2/main.c
@@ -112,7 +112,8 @@ static int __init init_gfs2_fs(void)
 	gfs2_inode_cachep = kmem_cache_create("gfs2_inode",
 					      sizeof(struct gfs2_inode),
 					      0,  SLAB_RECLAIM_ACCOUNT|
-					          SLAB_MEM_SPREAD,
+					          SLAB_MEM_SPREAD|
+						  SLAB_ACCOUNT,
 					      gfs2_init_inode_once);
 	if (!gfs2_inode_cachep)
 		goto fail;
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index 4574fdd3d421..1ca95c232bb5 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -483,8 +483,8 @@ static int __init init_hfs_fs(void)
 	int err;
 
 	hfs_inode_cachep = kmem_cache_create("hfs_inode_cache",
-		sizeof(struct hfs_inode_info), 0, SLAB_HWCACHE_ALIGN,
-		hfs_init_once);
+		sizeof(struct hfs_inode_info), 0,
+		SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT, hfs_init_once);
 	if (!hfs_inode_cachep)
 		return -ENOMEM;
 	err = register_filesystem(&hfs_fs_type);
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 7302d96ae8bf..5d54490a136d 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -663,7 +663,7 @@ static int __init init_hfsplus_fs(void)
 	int err;
 
 	hfsplus_inode_cachep = kmem_cache_create("hfsplus_icache",
-		HFSPLUS_INODE_SIZE, 0, SLAB_HWCACHE_ALIGN,
+		HFSPLUS_INODE_SIZE, 0, SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT,
 		hfsplus_init_once);
 	if (!hfsplus_inode_cachep)
 		return -ENOMEM;
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
index a561591896bd..458cf463047b 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -261,7 +261,7 @@ static int init_inodecache(void)
 	hpfs_inode_cachep = kmem_cache_create("hpfs_inode_cache",
 					     sizeof(struct hpfs_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (hpfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb968b65..496add05f380 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1322,7 +1322,7 @@ static int __init init_hugetlbfs_fs(void)
 	error = -ENOMEM;
 	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
 					sizeof(struct hugetlbfs_inode_info),
-					0, 0, init_once);
+					0, SLAB_ACCOUNT, init_once);
 	if (hugetlbfs_inode_cachep == NULL)
 		goto out2;
 
diff --git a/fs/inode.c b/fs/inode.c
index 78a17b8859e1..08c66502f1f4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1882,7 +1882,7 @@ void __init inode_init(void)
 					 sizeof(struct inode),
 					 0,
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
-					 SLAB_MEM_SPREAD),
+					 SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					 init_once);
 
 	/* Hash may have been set up in inode_init_early */
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index d67a16f2a45d..9bc2431d2df8 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -94,7 +94,7 @@ static int __init init_inodecache(void)
 	isofs_inode_cachep = kmem_cache_create("isofs_inode_cache",
 					sizeof(struct iso_inode_info),
 					0, (SLAB_RECLAIM_ACCOUNT|
-					SLAB_MEM_SPREAD),
+					SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					init_once);
 	if (isofs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index d86c5e3176a1..bb080c272149 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -387,7 +387,7 @@ static int __init init_jffs2_fs(void)
 	jffs2_inode_cachep = kmem_cache_create("jffs2_i",
 					     sizeof(struct jffs2_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     jffs2_i_init_once);
 	if (!jffs2_inode_cachep) {
 		pr_err("error: Failed to initialise inode cache\n");
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 4cd9798f4948..6efadc61c15b 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -901,7 +901,7 @@ static int __init init_jfs_fs(void)
 
 	jfs_inode_cachep =
 	    kmem_cache_create("jfs_ip", sizeof(struct jfs_inode_info), 0,
-			    SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			    SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
 			    init_once);
 	if (jfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/logfs/inode.c b/fs/logfs/inode.c
index af49e2d6941a..5d65db2e03f4 100644
--- a/fs/logfs/inode.c
+++ b/fs/logfs/inode.c
@@ -408,7 +408,8 @@ const struct super_operations logfs_super_operations = {
 int logfs_init_inode_cache(void)
 {
 	logfs_inode_cache = kmem_cache_create("logfs_inode_cache",
-			sizeof(struct logfs_inode), 0, SLAB_RECLAIM_ACCOUNT,
+			sizeof(struct logfs_inode), 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_ACCOUNT,
 			logfs_init_once);
 	if (!logfs_inode_cache)
 		return -ENOMEM;
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 086cd0a61e80..5942c3e10fa5 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -91,7 +91,7 @@ static int __init init_inodecache(void)
 	minix_inode_cachep = kmem_cache_create("minix_inode_cache",
 					     sizeof(struct minix_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (minix_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 9605a2f63549..d80446e1a333 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -82,7 +82,7 @@ static int init_inodecache(void)
 	ncp_inode_cachep = kmem_cache_create("ncp_inode_cache",
 					     sizeof(struct ncp_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (ncp_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e10d833..412f888fad13 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1904,7 +1904,7 @@ static int __init nfs_init_inodecache(void)
 	nfs_inode_cachep = kmem_cache_create("nfs_inode_cache",
 					     sizeof(struct nfs_inode),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (nfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index f47585bfeb01..dcf8e2ff3072 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -1419,7 +1419,8 @@ static int __init nilfs_init_cachep(void)
 {
 	nilfs_inode_cachep = kmem_cache_create("nilfs2_inode_cache",
 			sizeof(struct nilfs_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT, nilfs_inode_init_once);
+			SLAB_RECLAIM_ACCOUNT|SLAB_ACCOUNT,
+			nilfs_inode_init_once);
 	if (!nilfs_inode_cachep)
 		goto fail;
 
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index d1a853585b53..2f77f8dfb861 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -3139,8 +3139,8 @@ static int __init init_ntfs_fs(void)
 
 	ntfs_big_inode_cache = kmem_cache_create(ntfs_big_inode_cache_name,
 			sizeof(big_ntfs_inode), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-			ntfs_big_inode_init_once);
+			SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|
+			SLAB_ACCOUNT, ntfs_big_inode_init_once);
 	if (!ntfs_big_inode_cache) {
 		pr_crit("Failed to create %s!\n", ntfs_big_inode_cache_name);
 		goto big_inode_err_out;
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index b5cf27dcb18a..03768bb3aab1 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -638,7 +638,7 @@ static int __init init_dlmfs_fs(void)
 	dlmfs_inode_cache = kmem_cache_create("dlmfs_inode_cache",
 				sizeof(struct dlmfs_inode_private),
 				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-					SLAB_MEM_SPREAD),
+					SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 				dlmfs_init_once);
 	if (!dlmfs_inode_cache) {
 		status = -ENOMEM;
diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 2de4c8a9340c..8ab0fcbc0b86 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -1771,7 +1771,7 @@ static int ocfs2_initialize_mem_caches(void)
 				       sizeof(struct ocfs2_inode_info),
 				       0,
 				       (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 				       ocfs2_inode_init_once);
 	ocfs2_dquot_cachep = kmem_cache_create("ocfs2_dquot_cache",
 					sizeof(struct ocfs2_dquot),
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index 15e4500cda3e..b61b883c8ff8 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -443,7 +443,7 @@ static int __init init_openprom_fs(void)
 					    sizeof(struct op_inode_info),
 					    0,
 					    (SLAB_RECLAIM_ACCOUNT |
-					     SLAB_MEM_SPREAD),
+					     SLAB_MEM_SPREAD | SLAB_ACCOUNT),
 					    op_inode_init_once);
 	if (!op_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index bd95b9fdebb0..561557122dea 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -95,7 +95,8 @@ void __init proc_init_inodecache(void)
 	proc_inode_cachep = kmem_cache_create("proc_inode_cache",
 					     sizeof(struct proc_inode),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_PANIC),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT|
+						SLAB_PANIC),
 					     init_once);
 }
 
diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index c4bcb778886e..f761acdd5a7a 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -364,7 +364,7 @@ static int init_inodecache(void)
 	qnx4_inode_cachep = kmem_cache_create("qnx4_inode_cache",
 					     sizeof(struct qnx4_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (qnx4_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/qnx6/inode.c b/fs/qnx6/inode.c
index 32d2e1a9774c..4f04f00a7e5e 100644
--- a/fs/qnx6/inode.c
+++ b/fs/qnx6/inode.c
@@ -624,7 +624,7 @@ static int init_inodecache(void)
 	qnx6_inode_cachep = kmem_cache_create("qnx6_inode_cache",
 					     sizeof(struct qnx6_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (!qnx6_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 4a62fe8cc3bf..05db7473bcb5 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -626,7 +626,8 @@ static int __init init_inodecache(void)
 						  sizeof(struct
 							 reiserfs_inode_info),
 						  0, (SLAB_RECLAIM_ACCOUNT|
-							SLAB_MEM_SPREAD),
+						      SLAB_MEM_SPREAD|
+						      SLAB_ACCOUNT),
 						  init_once);
 	if (reiserfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 268733cda397..e1113399a6b4 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -618,8 +618,8 @@ static int __init init_romfs_fs(void)
 	romfs_inode_cachep =
 		kmem_cache_create("romfs_i",
 				  sizeof(struct romfs_inode_info), 0,
-				  SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD,
-				  romfs_i_init_once);
+				  SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD |
+				  SLAB_ACCOUNT, romfs_i_init_once);
 
 	if (!romfs_inode_cachep) {
 		pr_err("Failed to initialise inode cache\n");
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 5056babe00df..ea59b475663c 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -420,7 +420,8 @@ static int __init init_inodecache(void)
 {
 	squashfs_inode_cachep = kmem_cache_create("squashfs_inode_cache",
 		sizeof(struct squashfs_inode_info), 0,
-		SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT, init_once);
+		SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_ACCOUNT,
+		init_once);
 
 	return squashfs_inode_cachep ? 0 : -ENOMEM;
 }
diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index 590ad9206e3f..087ed6a1c1df 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -353,7 +353,7 @@ int __init sysv_init_icache(void)
 {
 	sysv_inode_cachep = kmem_cache_create("sysv_inode_cache",
 			sizeof(struct sysv_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
 			init_once);
 	if (!sysv_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 9547a27868ad..9d064789c63a 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2241,8 +2241,8 @@ static int __init ubifs_init(void)
 
 	ubifs_inode_slab = kmem_cache_create("ubifs_inode_slab",
 				sizeof(struct ubifs_inode), 0,
-				SLAB_MEM_SPREAD | SLAB_RECLAIM_ACCOUNT,
-				&inode_slab_ctor);
+				SLAB_MEM_SPREAD | SLAB_RECLAIM_ACCOUNT |
+				SLAB_ACCOUNT, &inode_slab_ctor);
 	if (!ubifs_inode_slab)
 		return -ENOMEM;
 
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 81155b9b445b..9c64a3ca9837 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -179,7 +179,8 @@ static int __init init_inodecache(void)
 	udf_inode_cachep = kmem_cache_create("udf_inode_cache",
 					     sizeof(struct udf_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT |
-						 SLAB_MEM_SPREAD),
+						 SLAB_MEM_SPREAD |
+						 SLAB_ACCOUNT),
 					     init_once);
 	if (!udf_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index f6390eec02ca..442fd52ebffe 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1427,7 +1427,7 @@ static int __init init_inodecache(void)
 	ufs_inode_cachep = kmem_cache_create("ufs_inode_cache",
 					     sizeof(struct ufs_inode_info),
 					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 					     init_once);
 	if (ufs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index cc6b768fc068..d1c66e465ca5 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -84,6 +84,7 @@ kmem_zalloc(size_t size, xfs_km_flags_t flags)
 #define KM_ZONE_HWALIGN	SLAB_HWCACHE_ALIGN
 #define KM_ZONE_RECLAIM	SLAB_RECLAIM_ACCOUNT
 #define KM_ZONE_SPREAD	SLAB_MEM_SPREAD
+#define KM_ZONE_ACCOUNT	SLAB_ACCOUNT
 
 #define kmem_zone	kmem_cache
 #define kmem_zone_t	struct kmem_cache
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 904f637cfa5f..70d5b3072631 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1703,8 +1703,8 @@ xfs_init_zones(void)
 
 	xfs_inode_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_t), "xfs_inode",
-			KM_ZONE_HWALIGN | KM_ZONE_RECLAIM | KM_ZONE_SPREAD,
-			xfs_fs_inode_init_once);
+			KM_ZONE_HWALIGN | KM_ZONE_RECLAIM | KM_ZONE_SPREAD |
+			KM_ZONE_ACCOUNT, xfs_fs_inode_init_once);
 	if (!xfs_inode_zone)
 		goto out_destroy_efi_zone;
 
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
index 161a1807e6ef..f4617cf07069 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1438,7 +1438,7 @@ static int __init init_mqueue_fs(void)
 
 	mqueue_inode_cachep = kmem_cache_create("mqueue_inode_cache",
 				sizeof(struct mqueue_inode_info), 0,
-				SLAB_HWCACHE_ALIGN, init_once);
+				SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT, init_once);
 	if (mqueue_inode_cachep == NULL)
 		return -ENOMEM;
 
diff --git a/kernel/cred.c b/kernel/cred.c
index 71179a09c1d6..0c0cd8a62285 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -569,8 +569,8 @@ EXPORT_SYMBOL(revert_creds);
 void __init cred_init(void)
 {
 	/* allocate a slab in which we can store credentials */
-	cred_jar = kmem_cache_create("cred_jar", sizeof(struct cred),
-				     0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+	cred_jar = kmem_cache_create("cred_jar", sizeof(struct cred), 0,
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT, NULL);
 }
 
 /**
diff --git a/kernel/delayacct.c b/kernel/delayacct.c
index ef90b04d783f..435c14a45118 100644
--- a/kernel/delayacct.c
+++ b/kernel/delayacct.c
@@ -34,7 +34,7 @@ __setup("nodelayacct", delayacct_setup_disable);
 
 void delayacct_init(void)
 {
-	delayacct_cache = KMEM_CACHE(task_delay_info, SLAB_PANIC);
+	delayacct_cache = KMEM_CACHE(task_delay_info, SLAB_PANIC|SLAB_ACCOUNT);
 	delayacct_tsk_init(&init_task);
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index f97f2c449f5c..ff39b78e6e23 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -300,9 +300,9 @@ void __init fork_init(void)
 #define ARCH_MIN_TASKALIGN	L1_CACHE_BYTES
 #endif
 	/* create a slab on which task_structs can be allocated */
-	task_struct_cachep =
-		kmem_cache_create("task_struct", arch_task_struct_size,
-			ARCH_MIN_TASKALIGN, SLAB_PANIC | SLAB_NOTRACK, NULL);
+	task_struct_cachep = kmem_cache_create("task_struct",
+			arch_task_struct_size, ARCH_MIN_TASKALIGN,
+			SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT, NULL);
 #endif
 
 	/* do the arch specific task caches init */
@@ -1851,16 +1851,19 @@ void __init proc_caches_init(void)
 	sighand_cachep = kmem_cache_create("sighand_cache",
 			sizeof(struct sighand_struct), 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU|
-			SLAB_NOTRACK, sighand_ctor);
+			SLAB_NOTRACK|SLAB_ACCOUNT, sighand_ctor);
 	signal_cachep = kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			NULL);
 	files_cachep = kmem_cache_create("files_cache",
 			sizeof(struct files_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			NULL);
 	fs_cachep = kmem_cache_create("fs_cache",
 			sizeof(struct fs_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			NULL);
 	/*
 	 * FIXME! The "sizeof(struct mm_struct)" currently includes the
 	 * whole struct cpumask for the OFFSTACK case. We could change
@@ -1870,8 +1873,9 @@ void __init proc_caches_init(void)
 	 */
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
-	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC);
+			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK|SLAB_ACCOUNT,
+			NULL);
+	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
 	mmap_init();
 	nsproxy_cache_init();
 }
diff --git a/kernel/pid.c b/kernel/pid.c
index ca368793808e..f09b026f5b56 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -604,5 +604,5 @@ void __init pidmap_init(void)
 	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
 
 	init_pid_ns.pid_cachep = KMEM_CACHE(pid,
-			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+			SLAB_HWCACHE_ALIGN | SLAB_PANIC | SLAB_ACCOUNT);
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 92be862c859b..fbf6f0f1d6c9 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -560,7 +560,7 @@ void __init mmap_init(void)
 
 	ret = percpu_counter_init(&vm_committed_as, 0, GFP_KERNEL);
 	VM_BUG_ON(ret);
-	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC);
+	vm_region_jar = KMEM_CACHE(vm_region, SLAB_PANIC|SLAB_ACCOUNT);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index b577fbb98d4b..3c3f1d21f075 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -428,8 +428,10 @@ static void anon_vma_ctor(void *data)
 void __init anon_vma_init(void)
 {
 	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
-			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
-	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain, SLAB_PANIC);
+			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
+			anon_vma_ctor);
+	anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
+			SLAB_PANIC|SLAB_ACCOUNT);
 }
 
 /*
diff --git a/mm/shmem.c b/mm/shmem.c
index 3b8b73928398..882933a7de99 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3107,7 +3107,7 @@ static int shmem_init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
 				sizeof(struct shmem_inode_info),
-				0, SLAB_PANIC, shmem_init_inode);
+				0, SLAB_PANIC|SLAB_ACCOUNT, shmem_init_inode);
 	return 0;
 }
 
diff --git a/net/socket.c b/net/socket.c
index 9963a0b53a64..2d70af8d943f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -293,7 +293,7 @@ static int init_inodecache(void)
 					      0,
 					      (SLAB_HWCACHE_ALIGN |
 					       SLAB_RECLAIM_ACCOUNT |
-					       SLAB_MEM_SPREAD),
+					       SLAB_MEM_SPREAD | SLAB_ACCOUNT),
 					      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index d81186d34558..14f45bf0410c 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1500,7 +1500,7 @@ int register_rpc_pipefs(void)
 	rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
 				sizeof(struct rpc_inode),
 				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+						SLAB_MEM_SPREAD|SLAB_ACCOUNT),
 				init_once);
 	if (!rpc_inode_cachep)
 		return -ENOMEM;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
