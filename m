Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 78F896B0073
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 11:31:19 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so9511240pbc.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 08:31:19 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 3/3] ARM: mm: use static_vm for managing static mapped areas
Date: Wed, 28 Nov 2012 01:28:50 +0900
Message-Id: <1354033730-850-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1354033730-850-1-git-send-email-js1304@gmail.com>
References: <1354033730-850-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>

A static mapped area is ARM-specific, so it is better not to use
generic vmalloc data structure, that is, vmlist and vmlist_lock
for managing static mapped area. And it causes some needless overhead and
reducing this overhead is better idea.

Now, we have newly introduced static_vm infrastructure.
With it, we don't need to iterate all mapped areas. Instead, we just
iterate static mapped areas. It helps to reduce an overhead of finding
matched area. And architecture dependency on vmalloc layer is removed,
so it will help to maintainability for vmalloc layer.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/arch/arm/include/asm/mach/static_vm.h b/arch/arm/include/asm/mach/static_vm.h
index 1bb6604..0d9c685 100644
--- a/arch/arm/include/asm/mach/static_vm.h
+++ b/arch/arm/include/asm/mach/static_vm.h
@@ -32,6 +32,12 @@ struct static_vm {
 	const void		*caller;
 };
 
+#define STATIC_VM_MEM		0x00000001
+#define STATIC_VM_EMPTY		0x00000002
+
+/* mtype should be less than 28 */
+#define STATIC_VM_MTYPE(mt)	(1UL << ((mt) + 4))
+
 extern struct static_vm *static_vmlist;
 extern spinlock_t static_vmlist_lock;
 
diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index 5dcc2fd..b7f3c27 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -36,6 +36,7 @@
 #include <asm/system_info.h>
 
 #include <asm/mach/map.h>
+#include <asm/mach/static_vm.h>
 #include <asm/mach/pci.h>
 #include "mm.h"
 
@@ -197,7 +198,8 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 	const struct mem_type *type;
 	int err;
 	unsigned long addr;
- 	struct vm_struct * area;
+	struct vm_struct *area;
+	phys_addr_t paddr = __pfn_to_phys(pfn);
 
 #ifndef CONFIG_ARM_LPAE
 	/*
@@ -219,24 +221,17 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
 	/*
 	 * Try to reuse one of the static mapping whenever possible.
 	 */
