Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2D452900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 19:59:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C97FD3EE0AE
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:59:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB25345DE5A
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:59:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82DA545DE58
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:59:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 776A11DB804B
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:59:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 425A81DB8051
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:59:53 +0900 (JST)
Date: Thu, 18 Aug 2011 08:52:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-Id: <20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110817113550.GA7482@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110810141425.GC15007@tiehlicka.suse.cz>
	<20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110811145055.GN8023@tiehlicka.suse.cz>
	<20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
	<20110817113550.GA7482@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, 17 Aug 2011 13:35:50 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 17-08-11 09:54:05, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Aug 2011 16:50:55 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > What about this (just compile tested)?
> > > --- 
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Subject: memcg: add nr_pages argument for hierarchical reclaim
> > > 
> > > Now that we are doing memcg direct reclaim limited to nr_to_reclaim
> > > pages (introduced by "memcg: stop vmscan when enough done.") we have to
> > > be more careful. Currently we are using SWAP_CLUSTER_MAX which is OK for
> > > most callers but it might cause failures for limit resize or force_empty
> > > code paths on big NUMA machines.
> > > 
> > > Previously we might have reclaimed up to nr_nodes * SWAP_CLUSTER_MAX
> > > while now we have it at SWAP_CLUSTER_MAX. Both resize and force_empty rely
> > > on reclaiming a certain amount of pages and retrying if their condition is
> > > still not met.
> > > 
> > > Let's add nr_pages argument to mem_cgroup_hierarchical_reclaim which will
> > > push it further to try_to_free_mem_cgroup_pages. We still fall back to
> > > SWAP_CLUSTER_MAX for small requests so the standard code (hot) paths are not
> > > affected by this.
> > > 
> > > Open questions:
> > > - Should we care about soft limit as well? Currently I am using excess
> > >   number of pages for the parameter so it can replace direct query for
> > >   the value in mem_cgroup_hierarchical_reclaim but should we push it to
> > >   mem_cgroup_shrink_node_zone?
> > >   I do not think so because we should try to reclaim from more groups in the
> > >   hierarchy and also it doesn't get to shrink_zones which has been modified
> > >   by the previous patch.
> > 
> > 
> > 
> > > - mem_cgroup_force_empty asks for reclaiming all pages. I guess it should be
> > >   OK but will have to think about it some more.
> > 
> > force_empty/rmdir() is allowed to be stopped by Ctrl-C. I think passing res->usage
> > is overkilling.
> 
> So, how many pages should be reclaimed then?
> 

How about (1 << (MAX_ORDER-1))/loop ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
