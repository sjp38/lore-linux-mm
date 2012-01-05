Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E74FF6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 10:22:56 -0500 (EST)
Date: Thu, 5 Jan 2012 15:22:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3.2.0-rc1 2/3] MM hook for page allocation and release
Message-ID: <20120105152253.GB27881@csn.ul.ie>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e78b4ac9d3d51ac16180114c08733e4bf62ec65e.1325696593.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Wed, Jan 04, 2012 at 07:21:55PM +0200, Leonid Moiseichuk wrote:
> That is required by Used Memory Meter (UMM) pseudo-device
> to track memory utilization in system. It is expected that
> hook MUST be very light to prevent performance impact
> on the hot allocation path. Accuracy of number managed pages
> does not expected to be absolute but fact of allocation or
> deallocation must be registered.
> 
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
> ---
>  include/linux/mm.h |   15 +++++++++++++++
>  mm/Kconfig         |    8 ++++++++
>  mm/page_alloc.c    |   31 +++++++++++++++++++++++++++++++
>  3 files changed, 54 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 3dc3a8c..d133f73 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1618,6 +1618,21 @@ extern int soft_offline_page(struct page *page, int flags);
>  
>  extern void dump_page(struct page *page);
>  
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +/*
> + * Hook function type which called when some pages allocated or released.
> + * Value of nr_pages is positive for post-allocation calls and negative
> + * after free.
> + */
> +typedef void (*mm_alloc_free_hook_t)(int nr_pages);
> +
> +/*

I'm going to chime in and say that hooks like this into the page
allocator are a no-go unless there really is absolutely no other option.
There is too much scope for abuse.

Even if they were not, this takes no account of the zone or node
we are allocating from making it useful only in the case where the
system had a single node and zone. This applies to mobile devices
but not a lot of other systems.

It also would have very poor information about memory pressure which
is likely to be far more interesting and for that, awareness of what
is happening in page reclaim is required.

I haven't looked at the alternatives but there has been some vague
discussion recently on reviving the concept of a low memory notifier,
somehow making the existing memcg oom notifier global or maybe the
andro lowmem killer can be adapted to your needs.

> @@ -2298,6 +2322,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  	put_mems_allowed();
>  
>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +#ifdef CONFIG_MM_ALLOC_FREE_HOOK
> +	call_alloc_free_hook(1 << order);
> +#endif
> +
>  	return page;
>  }

you are calling a free hook there in the alloc path. Seems odd.

This is just a side-note but as this information is meant to be
consumed by userspace you have the option of hooking into the
mm_page_alloc tracepoint. You get the same information about how
many pages are allocated or freed. I accept that it will probably be
a bit slower but on the plus side it'll be backwards compatible and
you don't need a kernel patch for it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
