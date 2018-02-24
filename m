Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAC086B0005
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 19:49:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e1so4997938pfi.10
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 16:49:29 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r3-v6si2653666plb.197.2018.02.23.16.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 16:49:28 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm: Report bad PTEs in lookup_swap_cache()
References: <20180223200341.17627-1-willy@infradead.org>
Date: Sat, 24 Feb 2018 08:49:26 +0800
In-Reply-To: <20180223200341.17627-1-willy@infradead.org> (Matthew Wilcox's
	message of "Fri, 23 Feb 2018 12:03:41 -0800")
Message-ID: <87zi3z2ovd.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

Matthew Wilcox <willy@infradead.org> writes:

> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> If we have garbage in the PTE, we can call the radix tree code with a
> NULL radix tree head which leads to an OOPS.  Detect the case where
> we've found a PTE that refers to a non-existent swap device and report
> the error correctly.

There is a patch in -mm tree which addresses this problem at least
partially as follow.  Please take a look at it.

https://www.spinics.net/lists/linux-mm/msg145242.html

[snip]

> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 39ae7cfad90f..5a7755ecbb03 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -328,14 +328,22 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
>   * lock getting page table operations atomic even if we drop the page
>   * lock before returning.
>   */
> -struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
> -			       unsigned long addr)
> +struct page *lookup_swap_cache(swp_entry_t entry, bool vma_ra,
> +			struct vm_fault *vmf)
>  {
>  	struct page *page;
> -	unsigned long ra_info;
> -	int win, hits, readahead;
> +	int readahead;
> +	struct address_space *swapper_space = swap_address_space(entry);
>  
> -	page = find_get_page(swap_address_space(entry), swp_offset(entry));
> +	if (!swapper_space) {
> +		if (vmf)
> +			pte_ERROR(vmf->orig_pte);
> +		else
> +			pr_err("Bad swp_entry: %lx\n", entry.val);

>From we get swap_entry from PTE to lookup_swap_cache(), nothing prevent
the swap device to be swapoff.  So, I think sometimes it is hard to
distinguish between garbage PTEs and PTEs which become deprecated
because of swapoff.

Best Regards,
Huang, Ying

> +		return NULL;
> +	}
> +
> +	page = find_get_page(swapper_space, swp_offset(entry));
>  
>  	INC_CACHE_INFO(find_total);
>  	if (page) {

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
