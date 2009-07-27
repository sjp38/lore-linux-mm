Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1EF366B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:00:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S00A3Y006552
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 09:00:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4BBC45DE58
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF83945DE62
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:00:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8530D1DB8044
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:00:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD9F61DB8047
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:00:08 +0900 (JST)
Date: Tue, 28 Jul 2009 08:58:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<1247679064.4089.26.camel@useless.americas.hpqcorp.net>
	<alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
	<alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
	<20090724160936.a3b8ad29.akpm@linux-foundation.org>
	<337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
	<5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
	<9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
	<alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 2009 10:55:47 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Sat, 25 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > _Direct_ use of task->mems_allowed is only in cpuset and mempolicy.
> > If no policy is used, it's not checked.
> > (See alloc_pages_current())
> > 
> > memory hotplug's notifier just updates top_cpuset's mems_allowed.
> > But it doesn't update each task's ones.
> 
> That's not true, cpuset_track_online_nodes() will call 
> scan_for_empty_cpusets() on top_cpuset, which works from the root to 
> leaves updating each cpuset's mems_allowed by intersecting it with 
> node_states[N_HIGH_MEMORY].  This is done as part of the MEM_OFFLINE 
> callback in the cpuset code, so N_HIGH_MEMORY represents the nodes still 
> online.
> 
yes.

> The nodemask for each task is updated to reflect the removal of a node and 
> it calls mpol_rebind_mm() with the new nodemask.
> 
yes, but _not_ updated at online.

> This is admittedly pretty late to be removing mems from cpusets (and 
> mempolicies) when the unplug has already happened.  We should look at 
> doing the rebind for MEM_GOING_OFFLINE.
> 
Hm.

What I felt at reading cpuset/mempolicy again is that it's too complex ;)
The 1st question is why mems_allowed which can be 1024bytes when max_node=4096
is copied per tasks....
And mempolicy code uses too much nodemask_t on stack.

I'll try some, today, including this bug-fix.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
