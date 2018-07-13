Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFB2D6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:16:06 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id z33-v6so10418978uah.4
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:16:06 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 96-v6si10137249uaz.261.2018.07.13.13.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 13:16:05 -0700 (PDT)
Date: Fri, 13 Jul 2018 13:15:57 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH 3/6] swap: Unify normal/huge code path in
 swap_page_trans_huge_swapped()
Message-ID: <20180713201557.bjt4tj26nisgdmmi@ca-dmjordan1.us.oracle.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
 <20180712233636.20629-4-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712233636.20629-4-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Jul 13, 2018 at 07:36:33AM +0800, Huang, Ying wrote:
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 75c84aa763a3..160f78072667 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -270,7 +270,10 @@ static inline void cluster_set_null(struct swap_cluster_info *info)
>  
>  static inline bool cluster_is_huge(struct swap_cluster_info *info)
>  {
> -	return info->flags & CLUSTER_FLAG_HUGE;
> +	if (IS_ENABLED(CONFIG_THP_SWAP))
> +		return info->flags & CLUSTER_FLAG_HUGE;
> +	else
> +		return false;
>  }
>  
>  static inline void cluster_clear_huge(struct swap_cluster_info *info)
> @@ -1489,9 +1492,6 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
>  	int i;
>  	bool ret = false;
>  
> -	if (!IS_ENABLED(CONFIG_THP_SWAP))
> -		return swap_swapcount(si, entry) != 0;

This tests the value returned from swap_count,

> -
>  	ci = lock_cluster_or_swap_info(si, offset);
>  	if (!ci || !cluster_is_huge(ci)) {
>  		if (map[roffset] != SWAP_HAS_CACHE)

and now we're testing

                    map[roffset] != SWAP_HAS_CACHE

instead.  The two seem to mean the same thing here, since the swap slot hasn't
been freed to the global pool and so can't be 0, but it might be better for
consistency and clarity to use swap_count here, and a few lines down too

        for (i = 0; i < SWAPFILE_CLUSTER; i++) {                                     
                if (map[offset + i] != SWAP_HAS_CACHE) {                             

since swap_count seems to be used everywhere else for this.
