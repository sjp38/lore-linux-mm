Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41CA26B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:15:09 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so70271508wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 04:15:09 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id k4si15648252wje.12.2016.02.26.04.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 04:15:08 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] staging/goldfish: use 6-arg get_user_pages()
Date: Fri, 26 Feb 2016 12:59:43 +0100
Message-Id: <1456488033-4044939-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jin Qian <jinqian@android.com>, linux-kernel@vger.kernel.org

After commit cde70140fed8 ("mm/gup: Overload get_user_pages() functions"),
we get warning for this file, as it calls get_user_pages() with eight
arguments after the change of the calling convention to use only six:

drivers/platform/goldfish/goldfish_pipe.c: In function 'goldfish_pipe_read_write':
drivers/platform/goldfish/goldfish_pipe.c:312:3: error: 'get_user_pages8' is deprecated [-Werror=deprecated-declarations]

This removes the first two arguments, which are now the default.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
The API change is currently only in the mm/pkeys branch of the
tip tree, while the goldfish_pipe driver started using the
old API in the staging/next branch.

Andrew could pick it up into linux-mm in the meantime, or I can
resend it at some later point if nobody else does the change
after 4.6-rc1.
---
 drivers/platform/goldfish/goldfish_pipe.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 9973cebb4d6f..07462d79d040 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -309,8 +309,7 @@ static ssize_t goldfish_pipe_read_write(struct file *filp, char __user *buffer,
 		 * much memory to the process.
 		 */
 		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(current, current->mm, address, 1,
-				     !is_write, 0, &page, NULL);
+		ret = get_user_pages(address, 1, !is_write, 0, &page, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (ret < 0)
 			break;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
