Date: Mon, 1 Dec 2008 00:43:37 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/8] badpage: vm_normal_page use print_bad_pte
In-Reply-To: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010042430.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

print_bad_pte() is so far being called only when zap_pte_range() finds
negative page_mapcount, or there's a fault on a pte_file where it does
not belong.  That's weak coverage when we suspect pagetable corruption.

Originally, it was called when vm_normal_page() found an invalid pfn:
but pfn_valid is expensive on some architectures and configurations, so
2.6.24 put that under CONFIG_DEBUG_VM (which doesn't help in the field),
then 2.6.26 replaced it by a VM_BUG_ON (likewise).

Reinstate the print_bad_pte() in vm_normal_page(), but use a cheaper
test than pfn_valid(): memmap_init_zone() (used in bootup and hotplug)
keep a __read_mostly note of the highest_memmap_pfn, vm_normal_page()
then check pfn against that.  We could call this pfn_plausible() or
pfn_sane(), but I doubt we'll need it elsewhere: of course it's not
reliable, but gives much stronger pagetable validation on many boxes.

Also use print_bad_pte() when the pte_special bit is found outside a
VM_PFNMAP or VM_MIXEDMAP area, instead of VM_BUG_ON.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/internal.h   |    1 +
 mm/memory.c     |   20 ++++++++++----------
 mm/page_alloc.c |    4 ++++
 3 files changed, 15 insertions(+), 10 deletions(-)

--- badpage3/mm/internal.h	2008-11-10 11:27:02.000000000 +0000
+++ badpage4/mm/internal.h	2008-11-28 20:40:42.000000000 +0000
@@ -49,6 +49,7 @@ extern void putback_lru_page(struct page
 /*
  * in mm/page_alloc.c
  */
+extern unsigned long highest_memmap_pfn;
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 
 /*
--- badpage3/mm/memory.c	2008-11-28 20:40:40.000000000 +0000
+++ badpage4/mm/memory.c	2008-11-28 20:40:42.000000000 +0000
@@ -467,21 +467,18 @@ static inline int is_cow_mapping(unsigne
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 				pte_t pte)
 {
-	unsigned long pfn;
+	unsigned long pfn = pte_pfn(pte);
 
 	if (HAVE_PTE_SPECIAL) {
-		if (likely(!pte_special(pte))) {
-			VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-			return pte_page(pte);
-		}
-		VM_BUG_ON(!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)));
+		if (likely(!pte_special(pte)))
+			goto check_pfn;
+		if (!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
+			print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
 
 	/* !HAVE_PTE_SPECIAL case follows: */
 
-	pfn = pte_pfn(pte);
-
 	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
 		if (vma->vm_flags & VM_MIXEDMAP) {
 			if (!pfn_valid(pfn))
@@ -497,11 +494,14 @@ struct page *vm_normal_page(struct vm_ar
 		}
 	}
 
-	VM_BUG_ON(!pfn_valid(pfn));
+check_pfn:
+	if (unlikely(pfn > highest_memmap_pfn)) {
+		print_bad_pte(vma, addr, pte, NULL);
+		return NULL;
+	}
 
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
-	 *
 	 * eg. VDSO mappings can cause them to exist.
 	 */
 out:
--- badpage3/mm/page_alloc.c	2008-11-28 20:40:40.000000000 +0000
+++ badpage4/mm/page_alloc.c	2008-11-28 20:40:42.000000000 +0000
@@ -69,6 +69,7 @@ EXPORT_SYMBOL(node_states);
 
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
+unsigned long highest_memmap_pfn __read_mostly;
 int percpu_pagelist_fraction;
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -2597,6 +2598,9 @@ void __meminit memmap_init_zone(unsigned
 	unsigned long pfn;
 	struct zone *z;
 
+	if (highest_memmap_pfn < end_pfn - 1)
+		highest_memmap_pfn = end_pfn - 1;
+
 	z = &NODE_DATA(nid)->node_zones[zone];
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
