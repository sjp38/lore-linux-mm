Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF776B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 02:21:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x23-v6so4463173pln.11
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 23:21:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 97-v6si8605592pld.345.2018.06.28.23.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Jun 2018 23:21:28 -0700 (PDT)
Date: Thu, 28 Jun 2018 23:21:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH -mm -v4 08/21] mm, THP, swap: Support to read a huge swap
 cluster for swapin a THP
Message-ID: <20180629062126.GJ7646@bombadil.infradead.org>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-9-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622035151.6676-9-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Fri, Jun 22, 2018 at 11:51:38AM +0800, Huang, Ying wrote:
> +++ b/mm/swap_state.c
> @@ -426,33 +447,37 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		/*
>  		 * call radix_tree_preload() while we can wait.
>  		 */
> -		err = radix_tree_maybe_preload(gfp_mask & GFP_KERNEL);
> +		err = radix_tree_maybe_preload_order(gfp_mask & GFP_KERNEL,
> +						     compound_order(new_page));
>  		if (err)
>  			break;

There's no more preloading in the XArray world, so this can just be dropped.

>  		/*
>  		 * Swap entry may have been freed since our caller observed it.
>  		 */
> +		err = swapcache_prepare(hentry, huge_cluster);
> +		if (err) {
>  			radix_tree_preload_end();
> -			break;
> +			if (err == -EEXIST) {
> +				/*
> +				 * We might race against get_swap_page() and
> +				 * stumble across a SWAP_HAS_CACHE swap_map
> +				 * entry whose page has not been brought into
> +				 * the swapcache yet.
> +				 */
> +				cond_resched();
> +				continue;
> +			} else if (err == -ENOTDIR) {
> +				/* huge swap cluster is split under us */
> +				continue;
> +			} else		/* swp entry is obsolete ? */
> +				break;

I'm not entirely happy about -ENOTDIR being overloaded to mean this.
Maybe we can return a new enum rather than an errno?

Also, I'm not sure that a true/false parameter is the right approach for
"is this a huge page".  I think we'll have usecases for swap entries which
are both larger and smaller than PMD_SIZE.

I was hoping to encode the swap entry size into the entry; we only need one
extra bit to do that (no matter the size of the entry).  I detailed the
encoding scheme here:

https://plus.google.com/117536210417097546339/posts/hvctn17WUZu

(let me know if that doesn't work for you; I'm not very experienced with
this G+ thing)
