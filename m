Date: Mon, 5 Aug 2002 20:11:32 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] vmap_pages() (4th resend)
Message-ID: <20020805201132.A26943@lst.de>
References: <20020729214638.A4582@lst.de> <Pine.LNX.4.33.0207291355550.1470-100000@penguin.transmeta.com> <20020805184257.A19020@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020805184257.A19020@infradead.org>; from hch@infradead.org on Mon, Aug 05, 2002 at 06:42:57PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Hmm? Is that such a big deal? I think it's worth it for cleanliness, and
> > kmalloc() should be plenty big enough (a standard 4kB kmalloc on x86 can
> > cover 4MB worth of vmalloc() space, and anybody who wants to vmalloc more
> > than than that had better have some good reason for it - and kmalloc() 
> > does actually work for much larger areas too).
> > 
> > So the kmalloc() approach sounds pretty trivial to me.

Okay, here is the patch.  vmalloc.c is changed from ground up, *vmalloc*
and vfree stay, in addition we have vmap/vunmap for the mapping I want
to add.  Note that the patch adds excessive comments, so it looks like
adding much more then it removes.


You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.458, 2002-08-05 21:05:30+02:00, hch@sb.bsdonline.org
  VM: Rework vmalloc code to support mapping of arbitray pages
  
  The vmalloc operation is split into two pieces:  allocate the backing
  pages and map them into the kernel page tabels for virtually contingous
  access. (Same for vfree).  A new set of interfaces, vmap & vunmap does
  only the second part and thus allows mapping arbitray pages into 
  kernel virtual memory.
  
  The vmalloc.c internals have been completly overhauled to support this,
  but the exported interfaces are unchanged.


 arch/i386/mm/ioremap.c    |    6 
 arch/sparc64/mm/modutil.c |   55 ++++++
 drivers/char/mem.c        |    5 
 include/linux/vmalloc.h   |   57 +++----
 kernel/ksyms.c            |    2 
 mm/vmalloc.c              |  364 +++++++++++++++++++++++++++++++---------------
 6 files changed, 335 insertions, 154 deletions


diff -Nru a/arch/i386/mm/ioremap.c b/arch/i386/mm/ioremap.c
--- a/arch/i386/mm/ioremap.c	Mon Aug  5 21:06:30 2002
+++ b/arch/i386/mm/ioremap.c	Mon Aug  5 21:06:30 2002
@@ -159,7 +159,7 @@
 	area->phys_addr = phys_addr;
 	addr = area->addr;
 	if (remap_area_pages(VMALLOC_VMADDR(addr), phys_addr, size, flags)) {
-		vfree(addr);
+		vunmap(addr);
 		return NULL;
 	}
 	return (void *) (offset + (char *)addr);
@@ -215,13 +215,13 @@
 	struct vm_struct *p;
 	if (addr <= high_memory) 
 		return; 
-	p = remove_kernel_area((void *) (PAGE_MASK & (unsigned long) addr));
+	p = remove_vm_area((void *) (PAGE_MASK & (unsigned long) addr));
 	if (!p) { 
 		printk("__iounmap: bad address %p\n", addr);
 		return;
 	} 
 
