Date: Fri, 9 Jun 2000 22:36:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: O_SYNC patches for 2.4.0-test1-ac11
Message-ID: <20000609223632.E2621@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+QahgC5+KEYLbs62"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>, Theodore Ts'o <tytso@valinux.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ulrich Drepper <drepper@cygnus.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

The following patch fully implements O_SYNC, fsync and fdatasync,
at least for ext2.  The infrastructure it includes should make it
trivial for any other filesystem to do likewise.

The basic changes are:

	Include a per-inode list of dirty buffers

	Pass a "datasync" parameter down to the filesystems when fsync
	or fdatasync are called, to distinguish between the two (when
	fdatasync is specified, we don't have to flush the inode to disk
	if only timestamps have changed)

	Split I_DIRTY into two bits, one (I_DIRTY_SYNC) which is set
	for all dirty inodes, and the other (I_DIRTY_DATASYNC) which 
	is set only if fdatasync needs to flush the inode (ie. it is
	set for everything except for timestamp updates).  This means:

		The old (flags & I_DIRTY) construct still returns 
		true if the inode is in any way dirty; and

		(flags |= I_DIRTY) sets both bits, as expected.

	fs/ext2 and __block_commit_write are modified to record the
	all newly dirtied buffers (both data and metadata) on the
	inode's dirty block list

	generic_file_write now honours the O_SYNC flag and calls
	generic_osync_inode(), which flushes the inode dirty buffer
	list and calls the inode's fsync method.

Note: currently, the O_SYNC code in generic_file_write calls 
generic_osync_inode with datasync==1, which means that O_SYNC is
interpreted as O_DSYNC according to the SUS spec.  In other words,
O_SYNC is not guaranteed to flush timestamp updates to disk (but
fsync is).  This is important: we do not currently have an O_DSYNC
flag (although that would now be trivial to implement), so existing
apps are forced to use O_SYNC instead.  Apps such as Oracle rely on
O_SYNC for write ordering, but due to a 2.2 bug, existing kernels
don't do the timestamp update and hence we achieve decent 
performance even without O_DSYNC.  We cannot suddenly cause all of
those applications to experience a massive performance drop.

One way round this would be to split O_SYNC into O_DSYNC and
O_TRUESYNC, and in glibc to redefine O_SYNC to be (O_DSYNC |
O_TRUESYNC).  If we keep the new O_DSYNC to have the same value
as the old O_SYNC, then:

	* Old applications which specified O_SYNC will continue
	  to get their expected (O_DSYNC) behaviour

	* New applications can specify O_SYNC or O_DSYNC and get
	  the selected behaviour on new kernels

	* New applications calling either O_SYNC or O_DSYNC will
	  still get O_SYNC on old kernels.

In performance testing, "dd" with 64k blocks and writing into an 
existing, preallocated file, gets close to theoretical disk bandwidth
(about 13MB/sec on a Cheetah), when using O_SYNC or when doing a
fdatasync between each write.  Doing fsync instead gives only about
3MB/sec and results in a lot of audible disk seeking, as expected.
If I don't preallocate the file, then even fdatasync is slow, as it
now has to sync the changed i_size information after every write (and
it gets slower as the file grows and the distance between the inode 
and the data being written increases).

--Stephen

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="osync-2.4.0-test1-ac11.diff"

--- linux-2.4.0-test1-ac11.osync/fs/block_dev.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/block_dev.c	Fri Jun  9 18:08:18 2000
@@ -313,7 +313,7 @@
  *	since the vma has no handle.
  */
  
-static int block_fsync(struct file *filp, struct dentry *dentry)
+static int block_fsync(struct file *filp, struct dentry *dentry, int datasync)
 {
 	return fsync_dev(dentry->d_inode->i_rdev);
 }
--- linux-2.4.0-test1-ac11.osync/fs/buffer.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/buffer.c	Fri Jun  9 18:08:18 2000
@@ -68,6 +68,8 @@
  *	lru_list_lock > hash_table_lock > free_list_lock > unused_list_lock
  */
 
+#define BH_ENTRY(list) list_entry((list), struct buffer_head, b_inode_buffers)
+
 /*
  * Hash table gook..
  */
@@ -323,7 +325,7 @@
  *	filp may be NULL if called via the msync of a vma.
  */
  
