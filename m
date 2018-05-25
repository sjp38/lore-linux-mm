Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFE36B02B0
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:50:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y124-v6so2905421qkc.8
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:50:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k3-v6si2507991qvj.206.2018.05.24.20.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:50:25 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 19/33] block: convert to bio_for_each_page_all2()
Date: Fri, 25 May 2018 11:46:07 +0800
Message-Id: <20180525034621.31147-20-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index a200c42e55dc..a14c854b9111 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1119,8 +1119,9 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_from_iter(bvec->bv_page,
@@ -1150,8 +1151,9 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 {
 	int i;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		ssize_t ret;
 
 		ret = copy_page_to_iter(bvec->bv_page,
@@ -1173,8 +1175,9 @@ void bio_free_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i)
+	bio_for_each_page_all2(bvec, bio, i, bia)
 		__free_page(bvec->bv_page);
 }
 EXPORT_SYMBOL(bio_free_pages);
@@ -1340,6 +1343,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	struct bio *bio;
 	int ret;
 	struct bio_vec *bvec;
+	struct bvec_iter_all bia;
 
 	if (!iov_iter_count(iter))
 		return ERR_PTR(-EINVAL);
@@ -1413,7 +1417,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 	return bio;
 
  out_unmap:
-	bio_for_each_page_all(bvec, bio, j) {
+	bio_for_each_page_all2(bvec, bio, j, bia) {
 		put_page(bvec->bv_page);
 	}
 	bio_put(bio);
@@ -1424,11 +1428,12 @@ static void __bio_unmap_user(struct bio *bio)
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
 
@@ -1520,8 +1525,9 @@ static void bio_copy_kern_endio_read(struct bio *bio)
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
index 77f3cecfaa7d..a76053d6fd6c 100644
--- a/block/blk-zoned.c
+++ b/block/blk-zoned.c
@@ -123,6 +123,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	unsigned int ofst;
 	void *addr;
 	int ret;
+	struct bvec_iter_all bia;
 
 	if (!q)
 		return -ENXIO;
@@ -190,7 +191,7 @@ int blkdev_report_zones(struct block_device *bdev,
 	n = 0;
 	nz = 0;
 	nr_rep = 0;
-	bio_for_each_page_all(bv, bio, i) {
+	bio_for_each_page_all2(bv, bio, i, bia) {
 
 		if (!bv->bv_page)
 			break;
@@ -223,7 +224,7 @@ int blkdev_report_zones(struct block_device *bdev,
 
 	*nr_zones = nz;
 out:
-	bio_for_each_page_all(bv, bio, i)
+	bio_for_each_page_all2(bv, bio, i, bia)
 		__free_page(bv->bv_page);
 	bio_put(bio);
 
diff --git a/block/bounce.c b/block/bounce.c
index f4ee4b81f7a2..8b14683f4061 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -143,11 +143,12 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
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
@@ -203,6 +204,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bool bounce = false;
 	int sectors = 0;
 	bool passthrough = bio_is_passthrough(*bio_orig);
+	struct bvec_iter_all bia;
 
 	bio_for_each_page(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
@@ -222,7 +224,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio = bio_clone_bioset(*bio_orig, GFP_NOIO, passthrough ? NULL :
 			bounce_bio_set);
 
-	bio_for_each_page_all(to, bio, i) {
+	bio_for_each_page_all2(to, bio, i, bia) {
 		struct page *page = to->bv_page;
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 75baad77d9a8..5ae2bc876295 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -369,10 +369,11 @@ static inline unsigned bio_pages_all(struct bio *bio)
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
