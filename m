Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 708656B0085
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 13:43:33 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so147903175wgd.2
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 10:43:33 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id b4si13814148wiv.31.2015.03.29.10.43.31
        for <linux-mm@kvack.org>;
        Sun, 29 Mar 2015 10:43:31 -0700 (PDT)
Date: Sun, 29 Mar 2015 20:43:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound
 page
Message-ID: <20150329174319.GB976@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
 <878uefn4ye.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878uefn4ye.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 29, 2015 at 09:58:25PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > Current split_huge_page() combines two operations: splitting PMDs into
> > tables of PTEs and splitting underlying compound page. This patch
> > changes split_huge_pmd() implementation to split the given PMD without
> > splitting other PMDs this page mapped with or underlying compound page.
> >
> > In order to do this we have to get rid of tail page refcounting, which
> > uses _mapcount of tail pages. Tail page refcounting is needed to be able
> > to split THP page at any point: we always know which of tail pages is
> > pinned (i.e. by get_user_pages()) and can distribute page count
> > correctly.
> >
> > We can avoid this by allowing split_huge_page() to fail if the compound
> > page is pinned. This patch removes all infrastructure for tail page
> > refcounting and make split_huge_page() to always return -EBUSY. All
> > split_huge_page() users already know how to handle its fail. Proper
> > implementation will be added later.
> >
> > Without tail page refcounting, implementation of split_huge_pmd() is
> > pretty straight-forward.
> >
> > Memory cgroup is not yet ready for new refcouting. Let's disable it on
> > Kconfig level.
> >
> .....
> ......
> 
> >
> >  	spin_lock(ptl);
> >  	if (page)
> > -		put_user_huge_page(page);
> > +		put_page(page);
> >  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> >  		spin_unlock(ptl);
> >  		mem_cgroup_cancel_charge(new_page, memcg);
> > @@ -1662,51 +1631,78 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> >  	put_huge_zero_page();
> >  }
> >
> > -void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
> > -		pmd_t *pmd)
> > +
> > +static void __split_huge_pmd_locked(struct vm_area_struct *vma,
> > +		pmd_t *pmd, unsigned long address)
> >  {
> > -	spinlock_t *ptl;
> > +	unsigned long haddr = address & HPAGE_PMD_MASK;
> >  	struct page *page;
> >  	struct mm_struct *mm = vma->vm_mm;
> > -	unsigned long haddr = address & HPAGE_PMD_MASK;
> > -	unsigned long mmun_start;	/* For mmu_notifiers */
> > -	unsigned long mmun_end;		/* For mmu_notifiers */
> > +	pgtable_t pgtable;
> > +	pmd_t _pmd;
> > +	bool young, write;
> > +	int i;
> >
> > -	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
> > +	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
> > +	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
> > +
> > +	if (is_huge_zero_pmd(*pmd))
> > +		return __split_huge_zero_page_pmd(vma, haddr, pmd);
> > +
> > +	page = pmd_page(*pmd);
> > +	VM_BUG_ON_PAGE(!page_count(page), page);
> > +	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
> > +
> > +	write = pmd_write(*pmd);
> > +	young = pmd_young(*pmd);
> > +
> > +	/* leave pmd empty until pte is filled */
> > +	pmdp_clear_flush_notify(vma, haddr, pmd);
> > +
> 
> So we now mark pmd none, while we go ahead and split the pmd. But then what
> happens to a parallel fault ? We don't hold mmap_sem here right ?

We do hold ptl. That should be enough.

> > +	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> > +	pmd_populate(mm, &_pmd, pgtable);
> > +
> > +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> > +		pte_t entry, *pte;
> > +		/*
> > +		 * Note that NUMA hinting access restrictions are not
> > +		 * transferred to avoid any possibility of altering
> > +		 * permissions across VMAs.
> > +		 */
> > +		entry = mk_pte(page + i, vma->vm_page_prot);
> > +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > +		if (!write)
> > +			entry = pte_wrprotect(entry);
> > +		if (!young)
> > +			entry = pte_mkold(entry);
> > +		pte = pte_offset_map(&_pmd, haddr);
> > +		BUG_ON(!pte_none(*pte));
> > +		atomic_inc(&page[i]._mapcount);
> > +		set_pte_at(mm, haddr, pte, entry);
> > +		pte_unmap(pte);
> > +	}
> > +	smp_wmb(); /* make pte visible before pmd */
> > +	pmd_populate(mm, pmd, pgtable);
> > +	atomic_dec(compound_mapcount_ptr(page));
> > +}
> > +
> 
> -aneesh
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
