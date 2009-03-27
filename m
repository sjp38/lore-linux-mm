Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBC8F6B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 10:53:55 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2RFAJv8253114
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 15:10:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2RFACXT4116720
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:12 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2RFACNB015245
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:10:12 +0100
Message-Id: <20090327151012.095486071@de.ibm.com>
References: <20090327150905.819861420@de.ibm.com>
Date: Fri, 27 Mar 2009 16:09:08 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/6] Guest page hinting: mlocked pages.
Content-Disposition: inline; filename=003-hva-mlock.diff
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org
Cc: frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj

Add code to get mlock() working with guest page hinting. The problem
with mlock is that locked pages may not be removed from page cache.
That means they need to be stable. page_make_volatile needs a way to
check if a page has been locked. To avoid traversing vma lists - which
would hurt performance a lot - a field is added in the struct
address_space. This field is set in mlock_fixup if a vma gets mlocked.
The bit never gets removed - once a file had an mlocked vma all future
pages added to it will stay stable.

The pages of an mlocked area are made present in the linux page table by
a call to make_pages_present which calls get_user_pages and follow_page.
The follow_page function is called for each page in the mlocked vma,
if the VM_LOCKED bit in the vma flags is set the page is made stable.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/fs.h |   10 ++++++++++
 mm/memory.c        |    5 +++--
 mm/mlock.c         |    4 ++++
 mm/page-states.c   |    5 ++++-
 mm/rmap.c          |   14 ++++++++++++--
 5 files changed, 33 insertions(+), 5 deletions(-)

Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -561,6 +561,9 @@ struct address_space {
 	unsigned long		flags;		/* error bits/gfp mask */
 	struct backing_dev_info *backing_dev_info; /* device readahead, etc */
 	spinlock_t		private_lock;	/* for use by the address_space */
+#ifdef CONFIG_PAGE_STATES
+	unsigned int		mlocked;	/* set if VM_LOCKED vmas present */
+#endif
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
 } __attribute__((aligned(sizeof(long))));
@@ -570,6 +573,13 @@ struct address_space {
 	 * of struct page's "mapping" pointer be used for PAGE_MAPPING_ANON.
 	 */
 
+static inline void mapping_set_mlocked(struct address_space *mapping)
+{
+#ifdef CONFIG_PAGE_STATES
+	mapping->mlocked = 1;
+#endif
+}
+
 struct block_device {
 	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
 	struct inode *		bd_inode;	/* will die */
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1177,9 +1177,10 @@ struct page *follow_page(struct vm_area_
 	if (flags & FOLL_GET)
 		get_page(page);
 
-	if (flags & FOLL_GET) {
+	if ((flags & FOLL_GET) || (vma->vm_flags & VM_LOCKED)) {
 		/*
-		 * The page is made stable if a reference is acquired.
+		 * The page is made stable if a reference is acquired or
+		 * the vm area is locked.
 		 * If the caller does not get a reference it implies that
 		 * the caller can deal with page faults in case the page
 		 * is swapped out. In this case the caller can deal with
Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c
+++ linux-2.6/mm/mlock.c
@@ -18,6 +18,7 @@
 #include <linux/rmap.h>
 #include <linux/mmzone.h>
 #include <linux/hugetlb.h>
+#include <linux/fs.h>
 
 #include "internal.h"
 
@@ -380,6 +381,9 @@ static int mlock_fixup(struct vm_area_st
 			(vma->vm_flags & (VM_IO | VM_PFNMAP)))
 		goto out;	/* don't set VM_LOCKED,  don't count */
 
+	if (lock && vma->vm_file && vma->vm_file->f_mapping)
+		mapping_set_mlocked(vma->vm_file->f_mapping);
+
 	if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
 			is_vm_hugetlb_page(vma) ||
 			vma == get_gate_vma(current)) {
Index: linux-2.6/mm/page-states.c
===================================================================
--- linux-2.6.orig/mm/page-states.c
+++ linux-2.6/mm/page-states.c
@@ -30,6 +30,8 @@
  */
 static inline int check_bits(struct page *page)
 {
+	struct address_space *mapping;
+
 	/*
 	 * There are several conditions that prevent a page from becoming
 	 * volatile. The first check is for the page bits.
@@ -53,7 +55,8 @@ static inline int check_bits(struct page
 	 * it volatile. It will be freed soon. And if the mapping ever
 	 * had locked pages all pages of the mapping will stay stable.
 	 */
-	return page_mapping(page) != NULL;
+	mapping = page_mapping(page);
+	return mapping && !mapping->mlocked;
 }
 
 /*
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -793,8 +793,18 @@ static int try_to_unmap_one(struct page 
 			goto out_unmap;
 		}
 		if (ptep_clear_flush_young_notify(vma, address, pte)) {
-			ret = SWAP_FAIL;
-			goto out_unmap;
+			/*
+			 * Check for discarded pages. This can happen if
+			 * there have been discarded pages before a vma
+			 * gets mlocked. The code in make_pages_present
+			 * will force all discarded pages out and reload
+			 * them. That happens after the VM_LOCKED bit
+			 * has been set.
+			 */
+			if (likely(!PageDiscarded(page))) {
+				ret = SWAP_FAIL;
+				goto out_unmap;
+			}
 		}
   	}
 

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
