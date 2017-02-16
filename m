Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD35C681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:40:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 89so4517362wrr.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:40:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e11si1816343wrc.310.2017.02.16.10.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 10:40:30 -0800 (PST)
Date: Thu, 16 Feb 2017 13:40:18 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170216184018.GC20791@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> @@ -1419,11 +1419,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
>  				page);
>  
> -			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
> -				/* It's a freeable page by MADV_FREE */
> -				dec_mm_counter(mm, MM_ANONPAGES);
> -				rp->lazyfreed++;
> -				goto discard;
> +			if (flags & TTU_LZFREE) {
> +				if (!PageDirty(page)) {
> +					/* It's a freeable page by MADV_FREE */
> +					dec_mm_counter(mm, MM_ANONPAGES);
> +					rp->lazyfreed++;
> +					goto discard;
> +				} else {
> +					set_pte_at(mm, address, pvmw.pte, pteval);
> +					ret = SWAP_FAIL;
> +					page_vma_mapped_walk_done(&pvmw);
> +					break;
> +				}

I don't understand why we need the TTU_LZFREE bit in general. More on
that below at the callsite.

> @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
>  	 * Anonymous pages are not handled by flushers and must be written
>  	 * from reclaim context. Do not stall reclaim based on them
>  	 */
> -	if (!page_is_file_cache(page)) {
> +	if (!page_is_file_cache(page) || page_is_lazyfree(page)) {

Do we need this? MADV_FREE clears the dirty bit off the page; we could
just let them go through with the function without any special-casing.

> @@ -986,6 +986,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		sc->nr_scanned++;
>  
> +		lazyfree = page_is_lazyfree(page);
> +
>  		if (unlikely(!page_evictable(page)))
>  			goto cull_mlocked;
>  
> @@ -993,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto keep_locked;
>  
>  		/* Double the slab pressure for mapped and swapcache pages */
> -		if (page_mapped(page) || PageSwapCache(page))
> +		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
>  			sc->nr_scanned++;
>  
>  		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> @@ -1119,13 +1121,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
> +		 * Lazyfree page could be freed directly
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page)) {
> +		if (PageAnon(page) && !PageSwapCache(page) && !lazyfree) {

lazyfree duplicates the anon check. As per the previous email, IMO it
would be much preferable to get rid of that "lazyfree" obscuring here.

This would simply be:

		if (PageAnon(page) && PageSwapBacked && !PageSwapCache)

> @@ -1142,7 +1144,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * The page is mapped into the page tables of one or more
>  		 * processes. Try to unmap it here.
>  		 */
> -		if (page_mapped(page) && mapping) {
> +		if (page_mapped(page) && (mapping || lazyfree)) {

Do we actually need to filter for mapping || lazyfree? If we fail to
allocate swap, we don't reach here. If the page is a truncated file
page, ttu returns pretty much instantly with SWAP_AGAIN. We should be
able to just check for page_mapped() alone, no?

>  			switch (ret = try_to_unmap(page, lazyfree ?
>  				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
>  				(ttu_flags | TTU_BATCH_FLUSH))) {

That bit I don't understand. Why do we need to pass TTU_LZFREE? What
information does that carry that cannot be gathered from inside ttu?

I.e. when ttu runs into PageAnon, can it simply check !PageSwapBacked?
And if it's still clean, it can lazyfreed++; goto discard.

Am I overlooking something?

> @@ -1154,7 +1156,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			case SWAP_MLOCK:
>  				goto cull_mlocked;
>  			case SWAP_LZFREE:
> -				goto lazyfree;
> +				/* follow __remove_mapping for reference */
> +				if (page_ref_freeze(page, 1)) {
> +					if (!PageDirty(page))
> +						goto lazyfree;
> +					else
> +						page_ref_unfreeze(page, 1);
> +				}
> +				goto keep_locked;
>  			case SWAP_SUCCESS:
>  				; /* try to free the page below */

This is a similar situation.

Can we let the page go through the regular __remove_mapping() process
and simply have that function check for PageAnon && !PageSwapBacked?

> @@ -1266,10 +1275,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -lazyfree:
>  		if (!mapping || !__remove_mapping(mapping, page, true))
>  			goto keep_locked;
> -
> +lazyfree:

... eliminating this special casing.

> @@ -1294,6 +1302,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  cull_mlocked:
>  		if (PageSwapCache(page))
>  			try_to_free_swap(page);
> +		if (lazyfree)
> +			clear_page_lazyfree(page);

Why cancel the MADV_FREE state? The combination seems non-sensical,
but we can simply retain the invalidated state while the page goes to
the unevictable list; munlock should move it back to inactive_file.

>  		unlock_page(page);
>  		list_add(&page->lru, &ret_pages);
>  		continue;
> @@ -1303,6 +1313,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
>  			try_to_free_swap(page);
>  		VM_BUG_ON_PAGE(PageActive(page), page);
> +		if (lazyfree)
> +			clear_page_lazyfree(page);

This is similar too.

Can we leave simply leave the page alone here? The only way we get to
this point is if somebody is reading the invalidated page. It's weird
for a lazyfreed page to become active, but it doesn't seem to warrant
active intervention here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
