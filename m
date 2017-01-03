Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 27ACD6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 15:50:31 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so112771876wjb.7
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 12:50:31 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id qr6si78582810wjc.79.2017.01.03.12.50.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 12:50:30 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id u144so88448753wmu.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 12:50:29 -0800 (PST)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH RESEND] rapidio: use get_user_pages_unlocked()
Date: Tue,  3 Jan 2017 20:50:24 +0000
Message-Id: <20170103205024.6704-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Porter <mporter@kernel.crashing.org>, Alexandre Bounine <alexandre.bounine@idt.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/rapidio/devices/rio_mport_cdev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 9013a585507e..50b617af81bd 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -889,17 +889,16 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 			goto err_req;
 		}

-		down_read(&current->mm->mmap_sem);
-		pinned = get_user_pages(
+		pinned = get_user_pages_unlocked(
 				(unsigned long)xfer->loc_addr & PAGE_MASK,
 				nr_pages,
-				dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
-				page_list, NULL);
-		up_read(&current->mm->mmap_sem);
+				page_list,
+				dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0);

 		if (pinned != nr_pages) {
 			if (pinned < 0) {
-				rmcd_error("get_user_pages err=%ld", pinned);
+				rmcd_error("get_user_pages_unlocked err=%ld",
+					   pinned);
 				nr_pages = 0;
 			} else
 				rmcd_error("pinned %ld out of %ld pages",
--
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
