Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E00636B0055
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 20:27:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S0RUgo018187
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 09:27:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D7745DE4F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:27:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C47A545DE4E
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:27:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 77CE11DB8038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:27:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2BB31DB803E
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 09:27:28 +0900 (JST)
Date: Tue, 28 Jul 2009 09:25:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
Message-Id: <20090728092529.bb0d7e9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0907271710590.27881@chino.kir.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, miaox@cn.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, y-goto@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jul 2009 17:14:32 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 28 Jul 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > The nodemask for each task is updated to reflect the removal of a node and 
> > > it calls mpol_rebind_mm() with the new nodemask.
> > > 
> > yes, but _not_ updated at online.
> > 
> 
> Well, I disagreed that we needed to alter any pre-existing mempolicies for 
> MEM_GOING_ONLINE or MEM_ONLINE since it may diverge from the original 
> intent of the policy.  MPOL_PREFERRED certain shouldn't change, 
> MPOL_INTERLEAVE would be unbalanced, and MPOL_BIND could diverge from 
> memory isolation or affinity requirements.
> 
> I'd be interested to hear any real world use cases for MEM_ONLINE updating 
> of mempolicies.
> 
Sorry, I was a bit condused. I thought I said about task->mems_allowed.
Not each policy.

Because we dont' update, task->mems_allowed need to be initilaized as
N_POSSIBLE_NODES. At usual thinking,  it should be N_HIGH_MEMORY or
N_ONLINE_NODES, as my patch does.

> > What I felt at reading cpuset/mempolicy again is that it's too complex ;)
> > The 1st question is why mems_allowed which can be 1024bytes when max_node=4096
> > is copied per tasks....
> 
> The page allocator needs lockless access to mems_allowed.
> 
Hmm, ok, I'll take care of that. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
