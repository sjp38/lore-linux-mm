Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69AAE6B02AC
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:43:50 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 79so93264170wmy.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:50 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y4si17284575wjc.180.2016.11.01.12.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 12:43:49 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id c17so24071057wmc.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:49 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] rapidio: use get_user_pages_unlocked()
Date: Tue,  1 Nov 2016 19:43:47 +0000
Message-Id: <20161101194347.24124-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, Matt Porter <mporter@kernel.crashing.org>, Alexandre Bounine <alexandre.bounine@idt.com>, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/rapidio/devices/rio_mport_cdev.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 9013a58..5fdd081 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -889,13 +889,11 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
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
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
