Message-Id: <200405222212.i4MMCTr14304@mail.osdl.org>
Subject: [patch 46/57] rmap 30 fix bad mapcount
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:11:57 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

From: Andrea Arcangeli <andrea@suse.de>

page_alloc.c's bad_page routine should reset a bad mapcount; and it's more
revealing to show the bad mapcount than just the boolean mapped.


---

 25-akpm/mm/page_alloc.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/page_alloc.c~rmap-30-fix-bad-mapcount mm/page_alloc.c
--- 25/mm/page_alloc.c~rmap-30-fix-bad-mapcount	2004-05-22 14:56:28.832708288 -0700
+++ 25-akpm/mm/page_alloc.c	2004-05-22 14:56:28.836707680 -0700
@@ -73,9 +73,9 @@ static void bad_page(const char *functio
 {
 	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
 		function, current->comm, page);
-	printk(KERN_EMERG "flags:0x%08lx mapping:%p mapped:%d count:%d\n",
+	printk(KERN_EMERG "flags:0x%08lx mapping:%p mapcount:%d count:%d\n",
 		(unsigned long)page->flags, page->mapping,
-		page_mapped(page), page_count(page));
+		(int)page->mapcount, page_count(page));
 	printk(KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n");
@@ -90,6 +90,7 @@ static void bad_page(const char *functio
 			1 << PG_writeback);
 	set_page_count(page, 0);
 	page->mapping = NULL;
+	page->mapcount = 0;
 }
 
 #ifndef CONFIG_HUGETLB_PAGE

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
