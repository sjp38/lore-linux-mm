Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 239246B025E
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 01:11:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f85so20039220pfe.7
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 22:11:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t21si1255026pgb.737.2017.10.24.22.11.39
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 22:11:40 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 1/7] block: use DECLARE_COMPLETION_ONSTACK in submit_bio_wait
Date: Wed, 25 Oct 2017 14:11:06 +0900
Message-Id: <1508908272-15757-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
References: <1508908272-15757-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: johan@kernel.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

Simplify the code by getting rid of the submit_bio_ret structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/bio.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 5f5472e..99d0ca5 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -917,17 +917,9 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 }
 EXPORT_SYMBOL_GPL(bio_iov_iter_get_pages);
 
-struct submit_bio_ret {
-	struct completion event;
-	int error;
-};
-
 static void submit_bio_wait_endio(struct bio *bio)
 {
-	struct submit_bio_ret *ret = bio->bi_private;
-
-	ret->error = blk_status_to_errno(bio->bi_status);
-	complete(&ret->event);
+	complete(bio->bi_private);
 }
 
 /**
@@ -943,16 +935,15 @@ static void submit_bio_wait_endio(struct bio *bio)
  */
 int submit_bio_wait(struct bio *bio)
 {
-	struct submit_bio_ret ret;
+	DECLARE_COMPLETION_ONSTACK(done);
 
-	init_completion(&ret.event);
-	bio->bi_private = &ret;
+	bio->bi_private = &done;
 	bio->bi_end_io = submit_bio_wait_endio;
 	bio->bi_opf |= REQ_SYNC;
 	submit_bio(bio);
-	wait_for_completion_io(&ret.event);
+	wait_for_completion_io(&done);
 
-	return ret.error;
+	return blk_status_to_errno(bio->bi_status);
 }
 EXPORT_SYMBOL(submit_bio_wait);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
