Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB876B02A6
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:49:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z1-v6so2916963qki.10
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:49:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k46-v6si7659619qta.9.2018.05.24.20.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:49:32 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 14/33] block: loop: pass segments to iov_iter
Date: Fri, 25 May 2018 11:46:02 +0800
Message-Id: <20180525034621.31147-15-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

iov_iter is implemented with bvec itererator, so it is safe to pass
segment to it, and this way is much more efficient than passing one
page in each bvec.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/block/loop.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 8d7d5581ca9c..e709c0380566 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -521,7 +521,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		struct bio_vec tmp;
 
 		__rq_for_each_bio(bio, rq)
-			segments += bio_pages(bio);
+			segments += bio_segments(bio);
 		bvec = kmalloc(sizeof(struct bio_vec) * segments, GFP_NOIO);
 		if (!bvec)
 			return -EIO;
@@ -533,7 +533,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_page
 		 * API will take care of all details for us.
 		 */
-		rq_for_each_page(tmp, rq, iter) {
+		rq_for_each_segment(tmp, rq, iter) {
 			*bvec = tmp;
 			bvec++;
 		}
@@ -547,7 +547,7 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		 */
 		offset = bio->bi_iter.bi_bvec_done;
 		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
-		segments = bio_pages(bio);
+		segments = bio_segments(bio);
 	}
 	atomic_set(&cmd->ref, 2);
 
-- 
2.9.5
