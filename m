Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2C3C6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:15:27 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so105358371ite.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:15:27 -0700 (PDT)
Received: from out4133-146.mail.aliyun.com (out4133-146.mail.aliyun.com. [42.120.133.146])
        by mx.google.com with ESMTP id a81si4604086ioa.39.2016.06.16.02.15.25
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 02:15:27 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <050201d1c7ae$9dbf9370$d93eba50$@alibaba-inc.com>
In-Reply-To: <050201d1c7ae$9dbf9370$d93eba50$@alibaba-inc.com>
Subject: Re: [PATCHv9-rebased2 11/37] mm: introduce do_set_pmd()
Date: Thu, 16 Jun 2016 17:15:22 +0800
Message-ID: <050301d1c7af$9cbe81b0$d63b8510$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> +
> +static int do_set_pmd(struct fault_env *fe, struct page *page)
> +{
> +	struct vm_area_struct *vma = fe->vma;
> +	bool write = fe->flags & FAULT_FLAG_WRITE;
> +	unsigned long haddr = fe->address & HPAGE_PMD_MASK;
> +	pmd_t entry;
> +	int i, ret;
> +
> +	if (!transhuge_vma_suitable(vma, haddr))
> +		return VM_FAULT_FALLBACK;
> +
> +	ret = VM_FAULT_FALLBACK;
> +	page = compound_head(page);
> +
> +	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
> +	if (unlikely(!pmd_none(*fe->pmd)))
> +		goto out;

Can we reply to the caller that fault is handled correctly(by
resetting ret to zero before jump)?

> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++)
> +		flush_icache_page(vma, page + i);
> +
> +	entry = mk_huge_pmd(page, vma->vm_page_prot);
> +	if (write)
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +
> +	add_mm_counter(vma->vm_mm, MM_FILEPAGES, HPAGE_PMD_NR);
> +	page_add_file_rmap(page, true);
> +
> +	set_pmd_at(vma->vm_mm, haddr, fe->pmd, entry);
> +
> +	update_mmu_cache_pmd(vma, haddr, fe->pmd);
> +
> +	/* fault is handled */
> +	ret = 0;
> +out:
> +	spin_unlock(fe->ptl);
> +	return ret;
> +}
> +#else
> +static int do_set_pmd(struct fault_env *fe, struct page *page)
> +{
> +	BUILD_BUG();
> +	return 0;
> +}
> +#endif
> +
>  /**
>   * alloc_set_pte - setup new PTE entry for given page and add reverse page
>   * mapping. If needed, the fucntion allocates page table or use pre-allocated.
> @@ -2940,9 +3000,19 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
>  	struct vm_area_struct *vma = fe->vma;
>  	bool write = fe->flags & FAULT_FLAG_WRITE;
>  	pte_t entry;
> +	int ret;
> +
> +	if (pmd_none(*fe->pmd) && PageTransCompound(page)) {
> +		/* THP on COW? */
> +		VM_BUG_ON_PAGE(memcg, page);
> +
> +		ret = do_set_pmd(fe, page);
> +		if (ret != VM_FAULT_FALLBACK)
> +			return ret;
> +	}
> 
>  	if (!fe->pte) {
> -		int ret = pte_alloc_one_map(fe);
> +		ret = pte_alloc_one_map(fe);
>  		if (ret)
>  			return ret;
>  	}
> diff --git a/mm/migrate.c b/mm/migrate.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
