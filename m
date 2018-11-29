Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 034E66B51AB
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 03:39:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so742392edb.5
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 00:39:05 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si692681edk.240.2018.11.29.00.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 00:39:04 -0800 (PST)
Date: Thu, 29 Nov 2018 09:39:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove pte_lock_deinit()
Message-ID: <20181129083903.GP6923@dhcp22.suse.cz>
References: <20181128235525.58780-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128235525.58780-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Souptick Joarder <jrdr.linux@gmail.com>, Logan Gunthorpe <logang@deltatee.com>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 28-11-18 16:55:25, Yu Zhao wrote:
> Pagetable page doesn't touch page->mapping or have any used field
> that overlaps with it. No need to clear mapping in dtor. In fact,
> doing so might mask problems that otherwise would be detected by
> bad_page().

yes the layour of the structure has changed since Hugh introduced the
pte lock split

> Signed-off-by: Yu Zhao <yuzhao@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5411de93a363..7c8f4fc9244e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1900,13 +1900,6 @@ static inline bool ptlock_init(struct page *page)
>  	return true;
>  }
>  
> -/* Reset page->mapping so free_pages_check won't complain. */
> -static inline void pte_lock_deinit(struct page *page)
> -{
> -	page->mapping = NULL;
> -	ptlock_free(page);
> -}
> -
>  #else	/* !USE_SPLIT_PTE_PTLOCKS */
>  /*
>   * We use mm->page_table_lock to guard all pagetable pages of the mm.
> @@ -1917,7 +1910,7 @@ static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
>  }
>  static inline void ptlock_cache_init(void) {}
>  static inline bool ptlock_init(struct page *page) { return true; }
> -static inline void pte_lock_deinit(struct page *page) {}
> +static inline void ptlock_free(struct page *page) {}
>  #endif /* USE_SPLIT_PTE_PTLOCKS */
>  
>  static inline void pgtable_init(void)
> @@ -1937,7 +1930,7 @@ static inline bool pgtable_page_ctor(struct page *page)
>  
>  static inline void pgtable_page_dtor(struct page *page)
>  {
> -	pte_lock_deinit(page);
> +	ptlock_free(page);
>  	__ClearPageTable(page);
>  	dec_zone_page_state(page, NR_PAGETABLE);
>  }
> -- 
> 2.20.0.rc1.387.gf8505762e3-goog
> 

-- 
Michal Hocko
SUSE Labs
