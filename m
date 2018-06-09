Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 132076B0282
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 08:34:02 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w203-v6so15154110qkb.16
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 05:34:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q37-v6si524541qtc.381.2018.06.09.05.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 05:34:01 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V6 17/30] block: introduce bio_for_each_chunk_all and bio_for_each_chunk_segment_all
Date: Sat,  9 Jun 2018 20:30:01 +0800
Message-Id: <20180609123014.8861-18-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
References: <20180609123014.8861-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Ming Lei <ming.lei@redhat.com>

This patch introduces bio_for_each_chunk_all() and bio_for_each_chunk_segment_all(),
which are for replacing the current bio_for_each_segment_all().

bio_for_each_chunk_all() will iterate one chunk by chunk, which is multipage based.

bio_for_each_chunk_segment_all() will iterate one segment by segment, which is
singlepage based.

For using bio_for_each_chunk_segment_all(), one 24-bytes extra local variable has to
be introduced.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 13 +++++++++++++
 include/linux/bvec.h | 31 +++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 0fa1035dde38..f21384be9b51 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -168,6 +168,19 @@ static inline bool bio_full(struct bio *bio)
 #define bio_for_each_segment_all(bvl, bio, i)				\
 	for (i = 0, bvl = (bio)->bi_io_vec; i < (bio)->bi_vcnt; i++, bvl++)
 
+#define bio_for_each_chunk_all(bvl, bio, i)		\
+	bio_for_each_segment_all(bvl, bio, i)
+
+#define chunk_for_each_segment(bv, bvl, i, citer)			\
+	for (bv = bvec_init_chunk_iter(&citer);				\
+		(citer.done < (bvl)->bv_len) &&				\
+		((chunk_next_segment((bvl), &citer)), 1);		\
+		citer.done += bv->bv_len, i += 1)
+
+#define bio_for_each_chunk_segment_all(bvl, bio, i, citer)		\
+	for (i = 0, citer.idx = 0; citer.idx < (bio)->bi_vcnt; citer.idx++)	\
+		chunk_for_each_segment(bvl, &((bio)->bi_io_vec[citer.idx]), i, citer)
+
 static inline void __bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 				      unsigned bytes, bool chunk)
 {
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index aac75d87d884..d4eaa0c26bb5 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -84,6 +84,12 @@ struct bvec_iter {
 						   current bvec */
 };
 
+struct bvec_chunk_iter {
+	struct bio_vec	bv;
+	int		idx;
+	unsigned	done;
+};
+
 /*
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
@@ -219,6 +225,31 @@ static inline bool bvec_iter_chunk_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+static inline struct bio_vec *bvec_init_chunk_iter(struct bvec_chunk_iter *citer)
+{
+	citer->bv.bv_page = NULL;
+	citer->done = 0;
+
+	return &citer->bv;
+}
+
+/* used for chunk_for_each_segment */
+static inline void chunk_next_segment(const struct bio_vec *chunk,
+		struct bvec_chunk_iter *iter)
+{
+	struct bio_vec *bv = &iter->bv;
+
+	if (bv->bv_page) {
+		bv->bv_page += 1;
+		bv->bv_offset = 0;
+	} else {
+		bv->bv_page = chunk->bv_page;
+		bv->bv_offset = chunk->bv_offset;
+	}
+	bv->bv_len = min_t(unsigned int, PAGE_SIZE - bv->bv_offset,
+			chunk->bv_len - iter->done);
+}
+
 /*
  * Get the last singlepage segment from the multipage bvec and store it
  * in @seg
-- 
2.9.5
