Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7804D82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 04:25:02 -0500 (EST)
Received: by wicll6 with SMTP id ll6so5496027wic.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 01:25:02 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id t16si8853416wmd.19.2015.11.05.01.25.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 01:25:01 -0800 (PST)
Received: by wicll6 with SMTP id ll6so5495633wic.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 01:25:00 -0800 (PST)
Date: Thu, 5 Nov 2015 11:24:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151105092459.GC7614@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105091013.GC29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105091013.GC29259@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 05, 2015 at 12:10:13PM +0300, Vladimir Davydov wrote:
> On Tue, Nov 03, 2015 at 05:26:15PM +0200, Kirill A. Shutemov wrote:
> ...
> > @@ -56,23 +56,69 @@ static int page_idle_clear_pte_refs_one(struct page *page,
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	spinlock_t *ptl;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> >  	pmd_t *pmd;
> >  	pte_t *pte;
> >  	bool referenced = false;
> >  
> > -	if (unlikely(PageTransHuge(page))) {
> > -		pmd = page_check_address_pmd(page, mm, addr, &ptl);
> > -		if (pmd) {
> > -			referenced = pmdp_clear_young_notify(vma, addr, pmd);
> > +	pgd = pgd_offset(mm, addr);
> > +	if (!pgd_present(*pgd))
> > +		return SWAP_AGAIN;
> > +	pud = pud_offset(pgd, addr);
> > +	if (!pud_present(*pud))
> > +		return SWAP_AGAIN;
> > +	pmd = pmd_offset(pud, addr);
> > +
> > +	if (pmd_trans_huge(*pmd)) {
> > +		ptl = pmd_lock(mm, pmd);
> > +                if (!pmd_present(*pmd))
> > +			goto unlock_pmd;
> > +		if (unlikely(!pmd_trans_huge(*pmd))) {
> >  			spin_unlock(ptl);
> > +			goto map_pte;
> >  		}
> > +
> > +		if (pmd_page(*pmd) != page)
> > +			goto unlock_pmd;
> > +
> > +		referenced = pmdp_clear_young_notify(vma, addr, pmd);
> > +		spin_unlock(ptl);
> > +		goto found;
> > +unlock_pmd:
> > +		spin_unlock(ptl);
> > +		return SWAP_AGAIN;
> >  	} else {
> > -		pte = page_check_address(page, mm, addr, &ptl, 0);
> > -		if (pte) {
> > -			referenced = ptep_clear_young_notify(vma, addr, pte);
> > -			pte_unmap_unlock(pte, ptl);
> > -		}
> > +		pmd_t pmde = *pmd;
> > +		barrier();
> > +		if (!pmd_present(pmde) || pmd_trans_huge(pmde))
> > +			return SWAP_AGAIN;
> > +
> > +	}
> > +map_pte:
> > +	pte = pte_offset_map(pmd, addr);
> > +	if (!pte_present(*pte)) {
> > +		pte_unmap(pte);
> > +		return SWAP_AGAIN;
> >  	}
> > +
> > +	ptl = pte_lockptr(mm, pmd);
> > +	spin_lock(ptl);
> > +
> > +	if (!pte_present(*pte)) {
> > +		pte_unmap_unlock(pte, ptl);
> > +		return SWAP_AGAIN;
> > +	}
> > +
> > +	/* THP can be referenced by any subpage */
> > +	if (pte_pfn(*pte) - page_to_pfn(page) >= hpage_nr_pages(page)) {
> > +		pte_unmap_unlock(pte, ptl);
> > +		return SWAP_AGAIN;
> > +	}
> > +
> > +	referenced = ptep_clear_young_notify(vma, addr, pte);
> > +	pte_unmap_unlock(pte, ptl);
> > +found:
> 
> Can't we hide this stuff in a helper function, which would be used by
> both page_referenced_one and page_idle_clear_pte_refs_one, instead of
> duplicating page_referenced_one code here?

I would like to, but there's no obvious way to do that: PMDs and PTEs
require different handling.

Any ideas?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