-	vmfree_area_pages(VMALLOC_VMADDR(p->addr), p->size);	
+	unmap_vm_area(p);
 	if (p->flags && p->phys_addr < virt_to_phys(high_memory)) { 
 		change_page_attr(virt_to_page(__va(p->phys_addr)),
 				 p->size >> PAGE_SHIFT,
diff -Nru a/arch/sparc64/mm/modutil.c b/arch/sparc64/mm/modutil.c
--- a/arch/sparc64/mm/modutil.c	Mon Aug  5 21:06:30 2002
+++ b/arch/sparc64/mm/modutil.c	Mon Aug  5 21:06:30 2002
@@ -4,6 +4,8 @@
  *  Copyright (C) 1997,1998 Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  *  Based upon code written by Linus Torvalds and others.
  */
+
+#warning "major untested changes to this file  --hch (2002/08/05)"
  
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
@@ -16,6 +18,7 @@
 void module_unmap (void * addr)
 {
 	struct vm_struct **p, *tmp;
+	int i;
 
 	if (!addr)
 		return;
@@ -23,21 +26,38 @@
 		printk("Trying to unmap module with bad address (%p)\n", addr);
 		return;
 	}
+
 	for (p = &modvmlist ; (tmp = *p) ; p = &tmp->next) {
 		if (tmp->addr == addr) {
 			*p = tmp->next;
-			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
-			kfree(tmp);
-			return;
 		}
 	}
 	printk("Trying to unmap nonexistent module vm area (%p)\n", addr);
+	return;
+
+found:
+
+	unmap_vm_area(tmp);
+	
+	for (i = 0; i < tmp->nr_pages; i++) {
+		if (unlikely(!tmp->pages[i]))
+			BUG();
+		__free_page(tmp->pages[i]);
+	}
+
+	kfree(tmp->pages);
+	kfree(tmp);
 }
 
+
 void * module_map (unsigned long size)
 {
-	void * addr;
 	struct vm_struct **p, *tmp, *area;
+	struct vm_struct *area;
+	struct page **pages;
+	void * addr;
+	unsigned int nr_pages, array_size, i;
+
 
 	size = PAGE_ALIGN(size);
 	if (!size || size > MODULES_LEN) return NULL;
@@ -55,11 +75,32 @@
 	area->size = size + PAGE_SIZE;
 	area->addr = addr;
 	area->next = *p;
+	area->pages = NULL;
+	area->nr_pages = 0;
+	area->phys_addr = 0;
 	*p = area;
 
-	if (vmalloc_area_pages(VMALLOC_VMADDR(addr), size, GFP_KERNEL, PAGE_KERNEL)) {
-		module_unmap(addr);
+	nr_pages = (size+PAGE_SIZE) >> PAGE_SHIFT;
+	array_size = (nr_pages * sizeof(struct page *));
+
+	area->nr_pages = nr_pages;
+	area->pages = pages = kmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM));
+	if (!area->pages)
 		return NULL;
+	memset(area->pages, 0, array_size);
+
+	for (i = 0; i < area->nr_pages; i++) {
+		area->pages[i] = alloc_page(gfp_mask);
+		if (unlikely(!area->pages[i]))
+			goto fail;
 	}
-	return addr;
+	
+	if (map_vm_area(area, prot, &pages))
+		goto fail;
+	return area->addr;
+
+fail:
+	vfree(area->addr);
+	return NULL;
+}
 }
diff -Nru a/drivers/char/mem.c b/drivers/char/mem.c
--- a/drivers/char/mem.c	Mon Aug  5 21:06:30 2002
+++ b/drivers/char/mem.c	Mon Aug  5 21:06:30 2002
@@ -210,6 +210,9 @@
 	return 0;
 }
 
+extern long vread(char *buf, char *addr, unsigned long count);
+extern long vwrite(char *buf, char *addr, unsigned long count);
+
 /*
  * This function reads the *virtual* memory as seen by the kernel.
  */
@@ -272,8 +275,6 @@
  	*ppos = p;
  	return virtr + read;
 }
-
-extern long vwrite(char *buf, char *addr, unsigned long count);
 
 /*
  * This function writes to the *virtual* memory as seen by the kernel.
diff -Nru a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h	Mon Aug  5 21:06:30 2002
+++ b/include/linux/vmalloc.h	Mon Aug  5 21:06:30 2002
@@ -1,44 +1,47 @@
-#ifndef __LINUX_VMALLOC_H
-#define __LINUX_VMALLOC_H
+#ifndef _LINUX_VMALLOC_H
+#define _LINUX_VMALLOC_H
 
 #include <linux/spinlock.h>
 
-#include <asm/pgtable.h>
-
 /* bits in vm_struct->flags */
 #define VM_IOREMAP	0x00000001	/* ioremap() and friends */
 #define VM_ALLOC	0x00000002	/* vmalloc() */