-	read_lock(&vmlist_lock);
-	for (area = vmlist; area; area = area->next) {
-		if (!size || (sizeof(phys_addr_t) == 4 && pfn >= 0x100000))
-			break;
-		if (!(area->flags & VM_ARM_STATIC_MAPPING))
-			continue;
-		if ((area->flags & VM_ARM_MTYPE_MASK) != VM_ARM_MTYPE(mtype))
-			continue;
-		if (__phys_to_pfn(area->phys_addr) > pfn ||
-		    __pfn_to_phys(pfn) + size-1 > area->phys_addr + area->size-1)
-			continue;
-		/* we can drop the lock here as we know *area is static */
-		read_unlock(&vmlist_lock);
-		addr = (unsigned long)area->addr;
-		addr += __pfn_to_phys(pfn) - area->phys_addr;
-		return (void __iomem *) (offset + addr);
+	if (size && !((sizeof(phys_addr_t) == 4 && pfn >= 0x100000))) {
+		struct static_vm *static_vm;
+
+		static_vm = find_static_vm_paddr(__pfn_to_phys(pfn), size,
+				STATIC_VM_MEM | STATIC_VM_MTYPE(mtype));
+		if (static_vm) {
+			addr = (unsigned long)static_vm->vaddr;
+			addr += paddr - static_vm->paddr;
+			return (void __iomem *) (offset + addr);
+		}
 	}
-	read_unlock(&vmlist_lock);
 
 	/*
 	 * Don't allow RAM to be mapped - this causes problems with ARMv6+
@@ -248,7 +243,7 @@ void __iomem * __arm_ioremap_pfn_caller(unsigned long pfn,
  	if (!area)
  		return NULL;
  	addr = (unsigned long)area->addr;
-	area->phys_addr = __pfn_to_phys(pfn);
+	area->phys_addr = paddr;
 
 #if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
 	if (DOMAIN_IO == 0 &&
@@ -346,34 +341,20 @@ __arm_ioremap_exec(unsigned long phys_addr, size_t size, bool cached)
 void __iounmap(volatile void __iomem *io_addr)
 {
 	void *addr = (void *)(PAGE_MASK & (unsigned long)io_addr);
-	struct vm_struct *vm;
-
-	read_lock(&vmlist_lock);
-	for (vm = vmlist; vm; vm = vm->next) {
-		if (vm->addr > addr)
-			break;
-		if (!(vm->flags & VM_IOREMAP))
-			continue;
-		/* If this is a static mapping we must leave it alone */
-		if ((vm->flags & VM_ARM_STATIC_MAPPING) &&
-		    (vm->addr <= addr) && (vm->addr + vm->size > addr)) {
-			read_unlock(&vmlist_lock);
-			return;
-		}
+	struct static_vm *static_vm;
+
+	static_vm = find_static_vm_vaddr(addr, STATIC_VM_MEM);
+	if (static_vm)
+		return;
+
 #if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
-		/*
-		 * If this is a section based mapping we need to handle it
-		 * specially as the VM subsystem does not know how to handle
-		 * such a beast.
-		 */
-		if ((vm->addr == addr) &&
-		    (vm->flags & VM_ARM_SECTION_MAPPING)) {
+	{
+		struct vm_struct *vm;
+		vm = find_vm_area(addr);
+		if (vm && (vm->flags & VM_ARM_SECTION_MAPPING))
 			unmap_area_sections((unsigned long)vm->addr, vm->size);
-			break;
-		}
-#endif
 	}
-	read_unlock(&vmlist_lock);
+#endif
 
 	vunmap(addr);
 }
