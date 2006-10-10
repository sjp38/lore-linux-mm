Date: Tue, 10 Oct 2006 04:36:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010023654.GD15822@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

This was triggered, but not the fault of, the dirty page accounting
patches. Suitable for -stable as well, after it goes upstream.

Unable to handle kernel NULL pointer dereference at virtual address 0000004c
EIP is at _spin_lock+0x12/0x66
Call Trace:
 [<401766e7>] __set_page_dirty_buffers+0x15/0xc0
 [<401401e7>] set_page_dirty+0x2c/0x51
 [<40140db2>] set_page_dirty_balance+0xb/0x3b
 [<40145d29>] __do_fault+0x1d8/0x279
 [<40147059>] __handle_mm_fault+0x125/0x951
 [<401133f1>] do_page_fault+0x440/0x59f
 [<4034d0c1>] error_code+0x39/0x40
 [<08048a33>] 0x8048a33
 =======================

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -701,7 +701,10 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  */
 int __set_page_dirty_buffers(struct page *page)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
+
+	if (unlikely(!mapping))
+		return !TestSetPageDirty(page);
 
 	spin_lock(&mapping->private_lock);
 	if (page_has_buffers(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
