Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 95E816B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 18:17:34 -0500 (EST)
Date: Wed, 10 Nov 2010 15:16:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch]vmscan: avoid set zone congested if no page dirty
Message-Id: <20101110151637.69393904.akpm@linux-foundation.org>
In-Reply-To: <1288831858.23014.129.camel@sli10-conroe>
References: <1288831858.23014.129.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, mel <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 04 Nov 2010 08:50:58 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> nr_dirty and nr_congested are increased only when page is dirty. So if all pages
> are clean, both them will be zero. In this case, we should not mark the zone
> congested.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b8a6fdc..d31d7ce 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -913,7 +913,7 @@ keep_lumpy:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty == nr_congested)
> +	if (nr_dirty == nr_congested && nr_dirty != 0)
>  		zone_set_flag(zone, ZONE_CONGESTED);
>  
>  	free_page_list(&free_pages);

In a way, this was a really big bug.  Reclaim will set the zone as
congested a *lot* - when reclaiming simple, clean pagecache.  It does
appear that kswapd will unset it a lot too, so the net effect isn't
obvious.

However most of the time, the atomic_read(&nr_bdi_congested[sync]) in
wait_iff_congested() will prevent this bug from causing harm.



btw, it's irritating that we have this asymmetry:

setter: zone_set_flag(zone, ZONE_CONGESTED)
getter: zone_is_reclaim_congested(zone)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
