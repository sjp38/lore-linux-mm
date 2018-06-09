Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA9C6B0286
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:34:21 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c1-v6so378540qtj.6
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:34:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q87-v6si7619460qkh.219.2018.06.09.05.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:34:20 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 19/30] md/dm/bcache: conver to bio_for_each_chunk_segment_all and bio_for_each_chunk_all
Date: Sat,  9 Jun 2018 20:30:03 +0800
Message-Id: <20180609123014.8861-20-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

In bch_bio_alloc_pages(), bio_for_each_chunk_all() is fine because this
helper can only be used on a freshly new bio.

For other cases, we conver to bio_for_each_chunk_segment_all() since they needn't
to update bvec table.

bio_for_each_segment_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_chunk_segment_all().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/bcache/btree.c | 3 ++-
 drivers/md/bcache/util.c  | 2 +-
 drivers/md/dm-crypt.c     | 3 ++-
 drivers/md/raid1.c        | 3 ++-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 2a0968c04e21..dc0747c37bdf 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -423,8 +423,9 @@ static void do_btree_node_write(struct btree *b)
 		int j;
 		struct bio_vec *bv;
 		void *base = (void *) ((unsigned long) i & ~(PAGE_SIZE - 1));
+		struct bvec_chunk_iter citer;
 
-		bio_for_each_segment_all(bv, b->bio, j)
+		bio_for_each_chunk_segment_all(bv, b->bio, j, citer)
 			memcpy(page_address(bv->bv_page),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index fc479b026d6d..2f05199f7edb 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -268,7 +268,7 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	int i;
 	struct bio_vec *bv;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	bio_for_each_chunk_all(bv, bio, i) {
 		bv->bv_page = alloc_page(gfp_mask);
 		if (!bv->bv_page) {
 			while (--bv >= bio->bi_io_vec)
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index da02f4d8e4b9..637ef1b1dc43 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1450,8 +1450,9 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 {
 	unsigned int i;
 	struct bio_vec *bv;
+	struct bvec_chunk_iter citer;
 
-	bio_for_each_segment_all(bv, clone, i) {
+	bio_for_each_chunk_segment_all(bv, clone, i, citer) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, &cc->page_pool);
 	}
diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index bad28520719b..2a4f1037c680 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2116,13 +2116,14 @@ static void process_checks(struct r1bio *r1_bio)
 		struct page **spages = get_resync_pages(sbio)->pages;
 		struct bio_vec *bi;
 		int page_len[RESYNC_PAGES] = { 0 };
+		struct bvec_chunk_iter citer;
 
 		if (sbio->bi_end_io != end_sync_read)
 			continue;
 		/* Now we can 'fixup' the error value */
 		sbio->bi_status = 0;
 
-		bio_for_each_segment_all(bi, sbio, j)
+		bio_for_each_chunk_segment_all(bi, sbio, j, citer)
 			page_len[j] = bi->bv_len;
 
 		if (!status) {
-- 
2.9.5
