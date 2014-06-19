Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 61F226B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:19:19 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so8813866wiv.2
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 00:19:18 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id hg9si6075680wjc.7.2014.06.19.00.19.17
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 00:19:17 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH] mm: Report attempts to overwrite PTE from remap_pfn_range()
Date: Thu, 19 Jun 2014 08:19:09 +0100
Message-Id: <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <20140616134124.0ED73E00A2@blue.fi.intel.com>
References: <20140616134124.0ED73E00A2@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

When using remap_pfn_range() from a fault handler, we are exposed to
races between concurrent faults. Rather than hitting a BUG, report the
error back to the caller, like vm_insert_pfn().

v2: Fix the pte address for unmapping along the error path.
v3: Report the error back and cleanup partial remaps.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
---

Whilst this has the semantics I want to allow two concurrent, but
serialised, pagefaults that try to prefault the same object to succeed,
it looks fragile and fraught with subtlety.
-Chris

---
 mm/memory.c | 54 ++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 38 insertions(+), 16 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d67fd9f..be51fcc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1657,32 +1657,41 @@ EXPORT_SYMBOL(vm_insert_mixed);
  * in null mappings (currently treated as "copy-on-access")
  */
 static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+			   unsigned long addr, unsigned long end,
+			   unsigned long pfn, pgprot_t prot,
+			   bool first)
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	int err = 0;
 
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
 	arch_enter_lazy_mmu_mode();
 	do {
-		BUG_ON(!pte_none(*pte));
+		if (!pte_none(*pte)) {
+			err = first ? -EBUSY : -EINVAL;
+			pte++;
+			break;
+		}
+		first = false;
 		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
-	return 0;
+	return err;
 }
 
 static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+				  unsigned long addr, unsigned long end,
+				  unsigned long pfn, pgprot_t prot,
+				  bool first)
 {
 	pmd_t *pmd;
 	unsigned long next;
+	int err;
 
 	pfn -= addr >> PAGE_SHIFT;
 	pmd = pmd_alloc(mm, pud, addr);
@@ -1691,19 +1700,23 @@ static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
 	VM_BUG_ON(pmd_trans_huge(*pmd));
 	do {
 		next = pmd_addr_end(addr, end);
-		if (remap_pte_range(mm, pmd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
+		err = remap_pte_range(mm, pmd, addr, next,
+				      pfn + (addr >> PAGE_SHIFT), prot, first);
+		if (err)
+			return err;
+
+		first = false;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end,
-			unsigned long pfn, pgprot_t prot)
+				  unsigned long addr, unsigned long end,
+				  unsigned long pfn, pgprot_t prot, bool first)
 {
 	pud_t *pud;
 	unsigned long next;
+	int err;
 
 	pfn -= addr >> PAGE_SHIFT;
 	pud = pud_alloc(mm, pgd, addr);
@@ -1711,9 +1724,12 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (remap_pmd_range(mm, pud, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot))
-			return -ENOMEM;
+		err = remap_pmd_range(mm, pud, addr, next,
+				      pfn + (addr >> PAGE_SHIFT), prot, first);
+		if (err)
+			return err;
+
+		first = false;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
@@ -1735,6 +1751,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	unsigned long next;
 	unsigned long end = addr + PAGE_ALIGN(size);
 	struct mm_struct *mm = vma->vm_mm;
+	bool first = true;
 	int err;
 
 	/*
@@ -1774,13 +1791,18 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	do {
 		next = pgd_addr_end(addr, end);
 		err = remap_pud_range(mm, pgd, addr, next,
-				pfn + (addr >> PAGE_SHIFT), prot);
+				      pfn + (addr >> PAGE_SHIFT), prot, first);
 		if (err)
 			break;
+
+		first = false;
 	} while (pgd++, addr = next, addr != end);
 
-	if (err)
+	if (err) {
 		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
+		if (err != -EBUSY)
+			zap_page_range_single(vma, addr, size, NULL);
+	}
 
 	return err;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
