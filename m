Date: Wed, 10 Nov 2004 06:17:33 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] kswapd shall not sleep during page shortage
Message-ID: <20041110081733.GG8414@logos.cnet>
References: <20041109174125.GF7632@logos.cnet> <20041109133343.0b34896d.akpm@osdl.org> <20041109182622.GA8300@logos.cnet> <20041109142257.1d1411e1.akpm@osdl.org> <4191675B.3090903@cyberone.com.au> <419181D5.1090308@cyberone.com.au> <20041109185640.32c8871b.akpm@osdl.org> <41918715.1080008@cyberone.com.au> <20041109191858.6802f5c3.akpm@osdl.org> <419195F9.4070806@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <419195F9.4070806@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2004 at 03:15:53PM +1100, Nick Piggin wrote:
> 
> 
> Andrew Morton wrote:
> 
> >Nick Piggin <piggin@cyberone.com.au> wrote:
> >
> >>Make sense?
> >>
> >
> >Hey, you know me - I'll believe anything.
> >
> >Let's take a second look at the numbers when you have a patch.  Please
> >check that we're printing all the relevant info at boot time.
> >
> >
> >
> >
> 
> OK with this patch, this is what the situation looks like:
> 
> without patch:
>      pages_min   pages_low   pages_high
> dma        4          8          12
> normal   234        468         702
> high     128        256         384
> 
> with patch:
>      pages_min   pages_low   pages_high
> dma       17         21          25
> normal   939       1173        1408
> high     128        160         192
> 
> without patch:
>                             | GFP_KERNEL        | GFP_ATOMIC
> allocate immediately         |   9 dma, 469 norm |  9 dma, 469 norm
> allocate after waking kswapd |   5 dma, 234 norm |  3 dma,  88 norm
> allocate after synch reclaim |   5 dma, 234 norm |  n/a
> 
> with patch:
>                             | GFP_KERNEL         | GFP_ATOMIC
> allocate immediately         |  22 dma, 1174 norm | 22 dma, 1174 norm
> allocate after waking kswapd |  18 dma,  940 norm |  6 dma,  440 norm
> allocate after synch reclaim |  18 dma,  940 norm |  n/a
> 
> 
> So the buffer between GFP_KERNEL and GFP_ATOMIC allocations is:
> 
> 2.6.8      | 465 dma, 117 norm, 582 tot = 2328K
> 2.6.10-rc  |   2 dma, 146 norm, 148 tot =  592K
> patch      |  12 dma, 500 norm, 512 tot = 2048K
> 
> Which is getting pretty good.
> 
> 
> kswap starts at:
> 2.6.8     477 dma, 496 norm, 973 total
> 2.6.10-rc   8 dma, 468 norm, 476 total
> patched    17 dma, 939 norm, 956 total
> 
> So in terms of total pages, that's looking similar to 2.6.8.
> 
> I'd respectfully suggest this is a regression (versus 2.6.8, at least),
> and hope it (or something like it) can get included in 2.6.10 after further
> testing?

That looks much better, thanks Nick!

I bet we wont be seeing the failures so often with this in place,
nice analysis.

>  linux-2.6-npiggin/mm/page_alloc.c |   41 +++++++++++++++++++++-----------------
>  1 files changed, 23 insertions(+), 18 deletions(-)
> 
> diff -puN mm/page_alloc.c~mm-restore-atomic-buffer mm/page_alloc.c
> --- linux-2.6/mm/page_alloc.c~mm-restore-atomic-buffer	2004-11-10 15:13:33.000000000 +1100
> +++ linux-2.6-npiggin/mm/page_alloc.c	2004-11-10 14:57:54.000000000 +1100
> @@ -1935,8 +1935,12 @@ static void setup_per_zone_pages_min(voi
>  			                   lowmem_pages;
>  		}
>  
> -		zone->pages_low = zone->pages_min * 2;
> -		zone->pages_high = zone->pages_min * 3;
> +		/*
> +		 * When interpreting these watermarks, just keep in mind that:
> +		 * zone->pages_min == (zone->pages_min * 4) / 4;
> +		 */
> +		zone->pages_low   = (zone->pages_min * 5) / 4;
> +		zone->pages_high  = (zone->pages_min * 6) / 4;
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	}
>  }
> @@ -1945,24 +1949,25 @@ static void setup_per_zone_pages_min(voi
>   * Initialise min_free_kbytes.
>   *
>   * For small machines we want it small (128k min).  For large machines
> - * we want it large (16MB max).  But it is not linear, because network
> + * we want it large (64MB max).  But it is not linear, because network
>   * bandwidth does not increase linearly with machine size.  We use
>   *
> - *	min_free_kbytes = sqrt(lowmem_kbytes)
> + * 	min_free_kbytes = 4 * sqrt(lowmem_kbytes), for better accuracy:
> + *	min_free_kbytes = sqrt(lowmem_kbytes * 16)
>   *
>   * which yields
>   *
> - * 16MB:	128k
> - * 32MB:	181k
> - * 64MB:	256k
> - * 128MB:	362k
> - * 256MB:	512k
> - * 512MB:	724k
> - * 1024MB:	1024k
> - * 2048MB:	1448k
> - * 4096MB:	2048k
> - * 8192MB:	2896k
> - * 16384MB:	4096k
> + * 16MB:	512k
> + * 32MB:	724k
> + * 64MB:	1024k
> + * 128MB:	1448k
> + * 256MB:	2048k
> + * 512MB:	2896k
> + * 1024MB:	4096k
> + * 2048MB:	5792k
> + * 4096MB:	8192k
> + * 8192MB:	11584k
> + * 16384MB:	16384k
>   */
>  static int __init init_per_zone_pages_min(void)
>  {
> @@ -1970,11 +1975,11 @@ static int __init init_per_zone_pages_mi
>  
>  	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
>  
> -	min_free_kbytes = int_sqrt(lowmem_kbytes);
> +	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
>  	if (min_free_kbytes < 128)
>  		min_free_kbytes = 128;
> -	if (min_free_kbytes > 16384)
> -		min_free_kbytes = 16384;
> +	if (min_free_kbytes > 65536)
> +		min_free_kbytes = 65536;
>  	setup_per_zone_pages_min();
>  	setup_per_zone_protection();
>  	return 0;
> 
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
