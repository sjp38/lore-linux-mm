From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: VMA lookup with RCU
Date: Mon, 8 Oct 2007 18:17:46 +1000
References: <46F01289.7040106@linux.vnet.ibm.com> <4709F92C.80207@linux.vnet.ibm.com> <470A6010.6000108@linux.vnet.ibm.com>
In-Reply-To: <470A6010.6000108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710081817.46478.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Eric Dumazet <dada1@cosmosbay.com>
Cc: balbir@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 09 October 2007 02:51, Vaidyanathan Srinivasan wrote:
> >> Apparently our IBM friends on this thread have a workload where mmap_sem
> >> does hurt, and I suspect its a massively threaded Java app on a somewhat
> >> larger box (8-16 cpus), which does a bit of faulting around.
> >>
> >> But I'll let them tell about it :-)
> >
> > Nick,
> >
> > We used the latest glibc (with the private futexes fix) and the latest
> > kernel. We see improvements in scalability, but at 12-16 CPU's, we see
> > a slowdown. Vaidy has been using ebizzy for testing mmap_sem
> > scalability.
>
> Hi Peter and Nick,
>
> We have been doing some tests with ebizzy 0.2 workload.
> Here are some of the test results...

Cool graphs!

Looks like private futexes blew your mmap_sem contention away. Not too
surprising: I wouldn't have expected a high performance app like this to be
doing a huge number of mmap()ing and page faults...

They almost tripled your peak performance! Of course that's with ebizzy...
what sort of correlation does this have to your real server app? (ie. does
it also see a 3x speedup?)

I don't see any synchronisation in ebizzy 2 -- I guess the gain is all due to
improved libc heap management scalability?


> ebizzy-futex.png plots the performance impact of private futex while
> ebizzy-rcu-vma.png plots the performance of Peter's RCU VMA look patch
> against base kernel with and without private futex.
>
> We can observe in both the plots that private futex improved scaling
> significantly from 4 CPUs to 8 CPUs but we still have scaling issues beyond
> 12 CPUs.
>
> Peter's RCU based b+tree vma lookup approach gives marginal performance
> improvement till 4 to 8 CPUs but does not help beyond that.
>
> Perhaps the scaling problem area shifts beyond 8-12 cpus and it is not just
> the mmap_sem and vma lookup.
>
> The significant oprofile output for various configurations are listed
> below:
>
> 12 CPUs 2.6.23-rc6 No private futex:
>
> samples  %        symbol name
> 6908330  23.7520  __down_read
> 4990895  17.1595  __up_read
> 2165162   7.4442  find_vma
> 2069868   7.1166  futex_wait
> 2063447   7.0945  futex_wake
> 1557829   5.3561  drop_futex_key_refs
> 741268    2.5486  task_rq_lock
> 638947    2.1968  schedule
> 600493    2.0646  system_call
> 515924    1.7738  copy_user_generic_unrolled
> 399672    1.3741  mwait_idle
>
> 12 CPUs 2.6.23-rc6 with private futex:
>
> samples  %        symbol name
> 2095531  15.5092  task_rq_lock
> 1094271   8.0988  schedule
> 1068093   7.9050  futex_wake
> 516250    3.8208  futex_wait
> 469220    3.4727  mwait_idle
> 468979    3.4710  system_call
> 443208    3.2802  idle_cpu
> 438301    3.2439  update_curr
> 397231    2.9399  try_to_wake_up
> 364424    2.6971  apic_timer_interrupt
> 362633    2.6839  scheduler_tick

There is basically no more mmap_sem contention or any vma lookups to
be seen. So I think it would be a waste of time to test my vma cache patches
really :P

It looks like most of the contention is on the runqueue locks and on futex
locks now. Both those paths are now pretty optimised... probably some
improvements could be made, but fundamentally if you are doing a lot of
sleeping on a single futex, and are doing a lot of cross-CPU wakeups, then
you are going to have scalability limits.

So improving glibc allocator to be more scalable, or changing the application
is likely to be the best course of action from here...

*If* you have a huge number of futexes, or a lot of processes (each with
their own threads and private futexes), then there are some possible things
we could try to improve in the private futex lookup code... but that doesn't
seem to be the case for you?


> All the above test results has the impact of oprofile included.  Running
> oprofile also may significantly increase mmap_sem contention.
>
> I Will run the tests again without oprofile to understand the impact of
> oprofile itself.
>
> Please let me know your comments and suggestions.

Getting confirmation of what is so costly in futex_wait and futex_wake
might be useful if you have time. I'll bet it is the hash lock, but could be
wrong.

Playing with the sched-domains parameters and possibly trying to reduce
the number of cross-CPU wakeups might help. However you have to be pretty
careful with this that you don't just tune the system to work well with ebizzy
and not your real workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