+#define VM_MAP		0x00000004	/* vmap()ed pages */
 
 struct vm_struct {
-	unsigned long flags;
-	void * addr;
-	unsigned long size;
-	unsigned long phys_addr;
-	struct vm_struct * next;
+	void			*addr;
+	unsigned long		size;
+	unsigned long		flags;
+	struct page		**pages;
+	unsigned int		nr_pages;
+	unsigned long		phys_addr;
+	struct vm_struct	*next;
 };
 
-extern struct vm_struct * get_vm_area (unsigned long size, unsigned long flags);
-extern void vfree(void * addr);
-extern void * __vmalloc (unsigned long size, int gfp_mask, pgprot_t prot);
-extern long vread(char *buf, char *addr, unsigned long count);
-extern void vmfree_area_pages(unsigned long address, unsigned long size);
-extern int vmalloc_area_pages(unsigned long address, unsigned long size,
-                              int gfp_mask, pgprot_t prot);
-extern struct vm_struct *remove_kernel_area(void *addr);
-
 /*
- * Various ways to allocate pages.
+ *	Highlevel APIs for driver use
  */
-
-extern void * vmalloc(unsigned long size);
-extern void * vmalloc_32(unsigned long size);
+extern void *vmalloc(unsigned long size);
+extern void *vmalloc_32(unsigned long size);
+extern void *__vmalloc(unsigned long size, int gfp_mask, pgprot_t prot);
+extern void vfree(void *addr);
+
+extern void *vmap(struct page **pages, unsigned int count);
+extern void vunmap(void *addr);
+ 
+/*
+ *	Lowlevel-APIs (not for driver use!)
+ */
+extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
+extern struct vm_struct *remove_vm_area(void *addr);
+extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
+			struct page ***pages);
+extern void unmap_vm_area(struct vm_struct *area);
 
 /*
- * vmlist_lock is a read-write spinlock that protects vmlist
- * Used in mm/vmalloc.c (get_vm_area() and vfree()) and fs/proc/kcore.c.
+ *	Internals.  Dont't use..
  */
 extern rwlock_t vmlist_lock;
+extern struct vm_struct *vmlist;
 
-extern struct vm_struct * vmlist;
-#endif
-
+#endif /* _LINUX_VMALLOC_H */
diff -Nru a/kernel/ksyms.c b/kernel/ksyms.c
--- a/kernel/ksyms.c	Mon Aug  5 21:06:30 2002
+++ b/kernel/ksyms.c	Mon Aug  5 21:06:30 2002
@@ -109,6 +109,8 @@
 EXPORT_SYMBOL(__vmalloc);
 EXPORT_SYMBOL(vmalloc);
 EXPORT_SYMBOL(vmalloc_32);
+EXPORT_SYMBOL(vmap);
+EXPORT_SYMBOL(vunmap);
 EXPORT_SYMBOL(vmalloc_to_page);
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(remap_page_range);
diff -Nru a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c	Mon Aug  5 21:06:30 2002
+++ b/mm/vmalloc.c	Mon Aug  5 21:06:30 2002
@@ -4,27 +4,28 @@
  *  Copyright (C) 1993  Linus Torvalds
  *  Support of BIGMEM added by Gerhard Wichert, Siemens AG, July 1999
  *  SMP-safe vmalloc/vfree/ioremap, Tigran Aivazian <tigran@veritas.com>, May 2000
+ *  Major rework to support vmap/vunmap, Christoph Hellwig, SGI, August 2002
  */
 
-#include <linux/config.h>
-#include <linux/slab.h>
-#include <linux/vmalloc.h>
-#include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
-#include <linux/smp_lock.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
+
 rwlock_t vmlist_lock = RW_LOCK_UNLOCKED;
