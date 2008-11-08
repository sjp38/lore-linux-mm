Message-Id: <20081108022014.460279000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:21 +1100
From: npiggin@suse.de
Subject: [patch 9/9] mm: vmalloc make lazy unmapping configurable
Content-Disposition: inline; filename=mm-vmalloc-nolazy-debug.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

Lazy unmapping in the vmalloc code has now opened the possibility for use
after free bugs to go undetected. We can catch those by forcing an unmap
and flush (which is going to be slow, but that's what happens).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -444,6 +444,27 @@ static void unmap_vmap_area(struct vmap_
 	vunmap_page_range(va->va_start, va->va_end);
 }
 
+static void vmap_debug_free_range(unsigned long start, unsigned long end)
+{
+	/*
+	 * Unmap page tables and force a TLB flush immediately if
+	 * CONFIG_DEBUG_PAGEALLOC is set. This catches use after free
+	 * bugs similarly to those in linear kernel virtual address
+	 * space after a page has been freed.
+	 *
+	 * All the lazy freeing logic is still retained, in order to
+	 * minimise intrusiveness of this debugging feature.
+	 *
+	 * This is going to be *slow* (linear kernel virtual address
+	 * debugging doesn't do a broadcast TLB flush so it is a lot
+	 * faster).
+	 */
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	vunmap_page_range(start, end);
+	flush_tlb_kernel_range(start, end);
+#endif
+}
+
 /*
  * lazy_max_pages is the maximum amount of virtual address space we gather up
  * before attempting to purge with a TLB flush.
@@ -906,6 +927,7 @@ void vm_unmap_ram(const void *mem, unsig
 	BUG_ON(addr & (PAGE_SIZE-1));
 
 	debug_check_no_locks_freed(mem, size);
+	vmap_debug_free_range(addr, addr+size);
 
 	if (likely(count <= VMAP_MAX_ALLOC))
 		vb_free(mem, size);
@@ -1115,6 +1137,8 @@ struct vm_struct *remove_vm_area(const v
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->private;
 		struct vm_struct *tmp, **p;
+
+		vmap_debug_free_range(va->va_start, va->va_end);
 		free_unmap_vmap_area(va);
 
 		write_lock(&vmlist_lock);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
