Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 760398D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 19:50:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF0ofw3010987
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 09:50:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0270945DE7C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:50:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE61945DE81
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:50:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 015121DB8040
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:50:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 52849E38008
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 09:50:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
In-Reply-To: <20101114182614.BEE5.A69D9226@jp.fujitsu.com>
References: <20101109123246.GA11477@amd> <20101114182614.BEE5.A69D9226@jp.fujitsu.com>
Message-Id: <20101115092452.BEF1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Nov 2010 09:50:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > @@ -1835,8 +1978,6 @@ static void shrink_zone(int priority, st
> >  			break;
> >  	}
> >  
> > -	sc->nr_reclaimed = nr_reclaimed;
> > -
> >  	/*
> >  	 * Even if we did not try to evict anon pages at all, we want to
> >  	 * rebalance the anon lru active/inactive ratio.
> > @@ -1844,6 +1985,23 @@ static void shrink_zone(int priority, st
> >  	if (inactive_anon_is_low(zone, sc))
> >  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >  
> > +	/*
> > +	 * Don't shrink slabs when reclaiming memory from
> > +	 * over limit cgroups
> > +	 */
> > +	if (sc->may_reclaim_slab) {
> > +		struct reclaim_state *reclaim_state = current->reclaim_state;
> > +
> > +		shrink_slab(zone, sc->nr_scanned - nr_scanned,
> 
> Doubtful calculation. What mean "sc->nr_scanned - nr_scanned"?
> I think nr_scanned simply keep old slab balancing behavior.

And per-zone reclaim can lead to new issue. On 32bit highmem system,
theorically the system has following memory usage.

ZONE_HIGHMEM: 100% used for page cache
ZONE_NORMAL:  100% used for slab

So, traditional page-cache/slab balancing may not work. I think following
new calculation or somethinhg else is necessary.

	if (zone_reclaimable_pages() > NR_SLAB_RECLAIMABLE) {
		using current calculation
	} else {
		shrink number of "objects >> reclaim-priority" objects
		(as page cache scanning calculation)
	}

However, it can be separate this patch, perhaps.



> 
> 
> > +			lru_pages, global_lru_pages, sc->gfp_mask);
> > +		if (reclaim_state) {
> > +			nr_reclaimed += reclaim_state->reclaimed_slab;
> > +			reclaim_state->reclaimed_slab = 0;
> > +		}
> > +	}
> > +
> > +	sc->nr_reclaimed = nr_reclaimed;
> > +
> >  	throttle_vm_writeout(sc->gfp_mask);
> >  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
