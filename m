Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A84706B02A5
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:31:08 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id z81so6971065oig.16
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:31:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z66si3861241oig.542.2017.12.18.04.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:31:07 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 33/45] fs: conver to bio_for_each_page_all2
Date: Mon, 18 Dec 2017 20:22:35 +0800
Message-Id: <20171218122247.3488-34-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_page_all2().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/block_dev.c  | 6 ++++--
 fs/crypto/bio.c | 3 ++-
 fs/direct-io.c  | 4 +++-
 fs/iomap.c      | 3 ++-
 fs/mpage.c      | 3 ++-
 5 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index e73f635502e7..41e1fc90f048 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -197,6 +197,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	ssize_t ret;
 	blk_qc_t qc;
 	int i;
+	struct bvec_iter_all bia;
 
 	if ((pos | iov_iter_alignment(iter)) &
 	    (bdev_logical_block_size(bdev) - 1))
@@ -242,7 +243,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_page_all(bvec, &bio, i) {
+	bio_for_each_page_all2(bvec, &bio, i, bia) {
 		if (should_dirty && !PageCompound(bvec->bv_page))
 			set_page_dirty_lock(bvec->bv_page);
 		put_page(bvec->bv_page);
@@ -309,8 +310,9 @@ static void blkdev_bio_end_io(struct bio *bio)
 	} else {
 		struct bio_vec *bvec;
 		int i;
+		struct bvec_iter_all bia;
 
-		bio_for_each_page_all(bvec, bio, i)
+		bio_for_each_page_all2(bvec, bio, i, bia)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 2dda77c3a89a..743c3ecb7f97 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -37,8 +37,9 @@ static void completion_pages(struct work_struct *work)
 	struct bio *bio = ctx->r.bio;
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bv, bio, i) {
+	bio_for_each_page_all2(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 5e6f4a5772d2..578a3a854115 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -530,7 +530,9 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 	if (dio->is_async && dio->op == REQ_OP_READ && dio->should_dirty) {
 		bio_check_pages_dirty(bio);	/* transfers ownership */
 	} else {
-		bio_for_each_page_all(bvec, bio, i) {
+		struct bvec_iter_all bia;
+
+		bio_for_each_page_all2(bvec, bio, i, bia) {
 			struct page *page = bvec->bv_page;
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
diff --git a/fs/iomap.c b/fs/iomap.c
index 286daad10ba2..fa4b6e15d29c 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -814,8 +814,9 @@ static void iomap_dio_bio_end_io(struct bio *bio)
 	} else {
 		struct bio_vec *bvec;
 		int i;
+		struct bvec_iter_all bia;
 
-		bio_for_each_page_all(bvec, bio, i)
+		bio_for_each_page_all2(bvec, bio, i, bia)
 			put_page(bvec->bv_page);
 		bio_put(bio);
 	}
diff --git a/fs/mpage.c b/fs/mpage.c
index 1cf322c4d6f8..f2da0f9ec0f2 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -48,8 +48,9 @@ static void mpage_end_io(struct bio *bio)
 {
 	struct bio_vec *bv;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bv, bio, i) {
+	bio_for_each_page_all2(bv, bio, i, bia) {
 		struct page *page = bv->bv_page;
 		page_endio(page, op_is_write(bio_op(bio)),
 				blk_status_to_errno(bio->bi_status));
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
