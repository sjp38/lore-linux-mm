Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E97CC6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:57:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y63so1761392pff.5
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:57:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t62si9238041pfa.49.2018.01.19.04.57.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 04:57:11 -0800 (PST)
Date: Fri, 19 Jan 2018 13:57:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2] mm, page_vma_mapped: Drop faulty pointer arithmetics
 in check_pte()
Message-ID: <20180119125707.GB6584@dhcp22.suse.cz>
References: <20180119124924.25642-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119124924.25642-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, torvalds@linux-foundation.org, aarcange@redhat.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri 19-01-18 15:49:24, Kirill A. Shutemov wrote:
> Tetsuo reported random crashes under memory pressure on 32-bit x86
> system and tracked down to change that introduced
> page_vma_mapped_walk().
> 
> The root cause of the issue is the faulty pointer math in check_pte().
> As ->pte may point to an arbitrary page we have to check that they are
> belong to the section before doing math. Otherwise it may lead to weird
> results.
> 
> It wasn't noticed until now as mem_map[] is virtually contiguous on
> flatmem or vmemmap sparsemem. Pointer arithmetic just works against all
> 'struct page' pointers. But with classic sparsemem, it doesn't because
> each section memap is allocated separately and so consecutive pfns
> crossing two sections might have struct pages at completely unrelated
> addresses.
> 
> Let's restructure code a bit and replace pointer arithmetic with
> operations on pfns.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> Cc: stable@vger.kernel.org

Much better. Thanks!
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  v2:
>    - Do not use uninitialized 'pfn' for !MIGRATION case (Michal)
> 
> ---
>  include/linux/swapops.h | 21 +++++++++++++++++
>  mm/page_vma_mapped.c    | 63 +++++++++++++++++++++++++++++--------------------
>  2 files changed, 59 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 9c5a2628d6ce..1d3877c39a00 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -124,6 +124,11 @@ static inline bool is_write_device_private_entry(swp_entry_t entry)
>  	return unlikely(swp_type(entry) == SWP_DEVICE_WRITE);
>  }
>  
> +static inline unsigned long device_private_entry_to_pfn(swp_entry_t entry)
> +{
> +	return swp_offset(entry);
> +}
> +
>  static inline struct page *device_private_entry_to_page(swp_entry_t entry)
>  {
>  	return pfn_to_page(swp_offset(entry));
> @@ -154,6 +159,11 @@ static inline bool is_write_device_private_entry(swp_entry_t entry)
>  	return false;
>  }
>  
> +static inline unsigned long device_private_entry_to_pfn(swp_entry_t entry)
> +{
> +	return 0;
> +}
> +
>  static inline struct page *device_private_entry_to_page(swp_entry_t entry)
>  {
>  	return NULL;
> @@ -189,6 +199,11 @@ static inline int is_write_migration_entry(swp_entry_t entry)
>  	return unlikely(swp_type(entry) == SWP_MIGRATION_WRITE);
>  }
>  
> +static inline unsigned long migration_entry_to_pfn(swp_entry_t entry)
> +{
> +	return swp_offset(entry);
> +}
> +
>  static inline struct page *migration_entry_to_page(swp_entry_t entry)
>  {
>  	struct page *p = pfn_to_page(swp_offset(entry));
> @@ -218,6 +233,12 @@ static inline int is_migration_entry(swp_entry_t swp)
>  {
>  	return 0;
>  }
> +
> +static inline unsigned long migration_entry_to_pfn(swp_entry_t entry)
> +{
> +	return 0;
> +}
> +
>  static inline struct page *migration_entry_to_page(swp_entry_t entry)
>  {
>  	return NULL;
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index d22b84310f6d..956015614395 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -30,10 +30,29 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
>  	return true;
>  }
>  
> +/**
> + * check_pte - check if @pvmw->page is mapped at the @pvmw->pte
> + *
> + * page_vma_mapped_walk() found a place where @pvmw->page is *potentially*
> + * mapped. check_pte() has to validate this.
> + *
> + * @pvmw->pte may point to empty PTE, swap PTE or PTE pointing to arbitrary
> + * page.
> + *
> + * If PVMW_MIGRATION flag is set, returns true if @pvmw->pte contains migration
> + * entry that points to @pvmw->page or any subpage in case of THP.
> + *
> + * If PVMW_MIGRATION flag is not set, returns true if @pvmw->pte points to
> + * @pvmw->page or any subpage in case of THP.
> + *
> + * Otherwise, return false.
> + *
> + */
>  static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  {
> +	unsigned long pfn;
> +
>  	if (pvmw->flags & PVMW_MIGRATION) {
> -#ifdef CONFIG_MIGRATION
>  		swp_entry_t entry;
>  		if (!is_swap_pte(*pvmw->pte))
>  			return false;
> @@ -41,37 +60,31 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  
>  		if (!is_migration_entry(entry))
>  			return false;
> -		if (migration_entry_to_page(entry) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (migration_entry_to_page(entry) < pvmw->page)
> -			return false;
> -#else
> -		WARN_ON_ONCE(1);
> -#endif
> -	} else {
> -		if (is_swap_pte(*pvmw->pte)) {
> -			swp_entry_t entry;
>  
> -			entry = pte_to_swp_entry(*pvmw->pte);
> -			if (is_device_private_entry(entry) &&
> -			    device_private_entry_to_page(entry) == pvmw->page)
> -				return true;
> -		}
> +		pfn = migration_entry_to_pfn(entry);
> +	} else if (is_swap_pte(*pvmw->pte)) {
> +		swp_entry_t entry;
>  
> -		if (!pte_present(*pvmw->pte))
> +		/* Handle un-addressable ZONE_DEVICE memory */
> +		entry = pte_to_swp_entry(*pvmw->pte);
> +		if (!is_device_private_entry(entry))
>  			return false;
>  
> -		/* THP can be referenced by any subpage */
> -		if (pte_page(*pvmw->pte) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (pte_page(*pvmw->pte) < pvmw->page)
> +		pfn = device_private_entry_to_pfn(entry);
> +	} else {
> +		if (!pte_present(*pvmw->pte))
>  			return false;
> +
> +		pfn = pte_pfn(*pvmw->pte);
>  	}
>  
> +	if (pfn < page_to_pfn(pvmw->page))
> +		return false;
> +
> +	/* THP can be referenced by any subpage */
> +	if (pfn - page_to_pfn(pvmw->page) >= hpage_nr_pages(pvmw->page))
> +		return false;
> +
>  	return true;
>  }
>  
> -- 
> 2.15.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
