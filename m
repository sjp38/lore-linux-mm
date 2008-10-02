Date: Thu, 02 Oct 2008 19:00:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] setup_per_zone_pages_min(): take zone->lock instead of zone->lru_lock
In-Reply-To: <1222882772.4846.40.camel@localhost.localdomain>
References: <20080930103748.44A3.E1E9C6FF@jp.fujitsu.com> <1222882772.4846.40.camel@localhost.localdomain>
Message-Id: <20081002185250.5767.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Thanks!

Tested-by: Yasunori Goto <y-goto@jp.fujitsu.com>


> From: Gerald Schaefer <gerald.schaefer@de.ibm.com> 
> 
> This replaces zone->lru_lock in setup_per_zone_pages_min() with zone->lock.
> There seems to be no need for the lru_lock anymore, but there is a need for
> zone->lock instead, because that function may call move_freepages() via
> setup_zone_migrate_reserve().
> 
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> 
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

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
