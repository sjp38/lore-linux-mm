Subject: Re: [PATCH 08/30] mm: serialize access to min_free_kbytes
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080724141529.855634756@chello.nl>
References: <20080724140042.408642539@chello.nl>
	 <20080724141529.855634756@chello.nl>
Date: Wed, 30 Jul 2008 15:36:00 +0300
Message-Id: <1217421360.7813.171.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
> plain text document attachment (mm-setup_per_zone_pages_min.patch)
> There is a small race between the procfs caller and the memory hotplug caller
> of setup_per_zone_pages_min(). Not a big deal, but the next patch will add yet
> another caller. Time to close the gap.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks good to me.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  mm/page_alloc.c |   16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -118,6 +118,7 @@ static char * const zone_names[MAX_NR_ZO
>  	 "Movable",
>  };
>  
> +static DEFINE_SPINLOCK(min_free_lock);
>  int min_free_kbytes = 1024;
>  
>  unsigned long __meminitdata nr_kernel_pages;
> @@ -4333,12 +4334,12 @@ static void setup_per_zone_lowmem_reserv
>  }
>  
>  /**
> - * setup_per_zone_pages_min - called when min_free_kbytes changes.
> + * __setup_per_zone_pages_min - called when min_free_kbytes changes.
>   *
>   * Ensures that the pages_{min,low,high} values for each zone are set correctly
>   * with respect to min_free_kbytes.
>   */
> -void setup_per_zone_pages_min(void)
> +static void __setup_per_zone_pages_min(void)
>  {
>  	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
>  	unsigned long lowmem_pages = 0;
> @@ -4433,6 +4434,15 @@ void setup_per_zone_inactive_ratio(void)
>  	}
>  }
>  
> +void setup_per_zone_pages_min(void)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&min_free_lock, flags);
> +	__setup_per_zone_pages_min();
> +	spin_unlock_irqrestore(&min_free_lock, flags);
> +}
> +
>  /*
>   * Initialise min_free_kbytes.
>   *
> @@ -4468,7 +4478,7 @@ static int __init init_per_zone_pages_mi
>  		min_free_kbytes = 128;
>  	if (min_free_kbytes > 65536)
>  		min_free_kbytes = 65536;
> -	setup_per_zone_pages_min();
> +	__setup_per_zone_pages_min();
>  	setup_per_zone_lowmem_reserve();
>  	setup_per_zone_inactive_ratio();
>  	return 0;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
