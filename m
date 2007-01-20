Date: Sat, 20 Jan 2007 08:05:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] buffer: memorder fix
Message-ID: <20070120070546.GC30774@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Anyone mind telling me why unlock_buffer, unlike unlock_page, thinks it can
clear the lock without ensuring the critical section is closed (ie. with a
barrier)?

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -78,6 +78,7 @@ EXPORT_SYMBOL(__lock_buffer);
 
 void fastcall unlock_buffer(struct buffer_head *bh)
 {
+	smp_mb__before_clear_bit();
 	clear_buffer_locked(bh);
 	smp_mb__after_clear_bit();
 	wake_up_bit(&bh->b_state, BH_Lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
