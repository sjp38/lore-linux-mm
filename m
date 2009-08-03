Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 262306B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:39:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n73BwHw6012424
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 3 Aug 2009 20:58:18 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADAE845DE61
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 20:58:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8159945DE57
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 20:58:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E4C31DB803F
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 20:58:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAA651DB804B
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 20:58:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <alpine.DEB.2.00.0907310210460.25447@chino.kir.corp.google.com>
References: <20090731091744.B6DE.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0907310210460.25447@chino.kir.corp.google.com>
Message-Id: <20090803200639.CC1D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  3 Aug 2009 20:58:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 31 Jul 2009, KOSAKI Motohiro wrote:
> 
> > > That's because the oom killer only really considers the highest oom_adj 
> > > value amongst all threads that share the same mm.  Allowing those threads 
> > > to each have different oom_adj values leads (i) to an inconsistency in 
> > > reporting /proc/pid/oom_score for how the oom killer selects a task to 
> > > kill and (ii) the oom killer livelock that it fixes when one thread 
> > > happens to be OOM_DISABLE.
> > 
> > I agree both. again I only disagree ABI breakage regression and
> > stupid new /proc interface.
> 
> Let's state the difference in behavior as of 2.6.31-rc1: applications can 
> no longer change the oom_adj value of a vfork() child prior to exec() 
> without it also affecting the parent.  I agree that was previously 
> allowed.  And it was that very allowance that LEADS TO THE LIVELOCK 
> because they both share a VM and it was possible for the oom killer to 
> select the one of the threads while the other was OOM_DISABLE.
> 
> This is an extremely simple livelock to trigger, AND YOU DON'T EVEN NEED 
> CAP_SYS_RESOURCE TO DO IT.  Consider a job scheduler that superuser has 
> set to OOM_DISABLE because of its necessity to the system.  Imagine if 
> that job scheduler vfork's a child and sets its inherited oom_adj value of 
> OOM_DISABLE to something higher so that the machine doesn't panic on 
> exec() when the child spikes in memory usage when the application first 
> starts.
> 
> Now imagine that either there are no other user threads or the job 
> scheduler itself has allocated more pages than any other thread.  Or, more 
> simply, imagine that it sets the child's oom_adj value to a higher 
> priority than other threads based on some heuristic.  Regardless, if the 
> system becomes oom before the exec() can happen and before the new VM is 
> attached to the child, the machine livelocks.
> 
> That happens because of two things:
> 
>  - the oom killer uses the oom_adj value to adjust the oom_score for a
>    task, and that score is mainly based on the size of each thread's VM,
>    and
> 
>  - the oom killer cannot kill a thread that shares a VM with an
>    OOM_DISABLE thread because it will not lead to future memory freeing.
> 
> So the preferred solution for complete consistency and to fix the livelock 
> is to make the oom_adj value a characteristic of the VM, because THAT'S 
> WHAT IT ACTS ON.  The effective oom_adj value for a thread is always equal 
> to the highest oom_adj value of any thread sharing its VM.
> 
> Do we really want to keep this inconsistency around forever in the kernel 
> so that /proc/pid/oom_score actually means NOTHING because another thread 
> sharing the memory has a different oom_adj?  Or do we want to take the 
> opportunity to fix a broken userspace model that leads to a livelock to 
> fix it and move on with a consistent interface and, with oom_adj_child, 
> all the functionality you had before.
> 
> And you and KAMEZAWA-san can continue to call my patches stupid, but 
> that's not adding anything to your argument.

Then, your patch will got full reverting ;)
I wouldn't hope this... please.


> 
> > Paul already pointed out this issue can be fixed without ABI change.
> > 
> 
> I'm unaware of any viable solution that has been proposed, sorry.

Please see my another mail. it's contain the patch.


> > if you feel my stand point is double standard, I need explain me more.
> > So, I don't think per-process oom_adj makes any regression on _real_ world.
> 
> Wrong, our machines have livelocked because of the exact scenario I 
> described above.

Hua?
David, per-process oom_adj was made _your_ patch. Do you propose
NAK yourself patch?

maybe, We made any miscommunication?

> > but vfork()'s one is real world issue.
> > 
> 
> And it's based on a broken assumption that oom_adj values actually mean 
> anything independent of other threads sharing the same memory.  That's a 
> completely false assumption.  Applications that are tuning oom_adj value 
> will rely on oom_scores, which are currently false if oom_adj differs 
> amongst those threads, and should be written to how the oom killer uses 
> the value.

No. another process have another process value is valid assumption.
sharing struct_mm is deeply implementaion detail. it shouldn't be
exposed userland.

Why do you think false assumption? In UNIX/Linux programming
is frequently used following idiom.

	if (fork() == 0) {
		setting_something_process_property();
		execve("new-command");
	}

vfork() is also frequently used. It is allowed long time common practice.
I don't think we can says "hey, you are silly!" to application developer.


> 
> > And, May I explay why I think your oom_adj_child is wrong idea?
> > The fact is: new feature introducing never fix regression. yes, some
> > application use new interface and disappear the problem. but other
> > application still hit the problem. that's not correct development style
> > in kernel.
> > 
> 
> So you're proposing that we forever allow /proc/pid/oom_score to be 
> completely wrong for pid without any knowledge to userspace?  That we 
> falsely advertise what it represents and allow userspace to believe that 
> changing oom_adj for a thread sharing memory with other threads actually 
> changes how the oom killer selects tasks?

No. perhaps no doublly.

1) In my patch, oom_score is also per-process value. all thread have the same
   oom_score.
   It's clear meaning.
2) In almost case, oom_score display collect value because oom_adj is per-process
   value too. 
   Yes, there is one exception. vfork() and change oom_adj'ed process might display 
   wrong value. but I don't think it is serious problem because vfork() process call
   exec() soon.
   Administrator never recognize this difference.

> Please.

David, I hope you join to fix this regression. I can't believe we
can't fix this issue honestly.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
