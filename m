Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EECBD6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:19:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z61so17703196wrc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:19:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o110si6645202wrc.152.2017.02.23.08.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 08:19:38 -0800 (PST)
Date: Thu, 23 Feb 2017 11:13:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170223161342.GC4031@cmpxchg.org>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 10:50:42AM -0800, Shaohua Li wrote:
> @@ -1424,6 +1424,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  				dec_mm_counter(mm, MM_ANONPAGES);
>  				rp->lazyfreed++;
>  				goto discard;
> +			} else if (!PageSwapBacked(page)) {
> +				/* dirty MADV_FREE page */
> +				set_pte_at(mm, address, pvmw.pte, pteval);
> +				ret = SWAP_DIRTY;
> +				page_vma_mapped_walk_done(&pvmw);
> +				break;
>  			}
>  
>  			if (swap_duplicate(entry) < 0) {
> @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  
>  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
>  		ret = SWAP_SUCCESS;
> -		if (rp.lazyfreed && !PageDirty(page))
> -			ret = SWAP_LZFREE;
> +		if (rp.lazyfreed && PageDirty(page))
> +			ret = SWAP_DIRTY;

Can this actually happen? If the page is dirty, ret should already be
SWAP_DIRTY, right? How would a dirty page get fully unmapped?

It seems to me rp.lazyfreed can be removed entirely now that we don't
have to identify the lazyfree case anymore. The failure case is much
easier to identify - all it takes is a single pte to be dirty.

> @@ -1118,8 +1120,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		/*
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
> +		 * Lazyfree page could be freed directly
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page)) {
> +		if (PageAnon(page) && !PageSwapCache(page) &&
> +		    PageSwapBacked(page)) {

Nit: I'd do PageAnon(page) && PageSwapBacked(page) && !PageSwapCache()
since anon && swapbacked together describe the page type and swapcache
the state. Plus, anon && swapbacked go together everywhere else.

Otherwise, looks very straight-forward!

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