-int file_fsync(struct file *filp, struct dentry *dentry)
+int file_fsync(struct file *filp, struct dentry *dentry, int datasync)
 {
 	struct inode * inode = dentry->d_inode;
 	struct super_block * sb;
@@ -332,7 +334,7 @@
 
 	lock_kernel();
 	/* sync the inode to buffers */
-	write_inode_now(inode);
+	write_inode_now(inode, 0);
 
 	/* sync the superblock to buffers */
 	sb = inode->i_sb;
@@ -373,7 +375,7 @@
 
 	/* We need to protect against concurrent writers.. */
 	down(&inode->i_sem);
-	err = file->f_op->fsync(file, dentry);
+	err = file->f_op->fsync(file, dentry, 0);
 	up(&inode->i_sem);
 
 out_putf:
@@ -406,9 +408,8 @@
 	if (!file->f_op || !file->f_op->fsync)
 		goto out_putf;
 
-	/* this needs further work, at the moment it is identical to fsync() */
 	down(&inode->i_sem);
-	err = file->f_op->fsync(file, dentry);
+	err = file->f_op->fsync(file, dentry, 1);
 	up(&inode->i_sem);
 
 out_putf:
@@ -535,8 +536,7 @@
  * As we don't lock buffers (unless we are reading them, that is),
  * something might happen to it while we sleep (ie a read-error
  * will force it bad). This shouldn't really happen currently, but
- * the code is ready.
- */
+ * the code is ready.  */
 struct buffer_head * get_hash_table(kdev_t dev, int block, int size)
 {
 	struct buffer_head **head = &hash(dev, block);
@@ -574,6 +574,42 @@
 	return 0;
 }
 
+void buffer_insert_inode_queue(struct buffer_head *bh, struct inode *inode)
+{
+	spin_lock(&lru_list_lock);
+	if (bh->b_inode)
+		list_del(&bh->b_inode_buffers);
+	bh->b_inode = inode;
+	list_add(&bh->b_inode_buffers, &inode->i_dirty_buffers);
+	spin_unlock(&lru_list_lock);
+}
+
+/* The caller must have the lru_list lock before calling the 
+   remove_inode_queue functions.  */
+static void __remove_inode_queue(struct buffer_head *bh)
+{
+	bh->b_inode = NULL;
+	list_del(&bh->b_inode_buffers);
+}
+
+static inline void remove_inode_queue(struct buffer_head *bh)
+{
+	if (bh->b_inode)
+		__remove_inode_queue(bh);
+}
+
+int inode_has_buffers(struct inode *inode)
+{
+	int ret;
+	
+	spin_lock(&lru_list_lock);
+	ret = !list_empty(&inode->i_dirty_buffers);
+	spin_unlock(&lru_list_lock);
+	
+	return ret;
+}
+
+
 /* If invalidate_buffers() will trash dirty buffers, it means some kind
    of fs corruption is going on. Trashing dirty data always imply losing
    information that was supposed to be just stored on the physical layer
@@ -801,6 +837,137 @@
 	return;
 }
 
+
+/*
+ * Synchronise all the inode's dirty buffers to the disk.
+ *
+ * We have conflicting pressures: we want to make sure that all
+ * initially dirty buffers get waited on, but that any subsequently
+ * dirtied buffers don't.  After all, we don't want fsync to last
+ * forever if somebody is actively writing to the file.
+ *
+ * Do this in two main stages: first we copy dirty buffers to a
+ * temporary inode list, queueing the writes as we go.  Then we clean
+ * up, waiting for those writes to complete.
+ * 
+ * During this second stage, any subsequent updates to the file may end
+ * up refiling the buffer on the original inode's dirty list again, so
+ * there is a chance we will end up with a buffer queued for write but
+ * not yet completed on that list.  So, as a final cleanup we go through
+ * the osync code to catch these locked, dirty buffers without requeuing
+ * any newly dirty buffers for write.
+ */
+
+int fsync_inode_buffers(struct inode *inode)
+{
+	struct buffer_head *bh;
+	struct inode tmp;
+	int err = 0, err2;
+	
+	INIT_LIST_HEAD(&tmp.i_dirty_buffers);
+	
+	spin_lock(&lru_list_lock);
+
+	while (!list_empty(&inode->i_dirty_buffers)) {
+		bh = BH_ENTRY(inode->i_dirty_buffers.next);
+		list_del(&bh->b_inode_buffers);
+		if (!buffer_dirty(bh) && !buffer_locked(bh))
+			bh->b_inode = NULL;
+		else {
+			bh->b_inode = &tmp;
+			list_add(&bh->b_inode_buffers, &tmp.i_dirty_buffers);
+			atomic_inc(&bh->b_count);
+			if (buffer_dirty(bh)) {
+				spin_unlock(&lru_list_lock);
+				ll_rw_block(WRITE, 1, &bh);
+				spin_lock(&lru_list_lock);
+			}
+		}
+	}
+
+	while (!list_empty(&tmp.i_dirty_buffers)) {
+		bh = BH_ENTRY(tmp.i_dirty_buffers.prev);
+		remove_inode_queue(bh);
+		spin_unlock(&lru_list_lock);
+		wait_on_buffer(bh);
+		if (!buffer_uptodate(bh))
+			err = -EIO;
+		brelse(bh);
+		spin_lock(&lru_list_lock);
+	}
+	
+	spin_unlock(&lru_list_lock);
+	err2 = osync_inode_buffers(inode);
+
+	if (err)
+		return err;
+	else
+		return err2;
+}
+
+
+/*
+ * osync is designed to support O_SYNC io.  It waits synchronously for
+ * all already-submitted IO to complete, but does not queue any new
+ * writes to the disk.
+ *
+ * To do O_SYNC writes, just queue the buffer writes with ll_rw_block as
+ * you dirty the buffers, and then use osync_inode_buffers to wait for
+ * completion.  Any other dirty buffers which are not yet queued for
+ * write will not be flushed to disk by the osync.
+ */
+
+int osync_inode_buffers(struct inode *inode)
+{
+	struct buffer_head *bh;
+	struct list_head *list;
+	int err = 0;
+
+	spin_lock(&lru_list_lock);
+	
+ repeat:
+	
+	for (list = inode->i_dirty_buffers.prev; 
+	     bh = BH_ENTRY(list), list != &inode->i_dirty_buffers;
+	     list = bh->b_inode_buffers.prev) {
+		if (buffer_locked(bh)) {
+			atomic_inc(&bh->b_count);
+			spin_unlock(&lru_list_lock);
+			wait_on_buffer(bh);
+			brelse(bh);
+			if (!buffer_uptodate(bh))
+				err = -EIO;
+			spin_lock(&lru_list_lock);
+			goto repeat;
+		}
+	}
+
+	spin_unlock(&lru_list_lock);
+	return err;
+}
+
+
+/*
+ * Invalidate any and all dirty buffers on a given inode.  We are
+ * probably unmounting the fs, but that doesn't mean we have already
+ * done a sync().  Just drop the buffers from the inode list.
+ */
+
+void invalidate_inode_buffers(struct inode *inode)
+{
+	struct list_head *list, *next;
+	
+	spin_lock(&lru_list_lock);
+	list = inode->i_dirty_buffers.next; 
+	while (list != &inode->i_dirty_buffers) {
+		next = list->next;
+		remove_inode_queue(BH_ENTRY(list));
+		list = next;
+	}
+	spin_unlock(&lru_list_lock);
+}
+
+
 /*
  * Ok, this is getblk, and it isn't very clear, again to hinder
  * race-conditions. Most of the code is seldom used, (ie repeating),
@@ -932,6 +1099,8 @@
 		__remove_from_lru_list(bh, bh->b_list);
 		bh->b_list = dispose;
 		__insert_into_lru_list(bh, dispose);
+		if (dispose == BUF_CLEAN)
+			remove_inode_queue(bh);
 	}
 }
 
@@ -968,6 +1137,7 @@
 	if (!atomic_dec_and_test(&buf->b_count) || buffer_locked(buf))
 		goto in_use;
 	__hash_unlink(buf);
+	remove_inode_queue(buf);
 	write_unlock(&hash_table_lock);
 	__remove_from_lru_list(buf, buf->b_list);
 	spin_unlock(&lru_list_lock);
@@ -1068,6 +1238,8 @@
  */
 static __inline__ void __put_unused_buffer_head(struct buffer_head * bh)
 {
+	if (bh->b_inode)
+		BUG();
 	if (nr_unused_buffer_heads >= MAX_UNUSED_BUFFERS) {
 		kmem_cache_free(bh_cachep, bh);
 	} else {
@@ -1315,8 +1487,10 @@
 	/* The bunffer can be either on the regular
 	 * queues or on the free list..
 	 */
-	if (bh->b_dev != B_FREE)
+	if (bh->b_dev != B_FREE) {
+		remove_inode_queue(bh);
 		__remove_from_queues(bh);
+	}
 	else
 		__remove_from_free_list(bh, index);
 	__put_unused_buffer_head(bh);	
@@ -1576,6 +1750,7 @@
 		} else {
 			set_bit(BH_Uptodate, &bh->b_state);
 			if (!atomic_set_buffer_dirty(bh)) {
+				buffer_insert_inode_queue(bh, inode);
 				__mark_dirty(bh, 0);
 				need_balance_dirty = 1;
 			}
@@ -2262,8 +2437,12 @@
 		/* The buffer can be either on the regular
 		 * queues or on the free list..
 		 */
-		if (p->b_dev != B_FREE)
+		if (p->b_dev != B_FREE) {
+			// @@@
+			if (p->b_inode)
+				BUG();
 			__remove_from_queues(p);
+		}
 		else
 			__remove_from_free_list(p, index);
 		__put_unused_buffer_head(p);
--- linux-2.4.0-test1-ac11.osync/fs/coda/dir.c.~1~	Mon May 29 09:46:07 2000
+++ linux-2.4.0-test1-ac11.osync/fs/coda/dir.c	Fri Jun  9 18:08:19 2000
@@ -50,7 +50,7 @@
 /* support routines */
 static int coda_venus_readdir(struct file *filp, void *dirent, 
 			      filldir_t filldir);
-int coda_fsync(struct file *, struct dentry *dentry);
+int coda_fsync(struct file *, struct dentry *dentry, int);
 
 int coda_crossvol_rename = 0;
 int coda_hasmknod = 0;
--- linux-2.4.0-test1-ac11.osync/fs/coda/file.c.~1~	Mon Feb 28 15:05:35 2000
+++ linux-2.4.0-test1-ac11.osync/fs/coda/file.c	Fri Jun  9 18:08:19 2000
@@ -30,7 +30,7 @@
 static int coda_file_mmap(struct file * file, struct vm_area_struct * vma);
 
 /* also exported from this file (used for dirs) */
-int coda_fsync(struct file *, struct dentry *dentry);
+int coda_fsync(struct file *, struct dentry *dentry, int);
 
 struct inode_operations coda_file_inode_operations = {
         permission:	coda_permission,
@@ -65,7 +65,7 @@
 	return res;
 }
 
-int coda_fsync(struct file *coda_file, struct dentry *coda_dentry)
+int coda_fsync(struct file *coda_file, struct dentry *coda_dentry, int datasync)
 {
         struct coda_inode_info *cnp;
 	struct inode *coda_inode = coda_dentry->d_inode;
@@ -96,7 +96,7 @@
 
 	down(&cont_inode->i_sem);
 
-        result = file_fsync(&cont_file ,&cont_dentry);
+        result = file_fsync(&cont_file ,&cont_dentry, 0);
 	if ( result == 0 ) {
 		result = venus_fsync(coda_inode->i_sb, &(cnp->c_fid));
 	}
--- linux-2.4.0-test1-ac11.osync/fs/ext2/dir.c.~1~	Wed Mar 29 22:35:20 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/dir.c	Fri Jun  9 18:08:19 2000
@@ -26,7 +26,7 @@
 	read:		generic_read_dir,
 	readdir:	ext2_readdir,
 	ioctl:		ext2_ioctl,
-	fsync:		ext2_sync_file,
+	fsync:		ext2_fsync_file,
 };
 
 int ext2_check_dir_entry (const char * function, struct inode * dir,
--- linux-2.4.0-test1-ac11.osync/fs/ext2/file.c.~1~	Mon Feb 28 15:05:35 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/file.c	Fri Jun  9 18:08:19 2000
@@ -91,6 +91,7 @@
 	return 0;
 }
 
+
 /*
  * We have mostly NULL's here: the current defaults are ok for
  * the ext2 filesystem.
@@ -103,7 +104,7 @@
 	mmap:		generic_file_mmap,
 	open:		ext2_open_file,
 	release:	ext2_release_file,
-	fsync:		ext2_sync_file,
+	fsync:		ext2_fsync_file,
 };
 
 struct inode_operations ext2_file_inode_operations = {
--- linux-2.4.0-test1-ac11.osync/fs/ext2/fsync.c.~1~	Fri Feb 11 12:00:42 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/fsync.c	Fri Jun  9 19:39:30 2000
@@ -27,131 +27,28 @@
 #include <linux/smp_lock.h>
 
 
-#define blocksize	(EXT2_BLOCK_SIZE(inode->i_sb))
-#define addr_per_block	(EXT2_ADDR_PER_BLOCK(inode->i_sb))
-
-static int sync_indirect(struct inode * inode, u32 * block, int wait)
-{
-	struct buffer_head * bh;
-	
-	if (!*block)
-		return 0;
-	bh = get_hash_table(inode->i_dev, le32_to_cpu(*block), blocksize);
-	if (!bh)
-		return 0;
-	if (wait && buffer_req(bh) && !buffer_uptodate(bh)) {
-		/* There can be a parallell read(2) that started read-I/O
-		   on the buffer so we can't assume that there's been
-		   an I/O error without first waiting I/O completation. */
-		wait_on_buffer(bh);
-		if (!buffer_uptodate(bh))
-		{
-			brelse (bh);
-			return -1;
-		}
-	}
-	if (wait || !buffer_uptodate(bh) || !buffer_dirty(bh)) {
-		if (wait)
-			/* when we return from fsync all the blocks
-			   must be _just_ stored on disk */
-			wait_on_buffer(bh);
-		brelse(bh);
-		return 0;
-	}
-	ll_rw_block(WRITE, 1, &bh);
-	atomic_dec(&bh->b_count);
-	return 0;
-}
-
-static int sync_iblock(struct inode * inode, u32 * iblock, 
-			struct buffer_head ** bh, int wait) 
-{
-	int rc, tmp;
-	
-	*bh = NULL;
-	tmp = le32_to_cpu(*iblock);
-	if (!tmp)
-		return 0;
-	rc = sync_indirect(inode, iblock, wait);
-	if (rc)
-		return rc;
-	*bh = bread(inode->i_dev, tmp, blocksize);
-	if (!*bh)
-		return -1;
-	return 0;
-}
-
-static int sync_dindirect(struct inode * inode, u32 * diblock, int wait)
-{
-	int i;
-	struct buffer_head * dind_bh;
-	int rc, err = 0;
-
-	rc = sync_iblock(inode, diblock, &dind_bh, wait);
-	if (rc || !dind_bh)
-		return rc;
-	
-	for (i = 0; i < addr_per_block; i++) {
-		rc = sync_indirect(inode, ((u32 *) dind_bh->b_data) + i, wait);
-		if (rc)
-			err = rc;
-	}
-	brelse(dind_bh);
-	return err;
-}
-
-static int sync_tindirect(struct inode * inode, u32 * tiblock, int wait)
-{
-	int i;
-	struct buffer_head * tind_bh;
-	int rc, err = 0;
-
-	rc = sync_iblock(inode, tiblock, &tind_bh, wait);
-	if (rc || !tind_bh)
-		return rc;
-	
-	for (i = 0; i < addr_per_block; i++) {
-		rc = sync_dindirect(inode, ((u32 *) tind_bh->b_data) + i, wait);
-		if (rc)
-			err = rc;
-	}
-	brelse(tind_bh);
-	return err;
-}
-
 /*
  *	File may be NULL when we are called. Perhaps we shouldn't
  *	even pass file to fsync ?
  */
 
-int ext2_sync_file(struct file * file, struct dentry *dentry)
+int ext2_fsync_file(struct file * file, struct dentry *dentry, int datasync)
 {
-	int wait, err = 0;
 	struct inode *inode = dentry->d_inode;
+	return ext2_fsync_inode(inode, datasync);
+}
 
-	lock_kernel();
-	if (S_ISLNK(inode->i_mode) && !(inode->i_blocks))
-		/*
-		 * Don't sync fast links!
-		 */
-		goto skip;
-
-	err = generic_buffer_fdatasync(inode, 0, ~0UL);
-
-	for (wait=0; wait<=1; wait++)
-	{
-		err |= sync_indirect(inode,
-				     inode->u.ext2_i.i_data+EXT2_IND_BLOCK,
-				     wait);
-		err |= sync_dindirect(inode,
-				      inode->u.ext2_i.i_data+EXT2_DIND_BLOCK, 
-				      wait);
-		err |= sync_tindirect(inode, 
-				      inode->u.ext2_i.i_data+EXT2_TIND_BLOCK, 
-				      wait);
-	}
-skip:
-	err |= ext2_sync_inode (inode);
-	unlock_kernel();
+int ext2_fsync_inode(struct inode *inode, int datasync)
+{
+	int err;
+	
+	err  = fsync_inode_buffers(inode);
+	if (!(inode->i_state & I_DIRTY))
+		return err;
+	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
+		return err;
+	
+	err |= ext2_sync_inode(inode);
 	return err ? -EIO : 0;
 }
+
--- linux-2.4.0-test1-ac11.osync/fs/ext2/inode.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/inode.c	Fri Jun  9 18:08:19 2000
@@ -403,11 +403,9 @@
 		*new = 1;
 	}
 	*p = le32_to_cpu(tmp);
