Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 174B56B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:55:32 -0500 (EST)
Date: Wed, 6 Mar 2013 09:55:17 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V2 03/11] mm: frontswap: cleanup code
Message-ID: <20130306145517.GC10760@phenom.dumpdata.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
 <1362559890-16710-3-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362559890-16710-3-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com

On Wed, Mar 06, 2013 at 04:51:22PM +0800, Bob Liu wrote:
> After allowing tmem backends to build/run as modules, frontswap_enabled always
> true if defined CONFIG_FRONTSWAP.
> But frontswap_test() depends on whether backend is registered, mv it into
> frontswap.c using fronstswap_ops to make the decision.

There is a benefit of keeping these checks in the header file - they
can be inlined in the code. But if you make this a function then the
code find_next_to_unuse has to make call instead of just checking an
value. James Bottomley wanted that to minimize the amount of extra
code swap has to go through to check whether to push the page to
frontswap or not.

Would it be possible to just keep it in the header file..

> 
> frontswap_set/clear are not used outside frontswap, so don't export them.

and this is a nice find - so lets indeed remove them.

> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  include/linux/frontswap.h |   28 +++-------------------
>  mm/frontswap.c            |   57 ++++++++++++++++++++++++---------------------
>  2 files changed, 33 insertions(+), 52 deletions(-)

Nice :-)

