Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF6296B027D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:55:48 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 67so43054392qkj.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:55:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s29si6771953qth.384.2018.11.15.00.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:55:47 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V10 09/19] block: introduce bio_bvecs()
Date: Thu, 15 Nov 2018 16:52:56 +0800
Message-Id: <20181115085306.9910-10-ming.lei@redhat.com>
In-Reply-To: <20181115085306.9910-1-ming.lei@redhat.com>
References: <20181115085306.9910-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

There are still cases in which we need to use bio_bvecs() for get the
number of multi-page segment, so introduce it.

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: dm-devel@redhat.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Cc: linux-erofs@lists.ozlabs.org
Cc: David Sterba <dsterba@suse.com>
Cc: linux-btrfs@vger.kernel.org
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: Coly Li <colyli@suse.de>
Cc: linux-bcache@vger.kernel.org
Cc: Boaz Harrosh <ooo@electrozaur.com>
Cc: Bob Peterson <rpeterso@redhat.com>
Cc: cluster-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 1f0dcf109841..3496c816946e 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -196,7 +196,6 @@ static inline unsigned bio_segments(struct bio *bio)
 	 * We special case discard/write same/write zeroes, because they
 	 * interpret bi_size differently:
 	 */
-
 	switch (bio_op(bio)) {
 	case REQ_OP_DISCARD:
 	case REQ_OP_SECURE_ERASE:
@@ -205,13 +204,34 @@ static inline unsigned bio_segments(struct bio *bio)
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
