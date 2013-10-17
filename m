Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAAC6B007B
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 10:49:41 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so2841828pad.37
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 07:49:41 -0700 (PDT)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCH] mm: Check for NULL return values from allocating functions
Date: Thu, 17 Oct 2013 07:49:34 -0700
Message-Id: <1382021374-8285-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>

A security audit revealed that several functions were not checking
return value of allocation functions. These allocations may return
NULL which may lead to NULL pointer dereferences and crashes or
security concerns. Fix this by properly checking the return value
and handling the error appropriately.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 fs/buffer.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 4d74335..b53f863 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1561,6 +1561,9 @@ void create_empty_buffers(struct page *page,
 	struct buffer_head *bh, *head, *tail;
 
 	head = alloc_page_buffers(page, blocksize, 1);
+	if (head == NULL)
+		return;
+
 	bh = head;
 	do {
 		bh->b_state |= b_state;
@@ -3008,16 +3011,18 @@ int _submit_bh(int rw, struct buffer_head *bh, unsigned long bio_flags)
 	BUG_ON(buffer_unwritten(bh));
 
 	/*
-	 * Only clear out a write error when rewriting
-	 */
-	if (test_set_buffer_req(bh) && (rw & WRITE))
-		clear_buffer_write_io_error(bh);
-
-	/*
 	 * from here on down, it's all bio -- do the initial mapping,
 	 * submit_bio -> generic_make_request may further map this bio around
 	 */
 	bio = bio_alloc(GFP_NOIO, 1);
+	if (bio == NULL)
+		return -ENOMEM;
+
+	/*
+	 * Only clear out a write error when rewriting
+	 */
+	if (test_set_buffer_req(bh) && (rw & WRITE))
+		clear_buffer_write_io_error(bh);
 
 	bio->bi_sector = bh->b_blocknr * (bh->b_size >> 9);
 	bio->bi_bdev = bh->b_bdev;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
