Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 84A936B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:14:39 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n6S0EbAf017213
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 01:14:39 +0100
Received: from pxi27 (pxi27.prod.google.com [10.243.27.27])
	by wpaz1.hot.corp.google.com with ESMTP id n6S0EYlm010950
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 17:14:35 -0700
Received: by pxi27 with SMTP id 27so2345033pxi.20
        for <linux-mm@kvack.org>; Mon, 27 Jul 2009 17:14:34 -0700 (PDT)
Date: Mon, 27 Jul 2009 17:14:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
In-Reply-To: <20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com> <1247679064.4089.26.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com> <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
 <20090724160936.a3b8ad29.akpm@linux-foundation.org> <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com> <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com> <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
 <alpine.DEB.2.00.0907271047590.8408@chino.kir.corp.google.com> <20090728085810.f7ae678a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:

> > The nodemask for each task is updated to reflect the removal of a node and 
> > it calls mpol_rebind_mm() with the new nodemask.
> > 
> yes, but _not_ updated at online.
> 

Well, I disagreed that we needed to alter any pre-existing mempolicies for 
MEM_GOING_ONLINE or MEM_ONLINE since it may diverge from the original 
intent of the policy.  MPOL_PREFERRED certain shouldn't change, 
MPOL_INTERLEAVE would be unbalanced, and MPOL_BIND could diverge from 
memory isolation or affinity requirements.

I'd be interested to hear any real world use cases for MEM_ONLINE updating 
of mempolicies.

> What I felt at reading cpuset/mempolicy again is that it's too complex ;)
> The 1st question is why mems_allowed which can be 1024bytes when max_node=4096
> is copied per tasks....

The page allocator needs lockless access to mems_allowed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
