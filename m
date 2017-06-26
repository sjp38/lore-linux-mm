Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37DA16B0365
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:14:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v19so47692239qkl.12
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:14:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m84si11681553qkh.57.2017.06.26.05.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 05:14:35 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH v2 11/51] md: raid1: initialize bvec table via bio_add_page()
Date: Mon, 26 Jun 2017 20:09:54 +0800
Message-Id: <20170626121034.3051-12-ming.lei@redhat.com>
In-Reply-To: <20170626121034.3051-1-ming.lei@redhat.com>
References: <20170626121034.3051-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Ming Lei <ming.lei@redhat.com>, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

We will support multipage bvec soon, so initialize bvec
table using the standardy way instead of writing the
talbe directly. Otherwise it won't work any more once
multipage bvec is enabled.

Cc: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/raid1.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 3febfc8391fb..835c42396861 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -2086,10 +2086,8 @@ static void process_checks(struct r1bio *r1_bio)
 	/* Fix variable parts of all bios */
 	vcnt = (r1_bio->sectors + PAGE_SIZE / 512 - 1) >> (PAGE_SHIFT - 9);
 	for (i = 0; i < conf->raid_disks * 2; i++) {
-		int j;
 		int size;
 		blk_status_t status;
-		struct bio_vec *bi;
 		struct bio *b = r1_bio->bios[i];
 		struct resync_pages *rp = get_resync_pages(b);
 		if (b->bi_end_io != end_sync_read)
@@ -2098,8 +2096,6 @@ static void process_checks(struct r1bio *r1_bio)
 		status = b->bi_status;
 		bio_reset(b);
 		b->bi_status = status;
-		b->bi_vcnt = vcnt;
-		b->bi_iter.bi_size = r1_bio->sectors << 9;
 		b->bi_iter.bi_sector = r1_bio->sector +
 			conf->mirrors[i].rdev->data_offset;
 		b->bi_bdev = conf->mirrors[i].rdev->bdev;
@@ -2107,15 +2103,20 @@ static void process_checks(struct r1bio *r1_bio)
 		rp->raid_bio = r1_bio;
 		b->bi_private = rp;
 
-		size = b->bi_iter.bi_size;
-		bio_for_each_segment_all(bi, b, j) {
-			bi->bv_offset = 0;
-			if (size > PAGE_SIZE)
-				bi->bv_len = PAGE_SIZE;
-			else
-				bi->bv_len = size;
-			size -= PAGE_SIZE;
-		}
+		/* initialize bvec table again */
+		rp->idx = 0;
+		size = r1_bio->sectors << 9;
+		do {
+			struct page *page = resync_fetch_page(rp, rp->idx++);
+			int len = min_t(int, size, PAGE_SIZE);
+
+			/*
+			 * won't fail because the vec table is big
+			 * enough to hold all these pages
+			 */
+			bio_add_page(b, page, len, 0);
+			size -= len;
+		} while (rp->idx < RESYNC_PAGES && size > 0);
 	}
 	for (primary = 0; primary < conf->raid_disks * 2; primary++)
 		if (r1_bio->bios[primary]->bi_end_io == end_sync_read &&
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
