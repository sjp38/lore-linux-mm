Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E16E6B06D8
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:28:33 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id a188-v6so729024oih.0
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:28:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b43si2947118oth.256.2018.11.09.02.28.32
        for <linux-mm@kvack.org>;
        Fri, 09 Nov 2018 02:28:32 -0800 (PST)
Subject: Re: [RFC][PATCH v1 03/11] mm: move definition of
 num_poisoned_pages_inc/dec to include/linux/mm.h
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-4-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <e4c4ae14-0d55-0738-9257-2c1232acef33@arm.com>
Date: Fri, 9 Nov 2018 15:58:27 +0530
MIME-Version: 1.0
In-Reply-To: <1541746035-13408-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> num_poisoned_pages_inc/dec had better be visible to some file like
> mm/sparse.c and mm/page_alloc.c (for a subsequent patch). So let's
> move it to include/linux/mm.h.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/mm.h      | 13 ++++++++++++-
>  include/linux/swapops.h | 16 ----------------
>  mm/sparse.c             |  2 +-
>  3 files changed, 13 insertions(+), 18 deletions(-)
> 
> diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
> index 59df394..22623ba 100644
> --- v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h
> +++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
> @@ -2741,7 +2741,7 @@ extern void shake_page(struct page *p, int access);
>  extern atomic_long_t num_poisoned_pages __read_mostly;
>  extern int soft_offline_page(struct page *page, int flags);
>  
> -
> +#ifdef CONFIG_MEMORY_FAILURE
>  /*
>   * Error handlers for various types of pages.
>   */
> @@ -2777,6 +2777,17 @@ enum mf_action_page_type {
>  	MF_MSG_UNKNOWN,
>  };
>  
> +static inline void num_poisoned_pages_inc(void)
> +{
> +	atomic_long_inc(&num_poisoned_pages);
> +}
> +
> +static inline void num_poisoned_pages_dec(void)
> +{
> +	atomic_long_dec(&num_poisoned_pages);
> +}
> +#endif
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr_hint,
> diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h v4.19-mmotm-2018-10-30-16-08_patched/include/linux/swapops.h
> index 4d96166..88137e9 100644
> --- v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h
> +++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/swapops.h
> @@ -320,8 +320,6 @@ static inline int is_pmd_migration_entry(pmd_t pmd)
>  
>  #ifdef CONFIG_MEMORY_FAILURE
>  
> -extern atomic_long_t num_poisoned_pages __read_mostly;
> -
>  /*
>   * Support for hardware poisoned pages
>   */
> @@ -336,16 +334,6 @@ static inline int is_hwpoison_entry(swp_entry_t entry)
>  	return swp_type(entry) == SWP_HWPOISON;
>  }
>  
> -static inline void num_poisoned_pages_inc(void)
> -{
> -	atomic_long_inc(&num_poisoned_pages);
> -}
> -
> -static inline void num_poisoned_pages_dec(void)
> -{
> -	atomic_long_dec(&num_poisoned_pages);
> -}
> -
>  #else
>  
>  static inline swp_entry_t make_hwpoison_entry(struct page *page)
> @@ -357,10 +345,6 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
>  {
>  	return 0;
>  }
> -
> -static inline void num_poisoned_pages_inc(void)
> -{
> -}

I hope this was a stray definition and redundant which does not prevent
build in absence of CONFIG_MEMORY_FAILURE.

>  #endif
>  
>  #if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
> diff --git v4.19-mmotm-2018-10-30-16-08/mm/sparse.c v4.19-mmotm-2018-10-30-16-08_patched/mm/sparse.c
> index 33307fc..7ada2e5 100644
> --- v4.19-mmotm-2018-10-30-16-08/mm/sparse.c
> +++ v4.19-mmotm-2018-10-30-16-08_patched/mm/sparse.c
> @@ -726,7 +726,7 @@ static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		if (PageHWPoison(&memmap[i])) {
> -			atomic_long_sub(1, &num_poisoned_pages);
> +			num_poisoned_pages_dec();
>  			ClearPageHWPoison(&memmap[i]);
>  		}
>  	}
> 

Otherwise looks good.

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
