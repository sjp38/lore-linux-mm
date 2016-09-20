Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5A36B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 02:03:33 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p53so14619277qtp.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 23:03:33 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id 136si20430623qkf.310.2016.09.19.23.03.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 23:03:32 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 3/3] mm/vmalloc: correct a few logic error in
 __insert_vmap_area()
Message-ID: <57E0D0F2.1060707@zoho.com>
Date: Tue, 20 Sep 2016 14:02:26 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

correct a few logic error in __insert_vmap_area() since the else if
condition is always true and meaningless

avoid endless loop under [un]mapping improper ranges whose boundary
are not aligned to page

correct lazy_max_pages() return value if the number of online cpus
is power of 2

improve performance for pcpu_get_vm_areas() via optimizing vmap_areas
overlay checking algorithm and finding near vmap_areas by list_head
other than rbtree

simplify /proc/vmallocinfo implementation via seq_file helpers
for list_head

Signed-off-by: zijun_hu <zijun_hu@htc.com>
Signed-off-by: zijun_hu <zijun_hu@zoho.com>
---
 include/linux/list.h |  11 ++++++
 mm/internal.h        |   6 +++
 mm/memblock.c        |  10 +----
 mm/vmalloc.c         | 104 +++++++++++++++++++++++++++------------------------
 4 files changed, 74 insertions(+), 57 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 5183138..23c3081 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -181,6 +181,17 @@ static inline int list_is_last(const struct list_head *list,
 }
 
 /**
+ * list_is_first - tests whether @list is the first entry in list @head
+ * @list: the entry to test
+ * @head: the head of the list
+ */
+static inline int list_is_first(const struct list_head *list,
+				const struct list_head *head)
+{
+	return list->prev == head;
+}
+
+/**
  * list_empty - tests whether a list is empty
  * @head: the list to test.
  */
diff --git a/mm/internal.h b/mm/internal.h
index 1501304..abbff7c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -71,6 +71,12 @@ static inline void set_page_refcounted(struct page *page)
 	set_page_count(page, 1);
 }
 
+/**
+ * check whether range [@s0, @e0) has intersection with [@s1, @e1)
+ */
+#define is_range_overlay(s0, e0, s1, e1) \
+	(((s1) >= (e0) || (s0) >= (e1)) ? false : true)
+
 extern unsigned long highest_memmap_pfn;
 
 /*
diff --git a/mm/memblock.c b/mm/memblock.c
index 483197e..b4c7d7c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -85,20 +85,14 @@ static inline phys_addr_t memblock_cap_size(phys_addr_t base, phys_addr_t *size)
 /*
  * Address comparison utilities
  */
-static unsigned long __init_memblock memblock_addrs_overlap(phys_addr_t base1, phys_addr_t size1,
-				       phys_addr_t base2, phys_addr_t size2)
-{
-	return ((base1 < (base2 + size2)) && (base2 < (base1 + size1)));
-}
-
 bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
 					phys_addr_t base, phys_addr_t size)
 {
 	unsigned long i;
 
 	for (i = 0; i < type->cnt; i++)
-		if (memblock_addrs_overlap(base, size, type->regions[i].base,
-					   type->regions[i].size))
+		if (is_range_overlay(base, base + size, type->regions[i].base,
+				type->regions[i].base + type->regions[i].size))
 			break;
 	return i < type->cnt;
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e7..dc938f6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -67,7 +67,7 @@ static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
 	do {
 		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
 		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
 }
 
 static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
@@ -108,6 +108,9 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	unsigned long next;
 
 	BUG_ON(addr >= end);
+	WARN_ON(!PAGE_ALIGNED(addr | end));
+
+	addr = round_down(addr, PAGE_SIZE);
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -139,7 +142,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 			return -ENOMEM;
 		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
 		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
 	return 0;
 }
 
@@ -193,6 +196,9 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	int nr = 0;
 
 	BUG_ON(addr >= end);
+	WARN_ON(!PAGE_ALIGNED(addr | end));
+
+	addr = round_down(addr, PAGE_SIZE);
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -291,6 +297,22 @@ static unsigned long cached_align;
 
 static unsigned long vmap_area_pcpu_hole;
 
+static inline struct vmap_area *next_vmap_area(struct vmap_area *va)
+{
+	if (list_is_last(&va->list, &vmap_area_list))
+		return  NULL;
+	else
+		return list_next_entry(va, list);
+}
+
+static inline struct vmap_area *prev_vmap_area(struct vmap_area *va)
+{
+	if (list_is_first(&va->list, &vmap_area_list))
+		return  NULL;
+	else
+		return list_prev_entry(va, list);
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -321,10 +343,10 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 		parent = *p;
 		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp_va->va_end)
-			p = &(*p)->rb_left;
-		else if (va->va_end > tmp_va->va_start)
-			p = &(*p)->rb_right;
+		if (va->va_end <= tmp_va->va_start)
+			p = &parent->rb_left;
+		else if (va->va_start >= tmp_va->va_end)
+			p = &parent->rb_right;
 		else
 			BUG();
 	}
@@ -594,7 +616,9 @@ static unsigned long lazy_max_pages(void)
 {
 	unsigned int log;
 
-	log = fls(num_online_cpus());
+	log = num_online_cpus();
+	if (log > 1)
+		log = (unsigned int)get_count_order(log);
 
 	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
 }