-struct vm_struct * vmlist;
+struct vm_struct *vmlist;
 
-static inline void free_area_pte(pmd_t * pmd, unsigned long address, unsigned long size)
+static inline void unmap_area_pte(pmd_t *pmd, unsigned long address,
+				  unsigned long size)
 {
-	pte_t * pte;
 	unsigned long end;
+	pte_t *pte;
 
 	if (pmd_none(*pmd))
 		return;
@@ -33,11 +34,13 @@
 		pmd_clear(pmd);
 		return;
 	}
+
 	pte = pte_offset_kernel(pmd, address);
 	address &= ~PMD_MASK;
 	end = address + size;
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
+
 	do {
 		pte_t page;
 		page = ptep_get_and_clear(pte);
@@ -45,24 +48,17 @@
 		pte++;
 		if (pte_none(page))
 			continue;
-		if (pte_present(page)) {
-			struct page *ptpage;
-			unsigned long pfn = pte_pfn(page);
-			if (!pfn_valid(pfn))
-				continue;
-			ptpage = pfn_to_page(pfn);
-			if (!PageReserved(ptpage))
-				__free_page(ptpage);
+		if (pte_present(page))
 			continue;
-		}
 		printk(KERN_CRIT "Whee.. Swapped out page in kernel page table\n");
 	} while (address < end);
 }
 
-static inline void free_area_pmd(pgd_t * dir, unsigned long address, unsigned long size)
+static inline void unmap_area_pmd(pgd_t *dir, unsigned long address,
+				  unsigned long size)
 {
-	pmd_t * pmd;
 	unsigned long end;
+	pmd_t *pmd;
 
 	if (pgd_none(*dir))
 		return;
@@ -71,36 +67,23 @@
 		pgd_clear(dir);
 		return;
 	}
+
 	pmd = pmd_offset(dir, address);
 	address &= ~PGDIR_MASK;
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
+
 	do {
-		free_area_pte(pmd, address, end - address);
+		unmap_area_pte(pmd, address, end - address);
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
 }
 
-void vmfree_area_pages(unsigned long start, unsigned long size)
-{
-	pgd_t * dir;
-	unsigned long address = start;
-	unsigned long end = start + size;
-
-	dir = pgd_offset_k(address);
-	flush_cache_all();
-	do {
-		free_area_pmd(dir, address, end - address);
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		dir++;
-	} while (address && (address < end));
-	flush_tlb_kernel_range(start, end);
-}
-
-static inline int alloc_area_pte (pte_t * pte, unsigned long address,
-			unsigned long size, int gfp_mask, pgprot_t prot)
+static inline int map_area_pte(pte_t *pte, unsigned long address,
+			       unsigned long size, pgprot_t prot,
+			       struct page ***pages)
 {
 	unsigned long end;
 
@@ -108,23 +91,26 @@
 	end = address + size;
 	if (end > PMD_SIZE)
 		end = PMD_SIZE;
+
 	do {
-		struct page * page;
-		spin_unlock(&init_mm.page_table_lock);
-		page = alloc_page(gfp_mask);
-		spin_lock(&init_mm.page_table_lock);
+		struct page *page = **pages;
+
 		if (!pte_none(*pte))
 			printk(KERN_ERR "alloc_area_pte: page already exists\n");
 		if (!page)
 			return -ENOMEM;
+
 		set_pte(pte, mk_pte(page, prot));
 		address += PAGE_SIZE;
 		pte++;
+		(*pages)++;
 	} while (address < end);
 	return 0;
 }
 
