Received: from d12relay01.megacenter.de.ibm.com (d12relay01.megacenter.de.ibm.com [9.149.165.180])
	by mtagate7.de.ibm.com (8.12.10/8.12.10) with ESMTP id i32EHJv4028810
	for <linux-mm@kvack.org>; Fri, 2 Apr 2004 14:17:22 GMT
Received: from mschwid3.boeblingen.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12relay01.megacenter.de.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i32EHHaA187088
	for <linux-mm@kvack.org>; Fri, 2 Apr 2004 16:17:18 +0200
Received: from sky by mschwid3.boeblingen.de.ibm.com with local (Exim 3.36 #1 (Debian))
	id 1B9PTq-0000Uv-00
	for <linux-mm@kvack.org>; Fri, 02 Apr 2004 16:17:10 +0200
Date: Fri, 2 Apr 2004 16:17:10 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] get_user_pages shortcut for anonymous pages.
Message-ID: <20040402141710.GA1903@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
did anybody else stumble over the bigcore test case in gdb on a 64
bit architecture? For s390-64 and no ulimit the bigcore test in
fact crashes the kernel. The system is still pingable but it doesn't
do anything because every single pages is used for page tables. The
bigcore process is not terminated because the system thinks that
there is enough swap space left to free some pages to continue.
But this isn't true because its all page tables. I can't solve the
real problem (too many page table pages) but I have a patch that
helps with the bigcore test. The reason why bigcore creates a lot
of pages tables is that the elf core dumper uses get_user_pages to
get the pages frames for all vmas of the process. get_user_pages
does a lookup for each page with follow_page and if the page
doesn't exist uses handle_mm_fault to force the page in if possible. 
It's handle_mm_fault that allocates the page middle directories and
the page tables. To prevent that I added a check to get_user_pages
to find out if the vma in question is for an anonymous mapping and
if the caller of get_user_pages only wants to read from the pages.
If this is the case (and follow_page returned NULL) just return
ZERO_PAGE without going over handle_mm_fault.
I tested this on a 256MB machine and bigcore successfully created
a 2TB sparse file that gdb could read. Is this something that is
worth to pursue or I am just wasting my time ?

blues skies,
  Martin.

diff -urN linux-2.6/mm/memory.c linux-2.6-bigcore/mm/memory.c
--- linux-2.6/mm/memory.c	Fri Apr  2 11:05:27 2004
+++ linux-2.6-bigcore/mm/memory.c	Fri Apr  2 11:08:08 2004
@@ -750,6 +750,18 @@
 			struct page *map;
 			int lookup_write = write;
 			while (!(map = follow_page(mm, start, lookup_write))) {
+				/*
+				 * Shortcut for anonymous pages. We don't want
+				 * to force the creation of pages tables for
+				 * insanly big anonymously mapped areas that
+				 * nobody touched so far. This is important
+				 * for doing a core dump for these mappings.
+				 */
+				if (!lookup_write && 
+				    (!vma->vm_ops || !vma->vm_ops->nopage)) {
+					map = ZERO_PAGE(start);
+					break;
+				}
 				spin_unlock(&mm->page_table_lock);
 				switch (handle_mm_fault(mm,vma,start,write)) {
 				case VM_FAULT_MINOR:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
