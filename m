Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5918A6B0253
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 08:10:44 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id td3so9684061pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:10:44 -0700 (PDT)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id w68si1241357pfa.234.2016.04.05.05.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 05:10:43 -0700 (PDT)
Received: by mail-pa0-x241.google.com with SMTP id q6so1151103pav.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:10:43 -0700 (PDT)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 27/27] mm: page_io.c: use bio_get_base_vec()
Date: Tue,  5 Apr 2016 20:07:42 +0800
Message-Id: <1459858062-21075-13-git-send-email-tom.leiming@gmail.com>
In-Reply-To: <1459858062-21075-1-git-send-email-tom.leiming@gmail.com>
References: <1459858062-21075-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>, Ming Lei <tom.leiming@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dongsu Park <dpark@posteo.net>, Minchan Kim <minchan@kernel.org>, Tejun Heo <tj@kernel.org>, Joe Perches <joe@perches.com>, Kent Overstreet <kent.overstreet@gmail.com>, Omar Sandoval <osandov@osandov.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 mm/page_io.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 18aac78..b5a6baf 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -43,7 +43,14 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 
 void end_swap_bio_write(struct bio *bio)
 {
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	/*
+	 * Single bvec bio.
+	 *
+	 * For accessing page pointed to by the 1st bvec, it
+	 * works too after multipage bvecs.
+	 */
+	struct bio_vec *bvec = bio_get_base_vec(bio);
+	struct page *page = bvec->bv_page;
 
 	if (bio->bi_error) {
 		SetPageError(page);
@@ -116,7 +123,14 @@ static void swap_slot_free_notify(struct page *page)
 
 static void end_swap_bio_read(struct bio *bio)
 {
-	struct page *page = bio->bi_io_vec[0].bv_page;
+	/*
+	 * Single bvec bio.
+	 *
+	 * For accessing page pointed to by the 1st bvec, it
+	 * works too after multipage bvecs.
+	 */
+	struct bio_vec *bvec = bio_get_base_vec(bio);
+	struct page *page = bvec->bv_page;
 
 	if (bio->bi_error) {
 		SetPageError(page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
