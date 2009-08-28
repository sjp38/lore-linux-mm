Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33DBA6B00B8
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:26:50 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7SDQl1d015886
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 18:56:47 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SDQl2A2461712
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 18:56:47 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7SDQk4X029388
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 18:56:46 +0530
Date: Fri, 28 Aug 2009 18:56:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-ID: <20090828132643.GM4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com> <20090828072007.GH4889@balbir.in.ibm.com> <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 16:35:23]:

> On Fri, 28 Aug 2009 12:50:08 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:23:21]:
> > 
> > > This patch tries to modify softlimit handling in memcg/res_counter.
> > > There are 2 reasons in general.
> > > 
> > >  1. soft_limit can use only against sub-hierarchy root.
> > >     Because softlimit tree is sorted by usage, putting prural groups
> > >     under hierarchy (which shares usage) will just adds noise and unnecessary
> > >     mess. This patch limits softlimit feature only to hierarchy root.
> > >     This will make softlimit-tree maintainance better. 
> > > 
> > >  2. In these days, it's reported that res_counter can be bottleneck in
> > >     massively parallel enviroment. We need to reduce jobs under spinlock.
> > >     The reason we check softlimit at res_counter_charge() is that any member
> > >     in hierarchy can have softlimit.
> > >     But by chages in "1", only hierarchy root has soft_limit. We can omit
> > >     hierarchical check in res_counter.
> > > 
> > > After this patch, soft limit is avaliable only for root of sub-hierarchy.
> > > (Anyway, softlimit for hierarchy children just makes users confused, hard-to-use)
> > >
> > 
> > 
> > I need some time to digest this change, if the root is a hiearchy root
> > then only root can support soft limits? I think the change makes it
> > harder to use soft limits. Please help me understand better. 
> > 
> I poitned out this issue many many times while you wrote patch.
> 
> memcg has "sub tree". hierarchy here means "sub tree" with use_hierarchy =1.
> 
> Assume
> 
> 
> 	/cgroup/Users/use_hierarchy=0
> 		  Gold/ use_hierarchy=1 
> 		     Bob
> 		     Mike
> 		  Silver/use_hierarchy=1
> 		     
> 		/System/use_hierarchy=1
> 	
> In flat, there are 3 sub trees.
> 	/cgroup/Users/Gold   (Gold has /cgroup/Users/Gold/Bog, /cgroup/Users/Gold/Mike)
> 	/cgroup/Users/Silver .....
> 	/cgroup/System	     .....
> 
> Then, subtrees means a group which inherits charges by use_hierarchy=1
> 
> In current implementation, softlimit can be set to arbitrary cgroup. 
> Then, following ops are allowed.
> ==
> 	/cgroup/Users/Gold softlimit= 1G
> 	/cgroup/Users/Gold/Bob  softlimit=800M
> 	/cgroup/Users/Gold/Mike softlimit=800M
> ==
> 
> Then, how your RB-tree for softlimit management works ?
> 
> When softlimit finds /cgroup/Users/Gold/, it will reclaim memory from
> all 3 groups by hierarchical_reclaim. If softlimit finds
> /cgroup/Users/Gold/Bob, reclaim from Bob means recalaim from Gold.

By reclaim from Bob means reclaim from Gold, are you referring to the
uncharging part, if so yes. But if you look at the tasks part, we
don't reclaim anything from the tasks in Gold.

> 
> Then, to keep the RB-tree neat, you have to extract all related cgroups and
> re-insert them all, every time.
> (But current code doesn't do that. It's broken.)

The earlier time dependent code used to catch that, since it was time
based. Now that it is based on activity, it will take a while before
the group is updated. I don't think it is broken, but updates can take
a lag before showing up.

> 
> Current soft-limit RB-tree will be easily broken i.e. not-sorted correctly
> if used under use_hierarchy=1.
> 

Not true, I think the sorted-ness is delayed and is seen when we pick
a tree for reclaim. Think of it as being lazy :)

> My patch disallows set softlimit to Bob and Mike, just allows against Gold
> because there can be considered as the same class, hierarchy.
>

But Bob and Mike might need to set soft limits between themselves. if
soft limit of gold is 1G and bob needs to be close to 750M and mike
250M, how do we do it without supporting what we have today?
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
