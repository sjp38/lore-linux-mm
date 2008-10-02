Date: Thu, 2 Oct 2008 14:49:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] setup_per_zone_pages_min(): take zone->lock instead of
 zone->lru_lock
Message-Id: <20081002144944.2ddaf350.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1222882772.4846.40.camel@localhost.localdomain>
References: <1222723206.6791.2.camel@ubuntu>
	<20080930094017.5ed2938a.kamezawa.hiroyu@jp.fujitsu.com>
	<20080930103748.44A3.E1E9C6FF@jp.fujitsu.com>
	<1222882772.4846.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 01 Oct 2008 19:39:32 +0200
Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:

> From: Gerald Schaefer <gerald.schaefer@de.ibm.com> 
> 
> This replaces zone->lru_lock in setup_per_zone_pages_min() with zone->lock.
> There seems to be no need for the lru_lock anymore, but there is a need for
> zone->lock instead, because that function may call move_freepages() via
> setup_zone_migrate_reserve().
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
Thank you!.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/page_alloc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -4207,7 +4207,7 @@ void setup_per_zone_pages_min(void)
>  	for_each_zone(zone) {
>  		u64 tmp;
>  
> -		spin_lock_irqsave(&zone->lru_lock, flags);
> +		spin_lock_irqsave(&zone->lock, flags);
>  		tmp = (u64)pages_min * zone->present_pages;
>  		do_div(tmp, lowmem_pages);
>  		if (is_highmem(zone)) {
> @@ -4239,7 +4239,7 @@ void setup_per_zone_pages_min(void)
>  		zone->pages_low   = zone->pages_min + (tmp >> 2);
>  		zone->pages_high  = zone->pages_min + (tmp >> 1);
>  		setup_zone_migrate_reserve(zone);
> -		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +		spin_unlock_irqrestore(&zone->lock, flags);
>  	}
>  
>  	/* update totalreserve_pages */
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
