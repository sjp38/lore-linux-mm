Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A376962009A
	for <linux-mm@kvack.org>; Thu,  6 May 2010 14:51:51 -0400 (EDT)
Date: Thu, 6 May 2010 15:00:38 -0400
From: Josef Bacik <josef@redhat.com>
Subject: [PATCH 2/3] direct-io: add a hook for the fs to provide its own
	submit_bio function
Message-ID: <20100506190037.GC13974@dhcp231-156.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Because BTRFS can do RAID and such, we need our own submit hook so we can setup
the bio's in the correct fashion, and handle checksum errors properly.  So there
are a few changes here

1) The submit_io hook.  This is straightforward, just call this instead of
submit_bio.

2) Honor the boundary flag a little more specifically.  BTRFS needs to supply
the _logical_ offset to the map_bh in it's get_block function so when we go to
submit the IO we can look up the right checksum information.  In order for this
to work out, we need to make sure each extent we map through get_block gets sent
individually.  The direct IO code tries to merge things together that appear to
be side by side, but since we are using logical offsets, thats always going to
be the case.  So instead of clearing dio->boundary when we create a new bio,
save it in a local variable, and submit the io if boundary was set.

3) Allow the fs to return -ENOTBLK for reads.  Usually this has only worked for
writes, since writes can fallback onto buffered IO.  But BTRFS needs the option
of falling back on buffered IO if it encounters a compressed extent, since we
need to read the entire extent in and decompress it.  So if we get -ENOTBLK back
from get_block we'll return back and fallback on buffered just like the write
case.

I've tested these changes with fsx and everything seems to work.  Thanks,

Signed-off-by: Josef Bacik <josef@redhat.com>
---
 fs/direct-io.c     |   32 ++++++++++++++++++++++++++------
 include/linux/fs.h |   19 ++++++++++++++++---
 2 files changed, 42 insertions(+), 9 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index e82adc2..3d174df 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -82,6 +82,7 @@ struct dio {
 	int reap_counter;		/* rate limit reaping */
 	get_block_t *get_block;		/* block mapping function */
 	dio_iodone_t *end_io;		/* IO completion function */
+	dio_submit_t *submit_io;	/* IO submition function */
 	sector_t final_block_in_bio;	/* current final block in bio + 1 */
 	sector_t next_block_for_io;	/* next block to be put under IO,
 					   in dio_blocks units */
@@ -300,6 +301,17 @@ static void dio_bio_end_io(struct bio *bio, int error)
 	spin_unlock_irqrestore(&dio->bio_lock, flags);
 }
 
+void dio_end_io(struct bio *bio, int error)
+{
+	struct dio *dio = bio->bi_private;
+
+	if (dio->is_async)
+		dio_bio_end_aio(bio, error);
+	else
+		dio_bio_end_io(bio, error);
+}
+EXPORT_SYMBOL(dio_end_io);
+
 static int
 dio_bio_alloc(struct dio *dio, struct block_device *bdev,
 		sector_t first_sector, int nr_vecs)
@@ -340,7 +352,10 @@ static void dio_bio_submit(struct dio *dio)
 	if (dio->is_async && dio->rw == READ)
 		bio_set_pages_dirty(bio);
 
-	submit_bio(dio->rw, bio);
+	if (!dio->submit_io)
+		submit_bio(dio->rw, bio);
+	else
+		dio->submit_io(dio->rw, bio, dio->inode);
 
 	dio->bio = NULL;
 	dio->boundary = 0;
@@ -600,6 +615,7 @@ static int dio_bio_add_page(struct dio *dio)
  */
 static int dio_send_cur_page(struct dio *dio)
 {
+	int boundary = dio->boundary;
 	int ret = 0;
 
 	if (dio->bio) {
@@ -612,7 +628,7 @@ static int dio_send_cur_page(struct dio *dio)
 		 * Submit now if the underlying fs is about to perform a
 		 * metadata read
 		 */
-		if (dio->boundary)
+		if (boundary)
 			dio_bio_submit(dio);
 	}
 
@@ -629,6 +645,8 @@ static int dio_send_cur_page(struct dio *dio)
 			ret = dio_bio_add_page(dio);
 			BUG_ON(ret != 0);
 		}
