Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l5SGfC9V243054
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 16:41:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5SGfCEu2085080
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5SGfCJq016566
	for <linux-mm@kvack.org>; Thu, 28 Jun 2007 18:41:12 +0200
Message-Id: <20070628164312.904067656@de.ibm.com>
References: <20070628164049.118610355@de.ibm.com>
Date: Thu, 28 Jun 2007 18:40:52 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/6] Guest page hinting: mlocked pages.
Content-Disposition: inline; filename=003-hva-mlock.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
From: Hubertus Franke <frankeh@watson.ibm.com>
From: Himanshu Raj <rhim@cc.gatech.edu>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

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
 mm/mlock.c         |    2 ++
 mm/page-states.c   |    5 ++++-
 mm/rmap.c          |   13 +++++++++++--
 5 files changed, 30 insertions(+), 5 deletions(-)

diff -urpN linux-2.6/include/linux/fs.h linux-2.6-patched/include/linux/fs.h
--- linux-2.6/include/linux/fs.h	2007-06-25 09:18:27.000000000 +0200
+++ linux-2.6-patched/include/linux/fs.h	2007-06-28 18:19:45.000000000 +0200
@@ -450,6 +450,9 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	struct address_space	*assoc_mapping;	/* ditto */
+#ifdef CONFIG_PAGE_STATES
+	unsigned int		mlocked;	/* set if VM_LOCKED vmas present */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -457,6 +460,13 @@ struct address_space {
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
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2007-06-28 18:19:45.000000000 +0200
@@ -981,9 +981,10 @@ struct page *follow_page(struct vm_area_
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
diff -urpN linux-2.6/mm/mlock.c linux-2.6-patched/mm/mlock.c
--- linux-2.6/mm/mlock.c	2007-05-22 09:49:49.000000000 +0200
+++ linux-2.6-patched/mm/mlock.c	2007-06-28 18:19:45.000000000 +0200
@@ -71,6 +71,8 @@ success:
 	 */
 	pages = (end - start) >> PAGE_SHIFT;
 	if (newflags & VM_LOCKED) {
+		if (vma->vm_file && vma->vm_file->f_mapping)
+			mapping_set_mlocked(vma->vm_file->f_mapping);
 		pages = -pages;
 		if (!(newflags & VM_IO))
 			ret = make_pages_present(start, end);
diff -urpN linux-2.6/mm/page-states.c linux-2.6-patched/mm/page-states.c
--- linux-2.6/mm/page-states.c	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/mm/page-states.c	2007-06-28 18:19:45.000000000 +0200
@@ -29,6 +29,8 @@
  */
 static inline int check_bits(struct page *page)
 {
+	struct address_space *mapping;
+
 	/*
 	 * There are several conditions that prevent a page from becoming
 	 * volatile. The first check is for the page bits.
@@ -44,7 +46,8 @@ static inline int check_bits(struct page
 	 * it volatile. It will be freed soon. And if the mapping ever
 	 * had locked pages all pages of the mapping will stay stable.
 	 */
-	return page_mapping(page) != NULL;
+	mapping = page_mapping(page);
+	return mapping && !mapping->mlocked;
 }
 
 /*
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2007-06-28 18:19:45.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2007-06-28 18:19:45.000000000 +0200
@@ -706,8 +706,17 @@ static int try_to_unmap_one(struct page 
 	 */
 	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
 			(ptep_clear_flush_young(vma, address, pte)))) {
-		ret = SWAP_FAIL;
-		goto out_unmap;
+		/*
+		 * Check for discarded pages. This can happen if there have
+		 * been discarded pages before a vma gets mlocked. The code
+		 * in make_pages_present will force all discarded pages out
+		 * and reload them. That happens after the VM_LOCKED bit
+		 * has been set.
+		 */
+		if (likely(!PageDiscarded(page))) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
 	}
 
 	/* Nuke the page table entry. */

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
