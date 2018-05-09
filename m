Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9869F6B0313
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:34:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q13-v6so15479943qtk.8
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:34:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r32-v6sor9747063qtr.105.2018.05.08.18.34.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 18:34:28 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 08/10] block: Add warning for bi_next not NULL in bio_endio()
Date: Tue,  8 May 2018 21:33:56 -0400
Message-Id: <20180509013358.16399-9-kent.overstreet@gmail.com>
In-Reply-To: <20180509013358.16399-1-kent.overstreet@gmail.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Recently found a bug where a driver left bi_next not NULL and then
called bio_endio(), and then the submitter of the bio used
bio_copy_data() which was treating src and dst as lists of bios.

Fixed that bug by splitting out bio_list_copy_data(), but in case other
things are depending on bi_next in weird ways, add a warning to help
avoid more bugs like that in the future.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/bio.c      | 3 +++
 block/blk-core.c | 8 +++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/block/bio.c b/block/bio.c
index ce8e259f9a..5c81391100 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1775,6 +1775,9 @@ void bio_endio(struct bio *bio)
 	if (!bio_integrity_endio(bio))
 		return;
 
+	if (WARN_ONCE(bio->bi_next, "driver left bi_next not NULL"))
+		bio->bi_next = NULL;
+
 	/*
 	 * Need to have a real endio function for chained bios, otherwise
 	 * various corner cases will break (like stacking block devices that
diff --git a/block/blk-core.c b/block/blk-core.c
index 66f24798ef..f3cf79198a 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -204,6 +204,10 @@ static void req_bio_endio(struct request *rq, struct bio *bio,
 	bio_advance(bio, nbytes);
 
 	/* don't actually finish bio if it's part of flush sequence */
+	/*
+	 * XXX this code looks suspicious - it's not consistent with advancing
+	 * req->bio in caller
+	 */
 	if (bio->bi_iter.bi_size == 0 && !(rq->rq_flags & RQF_FLUSH_SEQ))
 		bio_endio(bio);
 }
@@ -2982,8 +2986,10 @@ bool blk_update_request(struct request *req, blk_status_t error,
 		struct bio *bio = req->bio;
 		unsigned bio_bytes = min(bio->bi_iter.bi_size, nr_bytes);
 
-		if (bio_bytes == bio->bi_iter.bi_size)
+		if (bio_bytes == bio->bi_iter.bi_size) {
 			req->bio = bio->bi_next;
+			bio->bi_next = NULL;
+		}
 
 		/* Completion has already been traced */
 		bio_clear_flag(bio, BIO_TRACE_COMPLETION);
-- 
2.17.0
