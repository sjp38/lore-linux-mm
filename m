Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D23A36B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 21:38:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1H2c19E029185
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Feb 2010 11:38:01 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C172145DE6E
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:38:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 985B245DE4D
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:38:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8050E1DB803A
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:38:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 21C321DB8043
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 11:37:57 +0900 (JST)
Date: Wed, 17 Feb 2010 11:34:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
	<20100216090005.f362f869.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
	<20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
	<20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
	<20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
	<20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
	<20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010 18:28:05 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > What do you think about making pagefaults use out_of_memory() directly and 
> > > respecting the sysctl_panic_on_oom settings?
> > > 
> > 
> > I don't think this patch is good. Because several memcg can
> > cause oom at the same time independently, system-wide oom locking is
> > unsuitable. BTW, what I doubt is much more fundamental thing.
> > 
> 
> We want to lock all populated zones with ZONE_OOM_LOCKED to avoid 
> needlessly killing more than one task regardless of how many memcgs are 
> oom.
> 
Current implentation archive what memcg want. Why remove and destroy memcg ?


> > What I doubt at most is "why VM_FAULT_OOM is necessary ? or why we have
> > to call oom_killer when page fault returns it".
> > Is there someone who returns VM_FAULT_OOM without calling page allocator
> > and oom-killer helps something in such situation ?
> > 
> 
> Before we invoked the oom killer for VM_FAULT_OOM, we simply sent a 
> SIGKILL to current because we simply don't have memory to fault the page 
> in, it's better to select a memory-hogging task to kill based on badness() 
> than to constantly kill current which may not help in the long term.
> 
What I mean is
 - What VM_FAULT_OOM means is not "memory is exhausted" but "something is exhausted".

For example, when hugepages are all used, it may return VM_FAULT_OOM.
Especially when nr_overcommit_hugepage == usage_of_hugepage, it returns VM_FAULT_OOM.

Then, what oom-killer can help it ? I think never and the requester should die.

Before modifying current code, I think we have to check all VM_FAULT_OOM and distinguish
 - memory is exhausted (and page allocater wasn't called.)
 - something other than memory is exhausted.

And, in hugepage case, even order > PAGE_ALLOC_COSTLY_ORDER, oom-killer is
called and pagegault_oom_kill kills tasks randomly.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
