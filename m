Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 958126B0006
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 03:02:31 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id p13so3560522plr.10
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 00:02:31 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u17si1427514pfm.190.2018.02.23.00.02.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 00:02:30 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH RESEND 1/2] mm: swap: clean up swap readahead
References: <20180220085249.151400-1-minchan@kernel.org>
	<20180220085249.151400-2-minchan@kernel.org>
Date: Fri, 23 Feb 2018 16:02:27 +0800
In-Reply-To: <20180220085249.151400-2-minchan@kernel.org>
	(minchan@kernel.org's message of "Tue, 20 Feb 2018 17:52:48 +0900")
Message-ID: <874lm83zho.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

<minchan@kernel.org> writes:
[snip]

> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 39ae7cfad90f..c56cce64b2c3 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -332,32 +332,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  			       unsigned long addr)
>  {
>  	struct page *page;
> -	unsigned long ra_info;
> -	int win, hits, readahead;
>  
>  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
>  
>  	INC_CACHE_INFO(find_total);
>  	if (page) {
> +		bool vma_ra = swap_use_vma_readahead();
> +		bool readahead = TestClearPageReadahead(page);
> +

TestClearPageReadahead() cannot be called for compound page.  As in

PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)

>  		INC_CACHE_INFO(find_success);
>  		if (unlikely(PageTransCompound(page)))
>  			return page;
> -		readahead = TestClearPageReadahead(page);

So we can only call it here after checking whether page is compound.

Best Regards,
Huang, Ying

> -		if (vma) {
> -			ra_info = GET_SWAP_RA_VAL(vma);
> -			win = SWAP_RA_WIN(ra_info);
> -			hits = SWAP_RA_HITS(ra_info);
> +
> +		if (vma && vma_ra) {
> +			unsigned long ra_val;
> +			int win, hits;
> +
> +			ra_val = GET_SWAP_RA_VAL(vma);
> +			win = SWAP_RA_WIN(ra_val);
> +			hits = SWAP_RA_HITS(ra_val);
>  			if (readahead)
>  				hits = min_t(int, hits + 1, SWAP_RA_HITS_MAX);
>  			atomic_long_set(&vma->swap_readahead_info,
>  					SWAP_RA_VAL(addr, win, hits));
>  		}
> +
>  		if (readahead) {
>  			count_vm_event(SWAP_RA_HIT);
> -			if (!vma)
> +			if (!vma || !vma_ra)
>  				atomic_inc(&swapin_readahead_hits);
>  		}
>  	}
> +
>  	return page;
>  }
>

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
