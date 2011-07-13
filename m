Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F3FD69000C2
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 20:42:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1F73E3EE081
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:42:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 056C72AEA8E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:42:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4D792E68C1
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:42:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D52B61DB804F
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:42:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F39A1DB8048
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:42:38 +0900 (JST)
Message-ID: <4E1CE9FF.3050707@jp.fujitsu.com>
Date: Wed, 13 Jul 2011 09:42:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: page allocator: Reconsider zones for allocation
 after direct reclaim
References: <1310389274-13995-1-git-send-email-mgorman@suse.de> <1310389274-13995-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1310389274-13995-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/07/11 22:01), Mel Gorman wrote:
> With zone_reclaim_mode enabled, it's possible for zones to be considered
> full in the zonelist_cache so they are skipped in the future. If the
> process enters direct reclaim, the ZLC may still consider zones to be
> full even after reclaiming pages. Reconsider all zones for allocation
> if direct reclaim returns successfully.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Hmmm...

I like the concept, but I'm worry about a corner case a bit.

If users are using cpusets/mempolicy, direct reclaim don't scan all zones.
Then, zlc_clear_zones_full() seems too aggressive operation.
Instead, couldn't we turn zlc->fullzones off from kswapd?


> ---
>  mm/page_alloc.c |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6913854..149409c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1616,6 +1616,21 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
>  	set_bit(i, zlc->fullzones);
>  }
>  
> +/*
> + * clear all zones full, called after direct reclaim makes progress so that
> + * a zone that was recently full is not skipped over for up to a second
> + */
> +static void zlc_clear_zones_full(struct zonelist *zonelist)
> +{
> +	struct zonelist_cache *zlc;	/* cached zonelist speedup info */
> +
> +	zlc = zonelist->zlcache_ptr;
> +	if (!zlc)
> +		return;
> +
> +	bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
> +}
> +
>  #else	/* CONFIG_NUMA */
>  
>  static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
> @@ -1963,6 +1978,10 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  	if (unlikely(!(*did_some_progress)))
>  		return NULL;
>  
> +	/* After successful reclaim, reconsider all zones for allocation */
> +	if (NUMA_BUILD)
> +		zlc_clear_zones_full(zonelist);
> +
>  retry:
>  	page = get_page_from_freelist(gfp_mask, nodemask, order,
>  					zonelist, high_zoneidx,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
