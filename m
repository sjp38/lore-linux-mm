Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 573116B0307
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:12:06 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id m2-v6so10519442plt.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:12:06 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l4-v6si14997401plb.213.2018.07.09.10.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 10:12:05 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 04/21] mm, THP, swap: Support PMD swap mapping in
 swapcache_free_cluster()
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-5-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <dd7b3dd7-9e10-4b9f-b931-915298bfd627@linux.intel.com>
Date: Mon, 9 Jul 2018 10:11:57 -0700
MIME-Version: 1.0
In-Reply-To: <20180622035151.6676-5-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

> +#ifdef CONFIG_THP_SWAP
> +static inline int cluster_swapcount(struct swap_cluster_info *ci)
> +{
> +	if (!ci || !cluster_is_huge(ci))
> +		return 0;
> +
> +	return cluster_count(ci) - SWAPFILE_CLUSTER;
> +}
> +#else
> +#define cluster_swapcount(ci)			0
> +#endif

Dumb questions, round 2:  On a CONFIG_THP_SWAP=n build, presumably,
cluster_is_huge()=0 always, so cluster_swapout() always returns 0.  Right?

So, why the #ifdef?

>  /*
>   * It's possible scan_swap_map() uses a free cluster in the middle of free
>   * cluster list. Avoiding such abuse to avoid list corruption.
> @@ -905,6 +917,7 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
>  	struct swap_cluster_info *ci;
>  
>  	ci = lock_cluster(si, offset);
> +	memset(si->swap_map + offset, 0, SWAPFILE_CLUSTER);
>  	cluster_set_count_flag(ci, 0, 0);
>  	free_cluster(si, idx);
>  	unlock_cluster(ci);

This is another case of gloriously comment-free code, but stuff that
_was_ covered in the changelog.  I'd much rather have code comments than
changelog comments.  Could we fix that?

I'm generally finding it quite hard to review this because I keep having
to refer back to the changelog to see if what you are doing matches what
you said you were doing.

> @@ -1288,24 +1301,30 @@ static void swapcache_free_cluster(swp_entry_t entry)
>  
>  	ci = lock_cluster(si, offset);
>  	VM_BUG_ON(!cluster_is_huge(ci));
> +	VM_BUG_ON(!is_cluster_offset(offset));
> +	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
>  	map = si->swap_map + offset;
> -	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
> -		val = map[i];
> -		VM_BUG_ON(!(val & SWAP_HAS_CACHE));
> -		if (val == SWAP_HAS_CACHE)
> -			free_entries++;
> +	if (!cluster_swapcount(ci)) {
> +		for (i = 0; i < SWAPFILE_CLUSTER; i++) {
> +			val = map[i];
> +			VM_BUG_ON(!(val & SWAP_HAS_CACHE));
> +			if (val == SWAP_HAS_CACHE)
> +				free_entries++;
> +		}
> +		if (free_entries != SWAPFILE_CLUSTER)
> +			cluster_clear_huge(ci);
>  	}

Also, I'll point out that cluster_swapcount() continues the horrific
naming of cluster_couunt(), not saying what the count is *of*.  The
return value doesn't help much:

	return cluster_count(ci) - SWAPFILE_CLUSTER;
