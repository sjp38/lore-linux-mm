Message-Id: <20071205071628.547577000@nick.local0.net>
References: <20071205071547.701344000@nick.local0.net>
Date: Wed, 05 Dec 2007 18:16:04 +1100
From: npiggin@suse.de
Subject: [patch 17/18] mm: remove nopage
Content-Disposition: inline; filename=mm-remove-nopage.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nothing in the tree uses nopage any more. Remove support for it in the
core mm code and documentation (and a few stray references to it in comments).

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 Documentation/feature-removal-schedule.txt |    9 --------
 Documentation/filesystems/Locking          |    3 --
 drivers/media/video/vino.c                 |    2 -
 drivers/video/vermilion/vermilion.c        |    5 ++--
 include/linux/mm.h                         |    8 -------
 mm/memory.c                                |   32 ++++++++++-------------------
 mm/mincore.c                               |    2 -
 mm/mmap.c                                  |   20 +++++++++---------
 mm/rmap.c                                  |    1 
 9 files changed, 27 insertions(+), 55 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -162,8 +162,6 @@ struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	struct page *(*nopage)(struct vm_area_struct *area,
-			unsigned long address, int *type);
 	unsigned long (*nopfn)(struct vm_area_struct *area,
 			unsigned long address);
 
@@ -611,12 +609,6 @@ static inline int page_mapped(struct pag
 }
 
 /*
- * Error return values for the *_nopage functions
- */
-#define NOPAGE_SIGBUS	(NULL)
-#define NOPAGE_OOM	((struct page *) (-1))
-
-/*
  * Error return values for the *_nopfn functions
  */
 #define NOPFN_SIGBUS	((unsigned long) -1)
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1044,8 +1044,7 @@ int get_user_pages(struct task_struct *t
 		if (pages)
 			foll_flags |= FOLL_GET;
 		if (!write && !(vma->vm_flags & VM_LOCKED) &&
-		    (!vma->vm_ops || (!vma->vm_ops->nopage &&
-					!vma->vm_ops->fault)))
+		    (!vma->vm_ops || !vma->vm_ops->fault))
 			foll_flags |= FOLL_ANON;
 
 		do {
@@ -2218,20 +2217,9 @@ static int __do_fault(struct mm_struct *
 
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
-	if (likely(vma->vm_ops->fault)) {
-		ret = vma->vm_ops->fault(vma, &vmf);
-		if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
-			return ret;
-	} else {
-		/* Legacy ->nopage path */
-		ret = 0;
-		vmf.page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
-		/* no page was available -- either SIGBUS or OOM */
-		if (unlikely(vmf.page == NOPAGE_SIGBUS))
-			return VM_FAULT_SIGBUS;
-		else if (unlikely(vmf.page == NOPAGE_OOM))
-			return VM_FAULT_OOM;
-	}
+	ret = vma->vm_ops->fault(vma, &vmf);
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+		return ret;
 
 	/*
 	 * For consistency in subsequent calls, make the faulted page always
@@ -2471,7 +2459,7 @@ static inline int handle_pte_fault(struc
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
-				if (vma->vm_ops->fault || vma->vm_ops->nopage)
+				if (likely(vma->vm_ops->fault))
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, write_access, entry);
 				if (unlikely(vma->vm_ops->nopfn))
Index: linux-2.6/mm/mincore.c
===================================================================
--- linux-2.6.orig/mm/mincore.c
+++ linux-2.6/mm/mincore.c
@@ -33,7 +33,7 @@ static unsigned char mincore_page(struct
 	 * When tmpfs swaps out a page from a file, any process mapping that
 	 * file will not get a swp_entry_t in its pte, but rather it is like
 	 * any other file mapping (ie. marked !present and faulted in with
-	 * tmpfs's .nopage). So swapped out tmpfs mappings are tested here.
+	 * tmpfs's .fault). So swapped out tmpfs mappings are tested here.
 	 *
 	 * However when tmpfs moves the page from pagecache and into swapcache,
 	 * it is still in core, but the find_get_page below won't find it.
Index: linux-2.6/Documentation/feature-removal-schedule.txt
===================================================================
--- linux-2.6.orig/Documentation/feature-removal-schedule.txt
+++ linux-2.6/Documentation/feature-removal-schedule.txt
@@ -172,15 +172,6 @@ Who:	Greg Kroah-Hartman <gregkh@suse.de>
 
 ---------------------------
 
-What:	vm_ops.nopage
-When:	Soon, provided in-kernel callers have been converted
-Why:	This interface is replaced by vm_ops.fault, but it has been around
-	forever, is used by a lot of drivers, and doesn't cost much to
-	maintain.
-Who:	Nick Piggin <npiggin@suse.de>
-
----------------------------
-
 What:	PHYSDEVPATH, PHYSDEVBUS, PHYSDEVDRIVER in the uevent environment
 When:	October 2008
 Why:	The stacking of class devices makes these values misleading and
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -514,7 +514,6 @@ prototypes:
 	void (*open)(struct vm_area_struct*);
 	void (*close)(struct vm_area_struct*);
 	int (*fault)(struct vm_area_struct*, struct vm_fault *);
-	struct page *(*nopage)(struct vm_area_struct*, unsigned long, int *);
 	int (*page_mkwrite)(struct vm_area_struct *, struct page *);
 
 locking rules:
@@ -522,7 +521,6 @@ locking rules:
 open:		no	yes
 close:		no	yes
 fault:		no	yes
-nopage:		no	yes
 page_mkwrite:	no	yes		no
 
 	->page_mkwrite() is called when a previously read-only page is
@@ -540,4 +538,3 @@ NULL.
 
 ipc/shm.c::shm_delete() - may need BKL.
 ->read() and ->write() in many drivers are (probably) missing BKL.
-drivers/sgi/char/graphics.c::sgi_graphics_nopage() - may need BKL.
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -623,7 +623,6 @@ void page_remove_rmap(struct page *page,
 			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
 			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
 			if (vma->vm_ops) {
-				print_symbol (KERN_EMERG "  vma->vm_ops->nopage = %s\n", (unsigned long)vma->vm_ops->nopage);
 				print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n", (unsigned long)vma->vm_ops->fault);
 			}
 			if (vma->vm_file && vma->vm_file->f_op)
Index: linux-2.6/drivers/media/video/vino.c
===================================================================
--- linux-2.6.orig/drivers/media/video/vino.c
+++ linux-2.6/drivers/media/video/vino.c
@@ -13,7 +13,7 @@
 /*
  * TODO:
  * - remove "mark pages reserved-hacks" from memory allocation code
- *   and implement nopage()
+ *   and implement fault()
  * - check decimation, calculating and reporting image size when
  *   using decimation
  * - implement read(), user mode buffers and overlay (?)
Index: linux-2.6/drivers/video/vermilion/vermilion.c
===================================================================
--- linux-2.6.orig/drivers/video/vermilion/vermilion.c
+++ linux-2.6/drivers/video/vermilion/vermilion.c
@@ -114,8 +114,9 @@ static int vmlfb_alloc_vram_area(struct 
 
 	/*
 	 * It seems like __get_free_pages only ups the usage count
-	 * of the first page. This doesn't work with nopage mapping, so
-	 * up the usage count once more.
+	 * of the first page. This doesn't work with fault mapping, so
+	 * up the usage count once more (XXX: should use split_page or
+	 * compound page).
 	 */
 
 	memset((void *)va->logical, 0x00, va->size);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
