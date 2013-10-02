Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 320446B0037
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:01 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so951393pbb.19
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:00 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 07/26] st: Convert sgl_map_user_pages() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:48 +0200
Message-Id: <1380724087-13927-8-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, Kai Makisara <Kai.Makisara@kolumbus.fi>

CC: linux-scsi@vger.kernel.org
CC: Kai Makisara <Kai.Makisara@kolumbus.fi>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/scsi/st.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index ff44b3c2cff2..ba11299c3740 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -4514,19 +4514,11 @@ static int sgl_map_user_pages(struct st_buffer *STbp,
 	if ((pages = kmalloc(max_pages * sizeof(*pages), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
 
-        /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
-        /* rw==READ means read from drive, write into memory area */
-	res = get_user_pages(
-		current,
-		current->mm,
-		uaddr,
-		nr_pages,
-		rw == READ,
-		0, /* don't force */
-		pages,
-		NULL);
-	up_read(&current->mm->mmap_sem);
+        /*
+	 * Try to fault in all of the necessary pages. rw==READ means read
+	 * from drive, write into memory area.
+	 */
+	res = get_user_pages_fast(uaddr, nr_pages, rw == READ, pages);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
