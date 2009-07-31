Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8270D6B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 05:31:34 -0400 (EDT)
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id n6V9VSMt024052
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 10:31:29 +0100
Received: from pxi42 (pxi42.prod.google.com [10.243.27.42])
	by zps77.corp.google.com with ESMTP id n6V9VP52008509
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:31:26 -0700
Received: by pxi42 with SMTP id 42so577419pxi.29
        for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:31:25 -0700 (PDT)
Date: Fri, 31 Jul 2009 02:31:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090731091744.B6DE.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907310210460.25447@chino.kir.corp.google.com>
References: <20090730090855.E415.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0907292356410.5581@chino.kir.corp.google.com> <20090731091744.B6DE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Jul 2009, KOSAKI Motohiro wrote:

> > That's because the oom killer only really considers the highest oom_adj 
> > value amongst all threads that share the same mm.  Allowing those threads 
> > to each have different oom_adj values leads (i) to an inconsistency in 
> > reporting /proc/pid/oom_score for how the oom killer selects a task to 
> > kill and (ii) the oom killer livelock that it fixes when one thread 
> > happens to be OOM_DISABLE.
> 
> I agree both. again I only disagree ABI breakage regression and
> stupid new /proc interface.

Let's state the difference in behavior as of 2.6.31-rc1: applications can 
no longer change the oom_adj value of a vfork() child prior to exec() 
without it also affecting the parent.  I agree that was previously 
allowed.  And it was that very allowance that LEADS TO THE LIVELOCK 
because they both share a VM and it was possible for the oom killer to 
select the one of the threads while the other was OOM_DISABLE.

This is an extremely simple livelock to trigger, AND YOU DON'T EVEN NEED 
CAP_SYS_RESOURCE TO DO IT.  Consider a job scheduler that superuser has 
set to OOM_DISABLE because of its necessity to the system.  Imagine if 
that job scheduler vfork's a child and sets its inherited oom_adj value of 
OOM_DISABLE to something higher so that the machine doesn't panic on 
exec() when the child spikes in memory usage when the application first 
starts.

Now imagine that either there are no other user threads or the job 
scheduler itself has allocated more pages than any other thread.  Or, more 
simply, imagine that it sets the child's oom_adj value to a higher 
priority than other threads based on some heuristic.  Regardless, if the 
system becomes oom before the exec() can happen and before the new VM is 
attached to the child, the machine livelocks.

That happens because of two things:

 - the oom killer uses the oom_adj value to adjust the oom_score for a
   task, and that score is mainly based on the size of each thread's VM,
   and

 - the oom killer cannot kill a thread that shares a VM with an
   OOM_DISABLE thread because it will not lead to future memory freeing.

So the preferred solution for complete consistency and to fix the livelock 
is to make the oom_adj value a characteristic of the VM, because THAT'S 
WHAT IT ACTS ON.  The effective oom_adj value for a thread is always equal 
to the highest oom_adj value of any thread sharing its VM.

Do we really want to keep this inconsistency around forever in the kernel 
so that /proc/pid/oom_score actually means NOTHING because another thread 
sharing the memory has a different oom_adj?  Or do we want to take the 
opportunity to fix a broken userspace model that leads to a livelock to 
fix it and move on with a consistent interface and, with oom_adj_child, 
all the functionality you had before.

And you and KAMEZAWA-san can continue to call my patches stupid, but 
that's not adding anything to your argument.

> Paul already pointed out this issue can be fixed without ABI change.
> 

I'm unaware of any viable solution that has been proposed, sorry.

> if you feel my stand point is double standard, I need explain me more.
> So, I don't think per-process oom_adj makes any regression on _real_ world.

Wrong, our machines have livelocked because of the exact scenario I 
described above.

> but vfork()'s one is real world issue.
> 

And it's based on a broken assumption that oom_adj values actually mean 
anything independent of other threads sharing the same memory.  That's a 
completely false assumption.  Applications that are tuning oom_adj value 
will rely on oom_scores, which are currently false if oom_adj differs 
amongst those threads, and should be written to how the oom killer uses 
the value.

> And, May I explay why I think your oom_adj_child is wrong idea?
> The fact is: new feature introducing never fix regression. yes, some
> application use new interface and disappear the problem. but other
> application still hit the problem. that's not correct development style
> in kernel.
> 

So you're proposing that we forever allow /proc/pid/oom_score to be 
completely wrong for pid without any knowledge to userspace?  That we 
falsely advertise what it represents and allow userspace to believe that 
changing oom_adj for a thread sharing memory with other threads actually 
changes how the oom killer selects tasks?

Please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
