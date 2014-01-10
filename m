Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id A383E6B004D
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:12:04 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id my13so1683522bkb.22
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 10:12:04 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lk6si4459933bkb.308.2014.01.10.10.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 10:12:03 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/9] mm + fs: store shadow entries in page cache
Date: Fri, 10 Jan 2014 13:10:40 -0500
Message-Id: <1389377443-11755-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Reclaim will be leaving shadow entries in the page cache radix tree
upon evicting the real page.  As those pages are found from the LRU,
an iput() can lead to the inode being freed concurrently.  At this
point, reclaim must no longer install shadow pages because the inode
freeing code needs to ensure the page tree is really empty.

Add an address_space flag, AS_EXITING, that the inode freeing code
sets under the tree lock before doing the final truncate.  Reclaim
will check for this flag before installing shadow pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/filesystems/porting               |  6 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c |  2 +-
 fs/9p/vfs_inode.c                               |  2 +-
 fs/affs/inode.c                                 |  2 +-
 fs/afs/inode.c                                  |  2 +-
 fs/bfs/inode.c                                  |  2 +-
 fs/block_dev.c                                  |  4 +-
 fs/btrfs/inode.c                                |  2 +-
 fs/cifs/cifsfs.c                                |  2 +-
 fs/coda/inode.c                                 |  2 +-
 fs/ecryptfs/super.c                             |  2 +-
 fs/exofs/inode.c                                |  2 +-
 fs/ext2/inode.c                                 |  2 +-
 fs/ext3/inode.c                                 |  2 +-
 fs/ext4/inode.c                                 |  4 +-
 fs/f2fs/inode.c                                 |  2 +-
 fs/fat/inode.c                                  |  2 +-
 fs/freevxfs/vxfs_inode.c                        |  2 +-
 fs/fuse/inode.c                                 |  2 +-
 fs/gfs2/super.c                                 |  2 +-
 fs/hfs/inode.c                                  |  2 +-
 fs/hfsplus/super.c                              |  2 +-
 fs/hostfs/hostfs_kern.c                         |  2 +-
 fs/hpfs/inode.c                                 |  2 +-
 fs/inode.c                                      |  4 +-
 fs/jffs2/fs.c                                   |  2 +-
 fs/jfs/inode.c                                  |  4 +-
 fs/logfs/readwrite.c                            |  2 +-
 fs/minix/inode.c                                |  2 +-
 fs/ncpfs/inode.c                                |  2 +-
 fs/nfs/inode.c                                  |  2 +-
 fs/nfs/nfs4super.c                              |  2 +-
 fs/nilfs2/inode.c                               |  6 +--
 fs/ntfs/inode.c                                 |  2 +-
 fs/ocfs2/inode.c                                |  4 +-
 fs/omfs/inode.c                                 |  2 +-
 fs/proc/inode.c                                 |  2 +-
 fs/reiserfs/inode.c                             |  2 +-
 fs/sysfs/inode.c                                |  2 +-
 fs/sysv/inode.c                                 |  2 +-
 fs/ubifs/super.c                                |  2 +-
 fs/udf/inode.c                                  |  4 +-
 fs/ufs/inode.c                                  |  2 +-
 fs/xfs/xfs_super.c                              |  2 +-
 include/linux/fs.h                              |  1 +
 include/linux/mm.h                              |  1 +
 include/linux/pagemap.h                         | 13 +++++-
 mm/filemap.c                                    | 33 ++++++++++++---
 mm/truncate.c                                   | 54 +++++++++++++++++++++++--
 mm/vmscan.c                                     |  2 +-
 50 files changed, 147 insertions(+), 65 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index f0890581f7f6..fc0de703066b 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -295,9 +295,9 @@ in the beginning of ->setattr unconditionally.
 	->clear_inode() and ->delete_inode() are gone; ->evict_inode() should
 be used instead.  It gets called whenever the inode is evicted, whether it has
 remaining links or not.  Caller does *not* evict the pagecache or inode-associated
