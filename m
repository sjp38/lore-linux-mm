Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1965A6B002C
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 10:27:13 -0500 (EST)
Date: Fri, 3 Feb 2012 09:27:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc PATCH]slub: per cpu partial statistics change
In-Reply-To: <1328256695.12669.24.camel@debian>
Message-ID: <alpine.DEB.2.00.1202030920060.2420@router.home>
References: <1328256695.12669.24.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 3 Feb 2012, Alex,Shi wrote:

> This patch split the cpu_partial_free into 2 parts: cpu_partial_node, PCP refilling
> times from node partial; and same name cpu_partial_free, PCP refilling times in
> slab_free slow path. A new statistic 'release_cpu_partial' is added to get PCP
> release times. These info are useful when do PCP tunning.

Releasing? The code where you inserted the new statistics counts the pages
put on the cpu partial list when refilling from the node partial list.

See more below.

>  struct kmem_cache_cpu {
> diff --git a/mm/slub.c b/mm/slub.c
> index 4907563..5dd299c 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1560,6 +1560,7 @@ static void *get_partial_node(struct kmem_cache *s,
>  		} else {
>  			page->freelist = t;
>  			available = put_cpu_partial(s, page, 0);
> +			stat(s, CPU_PARTIAL_NODE);

This is refilling the per cpu partial list from the node list.

>  		}
>  		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
>  			break;
> @@ -1973,6 +1974,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  				local_irq_restore(flags);
>  				pobjects = 0;
>  				pages = 0;
> +				stat(s, RELEASE_CPU_PARTIAL);

The callers count the cpu partial operations. Why is there now one in
put_cpu_partial? It is moving a page to the cpu partial list. Not
releasing it from the cpu partial list.

>
> @@ -2465,9 +2466,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>  		 * If we just froze the page then put it onto the
>  		 * per cpu partial list.
>  		 */
> -		if (new.frozen && !was_frozen)
> +		if (new.frozen && !was_frozen) {
>  			put_cpu_partial(s, page, 1);
> -
> +			stat(s, CPU_PARTIAL_FREE);

cpu partial list filled with a partial page created from a fully allocated
slab (which therefore was not on any list before).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
