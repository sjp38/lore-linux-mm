Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCYtMH074430
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:34:55 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCa0Gv123304
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:36:00 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCYtKw006033
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:34:55 +0200
Date: Mon, 24 Apr 2006 14:34:59 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 4/8] Page host virtual assist: mlocked pages.
Message-ID: <20060424123459.GE15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

[patch 4/8] Page host virtual assist: mlocked pages.

Add code to get mlock() working with page host virtual assist. The
problem with mlock is that locked pages may not be removed from page
cache. That means they need to be stable. page_hva_make_volatile needs
a way to check if a page has been locked. To avoid traversing vma
lists - which would hurt performance a lot - a field is added in the
struct address space. This bit is set in mlock_fixup if a vma gets
mlocked. The bit never gets removed - once a file had an mlocked vma
all future pages added to it will stay stable.

To complete the picture make_pages_present has to check for the host
page state besides making the pages present in the linux page table.
This is done by a call to get_user_pages with a pages parameter. Since
the VM_LOCKED bit of the vma will be set prior to the call to
get_user_pages an additional check is needed in the try_to_unmap_one
function. If get_user_pages finds a discarded page it needs to get
removed from the page cache and all page tables dispite the fact that
VM_LOCKED is set. After get_user_pages is back the pages are stable.
The references to the pages can be returned immediatly, the pages will
stay in stable because the mlocked bit is not set for the mapping.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/fs.h |    1 +
 mm/memory.c        |   25 +++++++++++++++++++++++++
 mm/mlock.c         |    2 ++
 mm/page_hva.c      |    5 ++++-
 mm/rmap.c          |    3 ++-
 5 files changed, 34 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/include/linux/fs.h linux-2.6-patched/include/linux/fs.h
--- linux-2.6/include/linux/fs.h	2006-04-24 12:51:20.000000000 +0200
+++ linux-2.6-patched/include/linux/fs.h	2006-04-24 12:51:28.000000000 +0200
@@ -394,6 +394,7 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+	unsigned int		mlocked;	/* set if VM_LOCKED vmas present */
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2006-04-24 12:51:28.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2006-04-24 12:51:28.000000000 +0200
@@ -2403,6 +2403,31 @@ int make_pages_present(unsigned long add
 	BUG_ON(addr >= end);
 	BUG_ON(end > vma->vm_end);
 	len = (end+PAGE_SIZE-1)/PAGE_SIZE-addr/PAGE_SIZE;
+
+	if (page_hva_enabled() && (vma->vm_flags & VM_LOCKED)) {
+		int rlen = len;
+		ret = 0;
+		while (rlen > 0) {
+			struct page *page_refs[32];
+			int chunk, cret, i;
+
+			chunk = rlen < 32 ? rlen : 32;
+			cret = get_user_pages(current, current->mm, addr,
+					      chunk, write, 0,
+					      page_refs, NULL);
+			if (cret > 0) {
+				for (i = 0; i < cret; i++)
+					page_cache_release(page_refs[i]);
+				ret += cret;
+			}
+			if (cret < chunk)
+				return ret ? : cret;
+			addr += 32*PAGE_SIZE;
+			rlen -= 32;
+		}
+		return ret == len ? 0 : -1;
+	}
+
 	ret = get_user_pages(current, current->mm, addr,
 			len, write, 0, NULL, NULL);
 	if (ret < 0)
diff -urpN linux-2.6/mm/mlock.c linux-2.6-patched/mm/mlock.c
--- linux-2.6/mm/mlock.c	2006-03-20 06:53:29.000000000 +0100
+++ linux-2.6-patched/mm/mlock.c	2006-04-24 12:51:28.000000000 +0200
@@ -60,6 +60,8 @@ success:
 	 */
 	pages = (end - start) >> PAGE_SHIFT;
 	if (newflags & VM_LOCKED) {
+		if (vma->vm_file && vma->vm_file->f_mapping)
+			vma->vm_file->f_mapping->mlocked = 1;
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
diff -urpN linux-2.6/mm/page_hva.c linux-2.6-patched/mm/page_hva.c
--- linux-2.6/mm/page_hva.c	2006-04-24 12:51:28.000000000 +0200
+++ linux-2.6-patched/mm/page_hva.c	2006-04-24 12:51:28.000000000 +0200
@@ -27,6 +27,8 @@
  */
 static inline int __page_hva_discardable(struct page *page,unsigned int offset)
 {
+	struct address_space *mapping;
+
 	/*
 	 * There are several conditions that prevent a page from becoming
 	 * volatile. The first check is for the page bits.
@@ -41,7 +43,8 @@ static inline int __page_hva_discardable
 	 * it volatile. It will be freed soon. If the mapping ever had
 	 * locked pages all pages of the mapping will stay stable.
 	 */
-	if (!page_mapping(page))
+	mapping = page_mapping(page);
+	if (!mapping || mapping->mlocked)
 		return 0;
 
 	/*
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2006-04-24 12:51:28.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2006-04-24 12:51:28.000000000 +0200
@@ -559,7 +559,8 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if ((vma->vm_flags & VM_LOCKED) ||
+	if (((vma->vm_flags & VM_LOCKED) &&
+	     !unlikely(page_hva_enabled() && PageDiscarded(page))) ||
 			(ptep_clear_flush_young(vma, address, pte)
 				&& !migration)) {
 		ret = SWAP_FAIL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
