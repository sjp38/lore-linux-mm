Date: Fri, 6 Aug 1999 03:11:56 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Reply-To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [PATCH] ext2_updatepage for 2.2.11
Message-ID: <Pine.LNX.3.96.990806021518.3158A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Stephen et all,

Below is my version of a fix for the SMP shared mmap bug by making ext2
write through the page cache using generic_file_write, plus an enhancement
to eliminate extraneous zeroing of freshly allocated buffers (and possible
unnescessary reading).  Could you look over it and tell me what you think? 
It's against Linus' 2.2.11-1, but I'll rework it into Alan's proposed
2.2.11-4 if you think it's good enough.  Also, look at the difference in
bonnie results for a file that fits entirely in memory:

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec  %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
base       16 10077  97.8 14936 43.8  7687  68.0 10037 100.5 44547 97.9 5833.0 193.9
updatepage 16  9496 100.3 25810 99.2 23910 100.7 13717  99.6 47550 98.7 6564.4 195.3

Nice, eh?  The difference in Rewrite is shocking, I ran the tests several
times to retest, but it's true -- eliminating the unneeded buffer cache
lookups/waits/reads is dead simple since generic_file_write takes care of
all the races for us.

		-ben (who thinks he'll go sleep now)

#----begin ben-2.2.11-1+ext2_updatepage.diff----

diff -urH clean/2.2.11-1/fs/ext2/balloc.c 2.2.11-1/fs/ext2/balloc.c
--- clean/2.2.11-1/fs/ext2/balloc.c	Thu Oct 29 00:54:56 1998
+++ 2.2.11-1/fs/ext2/balloc.c	Fri Aug  6 01:30:20 1999
@@ -358,7 +358,7 @@
  * bitmap, and then for any free bit if that fails.
  */
 int ext2_new_block (const struct inode * inode, unsigned long goal,
-		    u32 * prealloc_count, u32 * prealloc_block, int * err)
+		    u32 * prealloc_count, u32 * prealloc_block, int * err, int create)
 {
 	struct buffer_head * bh;
 	struct buffer_head * bh2;
@@ -599,15 +599,19 @@
 		unlock_super (sb);
 		return 0;
 	}
-	if (!(bh = getblk (sb->s_dev, j, sb->s_blocksize))) {
-		ext2_error (sb, "ext2_new_block", "cannot get block %d", j);
-		unlock_super (sb);
-		return 0;
+
+	/* if caller has said the block doesn't need to be zero'd, don't! -ben */
+	if (create != 2) {
+		if (!(bh = getblk (sb->s_dev, j, sb->s_blocksize))) {
+			ext2_error (sb, "ext2_new_block", "cannot get block %d", j);
+			unlock_super (sb);
+			return 0;
+		}
+		memset(bh->b_data, 0, sb->s_blocksize);
+		mark_buffer_uptodate(bh, 1);
+		mark_buffer_dirty(bh, 1);
+		brelse (bh);
 	}
-	memset(bh->b_data, 0, sb->s_blocksize);
-	mark_buffer_uptodate(bh, 1);
-	mark_buffer_dirty(bh, 1);
-	brelse (bh);
 
 	ext2_debug ("allocating block %d. "
 		    "Goal hits %d of %d.\n", j, goal_hits, goal_attempts);
diff -urH clean/2.2.11-1/fs/ext2/file.c 2.2.11-1/fs/ext2/file.c
--- clean/2.2.11-1/fs/ext2/file.c	Fri Jul 23 20:41:13 1999
+++ 2.2.11-1/fs/ext2/file.c	Fri Aug  6 01:40:50 1999
@@ -31,11 +31,11 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 
-#define	NBUF	32
-
 #define MIN(a,b) (((a)<(b))?(a):(b))
 #define MAX(a,b) (((a)>(b))?(a):(b))
 
+static int ext2_updatepage(struct file *filp, struct page *page,
+		unsigned long offset, unsigned int bytes, int sync);
 static long long ext2_file_lseek(struct file *, long long, int);
 static ssize_t ext2_file_write (struct file *, const char *, size_t, loff_t *);
 static int ext2_release_file (struct inode *, struct file *);
@@ -100,7 +100,8 @@
 	ext2_bmap,		/* bmap */
 	ext2_truncate,		/* truncate */
 	ext2_permission,	/* permission */
-	NULL			/* smap */
+	NULL,			/* smap */
+	ext2_updatepage
 };
 
 /*
@@ -156,22 +157,11 @@
 {
 	struct inode * inode = filp->f_dentry->d_inode;
 	off_t pos;
-	long block;
-	int offset;
-	int written, c;
-	struct buffer_head * bh, *bufferlist[NBUF];
 	struct super_block * sb;
-	int err;
-	int i,buffercount,write_error, new_buffer;
 
 	/* POSIX: mtime/ctime may not change for 0 count */
 	if (!count)
 		return 0;
