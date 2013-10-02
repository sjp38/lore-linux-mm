Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 852E56B0038
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:02 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so1089033pab.8
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:02 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 13/26] fsl_hypervisor: Convert ioctl_memcpy() to use get_user_pages_fast()
Date: Wed,  2 Oct 2013 16:27:54 +0200
Message-Id: <1380724087-13927-14-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Timur Tabi <timur@freescale.com>

CC: Timur Tabi <timur@freescale.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/virt/fsl_hypervisor.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index d294f67d6f84..791a46a5dd2a 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -242,13 +242,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
