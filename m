Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 158256B0044
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 16:53:45 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so13235969pab.33
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 13:53:44 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id g5si43670757pav.56.2014.01.02.13.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jan 2014 13:53:43 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [RFC PATCHv3 08/11] mm/vmalloc.c: Allow lowmem to be tracked in vmalloc
Date: Thu,  2 Jan 2014 13:53:26 -0800
Message-Id: <1388699609-18214-9-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Laura Abbott <lauraa@codeaurora.org>, Neeti Desai <neetid@codeaurora.org>

vmalloc is currently assumed to be a completely separate address space
from the lowmem region. While this may be true in the general case,
there are some instances where lowmem and virtual space intermixing
provides gains. One example is needing to steal a large chunk of physical
lowmem for another purpose outside the systems usage. Rather than
waste the precious lowmem space on a 32-bit system, we can allow the
virtual holes created by the physical holes to be used by vmalloc
for virtual addressing. Track lowmem allocations in vmalloc to
allow mixing of lowmem and vmalloc.

Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
Signed-off-by: Neeti Desai <neetid@codeaurora.org>
---
 include/linux/mm.h      |    6 ++
 include/linux/vmalloc.h |   31 ++++++++++++
 mm/Kconfig              |    6 ++
 mm/vmalloc.c            |  119 ++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 146 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3552717..3c2368d6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -333,6 +333,10 @@ unsigned long vmalloc_to_pfn(const void *addr);
  * On nommu, vmalloc/vfree wrap through kmalloc/kfree directly, so there
  * is no special casing required.
  */
+
+#ifdef CONFIG_VMALLOC_INTERMIX
+extern int is_vmalloc_addr(const void *x);
+#else
 static inline int is_vmalloc_addr(const void *x)
 {
 #ifdef CONFIG_MMU
@@ -343,6 +347,8 @@ static inline int is_vmalloc_addr(const void *x)
 	return 0;
 #endif
 }
+#endif
+
 #ifdef CONFIG_MMU
 extern int is_vmalloc_or_module_addr(const void *x);
 #else
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 4b8a891..995041c 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -16,6 +16,7 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
 #define VM_VPAGES		0x00000010	/* buffer for pages was vmalloc'ed */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
+#define VM_LOWMEM		0x00000040	/* Tracking of direct mapped lowmem */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -150,6 +151,31 @@ extern long vwrite(char *buf, char *addr, unsigned long count);
 extern struct list_head vmap_area_list;
 extern __init void vm_area_add_early(struct vm_struct *vm);
 extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
+#ifdef CONFIG_VMALLOC_INTERMIX
+extern void __vmalloc_calc_next_area(int *v, unsigned long *start, unsigned long *end, bool is_vmalloc);
+extern void mark_vmalloc_reserved_area(void *addr, unsigned long size);
+
+#define for_each_potential_vmalloc_area(start, end, i) \
+	for (*i = 0, __vmalloc_calc_next_area((i), (start), (end), true); \
+		*start; \
+		__vmalloc_calc_next_area((i), (start), (end), true))
+
+#define for_each_potential_nonvmalloc_area(start, end, i) \
+	for (*i = 0, __vmalloc_calc_next_area((i), (start), (end), false); \
+		*start; \
+		__vmalloc_calc_next_area((i), (start), (end), false))
+
+#else
+static inline void mark_vmalloc_reserved_area(void *addr, unsigned long size)
+{ };
+
+#define for_each_potential_vmalloc_area(start, end, i) \
+	for (*i = 0, *start = VMALLOC_START, *end = VMALLOC_END; *i == 0; *i = 1)
+
+#define for_each_potential_nonvmalloc_area(start, end, i) \
+	for (*i = 0, *start = PAGE_OFFSET, *end = high_memory; *i == 0; *i = 1)
+
+#endif
 
 #ifdef CONFIG_SMP
 # ifdef CONFIG_MMU
@@ -180,7 +206,12 @@ struct vmalloc_info {
 };
 
 #ifdef CONFIG_MMU
+#ifdef CONFIG_VMALLOC_INTERMIX
+extern unsigned long total_vmalloc_size;
+#define VMALLOC_TOTAL total_vmalloc_size
+#else
 #define VMALLOC_TOTAL (VMALLOC_END - VMALLOC_START)
+#endif
 extern void get_vmalloc_info(struct vmalloc_info *vmi);
 #else
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 723bbe0..e3c37c4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -552,3 +552,9 @@ config MEM_SOFT_DIRTY
 	  it can be cleared by hands.
 
 	  See Documentation/vm/soft-dirty.txt for more details.
