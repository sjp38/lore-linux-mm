Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 27AE06B01AF
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:56 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjrlX024568
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A9DCD45DE52
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 79A2D45DE4E
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FE241DB8017
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0876CE08003
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <alpine.DEB.2.00.1006162212490.19549@chino.kir.corp.google.com>
References: <20100608194533.7657.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162212490.19549@chino.kir.corp.google.com>
Message-Id: <20100621203838.B542.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Sorry I can't ack this. again and again, I try to explain why this is wrong
> > (hopefully last)
> > 
> > 1) incompatibility
> >    oom_score is one of ABI. then, we can't change this. from enduser view,
> >    this change is no merit. In general, an incompatibility is allowed on very
> >    limited situation such as that an end-user get much benefit than compatibility.
> >    In other word, old style ABI doesn't works fine from end user view.
> >    But, in this case, it isn't.
> > 
> 
> There is no incompatibility here, /proc/pid/oom_score has no meaningful 
> units because of the old heuristic.  The _only_ thing it represents is a 
> score in comparison with other eligible tasks to decide which task to 
> kill.  Thus, oom_score by itself means nothing if not compared to other 
> eligible tasks.
> 
> Although deprecated, /proc/pid/oom_adj still changes 
> /proc/pid/oom_score_adj with a different scale (-17 maps to -1000 and +15 
> maps to +1000), so there is absolutely no userspace imcompatibility with 
> this change.

I sympathize your burden. Yes, oom_adj is suck.

but it is still an abi. we (kernel developers) can't define it as no 
meaningful. that's defined by userland folks.

If you want to change the world, you need to discuss userland folks.

> 
> > 2) technically incorrect
> >    this math is not correct math. this is not represented "allowed memory".
> >    example, 1) this is not accumulated mlocked memory, but it can be freed
> >    task kill 2) SHM_LOCKED memory freeablility depend on IPC_RMID did or not.
> >    if not, task killing doesn't free SYSV IPC memory.
> 
> Ah, very good point.  We should be using totalram_pages + total_swap_pages 
> here to represent global normalization, memcg limit for CONSTRAINT_MEMCG, 
> and a total of node_spanned_pages for mempolicy nodes or cpuset mems for 
> CONSTAINT_MEMORY_POLICY and CONSTRAINT_CPUSET, respectively.  I'll make 
> that switch in the next revision, thanks!

I can't understand. What problem do this solve?

> 
> >    In additon, 3) This normalization doesn't works on asymmetric numa. 
> >    total pages and oom are not related almostly.
> 
> What this does is represents the heuristic baseline, rss and swap, as a 
> proportion depending on the type of oom constraint.  This works when 
> comparing eligible tasks amongst each other because the the task with the 
> highest rss and swap is the one we (normally) want to kill, minus the 3% 
> privilege given to root and outside influence of /proc/pid/oom_score_adj.
> 
> We want to represent this as a proportion and not as a shear value simply 
> because the task may be attached to a cpuset, a memcg, or bound to a 
> mempolicy out from under the task's knowledge.  That is, we compare tasks 
> sharing the same constraint for oom kill and normalize the heuristic based 
> on that.  We don't want to expose a userspace interface that takes memory 
> quantities directly since the task may be bound to a mempolicy, for 
> instance, later and the oom_score_adj is then rendered obsolete.

Can't understand. Do you mean you suggest to ignore this issue?
I feel you talked unrelated thing.

Plus the fact is, If you think "We don't want to expose a userspace 
interface that takes memory quantities directly", it already did 5 years ago.
your proposal was too late 5 years. (look at andrea)


> > 4) scalability. if the 
> >    system 10TB memory, 1 point oom score mean 10GB memory consumption.
> 
> Well, sure, a 10TB system would have a large granularity such as that :)  
> But in such cases we don't necessarily care if one task is using 5GB more 
> than another task using 1TB, for example.

Probably not.

When we are thinking common DB server workload, DB process consume
almost memory, but it's OOM_DISABLEed. OOM victims are typically selected from
some assistant JVM process.


So, I don't think this is good idea. Instead, To enhance memcg oom notification
looks promising. 

And other piece of this patch looks promising rather than this. please
resend them. (of cource, test result too)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
