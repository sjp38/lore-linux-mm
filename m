Message-Id: <20071004040002.395028045@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:38 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [03/18] vmalloc_address(): Determine vmalloc address from page struct
Content-Disposition: inline; filename=vcompound_vmalloc_address
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Sometimes we need to figure out which vmalloc address is in use
for a certain page struct. There is no easy way to figure out
the vmalloc address from the page struct. Simply search through
the kernel page tables to find the address. Use sparingly.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |    2 +
 mm/vmalloc.c       |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+)

Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2007-10-03 16:20:15.000000000 -0700
+++ linux-2.6/mm/vmalloc.c	2007-10-03 16:20:48.000000000 -0700
@@ -840,3 +840,82 @@ void free_vm_area(struct vm_struct *area
 	kfree(area);
 }
 EXPORT_SYMBOL_GPL(free_vm_area);
+
+
+/*
+ * Determine vmalloc address from a page struct.
+ *
+ * Linear search through all ptes of the vmalloc area.
+ */
+static unsigned long vaddr_pte_range(pmd_t *pmd, unsigned long addr,
+		unsigned long end, unsigned long pfn)
+{
+	pte_t *pte;
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		pte_t ptent = *pte;
+		if (pte_present(ptent) && pte_pfn(ptent) == pfn)
+			return addr;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	return 0;
+}
+
+static inline unsigned long vaddr_pmd_range(pud_t *pud, unsigned long addr,
+		unsigned long end, unsigned long pfn)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	unsigned long n;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		n = vaddr_pte_range(pmd, addr, next, pfn);
+		if (n)
+			return n;
+	} while (pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline unsigned long vaddr_pud_range(pgd_t *pgd, unsigned long addr,
+		unsigned long end, unsigned long pfn)
+{
+	pud_t *pud;
+	unsigned long next;
+	unsigned long n;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		n = vaddr_pmd_range(pud, addr, next, pfn);
+		if (n)
+			return n;
+	} while (pud++, addr = next, addr != end);
+	return 0;
+}
+
+void *vmalloc_address(struct page *page)
+{
+	pgd_t *pgd;
+	unsigned long next, n;
+	unsigned long addr = VMALLOC_START;
+	unsigned long pfn = page_to_pfn(page);
+
+	pgd = pgd_offset_k(VMALLOC_START);
+	do {
+		next = pgd_addr_end(addr, VMALLOC_END);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		n = vaddr_pud_range(pgd, addr, next, pfn);
+		if (n)
+			return (void *)n;
+	} while (pgd++, addr = next, addr < VMALLOC_END);
+	return NULL;
+}
+EXPORT_SYMBOL(vmalloc_address);
+
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2007-10-03 16:19:27.000000000 -0700
+++ linux-2.6/include/linux/mm.h	2007-10-03 16:20:48.000000000 -0700
@@ -294,6 +294,8 @@ static inline int get_page_unless_zero(s
 	return atomic_inc_not_zero(&page->_count);
 }
 
+void *vmalloc_address(struct page *);
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
