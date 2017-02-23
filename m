Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3079E6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 11:04:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s27so18018095wrb.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 08:04:24 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j140si7495132wmg.23.2017.02.23.08.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 08:04:22 -0800 (PST)
Date: Thu, 23 Feb 2017 10:58:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V4 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170223155827.GB4031@cmpxchg.org>
References: <cover.1487788131.git.shli@fb.com>
 <a1a28aa85280a7b3fd6145604eed4132228bd6d1.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1a28aa85280a7b3fd6145604eed4132228bd6d1.1487788131.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Shaohua,

On Wed, Feb 22, 2017 at 10:50:41AM -0800, Shaohua Li wrote:
> @@ -268,6 +268,12 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  		int lru = page_lru_base_type(page);
>  
>  		del_page_from_lru_list(page, lruvec, lru);
> +		if (PageAnon(page) && !PageSwapBacked(page)) {
> +			SetPageSwapBacked(page);
> +			/* charge to anon scanned/rotated reclaim_stat */
> +			file = 0;
> +			lru = LRU_INACTIVE_ANON;
> +		}

As per my previous feedback, please remove this. Write-after-free will
be caught and handled in the reclaimer, read-after-free is a bug that
really doesn't require optimizing page aging for. And we definitely
shouldn't declare invalid data suddenly valid because it's being read.

> @@ -561,20 +567,26 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  }
>  
>  
> -static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> +static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
>  			    void *arg)
>  {
> -	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> -		int file = page_is_file_cache(page);
> -		int lru = page_lru_base_type(page);
> +	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> +	    !PageUnevictable(page)) {
> +		bool active = PageActive(page);
>  
> -		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> +		del_page_from_lru_list(page, lruvec, LRU_INACTIVE_ANON + active);
>  		ClearPageActive(page);
>  		ClearPageReferenced(page);
> -		add_page_to_lru_list(page, lruvec, lru);
> +		/*
> +		 * lazyfree pages are clean anonymous pages. They have
> +		 * SwapBacked flag cleared to destinguish normal anonymous
> +		 * pages

distinguish

Otherwise, looks great to me. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
