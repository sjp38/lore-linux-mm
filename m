Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7946B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 13:55:53 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6RHttda022599
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 10:55:58 -0700
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by spaceape11.eur.corp.google.com with ESMTP id n6RHtXB6005577
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 10:55:53 -0700
Received: by pzk31 with SMTP id 31so3148415pzk.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 10:55:51 -0700 (PDT)
Date: Mon, 27 Jul 2009 10:55:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
 <20090724160936.a3b8ad29.akpm@linux-foundation.org> <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com> <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
 <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Jul 2009, KAMEZAWA Hiroyuki wrote:

> _Direct_ use of task->mems_allowed is only in cpuset and mempolicy.
> If no policy is used, it's not checked.
> (See alloc_pages_current())
> 
> memory hotplug's notifier just updates top_cpuset's mems_allowed.
> But it doesn't update each task's ones.

That's not true, cpuset_track_online_nodes() will call 
scan_for_empty_cpusets() on top_cpuset, which works from the root to 
leaves updating each cpuset's mems_allowed by intersecting it with 
node_states[N_HIGH_MEMORY].  This is done as part of the MEM_OFFLINE 
callback in the cpuset code, so N_HIGH_MEMORY represents the nodes still 
online.

The nodemask for each task is updated to reflect the removal of a node and 
it calls mpol_rebind_mm() with the new nodemask.

This is admittedly pretty late to be removing mems from cpusets (and 
mempolicies) when the unplug has already happened.  We should look at 
doing the rebind for MEM_GOING_OFFLINE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