-	write_error = buffercount = 0;
-	if (!inode) {
-		printk("ext2_file_write: inode = NULL\n");
-		return -EINVAL;
-	}
 	sb = inode->i_sb;
 	if (sb->s_flags & MS_RDONLY)
 		/*
@@ -234,48 +224,58 @@
 	 */
 	if (filp->f_flags & O_SYNC)
 		inode->u.ext2_i.i_osync++;
+
+	*ppos = pos;
+
+	/* Okay, this is different from before: we now write through the page
+	 * cache and do all the real work in updatepage. -ben
+	 */
+	count = generic_file_write(filp, buf, count, ppos);
+
+	if (filp->f_flags & O_SYNC)
+		inode->u.ext2_i.i_osync--;
+	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
+	mark_inode_dirty(inode);
+	return count;
+}
+
+/* stuff formerly in ext2_file_write
+ */
+static int ext2_updatepage(struct file *filp, struct page *page,
+		unsigned long offset, unsigned int bytes, int sync)
+{
+	struct inode * inode = filp->f_dentry->d_inode;
+	struct buffer_head * bh, *bufferlist[PAGE_SIZE/512];
+	struct super_block * sb = inode->i_sb;
+	long block;
+	int written, c;
+	int err;
+	int i,buffercount,write_error;
+	const char *buf = (char *)page_address(page) + offset;
+	off_t pos = page->offset + offset;
+	int count = bytes;
+
+	write_error = buffercount = 0;
 	block = pos >> EXT2_BLOCK_SIZE_BITS(sb);
 	offset = pos & (sb->s_blocksize - 1);
 	c = sb->s_blocksize - offset;
 	written = 0;
 	do {
-		bh = ext2_getblk (inode, block, 1, &err);
+		if (c > count)
+			c = count;
+		bh = ext2_getblk (inode, block, (c == sb->s_blocksize) ? 2 : 1, &err);
 		if (!bh) {
 			if (!written)
 				written = err;
 			break;
 		}
-		if (c > count)
-			c = count;
 
-		/* Tricky: what happens if we are writing the complete
-		 * contents of a block which is not currently
-		 * initialised?  We have to obey the same
-		 * synchronisation rules as the IO code, to prevent some
-		 * other process from stomping on the buffer contents by
-		 * refreshing them from disk while we are setting up the
-		 * buffer.  The copy_from_user() can page fault, after
-		 * all.  We also have to throw away partially successful
-		 * copy_from_users to such buffers, since we can't trust
-		 * the rest of the buffer_head in that case.  --sct */
-
-		new_buffer = (!buffer_uptodate(bh) && !buffer_locked(bh) &&
-			      c == sb->s_blocksize);
-
-		if (new_buffer) {
-			set_bit(BH_Lock, &bh->b_state);
-			c -= copy_from_user (bh->b_data + offset, buf, c);
-			if (c != sb->s_blocksize) {
-				c = 0;
-				unlock_buffer(bh);
-				brelse(bh);
-				if (!written)
-					written = -EFAULT;
-				break;
-			}
-			mark_buffer_uptodate(bh, 1);
-			unlock_buffer(bh);
-		} else {
+		/* if someone else is reading the buffer, wait for it to complete. -ben */
+		if (buffer_locked(bh))
+			wait_on_buffer(bh);
+
+		/* only read the buffer if we must. */
+		if (c != sb->s_blocksize) {
 			if (!buffer_uptodate(bh)) {
 				ll_rw_block (READ, 1, &bh);
 				wait_on_buffer (bh);
@@ -286,41 +286,27 @@
 					break;
 				}
 			}
-			c -= copy_from_user (bh->b_data + offset, buf, c);
-		}
-		if (!c) {
-			brelse(bh);
-			if (!written)
-				written = -EFAULT;
-			break;
 		}
+		memcpy(bh->b_data + offset, buf, c);
+		if (c == sb->s_blocksize && !buffer_uptodate(bh))
+			mark_buffer_uptodate(bh, 1);
 		mark_buffer_dirty(bh, 0);
-		update_vm_cache(inode, pos, bh->b_data + offset, c);
-		pos += c;
 		written += c;
 		buf += c;
 		count -= c;
 
-		if (filp->f_flags & O_SYNC)
+		if (sync)
 			bufferlist[buffercount++] = bh;
 		else
 			brelse(bh);
-		if (buffercount == NBUF){
-			ll_rw_block(WRITE, buffercount, bufferlist);
-			for(i=0; i<buffercount; i++){
-				wait_on_buffer(bufferlist[i]);
-				if (!buffer_uptodate(bufferlist[i]))
-					write_error=1;
-				brelse(bufferlist[i]);
-			}
-			buffercount=0;
-		}
-		if(write_error)
-			break;
 		block++;
 		offset = 0;
 		c = sb->s_blocksize;
 	} while (count);
+
+	if (PAGE_SIZE == written)
+		set_bit(PG_uptodate, &page->flags);
+
 	if ( buffercount ){
 		ll_rw_block(WRITE, buffercount, bufferlist);
 		for(i=0; i<buffercount; i++){
@@ -329,15 +315,9 @@
 				write_error=1;
 			brelse(bufferlist[i]);
 		}
-	}		
-	if (pos > inode->i_size)
-		inode->i_size = pos;
-	if (filp->f_flags & O_SYNC)
-		inode->u.ext2_i.i_osync--;
-	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
-	*ppos = pos;
-	mark_inode_dirty(inode);
-	return written;
+	}
+
+	return write_error ? -EIO : written;
 }
 
 /*
diff -urH clean/2.2.11-1/fs/ext2/inode.c 2.2.11-1/fs/ext2/inode.c
--- clean/2.2.11-1/fs/ext2/inode.c	Tue May  4 19:27:07 1999
+++ 2.2.11-1/fs/ext2/inode.c	Fri Aug  6 01:31:25 1999
@@ -92,7 +92,7 @@
 #endif
 }
 
-static int ext2_alloc_block (struct inode * inode, unsigned long goal, int * err)
+static int ext2_alloc_block (struct inode * inode, unsigned long goal, int * err, int create)
 {
 #ifdef EXT2FS_DEBUG
 	static unsigned long alloc_hits = 0, alloc_attempts = 0;
@@ -112,19 +112,21 @@
 		ext2_debug ("preallocation hit (%lu/%lu).\n",
 			    ++alloc_hits, ++alloc_attempts);
 
-		/* It doesn't matter if we block in getblk() since
-		   we have already atomically allocated the block, and
-		   are only clearing it now. */
-		if (!(bh = getblk (inode->i_sb->s_dev, result,
-				   inode->i_sb->s_blocksize))) {
-			ext2_error (inode->i_sb, "ext2_alloc_block",
-				    "cannot get block %lu", result);
-			return 0;
+		if (create != 2) {
+			/* It doesn't matter if we block in getblk() since
+			   we have already atomically allocated the block, and
+			   are only clearing it now. */
+			if (!(bh = getblk (inode->i_sb->s_dev, result,
+					   inode->i_sb->s_blocksize))) {
+				ext2_error (inode->i_sb, "ext2_alloc_block",
+					    "cannot get block %lu", result);
+				return 0;
+			}
+			memset(bh->b_data, 0, inode->i_sb->s_blocksize);
+			mark_buffer_uptodate(bh, 1);
+			mark_buffer_dirty(bh, 1);
+			brelse (bh);
 		}
-		memset(bh->b_data, 0, inode->i_sb->s_blocksize);
-		mark_buffer_uptodate(bh, 1);
-		mark_buffer_dirty(bh, 1);
-		brelse (bh);
 	} else {
 		ext2_discard_prealloc (inode);
 		ext2_debug ("preallocation miss (%lu/%lu).\n",
@@ -132,12 +134,12 @@
 		if (S_ISREG(inode->i_mode))
 			result = ext2_new_block (inode, goal, 
 				 &inode->u.ext2_i.i_prealloc_count,
-				 &inode->u.ext2_i.i_prealloc_block, err);
+				 &inode->u.ext2_i.i_prealloc_block, err, create);
 		else
-			result = ext2_new_block (inode, goal, 0, 0, err);
+			result = ext2_new_block (inode, goal, 0, 0, err, create);
 	}
 #else
