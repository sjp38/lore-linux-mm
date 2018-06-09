Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C727D6B0277
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:33:05 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f8-v6so4522194qth.9
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:33:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k33-v6si66755qta.311.2018.06.09.05.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:33:04 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 12/30] block: introduce bio_chunks()
Date: Sat,  9 Jun 2018 20:29:56 +0800
Message-Id: <20180609123014.8861-13-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

There are still cases in which we need to use bio_chunks() for get the
number of multipage segment, so introduce it.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index c17b8f80d650..13fd7bc30390 100644
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
+static inline unsigned bio_chunks(struct bio *bio)
+{
+	unsigned chunks = 0;
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
+		bio_for_each_chunk(bv, bio, iter)
+			chunks++;
+		return chunks;
+	}
 }
 
 /*
-- 
2.9.5
