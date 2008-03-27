Date: Wed, 26 Mar 2008 21:18:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: vmalloc: Return page array on vunmap
Message-ID: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 3 Oct 2007 20:42:42 -0700
Subject: vmalloc: Return page array on vunmap
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make vunmap return the page array that was used at vmap. This is useful
if one has no structures to track the page array but simply stores the
virtual address somewhere. The disposition of the page array can then
be decided upon by the caller after vunmap has torn down the mapping.

vfree() may now also be used instead of vunmap. vfree() will release the
page array after vunmap'ping it. If vfree() is called to free the page
array then the page array must either be

1. Allocated via the slab allocator

2. Allocated via vmalloc but then VM_VPAGES must have been passed at
   vunmap to specify that a vfree is needed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/vmalloc.h |    2 +-
 mm/vmalloc.c            |   29 +++++++++++++++++++----------
 2 files changed, 20 insertions(+), 11 deletions(-)

Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-26 21:17:29.536667641 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-26 21:17:30.746669304 -0700
@@ -50,7 +50,7 @@ extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
-extern void vunmap(const void *addr);
+extern struct page **vunmap(const void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-26 21:17:29.546668091 -0700
+++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-26 21:18:17.903682868 -0700
@@ -153,6 +153,7 @@ int map_vm_area(struct vm_struct *area, 
 	unsigned long addr = (unsigned long) area->addr;
 	unsigned long end = addr + area->size - PAGE_SIZE;
 	int err;
+	area->pages = *pages;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
@@ -163,6 +164,8 @@ int map_vm_area(struct vm_struct *area, 
 			break;
 	} while (pgd++, addr = next, addr != end);
 	flush_cache_vmap((unsigned long) area->addr, end);
+
+	area->nr_pages = *pages - area->pages;
 	return err;
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
@@ -372,17 +375,18 @@ struct vm_struct *remove_vm_area(const v
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
@@ -390,29 +394,30 @@ static void __vunmap(const void *addr, i
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
@@ -441,10 +446,10 @@ EXPORT_SYMBOL(vfree);
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
 
@@ -457,6 +462,10 @@ EXPORT_SYMBOL(vunmap);
  *
  *	Maps @count pages from @pages into contiguous kernel virtual
  *	space.
+ *
+ *	The page array may be freed using vfree(). In that case the page
+ *	array must be allocated via the slab allocator. If the page array
+ *	was allocated via vmalloc then VM_VPAGES must be set in flags.
  */
 void *vmap(struct page **pages, unsigned int count,
 		unsigned long flags, pgprot_t prot)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
