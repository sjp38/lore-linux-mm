Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9CF6B02AE
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:50:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z140-v6so2895173qka.12
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:50:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n4-v6si4169691qkl.110.2018.05.24.20.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:50:15 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 18/33] block: deal with dirtying pages for multipage bvec
Date: Fri, 25 May 2018 11:46:06 +0800
Message-Id: <20180525034621.31147-19-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

In bio_check_pages_dirty(), bvec->bv_page is used as flag for marking
if the page has been dirtied & released, and if no, it will be dirtied
in deferred workqueue.

With multipage bvec, we can't do that any more, so change the logic into
checking all pages in one mp bvec, and only release all these pages if all
are dirtied, otherwise dirty them all in deferred wrokqueue.

This patch introduces segment_for_each_page_all() to deal with the case
a bit easier.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c          | 45 +++++++++++++++++++++++++++++++++++++--------
 include/linux/bvec.h |  7 +++++++
 2 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 63d4fe85f42e..a200c42e55dc 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1630,8 +1630,9 @@ void bio_set_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
@@ -1640,16 +1641,26 @@ void bio_set_pages_dirty(struct bio *bio)
 }
 EXPORT_SYMBOL_GPL(bio_set_pages_dirty);
 
+static inline void release_mp_bvec_pages(struct bio_vec *bvec)
+{
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	segment_for_each_page_all(bv, bvec, iter)
+		put_page(bv.bv_page);
+}
+
 static void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	/* iterate each mp bvec */
+	bio_for_each_segment_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (page)
-			put_page(page);
+			release_mp_bvec_pages(bvec);
 	}
 }
 
@@ -1693,20 +1704,38 @@ static void bio_dirty_fn(struct work_struct *work)
 	}
 }
 
+static inline void check_mp_bvec_pages(struct bio_vec *bvec,
+		int *nr_dirty, int *nr_pages)
+{
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	segment_for_each_page_all(bv, bvec, iter) {
+		struct page *page = bv.bv_page;
+
+		if (PageDirty(page) || PageCompound(page))
+			(*nr_dirty)++;
+		(*nr_pages)++;
+	}
+}
+
 void bio_check_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int nr_clean_pages = 0;
 	int i;
 
-	bio_for_each_page_all(bvec, bio, i) {
-		struct page *page = bvec->bv_page;
+	bio_for_each_segment_all(bvec, bio, i) {
+		int nr_dirty = 0, nr_pages = 0;
+
+		check_mp_bvec_pages(bvec, &nr_dirty, &nr_pages);
 
-		if (PageDirty(page) || PageCompound(page)) {
-			put_page(page);
+		/* release all pages in the mp bvec if all are dirtied */
+		if (nr_dirty == nr_pages) {
+			release_mp_bvec_pages(bvec);
 			bvec->bv_page = NULL;
 		} else {
-			nr_clean_pages++;
+			nr_clean_pages += nr_pages;
 		}
 	}
 
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 2deee87b823e..893e8fef0dd0 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -225,6 +225,13 @@ static inline bool bvec_iter_seg_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+#define segment_for_each_page_all(pg_bvl, seg_bvec, iter)		\
+	for (iter = BVEC_ITER_ALL_INIT,					\
+	     (iter).bi_size = (seg_bvec)->bv_len  - (iter).bi_bvec_done;\
+	     (iter).bi_size &&						\
+		((pg_bvl = bvec_iter_bvec((seg_bvec), (iter))), 1);	\
+	     bvec_iter_advance((seg_bvec), &(iter), (pg_bvl).bv_len))
+
 /* get the last page from the multipage bvec and store it in @pg */
 static inline void segment_last_page(const struct bio_vec *seg,
 		struct bio_vec *pg)
-- 
2.9.5
