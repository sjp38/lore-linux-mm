Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Roman Gushchin <guroan@gmail.com>
Subject: [RFC 3/4] mm: allocate vmalloc metadata in one allocation
Date: Fri, 14 Dec 2018 10:07:19 -0800
Message-Id: <20181214180720.32040-4-guro@fb.com>
In-Reply-To: <20181214180720.32040-1-guro@fb.com>
References: <20181214180720.32040-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>
List-ID: <linux-mm.kvack.org>

Currently any vmalloc() call leads to at least 3 metadata allocations:
1) struct vm_struct
2) struct vm_area
3) struct vm_struct->pages array

Especially for small allocations (e.g. 4 pages for kernel stacks,
which seems to be one of the main vmalloc() usages these days),
it creates some measurable overhead.

vm_struct->pages array has almost the same lifetime as vm_struct,
and vm_area has a similar, but is freed lazily. So, it's perfectly
possible to squeeze all 3 allocations into one:
  [ struct vm_struct | struct vm_area | pages array ]

This also slightly simplifies freeing and error handling paths
(e.g. fewer ENOMEM handling points).

On my setup it saves up to 4% cpu on allocation of 1000000 4-pages
areas.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/mips/mm/ioremap.c      |   7 +--
 arch/nios2/mm/ioremap.c     |   4 +-
 arch/sh/kernel/cpu/sh4/sq.c |   5 +-
 arch/sh/mm/ioremap.c        |   8 +--
 arch/x86/mm/ioremap.c       |   4 +-
 include/linux/vmalloc.h     |   3 +-
 mm/vmalloc.c                | 113 +++++++++++++++++++++---------------
 7 files changed, 72 insertions(+), 72 deletions(-)

diff --git a/arch/mips/mm/ioremap.c b/arch/mips/mm/ioremap.c
index 1601d90b087b..22fa47217a52 100644
--- a/arch/mips/mm/ioremap.c
+++ b/arch/mips/mm/ioremap.c
@@ -190,16 +190,11 @@ void __iomem * __ioremap(phys_addr_t phys_addr, phys_addr_t size, unsigned long
 
 void __iounmap(const volatile void __iomem *addr)
 {
-	struct vm_struct *p;
-
 	if (IS_KSEG1(addr))
 		return;
 
-	p = remove_vm_area((void *) (PAGE_MASK & (unsigned long __force) addr));
-	if (!p)
+	if (remove_vm_area((void *) (PAGE_MASK & (unsigned long __force) addr)))
 		printk(KERN_ERR "iounmap: bad address %p\n", addr);
-
-	kfree(p);
 }
 
 EXPORT_SYMBOL(__ioremap);
diff --git a/arch/nios2/mm/ioremap.c b/arch/nios2/mm/ioremap.c
index 3a28177a01eb..0098494940ae 100644
--- a/arch/nios2/mm/ioremap.c
+++ b/arch/nios2/mm/ioremap.c
@@ -179,9 +179,7 @@ void __iounmap(void __iomem *addr)
 	if ((unsigned long) addr > CONFIG_NIOS2_IO_REGION_BASE)
 		return;
 
-	p = remove_vm_area((void *) (PAGE_MASK & (unsigned long __force) addr));
-	if (!p)
+	if (remove_vm_area((void *) (PAGE_MASK & (unsigned long __force) addr)))
 		pr_err("iounmap: bad address %p\n", addr);
-	kfree(p);
 }
 EXPORT_SYMBOL(__iounmap);
diff --git a/arch/sh/kernel/cpu/sh4/sq.c b/arch/sh/kernel/cpu/sh4/sq.c
index 4ca78ed71ad2..50be8449a52d 100644
--- a/arch/sh/kernel/cpu/sh4/sq.c
+++ b/arch/sh/kernel/cpu/sh4/sq.c
@@ -229,10 +229,7 @@ void sq_unmap(unsigned long vaddr)
 		/*
 		 * Tear down the VMA in the MMU case.
 		 */
