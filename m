Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D03EC6B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:02:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u78so5702047wmd.13
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 01:02:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13si10632274wrf.311.2017.10.30.01.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 01:02:33 -0700 (PDT)
Date: Mon, 30 Oct 2017 09:02:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm -V2] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171030080230.apijacsx7fd3qeox@dhcp22.suse.cz>
References: <20171027055327.5428-1-ying.huang@intel.com>
 <20171029235713.GA4332@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171029235713.GA4332@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Mon 30-10-17 08:57:13, Minchan Kim wrote:
[...]
> Although it's better than old, we can make it simple, still.
> 
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 291c4b534658..f50d5a48f03a 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -41,6 +41,13 @@ static inline unsigned swp_type(swp_entry_t entry)
>  	return (entry.val >> SWP_TYPE_SHIFT(entry));
>  }
>  
> +extern struct swap_info_struct *swap_info[];
> +
> +static inline struct swap_info_struct *swp_si(swp_entry_t entry)
> +{
> +	return swap_info[swp_type(entry)];
> +}
> +
>  /*
>   * Extract the `offset' field from a swp_entry_t.  The swp_entry_t is in
>   * arch-independent format
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 378262d3a197..a0fe2d54ad09 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -554,6 +554,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct page *page;
> +	struct swap_info_struct *si = swp_si(entry);

Aren't you accessing beyond the array here?

>  	unsigned long entry_offset = swp_offset(entry);
>  	unsigned long offset = entry_offset;
>  	unsigned long start_offset, end_offset;
> @@ -572,6 +573,9 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  	if (!start_offset)	/* First page is swap header. */
>  		start_offset++;
>  
> +	if (end_offset >= si->max)
> +		end_offset = si->max - 1;
> +
>  	blk_start_plug(&plug);
>  	for (offset = start_offset; offset <= end_offset ; offset++) {
>  		/* Ok, do the async read-ahead now */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
