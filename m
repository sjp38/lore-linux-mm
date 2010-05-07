Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E4CB6B0228
	for <linux-mm@kvack.org>; Fri,  7 May 2010 13:40:39 -0400 (EDT)
Date: Fri, 7 May 2010 13:40:29 -0400
From: Josef Bacik <josef@redhat.com>
Subject: [PATCH 2/5] direct-io: add a hook for the fs to provide its own
	submit_bio function V2
Message-ID: <20100507174028.GC3360@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: hch@infradead.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

V1->V2:
-Changed dio_end_io to EXPORT_SYMBOL_GPL
-Removed the own_submit blockdev dio helper
-Removed the boundary change

Because BTRFS can do RAID and such, we need our own submit hook so we can setup
the bio's in the correct fashion, and handle checksum errors properly.  So there
are a few changes here

1) The submit_io hook.  This is straightforward, just call this instead of
submit_bio.

2) Allow the fs to return -ENOTBLK for reads.  Usually this has only worked for
writes, since writes can fallback onto buffered IO.  But BTRFS needs the option
of falling back on buffered IO if it encounters a compressed extent, since we
need to read the entire extent in and decompress it.  So if we get -ENOTBLK back
from get_block we'll return back and fallback on buffered just like the write
case.

I've tested these changes with fsx and everything seems to work.  Thanks,

Signed-off-by: Josef Bacik <josef@redhat.com>
---
 fs/direct-io.c     |   27 ++++++++++++++++++++++-----
 include/linux/fs.h |   10 +++++++---
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index e82adc2..2dbf2e9 100644
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
+EXPORT_SYMBOL_GPL(dio_end_io);
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
@@ -935,7 +950,7 @@ static ssize_t
 direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode, 
 	const struct iovec *iov, loff_t offset, unsigned long nr_segs, 
 	unsigned blkbits, get_block_t get_block, dio_iodone_t end_io,
-	struct dio *dio)
+	dio_submit_t submit_io, struct dio *dio)
 {
 	unsigned long user_addr; 
 	unsigned long flags;
@@ -952,6 +967,7 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 
 	dio->get_block = get_block;
 	dio->end_io = end_io;
+	dio->submit_io = submit_io;
 	dio->final_block_in_bio = -1;
 	dio->next_block_for_io = -1;
 
@@ -1008,7 +1024,7 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 		}
 	} /* end iovec loop */
 
-	if (ret == -ENOTBLK && (rw & WRITE)) {
+	if (ret == -ENOTBLK) {
 		/*
 		 * The remaining part of the request will be
 		 * be handled by buffered I/O when we return
@@ -1110,7 +1126,7 @@ ssize_t
 __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 	struct block_device *bdev, const struct iovec *iov, loff_t offset, 
 	unsigned long nr_segs, get_block_t get_block, dio_iodone_t end_io,
-	int flags)
+	dio_submit_t submit_io,	int flags)
 {
 	int seg;
 	size_t size;
@@ -1197,7 +1213,8 @@ __blockdev_direct_IO(int rw, struct kiocb *iocb, struct inode *inode,
 		(end > i_size_read(inode)));
 
 	retval = direct_io_worker(rw, iocb, inode, iov, offset,
-				nr_segs, blkbits, get_block, end_io, dio);
+				nr_segs, blkbits, get_block, end_io,
+				submit_io, dio);
 
 	/*
 	 * In case of error extending write may have instantiated a few
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 44f35ae..9e76d01 100644
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
 
@@ -2279,7 +2283,7 @@ static inline ssize_t blockdev_direct_IO_no_locking(int rw, struct kiocb *iocb,
 	dio_iodone_t end_io)
 {
 	return __blockdev_direct_IO(rw, iocb, inode, bdev, iov, offset,
-				nr_segs, get_block, end_io, 0);
+				    nr_segs, get_block, end_io, NULL, 0);
 }
 #endif
 
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
