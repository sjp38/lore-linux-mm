Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 625F96B02A3
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:30:58 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j135so7048462oih.9
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:30:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si3655109oiy.153.2017.12.18.04.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:30:57 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 32/45] md/dm/bcache: conver to bio_for_each_page_all2 and bio_for_each_segment
Date: Mon, 18 Dec 2017 20:22:34 +0800
Message-Id: <20171218122247.3488-33-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

In bch_bio_alloc_pages(), bio_for_each_segment() is fine because this
helper can only be used on a freshly new bio.

For other cases, we conver to bio_for_each_page_all2() since they needn't
to update bvec table.

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_page_all2().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/bcache/btree.c | 3 ++-
 drivers/md/bcache/util.c  | 2 +-
 drivers/md/dm-crypt.c     | 3 ++-
 drivers/md/raid1.c        | 3 ++-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index a82100527495..ac7bac6e6a29 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -423,8 +423,9 @@ static void do_btree_node_write(struct btree *b)
 		int j;
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
+		struct bvec_iter_all bia;
 
-		bio_for_each_page_all(bv, b->bio, j)
+		bio_for_each_page_all2(bv, b->bio, j, bia)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index 8f2d522822b1..a23cd6a14b74 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -298,7 +298,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	int i;
 	struct bio_vec *bv;
 
-	bio_for_each_page_all(bv, bio, i) {
+	bio_for_each_segment_all(bv, bio, i) {
 		bv->bv_page = alloc_page(gfp_mask);
 		if (!bv->bv_page) {
 			while (--bv >= bio->bi_io_vec)
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 970a761de621..19dc1f6b523a 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1442,8 +1442,9 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 {
 	unsigned int i;
 	struct bio_vec *bv;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bv, clone, i) {
+	bio_for_each_page_all2(bv, clone, i, bia) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
 	}
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index e64b49929b8d..da5d7ea5504b 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2083,13 +2083,14 @@ static void process_checks(struct r1bio *r1_bio)
 		struct page **spages = get_resync_pages(sbio)->pages;
 		struct bio_vec *bi;
 		int page_len[RESYNC_PAGES] = { 0 };
+		struct bvec_iter_all bia;
 
 		if (sbio->bi_end_io != end_sync_read)
 			continue;
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_page_all(bi, sbio, j)
+		bio_for_each_page_all2(bi, sbio, j, bia)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
