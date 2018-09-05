Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1C06B71AD
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 02:24:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v9-v6so3253581ply.13
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 23:24:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d35-v6si1024468pla.116.2018.09.04.23.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 23:24:31 -0700 (PDT)
Date: Wed, 5 Sep 2018 08:24:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
Message-ID: <20180905062428.GV14951@dhcp22.suse.cz>
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183345.4416.76515.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904183345.4416.76515.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Tue 04-09-18 11:33:45, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> It doesn't make much sense to use the atomic SetPageReserved at init time
> when we are using memset to clear the memory and manipulating the page
> flags via simple "&=" and "|=" operations in __init_single_page.
> 
> This patch adds a non-atomic version __SetPageReserved that can be used
> during page init and shows about a 10% improvement in initialization times
> on the systems I have available for testing.

I agree with Dave about a comment is due. I am also quite surprised that
this leads to such a large improvement. Could you be more specific about
your test and machines you were testing on?

Other than that the patch makes sense to me.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

With the above addressed, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/page-flags.h |    1 +
>  mm/page_alloc.c            |    4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74bee8cecf4c..57ec3fef7e9f 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -292,6 +292,7 @@ static inline int PagePoisoned(const struct page *page)
>  
>  PAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
>  	__CLEARPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
> +	__SETPAGEFLAG(Reserved, reserved, PF_NO_COMPOUND)
>  PAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
>  	__CLEARPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
>  	__SETPAGEFLAG(SwapBacked, swapbacked, PF_NO_TAIL)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 05e983f42316..9c7d6e971630 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1231,7 +1231,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  			/* Avoid false-positive PageTail() */
>  			INIT_LIST_HEAD(&page->lru);
>  
> -			SetPageReserved(page);
> +			__SetPageReserved(page);
>  		}
>  	}
>  }
> @@ -5518,7 +5518,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		page = pfn_to_page(pfn);
>  		__init_single_page(page, pfn, zone, nid);
>  		if (context == MEMMAP_HOTPLUG)
> -			SetPageReserved(page);
> +			__SetPageReserved(page);
>  
>  		/*
>  		 * Mark the block movable so that blocks are reserved for
> 

-- 
Michal Hocko
SUSE Labs
