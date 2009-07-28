Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D1E7A6B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 21:25:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S1Q5lD024135
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 10:26:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF46145DE63
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:26:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DE5C45DE57
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:26:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8505C1DB8047
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:26:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 261F71DB803A
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 10:26:04 +0900 (JST)
Date: Tue, 28 Jul 2009 10:24:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090728102411.2a18c2e3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090728101157.9465b2e5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
	<alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
	<20090724160936.a3b8ad29.akpm@linux-foundation.org>
	<337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
	<5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
	<9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com>
	<20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com>
	<20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271731040.29815@chino.kir.corp.google.com>
	<20090728095453.1fe79de1.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0907271758170.29815@chino.kir.corp.google.com>
	<20090728101157.9465b2e5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009 10:11:57 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 27 Jul 2009 18:02:50 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > > > The problem originally reported here doesn't appear to have anything to do 
> > > > with hotplug, it looks like it is the result of Lee's observation that 
> > > > ia64 defaults top_cpuset's mems to N_POSSIBLE, which _should_ have been 
> > > > updated by cpuset_init_smp(). 
> > > cpuset_init_smp() just updates cpuset's mask.
> > > init's task->mems_allowed is intizialized independently from cpuset's mask.
> > > 
> > 
> > Presumably the bug is that N_HIGH_MEMORY is not a subset of N_ONLINE at 
> > this point on ia64.
> > 
> N_HIGH_MEMORY is must be subset of N_ONLINE, at the any moment. Hmm,
> I'll look into what happens in ia64 world.
> 

At quick look, N_HIGH_MEMORY is set here while init. (I ignore hoplug now.)

== before init==
  60 #ifndef CONFIG_NUMA
  61         [N_NORMAL_MEMORY] = { { [0] = 1UL } },
  62 #ifdef CONFIG_HIGHMEM
  63         [N_HIGH_MEMORY] = { { [0] = 1UL } },
  64 #endif
== 
3860 static unsigned long __init early_calculate_totalpages(void)
3861 {
  ....
3869                 if (pages)
3870                         node_set_state(early_node_map[i].nid, N_HIGH_MEMORY);
3871         }
==
4041 void __init free_area_init_nodes(unsigned long *max_zone_pfn)
4042 {
4105                 if (pgdat->node_present_pages)
4106                         node_set_state(nid, N_HIGH_MEMORY);
==


All of them are done while mem_init(). Then if N_HIGH_MEMORY is not correct at
kernel_init(). It's bug.

I think what Lee and Miao pointed out is just a hotplug problem.
Ok, I'll try some patch but it'll take some hours.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
