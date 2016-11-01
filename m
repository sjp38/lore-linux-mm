Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37E736B02A1
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:43:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so93261446wmy.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:36 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id w3si4354326wjd.161.2016.11.01.12.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 12:43:34 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 68so17370863wmz.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:34 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] drivers/virt: use get_user_pages_unlocked()
Date: Tue,  1 Nov 2016 19:43:32 +0000
Message-Id: <20161101194332.23961-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, Timur Tabi <timur@freescale.com>, Kumar Gala <galak@kernel.crashing.org>, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/virt/fsl_hypervisor.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 150ce2a..d3eca87 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -243,11 +243,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	sg_list = PTR_ALIGN(sg_list_unaligned, sizeof(struct fh_sg_list));
 
 	/* Get the physical addresses of the source buffer */
-	down_read(&current->mm->mmap_sem);
-	num_pinned = get_user_pages(param.local_vaddr - lb_offset,
-		num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
-		pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	num_pinned = get_user_pages_unlocked(param.local_vaddr - lb_offset,
+		num_pages, pages, (param.source == -1) ? 0 : FOLL_WRITE);
 
 	if (num_pinned != num_pages) {
 		/* get_user_pages() failed */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
