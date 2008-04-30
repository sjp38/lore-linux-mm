Message-Id: <20080430044319.072339672@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:52 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [01/11] vmalloc: Return page array on vunmap
Content-Disposition: inline; filename=vcp_return_page_array_on_vunmap
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make vunmap return the page array that was used at vmap(). This is useful
if one has no structures to track the page array but simply stores the
virtual address returned by vmap somewhere. The caller may only need the
page array to dispose of it after vunmap().

vfree() can also now be used instead of vunmap(). vfree() will release the
page array after vunmap'ping it. If vfree() is called to free the page
array then the page array must either be

1. Allocated via the slab allocator

2. Allocated via vmalloc but then VM_VPAGES must have been passed at
   vunmap to specify that a vfree is needed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/vmalloc.h |    2 +-
 mm/vmalloc.c            |   28 ++++++++++++++++++----------
 2 files changed, 19 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h	2008-04-28 14:34:40.033649949 -0700
+++ linux-2.6/include/linux/vmalloc.h	2008-04-29 16:44:49.273706592 -0700
@@ -50,7 +50,7 @@ extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
-extern void vunmap(const void *addr);
+extern struct page **vunmap(const void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2008-04-28 14:34:40.623748915 -0700
+++ linux-2.6/mm/vmalloc.c	2008-04-29 16:44:49.273706592 -0700
@@ -372,17 +372,18 @@ struct vm_struct *remove_vm_area(const v
 	return v;
 }
 
-static void __vunmap(const void *addr, int deallocate_pages)
+static struct page **__vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
+	struct page **pages;
 
 	if (!addr)
-		return;
+		return NULL;
 
 	if ((PAGE_SIZE-1) & (unsigned long)addr) {
 		printk(KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
 		WARN_ON(1);
-		return;
+		return NULL;
 	}
 
 	area = remove_vm_area(addr);
@@ -390,29 +391,30 @@ static void __vunmap(const void *addr, i
 		printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
 		WARN_ON(1);
-		return;
+		return NULL;
 	}
 
+	pages = area->pages;
 	debug_check_no_locks_freed(addr, area->size);
 
 	if (deallocate_pages) {
 		int i;
 
 		for (i = 0; i < area->nr_pages; i++) {
-			struct page *page = area->pages[i];
+			struct page *page = pages[i];
 
 			BUG_ON(!page);
 			__free_page(page);
 		}
 
 		if (area->flags & VM_VPAGES)
-			vfree(area->pages);
+			vfree(pages);
 		else
-			kfree(area->pages);
+			kfree(pages);
 	}
 
 	kfree(area);
-	return;
+	return pages;
 }
 
 /**
@@ -441,10 +443,10 @@ EXPORT_SYMBOL(vfree);
  *
  *	Must not be called in interrupt context.
  */
-void vunmap(const void *addr)
+struct page **vunmap(const void *addr)
 {
 	BUG_ON(in_interrupt());
-	__vunmap(addr, 0);
+	return __vunmap(addr, 0);
 }
 EXPORT_SYMBOL(vunmap);
 
@@ -457,6 +459,11 @@ EXPORT_SYMBOL(vunmap);
  *
  *	Maps @count pages from @pages into contiguous kernel virtual
  *	space.
+ *
+ *	The page array may be freed using if the result of vmap is passed to
+ *	vfree().  In that case the page array must either have been allocated
+ *	using kmalloc or via vmalloc. For the vmalloc case VM_VPAGES must
+ *	be set in flags.
  */
 void *vmap(struct page **pages, unsigned int count,
 		unsigned long flags, pgprot_t prot)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
