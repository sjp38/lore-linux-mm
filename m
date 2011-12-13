Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id DDFDE6B024C
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 05:06:09 -0500 (EST)
Date: Tue, 13 Dec 2011 11:06:01 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] bootmem: micro optimize freeing pages in bulks
Message-ID: <20111213100601.GA28671@cmpxchg.org>
References: <1322777455-32315-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1322777455-32315-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 01, 2011 at 11:10:55PM +0100, Uwe Kleine-Konig wrote:
> The first entry of bdata->node_bootmem_map holds the data for
> bdata->node_min_pfn up to bdata->node_min_pfn + BITS_PER_LONG - 1. So
> the test for freeing all pages of a single map entry can be slightly
> relaxed.

Agreed.  The optimization is tiny - we may lose one bulk order-5/6
free per node and do it in 32/64 order-0 frees instead (we touch each
page anyway one way or another), but the code makes more sense with
your change.

[ Btw, what's worse is start being unaligned, because we won't do a
  single batch free then.  The single-page loop should probably just
  move to the next BITS_PER_WORD boundary and then retry the aligned
  batch frees.  Oh, well... ]

> Moreover use DIV_ROUND_UP in another place instead of open coding it.

Agreed.

> Cc: Johannes Weiner <hannes@saeurebad.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>
> ---
> Hello,
> 
> I'm not sure the current code is correct (and my patch doesn't fix it):
> 
> If
> 
> 	aligned && vec == ~0UL
> 
> evalutates to true, but
> 
> 	start + BITS_PER_LONG <= end
> 
> does not (or "< end" resp.) the else branch still frees all BITS_PER_LONG
> pages. Is this intended? If yes, the last check can better be omitted
> resulting in the pages being freed in a bulk.
> If not, the loop in the else branch should only do something like:
> 
> 	while (vec && off < min(BITS_PER_LONG, end - start)) {
> 		...

I would think this is fine because node_bootmem_map, which is where
vec points to, is sized in multiples of pages, and zeroed word-wise.
So even if end is not aligned, we can rely on !vec.

> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index fc22150..1e7d791 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -56,7 +56,7 @@ early_param("bootmem_debug", bootmem_debug_setup);
>  
>  static unsigned long __init bootmap_bytes(unsigned long pages)
>  {
> -	unsigned long bytes = (pages + 7) / 8;
> +	unsigned long bytes = DIV_ROUND_UP(pages, 8);
>  
>  	return ALIGN(bytes, sizeof(long));
>  }
> @@ -197,7 +197,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  		idx = start - bdata->node_min_pfn;
>  		vec = ~map[idx / BITS_PER_LONG];
>  
> -		if (aligned && vec == ~0UL && start + BITS_PER_LONG < end) {
> +		if (aligned && vec == ~0UL && start + BITS_PER_LONG <= end) {
>  			int order = ilog2(BITS_PER_LONG);
>  
>  			__free_pages_bootmem(pfn_to_page(start), order);

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
