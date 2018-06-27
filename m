Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80B7C6B028A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:49:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 99-v6so1968116qkr.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:49:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f5-v6si3508749qve.92.2018.06.27.05.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:49:35 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 18/24] block: introduce bio_bvecs()
Date: Wed, 27 Jun 2018 20:45:42 +0800
Message-Id: <20180627124548.3456-19-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

There are still cases in which we need to use bio_bvecs() for get the
number of multipage segment, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 551444bd9795..083c1ee9c6c8 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -242,7 +242,6 @@ static inline unsigned bio_segments(struct bio *bio)
 	 * We special case discard/write same/write zeroes, because they
 	 * interpret bi_size differently:
 	 */
-
 	switch (bio_op(bio)) {
 	case REQ_OP_DISCARD:
 	case REQ_OP_SECURE_ERASE:
@@ -251,13 +250,34 @@ static inline unsigned bio_segments(struct bio *bio)
 	case REQ_OP_WRITE_SAME:
 		return 1;
 	default:
-		break;
+		bio_for_each_segment(bv, bio, iter)
+			segs++;
+		return segs;
 	}
+}
 
-	bio_for_each_segment(bv, bio, iter)
-		segs++;
+static inline unsigned bio_bvecs(struct bio *bio)
+{
+	unsigned bvecs = 0;
+	struct bio_vec bv;
+	struct bvec_iter iter;
 
-	return segs;
+	/*
+	 * We special case discard/write same/write zeroes, because they
+	 * interpret bi_size differently:
+	 */
+	switch (bio_op(bio)) {
+	case REQ_OP_DISCARD:
+	case REQ_OP_SECURE_ERASE:
+	case REQ_OP_WRITE_ZEROES:
+		return 0;
+	case REQ_OP_WRITE_SAME:
+		return 1;
+	default:
+		bio_for_each_bvec(bv, bio, iter)
+			bvecs++;
+		return bvecs;
+	}
 }
 
 /*
-- 
2.9.5