-	mark_buffer_dirty(bh, 1);
-	if (IS_SYNC(inode) || inode->u.ext2_i.i_osync) {
+	mark_buffer_dirty_inode(bh, 1, inode);
+	if (IS_SYNC(inode) || inode->u.ext2_i.i_osync) 
 		ll_rw_block (WRITE, 1, &bh);
-		wait_on_buffer (bh);
-	}
 	inode->i_ctime = CURRENT_TIME;
 	inode->i_blocks += blocksize/512;
 	mark_inode_dirty(inode);
@@ -918,10 +916,10 @@
 	return err;
 }
 
-void ext2_write_inode (struct inode * inode)
+void ext2_write_inode (struct inode * inode, int wait)
 {
 	lock_kernel();
-	ext2_update_inode (inode, 0);
+	ext2_update_inode (inode, wait);
 	unlock_kernel();
 }
 
--- linux-2.4.0-test1-ac11.osync/fs/ext2/namei.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/namei.c	Fri Jun  9 18:08:19 2000
@@ -451,7 +451,7 @@
 	strcpy (de->name, "..");
 	ext2_set_de_type(dir->i_sb, de, S_IFDIR);
 	inode->i_nlink = 2;
-	mark_buffer_dirty(dir_block, 1);
+	mark_buffer_dirty_inode(dir_block, 1, dir);
 	brelse (dir_block);
 	inode->i_mode = S_IFDIR | mode;
 	if (dir->i_mode & S_ISGID)
