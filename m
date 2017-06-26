Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D720A6B03AB
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:16:40 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o142so48269570qke.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:16:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m26si7495014qtf.250.2017.06.26.05.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:16:40 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 23/51] blk-merge: compute bio->bi_seg_front_size efficiently
Date: Mon, 26 Jun 2017 20:10:06 +0800
Message-Id: <20170626121034.3051-24-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

It is enough to check and compute bio->bi_seg_front_size just
after the 1st segment is found, but current code checks that
for each bvec, which is inefficient.

This patch follows the way in  __blk_recalc_rq_segments()
for computing bio->bi_seg_front_size, and it is more efficient
and code becomes more readable too.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 5df13041b851..821b9c206308 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -145,22 +145,21 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			bvprvp = &bvprv;
 			sectors += bv.bv_len >> 9;
 
-			if (nsegs == 1 && seg_size > front_seg_size)
-				front_seg_size = seg_size;
 			continue;
 		}
 new_segment:
 		if (nsegs == queue_max_segments(q))
 			goto split;
 
+		if (nsegs == 1 && seg_size > front_seg_size)
+			front_seg_size = seg_size;
+
 		nsegs++;
 		bvprv = bv;
 		bvprvp = &bvprv;
 		seg_size = bv.bv_len;
 		sectors += bv.bv_len >> 9;
 
-		if (nsegs == 1 && seg_size > front_seg_size)
-			front_seg_size = seg_size;
 	}
 
 	do_split = false;
@@ -173,6 +172,8 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			bio = new;
 	}
 
+	if (nsegs == 1 && seg_size > front_seg_size)
+		front_seg_size = seg_size;
 	bio->bi_seg_front_size = front_seg_size;
 	if (seg_size > bio->bi_seg_back_size)
 		bio->bi_seg_back_size = seg_size;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
