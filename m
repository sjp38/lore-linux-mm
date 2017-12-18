Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07AA66B029D
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:30:20 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v63so6975304oif.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:30:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x18si3787947oia.288.2017.12.18.04.30.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:30:19 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 29/45] block: bio: introduce bio_for_each_page_all2 and bio_for_each_segment_all
Date: Mon, 18 Dec 2017 20:22:31 +0800
Message-Id: <20171218122247.3488-30-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

This patch introduces bio_for_each_page_all2(), which is for replacing
bio_for_each_page_all() in case that the returned bvec has to be single
page bvec.

Given the interface type has to be changed for passing one local iterator
variable of 'bvec_iter_all', and doing all changes in one single patch
isn't realistic, so use the name of bio_for_each_page_all2() temporarily
for conversion, and once all bio_for_each_page_all() is converted, the
original name of bio_for_each_page_all() will be recovered finally.

This patch introduce bio_for_each_segment_all too, which is used for
updating bvec table directly, and users should be carful about this
helper since it returns real multipage segment now.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h  | 18 ++++++++++++++++++
 include/linux/bvec.h |  6 ++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 205a914ee3c0..f96c9f662f92 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -221,6 +221,24 @@ static inline bool bio_rewind_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)			\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define bio_for_each_segment_all(bvl, bio, i) \
+	bio_for_each_page_all((bvl), (bio), (i))
+
+/*
+ * This helper returns singlepage bvec to caller, and the sp bvec is
+ * generated in-flight from multipage bvec stored in bvec table. So we
+ * can _not_ change the bvec stored in bio->bi_io_vec[] via this helper.
+ *
+ * If bvec need to be updated in the table, please use
+ * bio_for_each_segment_all() and make sure it is correctly used since
+ * bvec may points to one multipage bvec.
+ */
+#define bio_for_each_page_all2(bvl, bio, i, bi)			\
+	for ((bi).iter = BVEC_ITER_ALL_INIT, i = 0, bvl = &(bi).bv;	\
+	     (bi).iter.bi_idx < (bio)->bi_vcnt &&			\
+		(((bi).bv = bio_iter_iovec((bio), (bi).iter)), 1);	\
+	     bio_advance_iter((bio), &(bi).iter, (bi).bv.bv_len), i++)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned __bio_elements(struct bio *bio, bool seg)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 217afcd83a15..2deee87b823e 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -84,6 +84,12 @@ struct bvec_iter {
 						   current bvec */
 };
 
+/* this iter is only for implementing bio_for_each_page_all2() */
+struct bvec_iter_all {
+	struct bvec_iter	iter;
+	struct bio_vec		bv;      /* in-flight singlepage bvec */
+};
+
 /*
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
