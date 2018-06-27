Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADEF6B0279
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:47:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id f8-v6so1754418qtb.23
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:47:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x2-v6si1762174qvn.14.2018.06.27.05.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:47:45 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 09/24] block: use bio_add_page in bio_iov_iter_get_pages
Date: Wed, 27 Jun 2018 20:45:33 +0800
Message-Id: <20180627124548.3456-10-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

Replace a nasty hack with a different nasty hack to prepare for multipage
bio_vecs.  By moving the temporary page array as far up as possible in
the space allocated for the bio_vec array we can iterate forward over it
and thus use bio_add_page.  Using bio_add_page means we'll be able to
merge physically contiguous pages once support for multipath bio_vecs is
merged.

Reviewed-by: Ming Lei <ming.lei@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/bio.c | 45 +++++++++++++++++++++------------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index de6cbaedfb65..80ea0c8878bd 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -825,6 +825,8 @@ int bio_add_page(struct bio *bio, struct page *page,
 }
 EXPORT_SYMBOL(bio_add_page);
 
+#define PAGE_PTRS_PER_BVEC	(sizeof(struct bio_vec) / sizeof(struct page *))
+
 /**
  * bio_iov_iter_get_pages - pin user or kernel pages and add them to a bio
  * @bio: bio to add pages to
@@ -836,38 +838,33 @@ EXPORT_SYMBOL(bio_add_page);
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
 {
 	unsigned short nr_pages = bio->bi_max_vecs - bio->bi_vcnt;
+	unsigned short entries_left = bio->bi_max_vecs - bio->bi_vcnt;
 	struct bio_vec *bv = bio->bi_io_vec + bio->bi_vcnt;
 	struct page **pages = (struct page **)bv;
-	size_t offset, diff;
-	ssize_t size;
+	ssize_t size, left;
+	unsigned len, i;
+	size_t offset;
+
+	/*
+	 * Move page array up in the allocated memory for the bio vecs as
+	 * far as possible so that we can start filling biovecs from the
+	 * beginning without overwriting the temporary page array.
+	 */
+	BUILD_BUG_ON(PAGE_PTRS_PER_BVEC < 2);
+	pages += entries_left * (PAGE_PTRS_PER_BVEC - 1);
 
 	size = iov_iter_get_pages(iter, pages, LONG_MAX, nr_pages, &offset);
 	if (unlikely(size <= 0))
 		return size ? size : -EFAULT;
-	nr_pages = (size + offset + PAGE_SIZE - 1) / PAGE_SIZE;
 
-	/*
-	 * Deep magic below:  We need to walk the pinned pages backwards
-	 * because we are abusing the space allocated for the bio_vecs
-	 * for the page array.  Because the bio_vecs are larger than the
-	 * page pointers by definition this will always work.  But it also
-	 * means we can't use bio_add_page, so any changes to it's semantics
-	 * need to be reflected here as well.
-	 */
-	bio->bi_iter.bi_size += size;
-	bio->bi_vcnt += nr_pages;
-
-	diff = (nr_pages * PAGE_SIZE - offset) - size;
-	while (nr_pages--) {
-		bv[nr_pages].bv_page = pages[nr_pages];
-		bv[nr_pages].bv_len = PAGE_SIZE;
-		bv[nr_pages].bv_offset = 0;
-	}
+	for (left = size, i = 0; left > 0; left -= len, i++) {
+		struct page *page = pages[i];
 
-	bv[0].bv_offset += offset;
-	bv[0].bv_len -= offset;
-	if (diff)
-		bv[bio->bi_vcnt - 1].bv_len -= diff;
+		len = min_t(size_t, PAGE_SIZE - offset, left);
+		if (WARN_ON_ONCE(bio_add_page(bio, page, len, offset) != len))
+			return -EINVAL;
+		offset = 0;
+	}
 
 	iov_iter_advance(iter, size);
 	return 0;
-- 
2.9.5