-static inline int alloc_area_pmd(pmd_t * pmd, unsigned long address, unsigned long size, int gfp_mask, pgprot_t prot)
+static inline int map_area_pmd(pmd_t *pmd, unsigned long address,
+			       unsigned long size, pgprot_t prot,
+			       struct page ***pages)
 {
 	unsigned long end;
 
@@ -132,76 +118,108 @@
 	end = address + size;
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
+
 	do {
 		pte_t * pte = pte_alloc_kernel(&init_mm, pmd, address);
 		if (!pte)
 			return -ENOMEM;
-		if (alloc_area_pte(pte, address, end - address, gfp_mask, prot))
+		if (map_area_pte(pte, address, end - address, prot, pages))
 			return -ENOMEM;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address < end);
+
 	return 0;
 }
 
-inline int vmalloc_area_pages (unsigned long address, unsigned long size,
-                               int gfp_mask, pgprot_t prot)
+void unmap_vm_area(struct vm_struct *area)
 {
-	pgd_t * dir;
-	unsigned long end = address + size;
-	int ret;
+	unsigned long address = VMALLOC_VMADDR(area->addr);
+	unsigned long end = (address + area->size);
+	pgd_t *dir;
+
+	dir = pgd_offset_k(address);
+	flush_cache_all();
+	do {
+		unmap_area_pmd(dir, address, end - address);
+		address = (address + PGDIR_SIZE) & PGDIR_MASK;
+		dir++;
+	} while (address && (address < end));
+	flush_tlb_kernel_range(VMALLOC_VMADDR(area->addr), end);
+}
+
+int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+{
+	unsigned long address = VMALLOC_VMADDR(area->addr);
+	unsigned long end = address + (area->size-PAGE_SIZE);
+	pgd_t *dir;
 
 	dir = pgd_offset_k(address);
 	spin_lock(&init_mm.page_table_lock);
 	do {
-		pmd_t *pmd;
-		
-		pmd = pmd_alloc(&init_mm, dir, address);
-		ret = -ENOMEM;
+		pmd_t *pmd = pmd_alloc(&init_mm, dir, address);
 		if (!pmd)
-			break;
-
-		ret = -ENOMEM;
-		if (alloc_area_pmd(pmd, address, end - address, gfp_mask, prot))
-			break;
+			return -ENOMEM;
+		if (map_area_pmd(pmd, address, end - address, prot, pages))
+			return -ENOMEM;
 
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
-
-		ret = 0;
 	} while (address && (address < end));
+
 	spin_unlock(&init_mm.page_table_lock);
 	flush_cache_all();
-	return ret;
+	return 0;
 }
 
-struct vm_struct * get_vm_area(unsigned long size, unsigned long flags)
+
+/**
+ *	get_vm_area  -  reserve a contingous kernel virtual area
+ *
+ *	@size:		size of the area
+ *	@flags:		%VM_IOREMAP for I/O mappings or VM_ALLOC
+ *
+ *	Search an area of @size in the kernel virtual mapping area,
+ *	and reserved it for out purposes.  Returns the area descriptor
+ *	on success or %NULL on failure.
+ */
+struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
-	unsigned long addr;
 	struct vm_struct **p, *tmp, *area;
+	unsigned long addr = VMALLOC_START;
 
-	area = (struct vm_struct *) kmalloc(sizeof(*area), GFP_KERNEL);
-	if (!area)
+	area = kmalloc(sizeof(*area), GFP_KERNEL);
+	if (unlikely(!area))
 		return NULL;
+
+	/*
+	 * We always allocate a guard page.
+	 */
 	size += PAGE_SIZE;
-	addr = VMALLOC_START;
+
 	write_lock(&vmlist_lock);
-	for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
+	for (p = &vmlist; (tmp = *p) ;p = &tmp->next) {
 		if ((size + addr) < addr)
 			goto out;
-		if (size + addr <= (unsigned long) tmp->addr)
-			break;
-		addr = tmp->size + (unsigned long) tmp->addr;
+		if (size + addr <= (unsigned long)tmp->addr)
+			goto found;
+		addr = tmp->size + (unsigned long)tmp->addr;
 		if (addr > VMALLOC_END-size)
 			goto out;
 	}
