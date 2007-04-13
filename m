Date: Sat, 14 Apr 2007 01:31:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: lockless test threads
Message-ID: <20070413233145.GA18150@wotan.suse.de>
References: <20070412103151.5564.16127.sendpatchset@linux.site> <20070412103330.5564.31067.sendpatchset@linux.site> <Pine.LNX.4.64.0704131748270.5565@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704131748270.5565@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 05:54:37PM +0100, Hugh Dickins wrote:
> On Thu, 12 Apr 2007, Nick Piggin wrote:
> 
> > Introduce a basic lockless pagecache test harness. I don't know what value
> > this has, because it hasn't caught a bug yet, but it might help with testing.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> A couple of fixes to fold in: the modular build needs two exports;
> and I got divide-by-0 with mem=512M to a HIGHMEM kernel.

Thanks!

> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> 
> --- 2.6.21-rc6-np/mm/lpctest.c	2007-04-13 15:25:41.000000000 +0100
> +++ linux/mm/lpctest.c	2007-04-13 17:36:22.000000000 +0100
> @@ -122,6 +122,8 @@ static int lpc_random_thread(void *arg)
>  			unsigned int times;
>  			struct page *page;
>  
> +			if (!zone->spanned_pages)
> +				continue;
>  			pfn = zone->zone_start_pfn +
>  				lpc_random(&rand) % zone->spanned_pages;
>  			if (!pfn_valid(pfn))
> --- 2.6.21-rc6-np/mm/mmzone.c	2007-02-04 18:44:54.000000000 +0000
> +++ linux/mm/mmzone.c	2007-04-13 16:10:06.000000000 +0100
> @@ -42,3 +42,7 @@ struct zone *next_zone(struct zone *zone
>  	return zone;
>  }
>  
> +#ifdef CONFIG_LPC_TEST_MODULE
> +EXPORT_SYMBOL_GPL(first_online_pgdat);
> +EXPORT_SYMBOL_GPL(next_zone);
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
