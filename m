Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC9F6B02AB
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:43:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 68so67001000wmz.5
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:46 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id m139si6614249wmb.129.2016.11.01.12.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 12:43:45 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id 68so17371400wmz.2
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:43:45 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] platform: goldfish: pipe: use get_user_pages_unlocked()
Date: Tue,  1 Nov 2016 19:43:43 +0000
Message-Id: <20161101194343.24072-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lorenzo Stoakes <lstoakes@gmail.com>

Moving from get_user_pages() to get_user_pages_unlocked() simplifies the code
and takes advantage of VM_FAULT_RETRY functionality when faulting in pages.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 drivers/platform/goldfish/goldfish_pipe.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 1aba2c7..2b21033 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -308,10 +308,8 @@ static ssize_t goldfish_pipe_read_write(struct file *filp, char __user *buffer,
 		 * returns a small amount, then there's no need to pin that
 		 * much memory to the process.
 		 */
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(address, 1, is_write ? 0 : FOLL_WRITE,
-				&page, NULL);
-		up_read(&current->mm->mmap_sem);
+		ret = get_user_pages_unlocked(address, 1, &page,
+				is_write ? 0 : FOLL_WRITE);
 		if (ret < 0)
 			break;
 
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