-	result = ext2_new_block (inode, goal, 0, 0, err);
+	result = ext2_new_block (inode, goal, 0, 0, err, create);
 #endif
 
 	return result;
@@ -256,7 +258,7 @@
 
 	ext2_debug ("goal = %d.\n", goal);
 
-	tmp = ext2_alloc_block (inode, goal, err);
+	tmp = ext2_alloc_block (inode, goal, err, create);
 	if (!tmp)
 		return NULL;
 	result = getblk (inode->i_dev, tmp, inode->i_sb->s_blocksize);
@@ -338,7 +340,7 @@
 		if (!goal)
 			goal = bh->b_blocknr;
 	}
-	tmp = ext2_alloc_block (inode, goal, err);
+	tmp = ext2_alloc_block (inode, goal, err, create);
 	if (!tmp) {
 		brelse (bh);
 		return NULL;
@@ -404,24 +406,24 @@
 		return inode_getblk (inode, block, create, b, err);
 	block -= EXT2_NDIR_BLOCKS;
 	if (block < addr_per_block) {
-		bh = inode_getblk (inode, EXT2_IND_BLOCK, create, b, err);
+		bh = inode_getblk (inode, EXT2_IND_BLOCK, !!create, b, err);
 		return block_getblk (inode, bh, block, create,
 				     inode->i_sb->s_blocksize, b, err);
 	}
 	block -= addr_per_block;
 	if (block < (1 << (addr_per_block_bits * 2))) {
-		bh = inode_getblk (inode, EXT2_DIND_BLOCK, create, b, err);
+		bh = inode_getblk (inode, EXT2_DIND_BLOCK, !!create, b, err);
 		bh = block_getblk (inode, bh, block >> addr_per_block_bits,
-				   create, inode->i_sb->s_blocksize, b, err);
+				   !!create, inode->i_sb->s_blocksize, b, err);
 		return block_getblk (inode, bh, block & (addr_per_block - 1),
 				     create, inode->i_sb->s_blocksize, b, err);
 	}
 	block -= (1 << (addr_per_block_bits * 2));
