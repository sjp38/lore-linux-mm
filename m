Date: Wed, 9 Jul 2008 14:14:39 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - GRU virtual -> physical translation
Message-ID: <20080709191439.GA7307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Open code the equivalent to follow_page(). This eliminates the
requirement for an EXPORT of follow_page(). In addition, the code
is optimized for the specific case that is needed by the GRU and only
supports architectures supported by the GRU (ia64 & x86_64).

Signed-off-by: Jack Steiner <steiner@sgi.com>

---

Andrew - do you want incremental patches or should I repost a V4 of
the original GRU driver.

After the GRU code is stabilized, I'll look into moving the open codes
PT lookup code into the kernel.


 drivers/misc/sgi-gru/grufault.c |   54 +++++++++++++++++++++++++++++++++-------
 1 file changed, 45 insertions(+), 9 deletions(-)

Index: linux/drivers/misc/sgi-gru/grufault.c
===================================================================
--- linux.orig/drivers/misc/sgi-gru/grufault.c	2008-07-09 13:54:16.786142769 -0500
+++ linux/drivers/misc/sgi-gru/grufault.c	2008-07-09 13:56:58.762219264 -0500
@@ -213,20 +213,56 @@ static int non_atomic_pte_lookup(struct 
 	return 0;
 }
 
+/*
+ *
+ * atomic_pte_lookup
+ *
+ * Convert a user virtual address to a physical address
+ * Only supports Intel large pages (2MB only) on x86_64.
+ *	ZZZ - hugepage support is incomplete
+ */
 static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
-			     int write, unsigned long *paddr, int *pageshift)
+	int write, unsigned long *paddr, int *pageshift)
 {
-	struct page *page;
+	pgd_t *pgdp;
+	pmd_t *pmdp;
+	pud_t *pudp;
+	pte_t pte;
+
+	WARN_ON(irqs_disabled());		/* ZZZ debug */
+
+	local_irq_disable();
+	pgdp = pgd_offset(vma->vm_mm, vaddr);
+	if (unlikely(pgd_none(*pgdp)))
+		goto err;
+
+	pudp = pud_offset(pgdp, vaddr);
+	if (unlikely(pud_none(*pudp)))
+		goto err;
+
+	pmdp = pmd_offset(pudp, vaddr);
+	if (unlikely(pmd_none(*pmdp)))
+		goto err;
+#ifdef CONFIG_X86_64
+	if (unlikely(pmd_large(*pmdp)))
+		pte = *(pte_t *) pmdp;
+	else
+#endif
+		pte = *pte_offset_kernel(pmdp, vaddr);
 
-	/* ZZZ Need to handle HUGE pages */
-	if (is_vm_hugetlb_page(vma))
-		return -EFAULT;
-	*pageshift = PAGE_SHIFT;
-	page = follow_page(vma, vaddr, (write ? FOLL_WRITE : 0));
-	if (!page)
+	local_irq_enable();
+
+	if (unlikely(!pte_present(pte) ||
+		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
 		return 1;
-	*paddr = page_to_phys(page);
+
+	*paddr = pte_pfn(pte) << PAGE_SHIFT;
+	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
 	return 0;
+
+err:
+	local_irq_enable();
+	return 1;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
