Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 082156B007E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:03:51 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m2so43994016ioa.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:03:51 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id g4si13987525oep.19.2016.04.14.05.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 05:03:50 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id w18so9556168oie.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 05:03:50 -0700 (PDT)
From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH v1 27/27] mm: page_io.c: use bio_get_base_vec()
Date: Thu, 14 Apr 2016 20:02:45 +0800
Message-Id: <1460635375-28282-28-git-send-email-tom.leiming@gmail.com>
In-Reply-To: <1460635375-28282-1-git-send-email-tom.leiming@gmail.com>
References: <1460635375-28282-1-git-send-email-tom.leiming@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org
Cc: linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Ming Lei <tom.leiming@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dongsu Park <dpark@posteo.net>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Kent Overstreet <kent.overstreet@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joe Perches <joe@perches.com>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 mm/page_io.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index cd92e3d..1ced9d3 100644
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
