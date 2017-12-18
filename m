Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 608B66B02A1
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:30:45 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id z30so8925968otd.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:30:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w3si3965397ote.69.2017.12.18.04.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:30:44 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 31/45] block: convert to bio_for_each_page_all2()
Date: Mon, 18 Dec 2017 20:22:33 +0800
Message-Id: <20171218122247.3488-32-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

We have to convert to bio_for_each_page_all2() for iterating page by
page.

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c         | 18 ++++++++++++------
 block/blk-zoned.c   |  5 +++--
 block/bounce.c      |  6 ++++--
 include/linux/bio.h |  3 ++-
 4 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 1c90b8473196..21d621e07ac9 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1063,8 +1063,9 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1094,8 +1095,9 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1117,8 +1119,9 @@ void bio_free_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i)
+	bio_for_each_page_all2(bvec, bio, i, bia)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1284,6 +1287,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	struct bio *bio;
 	int ret;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
 	if (!iov_iter_count(iter))
 		return ERR_PTR(-EINVAL);
@@ -1357,7 +1361,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_page_all(bvec, bio, j) {
+	bio_for_each_page_all2(bvec, bio, j, bia) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1368,11 +1372,12 @@ static void __bio_unmap_user(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		if (bio_data_dir(bio) == READ)
 			set_page_dirty_lock(bvec->bv_page);
 
@@ -1464,8 +1469,9 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	char *p = bio->bi_private;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
 		p += bvec->bv_len;
 	}
diff --git a/block/blk-zoned.c b/block/blk-zoned.c
index 99f6e2cb6fd5..2899adfa23f4 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -81,6 +81,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	unsigned int ofst;
 	void *addr;
 	int ret;
+	struct bvec_iter_all bia;
 
 	if (!q)
 		return -ENXIO;
@@ -148,7 +149,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	n = 0;
 	nz = 0;
 	nr_rep = 0;
-	bio_for_each_page_all(bv, bio, i) {
+	bio_for_each_page_all2(bv, bio, i, bia) {
 
 		if (!bv->bv_page)
 			break;
@@ -181,7 +182,7 @@ int blkdev_report_zones(struct block_device *bdev,
 
 	*nr_zones = nz;
 out:
-	bio_for_each_page_all(bv, bio, i)
+	bio_for_each_page_all2(bv, bio, i, bia)
 		__free_page(bv->bv_page);
 	bio_put(bio);
 
diff --git a/block/bounce.c b/block/bounce.c
index 67aa6cff16d6..6436c07179f0 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -146,11 +146,12 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	struct bio_vec *bvec, orig_vec;
 	int i;
 	struct bvec_iter orig_iter = bio_orig->bi_iter;
+	struct bvec_iter_all bia;
 
 	/*
 	 * free up bounce indirect pages used
 	 */
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
 		if (bvec->bv_page != orig_vec.bv_page) {
 			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
@@ -205,6 +206,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	unsigned i = 0;
 	bool bounce = false;
 	int sectors = 0;
+	struct bvec_iter_all bia;
 
 	bio_for_each_page(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -223,7 +225,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	}
 	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, bounce_bio_set);
 
-	bio_for_each_page_all(to, bio, i) {
+	bio_for_each_page_all2(to, bio, i, bia) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/include/linux/bio.h b/include/linux/bio.h
index f96c9f662f92..899db6701f0d 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -365,10 +365,11 @@ static inline unsigned bio_pages_all(struct bio *bio)
 {
 	unsigned i;
 	struct bio_vec *bv;
+	struct bvec_iter_all bia;
 
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
 
-	bio_for_each_page_all(bv, bio, i)
+	bio_for_each_page_all2(bv, bio, i, bia)
 		;
 	return i;
 }
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