-metadata buffers; getting rid of those is responsibility of method, as it had
-been for ->delete_inode(). Caller makes sure async writeback cannot be running
-for the inode while (or after) ->evict_inode() is called.
+metadata buffers; the method has to use truncate_inode_pages_final() to get rid
+of those. Caller makes sure async writeback cannot be running for the inode while
+(or after) ->evict_inode() is called.
 
 	->drop_inode() returns int now; it's called on final iput() with
 inode->i_lock held and it returns true if filesystems wants the inode to be
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b868c2bd58d2..79cbc9c5b744 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1817,7 +1817,7 @@ void ll_delete_inode(struct inode *inode)
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
 				   CL_FSYNC_DISCARD, 1);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	/* Workaround for LU-118 */
 	if (inode->i_data.nrpages) {
diff --git a/fs/9p/vfs_inode.c b/fs/9p/vfs_inode.c
index 94de6d1482e2..e6716c295a99 100644
--- a/fs/9p/vfs_inode.c
+++ b/fs/9p/vfs_inode.c
@@ -444,7 +444,7 @@ void v9fs_evict_inode(struct inode *inode)
 {
 	struct v9fs_inode *v9inode = V9FS_I(inode);
 
-	truncate_inode_pages(inode->i_mapping, 0);
+	truncate_inode_pages_final(inode->i_mapping);
 	clear_inode(inode);
 	filemap_fdatawrite(inode->i_mapping);
 
diff --git a/fs/affs/inode.c b/fs/affs/inode.c
index 0e092d08680e..96df91e8c334 100644
--- a/fs/affs/inode.c
+++ b/fs/affs/inode.c
@@ -259,7 +259,7 @@ affs_evict_inode(struct inode *inode)
 {
 	unsigned long cache_page;
 	pr_debug("AFFS: evict_inode(ino=%lu, nlink=%u)\n", inode->i_ino, inode->i_nlink);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	if (!inode->i_nlink) {
 		inode->i_size = 0;
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 789bc253b5f6..2bbe60e3f0e3 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -422,7 +422,7 @@ void afs_evict_inode(struct inode *inode)
 
 	ASSERTCMP(inode->i_ino, ==, vnode->fid.vnode);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	afs_give_up_callback(vnode);
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 8defc6b3f9a2..29aa5cf6639b 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -172,7 +172,7 @@ static void bfs_evict_inode(struct inode *inode)
 
 	dprintf("ino=%08lx\n", ino);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	invalidate_inode_buffers(inode);
 	clear_inode(inode);
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 1e86823a9cbd..c7a7def27b07 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -83,7 +83,7 @@ void kill_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
 		return;
 
 	invalidate_bh_lrus();
@@ -419,7 +419,7 @@ static void bdev_evict_inode(struct inode *inode)
 {
 	struct block_device *bdev = &BDEV_I(inode)->bdev;
 	struct list_head *p;
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	invalidate_inode_buffers(inode); /* is it needed here? */
 	clear_inode(inode);
 	spin_lock(&bdev_lock);
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 51e3afa78354..d3e498390189 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4471,7 +4471,7 @@ void btrfs_evict_inode(struct inode *inode)
 
 	trace_btrfs_inode_evict(inode);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (inode->i_nlink && (btrfs_root_refs(&root->root_item) != 0 ||
 			       btrfs_is_free_space_inode(inode)))
 		goto no_delete;
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 77fc5e181077..d795c50e67cb 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -286,7 +286,7 @@ cifs_destroy_inode(struct inode *inode)
 static void
 cifs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	cifs_fscache_release_inode_cookie(inode);
 }
diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index 4dcc0d81a7aa..43a5b38fc8d3 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -250,7 +250,7 @@ static void coda_put_super(struct super_block *sb)
 
 static void coda_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	coda_cache_clear_inode(inode);
 }
diff --git a/fs/ecryptfs/super.c b/fs/ecryptfs/super.c
index e879cf8ff0b1..afa1b81c3418 100644
--- a/fs/ecryptfs/super.c
+++ b/fs/ecryptfs/super.c
@@ -132,7 +132,7 @@ static int ecryptfs_statfs(struct dentry *dentry, struct kstatfs *buf)
  */
 static void ecryptfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	iput(ecryptfs_inode_to_lower(inode));
 }
diff --git a/fs/exofs/inode.c b/fs/exofs/inode.c
index a52a5d23c30b..d9ff4d304b41 100644
--- a/fs/exofs/inode.c
+++ b/fs/exofs/inode.c
@@ -1479,7 +1479,7 @@ void exofs_evict_inode(struct inode *inode)
 	struct ore_io_state *ios;
 	int ret;
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	/* TODO: should do better here */
 	if (inode->i_nlink || is_bad_inode(inode))
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index c260de6d7b6d..115fa58bb9ae 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -78,7 +78,7 @@ void ext2_evict_inode(struct inode * inode)
 		dquot_drop(inode);
 	}
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	if (want_delete) {
 		sb_start_intwrite(inode->i_sb);
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 2bd85486b879..153f4bec69ef 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -228,7 +228,7 @@ void ext3_evict_inode (struct inode *inode)
 		log_wait_commit(journal, commit_tid);
 		filemap_write_and_wait(&inode->i_data);
 	}
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	ext3_discard_reservation(inode);
 	rsv = ei->i_block_alloc_info;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e274e9c1171f..3b75e70ae2eb 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -214,7 +214,7 @@ void ext4_evict_inode(struct inode *inode)
 			jbd2_complete_transaction(journal, commit_tid);
 			filemap_write_and_wait(&inode->i_data);
 		}
