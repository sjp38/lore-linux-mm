Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AD9B26B003D
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:03 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so958851pbb.27
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:03 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 08/26] ced1401: Convert driver to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:49 +0200
Message-Id: <1380724087-13927-9-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/ced1401/ced_ioc.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/ced1401/ced_ioc.c b/drivers/staging/ced1401/ced_ioc.c
index 2dbaf39e2fc2..62efd74b8c04 100644
--- a/drivers/staging/ced1401/ced_ioc.c
+++ b/drivers/staging/ced1401/ced_ioc.c
@@ -692,10 +692,7 @@ static int SetArea(DEVICE_EXTENSION *pdx, int nArea, char __user *puBuf,
 		__func__, puBuf, dwLength, bCircular);
 
 	/*  To pin down user pages we must first acquire the mapping semaphore. */
-	down_read(&current->mm->mmap_sem);	/*  get memory map semaphore */
-	nPages = get_user_pages(current, current->mm, ulStart, len, 1, 0,
-				pPages, NULL);
-	up_read(&current->mm->mmap_sem);	/*  release the semaphore */
+	nPages = get_user_pages_fast(ulStart, len, 1, pPages);
 	dev_dbg(&pdx->interface->dev, "%s nPages = %d", __func__, nPages);
 
 	if (nPages > 0) {		/*  if we succeeded */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
