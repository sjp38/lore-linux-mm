Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 832C06B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:41:07 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id v16so3637104bkz.27
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 20:41:06 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dp9si13189183bkc.286.2013.11.27.20.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 20:41:06 -0800 (PST)
Date: Wed, 27 Nov 2013 23:40:19 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v6
Message-ID: <20131128044019.GK22729@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Here are the changes to the series I have accumulated so far.  Mainly:

o truncate_inode_pages_final() that sets mapping_set_exiting() and
  uses ordered but unlocked nrshadows & nrpages reads to skip the tree
  lock acquisition and IRQ disabling on empty page cache trees.

o revert all efforts to make the lru_lock IRQ-safe just to silence
  lockdep.  Also solves the problem of the list_lru_init() key API.

o in the shadow shrinker, drop the lru_lock after mapping->tree_lock
  has been acquired.  The latter pins the inode by preventing the
  final truncate from removing shadow entries, so we can safely
  release the lru lock once mapping->tree_lock is acquired and the
  node is taken off the list.

o changed radix_tree_node member names and documented them better

o fixed typos

As we agreed to keep the shadow node lru management non-lazy for now,
we don't need to worry about the lifetime of radix tree nodes in the
shrinker beyond taking it off the lru list with the lru_lock and
mapping->tree_lock held.  No complicated RCU scheme required.

---

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index f089058..fc0de70 100644
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
index b868c2b..79cbc9c 100644
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
index 94de6d1..e6716c2 100644
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
index 0e092d0..96df91e 100644
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
index 789bc25..2bbe60e 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -422,7 +422,7 @@ void afs_evict_inode(struct inode *inode)
 
 	ASSERTCMP(inode->i_ino, ==, vnode->fid.vnode);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 
 	afs_give_up_callback(vnode);
diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 8defc6b..29aa5cf 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -172,7 +172,7 @@ static void bfs_evict_inode(struct inode *inode)
 
 	dprintf("ino=%08lx\n", ino);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	invalidate_inode_buffers(inode);
 	clear_inode(inode);
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 391ffe5..c7a7def 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
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
index 51e3afa..d3e4983 100644
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
index 77fc5e1..d795c50 100644
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
index 4dcc0d8..43a5b38 100644
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
index e879cf8..afa1b81 100644
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
index a52a5d2..d9ff4d3 100644
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
index c260de6..115fa58 100644
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
index 2bd8548..153f4be 100644
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
index e274e9c..3b75e70 100644
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
index 9339cd2..0bd44f8 100644
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
index 0062da2..fe802d8 100644
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
index f47df72..363e3ae 100644
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
index a8ce6da..09d7fa0 100644
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
index e5639de..ac96a99 100644
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
index 380ab31..9e2fecd 100644
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
index 4c4d142..b9436d9 100644
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
index 2543728..0c9f640 100644
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
index 9edeeb0..50a4273 100644
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
index 7858fb7..093864e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -546,26 +546,10 @@ static void evict(struct inode *inode)
 	 */
 	inode_wait_for_writeback(inode);
 
-	/*
-	 * Page reclaim can not do iput() and thus can race with the
-	 * inode teardown.  Tell it when the address space is exiting,
-	 * so that it does not install eviction information after the
-	 * final truncate has begun.
-	 *
-	 * As truncation uses a lockless tree lookup, acquire the
-	 * spinlock to make sure any ongoing tree modification that
-	 * does not see AS_EXITING is completed before starting the
-	 * final truncate.
-	 */
-	spin_lock_irq(&inode->i_data.tree_lock);
-	mapping_set_exiting(&inode->i_data);
-	spin_unlock_irq(&inode->i_data.tree_lock);
-
 	if (op->evict_inode) {
 		op->evict_inode(inode);
 	} else {
-		if (inode->i_data.nrpages || inode->i_data.nrshadows)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 		clear_inode(inode);
 	}
 	if (S_ISBLK(inode->i_mode) && inode->i_bdev)
diff --git a/fs/jffs2/fs.c b/fs/jffs2/fs.c
index fe3c052..00ed6c6 100644
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
index f4aab71..6f8fe72 100644
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
index 9a59cba..4814031 100644
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
index 0332109..03aaeb1 100644
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
index 4659da6..e728061 100644
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
index eda8879..fbc38a6 100644
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
index e26acdd..f2a5c44 100644
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
index 42fcbe3..b9c5726 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -783,16 +783,14 @@ void nilfs_evict_inode(struct inode *inode)
 	int ret;
 
 	if (inode->i_nlink || !ii->i_root || unlikely(is_bad_inode(inode))) {
-		if (inode->i_data.nrpages || inode->i_data.nrshadows)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages_final(&inode->i_data);
 		clear_inode(inode);
 		nilfs_clear_inode(inode);
 		return;
 	}
 	nilfs_transaction_begin(sb, &ti, 0); /* never fails */
 
