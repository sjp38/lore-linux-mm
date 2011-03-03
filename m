Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 135ED8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 14:54:20 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p23Js1p7016168
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 11:54:01 -0800
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by hpaq11.eem.corp.google.com with ESMTP id p23JrPPG012244
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 11:54:00 -0800
Received: by pxi15 with SMTP id 15so218960pxi.19
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 11:53:59 -0800 (PST)
Date: Thu, 3 Mar 2011 11:53:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110303100030.B936.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103031147560.9993@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Thu, 3 Mar 2011, KOSAKI Motohiro wrote:

> > This patch revents unnecessary oom kills or kernel panics by reverting
> > two commits:
> > 
> > 	495789a5 (oom: make oom_score to per-process value)
> > 	cef1d352 (oom: multi threaded process coredump don't make deadlock)
> > 
> > First, 495789a5 (oom: make oom_score to per-process value) ignores the
> > fact that all threads in a thread group do not necessarily exit at the
> > same time.
> > 
> > It is imperative that select_bad_process() detect threads that are in the
> > exit path, specifically those with PF_EXITING set, to prevent needlessly
> > killing additional tasks.  
> 
> to prevent? No, it is not a reason of PF_EXITING exist.
> 

It is not the sole reason PF_EXITING exists in the kernel, no.  It was 
used in select_bad_process() to ensure we don't needlessly kill another 
task if an eligible one is already in the exit path.  We want to ensure 
that the oom killer only kills a process getting work done when nothing 
has the potential to free memory in the short term.  It's not a guarantee 
that the PF_EXITING task will free memory, but it has the potential to be 
the last thread pinning the ->mm.

> > By iterating over threads instead, it is possible to detect threads that
> > are exiting and nominate them for oom kill so they get access to memory
> > reserves.
> 
> In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
> PF_EXITING is not a sign of memory freeing in nearly future. If other
> CPUs don't try to free memory, prevent oom and waiting makes deadlock.
> 

It's not a deadlock if a thread is PF_EXITING and isn't stalled by, for 
instance, failed memory allocations.  That's why this patch restores the 
behavior back to what it was previous to cef1d352: if an eligible thread 
is PF_EXITING and is not current, then wait for it; otherwise, if it is 
current, give it access to memory reserves so it can allow the allocation 
to succeed.

> > Second, cef1d352 (oom: multi threaded process coredump don't make
> > deadlock) erroneously avoids making the oom killer a no-op when an
> > eligible thread other than current isfound to be exiting.  We want to
> > detect this situation so that we may allow that exiting thread time to
> > exit and free its memory; if it is able to exit on its own, that should
> > free memory so current is no loner oom.  If it is not able to exit on its
> > own, the oom killer will nominate it for oom kill which, in this case,
> > only means it will get access to memory reserves.
> > 
> > Without this change, it is easy for the oom killer to unnecessarily
> > target tasks when all threads of a victim don't exit before the thread
> > group leader or, in the worst case, panic the machine.
> > 
> 
> You missed deadlock is more worse than panic. And again, task overkill
> is a part of OOM killer design. it is necessary to avoid deadlock. If
> you want to change this spec, you need to remove deadlock change at first.
> 

There is no deadlock being introduced by this patch; if you have an 
example of one, then please show it.  The problem is not just overkill but 
rather panicking the machine when no other eligible processes exist.  We 
have seen this in production quite a few times and we'd like to see this 
patch merged to avoid our machines panicking because the oom killer, by 
your patch, isn't considering threads that are eligible in the exit path 
once their parent has been killed and has exited itself yet memory freeing 
isn't possible yet because the threads still pin the ->mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
