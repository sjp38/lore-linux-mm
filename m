Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD2B16B0292
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 21:02:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e12so278140pgu.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 18:02:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b188si7317092pgc.452.2018.01.18.18.02.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 18:02:19 -0800 (PST)
Message-Id: <201801190201.w0J21YEM099982@www262.sakura.ne.jp>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 19 Jan 2018 11:01:34 +0900
References: <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com> <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
In-Reply-To: <20180118154026.jzdgdhkcxiliaulp@node.shutemov.name>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, torvalds@linux-foundation.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Kirill A. Shutemov wrote:
> Something like this?
> 
> 
> From 251e124630da82482e8b320c73162ce89af04d5d Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Thu, 18 Jan 2018 18:24:07 +0300
> Subject: [PATCH] mm, page_vma_mapped: Fix pointer arithmetics in check_pte()
> 
> Tetsuo reported random crashes under memory pressure on 32-bit x86
> system and tracked down to change that introduced
> page_vma_mapped_walk().
> 
> The root cause of the issue is the faulty pointer math in check_pte().
> As ->pte may point to an arbitrary page we have to check that they are
> belong to the section before doing math. Otherwise it may lead to weird
> results.
> 
> It wasn't noticed until now as mem_map[] is virtually contiguous on flatmem or
> vmemmap sparsemem. Pointer arithmetic just works against all 'struct page'
> pointers. But with classic sparsemem, it doesn't.
> 
> Let's restructure code a bit and add necessary check.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Fixes: ace71a19cec5 ("mm: introduce page_vma_mapped_walk()")
> Cc: stable@vger.kernel.org

This patch solves the problem. Thank you.

Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

> ---
>  mm/page_vma_mapped.c | 66 +++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 45 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index d22b84310f6d..de195dcdfbd8 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -30,8 +30,28 @@ static bool map_pte(struct page_vma_mapped_walk *pvmw)
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
> +	struct page *page;
> +
>  	if (pvmw->flags & PVMW_MIGRATION) {
>  #ifdef CONFIG_MIGRATION
>  		swp_entry_t entry;
> @@ -41,37 +61,41 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  
>  		if (!is_migration_entry(entry))
>  			return false;
> -		if (migration_entry_to_page(entry) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (migration_entry_to_page(entry) < pvmw->page)
> -			return false;
> +
> +		page = migration_entry_to_page(entry);
>  #else
>  		WARN_ON_ONCE(1);
>  #endif
> -	} else {
> -		if (is_swap_pte(*pvmw->pte)) {
> -			swp_entry_t entry;
> +	} else if (is_swap_pte(*pvmw->pte)) {
> +		swp_entry_t entry;
>  
> -			entry = pte_to_swp_entry(*pvmw->pte);
> -			if (is_device_private_entry(entry) &&
> -			    device_private_entry_to_page(entry) == pvmw->page)
> -				return true;
> -		}
> +		/* Handle un-addressable ZONE_DEVICE memory */
> +		entry = pte_to_swp_entry(*pvmw->pte);
> +		if (!is_device_private_entry(entry))
> +			return false;
>  
> +		page = device_private_entry_to_page(entry);
> +	} else {
>  		if (!pte_present(*pvmw->pte))
>  			return false;
>  
> -		/* THP can be referenced by any subpage */
> -		if (pte_page(*pvmw->pte) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {
> -			return false;
> -		}
> -		if (pte_page(*pvmw->pte) < pvmw->page)
> -			return false;
> +		page = pte_page(*pvmw->pte);
>  	}
>  
> +	/*
> +	 * Make sure that pages are in the same section before doing pointer
> +	 * arithmetics.
> +	 */
> +	if (page_to_section(pvmw->page) != page_to_section(page))
> +		return false;
> +
> +	if (page < pvmw->page)
> +		return false;
> +
> +	/* THP can be referenced by any subpage */
> +	if (page - pvmw->page >= hpage_nr_pages(pvmw->page))
> +		return false;
> +
>  	return true;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
