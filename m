Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 577288E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:19:56 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w19so20356648qto.13
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:19:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f21si7252828qve.138.2019.01.21.00.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:19:55 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V14 05/18] block: introduce bio_for_each_mp_bvec() and rq_for_each_mp_bvec()
Date: Mon, 21 Jan 2019 16:17:52 +0800
Message-Id: <20190121081805.32727-6-ming.lei@redhat.com>
In-Reply-To: <20190121081805.32727-1-ming.lei@redhat.com>
References: <20190121081805.32727-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Ming Lei <ming.lei@redhat.com>

bio_for_each_mp_bvec() is used for iterating over multi-page bvec for bio
split & merge code.

rq_for_each_mp_bvec() can be used for drivers which may handle the
multi-page bvec directly, so far loop is one perfect use case.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h    | 10 ++++++++++
 include/linux/blkdev.h |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 72b4f7be2106..730288145568 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -156,6 +156,16 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_mp_bvec(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = mp_bvec_iter_bvec((bio)->bi_io_vec, (iter))), 1); \
+	     bio_advance_iter((bio), &(iter), (bvl).bv_len))
+
+/* iterate over multi-page bvec */
+#define bio_for_each_mp_bvec(bvl, bio, iter)			\
+	__bio_for_each_mp_bvec(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 338604dff7d0..6ebae3ee8f44 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -797,6 +797,10 @@ struct req_iterator {
 	__rq_for_each_bio(_iter.bio, _rq)			\
 		bio_for_each_segment(bvl, _iter.bio, _iter.iter)
 
+#define rq_for_each_mp_bvec(bvl, _rq, _iter)			\
+	__rq_for_each_bio(_iter.bio, _rq)			\
+		bio_for_each_mp_bvec(bvl, _iter.bio, _iter.iter)
+
 #define rq_iter_last(bvec, _iter)				\
 		(_iter.bio->bi_next == NULL &&			\
 		 bio_iter_last(bvec, _iter.iter))
-- 
2.9.5
