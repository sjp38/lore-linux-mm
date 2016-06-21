Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82088828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 11:04:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so14364011lfl.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:04:39 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id u74si18268062lfd.336.2016.06.21.08.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 08:04:36 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id w130so4202018lfd.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 08:04:36 -0700 (PDT)
Date: Tue, 21 Jun 2016 18:04:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 1/2] mm: thp: move pmd check inside ptl for
 freeze_page()
Message-ID: <20160621150433.GA7536@node.shutemov.name>
References: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160617084041.GA28105@node.shutemov.name>
 <20160620085502.GA17560@hori1.linux.bs1.fc.nec.co.jp>
 <20160620093201.GB27871@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160620093201.GB27871@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Jun 20, 2016 at 12:32:01PM +0300, Kirill A. Shutemov wrote:
> > +void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> > +				unsigned long address, struct page *page)
> > +{
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +
> > +	pgd = pgd_offset(vma->vm_mm, address);
> > +	if (!pgd_present(*pgd))
> > +		return;
> > +
> > +	pud = pud_offset(pgd, address);
> > +	if (!pud_present(*pud))
> > +		return;
> > +
> > +	pmd = pmd_offset(pud, address);
> > +	__split_huge_pmd(vma, pmd, address, page, true);
> >  }
> 
> I don't see a reason to introduce new function. Just move the page
> check under ptl from split_huge_pmd_address() and that should be enough.
> 
> Or am I missing something?

I'm talking about something like patch below. Could you test it?

If it works fine to you, feel free to submit with my Signed-off-by.

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index eb810816bbc6..92ce91c03cd0 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -98,7 +98,7 @@ static inline int split_huge_page(struct page *page)
 void deferred_split_huge_page(struct page *page);
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze);
+		unsigned long address, bool freeze, struct page *page);
 
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
@@ -106,7 +106,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pmd_trans_huge(*____pmd)				\
 					|| pmd_devmap(*____pmd))	\
 			__split_huge_pmd(__vma, __pmd, __address,	\
-						false);			\
+						false, NULL);		\
 	}  while (0)
 
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index eaf3a4a655a6..2297aa41581e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1638,7 +1638,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze)
+		unsigned long address, bool freeze, struct page *page)
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
@@ -1646,8 +1646,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
+
+	/*
+	 * If caller asks to setup a migration entries, we need a page to check
+	 * pmd against. Otherwise we can end up replacing wrong page.
+	 */
+	VM_BUG_ON(freeze && !page);
+	if (page && page != pmd_page(*pmd))
+		goto out;
+
 	if (pmd_trans_huge(*pmd)) {
-		struct page *page = pmd_page(*pmd);
+		page = pmd_page(*pmd);
 		if (PageMlocked(page))
 			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
@@ -1678,20 +1687,12 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
 		return;
 
 	/*
-	 * If caller asks to setup a migration entries, we need a page to check
-	 * pmd against. Otherwise we can end up replacing wrong page.
-	 */
-	VM_BUG_ON(freeze && !page);
-	if (page && page != pmd_page(*pmd))
-		return;
-
-	/*
 	 * Caller holds the mmap_sem write mode or the anon_vma lock,
 	 * so a huge pmd cannot materialize from under us (khugepaged
 	 * holds both the mmap_sem write mode and the anon_vma lock
 	 * write mode).
 	 */
-	__split_huge_pmd(vma, pmd, address, freeze);
+	__split_huge_pmd(vma, pmd, address, freeze, page);
 }
 
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
