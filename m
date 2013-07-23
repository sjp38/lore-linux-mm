Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D0DCB6B0034
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 18:12:58 -0400 (EDT)
Message-ID: <51EEFFAD.701@infradead.org>
Date: Tue, 23 Jul 2013 15:11:57 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] lib: Make radix_tree_node_alloc() work correctly within
 interrupt
References: <1374617060-25805-1-git-send-email-jack@suse.cz>
In-Reply-To: <1374617060-25805-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>

On 07/23/13 15:04, Jan Kara wrote:

Hi,

s/sence/sense/ please.


> 
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index e796429..7811ed3 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -32,6 +32,7 @@
>  #include <linux/string.h>
>  #include <linux/bitops.h>
>  #include <linux/rcupdate.h>
> +#include <linux/hardirq.h>		/* in_interrupt() */
>  
>  
>  #ifdef __KERNEL__
> @@ -207,7 +208,12 @@ radix_tree_node_alloc(struct radix_tree_root *root)
>  	struct radix_tree_node *ret = NULL;
>  	gfp_t gfp_mask = root_gfp_mask(root);
>  
> -	if (!(gfp_mask & __GFP_WAIT)) {
> +	/*
> +	 * Preload code isn't irq safe and it doesn't make sence to use

	                                                   sense

> +	 * preloading in the interrupt anyway as all the allocations have to
> +	 * be atomic. So just do normal allocation when in interrupt.
> +	 */
> +	if (!(gfp_mask & __GFP_WAIT) && !in_interrupt()) {
>  		struct radix_tree_preload *rtp;
>  
>  		/*
> @@ -264,7 +270,7 @@ radix_tree_node_free(struct radix_tree_node *node)
>   * To make use of this facility, the radix tree must be initialised without
>   * __GFP_WAIT being passed to INIT_RADIX_TREE().
>   */
> -int radix_tree_preload(gfp_t gfp_mask)
> +static int __radix_tree_preload(gfp_t gfp_mask)
>  {
>  	struct radix_tree_preload *rtp;
>  	struct radix_tree_node *node;
> @@ -288,9 +294,40 @@ int radix_tree_preload(gfp_t gfp_mask)
>  out:
>  	return ret;
>  }
> +
> +/*
> + * Load up this CPU's radix_tree_node buffer with sufficient objects to
> + * ensure that the addition of a single element in the tree cannot fail.  On
> + * success, return zero, with preemption disabled.  On error, return -ENOMEM
> + * with preemption not disabled.
> + *
> + * To make use of this facility, the radix tree must be initialised without
> + * __GFP_WAIT being passed to INIT_RADIX_TREE().
> + */
> +int radix_tree_preload(gfp_t gfp_mask)
> +{
> +	/* Warn on non-sensical use... */
> +	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT));
> +	return __radix_tree_preload(gfp_mask);
> +}
>  EXPORT_SYMBOL(radix_tree_preload);
>  
>  /*
> + * The same as above function, except we don't guarantee preloading happens.
> + * We do it, if we decide it helps. On success, return zero with preemption
> + * disabled. On error, return -ENOMEM with preemption not disabled.
> + */
> +int radix_tree_maybe_preload(gfp_t gfp_mask)
> +{
> +	if (gfp_mask & __GFP_WAIT)
> +		return __radix_tree_preload(gfp_mask);
> +	/* Preloading doesn't help anything with this gfp mask, skip it */
> +	preempt_disable();
> +	return 0;
> +}
> +EXPORT_SYMBOL(radix_tree_maybe_preload);
> +
> +/*
>   *	Return the maximum key which can be store into a

	                                    stored

>   *	radix tree with height HEIGHT.
>   */

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
