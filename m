Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9C33C6B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:21:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7LuHh025961
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:21:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1344645DE7A
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:21:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AD245DE6E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:21:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCB3B1DB803E
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:21:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 712DE1DB803F
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:21:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
In-Reply-To: <20101116074717.GB3460@amd>
References: <20101115092452.BEF1.A69D9226@jp.fujitsu.com> <20101116074717.GB3460@amd>
Message-Id: <20101123162027.7BB0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:21:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Sorry for the delay. Recently I have no time at all ;)


> On Mon, Nov 15, 2010 at 09:50:36AM +0900, KOSAKI Motohiro wrote:
> > > > @@ -1835,8 +1978,6 @@ static void shrink_zone(int priority, st
> > > >  			break;
> > > >  	}
> > > >  
> > > > -	sc->nr_reclaimed = nr_reclaimed;
> > > > -
> > > >  	/*
> > > >  	 * Even if we did not try to evict anon pages at all, we want to
> > > >  	 * rebalance the anon lru active/inactive ratio.
> > > > @@ -1844,6 +1985,23 @@ static void shrink_zone(int priority, st
> > > >  	if (inactive_anon_is_low(zone, sc))
> > > >  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> > > >  
> > > > +	/*
> > > > +	 * Don't shrink slabs when reclaiming memory from
> > > > +	 * over limit cgroups
> > > > +	 */
> > > > +	if (sc->may_reclaim_slab) {
> > > > +		struct reclaim_state *reclaim_state = current->reclaim_state;
> > > > +
> > > > +		shrink_slab(zone, sc->nr_scanned - nr_scanned,
> > > 
> > > Doubtful calculation. What mean "sc->nr_scanned - nr_scanned"?
> > > I think nr_scanned simply keep old slab balancing behavior.
> > 
> > And per-zone reclaim can lead to new issue. On 32bit highmem system,
> > theorically the system has following memory usage.
> > 
> > ZONE_HIGHMEM: 100% used for page cache
> > ZONE_NORMAL:  100% used for slab
> > 
> > So, traditional page-cache/slab balancing may not work. I think following
> 
> Yes, in theory you are right. I guess in theory the same hole exists
> if we have 0% page cache reclaimable globally, but this may be slightly
> more likely to hit.

I'm not worry about so much "0% page cache reclaimable globally" case
because I doubt it can be happen in real.


> > new calculation or somethinhg else is necessary.
> > 
> > 	if (zone_reclaimable_pages() > NR_SLAB_RECLAIMABLE) {
> > 		using current calculation
> > 	} else {
> > 		shrink number of "objects >> reclaim-priority" objects
> > 		(as page cache scanning calculation)
> > 	}
> > 
> > However, it can be separate this patch, perhaps.
> 
> I agree. In fact, perhaps the new calculation would work well in all
> cases anyway, so maybe we should move away from making slab reclaim a
> slave to pagecache reclaim.
> 
> Can we approach that in subsequent patches?

OK!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
