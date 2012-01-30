Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E135C6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:05:43 -0500 (EST)
Date: Mon, 30 Jan 2012 13:05:40 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/15] mm: trigger page reclaim in alloc_contig_range()
 to stabilize watermarks
Message-ID: <20120130130540.GN25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-12-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-12-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:53AM +0100, Marek Szyprowski wrote:
> alloc_contig_range() performs memory allocation so it also should keep
> track on keeping the correct level of memory watermarks. This commit adds
> a call to *_slowpath style reclaim to grab enough pages to make sure that
> the final collection of contiguous pages from freelists will not starve
> the system.
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> ---
>  mm/page_alloc.c |   36 ++++++++++++++++++++++++++++++++++++
>  1 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e35d06b..05eaa82 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5613,6 +5613,34 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>  	return ret;
>  }
>  
> +/*
> + * Trigger memory pressure bump to reclaim some pages in order to be able to
> + * allocate 'count' pages in single page units. Does similar work as
> + *__alloc_pages_slowpath() function.
> + */
> +static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
> +{
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
> +	int did_some_progress = 0;
> +	int order = 1;
> +	unsigned long watermark;
> +
> +	/* Obey watermarks as if the page was being allocated */
> +	watermark = low_wmark_pages(zone) + count;
> +	while (!zone_watermark_ok(zone, 0, watermark, 0, 0)) {
> +		wake_all_kswapd(order, zonelist, high_zoneidx, zone_idx(zone));
> +
> +		did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
> +						      NULL);
> +		if (!did_some_progress) {
> +			/* Exhausted what can be done so it's blamo time */
> +			out_of_memory(zonelist, gfp_mask, order, NULL);
> +		}

There are three problems here

1. CMA can trigger the OOM killer.

That seems like overkill to me but as I do not know the consequences
of CMA failing, it's your call.

2. You cannot guarantee that try_to_free_pages will free pages from the
   zone you care about or that kswapd will do anything

You check the watermarks and take into account the size of the pending
CMA allocation. kswapd in vmscan.c on the other hand will simply check
the watermarks and probably go back to sleep. You should be aware of
this in case you ever get bugs that CMA takes too long and that it
appears to be stuck in this loop with kswapd staying asleep.

3. You reclaim from zones other than your target zone

try_to_free_pages is not necessarily going to free pages in the
zone you are checking for. It'll work on ARM in many cases because
there will be only one zone but on other arches, this logic will
be problematic and will potentially livelock. You need to pass in
a zonelist that only contains the zone that CMA cares about. If it
cannot reclaim, did_some_progress == 0 and it'll exit. Otherwise
there is a possibility that this will loop forever reclaiming pages
from the wrong zones.

I won't ack this particular patch but I am not going to insist that
you fix these prior to merging either. If you leave problem 3 as it
is, I would really like to see a comment explaning the problem for
future users of CMA on other arches (if they exist).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
