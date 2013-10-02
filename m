Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4260C6B0031
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:00 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so956322pdj.3
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:28:59 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 03/26] dma: Use get_user_pages_fast() in dma_pin_iovec_pages()
Date: Wed,  2 Oct 2013 16:27:44 +0200
Message-Id: <1380724087-13927-4-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>

CC: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/dma/iovlock.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/dma/iovlock.c b/drivers/dma/iovlock.c
index bb48a57c2fc1..8b16332da8a9 100644
--- a/drivers/dma/iovlock.c
+++ b/drivers/dma/iovlock.c
@@ -95,17 +95,10 @@ struct dma_pinned_list *dma_pin_iovec_pages(struct iovec *iov, size_t len)
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(
-			current,
-			current->mm,
-			(unsigned long) iov[i].iov_base,
-			page_list->nr_pages,
-			1,	/* write */
-			0,	/* force */
-			page_list->pages,
-			NULL);
-		up_read(&current->mm->mmap_sem);
+		ret = get_user_pages_fast((unsigned long) iov[i].iov_base,
+					  page_list->nr_pages,
+					  1,	/* write */
+					  page_list->pages);
 
 		if (ret != page_list->nr_pages)
 			goto unpin;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