-		struct vm_struct *vma;
-
-		vma = remove_vm_area((void *)(map->sq_addr & PAGE_MASK));
-		if (!vma) {
+		if (remove_vm_area((void *)(map->sq_addr & PAGE_MASK))) {
 			printk(KERN_ERR "%s: bad address 0x%08lx\n",
 			       __func__, map->sq_addr);
 			return;
diff --git a/arch/sh/mm/ioremap.c b/arch/sh/mm/ioremap.c
index d09ddfe58fd8..160853473afc 100644
--- a/arch/sh/mm/ioremap.c
+++ b/arch/sh/mm/ioremap.c
@@ -106,7 +106,6 @@ static inline int iomapping_nontranslatable(unsigned long offset)
 void __iounmap(void __iomem *addr)
 {
 	unsigned long vaddr = (unsigned long __force)addr;
-	struct vm_struct *p;
 
 	/*
 	 * Nothing to do if there is no translatable mapping.
@@ -126,12 +125,7 @@ void __iounmap(void __iomem *addr)
 	if (pmb_unmap(addr) == 0)
 		return;
 
-	p = remove_vm_area((void *)(vaddr & PAGE_MASK));
-	if (!p) {
+	if (remove_vm_area((void *)(vaddr & PAGE_MASK)))
 		printk(KERN_ERR "%s: bad address %p\n", __func__, addr);
-		return;
-	}
-
-	kfree(p);
 }
 EXPORT_SYMBOL(__iounmap);
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 5378d10f1d31..6fb570b8874a 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -433,9 +433,7 @@ void iounmap(volatile void __iomem *addr)
 	free_memtype(p->phys_addr, p->phys_addr + get_vm_area_size(p));
 
 	/* Finally remove it */
-	o = remove_vm_area((void __force *)addr);
-	BUG_ON(p != o || o == NULL);
-	kfree(p);
+	BUG_ON(remove_vm_area((void __force *)addr));
 }
 EXPORT_SYMBOL(iounmap);
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..1205f7a03b48 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,6 +21,7 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_EXT_PAGES		0x00000100	/* pages array is not embedded */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -132,7 +133,7 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					unsigned long flags,
 					unsigned long start, unsigned long end,
 					const void *caller);
-extern struct vm_struct *remove_vm_area(const void *addr);
+extern int remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 24c8ab28254d..edd76953c23c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1388,12 +1388,20 @@ static void clear_vm_uninitialized_flag(struct vm_struct *vm)
 	vm->flags &= ~VM_UNINITIALIZED;
 }
 
