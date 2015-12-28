Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3A86B02A1
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 05:05:55 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l126so263475434wml.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 02:05:55 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id w6si79844232wju.89.2015.12.28.02.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 02:05:53 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l65so1844597wmf.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 02:05:53 -0800 (PST)
Date: Mon, 28 Dec 2015 12:05:51 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/8] mm: Add optional support for PUD-sized transparent
 hugepages
Message-ID: <20151228100551.GA4589@node.shutemov.name>
References: <1450974037-24775-1-git-send-email-matthew.r.wilcox@intel.com>
 <1450974037-24775-2-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450974037-24775-2-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu, Dec 24, 2015 at 11:20:30AM -0500, Matthew Wilcox wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4bf3811..e14634f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1958,6 +1977,17 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
>  	return ptl;
>  }
>  
> +/*
> + * No scalability reason to split PUD locks yet, but follow the same pattern
> + * as the PMD locks to make it easier if we have to.
> + */

I don't think it makes any good unless you convert all other places where
we use page_table_lock to protect pud table (like __pud_alloc()) to the
same API.
I think this would deserve separate patch.

> +static inline spinlock_t *pud_lock(struct mm_struct *mm, pud_t *pud)
> +{
> +	spinlock_t *ptl = &mm->page_table_lock;
> +	spin_lock(ptl);
> +	return ptl;
> +}
> +
>  extern void free_area_init(unsigned long * zones_size);
>  extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);

...

> diff --git a/mm/memory.c b/mm/memory.c
> index 416b129..7328df0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1220,9 +1220,27 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>  	pud = pud_offset(pgd, addr);
>  	do {
>  		next = pud_addr_end(addr, end);
> +		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
> +			if (next - addr != HPAGE_PUD_SIZE) {
> +#ifdef CONFIG_DEBUG_VM

IS_ENABLED(CONFIG_DEBUG_VM) ?

> +				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
> +					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
> +						__func__, addr, end,
> +						vma->vm_start,
> +						vma->vm_end);

dump_vma(), I guess.

> +					BUG();
> +				}
> +#endif
> +				split_huge_pud(vma, pud, addr);
> +			} else if (zap_huge_pud(tlb, vma, pud, addr))
> +				goto next;
> +			/* fall through */
> +		}
>  		if (pud_none_or_clear_bad(pud))
>  			continue;
>  		next = zap_pmd_range(tlb, vma, pud, addr, next, details);
> +next:
> +		cond_resched();
>  	} while (pud++, addr = next, addr != end);
>  
>  	return addr;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
