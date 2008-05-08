Subject: [patch] mm: fix infinite loop in filemap_fault
Message-Id: <E1JuBeb-0008Hr-0q@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 08 May 2008 21:19:45 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think this is a pretty obvious fix.  The only thing I don't
understand, is how did this manage to go unnoticed for almost a year.
Are persistent read errors *that* rare?


----
From: Miklos Szeredi <mszeredi@suse.cz>

filemap_fault will go into an infinite loop if ->readpage() fails
asynchronously.

AFAICS the bug was introduced by this commit, which removed the wait
after the final readpage:

   commit d00806b183152af6d24f46f0c33f14162ca1262a
   Author: Nick Piggin <npiggin@suse.de>
   Date:   Thu Jul 19 01:46:57 2007 -0700

       mm: fix fault vs invalidate race for linear mappings

Fix by reintroducing the wait_on_page_locked() after ->readpage() to
make sure the page is up-to-date before jumping back to the beginning
of the function.

I've noticed this while testing nfs exporting on fuse.  The patch
fixes it.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
CC: Nick Piggin <npiggin@suse.de>
---
 mm/filemap.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux.git/mm/filemap.c
===================================================================
--- linux.git.orig/mm/filemap.c	2008-05-08 08:17:22.000000000 +0200
+++ linux.git/mm/filemap.c	2008-05-08 11:55:42.000000000 +0200
@@ -1461,6 +1461,11 @@ page_not_uptodate:
 	 */
 	ClearPageError(page);
 	error = mapping->a_ops->readpage(file, page);
+	if (!error) {
+		wait_on_page_locked(page);
+		if (!PageUptodate(page))
+			error = -EIO;
+	}
 	page_cache_release(page);
 
 	if (!error || error == AOP_TRUNCATED_PAGE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
