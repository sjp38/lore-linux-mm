Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4E8746B004D
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 16:34:04 -0500 (EST)
Date: Thu, 29 Dec 2011 08:33:59 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-ID: <20111228213359.GF12731@dastard>
References: <1324437036.4677.5.camel@hakkenden.homenet>
 <20111221095249.GA28474@tiehlicka.suse.cz>
 <20111221225512.GG23662@dastard>
 <1324630880.562.6.camel@rybalov.eng.ttk.net>
 <20111223102027.GB12731@dastard>
 <1324638242.562.15.camel@rybalov.eng.ttk.net>
 <20111223204503.GC12731@dastard>
 <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
 <1324954208.4634.2.camel@hakkenden.homenet>
 <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Nikolay S." <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 27, 2011 at 01:44:05PM +0900, KAMEZAWA Hiroyuki wrote:
> To me,  it seems kswapd does usual work...reclaim small memory until free
> gets enough. And it seems 'dd' allocates its memory from ZONE_DMA32 because
> of gfp_t fallbacks.
> 
> 
> Memo.
> 
> 1. why shrink_slab() should be called per zone, which is not zone aware.
>    Isn't it enough to call it per priority ?

It is intended that it should be zone aware, but the current
shrinkers only have global LRUs and hence cannot discriminate
between objects from different zones easily. And if only a single
node/zone is being scanned, then we still have to call shirnk_slab()
to try to free objects in that zone/node, despite it's current
global scope.

I have some prototype patches that make the major slab caches and
shrinkers zone/node aware - that is the eventual goal here - but
first all the major slab cache LRUs need to be converted to be node
aware first. Then we can pass a nodemask into shrink_slab() and down
to the shrinkers so that those that have per-node LRUs can scan only
the appropriate nodes for objects to free. This is someting that I'm
working on in my spare time, but I have very little of that at the
moment, unfortunately.

> 2. what spinlock contention that perf showed ?
>    And if shrink_slab() doesn't consume cpu as trace shows, why perf 
>    says shrink_slab() is heavy..

There isn't any spin lock contention - it's just showing how
expensive locking superblocks is when it's being done every few
microseconds for no good reason.

> 3. because 8/9 of memory is in DMA32, calling shrink_slab() frequently
>    at scanning NORMAL seems to be time wasting.

Especially as the shrink_slab() calls are returning zero pages freed
every single time (i.e. the slab caches are empty). kswapd needs to
back off here, I think, or free more memory at a time. Only freeing
100 pages at a time is pretty inefficient, esp. as we have 4 orders
of magnitude more pages on the LRU and that is consuming >90% of
RAM...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
