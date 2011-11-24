Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD006B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 08:12:26 -0500 (EST)
Date: Thu, 24 Nov 2011 14:11:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across zones
Message-ID: <20111124131155.GB1225@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
 <1322055258-3254-4-git-send-email-hannes@cmpxchg.org>
 <20111124100755.d8b783a8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124100755.d8b783a8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 10:07:55AM +0900, KAMEZAWA Hiroyuki wrote:
> 
> 
> Can I make a question ?
> 
> On Wed, 23 Nov 2011 14:34:16 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> 
> > +		/*
> > +		 * When allocating a page cache page for writing, we
> > +		 * want to get it from a zone that is within its dirty
> > +		 * limit, such that no single zone holds more than its
> > +		 * proportional share of globally allowed dirty pages.
> > +		 * The dirty limits take into account the zone's
> > +		 * lowmem reserves and high watermark so that kswapd
> > +		 * should be able to balance it without having to
> > +		 * write pages from its LRU list.
> > +		 *
> > +		 * This may look like it could increase pressure on
> > +		 * lower zones by failing allocations in higher zones
> > +		 * before they are full.  But the pages that do spill
> > +		 * over are limited as the lower zones are protected
> > +		 * by this very same mechanism.  It should not become
> > +		 * a practical burden to them.
> > +		 *
> > +		 * XXX: For now, allow allocations to potentially
> > +		 * exceed the per-zone dirty limit in the slowpath
> > +		 * (ALLOC_WMARK_LOW unset) before going into reclaim,
> > +		 * which is important when on a NUMA setup the allowed
> > +		 * zones are together not big enough to reach the
> > +		 * global limit.  The proper fix for these situations
> > +		 * will require awareness of zones in the
> > +		 * dirty-throttling and the flusher threads.
> > +		 */
> > +		if ((alloc_flags & ALLOC_WMARK_LOW) &&
> > +		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> > +			goto this_zone_full;
> >  
> >  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
> >  		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> 
> This wil call 
> 
>                 if (NUMA_BUILD)
>                         zlc_mark_zone_full(zonelist, z);
> 
> And this zone will be marked as full. 
> 
> IIUC, zlc_clear_zones_full() is called only when direct reclaim ends.
> So, if no one calls direct-reclaim, 'full' mark may never be cleared
> even when number of dirty pages goes down to safe level ?
> I'm sorry if this is alread discussed.

It does not remember which zones are marked full for longer than a
second - see zlc_setup() - and also ignores this information when an
iteration over the zonelist with the cache enabled came up
empty-handed.

I thought it would make sense to take advantage of the cache and save
the zone_dirty_ok() checks against ineligible zones too on subsequent
iterations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