-	area->phys_addr = 0;
+
+found:
+	area->next = *p;
+	*p = area;
+
 	area->flags = flags;
 	area->addr = (void *)addr;
 	area->size = size;
-	area->next = *p;
-	*p = area;
+	area->pages = NULL;
+	area->nr_pages = 0;
+	area->phys_addr = 0;
 	write_unlock(&vmlist_lock);
+
 	return area;
 
 out:
@@ -210,87 +228,203 @@
 	return NULL;
 }
 
-struct vm_struct *remove_kernel_area(void *addr) 
+/**
+ *	remove_vm_area  -  find and remove a contingous kernel virtual area
+ *
+ *	@addr:		base address
+ *
+ *	Search for the kernel VM area starting at @addr, and remove it.
+ *	This function returns the found VM area, but using it is NOT safe
+ *	on SMP machines.
+ */
+struct vm_struct *remove_vm_area(void *addr)
 {
 	struct vm_struct **p, *tmp;
-	write_lock(&vmlist_lock);
-	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
-		if (tmp->addr == addr) {
-			*p = tmp->next;
-			write_unlock(&vmlist_lock);
-			return tmp;
-		}
 
+	write_lock(&vmlist_lock);
+	for (p = &vmlist ; (tmp = *p) ;p = &tmp->next) {
+		 if (tmp->addr == addr)
+			 goto found;
 	}
 	write_unlock(&vmlist_lock);
 	return NULL;
-} 
 
