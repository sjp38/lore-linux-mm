Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0EE356B009C
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 03:37:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S7bIJh031900
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 16:37:18 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 10CF145DE79
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 16:37:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7A5C45DE70
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 16:37:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD6261DB803A
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 16:37:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 675511DB8037
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 16:37:14 +0900 (JST)
Date: Fri, 28 Aug 2009 16:35:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-Id: <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090828072007.GH4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
	<20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090828072007.GH4889@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Aug 2009 12:50:08 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:23:21]:
> 
> > This patch tries to modify softlimit handling in memcg/res_counter.
> > There are 2 reasons in general.
> > 
> >  1. soft_limit can use only against sub-hierarchy root.
> >     Because softlimit tree is sorted by usage, putting prural groups
> >     under hierarchy (which shares usage) will just adds noise and unnecessary
> >     mess. This patch limits softlimit feature only to hierarchy root.
> >     This will make softlimit-tree maintainance better. 
> > 
> >  2. In these days, it's reported that res_counter can be bottleneck in
> >     massively parallel enviroment. We need to reduce jobs under spinlock.
> >     The reason we check softlimit at res_counter_charge() is that any member
> >     in hierarchy can have softlimit.
> >     But by chages in "1", only hierarchy root has soft_limit. We can omit
> >     hierarchical check in res_counter.
> > 
> > After this patch, soft limit is avaliable only for root of sub-hierarchy.
> > (Anyway, softlimit for hierarchy children just makes users confused, hard-to-use)
> >
> 
> 
> I need some time to digest this change, if the root is a hiearchy root
> then only root can support soft limits? I think the change makes it
> harder to use soft limits. Please help me understand better. 
> 
I poitned out this issue many many times while you wrote patch.

memcg has "sub tree". hierarchy here means "sub tree" with use_hierarchy =1.

Assume


	/cgroup/Users/use_hierarchy=0
		  Gold/ use_hierarchy=1 
		     Bob
		     Mike
		  Silver/use_hierarchy=1
		     
		/System/use_hierarchy=1
	
In flat, there are 3 sub trees.
	/cgroup/Users/Gold   (Gold has /cgroup/Users/Gold/Bog, /cgroup/Users/Gold/Mike)
	/cgroup/Users/Silver .....
	/cgroup/System	     .....

Then, subtrees means a group which inherits charges by use_hierarchy=1

In current implementation, softlimit can be set to arbitrary cgroup. 
Then, following ops are allowed.
==
	/cgroup/Users/Gold softlimit= 1G
	/cgroup/Users/Gold/Bob  softlimit=800M
	/cgroup/Users/Gold/Mike softlimit=800M
==

Then, how your RB-tree for softlimit management works ?

When softlimit finds /cgroup/Users/Gold/, it will reclaim memory from
all 3 groups by hierarchical_reclaim. If softlimit finds
/cgroup/Users/Gold/Bob, reclaim from Bob means recalaim from Gold.

Then, to keep the RB-tree neat, you have to extract all related cgroups and
re-insert them all, every time.
(But current code doesn't do that. It's broken.)

Current soft-limit RB-tree will be easily broken i.e. not-sorted correctly
if used under use_hierarchy=1.

My patch disallows set softlimit to Bob and Mike, just allows against Gold
because there can be considered as the same class, hierarchy.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
