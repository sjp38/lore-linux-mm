Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D63AF6B0169
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 19:38:06 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 32A123EE0BD
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:38:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16A3E45DE5C
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:38:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D77E445DE58
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:38:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C82B51DB8054
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:38:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 820231DB804F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:38:02 +0900 (JST)
Date: Thu, 11 Aug 2011 08:30:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 1/6]  memg: better numa scanning
Message-Id: <20110811083043.a3b2ba65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110810100042.GA15007@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810100042.GA15007@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 10 Aug 2011 12:00:42 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-08-11 19:08:24, KAMEZAWA Hiroyuki wrote:
> > 
> > Making memcg numa's scanning information update by schedule_work().
> > 
> > Now, memcg's numa information is updated under a thread doing
> > memory reclaim. It's not very heavy weight now. But upcoming updates
> > around numa scanning will add more works. This patch makes
> > the update be done by schedule_work() and reduce latency caused
> > by this updates.
> 
> I am not sure whether this pays off. Anyway, I think it would be better
> to place this patch somewhere at the end of the series so that we can
> measure its impact separately.
> 

I'll consider reordering when I come back from vacation.

> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Otherwise looks good to me.
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> 

Thanks.

> Just a minor nit bellow.
> 
> > ---
> >  mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++------------
> >  1 file changed, 30 insertions(+), 12 deletions(-)
> > 
> > Index: mmotm-Aug3/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-Aug3.orig/mm/memcontrol.c
> > +++ mmotm-Aug3/mm/memcontrol.c
> > @@ -285,6 +285,7 @@ struct mem_cgroup {
> >  	nodemask_t	scan_nodes;
> >  	atomic_t	numainfo_events;
> >  	atomic_t	numainfo_updating;
> > +	struct work_struct	numainfo_update_work;
> >  #endif
> >  	/*
> >  	 * Should the accounting and control be hierarchical, per subtree?
> > @@ -1567,6 +1568,23 @@ static bool test_mem_cgroup_node_reclaim
> >  }
> >  #if MAX_NUMNODES > 1
> >  
> > +static void mem_cgroup_numainfo_update_work(struct work_struct *work)
> > +{
> > +	struct mem_cgroup *memcg;
> > +	int nid;
> > +
> > +	memcg = container_of(work, struct mem_cgroup, numainfo_update_work);
> > +
> > +	memcg->scan_nodes = node_states[N_HIGH_MEMORY];
> > +	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
> > +		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
> > +			node_clear(nid, memcg->scan_nodes);
> > +	}
> > +	atomic_set(&memcg->numainfo_updating, 0);
> > +	css_put(&memcg->css);
> > +}
> > +
> > +
> >  /*
> >   * Always updating the nodemask is not very good - even if we have an empty
> >   * list or the wrong list here, we can start from some node and traverse all
> > @@ -1575,7 +1593,6 @@ static bool test_mem_cgroup_node_reclaim
> >   */
> 
> Would be good to update the function comment as well (we still have 10s
> period there).
> 

ok.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
