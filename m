Message-Id: <20071004040002.172507452@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:37 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [02/18] vunmap: return page array passed on vmap()
Content-Disposition: inline; filename=vcompound_vunmap_returns_pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Make vunmap return the page array that was used at vmap. This is useful
if one has no structures to track the page array but simply stores the
virtual address somewhere. The disposition of the page array can be
decided upon after vunmap. vfree() may now also be used instead of
vunmap which will release the page array after vunmap'ping it.

As noted by Kamezawa: The same subsystem that provides the page array
to vmap must must use its own method to dispose of the page array.

If vfree() is called to free the page array then the page array must either
be

1. Allocated via the slab allocator

2. Allocated via vmalloc but then VM_VPAGES must have been passed at
   vunmap to specify that a vfree is needed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmalloc.h |    2 +-
 mm/vmalloc.c            |   32 ++++++++++++++++++++++----------
 2 files changed, 23 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h	2007-10-03 16:19:29.000000000 -0700
+++ linux-2.6/include/linux/vmalloc.h	2007-10-03 16:19:41.000000000 -0700
@@ -49,7 +49,7 @@ extern void vfree(void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
-extern void vunmap(void *addr);
+extern struct page **vunmap(void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2007-10-03 16:19:35.000000000 -0700
+++ linux-2.6/mm/vmalloc.c	2007-10-03 16:20:15.000000000 -0700
@@ -152,6 +152,7 @@ int map_vm_area(struct vm_struct *area, 
 	unsigned long addr = (unsigned long) area->addr;
 	unsigned long end = addr + area->size - PAGE_SIZE;
 	int err;
+	area->pages = *pages;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
@@ -162,6 +163,8 @@ int map_vm_area(struct vm_struct *area, 
 			break;
 	} while (pgd++, addr = next, addr != end);
 	flush_cache_vmap((unsigned long) area->addr, end);
+
+	area->nr_pages = *pages - area->pages;
 	return err;
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
@@ -318,17 +321,18 @@ struct vm_struct *remove_vm_area(void *a
 	return v;
 }
 
-static void __vunmap(void *addr, int deallocate_pages)
+static struct page **__vunmap(void *addr, int deallocate_pages)
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
@@ -336,29 +340,30 @@ static void __vunmap(void *addr, int dea
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
@@ -387,10 +392,10 @@ EXPORT_SYMBOL(vfree);
  *
  *	Must not be called in interrupt context.
  */
-void vunmap(void *addr)
+struct page **vunmap(void *addr)
 {
 	BUG_ON(in_interrupt());
-	__vunmap(addr, 0);
+	return __vunmap(addr, 0);
 }
 EXPORT_SYMBOL(vunmap);
 
@@ -403,6 +408,13 @@ EXPORT_SYMBOL(vunmap);
  *
  *	Maps @count pages from @pages into contiguous kernel virtual
  *	space.
+ *
+ *	The page array may be freed via vfree() on the virtual address
+ *	returned. In that case the page array must be allocated via
+ *	the slab allocator. If the page array was allocated via
+ *	vmalloc then VM_VPAGES must be specified in the flags. There is
+ *	no support for vfree() to free a page array allocated via the
+ *	page allocator.
  */
 void *vmap(struct page **pages, unsigned int count,
 		unsigned long flags, pgprot_t prot)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
