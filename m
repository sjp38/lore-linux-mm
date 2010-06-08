Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 06C406B01C3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:16:19 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:15:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 17/18] oom: add forkbomb penalty to badness heuristic
Message-Id: <20100608161541.6b43b48c.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061527180.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061527180.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:58 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Add a forkbomb penalty for processes that fork an excessively large
> number of children to penalize that group of tasks and not others.  A
> threshold is configurable from userspace to determine how many first-
> generation execve children (those with their own address spaces) a task
> may have before it is considered a forkbomb.  This can be tuned by
> altering the value in /proc/sys/vm/oom_forkbomb_thres, which defaults to
> 1000.
> 
> When a task has more than 1000 first-generation children with different
> address spaces than itself, a penalty of
> 
> 	(average rss of children) * (# of 1st generation execve children)
> 	-----------------------------------------------------------------
> 			oom_forkbomb_thres
> 
> is assessed.  So, for example, using the default oom_forkbomb_thres of
> 1000, the penalty is twice the average rss of all its execve children if
> there are 2000 such tasks.  A task is considered to count toward the
> threshold if its total runtime is less than one second; for 1000 of such
> tasks to exist, the parent process must be forking at an extremely high
> rate either erroneously or maliciously.
> 
> Even though a particular task may be designated a forkbomb and selected as
> the victim, the oom killer will still kill the 1st generation execve child
> with the highest badness() score in its place.  The avoids killing
> important servers or system daemons.  When a web server forks a very large
> number of threads for client connections, for example, it is much better
> to kill one of those threads than to kill the server and make it
> unresponsive.
> 

- "oom_forkbomb_thresh" or "oom_forkbomb_threshold", please.

- No new proc knobs!  They lock us into implementation details.

- Let's go outside the box: forkbomb is just a workload.  Why does
  one particular workload need special-casing in the oom-killer?  If
  the oom-kill was working well then when a forkbomb causes an oom, the
  oom-killer would kill whatever is necessary to unlock the system and
  will then let things proceed.

  IOW, if the oom-killer can't handle this particular workload
  gracefully without special-casing then it isn't working well enough.

  Now, maybe there is an argument that a forkbomb is sufficiently
  damaging to warrant adding special-case handling in the kernel.  But
  if so, it should be detected and handled at sys_fork()
  (RLIMIT_NPROC?), not in the oom-killer.  Or, better, the kernel
  should be fixed so that whatever damage the forkbomb causes doesn't
  get caused any more.

  (otoh, the oom-killer is already stuffed full of heuristics and
  this is just another one.  But it should work correctly without it,
  dammit!)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
