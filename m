Message-ID: <43EC2572.7010100@yahoo.com.au>
Date: Fri, 10 Feb 2006 16:32:34 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
References: <200602101355.41421.kernel@kolivas.org> <20060209205559.409c0290.akpm@osdl.org> <43EC1E0E.6060702@yahoo.com.au> <200602101626.12824.kernel@kolivas.org>
In-Reply-To: <200602101626.12824.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:

> Just so it's clear I understand, is this what you (both) had in mind?
> Inline so it's not built for !CONFIG_SWAP_PREFETCH
> 

Close...

> Index: linux-2.6.16-rc2-ck1/mm/swap.c
> ===================================================================
> --- linux-2.6.16-rc2-ck1.orig/mm/swap.c	2006-02-09 21:53:37.000000000 +1100
> +++ linux-2.6.16-rc2-ck1/mm/swap.c	2006-02-10 16:22:45.000000000 +1100
> @@ -156,6 +156,13 @@ void fastcall lru_cache_add_active(struc
>  	put_cpu_var(lru_add_active_pvecs);
>  }
>  
> +inline void lru_cache_add_tail(struct page *page)

Is this inline going to do what you intend?

> +{
> +	struct zone *zone = page_zone(page);
> +

     spin_lock_irq(&zone->lru_lock);

> +	add_page_to_inactive_list_tail(zone, page);

     spin_unlock_irq(&zone->lru_lock);

> +}
> +
>  static void __lru_add_drain(int cpu)
>  {
>  	struct pagevec *pvec = &per_cpu(lru_add_pvecs, cpu);

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
