Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 734D56B000C
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:52:31 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e8-v6so2945017qtj.0
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:52:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j123-v6si7354771qkd.369.2018.05.24.20.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:52:30 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 31/33] block: bio: pass segments to bio if bio_add_page() is bypassed
Date: Fri, 25 May 2018 11:46:19 +0800
Message-Id: <20180525034621.31147-32-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

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
index bc3992f52fe8..b7d9089cb28f 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -913,6 +913,41 @@ int bio_add_page(struct bio *bio, struct page *page,
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
+	if (bio->bi_disk)
+		q = bio->bi_disk->queue;
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
@@ -928,6 +963,8 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 	struct page **pages = (struct page **)bv;
 	size_t offset, diff;
 	ssize_t size;
+	unsigned short nr_segs;
+	unsigned char page_cnt[nr_pages];	/* at most 256 pages */
 
 	size = iov_iter_get_pages(iter, pages, LONG_MAX, nr_pages, &offset);
 	if (unlikely(size <= 0))
@@ -943,13 +980,18 @@ int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
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
2.9.5