diff --git a/arch/arm/mm/mm.h b/arch/arm/mm/mm.h
index a8ee92d..3ae75e5 100644
--- a/arch/arm/mm/mm.h
+++ b/arch/arm/mm/mm.h
@@ -52,16 +52,6 @@ extern void __flush_dcache_page(struct address_space *mapping, struct page *page
 /* (super)section-mapped I/O regions used by ioremap()/iounmap() */
 #define VM_ARM_SECTION_MAPPING	0x80000000
 
-/* permanent static mappings from iotable_init() */
-#define VM_ARM_STATIC_MAPPING	0x40000000
-
-/* empty mapping */
-#define VM_ARM_EMPTY_MAPPING	0x20000000
-
-/* mapping type (attributes) for permanent static mappings */
-#define VM_ARM_MTYPE(mt)		((mt) << 20)
-#define VM_ARM_MTYPE_MASK	(0x1f << 20)
-
 /* consistent regions used by dma_alloc_attrs() */
 #define VM_ARM_DMA_CONSISTENT	0x20000000
 
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 941dfb9..6c154c1 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -31,6 +31,7 @@
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
+#include <asm/mach/static_vm.h>
 #include <asm/mach/pci.h>
 
 #include "mm.h"
@@ -757,21 +758,28 @@ void __init iotable_init(struct map_desc *io_desc, int nr)
 {
 	struct map_desc *md;
 	struct vm_struct *vm;
+	struct static_vm *static_vm;
 
 	if (!nr)
 		return;
 
 	vm = early_alloc_aligned(sizeof(*vm) * nr, __alignof__(*vm));
+	static_vm = early_alloc_aligned(sizeof(*static_vm) * nr,
+						__alignof__(*static_vm));
 
 	for (md = io_desc; nr; md++, nr--) {
 		create_mapping(md);
+
 		vm->addr = (void *)(md->virtual & PAGE_MASK);
 		vm->size = PAGE_ALIGN(md->length + (md->virtual & ~PAGE_MASK));
 		vm->phys_addr = __pfn_to_phys(md->pfn);
-		vm->flags = VM_IOREMAP | VM_ARM_STATIC_MAPPING;
-		vm->flags |= VM_ARM_MTYPE(md->type);
+		vm->flags = VM_IOREMAP;
 		vm->caller = iotable_init;
+
+		init_static_vm(static_vm, vm, STATIC_VM_MEM |
+						STATIC_VM_MTYPE(md->type));
 		vm_area_add_early(vm++);
+		insert_static_vm(static_vm++);
 	}
 }
 
@@ -779,13 +787,20 @@ void __init vm_reserve_area_early(unsigned long addr, unsigned long size,
 				  void *caller)
 {
 	struct vm_struct *vm;
+	struct static_vm *static_vm;
 
 	vm = early_alloc_aligned(sizeof(*vm), __alignof__(*vm));
+	static_vm = early_alloc_aligned(sizeof(*static_vm),
+					__alignof__(*static_vm));
+
 	vm->addr = (void *)addr;
 	vm->size = size;
-	vm->flags = VM_IOREMAP | VM_ARM_EMPTY_MAPPING;
+	vm->flags = VM_IOREMAP;
 	vm->caller = caller;
+
+	init_static_vm(static_vm, vm, STATIC_VM_EMPTY);
 	vm_area_add_early(vm);
+	insert_static_vm(static_vm);
 }
 
 #ifndef CONFIG_ARM_LPAE
@@ -810,15 +825,19 @@ static void __init pmd_empty_section_gap(unsigned long addr)
 
 static void __init fill_pmd_gaps(void)
 {
-	struct vm_struct *vm;
+	struct static_vm *area;
 	unsigned long addr, next = 0;
 	pmd_t *pmd;
 
-	/* we're still single threaded hence no lock needed here */
-	for (vm = vmlist; vm; vm = vm->next) {
-		if (!(vm->flags & (VM_ARM_STATIC_MAPPING | VM_ARM_EMPTY_MAPPING)))
-			continue;
-		addr = (unsigned long)vm->addr;
+	/*
+	 * We should not take a lock here, because pmd_empty_section_gap()
+	 * invokes vm_reserve_area_early(), and then it call insert_static_vm()
+	 * which try to take a lock.
+	 * We're still single thread, so traverse whole list without a lock
+	 * is safe for now. And inserting new entry is also safe.
+	 */
+	for (area = static_vmlist; area; area = area->next) {
+		addr = (unsigned long)area->vaddr;
 		if (addr < next)
 			continue;
 
@@ -838,7 +857,7 @@ static void __init fill_pmd_gaps(void)
 		 * If so and the second section entry for this PMD is empty
 		 * then we block the corresponding virtual address.
 		 */
-		addr += vm->size;
+		addr += area->size;
 		if ((addr & ~PMD_MASK) == SECTION_SIZE) {
 			pmd = pmd_off_k(addr) + 1;
 			if (pmd_none(*pmd))
@@ -857,19 +876,13 @@ static void __init fill_pmd_gaps(void)
 #if defined(CONFIG_PCI) && !defined(CONFIG_NEED_MACH_IO_H)
 static void __init pci_reserve_io(void)
 {
-	struct vm_struct *vm;
-	unsigned long addr;
+	struct static_vm *static_vm;
 
-	/* we're still single threaded hence no lock needed here */
-	for (vm = vmlist; vm; vm = vm->next) {
-		if (!(vm->flags & VM_ARM_STATIC_MAPPING))
-			continue;
-		addr = (unsigned long)vm->addr;
-		addr &= ~(SZ_2M - 1);
-		if (addr == PCI_IO_VIRT_BASE)
-			return;
+	static_vm = find_static_vm_vaddr((void *)PCI_IO_VIRT_BASE,
+						STATIC_VM_MEM);
+	if (static_vm)
+		return;
 
-	}
 	vm_reserve_area_early(PCI_IO_VIRT_BASE, SZ_2M, pci_reserve_io);
 }
 #else
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