-void vfree(void * addr)
+found:
+	*p = tmp->next;
+	write_unlock(&vmlist_lock);
+	return tmp;
+}
+
+void __vunmap(void *addr, int deallocate_pages)
 {
-	struct vm_struct *tmp;
+	struct vm_struct *area;
 
 	if (!addr)
 		return;
-	if ((PAGE_SIZE-1) & (unsigned long) addr) {
+
+	if ((PAGE_SIZE-1) & (unsigned long)addr) {
 		printk(KERN_ERR "Trying to vfree() bad address (%p)\n", addr);
 		return;
 	}
-	tmp = remove_kernel_area(addr); 
-	if (tmp) { 
-			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
-			kfree(tmp);
-			return;
+
+	area = remove_vm_area(addr);
+	if (unlikely(!area)) {
+		printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
+				addr);
+		return;
+	}
+
+	unmap_vm_area(area);
+	
+	if (deallocate_pages) {
+		int i;
+
+		for (i = 0; i < area->nr_pages; i++) {
+			if (unlikely(!area->pages[i]))
+				BUG();
+			__free_page(area->pages[i]);
 		}
-	printk(KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n", addr);
+
+		kfree(area->pages);
+	}
+
+	kfree(area);
+	return;
 }
 
-/*
- *	Allocate any pages
+/**
+ *	vfree  -  release memory allocated by vmalloc()
+ *
+ *	@addr:		memory base address
+ *
+ *	Free the virtually continguos memory area starting at @addr, as
+ *	obtained from vmalloc(), vmalloc_32() or __vmalloc().
+ *
+ *	May not be called in interrupt context.
  */
-
-void * vmalloc (unsigned long size)
+void vfree(void *addr)
 {
-	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
+	__vunmap(addr, 1);
 }
 
-/*
- *	Allocate ISA addressable pages for broke crap
+/**
+ *	vunmap  -  release virtual mapping obtained by vmap()
+ *
+ *	@addr:		memory base address
+ *
+ *	Free the virtually continguos memory area starting at @addr,
+ *	which was created from the page array passed to vmap().
+ *
+ *	May not be called in interrupt context.
  */
-
-void * vmalloc_dma (unsigned long size)
+void vunmap(void *addr)
 {
-	return __vmalloc(size, GFP_KERNEL|GFP_DMA, PAGE_KERNEL);
+	__vunmap(addr, 0);
 }
 
-/*
- *	vmalloc 32bit PA addressable pages - eg for PCI 32bit devices
+/**
+ *	vmap  -  map an array of pages into virtually continguos space
+ *
+ *	@pages:		array of page pointers
+ *	@count:		number of pages to map
+ *
+ *	Maps @count pages from @pages into continguos kernel virtual
+ *	space.
  */
-
-void * vmalloc_32(unsigned long size)
+void *vmap(struct page **pages, unsigned int count)
 {
-	return __vmalloc(size, GFP_KERNEL, PAGE_KERNEL);
+	struct vm_struct *area;
+
+	if (count > num_physpages)
+		return NULL;
+
+	area = get_vm_area((count << PAGE_SHIFT), VM_MAP);
+	if (!area)
+		return NULL;
+	if (map_vm_area(area, PAGE_KERNEL, &pages)) {
+		vunmap(area->addr);
+		return NULL;
+	}
+
+	return area->addr;
 }
 
-void * __vmalloc (unsigned long size, int gfp_mask, pgprot_t prot)
+/**
+ *	__vmalloc  -  allocate virtually continguos memory
+ *
+ *	@size:		allocation size
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator with @gfp_mask flags.  Map them into continguos
+ *	kernel virtual space, using a pagetable protection of @prot.
+ */
+void *__vmalloc(unsigned long size, int gfp_mask, pgprot_t prot)
 {
-	void * addr;
 	struct vm_struct *area;
+	struct page **pages;
+	unsigned int nr_pages, array_size, i;
 
 	size = PAGE_ALIGN(size);
-	if (!size || (size >> PAGE_SHIFT) > num_physpages) {
-		BUG();
+	if (!size || (size >> PAGE_SHIFT) > num_physpages)
 		return NULL;
-	}
+
 	area = get_vm_area(size, VM_ALLOC);
 	if (!area)
 		return NULL;
-	addr = area->addr;
-	if (vmalloc_area_pages(VMALLOC_VMADDR(addr), size, gfp_mask, prot)) {
-		vfree(addr);
+
+	nr_pages = (size+PAGE_SIZE) >> PAGE_SHIFT;
+	array_size = (nr_pages * sizeof(struct page *));
+
+	area->nr_pages = nr_pages;
+	area->pages = pages = kmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM));
+	if (!area->pages)
 		return NULL;
+	memset(area->pages, 0, array_size);
+
+	for (i = 0; i < area->nr_pages; i++) {
+		area->pages[i] = alloc_page(gfp_mask);
+		if (unlikely(!area->pages[i]))
+			goto fail;
 	}
-	return addr;
+	
+	if (map_vm_area(area, prot, &pages))
+		goto fail;
+	return area->addr;
+
+fail:
+	vfree(area->addr);
+	return NULL;
+}
+
+/**
+ *	vmalloc  -  allocate virtually continguos memory
+ *
+ *	@size:		allocation size
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator and map them into continguos kernel virtual space.
+ *
+ *	For tight cotrol over page level allocator and protection flags
+ *	use __vmalloc() instead.
+ */
+void *vmalloc(unsigned long size)
+{
+       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
+}
+
+/**
+ *	vmalloc_32  -  allocate virtually continguos memory (32bit addressable)
+ *
+ *	@size:		allocation size
+ *
+ *	Allocate enough 32bit PA addressable pages to cover @size from the
+ *	page level allocator and map them into continguos kernel virtual space.
+ */
+void *vmalloc_32(unsigned long size)
+{
+	return __vmalloc(size, GFP_KERNEL, PAGE_KERNEL);
 }
 
 long vread(char *buf, char *addr, unsigned long count)

===================================================================


This BitKeeper patch contains the following changesets:
1.458
## Wrapped with gzip_uu ##


begin 664 bkpatch5312
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
I:XOI6VY_8(OV28ZW.5S^7S]OQKW;=+DXFIB.JG//E/\;@P-E(E8X````
`
end
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
