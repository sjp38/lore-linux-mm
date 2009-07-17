Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BA7086B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 05:09:40 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n6H99ZdX008407
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 10:09:35 +0100
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by zps37.corp.google.com with ESMTP id n6H99Wue007069
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 02:09:33 -0700
Received: by pxi1 with SMTP id 1so266218pxi.24
        for <linux-mm@kvack.org>; Fri, 17 Jul 2009 02:09:32 -0700 (PDT)
Date: Fri, 17 Jul 2009 02:09:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907170203330.13151@chino.kir.corp.google.com>
References: <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <20090717090003.A903.A69D9226@jp.fujitsu.com> <20090717095745.1d3039b1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009, KAMEZAWA Hiroyuki wrote:

> IMHO, the application itseld should be notifed to change its mempolicy by
> hot-plug script on the host. While an application uses interleave, a new node
> hot-added is just a noise. I think "How pages are interleaved" should not be
> changed implicitly. Then, checking at set_mempolicy() seems sane. If notified,
> application can do page migration and rebuild his mapping in ideal way.
> 

Agreed, it doesn't seem helpful to add a node to MPOL_INTERLEAVE for 
memory hotplug; the same is probably true of MPOL_BIND as well since the 
application will never want to unknowingly expand its set of allowed 
nodes.  There's no case where MPOL_PREFERRED would want to implicitly 
switch to the added node.

I'm not convinced that we have to support hot-add in existing mempolicies 
at all.

> BUT I don't linke init->mem_allowed contains N_POSSIBLE...it should be initialized
> to N_HIGH_MEMORY, IMHO.
> 

It doesn't matter for the page allocator since zonelists will never 
include zones from nodes that aren't online, so the underlying bug here 
does seem to be the behavior of ->mems_allowed and we're probably only 
triggering it by mempolicies.  cpuset_track_online_nodes() should be 
keeping top_cpuset's mems_allowed consistent with N_HIGH_MEMORY and all 
descendents must have a subset of top_cpuset's nodes, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
