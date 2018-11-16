Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2296B09B0
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:30:31 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id t15so26429361wrx.16
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:30:31 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p8si2880591wrq.87.2018.11.16.05.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:30:29 -0800 (PST)
Date: Fri, 16 Nov 2018 14:30:28 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 02/19] block: introduce bio_for_each_bvec()
Message-ID: <20181116133028.GB3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-3-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-3-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> +static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
> +				      unsigned bytes, bool mp)

I think these magic 'bool np' arguments and wrappers over wrapper
don't help anyone to actually understand the code.  I'd vote for
removing as many wrappers as we really don't need, and passing the
actual segment limit instead of the magic bool flag.  Something like
this untested patch:

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 277921ad42e7..dcad0b69f57a 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -138,30 +138,21 @@ static inline bool bio_full(struct bio *bio)
 		bvec_for_each_segment(bvl, &((bio)->bi_io_vec[iter_all.idx]), i, iter_all)
 
 static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
-				      unsigned bytes, bool mp)
+				      unsigned bytes, unsigned max_segment)
 {
 	iter->bi_sector += bytes >> 9;
 
 	if (bio_no_advance_iter(bio))
 		iter->bi_size -= bytes;
 	else
-		if (!mp)
-			bvec_iter_advance(bio->bi_io_vec, iter, bytes);
-		else
-			mp_bvec_iter_advance(bio->bi_io_vec, iter, bytes);
+		__bvec_iter_advance(bio->bi_io_vec, iter, bytes, max_segment);
 		/* TODO: It is reasonable to complete bio with error here. */
 }
 
 static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 				    unsigned bytes)
 {
-	__bio_advance_iter(bio, iter, bytes, false);
-}
-
-static inline void bio_advance_mp_iter(struct bio *bio, struct bvec_iter *iter,
-				       unsigned bytes)
-{
-	__bio_advance_iter(bio, iter, bytes, true);
+	__bio_advance_iter(bio, iter, bytes, PAGE_SIZE);
 }
 
 #define __bio_for_each_segment(bvl, bio, iter, start)			\
@@ -177,7 +168,7 @@ static inline void bio_advance_mp_iter(struct bio *bio, struct bvec_iter *iter,
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
 		((bvl = bio_iter_mp_iovec((bio), (iter))), 1);	\
-	     bio_advance_mp_iter((bio), &(iter), (bvl).bv_len))
+	     __bio_advance_iter((bio), &(iter), (bvl).bv_len, 0))
 
 /* returns one real segment(multipage bvec) each time */
 #define bio_for_each_bvec(bvl, bio, iter)			\
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 02f26d2b59ad..5e2ed46c1c88 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -138,8 +138,7 @@ struct bvec_iter_all {
 })
 
 static inline bool __bvec_iter_advance(const struct bio_vec *bv,
-				       struct bvec_iter *iter,
-				       unsigned bytes, bool mp)
+		struct bvec_iter *iter, unsigned bytes, unsigned max_segment)
 {
 	if (WARN_ONCE(bytes > iter->bi_size,
 		     "Attempted to advance past end of bvec iter\n")) {
@@ -148,18 +147,18 @@ static inline bool __bvec_iter_advance(const struct bio_vec *bv,
 	}
 
 	while (bytes) {
-		unsigned len;
+		unsigned segment_len = mp_bvec_iter_len(bv, *iter);
 
-		if (mp)
-			len = mp_bvec_iter_len(bv, *iter);
-		else
-			len = bvec_iter_len(bv, *iter);
+		if (max_segment) {
+			max_segment -= bvec_iter_offset(bv, *iter);
+			segment_len = min(segment_len, max_segment);
+		}
 
-		len = min(bytes, len);
+		segment_len = min(bytes, segment_len);
 
-		bytes -= len;
-		iter->bi_size -= len;
-		iter->bi_bvec_done += len;
+		bytes -= segment_len;
+		iter->bi_size -= segment_len;
+		iter->bi_bvec_done += segment_len;
 
 		if (iter->bi_bvec_done == __bvec_iter_bvec(bv, *iter)->bv_len) {
 			iter->bi_bvec_done = 0;
@@ -197,14 +196,7 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 				     struct bvec_iter *iter,
 				     unsigned bytes)
 {
-	return __bvec_iter_advance(bv, iter, bytes, false);
-}
-
-static inline bool mp_bvec_iter_advance(const struct bio_vec *bv,
-					struct bvec_iter *iter,
-					unsigned bytes)
-{
-	return __bvec_iter_advance(bv, iter, bytes, true);
+	return __bvec_iter_advance(bv, iter, bytes, PAGE_SIZE);
 }
 
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