+	} else if (boundary) {
+		dio_bio_submit(dio);
 	}
 out:
 	return ret;
@@ -935,7 +953,7 @@ static ssize_t
 direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode, 
 	const struct iovec *iov, loff_t offset, unsigned long nr_segs, 
 	unsigned blkbits, get_block_t get_block, dio_iodone_t end_io,
-	struct dio *dio)
+	dio_submit_t submit_io, struct dio *dio)
 {
 	unsigned long user_addr; 
 	unsigned long flags;
@@ -952,6 +970,7 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 
 	dio->get_block = get_block;
 	dio->end_io = end_io;
+	dio->submit_io = submit_io;
 	dio->final_block_in_bio = -1;
 	dio->next_block_for_io = -1;
 
@@ -1008,7 +1027,7 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 		}
 	} /* end iovec loop */
 
-	if (ret == -ENOTBLK && (rw & WRITE)) {
+	if (ret == -ENOTBLK) {
 		/*
 		 * The remaining part of the request will be
 		 * be handled by buffered I/O when we return
@@ -1110,7 +1129,7 @@ ssize_t
 __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 	struct block_device *bdev, const struct iovec *iov, loff_t offset, 
 	unsigned long nr_segs, get_block_t get_block, dio_iodone_t end_io,
-	int flags)
+	dio_submit_t submit_io,	int flags)
 {
 	int seg;
 	size_t size;
@@ -1197,7 +1216,8 @@ __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 		(end > i_size_read(inode)));
 
 	retval = direct_io_worker(rw, iocb, inode, iov, offset,
-				nr_segs, blkbits, get_block, end_io, dio);
+				nr_segs, blkbits, get_block, end_io,
+				submit_io, dio);
 
 	/*
 	 * In case of error extending write may have instantiated a few
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 44f35ae..d56f0be 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2250,10 +2250,14 @@ static inline int xip_truncate_page(struct address_space *mapping, loff_t from)
 #endif
 
 #ifdef CONFIG_BLOCK
+struct bio;
+typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode);
+void dio_end_io(struct bio *bio, int error);
+
 ssize_t __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 	struct block_device *bdev, const struct iovec *iov, loff_t offset,
 	unsigned long nr_segs, get_block_t get_block, dio_iodone_t end_io,
-	int lock_type);
+	dio_submit_t submit_io,	int lock_type);
 
 enum {
 	/* need locking between buffered and direct access */
@@ -2269,7 +2273,7 @@ static inline ssize_t blockdev_direct_IO(int rw, struct kiocb *iocb,
 	dio_iodone_t end_io)
 {
 	return __blockdev_direct_IO(rw, iocb, inode, bdev, iov, offset,
-				    nr_segs, get_block, end_io,
+				    nr_segs, get_block, end_io, NULL,
 				    DIO_LOCKING | DIO_SKIP_HOLES);
 }
 
@@ -2279,7 +2283,16 @@ static inline ssize_t blockdev_direct_IO_no_locking(int rw, struct kiocb *iocb,
 	dio_iodone_t end_io)
 {
 	return __blockdev_direct_IO(rw, iocb, inode, bdev, iov, offset,
-				nr_segs, get_block, end_io, 0);
+				    nr_segs, get_block, end_io, NULL, 0);
+}
+
+static inline ssize_t blockdev_direct_IO_own_submit(int rw, struct kiocb *iocb,
+	struct inode *inode, struct block_device *bdev, const struct iovec *iov,
+	loff_t offset, unsigned long nr_segs, get_block_t get_block,
+	dio_submit_t submit_io)
+{
+	return __blockdev_direct_IO(rw, iocb, inode, bdev, iov, offset,
+				    nr_segs, get_block, NULL, submit_io, 0);
 }
 #endif
 
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
