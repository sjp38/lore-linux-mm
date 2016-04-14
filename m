Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC86828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:07 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q8so48649623lfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si17031706wjh.191.2016.04.14.08.15.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:05 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 00/20] kthread: Use kthread worker API more widely
Date: Thu, 14 Apr 2016 17:14:19 +0200
Message-Id: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-watchdog@vger.kernel.org, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Maxim Levitsky <maximlevitsky@gmail.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

My intention is to make it easier to manipulate and maintain kthreads.
Especially, I want to replace all the custom main cycles with a
generic one. Also I want to make the kthreads sleep in a consistent
state in a common place when there is no work.

My first attempt was with a brand new API (iterant kthread), see
http://thread.gmane.org/gmane.linux.kernel.api/11892 . But I was
directed to improve the existing kthread worker API. This is
the 4th iteration of the new direction.


1nd..10th patches: improve the existing kthread worker API

11th..16th, 18th, 20th patches: convert several kthreads into
      the kthread worker API, namely: khugepaged, ring buffer
      benchmark, hung_task, kmemleak, ipmi, IB/fmr_pool,
      memstick/r592, intel_powerclamp
      
17th, 19th patches: do some preparation steps; they usually do
      some clean up that makes sense even without the conversion.


Changes against v5:

  + removed spin_trylock() from delayed_kthread_work_timer_fn();
    instead temporary released worked->lock() when calling
    del_timer_sync(); made sure that any queueing was blocked
    by work->canceling in the meatime

  + used 0th byte for KTW_FREEZABLE to reduce confusion

  + fixed warnings in comments reported by make htmldocs

  + sigh, there was no easy way to create an empty va_list
    that would work on all architectures; decided to make
    @namefmt generic in create_kthread_worker_on_cpu()

  + converted khungtaskd a better way; it was inspired by
    the recent changes that appeared in 4.6-rc1


Changes against v4:

  + added worker->delayed_work_list; it simplified the check
    for pending work; we do not longer need the new timer_active()
    function; also we do not need the link work->timer. On the
    other hand we need to distinguish between the normal and
    the delayed work by a boolean parameter passed to
    the common functions, e.g. __cancel_kthread_work_sync()
    
  + replaced most try_lock repeat cycles with a WARN_ON();
    the API does not allow to use the work with more workers;
    so such a situation would be a bug; it removed the
    complex try_lock_kthread_work() function that supported
    more modes;

  + renamed kthread_work_pending() to queuing_blocked();
    added this function later when really needed

  + renamed try_to_cancel_kthread_work() to __cancel_kthread_work();
    in fact, this a common implementation for the async cancel()
    function

  + removed a dull check for invalid cpu number in
    create_kthread_worker_on_cpu(); removed some other unnecessary
    code structures as suggested by Tejun

  + consistently used bool return value in all new __cancel functions

  + fixed ordering of cpu and flags parameters in
    create_kthread_worker_on_cpu() vs. create_kthread_worker()

  + used memset in the init_kthread_worker()

  + updated many comments as suggested by Tejun and as
    required the above changes

  + removed obsolete patch adding timer_active()

  + removed obsolete patch for using try_lock in flush_kthread_worker()

  + double checked all existing users of kthread worker API
    that they reinitialized the work when the worker was started
    and would not print false warnings; all looked fine

  + added taken acks for the Intel Powerclamp conversion
    

Changes against v3:

  + allow to free struct kthread_work from its callback; do not touch
    the struct from the worker post-mortem; as a side effect, the structure
    must be reinitialized when the worker gets restarted; updated
    khugepaged, and kmemleak accordingly

  + call del_timer_sync() with worker->lock; instead, detect canceling
    in the timer callback and give up an attempt to get the lock there;
    do busy loop with spin_is_locked() to reduce cache bouncing

  + renamed ipmi+func() -> ipmi_kthread_worker_func() as suggested
    by Corey

  + added some collected Reviewed-by

  
