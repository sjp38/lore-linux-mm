Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB636B0055
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 07:42:26 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n22CgE1N007491
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 18:12:14 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n22CdGXj4407412
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 18:09:16 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n22CgDso005930
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 23:42:13 +1100
Date: Mon, 2 Mar 2009 18:12:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090302124210.GK11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090302092404.1439d2a6.kamezawa.hiroyu@jp.fujitsu.com> <20090302044043.GC11421@balbir.in.ibm.com> <20090302143250.f47758f9.kamezawa.hiroyu@jp.fujitsu.com> <20090302060519.GG11421@balbir.in.ibm.com> <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com> <20090302063649.GJ11421@balbir.in.ibm.com> <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 16:06:02]:

> On Mon, 2 Mar 2009 12:06:49 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 15:21:28]:
> > 
> > > On Mon, 2 Mar 2009 11:35:19 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 14:32:50]:
> > > > 
> > > > > On Mon, 2 Mar 2009 10:10:43 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-02 09:24:04]:
> > > > > > 
> > > > > > > On Sun, 01 Mar 2009 11:59:59 +0530
> > > > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > > > 
> > > > > > > > 
> > > > > > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > > 
> > > > > > > 
> > > > > > > At first, it's said "When cgroup people adds something, the kernel gets slow".
> > > > > > > This is my start point of reviewing. Below is comments to this version of patch.
> > > > > > > 
> > > > > > >  1. I think it's bad to add more hooks to res_counter. It's enough slow to give up
> > > > > > >     adding more fancy things..
> > > > > > 
> > > > > > res_counters was desgined to be extensible, why is adding anything to
> > > > > > it going to make it slow, unless we turn on soft_limits?
> > > > > > 
> > > > > You inserted new "if" logic in the core loop.
> > > > > (What I want to say here is not that this is definitely bad but that "isn't there
> > > > >  any alternatives which is less overhead.)
> > > > > 
> > > > > 
> > > > > > > 
> > > > > > >  2. please avoid to add hooks to hot-path. In your patch, especially a hook to
> > > > > > >     mem_cgroup_uncharge_common() is annoying me.
> > > > > > 
> > > > > > If soft limits are not enabled, the function does a small check and
> > > > > > leaves. 
> > > > > > 
> > > > > &soft_fail_res is passed always even if memory.soft_limit==ULONG_MAX
> > > > > res_counter_soft_limit_excess() adds one more function call and spinlock, and irq-off.
> > > > >
> > > > 
> > > > OK, I see that overhead.. I'll figure out a way to work around it.
> > > >  
> > > > > > > 
> > > > > > >  3. please avoid to use global spinlock more. 
> > > > > > >     no lock is best. mutex is better, maybe.
> > > > > > > 
> > > > > > 
> > > > > > No lock to update a tree which is update concurrently?
> > > > > > 
> > > > > Using tree/sort itself is nonsense, I believe.
> > > > > 
> > > > 
> > > > I tried using prio trees in the past, but they are not easy to update
> > > > either. I won't mind asking for suggestions for a data structure that
> > > > can scaled well, allow quick insert/delete and search.
> > > > 
> > > Now, because the routine is called by kswapd() not by try_to_free.....
> > > 
> > > It's not necessary to be very very fast. That's my point.
> > >
> > 
> > OK, I get your point, but whay does that make RB-Tree data structure non-sense?
> >  
> 
>  1. Until memory-shortage, rb-tree is kept to be updated and the users(kernel)
>     has to pay its maintainace/check cost, whici is unnecessary.
>     Considering trade-off, paying cost only when memory-shortage happens tend to
>     be reasonable way.
As you've seen in the code, the cost is only at an interval HZ/2
currently. The other overhead is the calculation of excess, I can try
and see if we can get rid of it.

> 
>  2. Current "exceed" just shows "How much we got over my soft limit" but doesn't
>     tell any information per-node/zone. Considering this, this rb-tree
>     information will not be able to help kswapd (on NUMA).
>     But maintain per-node information uses too much resource.

Yes, kswapd is per-node and we try to free all pages belonging to a
zonelist as specified by pgdat->node_zonelists for the memory control
groups that are over their soft limit. Keeping this information per
node makes no sense (exceeds information).

> 
>  Considering above 2, it's not bad to find victim by proper logic
>  from balance_pgdat() by using mem_cgroup_select_victim().
>  like this:
> ==
>  struct mem_cgroup *select_vicitim_at_soft_limit_via_balance_pgdat(int nid, int zid)
>  {
>      while (?) {
>         vitcim = mem_cgroup_select_victim(init_mem_cgroup);  #need some modification.
>         if (victim is not over soft-limit)
>              continue;
>         /* Ok this is candidate */
>         usage = mem_cgroup_nid_zid_usage(mem, nid, zid); #get sum of active/inactive
>         if (usage_is_enough_big)
>               return victim;

We currently track overall usage, so we split into per nid, zid
information and use that? Is that your suggestion? The soft limit is
also an aggregate limit, how do we define usage_is_big_enough or
usage_is_enough_big? Through some heuristics?

>      }
>  }
>  balance_pgdat()
>  ...... find target zone....
>  ...
>  mem = select_victime_at_soft_limit_via_balance_pgdat(nid, zid)
>  if (mem)
>    sc->mem = mem;
>  shrink_zone();
>  if (mem) {
>    sc->mem = NULL;
>    css_put(&mem->css);
>  }
> ==
> 
>  We have to pay scan cost but it will not be too big(if there are not thousands of memcg.)
>  Under above, round-robin rotation is used rather than sort.

Yes, we sort, but not frequently at every page-fault but at a
specified interval.

>  Maybe I can show you sample.....(but I'm a bit busy.)
>

Explanation and review is good, but I don't see how not-sorting will
help? I need something that can help me point to the culprits quickly
enough during soft limit reclaim and RB-Tree works very well for me. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
