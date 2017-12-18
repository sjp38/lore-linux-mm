Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34E556B029F
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:30:32 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id u10so8819857otc.21
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:30:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g128si882516oif.32.2017.12.18.04.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:30:31 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 30/45] block: deal with dirtying pages for multipage bvec
Date: Mon, 18 Dec 2017 20:22:32 +0800
Message-Id: <20171218122247.3488-31-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index 1649dc465af7..1c90b8473196 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1574,8 +1574,9 @@ void bio_set_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
@@ -1583,16 +1584,26 @@ void bio_set_pages_dirty(struct bio *bio)
 	}
 }
 
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
 
@@ -1636,20 +1647,38 @@ static void bio_dirty_fn(struct work_struct *work)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
