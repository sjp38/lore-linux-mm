Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id C323982F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 09:37:31 -0500 (EST)
Received: by lbbwb3 with SMTP id wb3so59066958lbb.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 06:37:31 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id aa4si323770lbc.76.2015.11.06.06.37.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 06:37:29 -0800 (PST)
Date: Fri, 6 Nov 2015 17:37:07 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: add page_check_address_transhuge helper
Message-ID: <20151106143707.GL29259@esperanza>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105091013.GC29259@esperanza>
 <20151105092459.GC7614@node.shutemov.name>
 <20151105120726.GD29259@esperanza>
 <20151105123606.GE7614@node.shutemov.name>
 <20151105125354.GE29259@esperanza>
 <20151105125838.GF7614@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105125838.GF7614@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

page_referenced_one() and page_idle_clear_pte_refs_one() duplicate the
code for looking up pte of a (possibly transhuge) page. Move this code
to a new helper function, page_check_address_transhuge(), and make the
above mentioned functions use it.

This is just a cleanup, no functional changes are intended.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/rmap.h |   8 ++++
 mm/page_idle.c       |  62 ++++-------------------------
 mm/rmap.c            | 110 ++++++++++++++++++++++++++++++---------------------
 3 files changed, 81 insertions(+), 99 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 853f4f3c6742..7b7ce0282c2d 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -217,6 +217,14 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 }
 
 /*
+ * Used by idle page tracking to check if a page was referenced via page
+ * tables.
+ */
+bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
+				  unsigned long address, pmd_t **pmdp,
+				  pte_t **ptep, spinlock_t **ptlp);
+
+/*
  * Used by swapoff to help locate where page is expected in vma.
  */
 unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 2c9ebe12b40d..374931f32ebc 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -55,70 +55,22 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 					unsigned long addr, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	spinlock_t *ptl;
 	bool referenced = false;
 
-	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
-		return SWAP_AGAIN;
-	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
-		return SWAP_AGAIN;
-	pmd = pmd_offset(pud, addr);
-
-	if (pmd_trans_huge(*pmd)) {
-		ptl = pmd_lock(mm, pmd);
-                if (!pmd_present(*pmd))
-			goto unlock_pmd;
-		if (unlikely(!pmd_trans_huge(*pmd))) {
-			spin_unlock(ptl);
-			goto map_pte;
-		}
-
-		if (pmd_page(*pmd) != page)
-			goto unlock_pmd;
-
-		referenced = pmdp_clear_young_notify(vma, addr, pmd);
-		spin_unlock(ptl);
-		goto found;
-unlock_pmd:
-		spin_unlock(ptl);
+	if (!page_check_address_transhuge(page, mm, addr, &pmd, &pte, &ptl))
 		return SWAP_AGAIN;
-	} else {
-		pmd_t pmde = *pmd;
-		barrier();
-		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return SWAP_AGAIN;
 
-	}
-map_pte:
-	pte = pte_offset_map(pmd, addr);
-	if (!pte_present(*pte)) {
+	if (pte) {
+		referenced = ptep_clear_young_notify(vma, addr, pte);
 		pte_unmap(pte);
-		return SWAP_AGAIN;
-	}
-
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-
-	if (!pte_present(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
-	}
+	} else
+		referenced = pmdp_clear_young_notify(vma, addr, pmd);
 
-	/* THP can be referenced by any subpage */
-	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
-		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
-	}
+	spin_unlock(ptl);
 
