Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2CBC46B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:56:32 -0400 (EDT)
Date: Wed, 31 Oct 2012 09:42:46 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH RFC] mm: simplify frontswap_init()
Message-ID: <20121031134246.GF27288@phenom.dumpdata.com>
References: <5090594E.7050401@cesarb.net>
 <1351638773-3986-1-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351638773-3986-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Oct 30, 2012 at 09:12:53PM -0200, Cesar Eduardo Barros wrote:
> The function frontswap_init() uses the passed parameter only to check
> for the presence of the frontswap_map. It is also passed down to
> frontswap_ops.init(), but all implementations of it in the kernel ignore
> the parameter.
> 
> Do the check for frontswap_map in the caller instead and remove the
> parameter from frontswap_init() and frontswap_ops.init().
> 
> Also, __frontswap_init() was exported, but its only caller (via an
> inline function) is mm/swapfile.c, which cannot be built as a module.
> Remove the unnecessary export.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
> ---
> 
> Not even compile tested, just a quick patch to show what I was thinking
> of, but feel free to apply if you think it is good.

That looks good.
> 
> I might write another patch to move it outside the lock later, but I
> would have to read the frontswap code more carefully first.
> 
>  drivers/staging/ramster/zcache-main.c |  2 +-
>  drivers/staging/zcache/zcache-main.c  |  2 +-
>  drivers/xen/tmem.c                    |  2 +-
>  include/linux/frontswap.h             |  8 ++++----
>  mm/frontswap.c                        | 10 ++--------
>  mm/swapfile.c                         |  3 ++-
>  6 files changed, 11 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
> index a09dd5c..b3f01c9 100644
> --- a/drivers/staging/ramster/zcache-main.c
> +++ b/drivers/staging/ramster/zcache-main.c
> @@ -1610,7 +1610,7 @@ static void zcache_frontswap_flush_area(unsigned type)
>  	}
>  }
>  
> -static void zcache_frontswap_init(unsigned ignored)
> +static void zcache_frontswap_init(void)
>  {
>  	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
>  	if (zcache_frontswap_poolid < 0)
> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
> index 52b43b7..cb67635 100644
> --- a/drivers/staging/zcache/zcache-main.c
> +++ b/drivers/staging/zcache/zcache-main.c
> @@ -1903,7 +1903,7 @@ static void zcache_frontswap_flush_area(unsigned type)
>  	}
>  }
>  
> -static void zcache_frontswap_init(unsigned ignored)
> +static void zcache_frontswap_init(void)
>  {
>  	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
>  	if (zcache_frontswap_poolid < 0)
> diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
> index 144564e..7156ff0 100644
> --- a/drivers/xen/tmem.c
> +++ b/drivers/xen/tmem.c
> @@ -343,7 +343,7 @@ static void tmem_frontswap_flush_area(unsigned type)
>  		(void)xen_tmem_flush_object(pool, oswiz(type, ind));
>  }
>  
> -static void tmem_frontswap_init(unsigned ignored)
> +static void tmem_frontswap_init(void)
>  {
>  	struct tmem_pool_uuid private = TMEM_POOL_PRIVATE_UUID;
>  
> diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
> index 3044254..6374c80 100644
> --- a/include/linux/frontswap.h
> +++ b/include/linux/frontswap.h
> @@ -6,7 +6,7 @@
>  #include <linux/bitops.h>
>  
>  struct frontswap_ops {
> -	void (*init)(unsigned);
> +	void (*init)(void);
>  	int (*store)(unsigned, pgoff_t, struct page *);
>  	int (*load)(unsigned, pgoff_t, struct page *);
>  	void (*invalidate_page)(unsigned, pgoff_t);
> @@ -22,7 +22,7 @@ extern void frontswap_writethrough(bool);
>  #define FRONTSWAP_HAS_EXCLUSIVE_GETS
>  extern void frontswap_tmem_exclusive_gets(bool);
>  
> -extern void __frontswap_init(unsigned type);
> +extern void __frontswap_init(void);
>  extern int __frontswap_store(struct page *page);
>  extern int __frontswap_load(struct page *page);
>  extern void __frontswap_invalidate_page(unsigned, pgoff_t);
> @@ -120,10 +120,10 @@ static inline void frontswap_invalidate_area(unsigned type)
>  		__frontswap_invalidate_area(type);
>  }
>  
> -static inline void frontswap_init(unsigned type)
> +static inline void frontswap_init(void)
>  {
>  	if (frontswap_enabled)
> -		__frontswap_init(type);
> +		__frontswap_init();
>  }
>  
>  #endif /* _LINUX_FRONTSWAP_H */
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 2890e67..d13661b 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -115,16 +115,10 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
>  /*
>   * Called when a swap device is swapon'd.
>   */
> -void __frontswap_init(unsigned type)
> +void __frontswap_init(void)
>  {
> -	struct swap_info_struct *sis = swap_info[type];
> -
> -	BUG_ON(sis == NULL);
> -	if (sis->frontswap_map == NULL)
> -		return;
> -	frontswap_ops.init(type);
> +	frontswap_ops.init();
>  }
> -EXPORT_SYMBOL(__frontswap_init);
>  
>  static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
>  {
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 088daf4..28c26bd 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1479,7 +1479,8 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
>  {
>  	spin_lock(&swap_lock);
>  	_enable_swap_info(p, prio, swap_map, frontswap_map);
> -	frontswap_init(p->type);
> +	if (frontswap_map)
> +		frontswap_init();
>  	spin_unlock(&swap_lock);
>  }
>  
> -- 
> 1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
