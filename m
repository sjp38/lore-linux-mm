Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C32EC6B0039
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:43:54 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so992383pdj.40
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:43:54 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 26/26] aio: Remove useless get_user_pages() call
Date: Wed,  2 Oct 2013 16:28:07 +0200
Message-Id: <1380724087-13927-27-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>

get_user_pages() call in aio_setup_ring() is useless these days. We
create all ringbuffer the pages in page cache using
find_or_create_page() anyway so we can just use the pointers we get from
this function instead of having to look them up via user address space.

CC: linux-fsdevel@vger.kernel.org
CC: linux-aio@kvack.org
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/aio.c | 48 +++++++++++++++++-------------------------------
 1 file changed, 17 insertions(+), 31 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 6b868f0e0c4c..a14a33027990 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -269,9 +269,21 @@ static int aio_setup_ring(struct kioctx *ctx)
 	file->f_inode->i_mapping->a_ops = &aio_ctx_aops;
 	file->f_inode->i_mapping->private_data = ctx;
 	file->f_inode->i_size = PAGE_SIZE * (loff_t)nr_pages;
+	ctx->aio_ring_file = file;
+	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring))
+			/ sizeof(struct io_event);
+
+	ctx->ring_pages = ctx->internal_pages;
+	if (nr_pages > AIO_RING_PAGES) {
+		ctx->ring_pages = kcalloc(nr_pages, sizeof(struct page *),
+					  GFP_KERNEL);
+		if (!ctx->ring_pages)
+			return -ENOMEM;
+	}
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
+
 		page = find_or_create_page(file->f_inode->i_mapping,
 					   i, GFP_HIGHUSER | __GFP_ZERO);
 		if (!page)
@@ -281,19 +293,13 @@ static int aio_setup_ring(struct kioctx *ctx)
 		SetPageUptodate(page);
 		SetPageDirty(page);
 		unlock_page(page);
+		ctx->ring_pages[i] = page;
 	}
-	ctx->aio_ring_file = file;
-	nr_events = (PAGE_SIZE * nr_pages - sizeof(struct aio_ring))
-			/ sizeof(struct io_event);
-
-	ctx->ring_pages = ctx->internal_pages;
-	if (nr_pages > AIO_RING_PAGES) {
-		ctx->ring_pages = kcalloc(nr_pages, sizeof(struct page *),
-					  GFP_KERNEL);
-		if (!ctx->ring_pages)
-			return -ENOMEM;
+	ctx->nr_pages = i;
+	if (unlikely(ctx->nr_pages != nr_pages)) {
+		aio_free_ring(ctx);
+		return -EAGAIN;
 	}
-
 	ctx->mmap_size = nr_pages * PAGE_SIZE;
 	pr_debug("attempting mmap of %lu bytes\n", ctx->mmap_size);
 
@@ -309,28 +315,8 @@ static int aio_setup_ring(struct kioctx *ctx)
 	}
 
 	pr_debug("mmap address: 0x%08lx\n", ctx->mmap_base);
-
-	/* We must do this while still holding mmap_sem for write, as we
-	 * need to be protected against userspace attempting to mremap()
-	 * or munmap() the ring buffer.
-	 */
-	ctx->nr_pages = get_user_pages(current, mm, ctx->mmap_base, nr_pages,
-				       1, 0, ctx->ring_pages, NULL);
-
-	/* Dropping the reference here is safe as the page cache will hold
-	 * onto the pages for us.  It is also required so that page migration
-	 * can unmap the pages and get the right reference count.
-	 */
-	for (i = 0; i < ctx->nr_pages; i++)
-		put_page(ctx->ring_pages[i]);
-
 	up_write(&mm->mmap_sem);
 
-	if (unlikely(ctx->nr_pages != nr_pages)) {
-		aio_free_ring(ctx);
-		return -EAGAIN;
-	}
-
 	ctx->user_id = ctx->mmap_base;
 	ctx->nr_events = nr_events; /* trusted copy */
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
