Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 55BE66B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:54:13 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2ANs3me011430
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Mar 2009 08:54:03 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53E1C45DE51
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3107045DE50
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FAFC1DB803E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CC0121DB8041
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:02 +0900 (JST)
Date: Wed, 11 Mar 2009 08:52:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] memcg: softlimit caller via kswapd
Message-Id: <20090311085241.1b893df0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090310190242.GG26837@balbir.in.ibm.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309164218.b64251b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090310190242.GG26837@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 2009 00:32:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:42:18]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Looks like a dirty hack, replacing sc-> fields this way. I've
> experimented a lot with per zone balancing and soft limits and it does
> not work well. The reasons
> 
> 1. zone watermark balancing has a different goal than soft limit. Soft
> limits are more of a mem cgroup feature rather than node/zone feature.
I can't catch what you want to say, here.

> IIRC, you called reclaim as hot-path for soft limit reclaim, my
> experimentation is beginning to show changed behaviour
> 
> On a system with 4 CPUs and 4 Nodes, I find all CPUs spending time
> doing reclaim, putting the hook in the reclaim path, makes the reclaim
> dependent on the number of tasks and contention.
> 
> What does your test data/experimentation show?
> 

Not done very pricrse test but I admit that can happen.
(BTW, 1 cpu per 1 node ?)
How to call this is the my main concern, now.

BTW, when you don't use softlimit, CPUs won't spend time in reclaim ?
If 1 cpu per 1 node, 1 kswapd per 1 node. So, it doesn't sound strange.

If it's better to add a softlimitd() for the system (means 1 thread for
the whole system), modification is not difficult.
(I think my code doesn't assume the caller is kswapd() other than /* comment */)

Thanks,
-Kame

> > +		scan -= sc->nr_scanned;
> > +	}
> > +	return;
> > +}
> >  /*
> >   * For kswapd, balance_pgdat() will work across all this node's zones until
> >   * they are all at pages_high.
> > @@ -1776,6 +1813,8 @@ static unsigned long balance_pgdat(pg_da
> >  	 */
> >  	int temp_priority[MAX_NR_ZONES];
> > 
> > +	/* Refill softlimit queue */
> > +	mem_cgroup_reschedule(pgdat->node_id);
> >  loop_again:
> >  	total_scanned = 0;
> >  	sc.nr_reclaimed = 0;
> > @@ -1856,6 +1895,9 @@ loop_again:
> >  					       end_zone, 0))
> >  				all_zones_ok = 0;
> >  			temp_priority[i] = priority;
> > +			/* Try soft limit at first */
> > +			shrink_zone_softlimit(&sc, zone, order, priority,
> > +					       8 * zone->pages_high, end_zone);
> >  			sc.nr_scanned = 0;
> >  			note_zone_scanning_priority(zone, priority);
> >  			/*
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
