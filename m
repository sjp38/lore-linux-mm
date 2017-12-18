Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 256486B026A
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:23:20 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id u22so8920859otd.13
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:23:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d142si3861203oih.411.2017.12.18.04.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:23:19 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 01/45] block: introduce bio helpers for converting to multipage bvec
Date: Mon, 18 Dec 2017 20:22:03 +0800
Message-Id: <20171218122247.3488-2-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

The following helpers are introduced for converting current users of
direct access to bvec table, and prepares for supporting multipage bvec:

	bio_pages_all()
	bio_first_bvec_all()
	bio_first_page_all()
	bio_last_bvec_all()

All are named as bio_*_all() to following bio_for_each_segment_all(),
they can only be used on bio of !bio_flagged(bio, BIO_CLONED), that means
the whole bvec table is covered.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 82f0c8fd7be8..435ddf04e889 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -300,6 +300,29 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 		bv->bv_len = iter.bi_bvec_done;
 }
 
+static inline unsigned bio_pages_all(struct bio *bio)
+{
+	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
+	return bio->bi_vcnt;
+}
+
+static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
+{
+	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
+	return bio->bi_io_vec;
+}
+
+static inline struct page *bio_first_page_all(struct bio *bio)
+{
+	return bio_first_bvec_all(bio)->bv_page;
+}
+
+static inline struct bio_vec *bio_last_bvec_all(struct bio *bio)
+{
+	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
+	return &bio->bi_io_vec[bio->bi_vcnt - 1];
+}
+
 enum bip_flags {
 	BIP_BLOCK_INTEGRITY	= 1 << 0, /* block layer owns integrity data */
 	BIP_MAPPED_INTEGRITY	= 1 << 1, /* ref tag has been remapped */
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