-	bh = inode_getblk (inode, EXT2_TIND_BLOCK, create, b, err);
+	bh = inode_getblk (inode, EXT2_TIND_BLOCK, !!create, b, err);
 	bh = block_getblk (inode, bh, block >> (addr_per_block_bits * 2),
-			   create, inode->i_sb->s_blocksize, b, err);
+			   !!create, inode->i_sb->s_blocksize, b, err);
 	bh = block_getblk (inode, bh, (block >> addr_per_block_bits) & (addr_per_block - 1),
-			   create, inode->i_sb->s_blocksize, b, err);
+			   !!create, inode->i_sb->s_blocksize, b, err);
 	return block_getblk (inode, bh, block & (addr_per_block - 1), create,
 			     inode->i_sb->s_blocksize, b, err);
 }
diff -urH clean/2.2.11-1/include/linux/ext2_fs.h 2.2.11-1/include/linux/ext2_fs.h
--- clean/2.2.11-1/include/linux/ext2_fs.h	Sat Apr 24 00:20:38 1999
+++ 2.2.11-1/include/linux/ext2_fs.h	Fri Aug  6 01:32:04 1999
@@ -522,7 +522,7 @@
 /* balloc.c */
 extern int ext2_group_sparse(int group);
 extern int ext2_new_block (const struct inode *, unsigned long,
-			   __u32 *, __u32 *, int *);
+			   __u32 *, __u32 *, int *, int);
 extern void ext2_free_blocks (const struct inode *, unsigned long,
 			      unsigned long);
 extern unsigned long ext2_count_free_blocks (struct super_block *);
diff -urH clean/2.2.11-1/mm/filemap.c 2.2.11-1/mm/filemap.c
--- clean/2.2.11-1/mm/filemap.c	Tue May 11 11:51:13 1999
+++ 2.2.11-1/mm/filemap.c	Sat Jul 31 19:16:20 1999
@@ -1515,8 +1515,11 @@
 		 * Do the real work.. If the writer ends up delaying the write,
 		 * the writer needs to increment the page use counts until he
 		 * is done with the page.
+		 * But don't perform the copy if it's from the same place, as
+		 * that's a Bad Thing to do on SMP!
 		 */
-		bytes -= copy_from_user((u8*)page_address(page) + offset, buf, bytes);
+		if (!segment_eq(get_fs(), KERNEL_DS) || (((u8 *)page_address(page) + offset) != (u8 *)buf))
+			bytes -= copy_from_user((u8*)page_address(page) + offset, buf, bytes);
 		status = -EFAULT;
 		if (bytes)
 			status = inode->i_op->updatepage(file, page, offset, bytes, sync);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
