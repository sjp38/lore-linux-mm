Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BF1AC6B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:56:47 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S0uq4u010667
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 09:56:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6F02AEA81
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:56:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F7D21EF082
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:56:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD3F61DB805A
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:56:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1547E1DB8040
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:56:49 +0900 (JST)
Date: Tue, 28 Jul 2009 09:54:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090728095453.1fe79de1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907271731040.29815@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<1247679064.4089.26.camel@useless.americas.hpqcorp.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 2009 17:38:30 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > Because we dont' update, task->mems_allowed need to be initilaized as
> > N_POSSIBLE_NODES. At usual thinking,  it should be N_HIGH_MEMORY or
> > N_ONLINE_NODES, as my patch does.
> > 
> 

> On MEM_OFFLINE, cpusets calls scan_for_empty_cpusets() which will 
> intersect each system cpuset's mems_allowed with N_HIGH_MEMORY.  It then 
> calls update_tasks_nodemask() which will update task->mems_allowed for 
> each task assigned to those cpusets.  This has a callback into the 
> mempolicy code to rebind the policy with the new mems.
> 
> So there's no apparent issue with memory hotplug in dealing with cpuset 
> mems, although I suggested that this be done for MEM_GOING_OFFLINE instead 
> of waiting until the mem is actually offline.
>
I _wrote_ this is just a side story to bug.
online/offline isn't related to this bug.

> The problem originally reported here doesn't appear to have anything to do 
> with hotplug, it looks like it is the result of Lee's observation that 
> ia64 defaults top_cpuset's mems to N_POSSIBLE, which _should_ have been 
> updated by cpuset_init_smp(). 
cpuset_init_smp() just updates cpuset's mask.
init's task->mems_allowed is intizialized independently from cpuset's mask.

Could you teach me a pointer for Lee's observation ?

> So it makes me believe that N_HIGH_MEMORY 
> isn't actually ready by the time do_basic_setup() is called to be useful.
> 
N_HIGH_MEMORY should be ready when zonelist is built. If not, it's bug.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
