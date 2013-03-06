Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id BBD906B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 07:36:44 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id k14so9339930iea.13
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 04:36:44 -0800 (PST)
Message-ID: <51373853.4010402@gmail.com>
Date: Wed, 06 Mar 2013 20:36:35 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 01/11] mm: frontswap: lazy initialization to allow
 tmem backends to build/run as modules
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>

On 03/06/2013 04:51 PM, Bob Liu wrote:
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
>
> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> built/loaded as modules rather than built-in and enabled by a boot parameter,
> this patch provides "lazy initialization", allowing backends to register to
> frontswap even after swapon was run. Before a backend registers all calls
> to init are recorded and the creation of tmem_pools delayed until a backend
> registers or until a frontswap store is attempted.

You drop patch 0/11, why? Where is the changelog?

>
> Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
> Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
> Signed-off-by: Andor Daam <andor.daam@googlemail.com>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> [v1: Fixes per Seth Jennings suggestions]
> [v2: Removed FRONTSWAP_HAS_.. ]
> [v3: Fix up per Bob Liu <lliubbo@gmail.com> recommendations]
> [v4: Fix up per Andrew's comments]
> Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>   mm/frontswap.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++++++------
>   1 file changed, 84 insertions(+), 10 deletions(-)
>
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 2890e67..cbd2b8a 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -80,6 +80,46 @@ static inline void inc_frontswap_succ_stores(void) { }
>   static inline void inc_frontswap_failed_stores(void) { }
>   static inline void inc_frontswap_invalidates(void) { }
>   #endif
> +
> +/*
> + * Due to the asynchronous nature of the backends loading potentially
> + * _after_ the swap system has been activated, we have chokepoints
> + * on all frontswap functions to not call the backend until the backend
> + * has registered.
> + *
> + * Specifically when no backend is registered (nobody called
> + * frontswap_register_ops) all calls to frontswap_init (which is done via
> + * swapon -> enable_swap_info -> frontswap_init) are registered and remembered
> + * (via the setting of need_init bitmap) but fail to create tmem_pools. When a
> + * backend registers with frontswap at some later point the previous
> + * calls to frontswap_init are executed (by iterating over the need_init
> + * bitmap) to create tmem_pools and set the respective poolids. All of that is
> + * guarded by us using atomic bit operations on the 'need_init' bitmap.
> + *
> + * This would not guards us against the user deciding to call swapoff right as
> + * we are calling the backend to initialize (so swapon is in action).
> + * Fortunatly for us, the swapon_mutex has been taked by the callee so we are
> + * OK. The other scenario where calls to frontswap_store (called via
> + * swap_writepage) is racing with frontswap_invalidate_area (called via
> + * swapoff) is again guarded by the swap subsystem.
> + *
> + * While no backend is registered all calls to frontswap_[store|load|
> + * invalidate_area|invalidate_page] are ignored or fail.
> + *
> + * The time between the backend being registered and the swap file system
> + * calling the backend (via the frontswap_* functions) is indeterminate as
> + * backend_registered is not atomic_t (or a value guarded by a spinlock).
> + * That is OK as we are comfortable missing some of these calls to the newly
> + * registered backend.
> + *
> + * Obviously the opposite (unloading the backend) must be done after all
> + * the frontswap_[store|load|invalidate_area|invalidate_page] start
> + * ignorning or failing the requests - at which point backend_registered
> + * would have to be made in some fashion atomic.
> + */
> +static DECLARE_BITMAP(need_init, MAX_SWAPFILES);
> +static bool backend_registered __read_mostly;
> +
>   /*
>    * Register operations for frontswap, returning previous thus allowing
>    * detection of multiple backends and possible nesting.
> @@ -87,9 +127,22 @@ static inline void inc_frontswap_invalidates(void) { }
>   struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
>   {
>   	struct frontswap_ops old = frontswap_ops;
> +	int i;
>   
>   	frontswap_ops = *ops;
>   	frontswap_enabled = true;
> +
> +	for (i = 0; i < MAX_SWAPFILES; i++) {
> +		if (test_and_clear_bit(i, need_init))
> +			(*frontswap_ops.init)(i);
> +	}
> +	/*
> +	 * We MUST have backend_registered set _after_ the frontswap_init's
> +	 * have been called. Otherwise __frontswap_store might fail. Hence
> +	 * the barrier to make sure compiler does not re-order us.
> +	 */
> +	barrier();
> +	backend_registered = true;
>   	return old;
>   }
>   EXPORT_SYMBOL(frontswap_register_ops);
> @@ -119,10 +172,16 @@ void __frontswap_init(unsigned type)
>   {
>   	struct swap_info_struct *sis = swap_info[type];
>   
> -	BUG_ON(sis == NULL);
> -	if (sis->frontswap_map == NULL)
> -		return;
> -	frontswap_ops.init(type);
> +	if (backend_registered) {
> +		BUG_ON(sis == NULL);
> +		if (sis->frontswap_map == NULL)
> +			return;
> +		(*frontswap_ops.init)(type);
> +	} else {
> +		BUG_ON(type > MAX_SWAPFILES);
> +		set_bit(type, need_init);
> +	}
> +
>   }
>   EXPORT_SYMBOL(__frontswap_init);
>   
> @@ -147,6 +206,11 @@ int __frontswap_store(struct page *page)
>   	struct swap_info_struct *sis = swap_info[type];
>   	pgoff_t offset = swp_offset(entry);
>   
> +	if (!backend_registered) {
> +		inc_frontswap_failed_stores();
> +		return ret;
> +	}
> +
>   	BUG_ON(!PageLocked(page));
>   	BUG_ON(sis == NULL);
>   	if (frontswap_test(sis, offset))
> @@ -186,6 +250,9 @@ int __frontswap_load(struct page *page)
>   	struct swap_info_struct *sis = swap_info[type];
>   	pgoff_t offset = swp_offset(entry);
>   
> +	if (!backend_registered)
> +		return ret;
> +
>   	BUG_ON(!PageLocked(page));
>   	BUG_ON(sis == NULL);
>   	if (frontswap_test(sis, offset))
> @@ -209,6 +276,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
>   {
>   	struct swap_info_struct *sis = swap_info[type];
>   
> +	if (!backend_registered)
> +		return;
> +
>   	BUG_ON(sis == NULL);
>   	if (frontswap_test(sis, offset)) {
>   		frontswap_ops.invalidate_page(type, offset);
> @@ -226,12 +296,15 @@ void __frontswap_invalidate_area(unsigned type)
>   {
>   	struct swap_info_struct *sis = swap_info[type];
>   
> -	BUG_ON(sis == NULL);
> -	if (sis->frontswap_map == NULL)
> -		return;
> -	frontswap_ops.invalidate_area(type);
> -	atomic_set(&sis->frontswap_pages, 0);
> -	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +	if (backend_registered) {
> +		BUG_ON(sis == NULL);
> +		if (sis->frontswap_map == NULL)
> +			return;
> +		(*frontswap_ops.invalidate_area)(type);
> +		atomic_set(&sis->frontswap_pages, 0);
> +		memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +	}
> +	clear_bit(type, need_init);
>   }
>   EXPORT_SYMBOL(__frontswap_invalidate_area);
>   
> @@ -364,6 +437,7 @@ static int __init init_frontswap(void)
>   	debugfs_create_u64("invalidates", S_IRUGO,
>   				root, &frontswap_invalidates);
>   #endif
> +	frontswap_enabled = 1;
>   	return 0;
>   }
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
