Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A94E66B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 12:53:50 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130619131611.GC24957@gmail.com>
References: <1371165992.27102.573.camel@schen9-DESK>
	 <20130619131611.GC24957@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jun 2013 09:53:51 -0700
Message-ID: <1371660831.27102.663.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Wed, 2013-06-19 at 15:16 +0200, Ingo Molnar wrote:

> > vmstat for mutex implementation: 
> > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > 38  0      0 130957920  47860 199956    0    0     0    56 236342 476975 14 72 14  0  0
> > 41  0      0 130938560  47860 219900    0    0     0     0 236816 479676 14 72 14  0  0
> > 
> > vmstat for rw-sem implementation (3.10-rc4)
> > procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
> >  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
> > 40  0      0 130933984  43232 202584    0    0     0     0 321817 690741 13 71 16  0  0
> > 39  0      0 130913904  43232 224812    0    0     0     0 322193 692949 13 71 16  0  0
> 
> It appears the main difference is that the rwsem variant context-switches 
> about 36% more than the mutex version, right?
> 
> I'm wondering how that's possible - the lock is mostly write-locked, 
> correct? So the lock-stealing from Davidlohr Bueso and Michel Lespinasse 
> ought to have brought roughly the same lock-stealing behavior as mutexes 
> do, right?
> 
> So the next analytical step would be to figure out why rwsem lock-stealing 
> is not behaving in an equivalent fashion on this workload. Do readers come 
> in frequently enough to disrupt write-lock-stealing perhaps?
> 
> Context-switch call-graph profiling might shed some light on where the 
> extra context switches come from...
> 
> Something like:
> 
>   perf record -g -e sched:sched_switch --filter 'prev_state != 0' -a sleep 1
> 
> or a variant thereof might do the trick.
> 

Ingo,

It appears that we are having much more down write failure causing a process to
block vs going to the slow path for the mutex case.

Here's the profile data from
perf record -g -e sched:sched_switch --filter 'prev_state != 0' -a sleep 1

3.10-rc4 (mutex implementation context switch profile)

-  59.51%             exim  [kernel.kallsyms]  [k] perf_trace_sched_switch
   - perf_trace_sched_switch
   - __schedule
      - 99.98% schedule
         + 33.07% schedule_timeout
         + 23.84% pipe_wait
         + 20.24% do_wait
         + 12.37% do_exit
         + 5.34% sigsuspend
         - 3.40% schedule_preempt_disabled
              __mutex_lock_common.clone.8
              __mutex_lock_slowpath
            - mutex_lock                   <---------low rate mutex blocking
               + 65.71% lock_anon_vma_root.clone.24
               + 19.03% anon_vma_lock.clone.21
               + 7.14% dup_mm
               + 5.36% unlink_file_vma
               + 1.71% ima_file_check
               + 0.64% generic_file_aio_write
         - 1.07% rwsem_down_write_failed
              call_rwsem_down_write_failed
              exit_shm
              do_exit
              do_group_exit
              SyS_exit_group
              system_call_fastpath
-  27.61%           smtpbm  [kernel.kallsyms]  [k] perf_trace_sched_switch
   - perf_trace_sched_switch
   - __schedule
   - schedule
   - schedule_timeout
      + 100.00% sk_wait_data
+   0.46%          swapper  [kernel.kallsyms]  [k] perf_trace_sched_switch


----------------------
3.10-rc4 implementation (rw-sem context switch profile)

81.91%             exim  [kernel.kallsyms]  [k] perf_trace_sched_switch
- perf_trace_sched_switch
- __schedule
   - 99.99% schedule
      - 65.26% rwsem_down_write_failed   <------High write lock blocking
         - call_rwsem_down_write_failed
            - 79.36% lock_anon_vma_root.clone.27
               + 52.64% unlink_anon_vmas
               + 47.36% anon_vma_clone
            + 12.16% anon_vma_fork
            + 8.00% anon_vma_free
      + 11.96% schedule_timeout
      + 7.66% do_exit
      + 7.61% do_wait
      + 5.49% pipe_wait
      + 1.82% sigsuspend
13.55%           smtpbm  [kernel.kallsyms]  [k] perf_trace_sched_switch
- perf_trace_sched_switch
- __schedule
- schedule
- schedule_timeout
 0.11%        rcu_sched  [kernel.kallsyms]  [k] perf_trace_sched_switch


Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
