Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9522B8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:43:16 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EgORo027174
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:42:24 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EgZw82342960
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:42:35 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EgXhr019966
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:42:34 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:02:53 +0530
Message-Id: <20110401143253.15455.84368.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 2/26]  2: mm: Move replace_page() to mm/memory.c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>


move replace_page() out of mm/ksm.c to mm/memory.c so that replace_page
can be used even when CONFIG_KSM is not defined.
replace_page() is used to implement background page replacement.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
---
 mm/ksm.c    |   62 -----------------------------------------------------------
 mm/memory.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+), 62 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index f444158..61df1db 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -751,68 +751,6 @@ out:
 	return err;
 }
 
-/**
- * replace_page - replace page in vma by new ksm page
- * @vma:      vma that holds the pte pointing to page
- * @page:     the page we are replacing by kpage
- * @kpage:    the ksm page we replace page by
- * @orig_pte: the original value of the pte
- *
- * Returns 0 on success, -EFAULT on failure.
- */
-int replace_page(struct vm_area_struct *vma, struct page *page,
-			struct page *kpage, pte_t orig_pte)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep;
-	spinlock_t *ptl;
-	unsigned long addr;
-	int err = -EFAULT;
-
-	addr = page_address_in_vma(page, vma);
-	if (addr == -EFAULT)
-		goto out;
-
-	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
-		goto out;
-
-	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
-		goto out;
-
-	pmd = pmd_offset(pud, addr);
-	BUG_ON(pmd_trans_huge(*pmd));
-	if (!pmd_present(*pmd))
-		goto out;
-
-	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	if (!pte_same(*ptep, orig_pte)) {
-		pte_unmap_unlock(ptep, ptl);
-		goto out;
-	}
-
-	get_page(kpage);
-	page_add_anon_rmap(kpage, vma, addr);
-
-	flush_cache_page(vma, addr, pte_pfn(*ptep));
-	ptep_clear_flush(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
-
-	page_remove_rmap(page);
-	if (!page_mapped(page))
-		try_to_free_swap(page);
-	put_page(page);
-
-	pte_unmap_unlock(ptep, ptl);
-	err = 0;
-out:
-	return err;
-}
-
 static int page_trans_compound_anon_split(struct page *page)
 {
 	int ret = 0;
diff --git a/mm/memory.c b/mm/memory.c
index 9da8cab..60b8494 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2733,6 +2733,68 @@ void unmap_mapping_range(struct address_space *mapping,
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
+/**
+ * replace_page - replace page in vma by new ksm page
+ * @vma:      vma that holds the pte pointing to page
+ * @page:     the page we are replacing by kpage
+ * @kpage:    the ksm page we replace page by
+ * @orig_pte: the original value of the pte
+ *
+ * Returns 0 on success, -EFAULT on failure.
+ */
+int replace_page(struct vm_area_struct *vma, struct page *page,
+			struct page *kpage, pte_t orig_pte)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long addr;
+	int err = -EFAULT;
+
+	addr = page_address_in_vma(page, vma);
+	if (addr == -EFAULT)
+		goto out;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, addr);
+	BUG_ON(pmd_trans_huge(*pmd));
+	if (!pmd_present(*pmd))
+		goto out;
+
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	if (!pte_same(*ptep, orig_pte)) {
+		pte_unmap_unlock(ptep, ptl);
+		goto out;
+	}
+
+	get_page(kpage);
+	page_add_anon_rmap(kpage, vma, addr);
+
+	flush_cache_page(vma, addr, pte_pfn(*ptep));
+	ptep_clear_flush(vma, addr, ptep);
+	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
+
+	page_remove_rmap(page);
+	if (!page_mapped(page))
+		try_to_free_swap(page);
+	put_page(page);
+
+	pte_unmap_unlock(ptep, ptl);
+	err = 0;
+out:
+	return err;
+}
+
 int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
 {
 	struct address_space *mapping = inode->i_mapping;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