> 
> diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
> index d4f2987..6c49e1e 100644
> --- a/include/linux/frontswap.h
> +++ b/include/linux/frontswap.h
> @@ -22,6 +22,7 @@ extern void frontswap_writethrough(bool);
>  #define FRONTSWAP_HAS_EXCLUSIVE_GETS
>  extern void frontswap_tmem_exclusive_gets(bool);
>  
> +extern bool __frontswap_test(struct swap_info_struct *, pgoff_t);
>  extern void __frontswap_init(unsigned type);
>  extern int __frontswap_store(struct page *page);
>  extern int __frontswap_load(struct page *page);
> @@ -29,26 +30,11 @@ extern void __frontswap_invalidate_page(unsigned, pgoff_t);
>  extern void __frontswap_invalidate_area(unsigned);
>  
>  #ifdef CONFIG_FRONTSWAP
> +#define frontswap_enabled (1)
>  
>  static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
>  {
> -	bool ret = false;
> -
> -	if (frontswap_enabled && sis->frontswap_map)
> -		ret = test_bit(offset, sis->frontswap_map);
> -	return ret;
> -}
> -
> -static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
> -{
> -	if (frontswap_enabled && sis->frontswap_map)
> -		set_bit(offset, sis->frontswap_map);
> -}
> -
> -static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
> -{
> -	if (frontswap_enabled && sis->frontswap_map)
> -		clear_bit(offset, sis->frontswap_map);
> +	return __frontswap_test(sis, offset);
>  }
>  
>  static inline void frontswap_map_set(struct swap_info_struct *p,
> @@ -71,14 +57,6 @@ static inline bool frontswap_test(struct swap_info_struct *sis, pgoff_t offset)
>  	return false;
>  }
>  
> -static inline void frontswap_set(struct swap_info_struct *sis, pgoff_t offset)
> -{
> -}
> -
> -static inline void frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
> -{
> -}
> -
>  static inline void frontswap_map_set(struct swap_info_struct *p,
>  				     unsigned long *map)
>  {
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index e44c9cb..2760b0f 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -27,14 +27,6 @@
>  static struct frontswap_ops *frontswap_ops __read_mostly;
>  
>  /*
> - * This global enablement flag reduces overhead on systems where frontswap_ops
> - * has not been registered, so is preferred to the slower alternative: a
> - * function call that checks a non-global.
> - */
> -bool frontswap_enabled __read_mostly;
> -EXPORT_SYMBOL(frontswap_enabled);
> -
> -/*
>   * If enabled, frontswap_store will return failure even on success.  As
>   * a result, the swap subsystem will always write the page to swap, in
>   * effect converting frontswap into a writethrough cache.  In this mode,
> @@ -128,8 +120,6 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
>  	struct frontswap_ops *old = frontswap_ops;
>  	int i;
>  
> -	frontswap_enabled = true;
> -
>  	for (i = 0; i < MAX_SWAPFILES; i++) {
>  		if (test_and_clear_bit(i, need_init))
>  			ops->init(i);
> @@ -183,9 +173,21 @@ void __frontswap_init(unsigned type)
>  }
>  EXPORT_SYMBOL(__frontswap_init);
>  
> -static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
> +bool __frontswap_test(struct swap_info_struct *sis,
> +				pgoff_t offset)
> +{
> +	bool ret = false;
> +
> +	if (frontswap_ops && sis->frontswap_map)
> +		ret = test_bit(offset, sis->frontswap_map);
> +	return ret;
> +}
> +EXPORT_SYMBOL(__frontswap_test);
> +
> +static inline void __frontswap_clear(struct swap_info_struct *sis,
> +				pgoff_t offset)
>  {
> -	frontswap_clear(sis, offset);
> +	clear_bit(offset, sis->frontswap_map);
>  	atomic_dec(&sis->frontswap_pages);
>  }
>  
> @@ -204,18 +206,20 @@ int __frontswap_store(struct page *page)
>  	struct swap_info_struct *sis = swap_info[type];
>  	pgoff_t offset = swp_offset(entry);
>  
> -	if (!frontswap_ops) {
> -		inc_frontswap_failed_stores();
> +	/*
> +	 * Return if no backend registed.
> +	 * Don't need to inc frontswap_failed_stores here.
> +	 */
> +	if (!frontswap_ops)
>  		return ret;
> -	}
>  
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(sis == NULL);
> -	if (frontswap_test(sis, offset))
> +	if (__frontswap_test(sis, offset))
>  		dup = 1;
>  	ret = frontswap_ops->store(type, offset, page);
>  	if (ret == 0) {
> -		frontswap_set(sis, offset);
> +		set_bit(offset, sis->frontswap_map);
>  		inc_frontswap_succ_stores();
>  		if (!dup)
>  			atomic_inc(&sis->frontswap_pages);
> @@ -248,18 +252,18 @@ int __frontswap_load(struct page *page)
>  	struct swap_info_struct *sis = swap_info[type];
>  	pgoff_t offset = swp_offset(entry);
>  
> -	if (!frontswap_ops)
> -		return ret;
> -
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(sis == NULL);
> -	if (frontswap_test(sis, offset))
> +	/*
> +	 * __frontswap_test() will check whether there is backend registered
> +	 */
> +	if (__frontswap_test(sis, offset))
>  		ret = frontswap_ops->load(type, offset, page);
>  	if (ret == 0) {
>  		inc_frontswap_loads();
>  		if (frontswap_tmem_exclusive_gets_enabled) {
>  			SetPageDirty(page);
> -			frontswap_clear(sis, offset);
> +			__frontswap_clear(sis, offset);
>  		}
>  	}
>  	return ret;
> @@ -274,11 +278,11 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
>  {
>  	struct swap_info_struct *sis = swap_info[type];
>  
> -	if (!frontswap_ops)
> -		return;
> -
>  	BUG_ON(sis == NULL);
> -	if (frontswap_test(sis, offset)) {
> +	/*
> +	 * __frontswap_test() will check whether there is backend registered
> +	 */
> +	if (__frontswap_test(sis, offset)) {
>  		frontswap_ops->invalidate_page(type, offset);
>  		__frontswap_clear(sis, offset);
>  		inc_frontswap_invalidates();
> @@ -435,7 +439,6 @@ static int __init init_frontswap(void)
>  	debugfs_create_u64("invalidates", S_IRUGO,
>  				root, &frontswap_invalidates);
>  #endif
> -	frontswap_enabled = 1;
>  	return 0;
>  }
>  
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