-	if (inode->i_data.nrpages || inode->i_data.nrshadows)
-		truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 
 	/* TODO: some of the following operations may fail.  */
 	nilfs_truncate_bmap(ii, 0);
diff --git a/fs/ntfs/inode.c b/fs/ntfs/inode.c
index 2778b02..bd50adc1 100644
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
index f87f9bd..f1c46a7 100644
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
index d8b0afd..ec58c76 100644
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
index 8eaa1ba..9ca0f08 100644
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
index ad62bdbb..bc8b800 100644
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -35,7 +35,7 @@ void reiserfs_evict_inode(struct inode *inode)
 	if (!inode->i_nlink && !is_bad_inode(inode))
 		dquot_initialize(inode);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	if (inode->i_nlink)
 		goto no_delete;
 
diff --git a/fs/super.c b/fs/super.c
index a958d52..0225c20 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -196,9 +196,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 
-		if (list_lru_init(&s->s_dentry_lru, NULL))
+		if (list_lru_init(&s->s_dentry_lru))
 			goto err_out;
-		if (list_lru_init(&s->s_inode_lru, NULL))
+		if (list_lru_init(&s->s_inode_lru))
 			goto err_out_dentry_lru;
 
 		INIT_LIST_HEAD(&s->s_mounts);
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index 963f910..bd0dd8d 100644
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
index c327d4e..5625ca9 100644
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
index 3e4aa72..b9ac1f3 100644
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
index 062b792..af6f4c3 100644
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
index c8ca960..61e8a9b 100644
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
diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index c49cbce..2634700 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -1670,7 +1670,7 @@ xfs_alloc_buftarg(
 	if (xfs_setsize_buftarg_early(btp, bdev))
 		goto error;
 
-	if (list_lru_init(&btp->bt_lru, NULL))
+	if (list_lru_init(&btp->bt_lru))
 		goto error;
 
 	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
index 57d6aa9..3e6c2e6 100644
--- a/fs/xfs/xfs_qm.c
+++ b/fs/xfs/xfs_qm.c
@@ -831,7 +831,7 @@ xfs_qm_init_quotainfo(
 
 	qinf = mp->m_quotainfo = kmem_zalloc(sizeof(xfs_quotainfo_t), KM_SLEEP);
 
-	if ((error = list_lru_init(&qinf->qi_lru, NULL))) {
+	if ((error = list_lru_init(&qinf->qi_lru))) {
 		kmem_free(qinf);
 		mp->m_quotainfo = NULL;
 		return error;
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 15188cc..47ce25d 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1006,7 +1006,7 @@ xfs_fs_evict_inode(
 
 	trace_xfs_evict_inode(ip);
 
-	truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages_final(&inode->i_data);
 	clear_inode(inode);
 	XFS_STATS_INC(vn_rele);
 	XFS_STATS_INC(vn_remove);
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index b970a45..3ce5417 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -32,7 +32,7 @@ struct list_lru {
 };
 
 void list_lru_destroy(struct list_lru *lru);
-int list_lru_init(struct list_lru *lru, struct lock_class_key *key);
+int list_lru_init(struct list_lru *lru);
 
 /**
  * list_lru_add: add an element to the lru list's tail
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c09ef3a..5449e7a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1588,6 +1588,7 @@ vm_unmapped_area(struct vm_unmapped_area_info *info)
 extern void truncate_inode_pages(struct address_space *, loff_t);
 extern void truncate_inode_pages_range(struct address_space *,
 				       loff_t lstart, loff_t lend);
+extern void truncate_inode_pages_final(struct address_space *);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 29df11f..33170db 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -88,15 +88,17 @@ struct radix_tree_node {
 	unsigned int	path;	/* Offset in parent & height from the bottom */
 	unsigned int	count;
 	union {
-		/* Used when ascending tree */
 		struct {
+			/* Used when ascending tree */
 			struct radix_tree_node *parent;
-			void *private;
+			/* For tree user */
+			void *private_data;
 		};
 		/* Used when freeing node */
 		struct rcu_head	rcu_head;
 	};
-	struct list_head lru;
+	/* For tree user */
+	struct list_head private_list;
 	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1865cd2..0a08953 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1425,7 +1425,7 @@ radix_tree_node_ctor(void *arg)
 	struct radix_tree_node *node = arg;
 
 	memset(node, 0, sizeof(*node));
-	INIT_LIST_HEAD(&node->lru);
+	INIT_LIST_HEAD(&node->private_list);
 }
 
 static __init unsigned long __maxindex(unsigned int height)
diff --git a/mm/filemap.c b/mm/filemap.c
index 79a7546..b93e223 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -120,8 +120,17 @@ static void page_cache_tree_delete(struct address_space *mapping,
 
 	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
 
-	if (shadow)
+	if (shadow) {
 		mapping->nrshadows++;
+		/*
+		 * Make sure the nrshadows update is committed before
+		 * the nrpages update so that final truncate racing
+		 * with reclaim does not see both counters 0 at the
+		 * same time and miss a shadow entry.
+		 */
+		smp_wmb();
+	}
+	mapping->nrpages--;
 
 	if (!node) {
 		/* Clear direct pointer tags in root node */
@@ -148,9 +157,10 @@ static void page_cache_tree_delete(struct address_space *mapping,
 			return;
 
 	/* Only shadow entries in there, keep track of this node */
-	if (!(node->count & RADIX_TREE_COUNT_MASK) && list_empty(&node->lru)) {
-		node->private = mapping;
-		list_lru_add(&workingset_shadow_nodes, &node->lru);
+	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
+	    list_empty(&node->private_list)) {
+		node->private_data = mapping;
+		list_lru_add(&workingset_shadow_nodes, &node->private_list);
 	}
 }
 
@@ -178,7 +188,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
-	mapping->nrpages--;
+
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
@@ -518,11 +528,13 @@ static int page_cache_tree_insert(struct address_space *mapping,
 			node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
 	}
 	radix_tree_replace_slot(slot, page);
+	mapping->nrpages++;
 	if (node) {
 		node->count++;
 		/* Installed page, can't be shadow-only anymore */
-		if (!list_empty(&node->lru))
-			list_lru_del(&workingset_shadow_nodes, &node->lru);
+		if (!list_empty(&node->private_list))
+			list_lru_del(&workingset_shadow_nodes,
+				     &node->private_list);
 	}
 	return 0;
 }
@@ -557,7 +569,6 @@ static int __add_to_page_cache_locked(struct page *page,
 	radix_tree_preload_end();
 	if (unlikely(error))
 		goto err_insert;
-	mapping->nrpages++;
 	__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	trace_mm_filemap_add_to_page_cache(page);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index c357e8f..72f9dec 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -114,7 +114,7 @@ restart:
 }
 EXPORT_SYMBOL_GPL(list_lru_walk_node);
 
-int list_lru_init(struct list_lru *lru, struct lock_class_key *key)
+int list_lru_init(struct list_lru *lru)
 {
 	int i;
 	size_t size = sizeof(*lru->node) * nr_node_ids;
@@ -126,8 +126,6 @@ int list_lru_init(struct list_lru *lru, struct lock_class_key *key)
 	nodes_clear(lru->active_nodes);
 	for (i = 0; i < nr_node_ids; i++) {
 		spin_lock_init(&lru->node[i].lock);
-		if (key)
-			lockdep_set_class(&lru->node[i].lock, key);
 		INIT_LIST_HEAD(&lru->node[i].list);
 		lru->node[i].nr_items = 0;
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index 9cf5f88..5c2615d 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -48,8 +48,9 @@ static void clear_exceptional_entry(struct address_space *mapping,
 		goto unlock;
 	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
 	/* No more shadow entries, stop tracking the node */
-	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) && !list_empty(&node->lru))
-		list_lru_del(&workingset_shadow_nodes, &node->lru);
+	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) &&
+	    !list_empty(&node->private_list))
+		list_lru_del(&workingset_shadow_nodes, &node->private_list);
 	__radix_tree_delete_node(&mapping->page_tree, node);
 unlock:
 	spin_unlock_irq(&mapping->tree_lock);
@@ -407,6 +408,53 @@ void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
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
diff --git a/mm/workingset.c b/mm/workingset.c
index ba8f0dd..2c3b5ad 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -35,7 +35,7 @@
  *
  *		Access frequency and refault distance
  *
- * A workload is trashing when its pages are frequently used but they
+ * A workload is thrashing when its pages are frequently used but they
  * are evicted from the inactive list every time before another access
  * would have promoted them to the active list.
  *
@@ -62,7 +62,7 @@
  *
  * Approximating inactive page access frequency - Observations:
  *
- * 1. When a page is accesed for the first time, it is added to the
+ * 1. When a page is accessed for the first time, it is added to the
  *    head of the inactive list, slides every existing inactive page
  *    towards the tail by one slot, and pushes the current tail page
  *    out of memory.
@@ -259,9 +259,6 @@ void workingset_activation(struct page *page)
  * slightly higher threshold than regular shrinkers so we don't
  * discard the entries too eagerly - after all, during light memory
  * pressure is exactly when we need them.
- *
- * The list_lru lock nests inside the IRQ-safe mapping->tree_lock, so
- * we have to disable IRQs for any list_lru operation as well.
  */
 
 struct list_lru workingset_shadow_nodes;
@@ -269,47 +266,47 @@ struct list_lru workingset_shadow_nodes;
 static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 					struct shrink_control *sc)
 {
-	unsigned long count;
-
-	local_irq_disable();
-	count = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
-	local_irq_enable();
-
-	return count;
+	return list_lru_count_node(&workingset_shadow_nodes, sc->nid);
 }
 
-#define NOIRQ_BATCH 32
-
 static enum lru_status shadow_lru_isolate(struct list_head *item,
 					  spinlock_t *lru_lock,
 					  void *arg)
 {
 	struct address_space *mapping;
 	struct radix_tree_node *node;
-	unsigned long *batch = arg;
 	unsigned int i;
 
-	node = container_of(item, struct radix_tree_node, lru);
-	mapping = node->private;
+	/*
+	 * Page cache insertions and deletions synchroneously maintain
+	 * the shadow node LRU under the mapping->tree_lock and the
+	 * lru_lock.  Because the page cache tree is emptied before
+	 * the inode can be destroyed, holding the lru_lock pins any
+	 * address_space that has radix tree nodes on the LRU.
+	 *
+	 * We can then safely transition to the mapping->tree_lock to
+	 * pin only the address_space of the particular node we want
+	 * to reclaim, take the node off-LRU, and drop the lru_lock.
+	 */
+
+	node = container_of(item, struct radix_tree_node, private_list);
+	mapping = node->private_data;
 
-	/* Don't disable IRQs for too long */
-	if (--(*batch) == 0) {
-		spin_unlock_irq(lru_lock);
-		*batch = NOIRQ_BATCH;
-		spin_lock_irq(lru_lock);
-		return LRU_RETRY;
+	/* Coming from the list, invert the lock order */
+	if (!spin_trylock_irq(&mapping->tree_lock)) {
+		spin_unlock(lru_lock);
+		goto out_retry;
 	}
 
-	/* Coming from the list, inverse the lock order */
-	if (!spin_trylock(&mapping->tree_lock))
-		return LRU_SKIP;
-
 	/*
 	 * The nodes should only contain one or more shadow entries,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
 
+	list_del_init(&node->private_list);
+	spin_unlock(lru_lock);
+
 	BUG_ON(!node->count);
 	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
 
@@ -323,30 +320,24 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 			mapping->nrshadows--;
 		}
 	}
-	list_del_init(&node->lru);
 	BUG_ON(node->count);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
 
-	spin_unlock(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 
 	count_vm_event(WORKINGSET_NODES_RECLAIMED);
-
-	return LRU_REMOVED;
+out_retry:
+	cond_resched();
+	spin_lock(lru_lock);
+	return LRU_RETRY;
 }
 
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
-	unsigned long batch = NOIRQ_BATCH;
-	unsigned long freed;
-
-	local_irq_disable();
-	freed = list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
-				   shadow_lru_isolate, &batch, &sc->nr_to_scan);
-	local_irq_enable();
-
-	return freed;
+	return list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
+				  shadow_lru_isolate, NULL, &sc->nr_to_scan);
 }
 
 static struct shrinker workingset_shadow_shrinker = {
@@ -356,13 +347,11 @@ static struct shrinker workingset_shadow_shrinker = {
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
-static struct lock_class_key shadow_nodes_key;
-
 static int __init workingset_init(void)
 {
 	int ret;
 
-	ret = list_lru_init(&workingset_shadow_nodes, &shadow_nodes_key);
+	ret = list_lru_init(&workingset_shadow_nodes);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
