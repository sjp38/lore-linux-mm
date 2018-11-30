Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDBAC6B5AC4
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 18:32:08 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id j83so4788358ywa.11
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 15:32:08 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q37si4132801ywa.288.2018.11.30.15.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 15:32:07 -0800 (PST)
Date: Fri, 30 Nov 2018 15:32:01 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V7 RESEND 08/21] swap: Support to read a huge swap
 cluster for swapin a THP
Message-ID: <20181130233201.6yuzbhymtjddvf3u@ca-dmjordan1.us.oracle.com>
References: <20181120085449.5542-1-ying.huang@intel.com>
 <20181120085449.5542-9-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120085449.5542-9-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Hi Ying,

On Tue, Nov 20, 2018 at 04:54:36PM +0800, Huang Ying wrote:
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 97831166994a..1eedbc0aede2 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -387,14 +389,42 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 * as SWAP_HAS_CACHE.  That's done in later part of code or
>  		 * else swap_off will be aborted if we return NULL.
>  		 */
> -		if (!__swp_swapcount(entry) && swap_slot_cache_enabled)
> +		if (!__swp_swapcount(entry, &entry_size) &&
> +		    swap_slot_cache_enabled)
>  			break;
>  
>  		/*
>  		 * Get a new page to read into from swap.
>  		 */
> -		if (!new_page) {
> -			new_page = alloc_page_vma(gfp_mask, vma, addr);
> +		if (!new_page ||
> +		    (IS_ENABLED(CONFIG_THP_SWAP) &&
> +		     hpage_nr_pages(new_page) != entry_size)) {
> +			if (new_page)
> +				put_page(new_page);
> +			if (IS_ENABLED(CONFIG_THP_SWAP) &&
> +			    entry_size == HPAGE_PMD_NR) {
> +				gfp_t gfp;
> +
> +				gfp = alloc_hugepage_direct_gfpmask(vma, addr);

vma is NULL when we get here from try_to_unuse, so the kernel will die on
vma->flags inside alloc_hugepage_direct_gfpmask.

try_to_unuse swaps in before it finds vma's, but even if those were reversed,
it seems try_to_unuse wouldn't always have a single vma to pass into this path
since it's walking the swap_map and multiple processes mapping the same huge
page can have different huge page advice (and maybe mempolicies?), affecting
the result of alloc_hugepage_direct_gfpmask.  And yet
alloc_hugepage_direct_gfpmask needs a vma to do its job.  So, I'm not sure how
to fix this.

If the entry's usage count were 1, we could find the vma in that common case to
give read_swap_cache_async, and otherwise allocate small pages.  We'd have THPs
some of the time and be exactly following alloc_hugepage_direct_gfpmask, but
would also be conservative when it's uncertain.

Or, if the system-wide THP settings allow it then go for it, but otherwise
ignore vma hints and always fall back to small pages.  This requires another
way of controlling THP allocations besides alloc_hugepage_direct_gfpmask.

Or maybe try_to_unuse shouldn't allocate hugepages at all, but then no perf
improvement for try_to_unuse.

What do you think?
