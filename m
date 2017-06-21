Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9266B03E0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:49:25 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id r62so48402117qkf.6
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:49:25 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id d188si14385020qkf.141.2017.06.21.04.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 04:49:24 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id d14so14967710qkb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 04:49:24 -0700 (PDT)
Date: Wed, 21 Jun 2017 14:49:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v7 06/10] mm: thp: check pmd migration entry in common
 path
Message-ID: <20170621114920.mmbexy4dbgbb4juq@node.shutemov.name>
References: <20170620230715.81590-1-zi.yan@sent.com>
 <20170620230715.81590-7-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170620230715.81590-7-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

On Tue, Jun 20, 2017 at 07:07:11PM -0400, Zi Yan wrote:
> @@ -1220,6 +1238,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>  		goto out_unlock;
>  
> +	if (unlikely(!pmd_present(orig_pmd)))
> +		goto out_unlock;
> +

Hm. Shouldn't we wait for the page here?

>  	page = pmd_page(orig_pmd);
>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>  	/*
> @@ -1556,6 +1577,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	if (is_huge_zero_pmd(orig_pmd))
>  		goto out;
>  
> +	if (unlikely(!pmd_present(orig_pmd))) {
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(orig_pmd));
> +		goto out;
> +	}
> +
>  	page = pmd_page(orig_pmd);
>  	/*
>  	 * If other processes are mapping this page, we couldn't discard
> @@ -1770,6 +1797,23 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	preserve_write = prot_numa && pmd_write(*pmd);
>  	ret = 1;
>  
> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> +	if (is_swap_pmd(*pmd)) {
> +		swp_entry_t entry = pmd_to_swp_entry(*pmd);
> +
> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
> +				  !is_pmd_migration_entry(*pmd));
> +		if (is_write_migration_entry(entry)) {
> +			pmd_t newpmd;
> +
> +			make_migration_entry_read(&entry);
> +			newpmd = swp_entry_to_pmd(entry);
> +			set_pmd_at(mm, addr, pmd, newpmd);

I was confused by this. Could you copy comment from change_pte_range()
here?

> +		}
> +		goto unlock;
> +	}
> +#endif
> +
>  	/*
>  	 * Avoid trapping faults against the zero page. The read-only
>  	 * data is likely to be read-cached on the local CPU and

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
