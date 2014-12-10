Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id ED5E56B0073
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 20:46:47 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so1732526pde.1
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:47 -0800 (PST)
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com. [209.85.220.52])
        by mx.google.com with ESMTPS id hb6si4281721pbc.194.2014.12.09.17.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 17:46:46 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so1713588pac.25
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 17:46:45 -0800 (PST)
From: Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH v3 5/7] btrfs: prevent ioctls from interfering with a swap file
Date: Tue,  9 Dec 2014 17:45:46 -0800
Message-Id: <a0ff3435124c2150effb6681d529d56032c711f8.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
In-Reply-To: <cover.1418173063.git.osandov@osandov.com>
References: <cover.1418173063.git.osandov@osandov.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Omar Sandoval <osandov@osandov.com>

There are several ioctls which can work around constraints enforced by
btrfs_swap_activate and lead to an unsafe situation. We cannot do any of
the following on an active swap file in order to avoid creating
compressed or shared extents:

- chattr -C or +c
- snapshot create
- defrag
- clone
- dedup

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 fs/btrfs/ctree.h   |  3 +++
 fs/btrfs/disk-io.c |  1 +
 fs/btrfs/ioctl.c   | 35 +++++++++++++++++++++++++++++++----
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/btrfs/ctree.h b/fs/btrfs/ctree.h
index fe69edd..38979b9 100644
--- a/fs/btrfs/ctree.h
+++ b/fs/btrfs/ctree.h
@@ -1891,6 +1891,9 @@ struct btrfs_root {
 	int send_in_progress;
 	struct btrfs_subvolume_writers *subv_writers;
 	atomic_t will_be_snapshoted;
+
+	/* Number of active swapfiles */
+	atomic_t nr_swapfiles;
 };
 
 struct btrfs_ioctl_defrag_range_args {
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 1bf9f89..60094c4 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1265,6 +1265,7 @@ static void __setup_root(u32 nodesize, u32 sectorsize, u32 stripesize,
 	atomic_set(&root->orphan_inodes, 0);
 	atomic_set(&root->refs, 1);
 	atomic_set(&root->will_be_snapshoted, 0);
+	atomic_set(&root->nr_swapfiles, 0);
 	root->log_transid = 0;
 	root->log_transid_committed = -1;
 	root->last_log_commit = 0;
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 4399f0c..18fa95c 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -291,9 +291,11 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		} else {
 			ip->flags |= BTRFS_INODE_NODATACOW;
 		}
-	} else {
+	} else if (!IS_SWAPFILE(inode)) {
 		/*
-		 * Revert back under same assuptions as above
+		 * Revert back under same assumptions as above. swap_activate
+		 * checks that we don't swapon a copy-on-write file, but we also
+		 * make sure that it doesn't become copy-on-write here.
 		 */
 		if (S_ISREG(mode)) {
 			if (inode->i_size == 0)
@@ -316,7 +318,12 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 		ret = btrfs_set_prop(inode, "btrfs.compression", NULL, 0, 0);
 		if (ret && ret != -ENODATA)
 			goto out_drop;
-	} else if (flags & FS_COMPR_FL) {
+	} else if (flags & FS_COMPR_FL && !IS_SWAPFILE(inode)) {
+		/*
+		 * Like nodatacow, swap_activate checks that we don't swapon a
+		 * compressed file, so we shouldn't let it become compressed.
+		 */
+
 		const char *comp;
 
 		ip->flags |= BTRFS_INODE_COMPRESS;
@@ -330,7 +337,6 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
 				     comp, strlen(comp), 0);
 		if (ret)
 			goto out_drop;
-
 	} else {
 		ret = btrfs_set_prop(inode, "btrfs.compression", NULL, 0, 0);
 		if (ret && ret != -ENODATA)
@@ -647,6 +653,12 @@ static int create_snapshot(struct btrfs_root *root, struct inode *dir,
 	if (!test_bit(BTRFS_ROOT_REF_COWS, &root->state))
 		return -EINVAL;
 
+	if (atomic_read(&root->nr_swapfiles)) {
+		btrfs_err(root->fs_info,
+			  "cannot create snapshot with active swapfile");
+		return -ETXTBSY;
+	}
+
 	atomic_inc(&root->will_be_snapshoted);
 	smp_mb__after_atomic();
 	btrfs_wait_nocow_write(root);
@@ -1292,6 +1304,12 @@ int btrfs_defrag_file(struct inode *inode, struct file *file,
 			compress_type = range->compress_type;
 	}
 
+	mutex_lock(&inode->i_mutex);
+	ret = IS_SWAPFILE(inode) ? -ETXTBSY : 0;
+	mutex_unlock(&inode->i_mutex);
+	if (ret)
+		return ret;
+
 	if (extent_thresh == 0)
 		extent_thresh = 256 * 1024;
 
@@ -2927,6 +2945,11 @@ static int btrfs_extent_same(struct inode *src, u64 loff, u64 len,
 
 	btrfs_double_lock(src, loff, dst, dst_loff, len);
 
+	if (IS_SWAPFILE(src) || IS_SWAPFILE(dst)) {
+		ret = -ETXTBSY;
+		goto out_unlock;
+	}
+
 	ret = extent_same_check_offsets(src, loff, len);
 	if (ret)
 		goto out_unlock;
@@ -3644,6 +3667,10 @@ static noinline long btrfs_ioctl_clone(struct file *file, unsigned long srcfd,
 		mutex_lock(&src->i_mutex);
 	}
 
+	ret = -ETXTBSY;
+	if (IS_SWAPFILE(src) || IS_SWAPFILE(inode))
+		goto out_unlock;
+
 	/* determine range to clone */
 	ret = -EINVAL;
 	if (off + len > src->i_size || off + len < off)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
