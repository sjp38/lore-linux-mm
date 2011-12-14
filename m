Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id BDD3C6B030C
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 15:20:37 -0500 (EST)
Date: Wed, 14 Dec 2011 21:20:32 +0100
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [patch 4/4] mm: bootmem: try harder to free pages in bulk
Message-ID: <20111214202032.GA24496@pengutronix.de>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
 <1323784711-1937-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1323784711-1937-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 13, 2011 at 02:58:31PM +0100, Johannes Weiner wrote:
> The loop that frees pages to the page allocator while bootstrapping
> tries to free higher-order blocks only when the starting address is
> aligned to that block size.  Otherwise it will free all pages on that
> node one-by-one.
> 
> Change it to free individual pages up to the first aligned block and
> then try higher-order frees from there.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
I gave all four patches a try now on my ARM machine and it still works
fine. But note that this patch isn't really tested, because for me
free_all_bootmem_core is only called once and that with an aligned
address.
But at least you didn't broke that case :-)
Having said that, I wonder if the code does the right thing for
unaligned start. (That is, it's wrong to start testing for bit 0 of
map[idx / BITS_PER_LONG], isn't it?) But if that's the case that's not
something you introduced in this series.

One more comment below.

> ---
>  mm/bootmem.c |   22 ++++++++++------------
>  1 files changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 1aea171..668e94d 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -171,7 +171,6 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
>  
>  static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  {
> -	int aligned;
>  	struct page *page;
>  	unsigned long start, end, pages, count = 0;
>  
> @@ -181,14 +180,8 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  	start = bdata->node_min_pfn;
>  	end = bdata->node_low_pfn;
>  
> -	/*
> -	 * If the start is aligned to the machines wordsize, we might
> -	 * be able to free pages in bulks of that order.
> -	 */
> -	aligned = !(start & (BITS_PER_LONG - 1));
> -
> -	bdebug("nid=%td start=%lx end=%lx aligned=%d\n",
> -		bdata - bootmem_node_data, start, end, aligned);
> +	bdebug("nid=%td start=%lx end=%lx\n",
> +		bdata - bootmem_node_data, start, end);
>  
>  	while (start < end) {
>  		unsigned long *map, idx, vec;
> @@ -196,12 +189,17 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  		map = bdata->node_bootmem_map;
>  		idx = start - bdata->node_min_pfn;
>  		vec = ~map[idx / BITS_PER_LONG];
> -
> -		if (aligned && vec == ~0UL) {
> +		/*
> +		 * If we have a properly aligned and fully unreserved
> +		 * BITS_PER_LONG block of pages in front of us, free
> +		 * it in one go.
> +		 */
> +		if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL) {
>  			int order = ilog2(BITS_PER_LONG);
>  
>  			__free_pages_bootmem(pfn_to_page(start), order);
>  			count += BITS_PER_LONG;
> +			start += BITS_PER_LONG;
>  		} else {
>  			unsigned long off = 0;
>  
> @@ -214,8 +212,8 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>  				vec >>= 1;
>  				off++;
>  			}
> +			start = ALIGN(start + 1, BITS_PER_LONG);
>  		}
> -		start += BITS_PER_LONG;
I don't know if the compiler would be more happy if you would just use

	start = ALIGN(start + 1, BITS_PER_LONG);

unconditionally and drop

	start += BITS_PER_LONG

in the if block?!

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
