Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0CC6B04D5
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 04:55:18 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j124so13047846qke.6
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 01:55:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e2si739535qtb.385.2017.08.08.01.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 01:55:17 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v3 49/49] block: bio: pass segments to bio if bio_add_page() is bypassed
Date: Tue,  8 Aug 2017 16:45:48 +0800
Message-Id: <20170808084548.18963-50-ming.lei@redhat.com>
In-Reply-To: <20170808084548.18963-1-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>

Under some situations, such as block direct I/O, we can't use
bio_add_page() for merging pages into multipage bvec, so
a new function is implemented for converting page array into one
segment array, then these cases can benefit from multipage bvec
too.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 48 insertions(+), 6 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index a5f7fd4ef818..aead0e3e36a9 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -881,6 +881,41 @@ int bio_add_page(struct bio *bio, struct page *page,
 }
 EXPORT_SYMBOL(bio_add_page);
 
+static unsigned convert_to_segs(struct bio* bio, struct page **pages,
+				unsigned char *page_cnt,
+				unsigned nr_pages)
+{
+
+	unsigned idx;
+	unsigned nr_seg = 0;
+	struct request_queue *q = NULL;
+
+	if (bio->bi_bdev)
+		q = bdev_get_queue(bio->bi_bdev);
+
+	if (!q || !blk_queue_cluster(q)) {
+		memset(page_cnt, 0, nr_pages);
+		return nr_pages;
+	}
+
+	page_cnt[nr_seg] = 0;
+	for (idx = 1; idx < nr_pages; idx++) {
+		struct page *pg_s = pages[nr_seg];
+		struct page *pg = pages[idx];
+
+		if (page_to_pfn(pg_s) + page_cnt[nr_seg] + 1 ==
+		    page_to_pfn(pg)) {
+			page_cnt[nr_seg]++;
+		} else {
+			page_cnt[++nr_seg] = 0;
+			if (nr_seg < idx)
+				pages[nr_seg] = pg;
+		}
+	}
+
+	return nr_seg + 1;
+}
+
 /**
  * bio_iov_iter_get_pages - pin user or kernel pages and add them to a bio
  * @bio: bio to add pages to
@@ -900,6 +935,8 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 	struct page **pages = (struct page **)bv;
 	size_t offset, diff;
 	ssize_t size;
+	unsigned short nr_segs;
+	unsigned char page_cnt[nr_pages];	/* at most 256 pages */
 
 	size = iov_iter_get_pages(iter, pages, LONG_MAX, nr_pages, &offset);
 	if (unlikely(size <= 0))
@@ -915,13 +952,18 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 	 * need to be reflected here as well.
 	 */
 	bio->bi_iter.bi_size += size;
-	bio->bi_vcnt += nr_pages;
-
 	diff = (nr_pages * PAGE_SIZE - offset) - size;
-	while (nr_pages--) {
-		bv[nr_pages].bv_page = pages[nr_pages];
-		bv[nr_pages].bv_len = PAGE_SIZE;
-		bv[nr_pages].bv_offset = 0;
+
+	/* convert into segments */
+	nr_segs = convert_to_segs(bio, pages, page_cnt, nr_pages);
+	bio->bi_vcnt += nr_segs;
+
+	while (nr_segs--) {
+		unsigned cnt = (unsigned)page_cnt[nr_segs] + 1;
+
+		bv[nr_segs].bv_page = pages[nr_segs];
+		bv[nr_segs].bv_len = PAGE_SIZE * cnt;
+		bv[nr_segs].bv_offset = 0;
 	}
 
 	bv[0].bv_offset += offset;
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
