Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2F37982F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:25:01 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so157531125wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:25:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l20si36838397wjw.125.2015.10.06.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 4/7] fsl_hypervisor: Convert ioctl_memcpy() to use get_user_pages_fast()
Date: Tue,  6 Oct 2015 11:24:27 +0200
Message-Id: <1444123470-4932-5-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Timur Tabi <timur@freescale.com>

From: Jan Kara <jack@suse.cz>

CC: Timur Tabi <timur@freescale.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/virt/fsl_hypervisor.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 32c8fc5f7a5c..c65e5e60d7fd 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -243,13 +243,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
 
 	/* Get the physical addresses of the source buffer */
-	down_read(&current->mm->mmap_sem);
-	num_pinned = get_user_pages(current, current->mm,
-		param.local_vaddr - lb_offset, num_pages,
-		(param.source == -1) ? READ : WRITE,
-		0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
-
+	num_pinned = get_user_pages_fast(param.local_vaddr - lb_offset,
+		num_pages, (param.source == -1) ? READ : WRITE, pages);
 	if (num_pinned != num_pages) {
 		/* get_user_pages() failed */
 		pr_debug("fsl-hv: could not lock source buffer\n");
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
