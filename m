Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0BC6B0275
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:47:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g8-v6so1855413qtp.19
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 05:47:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p184-v6si3893824qkb.380.2018.06.27.05.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 05:47:22 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V7 07/24] block: simplify bio_check_pages_dirty
Date: Wed, 27 Jun 2018 20:45:31 +0800
Message-Id: <20180627124548.3456-8-ming.lei@redhat.com>
In-Reply-To: <20180627124548.3456-1-ming.lei@redhat.com>
References: <20180627124548.3456-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, Mike Snitzer <snitzer@redhat.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>, Christoph Hellwig <hch@lst.de>

From: Christoph Hellwig <hch@lst.de>

bio_check_pages_dirty currently inviolates the invariant that bv_page of
a bio_vec inside bi_vcnt shouldn't be zero, and that is going to become
really annoying with multpath biovecs.  Fortunately there isn't any
all that good reason for it - once we decide to defer freeing the bio
to a workqueue holding onto a few additional pages isn't really an
issue anymore.  So just check if there is a clean page that needs
dirtying in the first path, and do a second pass to free them if there
was none, while the cache is still hot.

Also use the chance to micro-optimize bio_dirty_fn a bit by not saving
irq state - we know we are called from a workqueue.

Reviewed-by: Ming Lei <ming.lei@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 block/bio.c | 56 +++++++++++++++++++++-----------------------------------
 1 file changed, 21 insertions(+), 35 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 43698bcff737..77f991688810 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1570,19 +1570,15 @@ static void bio_release_pages(struct bio *bio)
 	struct bio_vec *bvec;
 	int i;
 
-	bio_for_each_segment_all(bvec, bio, i) {
-		struct page *page = bvec->bv_page;
-
-		if (page)
-			put_page(page);
-	}
+	bio_for_each_segment_all(bvec, bio, i)
+		put_page(bvec->bv_page);
 }
 
 /*
  * bio_check_pages_dirty() will check that all the BIO's pages are still dirty.
  * If they are, then fine.  If, however, some pages are clean then they must
  * have been written out during the direct-IO read.  So we take another ref on
- * the BIO and the offending pages and re-dirty the pages in process context.
+ * the BIO and re-dirty the pages in process context.
  *
  * It is expected that bio_check_pages_dirty() will wholly own the BIO from
  * here on.  It will run one put_page() against each page and will run one
@@ -1600,52 +1596,42 @@ static struct bio *bio_dirty_list;
  */
 static void bio_dirty_fn(struct work_struct *work)
 {
-	unsigned long flags;
-	struct bio *bio;
+	struct bio *bio, *next;
 
-	spin_lock_irqsave(&bio_dirty_lock, flags);
-	bio = bio_dirty_list;
+	spin_lock_irq(&bio_dirty_lock);
+	next = bio_dirty_list;
 	bio_dirty_list = NULL;
-	spin_unlock_irqrestore(&bio_dirty_lock, flags);
+	spin_unlock_irq(&bio_dirty_lock);
 
-	while (bio) {
-		struct bio *next = bio->bi_private;
+	while ((bio = next) != NULL) {
+		next = bio->bi_private;
 
 		bio_set_pages_dirty(bio);
 		bio_release_pages(bio);
 		bio_put(bio);
-		bio = next;
 	}
 }
 
 void bio_check_pages_dirty(struct bio *bio)
 {
 	struct bio_vec *bvec;
-	int nr_clean_pages = 0;
+	unsigned long flags;
 	int i;
 
 	bio_for_each_segment_all(bvec, bio, i) {
-		struct page *page = bvec->bv_page;
-
-		if (PageDirty(page) || PageCompound(page)) {
-			put_page(page);
-			bvec->bv_page = NULL;
-		} else {
-			nr_clean_pages++;
-		}
+		if (!PageDirty(bvec->bv_page) && !PageCompound(bvec->bv_page))
+			goto defer;
 	}
 
-	if (nr_clean_pages) {
-		unsigned long flags;
-
-		spin_lock_irqsave(&bio_dirty_lock, flags);
-		bio->bi_private = bio_dirty_list;
-		bio_dirty_list = bio;
-		spin_unlock_irqrestore(&bio_dirty_lock, flags);
-		schedule_work(&bio_dirty_work);
-	} else {
-		bio_put(bio);
-	}
+	bio_release_pages(bio);
+	bio_put(bio);
+	return;
+defer:
+	spin_lock_irqsave(&bio_dirty_lock, flags);
+	bio->bi_private = bio_dirty_list;
+	bio_dirty_list = bio;
+	spin_unlock_irqrestore(&bio_dirty_lock, flags);
+	schedule_work(&bio_dirty_work);
 }
 EXPORT_SYMBOL_GPL(bio_check_pages_dirty);
 
-- 
2.9.5
