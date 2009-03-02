Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 77C8E6B0047
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 12:42:15 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n22Hg4iY007414
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 23:12:04 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n22HgA8g4186176
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 23:12:11 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n22Hg29w011729
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 23:12:02 +0530
Date: Mon, 2 Mar 2009 23:11:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090302174156.GM11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com> <20090302044043.GC11421@balbir.in.ibm.com> <20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com> <20090302060519.GG11421@balbir.in.ibm.com> <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com> <20090302063649.GJ11421@balbir.in.ibm.com> <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com> <20090302124210.GK11421@balbir.in.ibm.com> <c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 23:04:34]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02
> > 16:06:02]:
> >
> >> On Mon, 2 Mar 2009 12:06:49 +0530
> >> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> > OK, I get your point, but whay does that make RB-Tree data structure
> >> non-sense?
> >> >
> >>
> >>  1. Until memory-shortage, rb-tree is kept to be updated and the
> >> users(kernel)
> >>     has to pay its maintainace/check cost, whici is unnecessary.
> >>     Considering trade-off, paying cost only when memory-shortage happens
> >> tend to
> >>     be reasonable way.
> > As you've seen in the code, the cost is only at an interval HZ/2
> > currently. The other overhead is the calculation of excess, I can try
> > and see if we can get rid of it.
> >
> >>
> >>  2. Current "exceed" just shows "How much we got over my soft limit" but
> >> doesn't
> >>     tell any information per-node/zone. Considering this, this rb-tree
> >>     information will not be able to help kswapd (on NUMA).
> >>     But maintain per-node information uses too much resource.
> >
> > Yes, kswapd is per-node and we try to free all pages belonging to a
> > zonelist as specified by pgdat->node_zonelists for the memory control
> > groups that are over their soft limit. Keeping this information per
> > node makes no sense (exceeds information).
> >
> >>
> >>  Considering above 2, it's not bad to find victim by proper logic
> >>  from balance_pgdat() by using mem_cgroup_select_victim().
> >>  like this:
> >> ==
> >>  struct mem_cgroup *select_vicitim_at_soft_limit_via_balance_pgdat(int
> >> nid, int zid)
> >>  {
> >>      while (?) {
> >>         vitcim = mem_cgroup_select_victim(init_mem_cgroup);  #need some
> >> modification.
> >>         if (victim is not over soft-limit)
> >>              continue;
> >>         /* Ok this is candidate */
> >>         usage = mem_cgroup_nid_zid_usage(mem, nid, zid); #get sum of
> >> active/inactive
> >>         if (usage_is_enough_big)
> >>               return victim;
> >
> > We currently track overall usage, so we split into per nid, zid
> > information and use that? Is that your suggestion?
> 
> My suggestion is that current per-zone statistics interface of memcg
> already holds all necessary information. And aggregate usage information
> is not worth to be tracked becauset it's no help for kswapd.
>

We have that data, but we need aggregate data to see who exceeded the
limit.
 
> >  The soft limit is
> > also an aggregate limit, how do we define usage_is_big_enough or
> > usage_is_enough_big? Through some heuristics?
> >
> I think that if memcg/zone's page usage is not 0, it's enough big.
> (and round robin rotation as hierachical reclaim can be used.)
> 
> There maybe some threshold to try.
> 
> For example)
>    need_to_reclaim = zone->high - zone->free.
>    if (usage_in_this_zone_of_memcg > need_to_reclaim/4)
>          select this.
> 
> Maybe we can adjust that later.
> 

No... this looks broken by design. Even if the administrator sets a
large enough limit and no soft limits, the cgroup gets reclaimed from?


> >>      }
> >>  }
> >>  balance_pgdat()
> >>  ...... find target zone....
> >>  ...
> >>  mem = select_victime_at_soft_limit_via_balance_pgdat(nid, zid)
> >>  if (mem)
> >>    sc->mem = mem;
> >>  shrink_zone();
> >>  if (mem) {
> >>    sc->mem = NULL;
> >>    css_put(&mem->css);
> >>  }
> >> ==
> >>
> >>  We have to pay scan cost but it will not be too big(if there are not
> >> thousands of memcg.)
> >>  Under above, round-robin rotation is used rather than sort.
> >
> > Yes, we sort, but not frequently at every page-fault but at a
> > specified interval.
> >
> >>  Maybe I can show you sample.....(but I'm a bit busy.)
> >>
> >
> > Explanation and review is good, but I don't see how not-sorting will
> > help? I need something that can help me point to the culprits quickly
> > enough during soft limit reclaim and RB-Tree works very well for me.
> >
> 
> I don't think "tracking memcg which exceeds soft limit" is not worth
> to do in synchronous way. It can be done in lazy way when it's necessary
> in simpler logic.
>

The synchronous way can be harmful if we do it every page fault. THe
current logic is quite simple....no?
 
> BTW, did you do set-softlimit-zero and rmdir() test ?
> At quick review, memcg will never be removed from RB tree because
> force_empty moves account from children to parent. But no tree ops there.
> plz see mem_cgroup_move_account().
> 

__mme_cgroup_free() has tree ops, shouldn't that catch this scenario?

> I'm sorry if I missed something.
>

Thanks for the review and discussion. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
