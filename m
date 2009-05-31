Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A98C75F0001
	for <linux-mm@kvack.org>; Sat, 30 May 2009 21:57:13 -0400 (EDT)
Date: Sat, 30 May 2009 18:55:37 -0700
From: "Larry H." <research@subreption.com>
Subject: [PATCH] Use kzfree in tty buffer management to enforce data
	sanitization
Message-ID: <20090531015537.GA8941@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

[PATCH] Use kzfree in tty buffer management to enforce data sanitization

This patch replaces the kfree() calls within the tty buffer management API
with kzfree(), to enforce sanitization of the buffer contents.

It also takes care of handling buffers larger than PAGE_SIZE, which are
allocated via the page allocator directly.

This prevents such information from persisting on memory, potentially
leaking sensitive data like access credentials, or being leaked to other
kernel users after re-allocation of the memory by the LIFO allocators.

This patch doesn't affect fastpaths.

Signed-off-by: Larry Highsmith <research@subreption.com>

Index: linux-2.6/drivers/char/tty_audit.c
===================================================================
--- linux-2.6.orig/drivers/char/tty_audit.c
+++ linux-2.6/drivers/char/tty_audit.c
@@ -54,10 +54,12 @@ err:
 static void tty_audit_buf_free(struct tty_audit_buf *buf)
 {
 	WARN_ON(buf->valid != 0);
-	if (PAGE_SIZE != N_TTY_BUF_SIZE)
-		kfree(buf->data);
-	else
+	if (PAGE_SIZE != N_TTY_BUF_SIZE) {
+		kzfree(buf->data);
+	} else {
+		memset(buf->data, 0, PAGE_SIZE);
 		free_page((unsigned long)buf->data);
+	}
 	kfree(buf);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
