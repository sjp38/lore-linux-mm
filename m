Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5157A6B026D
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:24:00 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w196so6954342oia.17
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:24:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l60si4144531otc.148.2017.12.18.04.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:23:59 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 04/45] block: bounce: avoid direct access to bvec table
Date: Mon, 18 Dec 2017 20:22:06 +0800
Message-Id: <20171218122247.3488-5-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, Matthew Wilcox <willy@infradead.org>

We will support multipage bvecs in the future, so change to iterator way
for getting bv_page of bvec from original bio.

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bounce.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/block/bounce.c b/block/bounce.c
index fceb1a96480b..0274c31d6c05 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -137,21 +137,20 @@ static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 static void bounce_end_io(struct bio *bio, mempool_t *pool)
 {
 	struct bio *bio_orig = bio->bi_private;
-	struct bio_vec *bvec, *org_vec;
+	struct bio_vec *bvec, orig_vec;
 	int i;
-	int start = bio_orig->bi_iter.bi_idx;
+	struct bvec_iter orig_iter = bio_orig->bi_iter;
 
 	/*
 	 * free up bounce indirect pages used
 	 */
 	bio_for_each_segment_all(bvec, bio, i) {
-		org_vec = bio_orig->bi_io_vec + i + start;
-
-		if (bvec->bv_page == org_vec->bv_page)
-			continue;
-
-		dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
-		mempool_free(bvec->bv_page, pool);
+		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
+		if (bvec->bv_page != orig_vec.bv_page) {
+			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
+			mempool_free(bvec->bv_page, pool);
+		}
+		bio_advance_iter(bio_orig, &orig_iter, orig_vec.bv_len);
 	}
 
 	bio_orig->bi_status = bio->bi_status;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
