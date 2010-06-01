Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8B2946B01CB
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:20:05 -0400 (EDT)
Date: Tue, 1 Jun 2010 22:18:43 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/5] oom: select_bad_process: PF_EXITING check should
	take ->mm into account
Message-ID: <20100601201843.GA20732@redhat.com>
References: <20100531183335.1846.A69D9226@jp.fujitsu.com> <20100531164354.GA9991@redhat.com> <20100601093951.2430.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100601093951.2430.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/01, KOSAKI Motohiro wrote:
>
> > I'd like to add a note... with or without this, we have problems
> > with the coredump. A thread participating in the coredumping
> > (group-leader in this case) can have PF_EXITING && mm, but this doesn't
> > mean it is going to exit soon, and the dumper can use a lot more memory.
>
> Sure. I think coredump sould do nothing if oom occur.
> So, merely making PF_COREDUMP is bad idea? I mean
>
> task-flags		allocator
> ------------------------------------------------
> none			N/A
> TIF_MEMDIE		allow to use emergency memory.
> 			don't call page reclaim.
> PF_COREDUMP		N/A
> TIF_MEMDIE+PF_COREDUMP	disallow to use emergency memory.
> 			don't call page reclaim.
>
> In other word, coredump path makes allocation failure if the task
> marked as TIF_MEMDIE.

Perhaps... But where should TIF_MEMDIE go this case? Let me clarify.

Two threads, group-leader L and its sub-thread T. T dumps the code.
In this case both threads have ->mm != NULL, L has PF_EXITING.

The first problem is, select_bad_process() always return -1 in this
case (even if the caller is T, this doesn't matter).

The second problem is that we should add TIF_MEMDIE to T, not L.

This is more or less easy. For simplicity, let's suppose we removed
this PF_EXITING check from select_bad_process().

Otoh, if we make do_coredump() interruptible (and we should do this
in any case), then perhaps the TIF_MEMDIE+PF_COREDUMP is not really
needed? Afaics we always send SIGKILL along with TIF_MEMDIE.

> > And, as it was already discussed, we only check the group-leader here.
> > But I can't suggest something better.
>
> I guess signal_group_exit() is enough in practical case.

Unlike SIGNAL_GROUP_EXIT check, signal_group_exit() can also mean
exec. This is probably correct. If we see the task inside de_thread()
he is going to free its old mm soon.

The problem is this check doesn't cover the case when a single-threaded
task exits (even if it does sys_exit_group). And it is not enough to
remove the thread_group_empty-case-optimization from do_group_exit(),
it can call sys_exit() instead.

But anyway I agree, select_bad_process can probably check

	signal_group_exit() || (PF_EXITINF && thread_group_empty())

And in that case it is better to remove the "&& p->mm" part of the
current check.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