@@ -788,7 +788,7 @@
 	mark_inode_dirty(old_dir);
 	if (dir_bh) {
 		PARENT_INO(dir_bh->b_data) = le32_to_cpu(new_dir->i_ino);
-		mark_buffer_dirty(dir_bh, 1);
+		mark_buffer_dirty_inode(dir_bh, 1, old_inode);
 		old_dir->i_nlink--;
 		mark_inode_dirty(old_dir);
 		if (new_inode) {
--- linux-2.4.0-test1-ac11.osync/fs/ext2/truncate.c.~1~	Fri Dec 10 15:24:41 1999
+++ linux-2.4.0-test1-ac11.osync/fs/ext2/truncate.c	Fri Jun  9 18:08:19 2000
@@ -211,7 +211,7 @@
 			inode->i_ino, tmp);
 		*p = 0;
 		if (dind_bh)
-			mark_buffer_dirty(dind_bh, 1);
+			mark_buffer_dirty_inode(dind_bh, 1, inode);
 		else
 			mark_inode_dirty(inode);
 		return 0;
@@ -279,7 +279,7 @@
 			inode->i_ino, tmp);
 		*p = 0;
 		if (tind_bh)
-			mark_buffer_dirty(tind_bh, 1);
+			mark_buffer_dirty_inode(tind_bh, 1, inode);
 		else
 			mark_inode_dirty(inode);
 		return 0;