+static void *__vmalloc_node(unsigned long size, unsigned long align,
+			    gfp_t gfp_mask, pgprot_t prot,
+			    int node, const void *caller);
+
 static struct vm_struct *__get_vm_area_node(unsigned long size,
 		unsigned long align, unsigned long flags, unsigned long start,
 		unsigned long end, int node, gfp_t gfp_mask, const void *caller)
 {
 	struct vmap_area *va;
 	struct vm_struct *area;
+	size_t area_size = sizeof(struct vmap_area) + sizeof(struct vm_struct);
+	unsigned long nr_pages = 0;
+	unsigned long pages_size;
+	struct page **pages = NULL;
 
 	BUG_ON(in_interrupt());
 	size = PAGE_ALIGN(size);
@@ -1404,19 +1412,57 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		align = 1ul << clamp_t(int, get_count_order_long(size),
 				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
-	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
-	if (unlikely(!area))
+	if (flags & VM_UNINITIALIZED) {
+		nr_pages = size >> PAGE_SHIFT;
+		pages_size = nr_pages * sizeof(struct page *);
+
+		if (area_size + pages_size <= PAGE_SIZE) {
+			/* area->pages array can be embedded */
+			area_size += nr_pages * sizeof(struct page *);
+		} else {
+			/* area->pages array has to be allocated externally */
+			const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) |
+				__GFP_ZERO;
+			const gfp_t highmem_mask =
+				(gfp_mask & (GFP_DMA | GFP_DMA32)) ?
+				0 : __GFP_HIGHMEM;
+
+			flags |= VM_EXT_PAGES;
+			pages = __vmalloc_node(pages_size, 1,
+					       nested_gfp | highmem_mask,
+					       PAGE_KERNEL, node, caller);
+			if (!pages)
+				return NULL;
+		}
+	}
+
+	/*
+	 * We allocate va, area and optionally area->pages at once.
+	 */
+	va = kzalloc_node(area_size, gfp_mask & GFP_RECLAIM_MASK, node);
+	if (unlikely(!va)) {
+		vfree(pages);
 		return NULL;
+	}
 
 	if (!(flags & VM_NO_GUARD))
 		size += PAGE_SIZE;
 
-	va = alloc_vmap_area(size, align, start, end, node, gfp_mask);
-	if (IS_ERR(va)) {
-		kfree(area);
+	if (init_vmap_area(va, size, align, start, end, node, gfp_mask)) {
+		vfree(pages);
+		kfree(va);
 		return NULL;
 	}
 
+	area = (struct vm_struct *)(va + 1);
+	if (flags & VM_UNINITIALIZED) {
+		area->nr_pages = nr_pages;
+		if (flags & VM_EXT_PAGES)
+			area->pages = pages;
+		else
+			area->pages = (struct page **)(area + 1);
+	}
+
 	setup_vmalloc_vm(area, va, flags, caller);
 
 	return area;
@@ -1480,7 +1526,7 @@ struct vm_struct *find_vm_area(const void *addr)
 	return NULL;
 }
 
-static struct vm_struct *__remove_vm_area(struct vmap_area *va)
+static void __remove_vm_area(struct vmap_area *va)
 {
 	struct vm_struct *vm = va->vm;
 
@@ -1494,8 +1540,6 @@ static struct vm_struct *__remove_vm_area(struct vmap_area *va)
 
 	kasan_free_shadow(vm);
 	free_unmap_vmap_area(va);
-
-	return vm;
 }
 
 /**
@@ -1503,19 +1547,18 @@ static struct vm_struct *__remove_vm_area(struct vmap_area *va)
  *	@addr:		base address
  *
  *	Search for the kernel VM area starting at @addr, and remove it.
- *	This function returns the found VM area, but using it is NOT safe
- *	on SMP machines, except for its size or flags.
  */
-struct vm_struct *remove_vm_area(const void *addr)
+int remove_vm_area(const void *addr)
 {
-	struct vm_struct *vm = NULL;
 	struct vmap_area *va;
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA)
-		vm = __remove_vm_area(va);
+	if (va && va->flags & VM_VM_AREA) {
+		__remove_vm_area(va);
+		return 0;
+	}
 
-	return vm;
+	return -EFAULT;
 }
 
 static void __vunmap(const void *addr, int deallocate_pages)
@@ -1552,10 +1595,11 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			__free_pages(page, 0);
 		}
 
-		kvfree(area->pages);
+		if (area->flags & VM_EXT_PAGES)
+			kvfree(area->pages);
 	}
 
-	kfree(area);
+	WARN_ON(area != (struct vm_struct *)(va + 1));
 }
 
 static inline void __vfree_deferred(const void *addr)
@@ -1676,37 +1720,13 @@ void *vmap(struct page **pages, unsigned int count,
 }
 EXPORT_SYMBOL(vmap);
 
-static void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, const void *caller);
 static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
-	struct page **pages;
-	unsigned int nr_pages, array_size, i;
-	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
 	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
-					0 :
-					__GFP_HIGHMEM;
-
-	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
-	array_size = (nr_pages * sizeof(struct page *));
-
-	area->nr_pages = nr_pages;
-	/* Please note that the recursion is strictly bounded. */
-	if (array_size > PAGE_SIZE) {
-		pages = __vmalloc_node(array_size, 1, nested_gfp|highmem_mask,
-				PAGE_KERNEL, node, area->caller);
-	} else {
-		pages = kmalloc_node(array_size, nested_gfp, node);
-	}
-	area->pages = pages;
-	if (!area->pages) {
-		remove_vm_area(area->addr);
-		kfree(area);
-		return NULL;
-	}
+		0 : __GFP_HIGHMEM;
+	unsigned int i;
 
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
@@ -1726,7 +1746,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
-	if (map_vm_area(area, prot, pages))
+	if (map_vm_area(area, prot, area->pages))
 		goto fail;
 	return area->addr;
 
@@ -2377,10 +2397,7 @@ EXPORT_SYMBOL_GPL(alloc_vm_area);
 
 void free_vm_area(struct vm_struct *area)
 {
-	struct vm_struct *ret;
-	ret = remove_vm_area(area->addr);
-	BUG_ON(ret != area);
-	kfree(area);
+	BUG_ON(remove_vm_area(area->addr));
 }
 EXPORT_SYMBOL_GPL(free_vm_area);
 
-- 
2.19.2
