Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91A056B0293
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:50:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v14-v6so1888250qto.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:50:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c6-v6si3911713qvo.55.2018.06.27.05.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:50:26 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 22/24] block: enable multipage bvecs
Date: Wed, 27 Jun 2018 20:45:46 +0800
Message-Id: <20180627124548.3456-23-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

This patch pulls the trigger for multipage bvecs.

Now any request queue which supports queue cluster will see multipage
bvecs.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 22c6c83a7c8b..1dc3361fd5f9 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -765,12 +765,23 @@ bool __bio_try_merge_page(struct bio *bio, struct page *page,
 
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
-
-		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
-			bv->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
+		struct request_queue *q = NULL;
+
+		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len)
+			goto merge;
+
+		if (bio->bi_disk)
+			q = bio->bi_disk->queue;
+
+		/* disable multipage bvec too if cluster isn't enabled */
+		if (!q || !blk_queue_cluster(q) ||
+		    (bvec_to_phys(bv) + bv->bv_len !=
+		     page_to_phys(page) + off))
+			return false;
+ merge:
+		bv->bv_len += len;
+		bio->bi_iter.bi_size += len;
+		return true;
 	}
 	return false;
 }
-- 
2.9.5
