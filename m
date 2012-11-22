Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A7BA46B0070
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 04:43:56 -0500 (EST)
Date: Thu, 22 Nov 2012 09:43:50 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/46] Automatic NUMA Balancing V4
Message-ID: <20121122094350.GS8218@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
 <20121121165342.GH8218@suse.de>
 <20121121170306.GA28811@gmail.com>
 <20121121172011.GI8218@suse.de>
 <20121121173316.GA29311@gmail.com>
 <20121122090514.GA17769@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121122090514.GA17769@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 22, 2012 at 10:05:14AM +0100, Ingo Molnar wrote:
> 
> > Thanks!
> > 
> > I ran a quick test with your 'balancenuma v4' tree and while 
> > numa02 and numa01-THREAD-ALLOC performance is looking good, 
> > numa01 performance does not look very good:
> > 
> >                     mainline    numa/core      balancenuma-v4
> >      numa01:           340.3       139.4          276 secs
> > 
> > 97% slower than numa/core.
> 
> I mean numa/core was 97% faster. That transforms into 
> balancenuma-v4 being 50.5% slower.
> 

I've asked the other questions on this already so I won't ask again.

> Your numbers from yesterday showed an even bigger proportion:
> 
> AUTONUMA BENCH
>                                           3.7.0                 3.7.0                 3.7.0                 3.7.0                 
> 3.7.0                 3.7.0
>                                 rc6-stats-v4r12   rc6-schednuma-v16r2 rc6-autonuma-v28fastr3	  rc6-moron-v4r38    rc6-twostage-v4r38  rc6-thpmigrate-v4r38
> Elapsed NUMA01                1668.03 (  0.00%)      486.04 ( 70.86%) 	   794.10 ( 52.39%)	 601.19 ( 63.96%)     1575.52 (  5.55%)     1066.67 ( 36.05%)
> 
> In your test numa/core was 240% times faster than mainline, 63% 
> faster than autonuma and 119% faster than 
> balancenuma-"rc6-thpmigrate-v4r38".
> 

Yes, I know and I know why. It's the two-filter thing and how it deals
with an adverse workload. Here is my description in mmtests comments on
what numa01 is.

# NUMA01
#   Two processes
#   NUM_CPUS/2 number of threads so all CPUs are in use
#   
#   On startup, the process forks
#   Each process mallocs a 3G buffer but there is no communication
#       between the processes.
#   Threads are created that zeros out the full buffer 1000 times
#
#   The objective of the test is that initially the two processes
#   allocate their memory on the same node. As the threads are
#   are created the memory will migrate from the initial node to
#   nodes that are closer to the referencing thread.
#
#   It is worth noting that this benchmark is specifically tuned
#   for two nodes and the expectation is that the two processes
#   and their threads split so that all process A runs on node 0
#   and all threads on process B run in node 1
#
#   With 4 and more nodes, this is actually an adverse workload.
#   As all the buffer is zeroed in both processes, there is an
#   expectation that it will continually bounce between two nodes.
#
#   So, on 2 nodes, this benchmark tests convergence. On 4 or more
#   nodes, this partially measures how much busy work automatic
#   NUMA migrate does and it'll be very noisy due to cache conflicts.

Wow, that's badly written! STill, on two nodes, numa01 is meant to
converge. On 4 nodes it is an adverse workload where the only reasonable
response is to interleave across all nodes. What likely happens is that
one process bounces between 2 nodes and the second process bounces between
the other two nodes -- all uselessly unless it's interleaving and then
backing off. I'm running on 4 nodes.

My tree has no interleaving policy. All it'll notice is that it may be
bouncing between nodes and stop migrating on the assumption that a remote
access is cheaper than a lot of migration. A smart policy is expected to
be able to overcome this.

Look at the other figures which are for a reasonable NUMA workload.
balancenuma is beating numacore there and it shouldn't be able to. One strong
likelihood is that we differ in the base mechanics. Another possibility
is that there is a bug in the policies somewhere. If you rebased on top,
we'd find out which.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
