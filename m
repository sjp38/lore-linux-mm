Message-Id: <20070925233007.302199268@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:51 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 08/14] vunmap: return page array passed on vmap()
Content-Disposition: inline; filename=vcompound_vunmap_returns_pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make vunmap return the page array that was used at vmap. This is useful
if one has no structures to track the page array but simply stores the
virtual address somewhere. The disposition of the page array can be
decided upon after vunmap. vfree() may now also be used instead of
vunmap which will release the page array after vunmap'ping it.

As noted by Kamezawa: The same subsystem that provides the page array
to vmap must must use its own method to dispose of the page array.

If vfree() is called to free the page array passed to vmap() [We currently
do not do that] then the page array must either be

1. Allocated via the slab allocator

2. Allocated via vmalloc but then VM_VPAGES must have been passed at
   vunmap to specify that a vfree is needed.

RFC->v1:
- Add comment explaining how to use vfree() to dispose of the page
  array passed on vmap().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmalloc.h |    2 +-
 mm/vmalloc.c            |   33 +++++++++++++++++++++++----------
 2 files changed, 24 insertions(+), 11 deletions(-)

Index: linux-2.6.23-rc8-mm1/include/linux/vmalloc.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/vmalloc.h	2007-09-25 15:02:59.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/vmalloc.h	2007-09-25 15:03:06.000000000 -0700
@@ -49,7 +49,7 @@ extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
-extern void vunmap(const void *addr);
+extern struct page **vunmap(const void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
Index: linux-2.6.23-rc8-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/vmalloc.c	2007-09-25 15:03:05.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/vmalloc.c	2007-09-25 15:03:06.000000000 -0700
@@ -357,17 +357,18 @@ struct vm_struct *remove_vm_area(const v
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
@@ -375,29 +376,30 @@ static void __vunmap(const void *addr, i
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
@@ -425,11 +427,13 @@ EXPORT_SYMBOL(vfree);
  *	which was created from the page array passed to vmap().
  *
  *	Must not be called in interrupt context.
+ *
+ *	Returns a pointer to the array of pointers to page structs
  */
-void vunmap(const void *addr)
+struct page **vunmap(const void *addr)
 {
 	BUG_ON(in_interrupt());
-	__vunmap(addr, 0);
+	return __vunmap(addr, 0);
 }
 EXPORT_SYMBOL(vunmap);
 
@@ -442,6 +446,13 @@ EXPORT_SYMBOL(vunmap);
  *
  *	Maps @count pages from @pages into contiguous kernel virtual
  *	space.
+ *
+ *	The page array may be freed via vfree() with the virtual address
+ *	returned from vmap. In that case the page array must be allocated via
+ *	the slab allocator. If the page array was allocated via
+ *	vmalloc then VM_VPAGES must be specified in the flags. There is
+ *	no support for vfree() freeing pages allocated via the
+ *	page allocator.
  */
 void *vmap(struct page **pages, unsigned int count,
 		unsigned long flags, pgprot_t prot)
@@ -454,6 +465,8 @@ void *vmap(struct page **pages, unsigned
 	area = get_vm_area((count << PAGE_SHIFT), flags);
 	if (!area)
 		return NULL;
+	area->pages = pages;
+	area->nr_pages = count;
 	if (map_vm_area(area, prot, &pages)) {
 		vunmap(area->addr);
 		return NULL;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
