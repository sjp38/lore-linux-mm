Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D7D1C6B029D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:24:52 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so157525974wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gc9si36857483wjb.57.2015.10.06.02.24.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:49 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 1/7] cris: Convert cryptocop to use get_user_pages_fast()
Date: Tue,  6 Oct 2015 11:24:24 +0200
Message-Id: <1444123470-4932-2-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, linux-cris-kernel@axis.com, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>

From: Jan Kara <jack@suse.cz>

CC: linux-cris-kernel@axis.com
CC: Mikael Starvik <starvik@axis.com>
CC: Jesper Nilsson <jesper.nilsson@axis.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/cris/arch-v32/drivers/cryptocop.c | 35 ++++++++++------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/drivers/cryptocop.c
index 877da1908234..df7ceeff1086 100644
--- a/arch/cris/arch-v32/drivers/cryptocop.c
+++ b/arch/cris/arch-v32/drivers/cryptocop.c
@@ -2716,43 +2716,28 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 		}
 	}
 
-	/* Acquire the mm page semaphore. */
-	down_read(&current->mm->mmap_sem);
-
-	err = get_user_pages(current,
-			     current->mm,
-			     (unsigned long int)(oper.indata + prev_ix),
-			     noinpages,
-			     0,  /* read access only for in data */
-			     0, /* no force */
-			     inpages,
-			     NULL);
+	err = get_user_pages_fast((unsigned long)(oper.indata + prev_ix),
+				  noinpages,
+				  0,  /* read access only for in data */
+				  inpages);
 
 	if (err < 0) {
-		up_read(&current->mm->mmap_sem);
 		nooutpages = noinpages = 0;
-		DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages indata\n"));
+		DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages_fast indata\n"));
 		goto error_cleanup;
 	}
 	noinpages = err;
 	if (oper.do_cipher){
-		err = get_user_pages(current,
-				     current->mm,
-				     (unsigned long int)oper.cipher_outdata,
-				     nooutpages,
-				     1, /* write access for out data */
-				     0, /* no force */
-				     outpages,
-				     NULL);
-		up_read(&current->mm->mmap_sem);
+		err = get_user_pages_fast((unsigned long)oper.cipher_outdata,
+					  nooutpages,
+					  1, /* write access for out data */
+					  outpages);
 		if (err < 0) {
 			nooutpages = 0;
-			DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages outdata\n"));
+			DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages_fast outdata\n"));
 			goto error_cleanup;
 		}
 		nooutpages = err;
-	} else {
-		up_read(&current->mm->mmap_sem);
 	}
 
 	/* Add 6 to nooutpages to make room for possibly inserted buffers for storing digest and
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
