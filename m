Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 854C16B003D
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:33:09 -0500 (EST)
Date: Sat, 28 Feb 2009 12:33:02 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 1/5] fsblock: prep
Message-ID: <20090228113302.GE28496@wotan.suse.de>
References: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228112858.GD28496@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>

Note: Don't bother reviewing this. It is a lot of rolled up patches.

This includes most of the core code changes required for fsblock.
Basically a rollup of the recent patches I sent, plus a rollup of
vmap changes (importantly change vmap API so vunmap is callable from
interrupt context. The vmap change is irrelevant unless running minix
with superpage size blocks, and fsblock's VMAP_CACHE feature).

---
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -14,6 +14,7 @@
 #include <linux/highmem.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -29,6 +30,16 @@
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
 
+/*
+ * Add a guard page between each kernel virtual address allocation if
+ * DEBUG_PAGEALLOC is turned on (could be a separate config option, but
+ * no big deal).
+ */
+#ifdef CONFIG_DEBUG_PAGEALLOC
+#define GUARD_SIZE PAGE_SIZE
+#else
+#define GUARD_SIZE 0
+#endif
 
 /*** Page table manipulation functions ***/
 
@@ -323,6 +334,7 @@ static struct vmap_area *alloc_vmap_area
 	unsigned long addr;
 	int purged = 0;
 
+	BUG_ON(in_interrupt());
 	BUG_ON(!size);
 	BUG_ON(size & ~PAGE_MASK);
 
@@ -334,7 +346,7 @@ static struct vmap_area *alloc_vmap_area
 retry:
 	addr = ALIGN(vstart, align);
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irq(&vmap_area_lock);
 	if (addr + size - 1 < addr)
 		goto overflow;
 
@@ -368,7 +380,7 @@ retry:
 		}
 
 		while (addr + size > first->va_start && addr + size <= vend) {
-			addr = ALIGN(first->va_end + PAGE_SIZE, align);
+			addr = ALIGN(first->va_end + GUARD_SIZE, align);
 			if (addr + size - 1 < addr)
 				goto overflow;
 
@@ -382,7 +394,7 @@ retry:
 found:
 	if (addr + size > vend) {
 overflow:
-		spin_unlock(&vmap_area_lock);
+		spin_unlock_irq(&vmap_area_lock);
 		if (!purged) {
 			purge_vmap_area_lazy();
 			purged = 1;
@@ -401,7 +413,7 @@ overflow:
 	va->va_end = addr + size;
 	va->flags = 0;
 	__insert_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irq(&vmap_area_lock);
 
 	return va;
 }
@@ -428,9 +440,9 @@ static void __free_vmap_area(struct vmap
  */
 static void free_vmap_area(struct vmap_area *va)
 {
-	spin_lock(&vmap_area_lock);
+	spin_lock_irq(&vmap_area_lock);
 	__free_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irq(&vmap_area_lock);
 }
 
 /*
@@ -457,8 +469,10 @@ static void vmap_debug_free_range(unsign
 	 * faster).
 	 */
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	vunmap_page_range(start, end);
-	flush_tlb_kernel_range(start, end);
+	if (!irqs_disabled()) {
+		vunmap_page_range(start, end);
+		flush_tlb_kernel_range(start, end);
+	}
 #endif
 }
 
@@ -502,10 +516,9 @@ static atomic_t vmap_lazy_nr = ATOMIC_IN
 static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 					int sync, int force_flush)
 {
-	static DEFINE_SPINLOCK(purge_lock);
+	static DEFINE_MUTEX(purge_lock);
 	LIST_HEAD(valist);
 	struct vmap_area *va;
-	struct vmap_area *n_va;
 	int nr = 0;
 
 	/*
@@ -514,10 +527,10 @@ static void __purge_vmap_area_lazy(unsig
 	 * the case that isn't actually used at the moment anyway.
 	 */
 	if (!sync && !force_flush) {
-		if (!spin_trylock(&purge_lock))
+		if (!mutex_trylock(&purge_lock))
 			return;
 	} else
-		spin_lock(&purge_lock);
+		mutex_lock(&purge_lock);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(va, &vmap_area_list, list) {
@@ -544,12 +557,12 @@ static void __purge_vmap_area_lazy(unsig
 		flush_tlb_kernel_range(*start, *end);
 
 	if (nr) {
-		spin_lock(&vmap_area_lock);
-		list_for_each_entry_safe(va, n_va, &valist, purge_list)
+		spin_lock_irq(&vmap_area_lock);
+		list_for_each_entry(va, &valist, purge_list)
 			__free_vmap_area(va);
-		spin_unlock(&vmap_area_lock);
+		spin_unlock_irq(&vmap_area_lock);
 	}
-	spin_unlock(&purge_lock);
+	mutex_unlock(&purge_lock);
 }
 
 /*
@@ -573,6 +586,17 @@ static void purge_vmap_area_lazy(void)
 	__purge_vmap_area_lazy(&start, &end, 1, 0);
 }
 
+static void deferred_purge(struct work_struct *work)
+{
+	try_purge_vmap_area_lazy();
+}
+
+static struct work_struct purge_work;
+static void kick_purge_vmap_area_lazy(void)
+{
+	schedule_work(&purge_work);
+}
+
 /*
  * Free and unmap a vmap area, caller ensuring flush_cache_vunmap had been
  * called for the correct range previously.
@@ -582,7 +606,7 @@ static void free_unmap_vmap_area_noflush
 	va->flags |= VM_LAZY_FREE;
 	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
 	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
-		try_purge_vmap_area_lazy();
+		kick_purge_vmap_area_lazy();
 }
 
 /*
@@ -597,10 +621,11 @@ static void free_unmap_vmap_area(struct
 static struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
+	unsigned long flags;
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	va = __find_vmap_area(addr);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	return va;
 }
@@ -734,17 +759,17 @@ static struct vmap_block *new_vmap_block
 	INIT_LIST_HEAD(&vb->dirty_list);
 
 	vb_idx = addr_to_vb_idx(va->va_start);
-	spin_lock(&vmap_block_tree_lock);
+	spin_lock_irq(&vmap_block_tree_lock);
 	err = radix_tree_insert(&vmap_block_tree, vb_idx, vb);
-	spin_unlock(&vmap_block_tree_lock);
+	spin_unlock_irq(&vmap_block_tree_lock);
 	BUG_ON(err);
 	radix_tree_preload_end();
 
 	vbq = &get_cpu_var(vmap_block_queue);
 	vb->vbq = vbq;
-	spin_lock(&vbq->lock);
+	spin_lock_irq(&vbq->lock);
 	list_add(&vb->free_list, &vbq->free);
-	spin_unlock(&vbq->lock);
+	spin_unlock_irq(&vbq->lock);
 	put_cpu_var(vmap_cpu_blocks);
 
 	return vb;
@@ -762,17 +787,17 @@ static void free_vmap_block(struct vmap_
 	struct vmap_block *tmp;
 	unsigned long vb_idx;
 
-	spin_lock(&vb->vbq->lock);
+	spin_lock_irq(&vb->vbq->lock);
 	if (!list_empty(&vb->free_list))
 		list_del(&vb->free_list);
 	if (!list_empty(&vb->dirty_list))
 		list_del(&vb->dirty_list);
-	spin_unlock(&vb->vbq->lock);
+	spin_unlock_irq(&vb->vbq->lock);
 
 	vb_idx = addr_to_vb_idx(vb->va->va_start);
-	spin_lock(&vmap_block_tree_lock);
+	spin_lock_irq(&vmap_block_tree_lock);
 	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
-	spin_unlock(&vmap_block_tree_lock);
+	spin_unlock_irq(&vmap_block_tree_lock);
 	BUG_ON(tmp != vb);
 
 	free_unmap_vmap_area_noflush(vb->va);
@@ -786,6 +811,7 @@ static void *vb_alloc(unsigned long size
 	unsigned long addr = 0;
 	unsigned int order;
 
+	BUG_ON(in_interrupt());
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
 	order = get_order(size);
@@ -796,7 +822,7 @@ again:
 	list_for_each_entry_rcu(vb, &vbq->free, free_list) {
 		int i;
 
-		spin_lock(&vb->lock);
+		spin_lock_irq(&vb->lock);
 		i = bitmap_find_free_region(vb->alloc_map,
 						VMAP_BBMAP_BITS, order);
 
@@ -806,14 +832,14 @@ again:
 					addr_to_vb_idx(vb->va->va_start));
 			vb->free -= 1UL << order;
 			if (vb->free == 0) {
-				spin_lock(&vbq->lock);
+				spin_lock_irq(&vbq->lock);
 				list_del_init(&vb->free_list);
-				spin_unlock(&vbq->lock);
+				spin_unlock_irq(&vbq->lock);
 			}
-			spin_unlock(&vb->lock);
+			spin_unlock_irq(&vb->lock);
 			break;
 		}
-		spin_unlock(&vb->lock);
+		spin_unlock_irq(&vb->lock);
 	}
 	put_cpu_var(vmap_cpu_blocks);
 	rcu_read_unlock();
@@ -830,11 +856,13 @@ again:
 
 static void vb_free(const void *addr, unsigned long size)
 {
+	unsigned long flags;
 	unsigned long offset;
 	unsigned long vb_idx;
 	unsigned int order;
 	struct vmap_block *vb;
 
+	BUG_ON(in_interrupt());
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
 
@@ -850,7 +878,7 @@ static void vb_free(const void *addr, un
 	rcu_read_unlock();
 	BUG_ON(!vb);
 
-	spin_lock(&vb->lock);
+	spin_lock_irqsave(&vb->lock, flags);
 	bitmap_allocate_region(vb->dirty_map, offset >> PAGE_SHIFT, order);
 	if (!vb->dirty) {
 		spin_lock(&vb->vbq->lock);
@@ -860,10 +888,10 @@ static void vb_free(const void *addr, un
 	vb->dirty += 1UL << order;
 	if (vb->dirty == VMAP_BBMAP_BITS) {
 		BUG_ON(vb->free || !list_empty(&vb->free_list));
-		spin_unlock(&vb->lock);
+		spin_unlock_irqrestore(&vb->lock, flags);
 		free_vmap_block(vb);
 	} else
-		spin_unlock(&vb->lock);
+		spin_unlock_irqrestore(&vb->lock, flags);
 }
 
 /**
@@ -888,6 +916,8 @@ void vm_unmap_aliases(void)
 	if (unlikely(!vmap_initialized))
 		return;
 
+	BUG_ON(in_interrupt());
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -896,7 +926,7 @@ void vm_unmap_aliases(void)
 		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
 			int i;
 
-			spin_lock(&vb->lock);
+			spin_lock_irq(&vb->lock);
 			i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
 			while (i < VMAP_BBMAP_BITS) {
 				unsigned long s, e;
@@ -918,7 +948,7 @@ void vm_unmap_aliases(void)
 				i = find_next_bit(vb->dirty_map,
 							VMAP_BBMAP_BITS, i);
 			}
-			spin_unlock(&vb->lock);
+			spin_unlock_irq(&vb->lock);
 		}
 		rcu_read_unlock();
 	}
@@ -942,6 +972,8 @@ void vm_unmap_ram(const void *mem, unsig
 	BUG_ON(addr > VMALLOC_END);
 	BUG_ON(addr & (PAGE_SIZE-1));
 
+	BUG_ON(in_interrupt());
+
 	debug_check_no_locks_freed(mem, size);
 	vmap_debug_free_range(addr, addr+size);
 
@@ -967,6 +999,8 @@ void *vm_map_ram(struct page **pages, un
 	unsigned long addr;
 	void *mem;
 
+	BUG_ON(in_interrupt());
+
 	if (likely(count <= VMAP_MAX_ALLOC)) {
 		mem = vb_alloc(size, GFP_KERNEL);
 		if (IS_ERR(mem))
@@ -996,6 +1030,7 @@ void __init vmalloc_init(void)
 	struct vm_struct *tmp;
 	int i;
 
+	INIT_WORK(&purge_work, deferred_purge);
 	for_each_possible_cpu(i) {
 		struct vmap_block_queue *vbq;
 
@@ -1029,7 +1064,7 @@ void unmap_kernel_range(unsigned long ad
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
-	unsigned long end = addr + area->size - PAGE_SIZE;
+	unsigned long end = addr + area->size;
 	int err;
 
 	err = vmap_page_range(addr, end, prot, *pages);
@@ -1055,7 +1090,6 @@ static struct vm_struct *__get_vm_area_n
 	struct vm_struct *tmp, **p;
 	unsigned long align = 1;
 
-	BUG_ON(in_interrupt());
 	if (flags & VM_IOREMAP) {
 		int bit = fls(size);
 
@@ -1075,11 +1109,6 @@ static struct vm_struct *__get_vm_area_n
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
@@ -1096,14 +1125,14 @@ static struct vm_struct *__get_vm_area_n
 	va->private = area;
 	va->flags |= VM_VM_AREA;
 
-	write_lock(&vmlist_lock);
+	write_lock_irq(&vmlist_lock);
 	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
 		if (tmp->addr >= area->addr)
 			break;
 	}
 	area->next = *p;
 	*p = area;
-	write_unlock(&vmlist_lock);
+	write_unlock_irq(&vmlist_lock);
 
 	return area;
 }
@@ -1180,16 +1209,16 @@ struct vm_struct *remove_vm_area(const v
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->private;
 		struct vm_struct *tmp, **p;
+		unsigned long flags;
 
 		vmap_debug_free_range(va->va_start, va->va_end);
 		free_unmap_vmap_area(va);
-		vm->size -= PAGE_SIZE;
 
-		write_lock(&vmlist_lock);
+		write_lock_irqsave(&vmlist_lock, flags);
 		for (p = &vmlist; (tmp = *p) != vm; p = &tmp->next)
 			;
 		*p = tmp->next;
-		write_unlock(&vmlist_lock);
+		write_unlock_irqrestore(&vmlist_lock, flags);
 
 		return vm;
 	}
@@ -1250,7 +1279,6 @@ static void __vunmap(const void *addr, i
  */
 void vfree(const void *addr)
 {
-	BUG_ON(in_interrupt());
 	__vunmap(addr, 1);
 }
 EXPORT_SYMBOL(vfree);
@@ -1266,7 +1294,6 @@ EXPORT_SYMBOL(vfree);
  */
 void vunmap(const void *addr)
 {
-	BUG_ON(in_interrupt());
 	__vunmap(addr, 0);
 }
 EXPORT_SYMBOL(vunmap);
@@ -1311,7 +1338,7 @@ static void *__vmalloc_area_node(struct
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
 
-	nr_pages = (area->size - PAGE_SIZE) >> PAGE_SHIFT;
+	nr_pages = area->size >> PAGE_SHIFT;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -1533,10 +1560,10 @@ long vread(char *buf, char *addr, unsign
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
-	read_lock(&vmlist_lock);
+	read_lock_irq(&vmlist_lock);
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+		if (addr >= vaddr + tmp->size)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -1546,7 +1573,7 @@ long vread(char *buf, char *addr, unsign
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + tmp->size - addr;
 		do {
 			if (count == 0)
 				goto finished;
@@ -1557,7 +1584,7 @@ long vread(char *buf, char *addr, unsign
 		} while (--n > 0);
 	}
 finished:
-	read_unlock(&vmlist_lock);
+	read_unlock_irq(&vmlist_lock);
 	return buf - buf_start;
 }
 
@@ -1571,10 +1598,10 @@ long vwrite(char *buf, char *addr, unsig
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
-	read_lock(&vmlist_lock);
+	read_lock_irq(&vmlist_lock);
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		vaddr = (char *) tmp->addr;
-		if (addr >= vaddr + tmp->size - PAGE_SIZE)
+		if (addr >= vaddr + tmp->size)
 			continue;
 		while (addr < vaddr) {
 			if (count == 0)
@@ -1583,7 +1610,7 @@ long vwrite(char *buf, char *addr, unsig
 			addr++;
 			count--;
 		}
-		n = vaddr + tmp->size - PAGE_SIZE - addr;
+		n = vaddr + tmp->size - addr;
 		do {
 			if (count == 0)
 				goto finished;
@@ -1594,7 +1621,7 @@ long vwrite(char *buf, char *addr, unsig
 		} while (--n > 0);
 	}
 finished:
-	read_unlock(&vmlist_lock);
+	read_unlock_irq(&vmlist_lock);
 	return buf - buf_start;
 }
 
@@ -1629,7 +1656,7 @@ int remap_vmalloc_range(struct vm_area_s
 	if (!(area->flags & VM_USERMAP))
 		return -EINVAL;
 
-	if (usize + (pgoff << PAGE_SHIFT) > area->size - PAGE_SIZE)
+	if (usize + (pgoff << PAGE_SHIFT) > area->size)
 		return -EINVAL;
 
 	addr += pgoff << PAGE_SHIFT;
@@ -1723,7 +1750,7 @@ static void *s_start(struct seq_file *m,
 	loff_t n = *pos;
 	struct vm_struct *v;
 
-	read_lock(&vmlist_lock);
+	read_lock_irq(&vmlist_lock);
 	v = vmlist;
 	while (n > 0 && v) {
 		n--;
@@ -1746,7 +1773,7 @@ static void *s_next(struct seq_file *m,
 
 static void s_stop(struct seq_file *m, void *p)
 {
-	read_unlock(&vmlist_lock);
+	read_unlock_irq(&vmlist_lock);
 }
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
Index: linux-2.6/arch/arm/mm/ioremap.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/ioremap.c
+++ linux-2.6/arch/arm/mm/ioremap.c
@@ -345,7 +345,7 @@ void __iounmap(volatile void __iomem *io
 	 * all the mappings before the area can be reclaimed
 	 * by someone else.
 	 */
-	write_lock(&vmlist_lock);
+	write_lock_irq(&vmlist_lock);
 	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
 		if ((tmp->flags & VM_IOREMAP) && (tmp->addr == addr)) {
 			if (tmp->flags & VM_ARM_SECTION_MAPPING) {
@@ -355,7 +355,7 @@ void __iounmap(volatile void __iomem *io
 			break;
 		}
 	}
-	write_unlock(&vmlist_lock);
+	write_unlock_irq(&vmlist_lock);
 #endif
 
 	vunmap(addr);
Index: linux-2.6/drivers/xen/xenbus/xenbus_client.c
===================================================================
--- linux-2.6.orig/drivers/xen/xenbus/xenbus_client.c
+++ linux-2.6/drivers/xen/xenbus/xenbus_client.c
@@ -488,12 +488,12 @@ int xenbus_unmap_ring_vfree(struct xenbu
 	 * xenbus_map_ring_valloc, but these 6 lines considerably simplify
 	 * this API.
 	 */
-	read_lock(&vmlist_lock);
+	read_lock_irq(&vmlist_lock);
 	for (area = vmlist; area != NULL; area = area->next) {
 		if (area->addr == vaddr)
 			break;
 	}
-	read_unlock(&vmlist_lock);
+	read_unlock_irq(&vmlist_lock);
 
 	if (!area) {
 		xenbus_dev_error(dev, -ENOENT,
Index: linux-2.6/fs/proc/kcore.c
===================================================================
--- linux-2.6.orig/fs/proc/kcore.c
+++ linux-2.6/fs/proc/kcore.c
@@ -336,7 +336,7 @@ read_kcore(struct file *file, char __use
 			if (!elf_buf)
 				return -ENOMEM;
 
-			read_lock(&vmlist_lock);
+			read_lock_irq(&vmlist_lock);
 			for (m=vmlist; m && cursize; m=m->next) {
 				unsigned long vmstart;
 				unsigned long vmsize;
@@ -364,7 +364,7 @@ read_kcore(struct file *file, char __use
 				memcpy(elf_buf + (vmstart - start),
 					(char *)vmstart, vmsize);
 			}
-			read_unlock(&vmlist_lock);
+			read_unlock_irq(&vmlist_lock);
 			if (copy_to_user(buffer, elf_buf, tsz)) {
 				kfree(elf_buf);
 				return -EFAULT;
Index: linux-2.6/fs/proc/mmu.c
===================================================================
--- linux-2.6.orig/fs/proc/mmu.c
+++ linux-2.6/fs/proc/mmu.c
@@ -30,7 +30,7 @@ void get_vmalloc_info(struct vmalloc_inf
 
 		prev_end = VMALLOC_START;
 
-		read_lock(&vmlist_lock);
+		read_lock_irq(&vmlist_lock);
 
 		for (vma = vmlist; vma; vma = vma->next) {
 			unsigned long addr = (unsigned long) vma->addr;
@@ -55,6 +55,6 @@ void get_vmalloc_info(struct vmalloc_inf
 		if (VMALLOC_END - prev_end > vmi->largest_chunk)
 			vmi->largest_chunk = VMALLOC_END - prev_end;
 
-		read_unlock(&vmlist_lock);
+		read_unlock_irq(&vmlist_lock);
 	}
 }
Index: linux-2.6/arch/x86/mm/ioremap.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/ioremap.c
+++ linux-2.6/arch/x86/mm/ioremap.c
@@ -428,12 +428,12 @@ void iounmap(volatile void __iomem *addr
 	   in parallel. Reuse of the virtual address is prevented by
 	   leaving it in the global lists until we're done with it.
 	   cpa takes care of the direct mappings. */
-	read_lock(&vmlist_lock);
+	read_lock_irq(&vmlist_lock);
 	for (p = vmlist; p; p = p->next) {
 		if (p->addr == (void __force *)addr)
 			break;
 	}
-	read_unlock(&vmlist_lock);
+	read_unlock_irq(&vmlist_lock);
 
 	if (!p) {
 		printk(KERN_ERR "iounmap: bad address %p\n", addr);
Index: linux-2.6/fs/file.c
===================================================================
--- linux-2.6.orig/fs/file.c
+++ linux-2.6/fs/file.c
@@ -20,24 +20,10 @@
 #include <linux/rcupdate.h>
 #include <linux/workqueue.h>
 
-struct fdtable_defer {
-	spinlock_t lock;
-	struct work_struct wq;
-	struct fdtable *next;
-};
-
 int sysctl_nr_open __read_mostly = 1024*1024;
 int sysctl_nr_open_min = BITS_PER_LONG;
 int sysctl_nr_open_max = 1024 * 1024; /* raised later */
 
-/*
- * We use this list to defer free fdtables that have vmalloced
- * sets/arrays. By keeping a per-cpu list, we avoid having to embed
- * the work_struct in fdtable itself which avoids a 64 byte (i386) increase in
- * this per-task structure.
- */
-static DEFINE_PER_CPU(struct fdtable_defer, fdtable_defer_list);
-
 static inline void * alloc_fdmem(unsigned int size)
 {
 	if (size <= PAGE_SIZE)
@@ -62,29 +48,9 @@ static inline void free_fdset(struct fdt
 		vfree(fdt->open_fds);
 }
 
-static void free_fdtable_work(struct work_struct *work)
-{
-	struct fdtable_defer *f =
-		container_of(work, struct fdtable_defer, wq);
-	struct fdtable *fdt;
-
-	spin_lock_bh(&f->lock);
-	fdt = f->next;
-	f->next = NULL;
-	spin_unlock_bh(&f->lock);
-	while(fdt) {
-		struct fdtable *next = fdt->next;
-		vfree(fdt->fd);
-		free_fdset(fdt);
-		kfree(fdt);
-		fdt = next;
-	}
-}
-
 void free_fdtable_rcu(struct rcu_head *rcu)
 {
 	struct fdtable *fdt = container_of(rcu, struct fdtable, rcu);
-	struct fdtable_defer *fddef;
 
 	BUG_ON(!fdt);
 
@@ -97,20 +63,9 @@ void free_fdtable_rcu(struct rcu_head *r
 				container_of(fdt, struct files_struct, fdtab));
 		return;
 	}
-	if (fdt->max_fds <= (PAGE_SIZE / sizeof(struct file *))) {
-		kfree(fdt->fd);
-		kfree(fdt->open_fds);
-		kfree(fdt);
-	} else {
-		fddef = &get_cpu_var(fdtable_defer_list);
-		spin_lock(&fddef->lock);
-		fdt->next = fddef->next;
-		fddef->next = fdt;
-		/* vmallocs are handled from the workqueue context */
-		schedule_work(&fddef->wq);
-		spin_unlock(&fddef->lock);
-		put_cpu_var(fdtable_defer_list);
-	}
+	free_fdarr(fdt);
+	free_fdset(fdt);
+	kfree(fdt);
 }
 
 /*
@@ -404,19 +359,8 @@ out:
 	return NULL;
 }
 
-static void __devinit fdtable_defer_list_init(int cpu)
-{
-	struct fdtable_defer *fddef = &per_cpu(fdtable_defer_list, cpu);
-	spin_lock_init(&fddef->lock);
-	INIT_WORK(&fddef->wq, free_fdtable_work);
-	fddef->next = NULL;
-}
-
 void __init files_defer_init(void)
 {
-	int i;
-	for_each_possible_cpu(i)
-		fdtable_defer_list_init(i);
 	sysctl_nr_open_max = min((size_t)INT_MAX, ~(size_t)0/sizeof(void *)) &
 			     -BITS_PER_LONG;
 }
Index: linux-2.6/ipc/util.c
===================================================================
--- linux-2.6.orig/ipc/util.c
+++ linux-2.6/ipc/util.c
@@ -477,10 +477,9 @@ void ipc_free(void* ptr, int size)
 
 /*
  * rcu allocations:
- * There are three headers that are prepended to the actual allocation:
+ * There are two headers that are prepended to the actual allocation:
  * - during use: ipc_rcu_hdr.
  * - during the rcu grace period: ipc_rcu_grace.
- * - [only if vmalloc]: ipc_rcu_sched.
  * Their lifetime doesn't overlap, thus the headers share the same memory.
  * Unlike a normal union, they are right-aligned, thus some container_of
  * forward/backward casting is necessary:
@@ -489,33 +488,16 @@ struct ipc_rcu_hdr
 {
 	int refcount;
 	int is_vmalloc;
-	void *data[0];
-};
-
-
-struct ipc_rcu_grace
-{
 	struct rcu_head rcu;
-	/* "void *" makes sure alignment of following data is sane. */
-	void *data[0];
-};
 
-struct ipc_rcu_sched
-{
-	struct work_struct work;
-	/* "void *" makes sure alignment of following data is sane. */
 	void *data[0];
 };
 
-#define HDRLEN_KMALLOC		(sizeof(struct ipc_rcu_grace) > sizeof(struct ipc_rcu_hdr) ? \
-					sizeof(struct ipc_rcu_grace) : sizeof(struct ipc_rcu_hdr))
-#define HDRLEN_VMALLOC		(sizeof(struct ipc_rcu_sched) > HDRLEN_KMALLOC ? \
-					sizeof(struct ipc_rcu_sched) : HDRLEN_KMALLOC)
 
 static inline int rcu_use_vmalloc(int size)
 {
 	/* Too big for a single page? */
-	if (HDRLEN_KMALLOC + size > PAGE_SIZE)
+	if (sizeof(struct ipc_rcu_hdr) + size > PAGE_SIZE)
 		return 1;
 	return 0;
 }
@@ -532,23 +514,26 @@ static inline int rcu_use_vmalloc(int si
 void* ipc_rcu_alloc(int size)
 {
 	void* out;
-	/* 
-	 * We prepend the allocation with the rcu struct, and
-	 * workqueue if necessary (for vmalloc). 
-	 */
+
 	if (rcu_use_vmalloc(size)) {
-		out = vmalloc(HDRLEN_VMALLOC + size);
+		out = vmalloc(sizeof(struct ipc_rcu_hdr) + size);
 		if (out) {
-			out += HDRLEN_VMALLOC;
-			container_of(out, struct ipc_rcu_hdr, data)->is_vmalloc = 1;
-			container_of(out, struct ipc_rcu_hdr, data)->refcount = 1;
+			struct ipc_rcu_hdr *hdr;
+
+			out += sizeof(struct ipc_rcu_hdr);
+			hdr = container_of(out, struct ipc_rcu_hdr, data);
+			hdr->is_vmalloc = 1;
+			hdr->refcount = 1;
 		}
 	} else {
-		out = kmalloc(HDRLEN_KMALLOC + size, GFP_KERNEL);
+		out = kmalloc(sizeof(struct ipc_rcu_hdr) + size, GFP_KERNEL);
 		if (out) {
-			out += HDRLEN_KMALLOC;
-			container_of(out, struct ipc_rcu_hdr, data)->is_vmalloc = 0;
-			container_of(out, struct ipc_rcu_hdr, data)->refcount = 1;
+			struct ipc_rcu_hdr *hdr;
+
+			out += sizeof(struct ipc_rcu_hdr);
+			hdr = container_of(out, struct ipc_rcu_hdr, data);
+			hdr->is_vmalloc = 0;
+			hdr->refcount = 1;
 		}
 	}
 
@@ -560,56 +545,30 @@ void ipc_rcu_getref(void *ptr)
 	container_of(ptr, struct ipc_rcu_hdr, data)->refcount++;
 }
 
-static void ipc_do_vfree(struct work_struct *work)
-{
-	vfree(container_of(work, struct ipc_rcu_sched, work));
-}
-
-/**
- * ipc_schedule_free - free ipc + rcu space
- * @head: RCU callback structure for queued work
- * 
- * Since RCU callback function is called in bh,
- * we need to defer the vfree to schedule_work().
- */
-static void ipc_schedule_free(struct rcu_head *head)
-{
-	struct ipc_rcu_grace *grace;
-	struct ipc_rcu_sched *sched;
-
-	grace = container_of(head, struct ipc_rcu_grace, rcu);
-	sched = container_of(&(grace->data[0]), struct ipc_rcu_sched,
-				data[0]);
-
-	INIT_WORK(&sched->work, ipc_do_vfree);
-	schedule_work(&sched->work);
-}
-
 /**
  * ipc_immediate_free - free ipc + rcu space
  * @head: RCU callback structure that contains pointer to be freed
  *
  * Free from the RCU callback context.
  */
-static void ipc_immediate_free(struct rcu_head *head)
+static void ipc_rcu_free(struct rcu_head *head)
 {
-	struct ipc_rcu_grace *free =
-		container_of(head, struct ipc_rcu_grace, rcu);
-	kfree(free);
+	struct ipc_rcu_hdr *hdr = container_of(head, struct ipc_rcu_hdr, rcu);
+
+	if (hdr->is_vmalloc)
+		vfree(hdr);
+	else
+		kfree(hdr);
 }
 
 void ipc_rcu_putref(void *ptr)
 {
-	if (--container_of(ptr, struct ipc_rcu_hdr, data)->refcount > 0)
+	struct ipc_rcu_hdr *hdr = container_of(ptr, struct ipc_rcu_hdr, data);
+
+	if (--hdr->refcount > 0)
 		return;
 
-	if (container_of(ptr, struct ipc_rcu_hdr, data)->is_vmalloc) {
-		call_rcu(&container_of(ptr, struct ipc_rcu_grace, data)->rcu,
-				ipc_schedule_free);
-	} else {
-		call_rcu(&container_of(ptr, struct ipc_rcu_grace, data)->rcu,
-				ipc_immediate_free);
-	}
+	call_rcu(&hdr->rcu, ipc_rcu_free);
 }
 
 /**
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -166,151 +166,6 @@ void end_buffer_write_sync(struct buffer
 }
 
 /*
- * Write out and wait upon all the dirty data associated with a block
- * device via its mapping.  Does not take the superblock lock.
- */
-int sync_blockdev(struct block_device *bdev)
-{
-	int ret = 0;
-
-	if (bdev)
-		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
-	return ret;
-}
-EXPORT_SYMBOL(sync_blockdev);
-
-/*
- * Write out and wait upon all dirty data associated with this
- * device.   Filesystem data as well as the underlying block
- * device.  Takes the superblock lock.
- */
-int fsync_bdev(struct block_device *bdev)
-{
-	struct super_block *sb = get_super(bdev);
-	if (sb) {
-		int res = fsync_super(sb);
-		drop_super(sb);
-		return res;
-	}
-	return sync_blockdev(bdev);
-}
-
-/**
- * freeze_bdev  --  lock a filesystem and force it into a consistent state
- * @bdev:	blockdevice to lock
- *
- * This takes the block device bd_mount_sem to make sure no new mounts
- * happen on bdev until thaw_bdev() is called.
- * If a superblock is found on this device, we take the s_umount semaphore
- * on it to make sure nobody unmounts until the snapshot creation is done.
- * The reference counter (bd_fsfreeze_count) guarantees that only the last
- * unfreeze process can unfreeze the frozen filesystem actually when multiple
- * freeze requests arrive simultaneously. It counts up in freeze_bdev() and
- * count down in thaw_bdev(). When it becomes 0, thaw_bdev() will unfreeze
- * actually.
- */
-struct super_block *freeze_bdev(struct block_device *bdev)
-{
-	struct super_block *sb;
-	int error = 0;
-
-	mutex_lock(&bdev->bd_fsfreeze_mutex);
-	if (bdev->bd_fsfreeze_count > 0) {
-		bdev->bd_fsfreeze_count++;
-		sb = get_super(bdev);
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return sb;
-	}
-	bdev->bd_fsfreeze_count++;
-
-	down(&bdev->bd_mount_sem);
-	sb = get_super(bdev);
-	if (sb && !(sb->s_flags & MS_RDONLY)) {
-		sb->s_frozen = SB_FREEZE_WRITE;
-		smp_wmb();
-
-		__fsync_super(sb);
-
-		sb->s_frozen = SB_FREEZE_TRANS;
-		smp_wmb();
-
-		sync_blockdev(sb->s_bdev);
-
-		if (sb->s_op->freeze_fs) {
-			error = sb->s_op->freeze_fs(sb);
-			if (error) {
-				printk(KERN_ERR
-					"VFS:Filesystem freeze failed\n");
-				sb->s_frozen = SB_UNFROZEN;
-				drop_super(sb);
-				up(&bdev->bd_mount_sem);
-				bdev->bd_fsfreeze_count--;
-				mutex_unlock(&bdev->bd_fsfreeze_mutex);
-				return ERR_PTR(error);
-			}
-		}
-	}
-
-	sync_blockdev(bdev);
-	mutex_unlock(&bdev->bd_fsfreeze_mutex);
-
-	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
-}
-EXPORT_SYMBOL(freeze_bdev);
-
-/**
- * thaw_bdev  -- unlock filesystem
- * @bdev:	blockdevice to unlock
- * @sb:		associated superblock
- *
- * Unlocks the filesystem and marks it writeable again after freeze_bdev().
- */
-int thaw_bdev(struct block_device *bdev, struct super_block *sb)
-{
-	int error = 0;
-
-	mutex_lock(&bdev->bd_fsfreeze_mutex);
-	if (!bdev->bd_fsfreeze_count) {
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return -EINVAL;
-	}
-
-	bdev->bd_fsfreeze_count--;
-	if (bdev->bd_fsfreeze_count > 0) {
-		if (sb)
-			drop_super(sb);
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return 0;
-	}
-
-	if (sb) {
-		BUG_ON(sb->s_bdev != bdev);
-		if (!(sb->s_flags & MS_RDONLY)) {
-			if (sb->s_op->unfreeze_fs) {
-				error = sb->s_op->unfreeze_fs(sb);
-				if (error) {
-					printk(KERN_ERR
-						"VFS:Filesystem thaw failed\n");
-					sb->s_frozen = SB_FREEZE_TRANS;
-					bdev->bd_fsfreeze_count++;
-					mutex_unlock(&bdev->bd_fsfreeze_mutex);
-					return error;
-				}
-			}
-			sb->s_frozen = SB_UNFROZEN;
-			smp_wmb();
-			wake_up(&sb->s_wait_unfrozen);
-		}
-		drop_super(sb);
-	}
-
-	up(&bdev->bd_mount_sem);
-	mutex_unlock(&bdev->bd_fsfreeze_mutex);
-	return 0;
-}
-EXPORT_SYMBOL(thaw_bdev);
-
-/*
  * Various filesystems appear to want __find_get_block to be non-blocking.
  * But it's the page lock which protects the buffers.  To get around this,
  * we get exclusion from try_to_free_buffers with the blockdev mapping's
@@ -599,7 +454,7 @@ EXPORT_SYMBOL(mark_buffer_async_write);
  * written back and waited upon before fsync() returns.
  *
  * The functions mark_buffer_inode_dirty(), fsync_inode_buffers(),
- * inode_has_buffers() and invalidate_inode_buffers() are provided for the
+ * mapping_has_private() and invalidate_inode_buffers() are provided for the
  * management of a list of dependent buffers at ->i_mapping->private_list.
  *
  * Locking is a little subtle: try_to_free_buffers() will remove buffers
@@ -652,11 +507,6 @@ static void __remove_assoc_queue(struct
 	bh->b_assoc_map = NULL;
 }
 
-int inode_has_buffers(struct inode *inode)
-{
-	return !list_empty(&inode->i_data.private_list);
-}
-
 /*
  * osync is designed to support O_SYNC io.  It waits synchronously for
  * all already-submitted IO to complete, but does not queue any new
@@ -932,8 +782,9 @@ static int fsync_buffers_list(spinlock_t
  */
 void invalidate_inode_buffers(struct inode *inode)
 {
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	struct address_space *mapping = &inode->i_data;
+
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
@@ -953,10 +804,10 @@ EXPORT_SYMBOL(invalidate_inode_buffers);
  */
 int remove_inode_buffers(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
 	int ret = 1;
 
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
@@ -1715,6 +1566,7 @@ static int __block_write_full_page(struc
 	struct buffer_head *bh, *head;
 	const unsigned blocksize = 1 << inode->i_blkbits;
 	int nr_underway = 0;
+	int clean_page = 1;
 
 	BUG_ON(!PageLocked(page));
 
@@ -1725,6 +1577,8 @@ static int __block_write_full_page(struc
 					(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
 
+	clean_page_prepare(page);
+
 	/*
 	 * Be very careful.  We have no exclusion from __set_page_dirty_buffers
 	 * here, and the (potentially unmapped) buffers may become dirty at
@@ -1786,7 +1640,7 @@ static int __block_write_full_page(struc
 		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
-			redirty_page_for_writepage(wbc, page);
+			clean_page = 0;
 			continue;
 		}
 		if (test_clear_buffer_dirty(bh)) {
@@ -1800,6 +1654,8 @@ static int __block_write_full_page(struc
 	 * The page and its buffers are protected by PageWriteback(), so we can
 	 * drop the bh refcounts early.
 	 */
+	if (clean_page)
+		clear_page_dirty(page);
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
 
@@ -2475,11 +2331,17 @@ block_page_mkwrite(struct vm_area_struct
 	int ret = -EINVAL;
 
 	lock_page(page);
+	if (!page->mapping) {
+		ret = 0;
+		goto out;
+	}
+
+	BUG_ON(page->mapping != inode->i_mapping);
+
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
-	    (page_offset(page) > size)) {
+	if (page_offset(page) > size) {
 		/* page got truncated out from underneath us */
-		goto out_unlock;
+		goto out;
 	}
 
 	/* page is wholly or partially inside EOF */
@@ -2492,8 +2354,7 @@ block_page_mkwrite(struct vm_area_struct
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
-out_unlock:
-	unlock_page(page);
+out:
 	return ret;
 }
 
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -158,22 +158,14 @@ void end_buffer_write_sync(struct buffer
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
-int inode_has_buffers(struct inode *);
 void invalidate_inode_buffers(struct inode *);
 int remove_inode_buffers(struct inode *inode);
 int sync_mapping_buffers(struct address_space *mapping);
 void unmap_underlying_metadata(struct block_device *bdev, sector_t block);
 
 void mark_buffer_async_write(struct buffer_head *bh);
-void invalidate_bdev(struct block_device *);
-int sync_blockdev(struct block_device *bdev);
 void __wait_on_buffer(struct buffer_head *);
 wait_queue_head_t *bh_waitq_head(struct buffer_head *bh);
-int fsync_bdev(struct block_device *);
-struct super_block *freeze_bdev(struct block_device *);
-int thaw_bdev(struct block_device *, struct super_block *);
-int fsync_super(struct super_block *);
-int fsync_no_super(struct block_device *);
 struct buffer_head *__find_get_block(struct block_device *bdev, sector_t block,
 			unsigned size);
 struct buffer_head *__getblk(struct block_device *bdev, sector_t block,
@@ -340,7 +332,6 @@ extern int __set_page_dirty_buffers(stru
 static inline void buffer_init(void) {}
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int sync_blockdev(struct block_device *bdev) { return 0; }
-static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -531,6 +531,20 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+
+	/*
+	 * release_mapping releases any private data on the mapping so that
+	 * it may be reclaimed. Returns 1 on success or 0 on failure. Second
+	 * parameter 'force' causes dirty data to be invalidated. (XXX: could
+	 * have other flags like sync/async, etc).
+	 */
+	int (*release)(struct address_space *, int);
+
+	/*
+	 * sync writes back and waits for any private data on the mapping,
+	 * as a data consistency operation.
+	 */
+	int (*sync)(struct address_space *);
 };
 
 /*
@@ -616,6 +630,14 @@ struct block_device {
 int mapping_tagged(struct address_space *mapping, int tag);
 
 /*
+ * Does this mapping have anything on its private list?
+ */
+static inline int mapping_has_private(struct address_space *mapping)
+{
+	return !list_empty(&mapping->private_list);
+}
+
+/*
  * Might pages of this file be mapped into userspace?
  */
 static inline int mapping_mapped(struct address_space *mapping)
@@ -1730,6 +1752,13 @@ extern void bd_set_size(struct block_dev
 extern void bd_forget(struct inode *inode);
 extern void bdput(struct block_device *);
 extern struct block_device *open_by_devnum(dev_t, fmode_t);
+extern void invalidate_bdev(struct block_device *);
+extern int sync_blockdev(struct block_device *bdev);
+extern struct super_block *freeze_bdev(struct block_device *);
+extern int thaw_bdev(struct block_device *bdev, struct super_block *sb);
+extern int fsync_bdev(struct block_device *);
+extern int fsync_super(struct super_block *);
+extern int fsync_no_super(struct block_device *);
 #else
 static inline void bd_forget(struct inode *inode) {}
 #endif
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/blkpg.h>
 #include <linux/buffer_head.h>
+#include <linux/pagevec.h>
 #include <linux/writeback.h>
 #include <linux/mpage.h>
 #include <linux/mount.h>
@@ -71,7 +72,7 @@ static void kill_bdev(struct block_devic
 int set_blocksize(struct block_device *bdev, int size)
 {
 	/* Size must be a power of two, and between 512 and PAGE_SIZE */
-	if (size > PAGE_SIZE || size < 512 || !is_power_of_2(size))
+	if (size < 512 || !is_power_of_2(size))
 		return -EINVAL;
 
 	/* Size cannot be smaller than the size supported by the device */
@@ -87,7 +88,6 @@ int set_blocksize(struct block_device *b
 	}
 	return 0;
 }
-
 EXPORT_SYMBOL(set_blocksize);
 
 int sb_set_blocksize(struct super_block *sb, int size)
@@ -174,6 +174,151 @@ blkdev_direct_IO(int rw, struct kiocb *i
 				iov, offset, nr_segs, blkdev_get_blocks, NULL);
 }
 
+/*
+ * Write out and wait upon all the dirty data associated with a block
+ * device via its mapping.  Does not take the superblock lock.
+ */
+int sync_blockdev(struct block_device *bdev)
+{
+	int ret = 0;
+
+	if (bdev)
+		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
+	return ret;
+}
+EXPORT_SYMBOL(sync_blockdev);
+
+/*
+ * Write out and wait upon all dirty data associated with this
+ * device.   Filesystem data as well as the underlying block
+ * device.  Takes the superblock lock.
+ */
+int fsync_bdev(struct block_device *bdev)
+{
+	struct super_block *sb = get_super(bdev);
+	if (sb) {
+		int res = fsync_super(sb);
+		drop_super(sb);
+		return res;
+	}
+	return sync_blockdev(bdev);
+}
+
+/**
+ * freeze_bdev  --  lock a filesystem and force it into a consistent state
+ * @bdev:	blockdevice to lock
+ *
+ * This takes the block device bd_mount_sem to make sure no new mounts
+ * happen on bdev until thaw_bdev() is called.
+ * If a superblock is found on this device, we take the s_umount semaphore
+ * on it to make sure nobody unmounts until the snapshot creation is done.
+ * The reference counter (bd_fsfreeze_count) guarantees that only the last
+ * unfreeze process can unfreeze the frozen filesystem actually when multiple
+ * freeze requests arrive simultaneously. It counts up in freeze_bdev() and
+ * count down in thaw_bdev(). When it becomes 0, thaw_bdev() will unfreeze
+ * actually.
+ */
+struct super_block *freeze_bdev(struct block_device *bdev)
+{
+	struct super_block *sb;
+	int error = 0;
+
+	mutex_lock(&bdev->bd_fsfreeze_mutex);
+	if (bdev->bd_fsfreeze_count > 0) {
+		bdev->bd_fsfreeze_count++;
+		sb = get_super(bdev);
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return sb;
+	}
+	bdev->bd_fsfreeze_count++;
+
+	down(&bdev->bd_mount_sem);
+	sb = get_super(bdev);
+	if (sb && !(sb->s_flags & MS_RDONLY)) {
+		sb->s_frozen = SB_FREEZE_WRITE;
+		smp_wmb();
+
+		__fsync_super(sb);
+
+		sb->s_frozen = SB_FREEZE_TRANS;
+		smp_wmb();
+
+		sync_blockdev(sb->s_bdev);
+
+		if (sb->s_op->freeze_fs) {
+			error = sb->s_op->freeze_fs(sb);
+			if (error) {
+				printk(KERN_ERR
+					"VFS:Filesystem freeze failed\n");
+				sb->s_frozen = SB_UNFROZEN;
+				drop_super(sb);
+				up(&bdev->bd_mount_sem);
+				bdev->bd_fsfreeze_count--;
+				mutex_unlock(&bdev->bd_fsfreeze_mutex);
+				return ERR_PTR(error);
+			}
+		}
+	}
+
+	sync_blockdev(bdev);
+	mutex_unlock(&bdev->bd_fsfreeze_mutex);
+
+	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
+}
+EXPORT_SYMBOL(freeze_bdev);
+
+/**
+ * thaw_bdev  -- unlock filesystem
+ * @bdev:	blockdevice to unlock
+ * @sb:		associated superblock
+ *
+ * Unlocks the filesystem and marks it writeable again after freeze_bdev().
+ */
+int thaw_bdev(struct block_device *bdev, struct super_block *sb)
+{
+	int error = 0;
+
+	mutex_lock(&bdev->bd_fsfreeze_mutex);
+	if (!bdev->bd_fsfreeze_count) {
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return -EINVAL;
+	}
+
+	bdev->bd_fsfreeze_count--;
+	if (bdev->bd_fsfreeze_count > 0) {
+		if (sb)
+			drop_super(sb);
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return 0;
+	}
+
+	if (sb) {
+		BUG_ON(sb->s_bdev != bdev);
+		if (!(sb->s_flags & MS_RDONLY)) {
+			if (sb->s_op->unfreeze_fs) {
+				error = sb->s_op->unfreeze_fs(sb);
+				if (error) {
+					printk(KERN_ERR
+						"VFS:Filesystem thaw failed\n");
+					sb->s_frozen = SB_FREEZE_TRANS;
+					bdev->bd_fsfreeze_count++;
+					mutex_unlock(&bdev->bd_fsfreeze_mutex);
+					return error;
+				}
+			}
+			sb->s_frozen = SB_UNFROZEN;
+			smp_wmb();
+			wake_up(&sb->s_wait_unfrozen);
+		}
+		drop_super(sb);
+	}
+
+	up(&bdev->bd_mount_sem);
+	mutex_unlock(&bdev->bd_fsfreeze_mutex);
+	return 0;
+}
+EXPORT_SYMBOL(thaw_bdev);
+
 static int blkdev_writepage(struct page *page, struct writeback_control *wbc)
 {
 	return block_write_full_page(page, blkdev_get_block, wbc);
@@ -206,6 +351,11 @@ static int blkdev_write_end(struct file
 	return ret;
 }
 
+static void blkdev_invalidate_page(struct page *page, unsigned long offset)
+{
+	block_invalidatepage(page, offset);
+}
+
 /*
  * private llseek:
  * for a block special file file->f_path.dentry->d_inode->i_size is zero
@@ -1259,6 +1409,8 @@ static const struct address_space_operat
 	.writepages	= generic_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
+	.set_page_dirty	= __set_page_dirty_buffers,
+	.invalidatepage = blkdev_invalidate_page,
 };
 
 const struct file_operations def_blk_fops = {
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1960,9 +1960,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
+			if (!pte_same(*page_table, orig_pte)) {
+				page_cache_release(old_page);
+				unlock_page(old_page);
 				goto unlock;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -2085,16 +2087,30 @@ unlock:
 		 *
 		 * do_no_page is protected similarly.
 		 */
-		wait_on_page_locked(dirty_page);
-		set_page_dirty_balance(dirty_page, page_mkwrite);
+		if (!page_mkwrite) {
+			wait_on_page_locked(dirty_page);
+			set_page_dirty_balance(dirty_page, page_mkwrite);
+		}
 		put_page(dirty_page);
+		if (page_mkwrite) {
+			struct address_space *mapping = old_page->mapping;
+
+			unlock_page(old_page);
+			page_cache_release(old_page);
+			balance_dirty_pages_ratelimited(mapping);
+		}
 	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
-	if (old_page)
+	if (old_page) {
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 		page_cache_release(old_page);
+	}
 	return VM_FAULT_OOM;
 
 unwritable_page:
@@ -2647,19 +2663,6 @@ static int __do_fault(struct mm_struct *
 				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
 					ret = VM_FAULT_SIGBUS;
 					anon = 1; /* no anon but release vmf.page */
-					goto out_unlocked;
-				}
-				lock_page(page);
-				/*
-				 * XXX: this is not quite right (racy vs
-				 * invalidate) to unlock and relock the page
-				 * like this, however a better fix requires
-				 * reworking page_mkwrite locking API, which
-				 * is better done later.
-				 */
-				if (!page->mapping) {
-					ret = 0;
-					anon = 1; /* no anon but release vmf.page */
 					goto out;
 				}
 				page_mkwrite = 1;
@@ -2713,16 +2716,23 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(vmf.page);
-out_unlocked:
-	if (anon)
-		page_cache_release(vmf.page);
-	else if (dirty_page) {
+	if (dirty_page) {
+		struct address_space *mapping = page->mapping;
+
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
 
+		if (set_page_dirty(dirty_page))
+			page_mkwrite = 1;
 		set_page_dirty_balance(dirty_page, page_mkwrite);
+		unlock_page(dirty_page);
 		put_page(dirty_page);
+		if (page_mkwrite)
+			balance_dirty_pages_ratelimited(mapping);
+	} else {
+		unlock_page(vmf.page);
+		if (anon)
+			page_cache_release(vmf.page);
 	}
 
 	return ret;
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -486,7 +486,7 @@ static int writeout(struct address_space
 		/* No write method for the address space */
 		return -EINVAL;
 
-	if (!clear_page_dirty_for_io(page))
+	if (!PageDirty(page))
 		/* Someone else already triggered a write */
 		return -EAGAIN;
 
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -1028,8 +1028,6 @@ continue_unlock:
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
-				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
@@ -1171,7 +1169,7 @@ int write_one_page(struct page *page, in
 	if (wait)
 		wait_on_page_writeback(page);
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		page_cache_get(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
@@ -1254,6 +1252,8 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers
  */
 int redirty_page_for_writepage(struct writeback_control *wbc, struct page *page)
 {
+	printk("redirty!\n");
+	dump_stack();
 	wbc->pages_skipped++;
 	return __set_page_dirty_nobuffers(page);
 }
@@ -1304,6 +1304,35 @@ int set_page_dirty_lock(struct page *pag
 }
 EXPORT_SYMBOL(set_page_dirty_lock);
 
+void clean_page_prepare(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	BUG_ON(!mapping);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+
+	if (mapping_cap_account_dirty(page->mapping)) {
+		if (page_mkclean(page))
+			set_page_dirty(page);
+	}
+}
+
+void clear_page_dirty(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	BUG_ON(!mapping);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+
+	ClearPageDirty(page);
+	if (mapping_cap_account_dirty(page->mapping)) {
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+	}
+}
+
 /*
  * Clear a page's dirty flag, while caring for dirty memory accounting.
  * Returns true if the page was previously dirty.
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -374,7 +374,7 @@ static pageout_t pageout(struct page *pa
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		int res;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
@@ -452,7 +452,7 @@ xfs_start_page_writeback(
 	ASSERT(PageLocked(page));
 	ASSERT(!PageWriteback(page));
 	if (clear_dirty)
-		clear_page_dirty_for_io(page);
+		clear_page_dirty(page);
 	set_page_writeback(page);
 	unlock_page(page);
 	/* If no buffers on the page are to be written, finish it here */
@@ -1230,6 +1230,7 @@ xfs_vm_writepage(
 
 	xfs_page_trace(XFS_WRITEPAGE_ENTER, inode, page, 0);
 
+	clean_page_prepare(page);
 	/*
 	 * We need a transaction if:
 	 *  1. There are delalloc buffers on the page
@@ -1277,9 +1278,7 @@ xfs_vm_writepage(
 	return 0;
 
 out_fail:
-	redirty_page_for_writepage(wbc, page);
-	unlock_page(page);
-	return 0;
+	error = 0;
 out_unlock:
 	unlock_page(page);
 	return error;
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -836,6 +836,8 @@ int redirty_page_for_writepage(struct wr
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+void clean_page_prepare(struct page *page);
+void clear_page_dirty(struct page *page);
 
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c
+++ linux-2.6/fs/mpage.c
@@ -463,6 +463,8 @@ int __mpage_writepage(struct page *page,
 	loff_t i_size = i_size_read(inode);
 	int ret = 0;
 
+	clean_page_prepare(page);
+
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
 		struct buffer_head *bh = head;
@@ -616,6 +618,7 @@ alloc_new:
 			try_to_free_buffers(page);
 	}
 
+	clear_page_dirty(page);
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
 	unlock_page(page);
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -782,9 +782,15 @@ int generic_osync_inode(struct inode *in
 	if (what & OSYNC_DATA)
 		err = filemap_fdatawrite(mapping);
 	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
-		err2 = sync_mapping_buffers(mapping);
-		if (!err)
-			err = err2;
+		if (!mapping->a_ops->sync) {
+			err2 = sync_mapping_buffers(mapping);
+			if (!err)
+				err = err2;
+		} else {
+			err2 = mapping->a_ops->sync(mapping);
+			if (!err)
+				err = err2;
+		}
 	}
 	if (what & OSYNC_DATA) {
 		err2 = filemap_fdatawait(mapping);
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -208,7 +208,8 @@ static struct inode *alloc_inode(struct
 
 void destroy_inode(struct inode *inode) 
 {
-	BUG_ON(inode_has_buffers(inode));
+	BUG_ON(mapping_has_private(&inode->i_data));
+	BUG_ON(inode->i_data.nrpages);
 	security_inode_free(inode);
 	if (inode->i_sb->s_op->destroy_inode)
 		inode->i_sb->s_op->destroy_inode(inode);
@@ -277,10 +278,14 @@ void __iget(struct inode * inode)
  */
 void clear_inode(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	might_sleep();
-	invalidate_inode_buffers(inode);
+	if (!mapping->a_ops->release)
+		invalidate_inode_buffers(inode);
        
-	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(mapping_has_private(mapping));
+	BUG_ON(mapping->nrpages);
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
 	inode_sync_wait(inode);
@@ -343,6 +348,7 @@ static int invalidate_list(struct list_h
 	for (;;) {
 		struct list_head * tmp = next;
 		struct inode * inode;
+		struct address_space * mapping;
 
 		/*
 		 * We can reschedule here without worrying about the list's
@@ -356,7 +362,12 @@ static int invalidate_list(struct list_h
 		if (tmp == head)
 			break;
 		inode = list_entry(tmp, struct inode, i_sb_list);
-		invalidate_inode_buffers(inode);
+		mapping = &inode->i_data;
+		if (!mapping->a_ops->release)
+			invalidate_inode_buffers(inode);
+		else
+			mapping->a_ops->release(mapping, 1); /* XXX: should be done in fs? */
+		BUG_ON(mapping_has_private(mapping));
 		if (!atomic_read(&inode->i_count)) {
 			list_move(&inode->i_list, dispose);
 			inode->i_state |= I_FREEING;
@@ -399,13 +410,15 @@ EXPORT_SYMBOL(invalidate_inodes);
 
 static int can_unuse(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	if (inode->i_state)
 		return 0;
-	if (inode_has_buffers(inode))
+	if (mapping_has_private(mapping))
 		return 0;
 	if (atomic_read(&inode->i_count))
 		return 0;
-	if (inode->i_data.nrpages)
+	if (mapping->nrpages)
 		return 0;
 	return 1;
 }
@@ -434,6 +447,7 @@ static void prune_icache(int nr_to_scan)
 	spin_lock(&inode_lock);
 	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
 		struct inode *inode;
+		struct address_space *mapping;
 
 		if (list_empty(&inode_unused))
 			break;
@@ -444,10 +458,17 @@ static void prune_icache(int nr_to_scan)
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
-		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		mapping = &inode->i_data;
+		if (mapping_has_private(mapping) || mapping->nrpages) {
+			int ret;
+
 			__iget(inode);
 			spin_unlock(&inode_lock);
-			if (remove_inode_buffers(inode))
+			if (mapping->a_ops->release)
+				ret = mapping->a_ops->release(mapping, 0);
+			else
+				ret = remove_inode_buffers(inode);
+			if (ret)
 				reap += invalidate_mapping_pages(&inode->i_data,
 								0, -1);
 			iput(inode);
Index: linux-2.6/fs/super.c
===================================================================
--- linux-2.6.orig/fs/super.c
+++ linux-2.6/fs/super.c
@@ -28,7 +28,7 @@
 #include <linux/blkdev.h>
 #include <linux/quotaops.h>
 #include <linux/namei.h>
-#include <linux/buffer_head.h>		/* for fsync_super() */
+#include <linux/fs.h>			/* for fsync_super() */
 #include <linux/mount.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
@@ -38,6 +38,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/buffer_head.h>		/* sync_blockdev */
 #include <linux/async.h>
 #include <asm/uaccess.h>
 #include "internal.h"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
