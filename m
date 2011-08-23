Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C9E3900138
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 04:56:56 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 01/13] fs: Use a common define for inode slab caches
Date: Tue, 23 Aug 2011 18:56:14 +1000
Message-Id: <1314089786-20535-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1314089786-20535-1-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

From: Dave Chinner <dchinner@redhat.com>

All inode slab cache initialisation calls need to use specific flags
so that certain core functionality works correctly (e.g. reclaimable
memory accounting). Some of these flags are used inconsistently
across different filesystems, so inode cache slab behaviour can vary
according to filesystem type.

Wrap all the SLAB_* flags relevant to inode caches up into a single
SLAB_INODES flag and convert all the inode caches to use the new
flag.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 Documentation/filesystems/porting |    3 +++
 fs/9p/v9fs.c                      |    3 +--
 fs/adfs/super.c                   |    3 +--
 fs/affs/super.c                   |    3 +--
 fs/afs/super.c                    |    7 +++----
 fs/befs/linuxvfs.c                |    3 +--
 fs/bfs/inode.c                    |    3 +--
 fs/btrfs/inode.c                  |    2 +-
 fs/ceph/super.c                   |    3 +--
 fs/cifs/cifsfs.c                  |    3 +--
 fs/coda/inode.c                   |    3 +--
 fs/efs/super.c                    |    3 +--
 fs/exofs/super.c                  |    3 +--
 fs/ext2/super.c                   |    3 +--
 fs/ext3/super.c                   |    3 +--
 fs/ext4/super.c                   |    3 +--
 fs/fat/inode.c                    |    3 +--
 fs/freevxfs/vxfs_super.c          |    2 +-
 fs/fuse/inode.c                   |    6 +++---
 fs/gfs2/main.c                    |    3 +--
 fs/hfs/super.c                    |    3 ++-
 fs/hfsplus/super.c                |    3 ++-
 fs/hpfs/super.c                   |    3 +--
 fs/hugetlbfs/inode.c              |    2 +-
 fs/inode.c                        |    4 +---
 fs/isofs/inode.c                  |    4 +---
 fs/jffs2/super.c                  |    3 +--
 fs/jfs/super.c                    |    3 +--
 fs/logfs/inode.c                  |    2 +-
 fs/minix/inode.c                  |    3 +--
 fs/ncpfs/inode.c                  |    3 +--
 fs/nfs/inode.c                    |    3 +--
 fs/nilfs2/super.c                 |    4 ++--
 fs/ntfs/super.c                   |    3 ++-
 fs/ocfs2/dlmfs/dlmfs.c            |    3 +--
 fs/ocfs2/super.c                  |    4 +---
 fs/openpromfs/inode.c             |    4 +---
 fs/proc/inode.c                   |    3 +--
 fs/qnx4/inode.c                   |    3 +--
 fs/reiserfs/super.c               |    7 ++-----
 fs/romfs/super.c                  |    3 +--
 fs/squashfs/super.c               |    3 ++-
 fs/sysv/inode.c                   |    3 +--
 fs/ubifs/super.c                  |    2 +-
 fs/udf/super.c                    |    3 +--
 fs/ufs/super.c                    |    3 +--
 fs/xfs/kmem.h                     |    1 +
 fs/xfs/xfs_super.c                |    4 ++--
 include/linux/slab.h              |    7 +++++++
 ipc/mqueue.c                      |    3 ++-
 mm/shmem.c                        |    3 ++-
 net/socket.c                      |    9 +++------
 net/sunrpc/rpc_pipe.c             |    5 ++---
 53 files changed, 77 insertions(+), 104 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index b4a3d76..2866bc9 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -352,6 +352,9 @@ protects *all* the dcache state of a given dentry.
 
 --
 [mandatory]
