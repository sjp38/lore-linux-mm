Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFC7F6B0281
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:25:58 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id l74so6965611oih.10
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:25:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y65si3770077oiy.434.2017.12.18.04.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:25:58 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 12/45] blk-merge: compute bio->bi_seg_front_size efficiently
Date: Mon, 18 Dec 2017 20:22:14 +0800
Message-Id: <20171218122247.3488-13-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index f5dedd57dff6..a476337a8ff4 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -146,22 +146,21 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
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
@@ -174,6 +173,8 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			bio = new;
 	}
 
+	if (nsegs == 1 && seg_size > front_seg_size)
+		front_seg_size = seg_size;
 	bio->bi_seg_front_size = front_seg_size;
 	if (seg_size > bio->bi_seg_back_size)
 		bio->bi_seg_back_size = seg_size;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
