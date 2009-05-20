Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 878E86B0093
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:41:07 -0400 (EDT)
Date: Wed, 20 May 2009 11:41:17 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 1/5] Apply the PG_sensitive flag to the tty API
Message-ID: <20090520184117.GA10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch deploys the use of the PG_sensitive page allocator flag
within the tty API, in the buffer management, input event handling
and input auditing code.

This should provide an additional safety layer against tty buffers
leaking information including passwords and other likely sensitive
input.

Again, you might refer to the paper by Jim Chow et. al on reducing
data resilience through secure deallocation. It explicitly mentions
this case, as well as other scenarios [1].

	[1] http://www.stanford.edu/~blp/papers/shredding.html

Signed-off-by: Larry H. <research@subreption.com>

---
 drivers/char/tty_audit.c  |    6 +++---
 drivers/char/tty_buffer.c |    2 +-
 drivers/char/tty_io.c     |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/char/tty_audit.c
===================================================================
--- linux-2.6.orig/drivers/char/tty_audit.c
+++ linux-2.6/drivers/char/tty_audit.c
@@ -28,13 +28,13 @@ static struct tty_audit_buf *tty_audit_b
 {
 	struct tty_audit_buf *buf;
 
-	buf = kmalloc(sizeof(*buf), GFP_KERNEL);
+	buf = kmalloc(sizeof(*buf), GFP_KERNEL | GFP_SENSITIVE);
 	if (!buf)
 		goto err;
 	if (PAGE_SIZE != N_TTY_BUF_SIZE)
-		buf->data = kmalloc(N_TTY_BUF_SIZE, GFP_KERNEL);
+		buf->data = kmalloc(N_TTY_BUF_SIZE, GFP_KERNEL | GFP_SENSITIVE);
 	else
-		buf->data = (unsigned char *)__get_free_page(GFP_KERNEL);
+		buf->data = (unsigned char *)__get_free_page(GFP_KERNEL | GFP_SENSITIVE);
 	if (!buf->data)
 		goto err_buf;
 	atomic_set(&buf->count, 1);
Index: linux-2.6/drivers/char/tty_buffer.c
===================================================================
--- linux-2.6.orig/drivers/char/tty_buffer.c
+++ linux-2.6/drivers/char/tty_buffer.c
@@ -60,7 +60,7 @@ static struct tty_buffer *tty_buffer_all
 
 	if (tty->buf.memory_used + size > 65536)
 		return NULL;
-	p = kmalloc(sizeof(struct tty_buffer) + 2 * size, GFP_ATOMIC);
+	p = kmalloc(sizeof(struct tty_buffer) + 2 * size, GFP_ATOMIC | GFP_SENSITIVE);
 	if (p == NULL)
 		return NULL;
 	p->used = 0;
Index: linux-2.6/drivers/char/tty_io.c
===================================================================
--- linux-2.6.orig/drivers/char/tty_io.c
+++ linux-2.6/drivers/char/tty_io.c
@@ -1031,7 +1031,7 @@ static inline ssize_t do_tty_write(
 		if (chunk < 1024)
 			chunk = 1024;
 
-		buf_chunk = kmalloc(chunk, GFP_KERNEL);
+		buf_chunk = kmalloc(chunk, GFP_KERNEL | GFP_SENSITIVE);
 		if (!buf_chunk) {
 			ret = -ENOMEM;
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