@@ -1110,7 +1134,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 
 	BUG_ON(!addr);
 	BUG_ON(addr < VMALLOC_START);
-	BUG_ON(addr > VMALLOC_END);
+	BUG_ON(addr >= VMALLOC_END);
 	BUG_ON(!PAGE_ALIGNED(addr));
 
 	debug_check_no_locks_freed(mem, size);
@@ -2294,10 +2318,6 @@ void free_vm_area(struct vm_struct *area)
 EXPORT_SYMBOL_GPL(free_vm_area);
 
 #ifdef CONFIG_SMP
-static struct vmap_area *node_to_va(struct rb_node *n)
-{
-	return n ? rb_entry(n, struct vmap_area, rb_node) : NULL;
-}
 
 /**
  * pvm_find_next_prev - find the next and prev vmap_area surrounding @end
@@ -2333,10 +2353,10 @@ static bool pvm_find_next_prev(unsigned long end,
 
 	if (va->va_end > end) {
 		*pnext = va;
-		*pprev = node_to_va(rb_prev(&(*pnext)->rb_node));
+		*pprev = prev_vmap_area(va);
 	} else {
 		*pprev = va;
-		*pnext = node_to_va(rb_next(&(*pprev)->rb_node));
+		*pnext = next_vmap_area(va);
 	}
 	return true;
 }
@@ -2371,7 +2391,7 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
 
 	while (*pprev && (*pprev)->va_end > addr) {
 		*pnext = *pprev;
-		*pprev = node_to_va(rb_prev(&(*pnext)->rb_node));
+		*pprev = prev_vmap_area(*pnext);
 	}
 
 	return addr;
@@ -2411,31 +2431,34 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	struct vm_struct **vms;
 	int area, area2, last_area, term_area;
 	unsigned long base, start, end, last_end;
+	unsigned long start2, end2;
 	bool purged = false;
 
 	/* verify parameters and allocate data structures */
+	if (nr_vms < 1)
+		return NULL;
 	BUG_ON(offset_in_page(align) || !is_power_of_2(align));
-	for (last_area = 0, area = 0; area < nr_vms; area++) {
+
+	last_area = nr_vms - 1;
+	BUG_ON(!IS_ALIGNED(offsets[last_area], align));
+	BUG_ON(!IS_ALIGNED(sizes[last_area], align));
+	for (area = 0; area < nr_vms - 1; area++) {
 		start = offsets[area];
 		end = start + sizes[area];
 
 		/* is everything aligned properly? */
-		BUG_ON(!IS_ALIGNED(offsets[area], align));
-		BUG_ON(!IS_ALIGNED(sizes[area], align));
+		BUG_ON(!IS_ALIGNED(start, align));
+		BUG_ON(!IS_ALIGNED(end, align));
 
 		/* detect the area with the highest address */
 		if (start > offsets[last_area])
 			last_area = area;
 
-		for (area2 = 0; area2 < nr_vms; area2++) {
-			unsigned long start2 = offsets[area2];
-			unsigned long end2 = start2 + sizes[area2];
-
-			if (area2 == area)
-				continue;
+		for (area2 = area + 1; area2 < nr_vms; area2++) {
+			start2 = offsets[area2];
+			end2 = start2 + sizes[area2];
 
-			BUG_ON(start2 >= start && start2 < end);
-			BUG_ON(end2 <= end && end2 > start);
+			BUG_ON(is_range_overlay(start, end, start2, end2));
 		}
 	}
 	last_end = offsets[last_area] + sizes[last_area];
@@ -2505,7 +2528,7 @@ retry:
 		 */
 		if (prev && prev->va_end > base + start)  {
 			next = prev;
-			prev = node_to_va(rb_prev(&next->rb_node));
+			prev = prev_vmap_area(next);
 			base = pvm_determine_end(&next, &prev, align) - end;
 			term_area = area;
 			continue;
@@ -2576,32 +2599,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 static void *s_start(struct seq_file *m, loff_t *pos)
 	__acquires(&vmap_area_lock)
 {
-	loff_t n = *pos;
-	struct vmap_area *va;
-
 	spin_lock(&vmap_area_lock);
-	va = list_first_entry(&vmap_area_list, typeof(*va), list);
-	while (n > 0 && &va->list != &vmap_area_list) {
-		n--;
-		va = list_next_entry(va, list);
-	}
-	if (!n && &va->list != &vmap_area_list)
-		return va;
-
-	return NULL;
-
+	return seq_list_start(&vmap_area_list, *pos);
 }
 
 static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	struct vmap_area *va = p, *next;
-
-	++*pos;
-	next = list_next_entry(va, list);
-	if (&next->list != &vmap_area_list)
-		return next;
-
-	return NULL;
+	return seq_list_next(p, &vmap_area_list, pos);
 }
 
 static void s_stop(struct seq_file *m, void *p)
@@ -2636,9 +2640,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 
 static int s_show(struct seq_file *m, void *p)
 {
-	struct vmap_area *va = p;
+	struct vmap_area *va;
 	struct vm_struct *v;
 
+	va = list_entry((struct list_head *)p, struct vmap_area, list);
+
 	/*
 	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
