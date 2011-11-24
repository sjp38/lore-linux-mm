Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E63426B00A1
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 20:09:09 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EBCD03EE0C2
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 10:09:06 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C22F645DF4F
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 10:09:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8112145DF48
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 10:09:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FC2F1DB8040
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 10:09:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 348001DB8051
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 10:09:06 +0900 (JST)
Date: Thu, 24 Nov 2011 10:07:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across
 zones
Message-Id: <20111124100755.d8b783a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1322055258-3254-4-git-send-email-hannes@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
	<1322055258-3254-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org



Can I make a question ?

On Wed, 23 Nov 2011 14:34:16 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:


> +		/*
> +		 * When allocating a page cache page for writing, we
> +		 * want to get it from a zone that is within its dirty
> +		 * limit, such that no single zone holds more than its
> +		 * proportional share of globally allowed dirty pages.
> +		 * The dirty limits take into account the zone's
> +		 * lowmem reserves and high watermark so that kswapd
> +		 * should be able to balance it without having to
> +		 * write pages from its LRU list.
> +		 *
> +		 * This may look like it could increase pressure on
> +		 * lower zones by failing allocations in higher zones
> +		 * before they are full.  But the pages that do spill
> +		 * over are limited as the lower zones are protected
> +		 * by this very same mechanism.  It should not become
> +		 * a practical burden to them.
> +		 *
> +		 * XXX: For now, allow allocations to potentially
> +		 * exceed the per-zone dirty limit in the slowpath
> +		 * (ALLOC_WMARK_LOW unset) before going into reclaim,
> +		 * which is important when on a NUMA setup the allowed
> +		 * zones are together not big enough to reach the
> +		 * global limit.  The proper fix for these situations
> +		 * will require awareness of zones in the
> +		 * dirty-throttling and the flusher threads.
> +		 */
> +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> +		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> +			goto this_zone_full;
>  
>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
>  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {

This wil call 

                if (NUMA_BUILD)
                        zlc_mark_zone_full(zonelist, z);

And this zone will be marked as full. 

IIUC, zlc_clear_zones_full() is called only when direct reclaim ends.
So, if no one calls direct-reclaim, 'full' mark may never be cleared
even when number of dirty pages goes down to safe level ?
I'm sorry if this is alread discussed.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
