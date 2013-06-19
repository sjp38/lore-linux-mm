Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 27A376B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:16:17 -0400 (EDT)
Received: by mail-ea0-f175.google.com with SMTP id z7so3178502eaf.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 06:16:15 -0700 (PDT)
Date: Wed, 19 Jun 2013 15:16:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
Message-ID: <20130619131611.GC24957@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371165992.27102.573.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Ingo,
> 
> At the time of switching the anon-vma tree's lock from mutex to 
> rw-sem (commit 5a505085), we encountered regressions for fork heavy workload. 
> A lot of optimizations to rw-sem (e.g. lock stealing) helped to 
> mitigate the problem.  I tried an experiment on the 3.10-rc4 kernel 
> to compare the performance of rw-sem to one that uses mutex. I saw 
> a 8% regression in throughput for rw-sem vs a mutex implementation in
> 3.10-rc4.
> 
> For the experiments, I used the exim mail server workload in 
> the MOSBENCH test suite on 4 socket (westmere) and a 4 socket 
> (ivy bridge) with the number of clients sending mail equal 
> to number of cores.  The mail server will
> fork off a process to handle an incoming mail and put it into mail
> spool. The lock protecting the anon-vma tree is stressed due to
> heavy forking. On both machines, I saw that the mutex implementation 
> has 8% more throughput.  I've pinned the cpu frequency to maximum
> in the experiments.
> 
> I've tried two separate tweaks to the rw-sem on 3.10-rc4.  I've tested 
> each tweak individually.
> 
> 1) Add an owner field when a writer holds the lock and introduce 
> optimistic spinning when an active writer is holding the semaphore.  
> It reduced the context switching by 30% to a level very close to the
> mutex implementation.  However, I did not see any throughput improvement
> of exim.
> 
> 2) When the sem->count's active field is non-zero (i.e. someone
> is holding the lock), we can skip directly to the down_write_failed
> path, without adding the RWSEM_DOWN_WRITE_BIAS and taking
> it off again from sem->count, saving us two atomic operations.
> Since we will try the lock stealing again later, this should be okay.
> Unfortunately it did not improve the exim workload either.  
> 
> Any suggestions on the difference between rwsem and mutex performance
> and possible improvements to recover this regression?
> 
> Thanks.
> 
> Tim
> 
> vmstat for mutex implementation: 
> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> 38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
> 41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0
> 
> vmstat for rw-sem implementation (3.10-rc4)
> procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> 40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
> 39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0

It appears the main difference is that the rwsem variant context-switches 
about 36% more than the mutex version, right?

I'm wondering how that's possible - the lock is mostly write-locked, 
correct? So the lock-stealing from Davidlohr Bueso and Michel Lespinasse 
ought to have brought roughly the same lock-stealing behavior as mutexes 
do, right?

So the next analytical step would be to figure out why rwsem lock-stealing 
is not behaving in an equivalent fashion on this workload. Do readers come 
in frequently enough to disrupt write-lock-stealing perhaps?

Context-switch call-graph profiling might shed some light on where the 
extra context switches come from...

Something like:

  perf record -g -e sched:sched_switch --filter 'prev_state != 0' -a sleep 1

or a variant thereof might do the trick.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
