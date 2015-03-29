Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 656EB6B0080
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 12:29:27 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so150331239pdn.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 09:29:27 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id h13si11360375pdf.62.2015.03.29.09.29.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Mar 2015 09:29:26 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 Mar 2015 02:29:21 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C2E3A2CE804E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:29:18 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2TGTAMu45219860
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:29:18 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2TGSiUi021332
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 03:28:45 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound page
In-Reply-To: <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
Date: Sun, 29 Mar 2015 21:58:25 +0530
Message-ID: <878uefn4ye.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Current split_huge_page() combines two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> changes split_huge_pmd() implementation to split the given PMD without
> splitting other PMDs this page mapped with or underlying compound page.
>
> In order to do this we have to get rid of tail page refcounting, which
> uses _mapcount of tail pages. Tail page refcounting is needed to be able
> to split THP page at any point: we always know which of tail pages is
> pinned (i.e. by get_user_pages()) and can distribute page count
> correctly.
>
> We can avoid this by allowing split_huge_page() to fail if the compound
> page is pinned. This patch removes all infrastructure for tail page
> refcounting and make split_huge_page() to always return -EBUSY. All
> split_huge_page() users already know how to handle its fail. Proper
> implementation will be added later.
>
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>
> Memory cgroup is not yet ready for new refcouting. Let's disable it on
> Kconfig level.
>
.....
......

>
>  	spin_lock(ptl);
>  	if (page)
> -		put_user_huge_page(page);
> +		put_page(page);
>  	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
>  		spin_unlock(ptl);
>  		mem_cgroup_cancel_charge(new_page, memcg);
> @@ -1662,51 +1631,78 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
>  	put_huge_zero_page();
>  }
>
> -void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
> -		pmd_t *pmd)
> +
> +static void __split_huge_pmd_locked(struct vm_area_struct *vma,
> +		pmd_t *pmd, unsigned long address)
>  {
> -	spinlock_t *ptl;
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
>  	struct page *page;
>  	struct mm_struct *mm = vma->vm_mm;
> -	unsigned long haddr = address & HPAGE_PMD_MASK;
> -	unsigned long mmun_start;	/* For mmu_notifiers */
> -	unsigned long mmun_end;		/* For mmu_notifiers */
> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	bool young, write;
> +	int i;
>
> -	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
> +	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
> +	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
> +
> +	if (is_huge_zero_pmd(*pmd))
> +		return __split_huge_zero_page_pmd(vma, haddr, pmd);
> +
> +	page = pmd_page(*pmd);
> +	VM_BUG_ON_PAGE(!page_count(page), page);
> +	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
> +
> +	write = pmd_write(*pmd);
> +	young = pmd_young(*pmd);
> +
> +	/* leave pmd empty until pte is filled */
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
> +

So we now mark pmd none, while we go ahead and split the pmd. But then what
happens to a parallel fault ? We don't hold mmap_sem here right ?

> +	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t entry, *pte;
> +		/*
> +		 * Note that NUMA hinting access restrictions are not
> +		 * transferred to avoid any possibility of altering
> +		 * permissions across VMAs.
> +		 */
> +		entry = mk_pte(page + i, vma->vm_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		if (!write)
> +			entry = pte_wrprotect(entry);
> +		if (!young)
> +			entry = pte_mkold(entry);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		BUG_ON(!pte_none(*pte));
> +		atomic_inc(&page[i]._mapcount);
> +		set_pte_at(mm, haddr, pte, entry);
> +		pte_unmap(pte);
> +	}
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(mm, pmd, pgtable);
> +	atomic_dec(compound_mapcount_ptr(page));
> +}
> +

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
