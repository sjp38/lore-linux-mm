Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3963B82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 07:07:55 -0500 (EST)
Received: by lbbes7 with SMTP id es7so33735532lbb.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 04:07:54 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id b193si4081336lfe.92.2015.11.05.04.07.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 04:07:53 -0800 (PST)
Date: Thu, 5 Nov 2015 15:07:26 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151105120726.GD29259@esperanza>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105091013.GC29259@esperanza>
 <20151105092459.GC7614@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151105092459.GC7614@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 05, 2015 at 11:24:59AM +0200, Kirill A. Shutemov wrote:
> On Thu, Nov 05, 2015 at 12:10:13PM +0300, Vladimir Davydov wrote:
> > On Tue, Nov 03, 2015 at 05:26:15PM +0200, Kirill A. Shutemov wrote:
> > ...
> > > @@ -56,23 +56,69 @@ static int page_idle_clear_pte_refs_one(struct page *page,
> > >  {
> > >  	struct mm_struct *mm = vma->vm_mm;
> > >  	spinlock_t *ptl;
> > > +	pgd_t *pgd;
> > > +	pud_t *pud;
> > >  	pmd_t *pmd;
> > >  	pte_t *pte;
> > >  	bool referenced = false;
> > >  
> > > -	if (unlikely(PageTransHuge(page))) {
> > > -		pmd = page_check_address_pmd(page, mm, addr, &ptl);
> > > -		if (pmd) {
> > > -			referenced = pmdp_clear_young_notify(vma, addr, pmd);
> > > +	pgd = pgd_offset(mm, addr);
> > > +	if (!pgd_present(*pgd))
> > > +		return SWAP_AGAIN;
> > > +	pud = pud_offset(pgd, addr);
> > > +	if (!pud_present(*pud))
> > > +		return SWAP_AGAIN;
> > > +	pmd = pmd_offset(pud, addr);
> > > +
> > > +	if (pmd_trans_huge(*pmd)) {
> > > +		ptl = pmd_lock(mm, pmd);
> > > +                if (!pmd_present(*pmd))
> > > +			goto unlock_pmd;
> > > +		if (unlikely(!pmd_trans_huge(*pmd))) {
> > >  			spin_unlock(ptl);
> > > +			goto map_pte;
> > >  		}
> > > +
> > > +		if (pmd_page(*pmd) != page)
> > > +			goto unlock_pmd;
> > > +
> > > +		referenced = pmdp_clear_young_notify(vma, addr, pmd);
> > > +		spin_unlock(ptl);
> > > +		goto found;
> > > +unlock_pmd:
> > > +		spin_unlock(ptl);
> > > +		return SWAP_AGAIN;
> > >  	} else {
> > > -		pte = page_check_address(page, mm, addr, &ptl, 0);
> > > -		if (pte) {
> > > -			referenced = ptep_clear_young_notify(vma, addr, pte);
> > > -			pte_unmap_unlock(pte, ptl);
> > > -		}
> > > +		pmd_t pmde = *pmd;
> > > +		barrier();
> > > +		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
> > > +			return SWAP_AGAIN;
> > > +
> > > +	}
> > > +map_pte:
> > > +	pte = pte_offset_map(pmd, addr);
> > > +	if (!pte_present(*pte)) {
> > > +		pte_unmap(pte);
> > > +		return SWAP_AGAIN;
> > >  	}
> > > +
> > > +	ptl = pte_lockptr(mm, pmd);
> > > +	spin_lock(ptl);
> > > +
> > > +	if (!pte_present(*pte)) {
> > > +		pte_unmap_unlock(pte, ptl);
> > > +		return SWAP_AGAIN;
> > > +	}
> > > +
> > > +	/* THP can be referenced by any subpage */
> > > +	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
> > > +		pte_unmap_unlock(pte, ptl);
> > > +		return SWAP_AGAIN;
> > > +	}
> > > +
> > > +	referenced = ptep_clear_young_notify(vma, addr, pte);
> > > +	pte_unmap_unlock(pte, ptl);
> > > +found:
> > 
> > Can't we hide this stuff in a helper function, which would be used by
> > both page_referenced_one and page_idle_clear_pte_refs_one, instead of
> > duplicating page_referenced_one code here?
> 
> I would like to, but there's no obvious way to do that: PMDs and PTEs
> require different handling.
> 
> Any ideas?

Something like this? [COMPLETELY UNTESTED]
---
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 853f4f3c6742..bb9169d07c2b 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -216,6 +216,10 @@ static inline pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	return ptep;
 }
 
+pte_t *page_check_address_transhuge(struct page *page, struct mm_struct *mm,
+				    unsigned long address,
+				    pmd_t **pmdp, spinlock_t **ptlp);
+
 /*
  * Used by swapoff to help locate where page is expected in vma.
  */
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 2c9ebe12b40d..6574ef6a1a96 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -56,69 +56,21 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
-	pgd_t *pgd;
-	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	bool referenced = false;
 
-	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
+	pte = page_check_address_transhuge(page, mm, address, &pmd, &ptl);
+	if (!pte)
 		return SWAP_AGAIN;
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
 
-		if (pmd_page(*pmd) != page)
-			goto unlock_pmd;
-
-		referenced = pmdp_clear_young_notify(vma, addr, pmd);
-		spin_unlock(ptl);
-		goto found;
-unlock_pmd:
-		spin_unlock(ptl);
-		return SWAP_AGAIN;
-	} else {
-		pmd_t pmde = *pmd;
-		barrier();
-		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return SWAP_AGAIN;
-
-	}
-map_pte:
-	pte = pte_offset_map(pmd, addr);
-	if (!pte_present(*pte)) {
-		pte_unmap(pte);
-		return SWAP_AGAIN;
-	}
+	if (pte == pmd) /* trans huge */
+		referenced = pmdp_clear_young_notify(vma, address, pmd);
+	else
+		referenced = ptep_clear_young_notify(vma, addr, pte);
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-
-	if (!pte_present(*pte)) {
-		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
-	}
-
-	/* THP can be referenced by any subpage */
-	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
-		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
-	}
-
-	referenced = ptep_clear_young_notify(vma, addr, pte);
 	pte_unmap_unlock(pte, ptl);
