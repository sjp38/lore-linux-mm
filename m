Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6366B01C1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 18:58:15 -0400 (EDT)
Date: Tue, 8 Jun 2010 15:58:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
Message-Id: <20100608155802.cdd4aff3.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:54 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> This a complete rewrite of the oom killer's badness() heuristic which is
> used to determine which task to kill in oom conditions.  The goal is to
> make it as simple and predictable as possible so the results are better
> understood and we end up killing the task which will lead to the most
> memory freeing while still respecting the fine-tuning from userspace.

It's not obvious from this description that then end result is better! 
Have you any testcases or scenarios which got improved?

> Instead of basing the heuristic on mm->total_vm for each task, the task's
> rss and swap space is used instead.  This is a better indication of the
> amount of memory that will be freeable if the oom killed task is chosen
> and subsequently exits.

Again, why should we optimise for the amount of memory which a killing
will yield (if that's what you mean).  We only need to free enough
memory to unblock the oom condition then proceed.

The last thing we want to do is to kill a process which has consumed
1000 CPU hours, or which is providing some system-critical service or
whatever.  Amount-of-memory-freeable is a relatively minor criterion.

>  This helps specifically in cases where KDE or
> GNOME is chosen for oom kill on desktop systems instead of a memory
> hogging task.

It helps how?  Examples and test cases?

> The baseline for the heuristic is a proportion of memory that each task is
> currently using in memory plus swap compared to the amount of "allowable"
> memory.

What does "swap" mean?  swapspace includes swap-backed swapcache,
un-swap-backed swapcache and non-resident swap.  Which of all these is
being used here and for what reason?

>  "Allowable," in this sense, means the system-wide resources for
> unconstrained oom conditions, the set of mempolicy nodes, the mems
> attached to current's cpuset, or a memory controller's limit.  The
> proportion is given on a scale of 0 (never kill) to 1000 (always kill),
> roughly meaning that if a task has a badness() score of 500 that the task
> consumes approximately 50% of allowable memory resident in RAM or in swap
> space.

So is a new aim of this code to also free up swap space?  Confused.

> The proportion is always relative to the amount of "allowable" memory and
> not the total amount of RAM systemwide so that mempolicies and cpusets may
> operate in isolation; they shall not need to know the true size of the
> machine on which they are running if they are bound to a specific set of
> nodes or mems, respectively.
> 
> Root tasks are given 3% extra memory just like __vm_enough_memory()
> provides in LSMs.  In the event of two tasks consuming similar amounts of
> memory, it is generally better to save root's task.
> 
> Because of the change in the badness() heuristic's baseline, it is also
> necessary to introduce a new user interface to tune it.  It's not possible
> to redefine the meaning of /proc/pid/oom_adj with a new scale since the
> ABI cannot be changed for backward compatability.  Instead, a new tunable,
> /proc/pid/oom_score_adj, is added that ranges from -1000 to +1000.  It may
> be used to polarize the heuristic such that certain tasks are never
> considered for oom kill while others may always be considered.  The value
> is added directly into the badness() score so a value of -500, for
> example, means to discount 50% of its memory consumption in comparison to
> other tasks either on the system, bound to the mempolicy, in the cpuset,
> or sharing the same memory controller.
> 
> /proc/pid/oom_adj is changed so that its meaning is rescaled into the
> units used by /proc/pid/oom_score_adj, and vice versa.  Changing one of
> these per-task tunables will rescale the value of the other to an
> equivalent meaning.  Although /proc/pid/oom_adj was originally defined as
> a bitshift on the badness score, it now shares the same linear growth as
> /proc/pid/oom_score_adj but with different granularity.  This is required
> so the ABI is not broken with userspace applications and allows oom_adj to
> be deprecated for future removal.

It was a mistake to add oom_adj in the first place.  Because it's a
user-visible knob which us tied to a particular in-kernel
implementation.  As we're seeing now, the presence of that knob locks
us into a particular implementation.

Given that oom_score_adj is just a rescaled version of oom_adj
(correct?), I guess things haven't got a lot worse on that front as a
result of these changes.


General observation regarding the patch description: I'm not seeing a
lot of reason for merging the patch!  What value does it bring to our
users?  What problems got solved?

Some of Kosaki's observations sounded fairly serious so I'll go into
wait-and-see mode on this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
