Message-Id: <20081108022014.097728000@nick.local0.net>
References: <20081108021512.686515000@suse.de>
Date: Sat, 08 Nov 2008 13:15:18 +1100
From: npiggin@suse.de
Subject: [patch 6/9] mm: vmalloc guard fix
Content-Disposition: inline; filename=mm-vmalloc-guard-fix.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>

The vmap virtual address allocator always leaves a guard page; no need for
these hacks to add PAGE_SIZE to the vm_struct that we wanted to allocate in
order to get the guard page (this has been giving 2 guard pages)

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -966,7 +966,7 @@ void unmap_kernel_range(unsigned long ad
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long end = addr + area->size - PAGE_SIZE;
+	unsigned long end = addr + area->size;
 	int err;
 
 	err = vmap_page_range(addr, end, prot, *pages);
@@ -1012,11 +1012,6 @@ static struct vm_struct *__get_vm_area_n
 	if (unlikely(!area))
 		return NULL;
 
-	/*
-	 * We always allocate a guard page.
-	 */
-	size += PAGE_SIZE;
-
 	va = alloc_vmap_area(size, align, start, end, node, gfp_mask);
 	if (IS_ERR(va)) {
 		kfree(area);
@@ -1110,7 +1105,6 @@ struct vm_struct *remove_vm_area(const v
 		struct vm_struct *vm = va->private;
 		struct vm_struct *tmp, **p;
 		free_unmap_vmap_area(va);
-		vm->size -= PAGE_SIZE;
 
 		write_lock(&vmlist_lock);
 		for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
@@ -1238,7 +1232,7 @@ static void *__vmalloc_area_node(struct 
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 
-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
+	nr_pages = area->size >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -1463,7 +1457,7 @@ long vread(char *buf, char *addr, unsign
 	read_lock(&vmlist_lock);
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+		if (addr >= vaddr + tmp->size)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -1473,7 +1467,7 @@ long vread(char *buf, char *addr, unsign
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + tmp->size - addr;
 		do {
 			if (count == 0)
 				goto finished;
@@ -1501,7 +1495,7 @@ long vwrite(char *buf, char *addr, unsig
 	read_lock(&vmlist_lock);
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+		if (addr >= vaddr + tmp->size)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -1510,7 +1504,7 @@ long vwrite(char *buf, char *addr, unsig
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + tmp->size - addr;
 		do {
 			if (count == 0)
 				goto finished;
@@ -1556,7 +1550,7 @@ int remap_vmalloc_range(struct vm_area_s
 	if (!(area->flags & VM_USERMAP))
 		return -EINVAL;
 
-	if (usize + (pgoff << PAGE_SHIFT) > area->size - PAGE_SIZE)
+	if (usize + (pgoff << PAGE_SHIFT) > area->size)
 		return -EINVAL;
 
 	addr += pgoff << PAGE_SHIFT;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
