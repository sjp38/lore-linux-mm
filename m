Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7540B6B003D
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 19:00:42 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2300cgM006348
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Mar 2009 09:00:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7602145DE54
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:00:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BFC7F45DE4F
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:00:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 77C5EE08009
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:00:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94CE8E0800E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:00:31 +0900 (JST)
Date: Tue, 3 Mar 2009 08:59:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-Id: <20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090302174156.GM11421@balbir.in.ibm.com>
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain>
	<20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302044043.GC11421@balbir.in.ibm.com>
	<20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302060519.GG11421@balbir.in.ibm.com>
	<20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302063649.GJ11421@balbir.in.ibm.com>
	<20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090302124210.GK11421@balbir.in.ibm.com>
	<c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com>
	<20090302174156.GM11421@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Mar 2009 23:11:56 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 23:04:34]:
> 
> > Balbir Singh wrote:
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02
> > > 16:06:02]:
> > >
> > >> On Mon, 2 Mar 2009 12:06:49 +0530
> > >> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > >> > OK, I get your point, but whay does that make RB-Tree data structure
> > >> non-sense?
> > >> >
> > >>
> > >>  1. Until memory-shortage, rb-tree is kept to be updated and the
> > >> users(kernel)
> > >>     has to pay its maintainace/check cost, whici is unnecessary.
> > >>     Considering trade-off, paying cost only when memory-shortage happens
> > >> tend to
> > >>     be reasonable way.
> > > As you've seen in the code, the cost is only at an interval HZ/2
> > > currently. The other overhead is the calculation of excess, I can try
> > > and see if we can get rid of it.
> > >
> > >>
> > >>  2. Current "exceed" just shows "How much we got over my soft limit" but
> > >> doesn't
> > >>     tell any information per-node/zone. Considering this, this rb-tree
> > >>     information will not be able to help kswapd (on NUMA).
> > >>     But maintain per-node information uses too much resource.
> > >
> > > Yes, kswapd is per-node and we try to free all pages belonging to a
> > > zonelist as specified by pgdat->node_zonelists for the memory control
> > > groups that are over their soft limit. Keeping this information per
> > > node makes no sense (exceeds information).
> > >
> > >>
> > >>  Considering above 2, it's not bad to find victim by proper logic
> > >>  from balance_pgdat() by using mem_cgroup_select_victim().
> > >>  like this:
> > >> ==
> > >>  struct mem_cgroup *select_vicitim_at_soft_limit_via_balance_pgdat(int
> > >> nid, int zid)
> > >>  {
> > >>      while (?) {
> > >>         vitcim = mem_cgroup_select_victim(init_mem_cgroup);  #need some
> > >> modification.
> > >>         if (victim is not over soft-limit)
> > >>              continue;
> > >>         /* Ok this is candidate */
> > >>         usage = mem_cgroup_nid_zid_usage(mem, nid, zid); #get sum of
> > >> active/inactive
> > >>         if (usage_is_enough_big)
> > >>               return victim;
> > >
> > > We currently track overall usage, so we split into per nid, zid
> > > information and use that? Is that your suggestion?
> > 
> > My suggestion is that current per-zone statistics interface of memcg
> > already holds all necessary information. And aggregate usage information
> > is not worth to be tracked becauset it's no help for kswapd.
> >
> 
> We have that data, but we need aggregate data to see who exceeded the
> limit.
>  
Aggregate data is in res_counter, already.



> > >  The soft limit is
> > > also an aggregate limit, how do we define usage_is_big_enough or
> > > usage_is_enough_big? Through some heuristics?
> > >
> > I think that if memcg/zone's page usage is not 0, it's enough big.
> > (and round robin rotation as hierachical reclaim can be used.)
> > 
> > There maybe some threshold to try.
> > 
> > For example)
> >    need_to_reclaim = zone->high - zone->free.
> >    if (usage_in_this_zone_of_memcg > need_to_reclaim/4)
> >          select this.
> > 
> > Maybe we can adjust that later.
> > 
> 
> No... this looks broken by design. Even if the administrator sets a
> large enough limit and no soft limits, the cgroup gets reclaimed from?
> 
I wrote
==
 if (victim is not over soft-limit)
==
....Maybe this discussion style is bad and I should explain my approach in patch.
(I can't write code today, sorry.)


> 
> > >>      }
> > >>  }
> > >>  balance_pgdat()
> > >>  ...... find target zone....
> > >>  ...
> > >>  mem = select_victime_at_soft_limit_via_balance_pgdat(nid, zid)
> > >>  if (mem)
> > >>    sc->mem = mem;
> > >>  shrink_zone();
> > >>  if (mem) {
> > >>    sc->mem = NULL;
> > >>    css_put(&mem->css);
> > >>  }
> > >> ==
> > >>
> > >>  We have to pay scan cost but it will not be too big(if there are not
> > >> thousands of memcg.)
> > >>  Under above, round-robin rotation is used rather than sort.
> > >
> > > Yes, we sort, but not frequently at every page-fault but at a
> > > specified interval.
> > >
> > >>  Maybe I can show you sample.....(but I'm a bit busy.)
> > >>
> > >
> > > Explanation and review is good, but I don't see how not-sorting will
> > > help? I need something that can help me point to the culprits quickly
> > > enough during soft limit reclaim and RB-Tree works very well for me.
> > >
> > 
> > I don't think "tracking memcg which exceeds soft limit" is not worth
> > to do in synchronous way. It can be done in lazy way when it's necessary
> > in simpler logic.
> >
> 
> The synchronous way can be harmful if we do it every page fault. THe
> current logic is quite simple....no?
In my point of view, No.

For example, I can never be able to explain why Hz/4 is the best and
why we have to maintain the tree while there are no memory shortage.

IMHO, Under well controlled system with cgroup, problematic applications
and very huge file cache users are udner limitation. Memory shortage can be
rare event after all.

But, on NUMA, because memcg just checks "usage" and doesn't check
"usage-per-node", there can be memory shortage and this kind of soft-limit
sounds attractive for me.

>  
> > BTW, did you do set-softlimit-zero and rmdir() test ?
> > At quick review, memcg will never be removed from RB tree because
> > force_empty moves account from children to parent. But no tree ops there.
> > plz see mem_cgroup_move_account().
> > 
> 
> __mme_cgroup_free() has tree ops, shouldn't that catch this scenario?
> 
Ok, I missed that. Thank you for clarification.

Regards.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
