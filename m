Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9FA6B03A0
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:53:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 2so1503326wmp.21
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:53:03 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 126si4725411wmq.11.2017.04.19.08.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 08:53:01 -0700 (PDT)
Date: Wed, 19 Apr 2017 11:52:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v9 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170419155252.GA3376@cmpxchg.org>
References: <20170419070625.19776-1-ying.huang@intel.com>
 <20170419070625.19776-2-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419070625.19776-2-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

On Wed, Apr 19, 2017 at 03:06:23PM +0800, Huang, Ying wrote:
> @@ -206,17 +212,34 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	 */
>  	err = add_to_swap_cache(page, entry,
>  			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
> -
> -	if (!err) {
> -		return 1;
> -	} else {	/* -ENOMEM radix-tree allocation failure */
> +	/* -ENOMEM radix-tree allocation failure */
> +	if (err)
>  		/*
>  		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
>  		 * clear SWAP_HAS_CACHE flag.
>  		 */
> -		swapcache_free(entry);
> -		return 0;
> +		goto fail_free;
> +
> +	if (unlikely(PageTransHuge(page))) {
> +		err = split_huge_page_to_list(page, list);
> +		if (err) {
> +			delete_from_swap_cache(page);
> +			return 0;
> +		}
>  	}
> +
> +	return 1;
> +
> +fail_free:
> +	if (unlikely(PageTransHuge(page)))
> +		swapcache_free_cluster(entry);
> +	else
> +		swapcache_free(entry);
> +fail:
> +	if (unlikely(PageTransHuge(page)) &&
> +	    !split_huge_page_to_list(page, list))
> +		goto retry;

May I ask why you added the unlikelies there? Can you generally say
THPs are unlikely in this path? Is the swap-out path so hot that
branch layout is critical? I doubt either is true.

Also please mention changes like these in the changelog next time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