-found:
+
 	if (referenced) {
 		clear_page_idle(page);
 		/*
diff --git a/mm/rmap.c b/mm/rmap.c
index 1f90bda685b6..3638190cf7bc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -796,48 +796,35 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	return 1;
 }
 
-struct page_referenced_arg {
-	int mapcount;
-	int referenced;
-	unsigned long vm_flags;
-	struct mem_cgroup *memcg;
-};
-/*
- * arg: page_referenced_arg will be passed
- */
-static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
-			unsigned long address, void *arg)
+pte_t *page_check_address_transhuge(struct page *page, struct mm_struct *mm,
+				    unsigned long address,
+				    pmd_t **pmdp, spinlock_t **ptlp)
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
+			return NULL;
 
 		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
+		pmd = NULL;
 		goto check_pte;
 	}
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
-		return SWAP_AGAIN;
-	pud = pud_offset(pgd, address);
+		return NULL;
 	if (!pud_present(*pud))
-		return SWAP_AGAIN;
+		return NULL;
 	pmd = pmd_offset(pud, address);
 
 	if (pmd_trans_huge(*pmd)) {
-		int ret = SWAP_AGAIN;
-
 		ptl = pmd_lock(mm, pmd);
 		if (!pmd_present(*pmd))
 			goto unlock_pmd;
@@ -849,30 +836,23 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
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
+		pte = (pte_t *)pmd;
 		goto found;
 unlock_pmd:
 		spin_unlock(ptl);
-		return ret;
+		return NULL;
 	} else {
 		pmd_t pmde = *pmd;
 		barrier();
 		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
-			return SWAP_AGAIN;
+			return NULL;
 	}
+
 map_pte:
 	pte = pte_offset_map(pmd, address);
 	if (!pte_present(*pte)) {
 		pte_unmap(pte);
-		return SWAP_AGAIN;
+		return NULL;
 	}
 
 	ptl = pte_lockptr(mm, pmd);
@@ -881,35 +861,66 @@ check_pte:
 
 	if (!pte_present(*pte)) {
 		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
+		return NULL;
 	}
 
 	/* THP can be referenced by any subpage */
 	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
 		pte_unmap_unlock(pte, ptl);
-		return SWAP_AGAIN;
+		return NULL;
 	}
+found:
+	*ptlp = ptl;
+	*pmdp = pmd;
+	return pte;
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
+	int referenced = 0;
+	struct page_referenced_arg *pra = arg;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = page_check_address_transhuge(page, mm, address, &pmd, &ptl);
+	if (!pte)
+		return SWAP_AGAIN;
 
 	if (vma->vm_flags & VM_LOCKED) {
 		pte_unmap_unlock(pte, ptl);
-		pra->vm_flags |= VM_LOCKED;
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
+	if (pte == pmd) { /* trans huge */
+		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
+	} else {
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
 	}
 	pte_unmap_unlock(pte, ptl);
 
-found:
 	if (referenced)
 		clear_page_idle(page);
 	if (test_and_clear_page_young(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
