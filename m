Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B03416B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 19:26:29 -0400 (EDT)
Subject: Performance regression from switching lock to rw-sem for anon-vma
 tree
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Jun 2013 16:26:32 -0700
Message-ID: <1371165992.27102.573.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Ingo,

At the time of switching the anon-vma tree's lock from mutex to 
rw-sem (commit 5a505085), we encountered regressions for fork heavy workload. 
A lot of optimizations to rw-sem (e.g. lock stealing) helped to 
mitigate the problem.  I tried an experiment on the 3.10-rc4 kernel 
to compare the performance of rw-sem to one that uses mutex. I saw 
a 8% regression in throughput for rw-sem vs a mutex implementation in
3.10-rc4.

For the experiments, I used the exim mail server workload in 
the MOSBENCH test suite on 4 socket (westmere) and a 4 socket 
(ivy bridge) with the number of clients sending mail equal 
to number of cores.  The mail server will
fork off a process to handle an incoming mail and put it into mail
spool. The lock protecting the anon-vma tree is stressed due to
heavy forking. On both machines, I saw that the mutex implementation 
has 8% more throughput.  I've pinned the cpu frequency to maximum
in the experiments.

I've tried two separate tweaks to the rw-sem on 3.10-rc4.  I've tested 
each tweak individually.

1) Add an owner field when a writer holds the lock and introduce 
optimistic spinning when an active writer is holding the semaphore.  
It reduced the context switching by 30% to a level very close to the
mutex implementation.  However, I did not see any throughput improvement
of exim.

2) When the sem->count's active field is non-zero (i.e. someone
is holding the lock), we can skip directly to the down_write_failed
path, without adding the RWSEM_DOWN_WRITE_BIAS and taking
it off again from sem->count, saving us two atomic operations.
Since we will try the lock stealing again later, this should be okay.
Unfortunately it did not improve the exim workload either.  

Any suggestions on the difference between rwsem and mutex performance
and possible improvements to recover this regression?

Thanks.

Tim

vmstat for mutex implementation: 
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0

vmstat for rw-sem implementation (3.10-rc4)
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0


Profile for mutex implementation:
5.02%             exim  [kernel.kallsyms]     [k] page_fault
3.67%             exim  [kernel.kallsyms]     [k] anon_vma_interval_tree_insert
2.66%             exim  [kernel.kallsyms]     [k] unmap_single_vma
2.15%             exim  [kernel.kallsyms]     [k] do_raw_spin_lock
2.14%             exim  [kernel.kallsyms]     [k] page_cache_get_speculative
2.04%             exim  [kernel.kallsyms]     [k] copy_page_rep
1.58%             exim  [kernel.kallsyms]     [k] clear_page_c
1.55%             exim  [kernel.kallsyms]     [k] cpu_relax
1.55%             exim  [kernel.kallsyms]     [k] mutex_unlock
1.42%             exim  [kernel.kallsyms]     [k] __slab_free
1.16%             exim  [kernel.kallsyms]     [k] mutex_lock  
1.12%             exim  libc-2.13.so          [.] vfprintf   
0.99%             exim  [kernel.kallsyms]     [k] find_vma  
0.95%             exim  [kernel.kallsyms]     [k] __list_del_entry    

Profile for rw-sem implementation
4.88%             exim  [kernel.kallsyms]     [k] page_fault
3.43%             exim  [kernel.kallsyms]     [k] anon_vma_interval_tree_insert
2.65%             exim  [kernel.kallsyms]     [k] unmap_single_vma
2.46%             exim  [kernel.kallsyms]     [k] do_raw_spin_lock
2.25%             exim  [kernel.kallsyms]     [k] copy_page_rep
2.01%             exim  [kernel.kallsyms]     [k] page_cache_get_speculative
1.81%             exim  [kernel.kallsyms]     [k] clear_page_c
1.51%             exim  [kernel.kallsyms]     [k] __slab_free
1.12%             exim  libc-2.13.so          [.] vfprintf
1.06%             exim  [kernel.kallsyms]     [k] __list_del_entry
1.02%          swapper  [kernel.kallsyms]     [k] _raw_spin_unlock_irqrestore
1.00%             exim  [kernel.kallsyms]     [k] find_vma
0.93%             exim  [kernel.kallsyms]     [k] mutex_unlock


turbostat for mutex implementation:
pk cor CPU    %c0  GHz  TSC    %c1    %c3    %c6 CTMP   %pc3   %pc6
            82.91 2.39 2.39  11.65   2.76   2.68   51   0.00   0.00

turbostat of rw-sem implementation (3.10-rc4):
pk cor CPU    %c0  GHz  TSC    %c1    %c3    %c6 CTMP   %pc3   %pc6
            80.10 2.39 2.39  14.96   2.80   2.13   52   0.00   0.00




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
