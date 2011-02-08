Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5873B8D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 18:58:02 -0500 (EST)
Date: Tue, 8 Feb 2011 15:57:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3][RESEND] Provide control over unmapped pages (v4)
Message-Id: <20110208155756.e149c3b6.akpm@linux-foundation.org>
In-Reply-To: <20110201165533.12377.11775.stgit@localhost6.localdomain6>
References: <20110201165329.12377.13683.stgit@localhost6.localdomain6>
	<20110201165533.12377.11775.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

On Tue, 01 Feb 2011 22:25:45 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Changelog v4
> 1. Add max_unmapped_ratio and use that as the upper limit
> to check when to shrink the unmapped page cache (Christoph
> Lameter)
> 
> Changelog v2
> 1. Use a config option to enable the code (Andrew Morton)
> 2. Explain the magic tunables in the code or at-least attempt
>    to explain them (General comment)
> 3. Hint uses of the boot parameter with unlikely (Andrew Morton)
> 4. Use better names (balanced is not a good naming convention)
> 
> Provide control using zone_reclaim() and a boot parameter. The
> code reuses functionality from zone_reclaim() to isolate unmapped
> pages and reclaim them as a priority, ahead of other mapped pages.
> A new sysctl for max_unmapped_ratio is provided and set to 16,
> indicating 16% of the total zone pages are unmapped, we start
> shrinking unmapped page cache.

We'll need some documentation for sysctl_max_unmapped_ratio, please. 
In Documentation/sysctl/vm.txt, I suppose.

It will be interesting to find out what this ratio refers to.  it
apears to be a percentage.  We've had problem in the past where 1% was
way too much and we had to change the kernel to provide much
finer-grained control.

>
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -306,7 +306,10 @@ struct zone {
>  	/*
>  	 * zone reclaim becomes active if more unmapped pages exist.
>  	 */
> +#if defined(CONFIG_UNMAPPED_PAGE_CONTROL) || defined(CONFIG_NUMA)
>  	unsigned long		min_unmapped_pages;
> +	unsigned long		max_unmapped_pages;
> +#endif

This change breaks the connection between min_unmapped_pages and its
documentation, and fails to document max_unmapped_pages.

Also, afacit if CONFIG_NUMA=y and CONFIG_UNMAPPED_PAGE_CONTROL=n,
max_unmapped_pages will be present in the kernel image and will appear
in /proc but it won't actually do anything.  Seems screwed up and
misleading.

>
> ...
>
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +/*
> + * Routine to reclaim unmapped pages, inspired from the code under
> + * CONFIG_NUMA that does unmapped page and slab page control by keeping
> + * min_unmapped_pages in the zone. We currently reclaim just unmapped
> + * pages, slab control will come in soon, at which point this routine
> + * should be called reclaim cached pages
> + */
> +unsigned long reclaim_unmapped_pages(int priority, struct zone *zone,
> +						struct scan_control *sc)
> +{
> +	if (unlikely(unmapped_page_control) &&
> +		(zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
> +		struct scan_control nsc;
> +		unsigned long nr_pages;
> +
> +		nsc = *sc;
> +
> +		nsc.swappiness = 0;
> +		nsc.may_writepage = 0;
> +		nsc.may_unmap = 0;
> +		nsc.nr_reclaimed = 0;
> +
> +		nr_pages = zone_unmapped_file_pages(zone) -
> +				zone->min_unmapped_pages;
> +		/*
> +		 * We don't want to be too aggressive with our
> +		 * reclaim, it is our best effort to control
> +		 * unmapped pages
> +		 */
> +		nr_pages >>= 3;
> +
> +		zone_reclaim_pages(zone, &nsc, nr_pages);
> +		return nsc.nr_reclaimed;
> +	}
> +	return 0;
> +}

This returns an undocumented ulong which is never used by callers.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
