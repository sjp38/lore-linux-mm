From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070113011546.9479.34967.sendpatchset@linux.site>
In-Reply-To: <20070113011526.9479.79596.sendpatchset@linux.site>
References: <20070113011526.9479.79596.sendpatchset@linux.site>
Subject: [patch 2/7] mm: simplify filemap_nopage
Date: Sat, 13 Jan 2007 04:28:01 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Dave Airlie <airlied@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, thomas@tungstengraphics.com
List-ID: <linux-mm.kvack.org>

Identical block is duplicated twice: contrary to the comment, we have been
re-reading the page *twice* in filemap_nopage rather than once.

If any retry logic or anything is needed, it belongs in lower levels anyway.
Only retry once. Linus agrees.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1468,30 +1468,6 @@ page_not_uptodate:
 		majmin = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
-	lock_page(page);
-
-	/* Did it get unhashed while we waited for it? */
-	if (!page->mapping) {
-		unlock_page(page);
-		page_cache_release(page);
-		goto retry_all;
-	}
-
-	/* Did somebody else get it up-to-date? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
-
-	error = mapping->a_ops->readpage(file, page);
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
-		goto retry_find;
-	}
 
 	/*
 	 * Umm, take care of errors if the page isn't up-to-date.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
