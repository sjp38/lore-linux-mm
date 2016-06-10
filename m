Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2C116B0260
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:12:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 4so34115861wmz.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 03:12:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s130si8065216wmf.67.2016.06.10.03.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 03:12:47 -0700 (PDT)
Subject: Re: [PATCH] mm, slaub: Add __GFP_ATOMIC to the GFP reclaim mask
References: <20160610093832.GK2527@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <575A929D.3070601@suse.cz>
Date: Fri, 10 Jun 2016 12:12:45 +0200
MIME-Version: 1.0
In-Reply-To: <20160610093832.GK2527@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcin Wojtas <mw@semihalf.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2016 11:38 AM, Mel Gorman wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