-	referenced = ptep_clear_young_notify(vma, addr, pte);
-	pte_unmap_unlock(pte, ptl);
-found:
 	if (referenced) {
 		clear_page_idle(page);
 		/*
diff --git a/mm/rmap.c b/mm/rmap.c
index 0837487d3737..7ac775e41820 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -796,48 +796,43 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	return 1;
 }
 
-struct page_referenced_arg {
-	int mapcount;
-	int referenced;
-	unsigned long vm_flags;
-	struct mem_cgroup *memcg;
-};
 /*
- * arg: page_referenced_arg will be passed
+ * Check that @page is mapped at @address into @mm. In contrast to
+ * page_check_address(), this function can handle transparent huge pages.
+ *
+ * On success returns true with pte mapped and locked. For transparent huge
+ * pages *@ptep is set to NULL.
  */
-static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, void *arg)
+bool page_check_address_transhuge(struct page *page, struct mm_struct *mm,
+				  unsigned long address, pmd_t **pmdp,
+				  pte_t **ptep, spinlock_t **ptlp)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	int referenced = 0;
-	struct page_referenced_arg *pra = arg;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
+	spinlock_t *ptl;
 
 	if (unlikely(PageHuge(page))) {
 		/* when pud is not present, pte will be NULL */
 		pte = huge_pte_offset(mm, address);
 		if (!pte)
-			return SWAP_AGAIN;
+			return false;
 
 		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
+		pmd = NULL;
 		goto check_pte;
 	}
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		return SWAP_AGAIN;
+		return false;
 	pud = pud_offset(pgd, address);
 	if (!pud_present(*pud))
-		return SWAP_AGAIN;
+		return false;
 	pmd = pmd_offset(pud, address);
 
 	if (pmd_trans_huge(*pmd)) {
-		int ret = SWAP_AGAIN;
-
 		ptl = pmd_lock(mm, pmd);
 		if (!pmd_present(*pmd))
 			goto unlock_pmd;
@@ -849,30 +844,22 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (pmd_page(*pmd) != page)
 			goto unlock_pmd;
 
-		if (vma->vm_flags & VM_LOCKED) {
-			pra->vm_flags |= VM_LOCKED;
-			ret = SWAP_FAIL; /* To break the loop */
-			goto unlock_pmd;
-		}
-
-		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced++;
-		spin_unlock(ptl);
+		pte = NULL;
 		goto found;
 unlock_pmd:
 		spin_unlock(ptl);
-		return ret;
+		return false;
 	} else {
 		pmd_t pmde = *pmd;
 		barrier();
 		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return SWAP_AGAIN;
+			return false;
 	}
 map_pte:
 	pte = pte_offset_map(pmd, address);
 	if (!pte_present(*pte)) {
 		pte_unmap(pte);
-		return SWAP_AGAIN;
+		return false;
 	}
 
 	ptl = pte_lockptr(mm, pmd);
@@ -881,35 +868,70 @@ check_pte:
 
 	if (!pte_present(*pte)) {
 		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
+		return false;
 	}
 
 	/* THP can be referenced by any subpage */
 	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
 		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
+		return false;
 	}
+found:
+	*ptep = pte;
+	*pmdp = pmd;
+	*ptlp = ptl;
+	return true;
+}
+
+struct page_referenced_arg {
+	int mapcount;
+	int referenced;
+	unsigned long vm_flags;
+	struct mem_cgroup *memcg;
+};
+/*
+ * arg: page_referenced_arg will be passed
+ */
+static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
+			unsigned long address, void *arg)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page_referenced_arg *pra = arg;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int referenced = 0;
+
+	if (!page_check_address_transhuge(page, mm, address, &pmd, &pte, &ptl))
+		return SWAP_AGAIN;
 
 	if (vma->vm_flags & VM_LOCKED) {
-		pte_unmap_unlock(pte, ptl);
+		if (pte)
+			pte_unmap(pte);
+		spin_unlock(ptl);
 		pra->vm_flags |= VM_LOCKED;
 		return SWAP_FAIL; /* To break the loop */
 	}
 
-	if (ptep_clear_flush_young_notify(vma, address, pte)) {
-		/*
-		 * Don't treat a reference through a sequentially read
-		 * mapping as such.  If the page has been used in
-		 * another mapping, we will catch it; if this other
-		 * mapping is already gone, the unmap path will have
-		 * set PG_referenced or activated the page.
-		 */
-		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+	if (pte) {
+		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+			/*
+			 * Don't treat a reference through a sequentially read
+			 * mapping as such.  If the page has been used in
+			 * another mapping, we will catch it; if this other
+			 * mapping is already gone, the unmap path will have
+			 * set PG_referenced or activated the page.
+			 */
+			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
+				referenced++;
+		}
+		pte_unmap(pte);
+	} else {
+		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 	}
-	pte_unmap_unlock(pte, ptl);
+	spin_unlock(ptl);
 
-found:
 	if (referenced)
 		clear_page_idle(page);
 	if (test_and_clear_page_young(page))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
