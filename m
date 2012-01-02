Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D966D6B004D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 02:00:21 -0500 (EST)
Date: Mon, 2 Jan 2012 18:00:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-ID: <20120102070017.GO23662@dastard>
References: <20111221225512.GG23662@dastard>
 <1324630880.562.6.camel@rybalov.eng.ttk.net>
 <20111223102027.GB12731@dastard>
 <1324638242.562.15.camel@rybalov.eng.ttk.net>
 <20111223204503.GC12731@dastard>
 <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
 <1324954208.4634.2.camel@hakkenden.homenet>
 <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
 <20111228213359.GF12731@dastard>
 <4EFB9EE2.1050903@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EFB9EE2.1050903@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Nikolay S." <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 28, 2011 at 05:57:38PM -0500, KOSAKI Motohiro wrote:
> (12/28/11 4:33 PM), Dave Chinner wrote:
> >On Tue, Dec 27, 2011 at 01:44:05PM +0900, KAMEZAWA Hiroyuki wrote:
> >>To me,  it seems kswapd does usual work...reclaim small memory until free
> >>gets enough. And it seems 'dd' allocates its memory from ZONE_DMA32 because
> >>of gfp_t fallbacks.
> >>
> >>
> >>Memo.
> >>
> >>1. why shrink_slab() should be called per zone, which is not zone aware.
> >>    Isn't it enough to call it per priority ?
> >
> >It is intended that it should be zone aware, but the current
> >shrinkers only have global LRUs and hence cannot discriminate
> >between objects from different zones easily. And if only a single
> >node/zone is being scanned, then we still have to call shirnk_slab()
> >to try to free objects in that zone/node, despite it's current
> >global scope.
> >
> >I have some prototype patches that make the major slab caches and
> >shrinkers zone/node aware - that is the eventual goal here - but
> >first all the major slab cache LRUs need to be converted to be node
> >aware first. Then we can pass a nodemask into shrink_slab() and down
> >to the shrinkers so that those that have per-node LRUs can scan only
> >the appropriate nodes for objects to free. This is someting that I'm
> >working on in my spare time, but I have very little of that at the
> >moment, unfortunately.
> 
> His machine only have one node. per node basis don't help him.

You've got hung up on a little detail like how to define locality(*)
and so completely missed my point.

That being: Improving reclaim granularity won't help at all until
the subsystems index their caches in a more fine grained manner.
And with work in progress to make the shrinkers *locality* aware,
then maybe per-priority is not sufficient, either.

IOWs, I don't think there's a right answer to your question, but
there's a good chance that it will be irrelevant given work that is
in progress...

Cheers,

Dave.

----

(*) Keep in mind that the biggest problem with the current
LRU/shrinker implementations is not the shrinker - it's that lock
contention in fast paths is a major performance limiting factor. In
the VFS, that limit is hit somewhere between 8-16 concurrent
processes all banging on a filesystem doing metadata intensive work.

That's the real problem we have to solve first, and what I'm trying
to do is solve it in a way that -aligns- to the MM architecture.
Forcing everyone to know about MM zones is not the right way to go -
it means we can't easily change the internals of the MM subsystem
without touching 20-30 external shrinker implementations. IOWs,
there needs to be a level of abstraction between the MM internals
and the shrinker API exposed to other subsystems.

However, we still need to expose some type of locality information
through that interface to allow the MM to shrink caches in a more
efficient manner.  Given that the allocation interfaces expose
per-node interfaces and so programmers are familiar with this method
of specifying locality, it seems natural to make the shrinker API
symmetric with that. And given that most caches are allocated out of
a single zone per node, having per-zone LRUs is just going to waste
a lot of memory....

But we should really discuss this when I post the patches again...

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
