Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id E71516B0010
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:50:33 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 5/6] fs: Take mapping lock during direct IO
Date: Thu, 31 Jan 2013 22:49:53 +0100
Message-Id: <1359668994-13433-6-git-send-email-jack@suse.cz>
In-Reply-To: <1359668994-13433-1-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Make direct IO code grab mapping range lock just before DIO is submitted
for the range under IO and release the lock once the IO is complete.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/direct-io.c |   67 +++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/fs/direct-io.c b/fs/direct-io.c
index 3a430f3..1127ca5 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -56,10 +56,13 @@
  * blocksize.
  */
 
+struct dio_bio_data;
+
 /* dio_state only used in the submission path */
 
 struct dio_submit {
 	struct bio *bio;		/* bio under assembly */
+	struct dio_bio_data *bio_data;	/* structure to be attached to the bio*/
 	unsigned blkbits;		/* doesn't change */
 	unsigned blkfactor;		/* When we're using an alignment which
 					   is finer than the filesystem's soft
@@ -143,7 +146,17 @@ struct dio {
 	struct page *pages[DIO_PAGES];	/* page buffer */
 } ____cacheline_aligned_in_smp;
 
+/*
+ * Structure associated with each submitted bio to provide back pointer and
+ * lock for the range accessed by the bio.
+ */
+struct dio_bio_data {
+	struct dio *dio;
+	struct range_lock lock;
+};
+
 static struct kmem_cache *dio_cache __read_mostly;
+static struct kmem_cache *dio_bio_data_cache __read_mostly;
 
 /*
  * How many pages are in the queue?
@@ -275,10 +288,13 @@ static int dio_bio_complete(struct dio *dio, struct bio *bio);
  */
 static void dio_bio_end_aio(struct bio *bio, int error)
 {
-	struct dio *dio = bio->bi_private;
+	struct dio_bio_data *bio_data = bio->bi_private;
+	struct dio *dio = bio_data->dio;
 	unsigned long remaining;
 	unsigned long flags;
 
+	range_unlock(&dio->inode->i_mapping->mapping_lock, &bio_data->lock);
+	kmem_cache_free(dio_bio_data_cache, bio_data);
 	/* cleanup the bio */
 	dio_bio_complete(dio, bio);
 
@@ -298,14 +314,17 @@ static void dio_bio_end_aio(struct bio *bio, int error)
  * The BIO completion handler simply queues the BIO up for the process-context
  * handler.
  *
- * During I/O bi_private points at the dio.  After I/O, bi_private is used to
- * implement a singly-linked list of completed BIOs, at dio->bio_list.
+ * During I/O bi_private points at the dio_data.  After I/O, bi_private is used
+ * to implement a singly-linked list of completed BIOs, at dio->bio_list.
  */
 static void dio_bio_end_io(struct bio *bio, int error)
 {
-	struct dio *dio = bio->bi_private;
+	struct dio_bio_data *bio_data = bio->bi_private;
+	struct dio *dio = bio_data->dio;
 	unsigned long flags;
 
+	range_unlock(&dio->inode->i_mapping->mapping_lock, &bio_data->lock);
+	kmem_cache_free(dio_bio_data_cache, bio_data);
 	spin_lock_irqsave(&dio->bio_lock, flags);
 	bio->bi_private = dio->bio_list;
 	dio->bio_list = bio;
@@ -325,7 +344,8 @@ static void dio_bio_end_io(struct bio *bio, int error)
  */
 void dio_end_io(struct bio *bio, int error)
 {
-	struct dio *dio = bio->bi_private;
+	struct dio_bio_data *bio_data = bio->bi_private;
+	struct dio *dio = bio_data->dio;
 
 	if (dio->is_async)
 		dio_bio_end_aio(bio, error);
@@ -369,8 +389,7 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
 {
 	struct bio *bio = sdio->bio;
 	unsigned long flags;
-
-	bio->bi_private = dio;
+	loff_t start = sdio->logical_offset_in_bio;
 
 	spin_lock_irqsave(&dio->bio_lock, flags);
 	dio->refcount++;
@@ -380,10 +399,30 @@ static inline void dio_bio_submit(struct dio *dio, struct dio_submit *sdio)
 		bio_set_pages_dirty(bio);
 
 	if (sdio->submit_io)
-		sdio->submit_io(dio->rw, bio, dio->inode,
-			       sdio->logical_offset_in_bio);
-	else
+		sdio->submit_io(dio->rw, bio, dio->inode, start);
+	else {
+		struct address_space *mapping = dio->inode->i_mapping;
+		loff_t end = sdio->logical_offset_in_bio + bio->bi_size - 1;
+
+		sdio->bio_data->dio = dio;
+		range_lock_init(&sdio->bio_data->lock,
+			start >> PAGE_CACHE_SHIFT, end >> PAGE_CACHE_SHIFT);
+		range_lock(&mapping->mapping_lock, &sdio->bio_data->lock);
+		/*
+		 * Once we hold mapping range lock writeout and invalidation
+		 * cannot race with page faults of buffered IO.
+		 */
+		filemap_write_and_wait_range(mapping, start, end);
+		if (dio->rw == WRITE && mapping->nrpages) {
+			invalidate_inode_pages2_range(mapping,
+				start >> PAGE_CACHE_SHIFT,
+				end >> PAGE_CACHE_SHIFT);
+		}
+		bio->bi_private = sdio->bio_data;
+		sdio->bio_data = NULL;
+
 		submit_bio(dio->rw, bio);
+	}
 
 	sdio->bio = NULL;
 	sdio->boundary = 0;
@@ -397,6 +436,8 @@ static inline void dio_cleanup(struct dio *dio, struct dio_submit *sdio)
 {
 	while (dio_pages_present(sdio))
 		page_cache_release(dio_get_page(dio, sdio));
+	if (sdio->bio_data)
+		kmem_cache_free(dio_bio_data_cache, sdio->bio_data);
 }
 
 /*
@@ -600,6 +641,11 @@ static inline int dio_new_bio(struct dio *dio, struct dio_submit *sdio,
 	nr_pages = min(sdio->pages_in_io, bio_get_nr_vecs(map_bh->b_bdev));
 	nr_pages = min(nr_pages, BIO_MAX_PAGES);
 	BUG_ON(nr_pages <= 0);
+	sdio->bio_data = kmem_cache_alloc(dio_bio_data_cache, GFP_KERNEL);
+	if (!sdio->bio_data) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	dio_bio_alloc(dio, sdio, map_bh->b_bdev, sector, nr_pages);
 	sdio->boundary = 0;
 out:
@@ -1307,6 +1353,7 @@ EXPORT_SYMBOL(__blockdev_direct_IO);
 static __init int dio_init(void)
 {
 	dio_cache = KMEM_CACHE(dio, SLAB_PANIC);
+	dio_bio_data_cache = KMEM_CACHE(dio_bio_data, SLAB_PANIC);
 	return 0;
 }
 module_init(dio_init)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
