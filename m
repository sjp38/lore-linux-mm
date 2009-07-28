Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 217DE6B0055
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:38:39 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n6S0caXA001939
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 01:38:37 +0100
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz17.hot.corp.google.com with ESMTP id n6S0cLSs018120
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 17:38:34 -0700
Received: by pzk37 with SMTP id 37so2370542pzk.24
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 17:38:34 -0700 (PDT)
Date: Mon, 27 Jul 2009 17:38:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907271731040.29815@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
 <20090724160936.a3b8ad29.akpm@linux-foundation.org> <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com> <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com> <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
 <alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com> <20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com> <20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:

> Because we dont' update, task->mems_allowed need to be initilaized as
> N_POSSIBLE_NODES. At usual thinking,  it should be N_HIGH_MEMORY or
> N_ONLINE_NODES, as my patch does.
> 

On MEM_OFFLINE, cpusets calls scan_for_empty_cpusets() which will 
intersect each system cpuset's mems_allowed with N_HIGH_MEMORY.  It then 
calls update_tasks_nodemask() which will update task->mems_allowed for 
each task assigned to those cpusets.  This has a callback into the 
mempolicy code to rebind the policy with the new mems.

So there's no apparent issue with memory hotplug in dealing with cpuset 
mems, although I suggested that this be done for MEM_GOING_OFFLINE instead 
of waiting until the mem is actually offline.

The problem originally reported here doesn't appear to have anything to do 
with hotplug, it looks like it is the result of Lee's observation that 
ia64 defaults top_cpuset's mems to N_POSSIBLE, which _should_ have been 
updated by cpuset_init_smp().  So it makes me believe that N_HIGH_MEMORY 
isn't actually ready by the time do_basic_setup() is called to be useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