Changes against v2:

  + used worker->lock to synchronize the operations with the work
    instead of the PENDING bit as suggested by Tejun Heo; it simplified
    the implementation in several ways

  + added timer_active(); used it together with del_timer_sync()
    to cancel the work a less tricky way

  + removed the controversial conversion of the RCU kthreads

  + added several other examples: hung_task, kmemleak, ipmi,
    IB/fmr_pool, memstick/r592, intel_powerclamp

  + the helper fixes for the ring buffer benchmark has been improved
    as suggested by Steven; they already are in the Linus tree now

  + fixed a possible race between the check for existing khugepaged
    worker and queuing the work
 

Changes against v1:

  + remove wrappers to manipulate the scheduling policy and priority

  + remove questionable wakeup_and_destroy_kthread_worker() variant

  + do not check for chained work when draining the queue

  + allocate struct kthread worker in create_kthread_work() and
    use more simple checks for running worker

  + add support for delayed kthread works and use them instead
    of waiting inside the works

  + rework the "unrelated" fixes for the ring buffer benchmark
    as discussed in the 1st RFC; also sent separately

  + convert also the consumer in the ring buffer benchmark


I have tested this patch set against the stable Linus tree
for 4.6-rc3.

Comments against v5 can be found at
http://thread.gmane.org/gmane.linux.kernel.mm/146726

Petr Mladek (20):
  kthread/smpboot: Do not park in kthread_create_on_cpu()
  kthread: Allow to call __kthread_create_on_node() with va_list args
  kthread: Add create_kthread_worker*()
  kthread: Add drain_kthread_worker()
  kthread: Add destroy_kthread_worker()
  kthread: Detect when a kthread work is used by more workers
  kthread: Initial support for delayed kthread work
  kthread: Allow to cancel kthread work
  kthread: Allow to modify delayed kthread work
  kthread: Better support freezable kthread workers
  mm/huge_page: Convert khugepaged() into kthread worker API
  ring_buffer: Convert benchmark kthreads into kthread worker API
  hung_task: Convert hungtaskd into kthread worker API
  kmemleak: Convert kmemleak kthread into kthread worker API
  ipmi: Convert kipmi kthread into kthread worker API
  IB/fmr_pool: Convert the cleanup thread into kthread worker API
  memstick/r592: Better synchronize debug messages in r592_io kthread
  memstick/r592: convert r592_io kthread into kthread worker API
  thermal/intel_powerclamp: Remove duplicated code that starts the
    kthread
  thermal/intel_powerclamp: Convert the kthread to kthread worker API

 drivers/char/ipmi/ipmi_si_intf.c     | 121 ++++----
 drivers/infiniband/core/fmr_pool.c   |  54 ++--
 drivers/memstick/host/r592.c         |  61 ++--
 drivers/memstick/host/r592.h         |   5 +-
 drivers/thermal/intel_powerclamp.c   | 302 ++++++++++--------
 include/linux/kthread.h              |  57 ++++
 kernel/hung_task.c                   |  83 +++--
 kernel/kthread.c                     | 571 +++++++++++++++++++++++++++++++----
 kernel/smpboot.c                     |   5 +
 kernel/trace/ring_buffer_benchmark.c | 133 ++++----
 mm/huge_memory.c                     | 138 +++++----
 mm/kmemleak.c                        |  87 +++---
 12 files changed, 1106 insertions(+), 511 deletions(-)

CC: Catalin Marinas <catalin.marinas@arm.com>
CC: linux-watchdog@vger.kernel.org
CC: Corey Minyard <minyard@acm.org>
CC: openipmi-developer@lists.sourceforge.net
CC: Doug Ledford <dledford@redhat.com>
CC: Sean Hefty <sean.hefty@intel.com>
CC: Hal Rosenstock <hal.rosenstock@gmail.com>
CC: linux-rdma@vger.kernel.org
CC: Maxim Levitsky <maximlevitsky@gmail.com>
CC: Zhang Rui <rui.zhang@intel.com>
CC: Eduardo Valentin <edubezval@gmail.com>
CC: Jacob Pan <jacob.jun.pan@linux.intel.com>
CC: linux-pm@vger.kernel.org
CC: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
