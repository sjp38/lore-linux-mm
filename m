Date: Fri, 6 Apr 2001 19:47:48 +0300
From: "Velizar Bodurski" <velizar81@yahoo.com>
Subject: [PATCH] thinko in filemap.c
Message-ID: <20010406194748.A561@koil.lint>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

There is a small thinko in the way remove_page_from_inode_queue()
and __remove_inode_page() are working together. A patch follows 
which should separate the work for the different functions.
Right now remove_page_from_inode_queue() after doing its job
is doing page->mapping = NULL;
This function is called by __remove_inode_page with no locks held
which also is doing page->mapping = NULL, this is needles. So with
this patch i'm removing the second NULLifying of the page's mapping.

Any comments are welcome. There is one question with this patch
and that is shouldn't it be the reverse way, I may have gotten
it the wrong way :).

This is against 2.4.3

----
diff -u mm/filemap.c.orig mm/filemap.c
--- mm/filemap.c.orig	Fri Apr  6 19:33:41 2001
+++ mm/filemap.c	Fri Apr  6 19:38:51 2001
@@ -108,7 +108,6 @@
 	if (PageDirty(page)) BUG();
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
-	page->mapping = NULL;
 }
 
 void remove_inode_page(struct page *page)


_________________________________________________________
Do You Yahoo!?
Get your free @yahoo.com address at http://mail.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