+
+# Some architectures (mostly 32-bit) may wish to allow holes in the memory
+# map to be used as vmalloc to save on precious virtual address space.
+config VMALLOC_INTERMIX
+	def_bool n
+	depends on ARCH_TRACKS_VMALLOC
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0fdf968..811f629 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -282,6 +282,82 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+#ifdef CONFIG_VMALLOC_INTERMIX
+#define POSSIBLE_VMALLOC_START	PAGE_OFFSET
+
+#define VMALLOC_BITMAP_SIZE	((VMALLOC_END - PAGE_OFFSET) >> \
+					PAGE_SHIFT)
+#define VMALLOC_TO_BIT(addr)	((addr - PAGE_OFFSET) >> PAGE_SHIFT)
+#define BIT_TO_VMALLOC(i)	(PAGE_OFFSET + i * PAGE_SIZE)
+
+unsigned long total_vmalloc_size;
+unsigned long vmalloc_reserved;
+
+/*
+ * Bitmap of kernel virtual address space. A set bit indicates a region is
+ * part of the direct mapped region and should not be treated as vmalloc.
+ */
+DECLARE_BITMAP(possible_areas, VMALLOC_BITMAP_SIZE);
+
+void __vmalloc_calc_next_area(int *v, unsigned long *start, unsigned long *end,
+					bool want_vmalloc)
+{
+	int i = *v;
+	int next;
+
+	if (want_vmalloc)
+		next = find_next_zero_bit(possible_areas, VMALLOC_BITMAP_SIZE, i);
+	else
+		next = find_next_bit(possible_areas, VMALLOC_BITMAP_SIZE, i);
+
+	if (next >= VMALLOC_BITMAP_SIZE) {
+		*start = 0;
+		*end = 0;
+		return;
+	}
+
+	*start = BIT_TO_VMALLOC(next);
+
+	if (want_vmalloc)
+		*v = find_next_bit(possible_areas, VMALLOC_BITMAP_SIZE, next);
+	else
+		*v = find_next_zero_bit(possible_areas, VMALLOC_BITMAP_SIZE, next);
+
+	*end = BIT_TO_VMALLOC(*v);
+}
+
+void mark_vmalloc_reserved_area(void *x, unsigned long size)
+{
+	unsigned long addr = (unsigned long)x;
+
+	bitmap_set(possible_areas, VMALLOC_TO_BIT(addr), size >> PAGE_SHIFT);
+	vmalloc_reserved += size;
+}
+
+int is_vmalloc_addr(const void *x)
+{
+	unsigned long addr = (unsigned long)x;
+
+	if (addr < POSSIBLE_VMALLOC_START || addr >= VMALLOC_END)
+		return 0;
+
+	if (test_bit(VMALLOC_TO_BIT(addr), possible_areas))
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL(is_vmalloc_addr);
+
+static void calc_total_vmalloc_size(void)
+{
+	total_vmalloc_size = VMALLOC_END - POSSIBLE_VMALLOC_START -
+				vmalloc_reserved;
+}
+#else
+#define POSSIBLE_VMALLOC_START	VMALLOC_START
+static void calc_total_vmalloc_size(void) { }
+#endif
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -497,7 +573,7 @@ static void __free_vmap_area(struct vmap_area *va)
 	 * here too, consider only end addresses which fall inside
 	 * vmalloc area proper.
 	 */
-	if (va->va_end > VMALLOC_START && va->va_end <= VMALLOC_END)
+	if (va->va_end > POSSIBLE_VMALLOC_START && va->va_end <= VMALLOC_END)
 		vmap_area_pcpu_hole = max(vmap_area_pcpu_hole, va->va_end);
 
 	kfree_rcu(va, rcu_head);
@@ -785,7 +861,7 @@ static RADIX_TREE(vmap_block_tree, GFP_ATOMIC);
 
 static unsigned long addr_to_vb_idx(unsigned long addr)
 {
-	addr -= VMALLOC_START & ~(VMAP_BLOCK_SIZE-1);
+	addr -= POSSIBLE_VMALLOC_START & ~(VMAP_BLOCK_SIZE-1);
 	addr /= VMAP_BLOCK_SIZE;
 	return addr;
 }
@@ -806,7 +882,7 @@ static struct vmap_block *new_vmap_block(gfp_t gfp_mask)
 		return ERR_PTR(-ENOMEM);
 
 	va = alloc_vmap_area(VMAP_BLOCK_SIZE, VMAP_BLOCK_SIZE,
-					VMALLOC_START, VMALLOC_END,
+					POSSIBLE_VMALLOC_START, VMALLOC_END,
 					node, gfp_mask);
 	if (IS_ERR(va)) {
 		kfree(vb);
@@ -1062,7 +1138,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	unsigned long addr = (unsigned long)mem;
 
 	BUG_ON(!addr);
-	BUG_ON(addr < VMALLOC_START);
+	BUG_ON(addr < POSSIBLE_VMALLOC_START);
 	BUG_ON(addr > VMALLOC_END);
 	BUG_ON(addr & (PAGE_SIZE-1));
 
@@ -1099,7 +1175,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 	} else {
 		struct vmap_area *va;
 		va = alloc_vmap_area(size, PAGE_SIZE,
-				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
+				POSSIBLE_VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
 		if (IS_ERR(va))
 			return NULL;
 
@@ -1158,8 +1234,8 @@ void __init vm_area_register_early(struct vm_struct *vm, size_t align)
 	static size_t vm_init_off __initdata;
 	unsigned long addr;
 
-	addr = ALIGN(VMALLOC_START + vm_init_off, align);
-	vm_init_off = PFN_ALIGN(addr + vm->size) - VMALLOC_START;
+	addr = ALIGN(POSSIBLE_VMALLOC_START + vm_init_off, align);
+	vm_init_off = PFN_ALIGN(addr + vm->size) - POSSIBLE_VMALLOC_START;
 
 	vm->addr = (void *)addr;
 
@@ -1196,6 +1272,7 @@ void __init vmalloc_init(void)
 
 	vmap_area_pcpu_hole = VMALLOC_END;
 
+	calc_total_vmalloc_size();
 	vmap_initialized = true;
 }
 
@@ -1363,16 +1440,17 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
  */
 struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
-	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
-				  NUMA_NO_NODE, GFP_KERNEL,
+	return __get_vm_area_node(size, 1, flags, POSSIBLE_VMALLOC_START,
+				  VMALLOC_END, NUMA_NO_NODE, GFP_KERNEL,
 				  __builtin_return_address(0));
 }
 
 struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 				const void *caller)
 {
-	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
-				  NUMA_NO_NODE, GFP_KERNEL, caller);
+	return __get_vm_area_node(size, 1, flags, POSSIBLE_VMALLOC_START,
+				  VMALLOC_END, NUMA_NO_NODE, GFP_KERNEL,
+				  caller);
 }
 
 /**
@@ -1683,8 +1761,8 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller)
 {
-	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
-				gfp_mask, prot, node, caller);
+	return __vmalloc_node_range(size, align, POSSIBLE_VMALLOC_START,
+				VMALLOC_END, gfp_mask, prot, node, caller);
 }
 
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
@@ -2355,7 +2433,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
 				     size_t align)
 {
-	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
+	const unsigned long vmalloc_start = ALIGN(POSSIBLE_VMALLOC_START, align);
 	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
 	struct vmap_area **vas, *prev, *next;
 	struct vm_struct **vms;
@@ -2625,6 +2703,9 @@ static int s_show(struct seq_file *m, void *p)
 	if (v->flags & VM_VPAGES)
 		seq_printf(m, " vpages");
 
+	if (v->flags & VM_LOWMEM)
+		seq_printf(m, " lowmem");
+
 	show_numa_info(m, v);
 	seq_putc(m, '\n');
 	return 0;
@@ -2679,7 +2760,7 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 	vmi->used = 0;
 	vmi->largest_chunk = 0;
 
-	prev_end = VMALLOC_START;
+	prev_end = 0;
 
 	spin_lock(&vmap_area_lock);
 
@@ -2694,7 +2775,7 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 		/*
 		 * Some archs keep another range for modules in vmalloc space
 		 */
-		if (addr < VMALLOC_START)
+		if (addr < POSSIBLE_VMALLOC_START)
 			continue;
 		if (addr >= VMALLOC_END)
 			break;
@@ -2702,6 +2783,12 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 		if (va->flags & (VM_LAZY_FREE | VM_LAZY_FREEING))
 			continue;
 
+		if (va->vm && va->vm->flags & VM_LOWMEM)
+			continue;
+
+		if (prev_end == 0)
+			prev_end = va->va_start;
+
 		vmi->used += (va->va_end - va->va_start);
 
 		free_area_size = addr - prev_end;
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
