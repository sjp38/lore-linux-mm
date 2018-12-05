Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 096476B749D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 08:49:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so11168016pgb.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 05:49:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor26233940pgs.5.2018.12.05.05.49.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 05:49:11 -0800 (PST)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH] mm: fix polled swap page in
Message-ID: <e15243a8-2cdf-c32c-ecee-f289377c8ef9@kernel.dk>
Date: Wed, 5 Dec 2018 06:49:08 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

swap_readpage() wants to do polling to bring in pages if asked to, but
it doesn't mark the bio as being polled. Additionally, the looping
around the blk_poll() check isn't correct - if we get a zero return, we
should call io_schedule(), we can't just assume that the bio has
completed.  The regular bio->bi_private check should be used for that.

Signed-off-by: Jens Axboe <axboe@kernel.dk>

---

diff --git a/mm/page_io.c b/mm/page_io.c
index 5bdfd21c1bd9..f3455f9f8dc7 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -401,6 +401,8 @@ int swap_readpage(struct page *page, bool synchronous)
 	get_task_struct(current);
 	bio->bi_private = current;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
+	if (synchronous)
+		bio->bi_opf |= REQ_HIPRI;
 	count_vm_event(PSWPIN);
 	bio_get(bio);
 	qc = submit_bio(bio);
@@ -411,7 +413,7 @@ int swap_readpage(struct page *page, bool synchronous)
 			break;
 
 		if (!blk_poll(disk->queue, qc, true))
-			break;
+			io_schedule();
 	}
 	__set_current_state(TASK_RUNNING);
 	bio_put(bio);

-- 
Jens Axboe
