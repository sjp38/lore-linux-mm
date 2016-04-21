Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 847AC6B02A9
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:15:26 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so79625554pab.3
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 14:15:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ta4si3145788pac.193.2016.04.21.14.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 14:15:23 -0700 (PDT)
Received: from akpm3.mtv.corp.google.com (unknown [104.132.1.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 6B9B4F34
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 21:15:23 +0000 (UTC)
Date: Thu, 21 Apr 2016 14:15:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: fs/exec.c: fix minor memory leak
Message-Id: <20160421141523.d5a96fd694dd8681be5b1d36@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Could someone please double-check this?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: fs/exec.c: fix minor memory leak

When the to-be-removed argument's trailing '\0' is the final byte in the
page, remove_arg_zero()'s logic will avoid freeing the page, will break
from the loop and will then advance bprm->p to point at the first byte in
the next page.  Net result: the final page for the zeroeth argument is
unfreed.

It isn't a very important leak - that page will be freed later by the
bprm-wide sweep in free_arg_pages().

Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=116841
Reported by: hujunjie <jj.net@163.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/exec.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff -puN fs/exec.c~fs-execc-fix-minor-memory-leak fs/exec.c
--- a/fs/exec.c~fs-execc-fix-minor-memory-leak
+++ a/fs/exec.c
@@ -1482,8 +1482,15 @@ int remove_arg_zero(struct linux_binprm
 		kunmap_atomic(kaddr);
 		put_arg_page(page);
 
-		if (offset == PAGE_SIZE)
+		if (offset == PAGE_SIZE) {
 			free_arg_page(bprm, (bprm->p >> PAGE_SHIFT) - 1);
+		} else if (offset == PAGE_SIZE - 1) {
+			/*
+			 * The trailing '\0' is the last byte in a page - we're
+			 * about to advance past that byte so free its page now
+			 */
+			free_arg_page(bprm, (bprm->p >> PAGE_SHIFT));
+		}
 	} while (offset == PAGE_SIZE);
 
 	bprm->p++;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
