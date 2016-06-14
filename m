Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65A14828FF
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 02:36:12 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id wy7so51773766lbb.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 23:36:12 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id n188si2381996wmf.30.2016.06.13.23.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 23:36:10 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id m124so19731270wme.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 23:36:10 -0700 (PDT)
Date: Tue, 14 Jun 2016 08:36:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, slaub: Add __GFP_ATOMIC to the GFP reclaim mask
Message-ID: <20160614063608.GA5681@dhcp22.suse.cz>
References: <20160610093832.GK2527@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160610093832.GK2527@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marcin Wojtas <mw@semihalf.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Fri 10-06-16 10:38:32, Mel Gorman wrote:
> Commit d0164adc89f6 ("mm, page_alloc: distinguish between being unable to
> sleep, unwilling to sleep and avoiding waking kswapd") modified __GFP_WAIT
> to explicitly identify the difference between atomic callers and those that
> were unwilling to sleep. Later the definition was removed entirely.
> 
> The GFP_RECLAIM_MASK is the set of flags that affect watermark checking
> and reclaim behaviour but __GFP_ATOMIC was never added. Without it, atomic
> users of the slab allocator strip the __GFP_ATOMIC flag and cannot access
> the page allocator atomic reserves.  This patch addresses the problem.
> 
> The user-visible impact depends on the workload but potentially atomic
> allocations unnecessarily fail without this path.
> 
> Cc: <stable@vger.kernel.org> # 4.4+
> Reported-by: Marcin Wojtas <mw@semihalf.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/internal.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index a37e5b6f9d25..2524ec880e24 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -24,7 +24,8 @@
>   */
>  #define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
>  			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
> -			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
> +			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
> +			__GFP_ATOMIC)
>  
>  /* The GFP flags allowed during early boot */
>  #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_RECLAIM|__GFP_IO|__GFP_FS))
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