-		truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 
 		WARN_ON(atomic_read(&EXT4_I(inode)->i_ioend_count));
 		goto no_delete;
@@ -225,7 +225,7 @@ void ext4_evict_inode(struct inode *inode)
 
 	if (ext4_should_order_data(inode))
 		ext4_begin_ordered_truncate(inode, 0);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	WARN_ON(atomic_read(&EXT4_I(inode)->i_ioend_count));
 	if (is_bad_inode(inode))
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index 9339cd292047..0bd44f84e79b 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -246,7 +246,7 @@ void f2fs_evict_inode(struct inode *inode)
 	int ilock;
 
 	trace_f2fs_evict_inode(inode);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	if (inode->i_ino == F2FS_NODE_INO(sbi) ||
 			inode->i_ino == F2FS_META_INO(sbi))
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 0062da21dd8b..fe802d83abdb 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -490,7 +490,7 @@ EXPORT_SYMBOL_GPL(fat_build_inode);
 
 static void fat_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (!inode->i_nlink) {
 		inode->i_size = 0;
 		fat_truncate_blocks(inode, 0);
diff --git a/fs/freevxfs/vxfs_inode.c b/fs/freevxfs/vxfs_inode.c
index f47df72cef17..363e3ae25f6b 100644
--- a/fs/freevxfs/vxfs_inode.c
+++ b/fs/freevxfs/vxfs_inode.c
@@ -354,7 +354,7 @@ static void vxfs_i_callback(struct rcu_head *head)
 void
 vxfs_evict_inode(struct inode *ip)
 {
-	truncate_inode_pages(&ip->i_data, 0);
+	truncate_inode_pages_final(&ip->i_data);
 	clear_inode(ip);
 	call_rcu(&ip->i_rcu, vxfs_i_callback);
 }
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index a8ce6dab60a0..09d7fa05f136 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -123,7 +123,7 @@ static void fuse_destroy_inode(struct inode *inode)
 
 static void fuse_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	if (inode->i_sb->s_flags & MS_ACTIVE) {
 		struct fuse_conn *fc = get_fuse_conn(inode);
diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
index e5639dec66c4..ac96a99c0e5d 100644
--- a/fs/gfs2/super.c
+++ b/fs/gfs2/super.c
@@ -1525,7 +1525,7 @@ out_unlock:
 		fs_warn(sdp, "gfs2_evict_inode: %d\n", error);
 out:
 	/* Case 3 starts here */
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	gfs2_rs_delete(ip);
 	gfs2_ordered_del_inode(ip);
 	clear_inode(inode);
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index 380ab31b5e0f..9e2fecd62f62 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -547,7 +547,7 @@ out:
 
 void hfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	if (HFS_IS_RSRC(inode) && HFS_I(inode)->rsrc_inode) {
 		HFS_I(HFS_I(inode)->rsrc_inode)->rsrc_inode = NULL;
diff --git a/fs/hfsplus/super.c b/fs/hfsplus/super.c
index 4c4d142cf890..b9436d923585 100644
--- a/fs/hfsplus/super.c
+++ b/fs/hfsplus/super.c
@@ -161,7 +161,7 @@ static int hfsplus_write_inode(struct inode *inode,
 static void hfsplus_evict_inode(struct inode *inode)
 {
 	hfs_dbg(INODE, "hfsplus_evict_inode: %lu\n", inode->i_ino);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	if (HFSPLUS_IS_RSRC(inode)) {
 		HFSPLUS_I(HFSPLUS_I(inode)->rsrc_inode)->rsrc_inode = NULL;
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index 25437280a207..0c9f64070e0f 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -239,7 +239,7 @@ static struct inode *hostfs_alloc_inode(struct super_block *sb)
 
 static void hostfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	if (HOSTFS_I(inode)->fd != -1) {
 		close_file(&HOSTFS_I(inode)->fd);
diff --git a/fs/hpfs/inode.c b/fs/hpfs/inode.c
index 9edeeb0ea97e..50a427313835 100644
--- a/fs/hpfs/inode.c
+++ b/fs/hpfs/inode.c
@@ -304,7 +304,7 @@ void hpfs_write_if_changed(struct inode *inode)
 
 void hpfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	if (!inode->i_nlink) {
 		hpfs_lock(inode->i_sb);
diff --git a/fs/inode.c b/fs/inode.c
index b33ba8e021cc..093864ea2358 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -503,6 +503,7 @@ void clear_inode(struct inode *inode)
 	 */
 	spin_lock_irq(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(inode->i_data.nrshadows);
 	spin_unlock_irq(&inode->i_data.tree_lock);
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
@@ -548,8 +549,7 @@ static void evict(struct inode *inode)
 	if (op->evict_inode) {
 		op->evict_inode(inode);
 	} else {
-		if (inode->i_data.nrpages)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 		clear_inode(inode);
 	}
 	if (S_ISBLK(inode->i_mode) && inode->i_bdev)
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index fe3c0527545f..00ed6c64a579 100644
--- a/fs/jffs2/fs.c
+++ b/fs/jffs2/fs.c
@@ -241,7 +241,7 @@ void jffs2_evict_inode (struct inode *inode)
 
 	jffs2_dbg(1, "%s(): ino #%lu mode %o\n",
 		  __func__, inode->i_ino, inode->i_mode);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	jffs2_do_clear_inode(c, f);
 }
diff --git a/fs/jfs/inode.c b/fs/jfs/inode.c
index f4aab719add5..6f8fe72c2a7a 100644
--- a/fs/jfs/inode.c
+++ b/fs/jfs/inode.c
@@ -154,7 +154,7 @@ void jfs_evict_inode(struct inode *inode)
 		dquot_initialize(inode);
 
 		if (JFS_IP(inode)->fileset == FILESYSTEM_I) {
-			truncate_inode_pages(&inode->i_data, 0);
+			truncate_inode_pages_final(&inode->i_data);
 
 			if (test_cflag(COMMIT_Freewmap, inode))
 				jfs_free_zero_link(inode);
@@ -168,7 +168,7 @@ void jfs_evict_inode(struct inode *inode)
 			dquot_free_inode(inode);
 		}
 	} else {
-		truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 	}
 	clear_inode(inode);
 	dquot_drop(inode);
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 9a59cbade2fb..48140315f627 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -2180,7 +2180,7 @@ void logfs_evict_inode(struct inode *inode)
 			do_delete_inode(inode);
 		}
 	}
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	/* Cheaper version of write_inode.  All changes are concealed in
diff --git a/fs/minix/inode.c b/fs/minix/inode.c
index 0332109162a5..03aaeb1a694a 100644
--- a/fs/minix/inode.c
+++ b/fs/minix/inode.c
@@ -26,7 +26,7 @@ static int minix_remount (struct super_block * sb, int * flags, char * data);
 
 static void minix_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (!inode->i_nlink) {
 		inode->i_size = 0;
 		minix_truncate(inode);
diff --git a/fs/ncpfs/inode.c b/fs/ncpfs/inode.c
index 4659da67e7f6..e728061edb13 100644
--- a/fs/ncpfs/inode.c
+++ b/fs/ncpfs/inode.c
@@ -296,7 +296,7 @@ ncp_iget(struct super_block *sb, struct ncp_entry_info *info)
 static void
 ncp_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	if (S_ISDIR(inode->i_mode)) {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index eda8879171c4..fbc38a62cbc9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -128,7 +128,7 @@ EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
 void nfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	nfs_clear_inode(inode);
 }
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index e26acdd1a645..f2a5c44106b6 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -98,7 +98,7 @@ static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
  */
 static void nfs4_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	pnfs_return_layout(inode);
 	pnfs_destroy_layout(NFS_I(inode));
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 7e350c562e0e..b9c5726120e3 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -783,16 +783,14 @@ void nilfs_evict_inode(struct inode *inode)
 	int ret;
 
 	if (inode->i_nlink || !ii->i_root || unlikely(is_bad_inode(inode))) {
-		if (inode->i_data.nrpages)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 		clear_inode(inode);
 		nilfs_clear_inode(inode);
 		return;
 	}
 	nilfs_transaction_begin(sb, &ti, 0); /* never fails */
 
-	if (inode->i_data.nrpages)
-		truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	/* TODO: some of the following operations may fail.  */
 	nilfs_truncate_bmap(ii, 0);
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index 2778b0255dc6..bd50adc1e6a7 100644
--- a/fs/ntfs/inode.c
+++ b/fs/ntfs/inode.c
@@ -2259,7 +2259,7 @@ void ntfs_evict_big_inode(struct inode *vi)
 {
 	ntfs_inode *ni = NTFS_I(vi);
 
-	truncate_inode_pages(&vi->i_data, 0);
+	truncate_inode_pages_final(&vi->i_data);
 	clear_inode(vi);
 
 #ifdef NTFS_RW
diff --git a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
index f87f9bd1edff..f1c46a7f9bc5 100644
--- a/fs/ocfs2/inode.c
+++ b/fs/ocfs2/inode.c
@@ -951,7 +951,7 @@ static void ocfs2_cleanup_delete_inode(struct inode *inode,
 		(unsigned long long)OCFS2_I(inode)->ip_blkno, sync_data);
 	if (sync_data)
 		filemap_write_and_wait(inode->i_mapping);
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 }
 
 static void ocfs2_delete_inode(struct inode *inode)
@@ -1167,7 +1167,7 @@ void ocfs2_evict_inode(struct inode *inode)
 	    (OCFS2_I(inode)->ip_flags & OCFS2_INODE_MAYBE_ORPHANED)) {
 		ocfs2_delete_inode(inode);
 	} else {
-		truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 	}
 	ocfs2_clear_inode(inode);
 }
diff --git a/fs/omfs/inode.c b/fs/omfs/inode.c
index d8b0afde2179..ec58c7659183 100644
--- a/fs/omfs/inode.c
+++ b/fs/omfs/inode.c
@@ -183,7 +183,7 @@ int omfs_sync_inode(struct inode *inode)
  */
 static void omfs_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	if (inode->i_nlink)
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 8eaa1ba793fc..9ca0f085dada 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -35,7 +35,7 @@ static void proc_evict_inode(struct inode *inode)
 	const struct proc_ns_operations *ns_ops;
 	void *ns;
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	/* Stop tracking associated processes */
diff --git a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
index ad62bdbb451e..bc8b8009897d 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -35,7 +35,7 @@ void reiserfs_evict_inode(struct inode *inode)
 	if (!inode->i_nlink && !is_bad_inode(inode))
 		dquot_initialize(inode);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (inode->i_nlink)
 		goto no_delete;
 
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index 963f910c8034..bd0dd8d88b50 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -309,7 +309,7 @@ void sysfs_evict_inode(struct inode *inode)
 {
 	struct sysfs_dirent *sd  = inode->i_private;
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	sysfs_put(sd);
 }
diff --git a/fs/sysv/inode.c b/fs/sysv/inode.c
index c327d4ee1235..5625ca920f5e 100644
--- a/fs/sysv/inode.c
+++ b/fs/sysv/inode.c
@@ -295,7 +295,7 @@ int sysv_sync_inode(struct inode *inode)
 
 static void sysv_evict_inode(struct inode *inode)
 {
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (!inode->i_nlink) {
 		inode->i_size = 0;
 		sysv_truncate(inode);
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 3e4aa7281e04..b9ac1f350920 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -351,7 +351,7 @@ static void ubifs_evict_inode(struct inode *inode)
 	dbg_gen("inode %lu, mode %#x", inode->i_ino, (int)inode->i_mode);
 	ubifs_assert(!atomic_read(&inode->i_count));
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	if (inode->i_nlink)
 		goto done;
diff --git a/fs/udf/inode.c b/fs/udf/inode.c
index 062b7925bca0..af6f4c38d91a 100644
--- a/fs/udf/inode.c
+++ b/fs/udf/inode.c
@@ -146,8 +146,8 @@ void udf_evict_inode(struct inode *inode)
 		want_delete = 1;
 		udf_setsize(inode, 0);
 		udf_update_inode(inode, IS_SYNC(inode));
-	} else
-		truncate_inode_pages(&inode->i_data, 0);
+	}
+	truncate_inode_pages_final(&inode->i_data);
 	invalidate_inode_buffers(inode);
 	clear_inode(inode);
 	if (iinfo->i_alloc_type != ICBTAG_FLAG_AD_IN_ICB &&
diff --git a/fs/ufs/inode.c b/fs/ufs/inode.c
index c8ca96086784..61e8a9b021dd 100644
--- a/fs/ufs/inode.c
+++ b/fs/ufs/inode.c
@@ -885,7 +885,7 @@ void ufs_evict_inode(struct inode * inode)
 	if (!inode->i_nlink && !is_bad_inode(inode))
 		want_delete = 1;
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (want_delete) {
 		loff_t old_i_size;
 		/*UFS_I(inode)->i_dtime = CURRENT_TIME;*/
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 15188cc99449..47ce25dc412d 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1006,7 +1006,7 @@ xfs_fs_evict_inode(
 
 	trace_xfs_evict_inode(ip);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	XFS_STATS_INC(vn_rele);
 	XFS_STATS_INC(vn_remove);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547ba191..9bfa5a57b4ed 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -416,6 +416,7 @@ struct address_space {
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
+	unsigned long		nrshadows;	/* number of shadow entries */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c09ef3ae55bc..5449e7a96adf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1588,6 +1588,7 @@ vm_unmapped_area(struct vm_unmapped_area_info *info)
 extern void truncate_inode_pages(struct address_space *, loff_t);
 extern void truncate_inode_pages_range(struct address_space *,
 				       loff_t lstart, loff_t lend);
+extern void truncate_inode_pages_final(struct address_space *);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index b6854b7c58cb..f132fdf5ce0f 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,7 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
+	AS_EXITING	= __GFP_BITS_SHIFT + 5, /* final truncate in progress */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -69,6 +70,16 @@ static inline int mapping_balloon(struct address_space *mapping)
 	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);
 }
 
+static inline void mapping_set_exiting(struct address_space *mapping)
+{
+	set_bit(AS_EXITING, &mapping->flags);
+}
+
+static inline int mapping_exiting(struct address_space *mapping)
+{
+	return test_bit(AS_EXITING, &mapping->flags);
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
@@ -547,7 +558,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
-extern void __delete_from_page_cache(struct page *page);
+extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 23eb3be27205..d02db5801dda 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -107,12 +107,33 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
+static void page_cache_tree_delete(struct address_space *mapping,
+				   struct page *page, void *shadow)
+{
+	if (shadow) {
+		void **slot;
+
+		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
+		radix_tree_replace_slot(slot, shadow);
+		mapping->nrshadows++;
+		/*
+		 * Make sure the nrshadows update is committed before
+		 * the nrpages update so that final truncate racing
+		 * with reclaim does not see both counters 0 at the
+		 * same time and miss a shadow entry.
+		 */
+		smp_wmb();
+	} else
+		radix_tree_delete(&mapping->page_tree, page->index);
+	mapping->nrpages--;
+}
+
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
  */
-void __delete_from_page_cache(struct page *page)
+void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -127,10 +148,11 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	page_cache_tree_delete(mapping, page, shadow);
+
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
-	mapping->nrpages--;
+
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
@@ -166,7 +188,7 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -426,7 +448,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		__delete_from_page_cache(old);
+		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
@@ -460,6 +482,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
+		mapping->nrshadows--;
 		mapping->nrpages++;
 		return 0;
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index b0f4d4bee8ab..97606fa4c458 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -35,7 +35,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * without the tree itself locked.  These unlocked entries
 	 * need verification under the tree lock.
 	 */
-	radix_tree_delete_item(&mapping->page_tree, index, entry);
+	if (radix_tree_delete_item(&mapping->page_tree, index, entry) == entry)
+		mapping->nrshadows--;
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
@@ -229,7 +230,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	int		i;
 
 	cleancache_invalidate_inode(mapping);
-	if (mapping->nrpages == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
 		return;
 
 	/* Offsets within partial pages */
@@ -391,6 +392,53 @@ void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
 EXPORT_SYMBOL(truncate_inode_pages);
 
 /**
+ * truncate_inode_pages_final - truncate *all* pages before inode dies
+ * @mapping: mapping to truncate
+ *
+ * Called under (and serialized by) inode->i_mutex.
+ *
+ * Filesystems have to use this in the .evict_inode path to inform the
+ * VM that this is the final truncate and the inode is going away.
+ */
+void truncate_inode_pages_final(struct address_space *mapping)
+{
+	unsigned long nrshadows;
+	unsigned long nrpages;
+
+	/*
+	 * Page reclaim can not participate in regular inode lifetime
+	 * management (can't call iput()) and thus can race with the
+	 * inode teardown.  Tell it when the address space is exiting,
+	 * so that it does not install eviction information after the
+	 * final truncate has begun.
+	 */
+	mapping_set_exiting(mapping);
+
+	/*
+	 * When reclaim installs eviction entries, it increases
+	 * nrshadows first, then decreases nrpages.  Make sure we see
+	 * this in the right order or we might miss an entry.
+	 */
+	nrpages = mapping->nrpages;
+	smp_rmb();
+	nrshadows = mapping->nrshadows;
+
+	if (nrpages || nrshadows) {
+		/*
+		 * As truncation uses a lockless tree lookup, acquire
+		 * the spinlock to make sure any ongoing tree
+		 * modification that does not see AS_EXITING is
+		 * completed before starting the final truncate.
+		 */
+		spin_lock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
+
+		truncate_inode_pages(mapping, 0);
+	}
+}
+EXPORT_SYMBOL(truncate_inode_pages_final);
+
+/**
  * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
  * @mapping: the address_space which holds the pages to invalidate
  * @start: the offset 'from' which to invalidate
@@ -483,7 +531,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 		goto failed;
 
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eea668d9cff6..b954b31602cf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -554,7 +554,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 		freepage = mapping->a_ops->freepage;
 
-		__delete_from_page_cache(page);
+		__delete_from_page_cache(page, NULL);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