--- linux-2.4.0-test1-ac11.osync/fs/inode.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/inode.c	Fri Jun  9 18:08:19 2000
@@ -96,6 +96,7 @@
 		INIT_LIST_HEAD(&inode->i_hash);
 		INIT_LIST_HEAD(&inode->i_data.pages);
 		INIT_LIST_HEAD(&inode->i_dentry);
+		INIT_LIST_HEAD(&inode->i_dirty_buffers);
 		sema_init(&inode->i_sem, 1);
 		sema_init(&inode->i_zombie, 1);
 		spin_lock_init(&inode->i_data.i_shared_lock);
@@ -122,14 +123,14 @@
  *	Mark an inode as dirty. Callers should use mark_inode_dirty.
  */
  
-void __mark_inode_dirty(struct inode *inode)
+void __mark_inode_dirty(struct inode *inode, int flags)
 {
 	struct super_block * sb = inode->i_sb;
 
 	if (sb) {
 		spin_lock(&inode_lock);
-		if (!(inode->i_state & I_DIRTY)) {
-			inode->i_state |= I_DIRTY;
+		if ((inode->i_state & flags) != flags) {
+			inode->i_state |= flags;
 			/* Only add valid (ie hashed) inodes to the dirty list */
 			if (!list_empty(&inode->i_hash)) {
 				list_del(&inode->i_list);
@@ -162,10 +163,10 @@
 }
 
 
-static inline void write_inode(struct inode *inode)
+static inline void write_inode(struct inode *inode, int wait)
 {
 	if (inode->i_sb && inode->i_sb->s_op && inode->i_sb->s_op->write_inode)
-		inode->i_sb->s_op->write_inode(inode);
+		inode->i_sb->s_op->write_inode(inode, wait);
 }
 
 static inline void __iget(struct inode * inode)
@@ -181,7 +182,7 @@
 	}
 }
 
-static inline void sync_one(struct inode *inode)
+static inline void sync_one(struct inode *inode, int wait)
 {
 	if (inode->i_state & I_LOCK) {
 		__iget(inode);
@@ -194,10 +195,11 @@
 		list_add(&inode->i_list,
 			 inode->i_count ? &inode_in_use : &inode_unused);
 		/* Set I_LOCK, reset I_DIRTY */
-		inode->i_state ^= I_DIRTY | I_LOCK;
+		inode->i_state |= I_LOCK;
+		inode->i_state &= ~I_DIRTY;
 		spin_unlock(&inode_lock);
 
-		write_inode(inode);
+		write_inode(inode, wait);
 
 		spin_lock(&inode_lock);
 		inode->i_state &= ~I_LOCK;
@@ -210,7 +212,7 @@
 	struct list_head * tmp;
 
 	while ((tmp = head->prev) != head)
-		sync_one(list_entry(tmp, struct inode, i_list));
+		sync_one(list_entry(tmp, struct inode, i_list), 0);
 }
 
 /**
@@ -243,6 +245,7 @@
 	spin_unlock(&inode_lock);
 }
 
+
 /*
  * Called with the spinlock already held..
  */
@@ -259,19 +262,20 @@
 /**
  *	write_inode_now	-	write an inode to disk
  *	@inode: inode to write to disk
+ *	@wait: if set, we wait for the write to complete on disk
  *
  *	This function commits an inode to disk immediately if it is
  *	dirty. This is primarily needed by knfsd.
  */
  
-void write_inode_now(struct inode *inode)
+void write_inode_now(struct inode *inode, int wait)
 {
 	struct super_block * sb = inode->i_sb;
 
 	if (sb) {
 		spin_lock(&inode_lock);
 		while (inode->i_state & I_DIRTY)
-			sync_one(inode);
+			sync_one(inode, wait);
 		spin_unlock(&inode_lock);
 	}
 	else
@@ -279,6 +283,60 @@
 }
 
 /**
+ * generic_osync_inode - flush all dirty data for a given inode to disk
+ * @inode: inode to write
+ * @datasync: if set, don't bother flushing timestamps
+ *
+ * This is called by generic_file_write for files which have the O_SYNC
+ * flag set, to flush dirty writes to disk.
+ */
+
+int generic_osync_inode(struct inode *inode, int datasync)
+{
+	int err;
+	
+	/* 
+	 * WARNING
+	 *
+	 * Currently, the filesystem write path does not pass the
+	 * filp down to the low-level write functions.  Therefore it
+	 * is impossible for (say) __block_commit_write to know if
+	 * the operation is O_SYNC or not.
+	 *
+	 * Ideally, O_SYNC writes would have the filesystem call
+	 * ll_rw_block as it went to kick-start the writes, and we
+	 * could call osync_inode_buffers() here to wait only for
+	 * those IOs which have already been submitted to the device
+	 * driver layer.  As it stands, if we did this we'd not write
+	 * anything to disk since our writes have not been queued by
+	 * this point: they are still on the dirty LRU.
+	 * 
+	 * So, currently we will call fsync_inode_buffers() instead,
+	 * to flush _all_ dirty buffers for this inode to disk on 
+	 * every O_SYNC write, not just the synchronous I/Os.  --sct
+	 */
+
+#ifdef WRITERS_QUEUE_IO
+	err = osync_inode_buffers(inode);
+#else
+	err = fsync_inode_buffers(inode);
+#endif
+
+	spin_lock(&inode_lock);
+	if (!(inode->i_state & I_DIRTY))
+		goto out;
+	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
+		goto out;
+	spin_unlock(&inode_lock);
+	write_inode_now(inode, 1);
+	return err;
+
+ out:
+	spin_unlock(&inode_lock);
+	return err;
+}
+
+/**
  * clear_inode - clear an inode
  * @inode: inode to clear
  *
@@ -347,6 +405,7 @@
 		inode = list_entry(tmp, struct inode, i_list);
 		if (inode->i_sb != sb)
 			continue;
+		invalidate_inode_buffers(inode);
 		if (!inode->i_count) {
 			list_del(&inode->i_hash);
 			INIT_LIST_HEAD(&inode->i_hash);
@@ -408,7 +467,8 @@
  *      dispose_list.
  */
 #define CAN_UNUSE(inode) \
-	(((inode)->i_state | (inode)->i_data.nrpages) == 0)
+	((((inode)->i_state | (inode)->i_data.nrpages) == 0) && \
+	 !inode_has_buffers(inode))
 #define INODE(entry)	(list_entry(entry, struct inode, i_list))
 
 void prune_icache(int goal)
@@ -913,7 +973,7 @@
 	if ( IS_NODIRATIME (inode) && S_ISDIR (inode->i_mode) ) return;
 	if ( IS_RDONLY (inode) ) return;
 	inode->i_atime = CURRENT_TIME;
-	mark_inode_dirty (inode);
+	mark_inode_dirty_sync (inode);
 }   /*  End Function update_atime  */
 
 
--- linux-2.4.0-test1-ac11.osync/fs/minix/fsync.c.~1~	Fri Feb 11 12:00:42 2000
+++ linux-2.4.0-test1-ac11.osync/fs/minix/fsync.c	Fri Jun  9 18:08:19 2000
@@ -329,7 +329,7 @@
  *	NULL
  */
  
-int minix_sync_file(struct file * file, struct dentry *dentry)
+int minix_sync_file(struct file * file, struct dentry *dentry, int datasync)
 {
 	struct inode *inode = dentry->d_inode;
 	
--- linux-2.4.0-test1-ac11.osync/fs/ncpfs/file.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/ncpfs/file.c	Fri Jun  9 18:08:19 2000
@@ -26,7 +26,7 @@
 	return a < b ? a : b;
 }
 
-static int ncp_fsync(struct file *file, struct dentry *dentry)
+static int ncp_fsync(struct file *file, struct dentry *dentry, int datasync)
 {
 	return 0;
 }
--- linux-2.4.0-test1-ac11.osync/fs/nfs/file.c.~1~	Thu Apr 27 16:15:27 2000
+++ linux-2.4.0-test1-ac11.osync/fs/nfs/file.c	Fri Jun  9 18:08:19 2000
@@ -39,7 +39,7 @@
 static ssize_t nfs_file_read(struct file *, char *, size_t, loff_t *);
 static ssize_t nfs_file_write(struct file *, const char *, size_t, loff_t *);
 static int  nfs_file_flush(struct file *);
-static int  nfs_fsync(struct file *, struct dentry *dentry);
+static int  nfs_fsync(struct file *, struct dentry *dentry, int);
 
 struct file_operations nfs_file_operations = {
 	read:		nfs_file_read,
@@ -124,7 +124,7 @@
  * whether any write errors occurred for this process.
  */
 static int
-nfs_fsync(struct file *file, struct dentry *dentry)
+nfs_fsync(struct file *file, struct dentry *dentry, int datasync)
 {
 	struct inode *inode = dentry->d_inode;
 	int status;
--- linux-2.4.0-test1-ac11.osync/fs/nfsd/vfs.c.~1~	Fri May 12 10:01:38 2000
+++ linux-2.4.0-test1-ac11.osync/fs/nfsd/vfs.c	Fri Jun  9 18:08:19 2000
@@ -312,7 +312,7 @@
 	if (err)
 		goto out_nfserr;
 	if (EX_ISSYNC(fhp->fh_export))
-		write_inode_now(inode);
+		write_inode_now(inode, 0);
 	err = 0;
 
 	/* Don't unlock inode; the nfssvc_release functions are supposed
@@ -514,7 +514,7 @@
 {
 	dprintk("nfsd: sync file %s\n", filp->f_dentry->d_name.name);
 	down(&filp->f_dentry->d_inode->i_sem);
-	filp->f_op->fsync(filp, filp->f_dentry);
+	filp->f_op->fsync(filp, filp->f_dentry,0);
 	up(&filp->f_dentry->d_inode->i_sem);
 }
 
@@ -522,10 +522,10 @@
 nfsd_sync_dir(struct dentry *dp)
 {
 	struct inode *inode = dp->d_inode;
-	int (*fsync) (struct file *, struct dentry *);
+	int (*fsync) (struct file *, struct dentry *, int);
 	
 	if (inode->i_fop && (fsync = inode->i_fop->fsync)) {
-		fsync(NULL, dp);
+		fsync(NULL, dp, 0);
 	}
 }
 
@@ -893,7 +893,7 @@
 
 	if (EX_ISSYNC(fhp->fh_export)) {
 		nfsd_sync_dir(dentry);
-		write_inode_now(dchild->d_inode);
+		write_inode_now(dchild->d_inode, 0);
 	}
 
 
@@ -1120,7 +1120,7 @@
 					| S_IFLNK;
 				err = notify_change(dnew, iap);
 				if (!err && EX_ISSYNC(fhp->fh_export))
-					write_inode_now(dentry->d_inode);
+					write_inode_now(dentry->d_inode, 0);
 		       }
 		}
 	} else
@@ -1180,7 +1180,7 @@
 	if (!err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
 			nfsd_sync_dir(ddir);
-			write_inode_now(dest);
+			write_inode_now(dest, 0);
 		}
 	} else {
 		if (err == -EXDEV && rqstp->rq_vers == 2)
--- linux-2.4.0-test1-ac11.osync/fs/qnx4/fsync.c.~1~	Fri Feb 11 12:00:42 2000
+++ linux-2.4.0-test1-ac11.osync/fs/qnx4/fsync.c	Fri Jun  9 18:08:19 2000
@@ -147,7 +147,7 @@
 	return err;
 }
 
-int qnx4_sync_file(struct file *file, struct dentry *dentry)
+int qnx4_sync_file(struct file *file, struct dentry *dentry, int datasync)
 {
         struct inode *inode = dentry->d_inode;
 	int wait, err = 0;
--- linux-2.4.0-test1-ac11.osync/fs/smbfs/file.c.~1~	Mon May 29 09:46:09 2000
+++ linux-2.4.0-test1-ac11.osync/fs/smbfs/file.c	Fri Jun  9 18:08:19 2000
@@ -27,7 +27,7 @@
 /* #define pr_debug printk */
 
 static int
-smb_fsync(struct file *file, struct dentry * dentry)
+smb_fsync(struct file *file, struct dentry * dentry, int datasync)
 {
 #ifdef SMBFS_DEBUG_VERBOSE
 printk("smb_fsync: sync file %s/%s\n", 
--- linux-2.4.0-test1-ac11.osync/fs/sysv/fsync.c.~1~	Fri Feb 11 12:00:42 2000
+++ linux-2.4.0-test1-ac11.osync/fs/sysv/fsync.c	Fri Jun  9 18:08:19 2000
@@ -178,7 +178,7 @@
 	return err;
 }
 
-int sysv_sync_file(struct file * file, struct dentry *dentry)
+int sysv_sync_file(struct file * file, struct dentry *dentry, int datasync)
 {
 	int wait, err = 0;
 	struct inode *inode = dentry->d_inode;
--- linux-2.4.0-test1-ac11.osync/include/linux/ext2_fs.h.~1~	Wed Mar 29 22:35:22 2000
+++ linux-2.4.0-test1-ac11.osync/include/linux/ext2_fs.h	Fri Jun  9 18:11:25 2000
@@ -548,7 +548,9 @@
 extern int ext2_write (struct inode *, struct file *, char *, int);
 
 /* fsync.c */
-extern int ext2_sync_file (struct file *, struct dentry *);
+extern int ext2_fsync_file (struct file *, struct dentry *, int);
+extern int ext2_fsync_inode (struct inode *, int);
+extern int ext2_osync_inode (struct inode *, int);
 
 /* ialloc.c */
 extern struct inode * ext2_new_inode (const struct inode *, int, int *);
@@ -562,7 +564,7 @@
 extern struct buffer_head * ext2_bread (struct inode *, int, int, int *);
 
 extern void ext2_read_inode (struct inode *);
-extern void ext2_write_inode (struct inode *);
+extern void ext2_write_inode (struct inode *, int);
 extern void ext2_put_inode (struct inode *);
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
--- linux-2.4.0-test1-ac11.osync/include/linux/fs.h.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/include/linux/fs.h	Fri Jun  9 18:11:26 2000
@@ -241,6 +241,9 @@
 	unsigned long b_rsector;	/* Real buffer location on disk */
 	wait_queue_head_t b_wait;
 	struct kiobuf * b_kiobuf;	/* kiobuf which owns this IO */
+
+	struct inode *	     b_inode;
+	struct list_head     b_inode_buffers;	/* doubly linked list of inode dirty buffers */
 };
 
 typedef void (bh_end_io_t)(struct buffer_head *bh, int uptodate);
@@ -380,6 +383,8 @@
 	struct list_head	i_list;
 	struct list_head	i_dentry;
 
+	struct list_head	i_dirty_buffers;
+
 	unsigned long		i_ino;
 	unsigned int		i_count;
 	kdev_t			i_dev;
@@ -446,16 +451,24 @@
 };
 
 /* Inode state bits.. */
-#define I_DIRTY		1
-#define I_LOCK		2
-#define I_FREEING	4
-#define I_CLEAR		8
+#define I_DIRTY_SYNC		1 /* Not dirty enough for O_DATASYNC */
+#define I_DIRTY_DATASYNC	2 /* Data-related inode changes pending */
+#define I_LOCK			4
+#define I_FREEING		8
+#define I_CLEAR			16
 
-extern void __mark_inode_dirty(struct inode *);
+#define I_DIRTY (I_DIRTY_SYNC | I_DIRTY_DATASYNC)
+
+extern void __mark_inode_dirty(struct inode *, int);
 static inline void mark_inode_dirty(struct inode *inode)
 {
-	if (!(inode->i_state & I_DIRTY))
-		__mark_inode_dirty(inode);
+	if ((inode->i_state & I_DIRTY) != I_DIRTY)
+		__mark_inode_dirty(inode, I_DIRTY);
+}
+static inline void mark_inode_dirty_sync(struct inode *inode)
+{
+	if (!(inode->i_state & I_DIRTY_SYNC))
+		__mark_inode_dirty(inode, I_DIRTY_SYNC);
 }
 
 struct fown_struct {
@@ -725,7 +738,7 @@
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *);
 	int (*release) (struct inode *, struct file *);
-	int (*fsync) (struct file *, struct dentry *);
+	int (*fsync) (struct file *, struct dentry *, int datasync);
 	int (*fasync) (int, struct file *, int);
 	int (*lock) (struct file *, int, struct file_lock *);
 	ssize_t (*readv) (struct file *, const struct iovec *, unsigned long, loff_t *);
@@ -758,7 +771,7 @@
  */
 struct super_operations {
 	void (*read_inode) (struct inode *);
-	void (*write_inode) (struct inode *);
+	void (*write_inode) (struct inode *, int);
 	void (*put_inode) (struct inode *);
 	void (*delete_inode) (struct inode *);
 	void (*put_super) (struct super_block *);
@@ -976,17 +989,28 @@
 	bh->b_end_io(bh, 0);
 }
 
+extern void buffer_insert_inode_queue(struct buffer_head *, struct inode *);
+static inline void mark_buffer_dirty_inode(struct buffer_head *bh, int flag, struct inode *inode)
+{
+	mark_buffer_dirty(bh, flag);
+	buffer_insert_inode_queue(bh, inode);
+}
+
 extern void balance_dirty(kdev_t);
 extern int check_disk_change(kdev_t);
 extern int invalidate_inodes(struct super_block *);
 extern void invalidate_inode_pages(struct inode *);
+extern void invalidate_inode_buffers(struct inode *);
 #define invalidate_buffers(dev)	__invalidate_buffers((dev), 0)
 #define destroy_buffers(dev)	__invalidate_buffers((dev), 1)
 extern void __invalidate_buffers(kdev_t dev, int);
 extern void sync_inodes(kdev_t);
-extern void write_inode_now(struct inode *);
+extern void write_inode_now(struct inode *, int);
 extern void sync_dev(kdev_t);
 extern int fsync_dev(kdev_t);
+extern int fsync_inode_buffers(struct inode *);
+extern int osync_inode_buffers(struct inode *);
+extern int inode_has_buffers(struct inode *);
 extern void sync_supers(kdev_t);
 extern int bmap(struct inode *, int);
 extern int notify_change(struct dentry *, struct iattr *);
@@ -1167,7 +1191,7 @@
 extern ssize_t char_write(struct file *, const char *, size_t, loff_t *);
 extern ssize_t block_write(struct file *, const char *, size_t, loff_t *);
 
-extern int file_fsync(struct file *, struct dentry *);
+extern int file_fsync(struct file *, struct dentry *, int);
 extern int generic_buffer_fdatasync(struct inode *inode, unsigned long start_idx, unsigned long end_idx);
 
 extern int inode_change_ok(struct inode *, struct iattr *);
--- linux-2.4.0-test1-ac11.osync/include/linux/minix_fs.h.~1~	Wed Mar 29 22:35:18 2000
+++ linux-2.4.0-test1-ac11.osync/include/linux/minix_fs.h	Fri Jun  9 18:08:19 2000
@@ -101,7 +101,7 @@
 
 extern void minix_truncate(struct inode *);
 extern int minix_sync_inode(struct inode *);
-extern int minix_sync_file(struct file *, struct dentry *);
+extern int minix_sync_file(struct file *, struct dentry *, int);
 
 extern struct address_space_operations minix_aops;
 extern struct inode_operations minix_file_inode_operations;
--- linux-2.4.0-test1-ac11.osync/include/linux/qnx4_fs.h.~1~	Wed Mar 29 22:35:18 2000
+++ linux-2.4.0-test1-ac11.osync/include/linux/qnx4_fs.h	Fri Jun  9 18:08:19 2000
@@ -116,7 +116,7 @@
 extern void qnx4_free_inode(struct inode *inode);
 extern int qnx4_unlink(struct inode *dir, struct dentry *dentry);
 extern int qnx4_rmdir(struct inode *dir, struct dentry *dentry);
-extern int qnx4_sync_file(struct file *file, struct dentry *dentry);
+extern int qnx4_sync_file(struct file *file, struct dentry *dentry, int);
 extern int qnx4_sync_inode(struct inode *inode);
 extern int qnx4_get_block(struct inode *inode, long iblock, struct buffer_head *bh, int create);
 
--- linux-2.4.0-test1-ac11.osync/mm/filemap.c.~1~	Fri Jun  9 18:08:09 2000
+++ linux-2.4.0-test1-ac11.osync/mm/filemap.c	Fri Jun  9 18:08:19 2000
@@ -1815,7 +1815,7 @@
 		if (!error && (flags & MS_SYNC)) {
 			struct file * file = vma->vm_file;
 			if (file && file->f_op && file->f_op->fsync)
-				error = file->f_op->fsync(file, file->f_dentry);
+				error = file->f_op->fsync(file, file->f_dentry, 1);
 		}
 		return error;
 	}
@@ -2554,7 +2554,7 @@
 	if (count) {
 		remove_suid(inode);
 		inode->i_ctime = inode->i_mtime = CURRENT_TIME;
-		mark_inode_dirty(inode);
+		mark_inode_dirty_sync(inode);
 	}
 
 	while (count) {
@@ -2611,7 +2611,13 @@
 	if (cached_page)
 		page_cache_free(cached_page);
 
+	/* For now, when the user asks for O_SYNC, we'll actually
+	 * provide O_DSYNC. */
+	if ((status >= 0) && (file->f_flags & O_SYNC))
+		status = generic_osync_inode(inode, 1); /* 1 means datasync */
+	
 	err = written ? written : status;
+
 out:
 	up(&inode->i_sem);
 	return err;

--+QahgC5+KEYLbs62--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
