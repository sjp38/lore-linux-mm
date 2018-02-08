Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F16D76B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 20:36:40 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so861258plv.16
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 17:36:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u76sor645254pgc.197.2018.02.07.17.36.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 17:36:39 -0800 (PST)
Date: Thu, 8 Feb 2018 10:36:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -mm -v2] mm, swap, frontswap: Fix THP swap if frontswap
 enabled
Message-ID: <20180208013635.GA596@jagdpanzerIV>
References: <20180207070035.30302-1-ying.huang@intel.com>
 <20180207130534.259cd71a595c6275b2da38d3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207130534.259cd71a595c6275b2da38d3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (02/07/18 13:05), Andrew Morton wrote:
[..]
> hm.  This is assuming that "cluster==true" means "this is thp swap". 
> That's presently true, but is it appropriate that get_swap_pages() is
> peeking at "cluster" to work out why it is being called?
> 
> Or would it be cleaner to do this in get_swap_page()?  Something like
> 
> --- a/mm/swap_slots.c~a
> +++ a/mm/swap_slots.c
> @@ -317,8 +317,11 @@ swp_entry_t get_swap_page(struct page *p
>  	entry.val = 0;
>  
>  	if (PageTransHuge(page)) {
> -		if (IS_ENABLED(CONFIG_THP_SWAP))
> -			get_swap_pages(1, true, &entry);
> +		/* Frontswap doesn't support THP */
> +		if (!frontswap_enabled()) {
> +			if (IS_ENABLED(CONFIG_THP_SWAP))
> +				get_swap_pages(1, true, &entry);
> +		}
>  		return entry;
>  	}

I have proposed exactly the same thing [1], Minchan commented that
it would introduce frontswap dependency to swap_slots.c [2]. Which
is true, but I'd still probably prefer to handle it all in
get_swap_page. Minchan, any objections?

[1] https://marc.info/?l=linux-mm&m=151791052007719&w=2
[2] https://marc.info/?l=linux-mm&m=151792646812617&w=2

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
