Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BAA56B0047
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 21:55:52 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o062toEc013065
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 11:55:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC8A045DE55
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:55:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B72CF45DE5D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:55:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8364C1DB803B
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:55:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2689D1DB803E
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 11:55:49 +0900 (JST)
Date: Wed, 6 Jan 2010 11:52:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
	<20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010 17:37:08 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
> >
> > I think this is the 1st reason but haven't rewrote rwsem itself and tested,
> > sorry.
> 
> Here's a totally untested patch! It may or may not work. It builds for me, 
> but that may be some cosmic accident. I _think_ I got the callee-clobbered 
> register set right, but somebody should check the comment in the new 
> rwsem_64.S, and double-check that the code actually matches what I tried 
> to do.
> 
> I had to change the inline asm to get the register sizes right too, so for 
> all I know this screws up x86-32 too.
> 
> In other words: UNTESTED! It may molest your pets and drink all your beer. 
> You have been warned.
> 
Thank you for warning ;)
My host boots successfully. Here is the result.


Result of Linus's rwmutex XADD patch.

Test:
	while (1) {
		touch memory
		barrier
		fork()->exit() if cpu==0
		berrier
	}

# Samples: 1121655736712
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    50.26%  multi-fault-all  [kernel]                  [k] smp_invalidate_interrup
    15.94%  multi-fault-all  [kernel]                  [k] flush_tlb_others_ipi
     6.50%  multi-fault-all  [kernel]                  [k] intel_pmu_enable_all
     3.17%  multi-fault-all  [kernel]                  [k] down_read_trylock
     2.08%  multi-fault-all  [kernel]                  [k] do_wp_page
     1.69%  multi-fault-all  [kernel]                  [k] page_fault
     1.63%  multi-fault-all  ./multi-fault-all-fork    [.] worker
     1.53%  multi-fault-all  [kernel]                  [k] up_read
     1.35%  multi-fault-all  [kernel]                  [k] do_page_fault
     1.24%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     1.10%  multi-fault-all  [kernel]                  [k] flush_tlb_page
     0.96%  multi-fault-all  [kernel]                  [k] invalidate_interrupt0
     0.92%  multi-fault-all  [kernel]                  [k] invalidate_interrupt3
     0.90%  multi-fault-all  [kernel]                  [k] invalidate_interrupt2


Test:
	while (1) {
		touch memory
		barrier
		madvice DONTNEED to locally touched memory.
		barrier
	}


# Samples: 1335012531823
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    32.17%  multi-fault-all  [kernel]                  [k] clear_page_c
     9.60%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     8.14%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsave
     6.23%  multi-fault-all  [kernel]                  [k] down_read_trylock
     4.98%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irq
     4.63%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_charge
     4.45%  multi-fault-all  [kernel]                  [k] up_read
     3.83%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     3.19%  multi-fault-all  [kernel]                  [k] __rmqueue
     3.05%  multi-fault-all  [kernel]                  [k] __mem_cgroup_commit_cha
     2.39%  multi-fault-all  [kernel]                  [k] bad_range
     1.78%  multi-fault-all  [kernel]                  [k] page_fault
     1.74%  multi-fault-all  [kernel]                  [k] mem_cgroup_charge_commo
     1.71%  multi-fault-all  [kernel]                  [k] lookup_page_cgroup

Then, the result is much improved by XADD rwsem.

In above profile, rwsem is still there.
But page-fault/sec is good. I hope some "big" machine users join to the test.
(I hope 4 sockets, at least..)


Here is peformance counter result of DONTNEED test. Counting the number of page
faults in 60 sec. So, bigger number of page fault is better.

[XADD rwsem]
[root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8

 Performance counter stats for './multi-fault-all 8' (5 runs):

       41950863  page-faults                ( +-   1.355% )
      502983592  cache-misses               ( +-   0.628% )

   60.002682206  seconds time elapsed   ( +-   0.000% )

[my patch]
[root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8

 Performance counter stats for './multi-fault-all 8' (5 runs):

       35835485  page-faults                ( +-   0.257% )
      511445661  cache-misses               ( +-   0.770% )

   60.004243198  seconds time elapsed   ( +-   0.002% )

Ah....xadd-rwsem seems to be faster than my patch ;)
Maybe my patch adds some big overhead (see below)

Then, on my host, I can get enough page-fault throughput by modifing rwsem.


Just for my interest, profile on my patch is here.

    24.69%  multi-fault-all  [kernel]                  [k] clear_page_c
    20.26%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     8.59%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irq
     4.88%  multi-fault-all  [kernel]                  [k] page_add_new_anon_rmap
     4.33%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsave
     4.27%  multi-fault-all  [kernel]                  [k] vma_put
     3.55%  multi-fault-all  [kernel]                  [k] __mem_cgroup_try_charge
     3.36%  multi-fault-all  [kernel]                  [k] find_vma_speculative
     2.90%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     2.77%  multi-fault-all  [kernel]                  [k] __rmqueue
     2.49%  multi-fault-all  [kernel]                  [k] bad_range

Hmm...spinlock contention is twice bigger.....????


  20.46%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
            |
            --- _raw_spin_lock
               |
               |--81.42%-- free_pcppages_bulk
               |          free_hot_cold_page
               |          __pagevec_free
               |          release_pages
               |          free_pages_and_swap_cache
               |          |
               |          |--99.57%-- unmap_vmas
               |          |          zap_page_range
               |          |          sys_madvise
               |          |          system_call_fastpath
               |          |          0x3f6b0e2cf7
               |           --0.43%-- [...]
               |
               |--17.86%-- get_page_from_freelist
               |          __alloc_pages_nodemask
               |          handle_mm_fault
               |          do_page_fault
               |          page_fault
               |          0x400940
               |          (nil)
                --0.71%-- [...]

This seems to be page allocator lock. Hmm...why this big..


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