+	Inodes must be allocated via a slab cache created with the
+SLAB_INODE_CACHE flag set. This sets all the necessary slab cache flags for
+correct operation and control of the cache across the system.
 
 	Filesystems must RCU-free their inodes, if they can have been accessed
 via rcu-walk path walk (basically, if the file can have had a path name in the
diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
index ef96618..e899f1d 100644
--- a/fs/9p/v9fs.c
+++ b/fs/9p/v9fs.c
@@ -525,8 +525,7 @@ static int v9fs_init_inode_cache(void)
 {
 	v9fs_inode_cache = kmem_cache_create("v9fs_inode_cache",
 					  sizeof(struct v9fs_inode),
-					  0, (SLAB_RECLAIM_ACCOUNT|
-					      SLAB_MEM_SPREAD),
+					  0, SLAB_INODE_CACHE,
 					  v9fs_inode_init_once);
 	if (!v9fs_inode_cache)
 		return -ENOMEM;
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index c8bf36a..a67095f 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -266,8 +266,7 @@ static int init_inodecache(void)
 {
 	adfs_inode_cachep = kmem_cache_create("adfs_inode_cache",
 					     sizeof(struct adfs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (adfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/affs/super.c b/fs/affs/super.c
index b31507d..fa727c1 100644
--- a/fs/affs/super.c
+++ b/fs/affs/super.c
@@ -120,8 +120,7 @@ static int init_inodecache(void)
 {
 	affs_inode_cachep = kmem_cache_create("affs_inode_cache",
 					     sizeof(struct affs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (affs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 356dcf0..ba7566d 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -86,10 +86,9 @@ int __init afs_fs_init(void)
 
 	ret = -ENOMEM;
 	afs_inode_cachep = kmem_cache_create("afs_inode_cache",
-					     sizeof(struct afs_vnode),
-					     0,
-					     SLAB_HWCACHE_ALIGN,
-					     afs_i_init_once);
+					sizeof(struct afs_vnode), 0,
+					SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
+					afs_i_init_once);
 	if (!afs_inode_cachep) {
 		printk(KERN_NOTICE "kAFS: Failed to allocate inode cache\n");
 		return ret;
diff --git a/fs/befs/linuxvfs.c b/fs/befs/linuxvfs.c
index 720d885..b62654f 100644
--- a/fs/befs/linuxvfs.c
+++ b/fs/befs/linuxvfs.c
@@ -436,8 +436,7 @@ befs_init_inodecache(void)
 {
 	befs_inode_cachep = kmem_cache_create("befs_inode_cache",
 					      sizeof (struct befs_inode_info),
-					      0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					      0, SLAB_INODE_CACHE,
 					      init_once);
 	if (befs_inode_cachep == NULL) {
 		printk(KERN_ERR "befs_init_inodecache: "
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index a8e37f8..6038016 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -271,8 +271,7 @@ static int init_inodecache(void)
 {
 	bfs_inode_cachep = kmem_cache_create("bfs_inode_cache",
 					     sizeof(struct bfs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (bfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 0ccc743..3afa9ca 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -6878,7 +6878,7 @@ int btrfs_init_cachep(void)
 {
 	btrfs_inode_cachep = kmem_cache_create("btrfs_inode_cache",
 			sizeof(struct btrfs_inode), 0,
-			SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD, init_once);
+			SLAB_INODE_CACHE, init_once);
 	if (!btrfs_inode_cachep)
 		goto fail;
 
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index d47c5ec..79b7ff3 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -532,8 +532,7 @@ static int __init init_caches(void)
 	ceph_inode_cachep = kmem_cache_create("ceph_inode_info",
 				      sizeof(struct ceph_inode_info),
 				      __alignof__(struct ceph_inode_info),
-				      (SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD),
-				      ceph_inode_init_once);
+				      SLAB_INODE_CACHE, ceph_inode_init_once);
 	if (ceph_inode_cachep == NULL)
 		return -ENOMEM;
 
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index f93eb94..c33fb7e 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -948,8 +948,7 @@ cifs_init_inodecache(void)
 {
 	cifs_inode_cachep = kmem_cache_create("cifs_inode_cache",
 					      sizeof(struct cifsInodeInfo),
-					      0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					      0, SLAB_INODE_CACHE,
 					      cifs_init_once);
 	if (cifs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index 871b277..0a31da6 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -78,8 +78,7 @@ int coda_init_inodecache(void)
 {
 	coda_inode_cachep = kmem_cache_create("coda_inode_cache",
 				sizeof(struct coda_inode_info),
-				0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-				init_once);
+				0, SLAB_INODE_CACHE, init_once);
 	if (coda_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/efs/super.c b/fs/efs/super.c
index 0f31acb..ff87da4 100644
--- a/fs/efs/super.c
+++ b/fs/efs/super.c
@@ -88,8 +88,7 @@ static int init_inodecache(void)
 {
 	efs_inode_cachep = kmem_cache_create("efs_inode_cache",
 				sizeof(struct efs_inode_info),
-				0, SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-				init_once);
+				0, SLAB_INODE_CACHE, init_once);
 	if (efs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 2748940..07f0023 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -194,8 +194,7 @@ static int init_inodecache(void)
 {
 	exofs_inode_cachep = kmem_cache_create("exofs_inode_cache",
 				sizeof(struct exofs_i_info), 0,
-				SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD,
-				exofs_init_once);
+				SLAB_INODE_CACHE, exofs_init_once);
 	if (exofs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 1dd62ed..9d5d7a7 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -198,8 +198,7 @@ static int init_inodecache(void)
 {
 	ext2_inode_cachep = kmem_cache_create("ext2_inode_cache",
 					     sizeof(struct ext2_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (ext2_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index 7beb69a..8c4c9e1 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -544,8 +544,7 @@ static int init_inodecache(void)
 {
 	ext3_inode_cachep = kmem_cache_create("ext3_inode_cache",
 					     sizeof(struct ext3_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (ext3_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 44d0c8d..738d64a 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -947,8 +947,7 @@ static int init_inodecache(void)
 {
 	ext4_inode_cachep = kmem_cache_create("ext4_inode_cache",
 					     sizeof(struct ext4_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (ext4_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 1726d73..3316e5d 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -543,8 +543,7 @@ static int __init fat_init_inodecache(void)
 {
 	fat_inode_cachep = kmem_cache_create("fat_inode_cache",
 					     sizeof(struct msdos_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (fat_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/freevxfs/vxfs_super.c b/fs/freevxfs/vxfs_super.c
index 9d1c995..225f18a 100644
--- a/fs/freevxfs/vxfs_super.c
+++ b/fs/freevxfs/vxfs_super.c
@@ -267,7 +267,7 @@ vxfs_init(void)
 
 	vxfs_inode_cachep = kmem_cache_create("vxfs_inode",
 			sizeof(struct vxfs_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD, NULL);
+			SLAB_INODE_CACHE, NULL);
 	if (!vxfs_inode_cachep)
 		return -ENOMEM;
 	rv = register_filesystem(&vxfs_fs_type);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 38f84cd..55ad0a1 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1138,9 +1138,9 @@ static int __init fuse_fs_init(void)
 		goto out_unreg;
 
 	fuse_inode_cachep = kmem_cache_create("fuse_inode",
-					      sizeof(struct fuse_inode),
-					      0, SLAB_HWCACHE_ALIGN,
-					      fuse_inode_init_once);
+					sizeof(struct fuse_inode), 0,
+					SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
+					fuse_inode_init_once);
 	err = -ENOMEM;
 	if (!fuse_inode_cachep)
 		goto out_unreg2;
diff --git a/fs/gfs2/main.c b/fs/gfs2/main.c
index 8a139ff..8ea7747 100644
--- a/fs/gfs2/main.c
+++ b/fs/gfs2/main.c
@@ -105,8 +105,7 @@ static int __init init_gfs2_fs(void)
 
 	gfs2_inode_cachep = kmem_cache_create("gfs2_inode",
 					      sizeof(struct gfs2_inode),
-					      0,  SLAB_RECLAIM_ACCOUNT|
-					          SLAB_MEM_SPREAD,
+					      0, SLAB_INODE_CACHE,
 					      gfs2_init_inode_once);
 	if (!gfs2_inode_cachep)
 		goto fail;
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index 1b55f70..789f74c 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -473,7 +473,8 @@ static int __init init_hfs_fs(void)
 	int err;
 
 	hfs_inode_cachep = kmem_cache_create("hfs_inode_cache",
-		sizeof(struct hfs_inode_info), 0, SLAB_HWCACHE_ALIGN,
+		sizeof(struct hfs_inode_info), 0,
+		SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
 		hfs_init_once);
 	if (!hfs_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index c106ca2..fc88368 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -590,7 +590,8 @@ static int __init init_hfsplus_fs(void)
 	int err;
 
 	hfsplus_inode_cachep = kmem_cache_create("hfsplus_icache",
-		HFSPLUS_INODE_SIZE, 0, SLAB_HWCACHE_ALIGN,
+		HFSPLUS_INODE_SIZE, 0,
+		SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
 		hfsplus_init_once);
 	if (!hfsplus_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/hpfs/super.c b/fs/hpfs/super.c
index 98580a3..3de3965 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -201,8 +201,7 @@ static int init_inodecache(void)
 {
 	hpfs_inode_cachep = kmem_cache_create("hpfs_inode_cache",
 					     sizeof(struct hpfs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (hpfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 87b6e04..1644d5f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1002,7 +1002,7 @@ static int __init init_hugetlbfs_fs(void)
 
 	hugetlbfs_inode_cachep = kmem_cache_create("hugetlbfs_inode_cache",
 					sizeof(struct hugetlbfs_inode_info),
-					0, 0, init_once);
+					0, SLAB_INODE_CACHE, init_once);
 	if (hugetlbfs_inode_cachep == NULL)
 		goto out2;
 
diff --git a/fs/inode.c b/fs/inode.c
index 73920d5..848808f 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1591,9 +1591,7 @@ void __init inode_init(void)
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache",
 					 sizeof(struct inode),
-					 0,
-					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
-					 SLAB_MEM_SPREAD),
+					 0, SLAB_INODE_CACHE | SLAB_PANIC,
 					 init_once);
 
 	/* Hash may have been set up in inode_init_early */
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index a5d0367..237dbc9 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -104,9 +104,7 @@ static int init_inodecache(void)
 {
 	isofs_inode_cachep = kmem_cache_create("isofs_inode_cache",
 					sizeof(struct iso_inode_info),
-					0, (SLAB_RECLAIM_ACCOUNT|
-					SLAB_MEM_SPREAD),
-					init_once);
+					0, SLAB_INODE_CACHE, init_once);
 	if (isofs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/jffs2/super.c b/fs/jffs2/super.c
index 853b8e3..3c9dbe8 100644
--- a/fs/jffs2/super.c
+++ b/fs/jffs2/super.c
@@ -266,8 +266,7 @@ static int __init init_jffs2_fs(void)
 
 	jffs2_inode_cachep = kmem_cache_create("jffs2_i",
 					     sizeof(struct jffs2_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     jffs2_i_init_once);
 	if (!jffs2_inode_cachep) {
 		printk(KERN_ERR "JFFS2 error: Failed to initialise inode cache\n");
diff --git a/fs/jfs/super.c b/fs/jfs/super.c
index 06c8a67..31a52a6 100644
--- a/fs/jfs/super.c
+++ b/fs/jfs/super.c
@@ -803,8 +803,7 @@ static int __init init_jfs_fs(void)
 
 	jfs_inode_cachep =
 	    kmem_cache_create("jfs_ip", sizeof(struct jfs_inode_info), 0,
-			    SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
-			    init_once);
+					     SLAB_INODE_CACHE, init_once);
 	if (jfs_inode_cachep == NULL)
 		return -ENOMEM;
 
diff --git a/fs/logfs/inode.c b/fs/logfs/inode.c
index edfea7a..cb96b72 100644
--- a/fs/logfs/inode.c
+++ b/fs/logfs/inode.c
@@ -392,7 +392,7 @@ const struct super_operations logfs_super_operations = {
 int logfs_init_inode_cache(void)
 {
 	logfs_inode_cache = kmem_cache_create("logfs_inode_cache",
-			sizeof(struct logfs_inode), 0, SLAB_RECLAIM_ACCOUNT,
+			sizeof(struct logfs_inode), 0, SLAB_INODE_CACHE,
 			logfs_init_once);
 	if (!logfs_inode_cache)
 		return -ENOMEM;
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index e7d23e2..4535e83 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -91,8 +91,7 @@ static int init_inodecache(void)
 {
 	minix_inode_cachep = kmem_cache_create("minix_inode_cache",
 					     sizeof(struct minix_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (minix_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 202f370..66add22 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -81,8 +81,7 @@ static int init_inodecache(void)
 {
 	ncp_inode_cachep = kmem_cache_create("ncp_inode_cache",
 					     sizeof(struct ncp_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (ncp_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..ee8bd18 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1506,8 +1506,7 @@ static int __init nfs_init_inodecache(void)
 {
 	nfs_inode_cachep = kmem_cache_create("nfs_inode_cache",
 					     sizeof(struct nfs_inode),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (nfs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/nilfs2/super.c b/fs/nilfs2/super.c
index 8351c44..f6025c1 100644
--- a/fs/nilfs2/super.c
+++ b/fs/nilfs2/super.c
@@ -1401,8 +1401,8 @@ static void nilfs_destroy_cachep(void)
 static int __init nilfs_init_cachep(void)
 {
 	nilfs_inode_cachep = kmem_cache_create("nilfs2_inode_cache",
-			sizeof(struct nilfs_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT, nilfs_inode_init_once);
+			sizeof(struct nilfs_inode_info), 0, SLAB_INODE_CACHE,
+			nilfs_inode_init_once);
 	if (!nilfs_inode_cachep)
 		goto fail;
 
diff --git a/fs/ntfs/super.c b/fs/ntfs/super.c
index b52706d..97ad840 100644
--- a/fs/ntfs/super.c
+++ b/fs/ntfs/super.c
@@ -3136,9 +3136,10 @@ static int __init init_ntfs_fs(void)
 		goto inode_err_out;
 	}
 
+	/* ntfs_big_inode_cache is the inode cache used for VFS level inodes */
 	ntfs_big_inode_cache = kmem_cache_create(ntfs_big_inode_cache_name,
 			sizeof(big_ntfs_inode), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
 			ntfs_big_inode_init_once);
 	if (!ntfs_big_inode_cache) {
 		printk(KERN_CRIT "NTFS: Failed to create %s!\n",
diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index b420767..f6c762d 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -676,8 +676,7 @@ static int __init init_dlmfs_fs(void)
 
 	dlmfs_inode_cache = kmem_cache_create("dlmfs_inode_cache",
 				sizeof(struct dlmfs_inode_private),
-				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-					SLAB_MEM_SPREAD),
+				0, (SLAB_HWCACHE_ALIGN|SLAB_INODE_CACHE),
 				dlmfs_init_once);
 	if (!dlmfs_inode_cache) {
 		status = -ENOMEM;
diff --git a/fs/ocfs2/super.c b/fs/ocfs2/super.c
index 56f6102..f4d0a0f 100644
--- a/fs/ocfs2/super.c
+++ b/fs/ocfs2/super.c
@@ -1784,9 +1784,7 @@ static int ocfs2_initialize_mem_caches(void)
 {
 	ocfs2_inode_cachep = kmem_cache_create("ocfs2_inode_cache",
 				       sizeof(struct ocfs2_inode_info),
-				       0,
-				       (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+				       0, (SLAB_HWCACHE_ALIGN|SLAB_INODE_CACHE),
 				       ocfs2_inode_init_once);
 	ocfs2_dquot_cachep = kmem_cache_create("ocfs2_dquot_cache",
 					sizeof(struct ocfs2_dquot),
diff --git a/fs/openpromfs/inode.c b/fs/openpromfs/inode.c
index a2a5bff..3aea1e8 100644
--- a/fs/openpromfs/inode.c
+++ b/fs/openpromfs/inode.c
@@ -448,9 +448,7 @@ static int __init init_openprom_fs(void)
 
 	op_inode_cachep = kmem_cache_create("op_inode_cache",
 					    sizeof(struct op_inode_info),
-					    0,
-					    (SLAB_RECLAIM_ACCOUNT |
-					     SLAB_MEM_SPREAD),
+					    0, SLAB_INODE_CACHE,
 					    op_inode_init_once);
 	if (!op_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 7ed72d6..9794661 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -97,8 +97,7 @@ void __init proc_init_inodecache(void)
 {
 	proc_inode_cachep = kmem_cache_create("proc_inode_cache",
 					     sizeof(struct proc_inode),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD|SLAB_PANIC),
+					     0, SLAB_INODE_CACHE | SLAB_PANIC,
 					     init_once);
 }
 
diff --git a/fs/qnx4/inode.c b/fs/qnx4/inode.c
index 2b06466..7b77dd1 100644
--- a/fs/qnx4/inode.c
+++ b/fs/qnx4/inode.c
@@ -447,8 +447,7 @@ static int init_inodecache(void)
 {
 	qnx4_inode_cachep = kmem_cache_create("qnx4_inode_cache",
 					     sizeof(struct qnx4_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (qnx4_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/reiserfs/super.c b/fs/reiserfs/super.c
index 14363b9..5ba7c0d 100644
--- a/fs/reiserfs/super.c
+++ b/fs/reiserfs/super.c
@@ -552,11 +552,8 @@ static void init_once(void *foo)
 static int init_inodecache(void)
 {
 	reiserfs_inode_cachep = kmem_cache_create("reiser_inode_cache",
-						  sizeof(struct
-							 reiserfs_inode_info),
-						  0, (SLAB_RECLAIM_ACCOUNT|
-							SLAB_MEM_SPREAD),
-						  init_once);
+					sizeof(struct reiserfs_inode_info),
+					0, SLAB_INODE_CACHE, init_once);
 	if (reiserfs_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/fs/romfs/super.c b/fs/romfs/super.c
index 2305e31..a771db6 100644
--- a/fs/romfs/super.c
+++ b/fs/romfs/super.c
@@ -625,8 +625,7 @@ static int __init init_romfs_fs(void)
 	romfs_inode_cachep =
 		kmem_cache_create("romfs_i",
 				  sizeof(struct romfs_inode_info), 0,
-				  SLAB_RECLAIM_ACCOUNT | SLAB_MEM_SPREAD,
-				  romfs_i_init_once);
+				  SLAB_INODE_CACHE, romfs_i_init_once);
 
 	if (!romfs_inode_cachep) {
 		printk(KERN_ERR
diff --git a/fs/squashfs/super.c b/fs/squashfs/super.c
index 7438850..b21d9ba 100644
--- a/fs/squashfs/super.c
+++ b/fs/squashfs/super.c
@@ -413,7 +413,8 @@ static int __init init_inodecache(void)
 {
 	squashfs_inode_cachep = kmem_cache_create("squashfs_inode_cache",
 		sizeof(struct squashfs_inode_info), 0,
-		SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT, init_once);
+		SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
+		init_once);
 
 	return squashfs_inode_cachep ? 0 : -ENOMEM;
 }
diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index 0630eb9..e3319db 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -367,8 +367,7 @@ const struct super_operations sysv_sops = {
 int __init sysv_init_icache(void)
 {
 	sysv_inode_cachep = kmem_cache_create("sysv_inode_cache",
-			sizeof(struct sysv_inode_info), 0,
-			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD,
+			sizeof(struct sysv_inode_info), 0, SLAB_INODE_CACHE,
 			init_once);
 	if (!sysv_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index b281212..91903f6 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2273,7 +2273,7 @@ static int __init ubifs_init(void)
 	err = -ENOMEM;
 	ubifs_inode_slab = kmem_cache_create("ubifs_inode_slab",
 				sizeof(struct ubifs_inode), 0,
-				SLAB_MEM_SPREAD | SLAB_RECLAIM_ACCOUNT,
+				SLAB_INODE_CACHE,
 				&inode_slab_ctor);
 	if (!ubifs_inode_slab)
 		goto out_reg;
diff --git a/fs/udf/super.c b/fs/udf/super.c
index 7b27b06..b6e9969 100644
--- a/fs/udf/super.c
+++ b/fs/udf/super.c
@@ -163,8 +163,7 @@ static int init_inodecache(void)
 {
 	udf_inode_cachep = kmem_cache_create("udf_inode_cache",
 					     sizeof(struct udf_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT |
-						 SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (!udf_inode_cachep)
 		return -ENOMEM;
diff --git a/fs/ufs/super.c b/fs/ufs/super.c
index 3915ade..0cd3dc0 100644
--- a/fs/ufs/super.c
+++ b/fs/ufs/super.c
@@ -1445,8 +1445,7 @@ static int init_inodecache(void)
 {
 	ufs_inode_cachep = kmem_cache_create("ufs_inode_cache",
 					     sizeof(struct ufs_inode_info),
-					     0, (SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+					     0, SLAB_INODE_CACHE,
 					     init_once);
 	if (ufs_inode_cachep == NULL)
 		return -ENOMEM;
diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
index f7c8f7a..4e6b372 100644
--- a/fs/xfs/kmem.h
+++ b/fs/xfs/kmem.h
@@ -82,6 +82,7 @@ extern void *kmem_zalloc_greedy(size_t *, size_t, size_t);
 #define KM_ZONE_HWALIGN	SLAB_HWCACHE_ALIGN
 #define KM_ZONE_RECLAIM	SLAB_RECLAIM_ACCOUNT
 #define KM_ZONE_SPREAD	SLAB_MEM_SPREAD
+#define KM_ZONE_INODES	SLAB_INODE_CACHE
 
 #define kmem_zone	kmem_cache
 #define kmem_zone_t	struct kmem_cache
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 9a72dda..c94ec22 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1589,8 +1589,8 @@ xfs_init_zones(void)
 
 	xfs_inode_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_t), "xfs_inode",
-			KM_ZONE_HWALIGN | KM_ZONE_RECLAIM | KM_ZONE_SPREAD,
-			xfs_fs_inode_init_once);
+					KM_ZONE_HWALIGN | KM_ZONE_INODES,
+					xfs_fs_inode_init_once);
 	if (!xfs_inode_zone)
 		goto out_destroy_efi_zone;
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 573c809..9d4a5b8 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -93,6 +93,13 @@
 				(unsigned long)ZERO_SIZE_PTR)
 
 /*
+ * Set the default flags necessary for inode caches manipulated by the VFS.
+ */
+#define SLAB_INODE_CACHE	(SLAB_MEM_SPREAD | \
+				 SLAB_DESTROY_BY_RCU | \
+				 SLAB_RECLAIM_ACCOUNT)
+
+/*
  * struct kmem_cache related prototypes
  */
 void __init kmem_cache_init(void);
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index ed049ea..512b1b2 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1278,7 +1278,8 @@ static int __init init_mqueue_fs(void)
 
 	mqueue_inode_cachep = kmem_cache_create("mqueue_inode_cache",
 				sizeof(struct mqueue_inode_info), 0,
-				SLAB_HWCACHE_ALIGN, init_once);
+				SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
+				init_once);
 	if (mqueue_inode_cachep == NULL)
 		return -ENOMEM;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 32f6763..98bfa2e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2249,7 +2249,8 @@ static int shmem_init_inodecache(void)
 {
 	shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
 				sizeof(struct shmem_inode_info),
-				0, SLAB_PANIC, shmem_init_inode);
+				0, SLAB_INODE_CACHE|SLAB_PANIC,
+				shmem_init_inode);
 	return 0;
 }
 
diff --git a/net/socket.c b/net/socket.c
index 24a7740..4ade5bf 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -284,12 +284,9 @@ static void init_once(void *foo)
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
-					      sizeof(struct socket_alloc),
-					      0,
-					      (SLAB_HWCACHE_ALIGN |
-					       SLAB_RECLAIM_ACCOUNT |
-					       SLAB_MEM_SPREAD),
-					      init_once);
+			      sizeof(struct socket_alloc), 0,
+			      SLAB_HWCACHE_ALIGN | SLAB_INODE_CACHE,
+			      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index b181e34..53f0dd6 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1064,9 +1064,8 @@ int register_rpc_pipefs(void)
 	int err;
 
 	rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
-				sizeof(struct rpc_inode),
-				0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-						SLAB_MEM_SPREAD),
+				sizeof(struct rpc_inode), 0,
+				SLAB_HWCACHE_ALIGN|SLAB_INODE_CACHE,
 				init_once);
 	if (!rpc_inode_cachep)
 		return -ENOMEM;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
