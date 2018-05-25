Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79ED26B02B4
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:50:47 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p190-v6so2908817qkc.17
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:50:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m39-v6si3681353qtm.382.2018.05.24.20.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:50:46 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 21/33] fs: conver to bio_for_each_page_all2
Date: Fri, 25 May 2018 11:46:09 +0800
Message-Id: <20180525034621.31147-22-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index 65498a34efa9..f581fc0a6142 100644
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
index bbf25b0de9f8..e6a6dd560da2 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -551,7 +551,9 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
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
index 42b0b1697b3d..31d19f8f0aac 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -817,8 +817,9 @@ static void iomap_dio_bio_end_io(struct bio *bio)
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
