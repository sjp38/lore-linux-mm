Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56D336B03C1
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:18:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z22so47568153qka.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:18:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s58si7157026qte.115.2017.06.26.05.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:18:28 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 33/51] block: deal with dirtying pages for multipage bvec
Date: Mon, 26 Jun 2017 20:10:16 +0800
Message-Id: <20170626121034.3051-34-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

In bio_check_pages_dirty(), bvec->bv_page is used as flag
for marking if the page has been dirtied & released, and if
no, it will be dirtied in deferred workqueue.

With multipage bvec, we can't do that any more, so change
the logic into checking all pages in one mp bvec, and only
release all these pages if all are dirtied, otherwise dirty
them all in deferred wrokqueue.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 45 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 37 insertions(+), 8 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index bf7f25889f6e..22e5deec7ec7 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1641,8 +1641,9 @@ void bio_set_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	bio_for_each_segment_all_sp(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (page && !PageCompound(page))
@@ -1650,16 +1651,26 @@ void bio_set_pages_dirty(struct bio *bio)
 	}
 }
 
+static inline void release_mp_bvec_pages(struct bio_vec *bvec)
+{
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	bvec_for_each_sp_bvec(bv, bvec, iter)
+		put_page(bv.bv_page);
+}
+
 static void bio_release_pages(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
+	/* iterate each mp bvec */
+	bio_for_each_segment_all_mp(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
 
 		if (page)
-			put_page(page);
+			release_mp_bvec_pages(bvec);
 	}
 }
 
@@ -1703,20 +1714,38 @@ static void bio_dirty_fn(struct work_struct *work)
 	}
 }
 
+static inline void check_mp_bvec_pages(struct bio_vec *bvec,
+		int *nr_dirty, int *nr_pages)
+{
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	bvec_for_each_sp_bvec(bv, bvec, iter) {
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
 
-	bio_for_each_segment_all(bvec, bio, i) {
-		struct page *page = bvec->bv_page;
+	bio_for_each_segment_all_mp(bvec, bio, i) {
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
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
