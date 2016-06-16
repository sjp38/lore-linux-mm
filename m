Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C60E36B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:17:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so25531008wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:17:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t124si4025144wmb.85.2016.06.16.04.17.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:17:40 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v9 00/12]  kthread: Kthread worker API improvements
Date: Thu, 16 Jun 2016 13:17:19 +0200
Message-Id: <1466075851-24013-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

I send the kthread worker API improvements separately as discussed
in v6, see
https://lkml.kernel.org/g/20160511105224.GE2749@pathway.suse.cz
They seem to be ready for inclusion in 4.8.

I will send the conversion of the particular kthreads once
the API changes are in some maintainers three (-mm?) and
visible in linux-next. If nobody suggests some other approach.

Also I plan to continue with conversion of more kthreads.

Just to remember. The intention of this patchset is to make
it easier to manipulate and maintain kthreads. Especially, I want
to replace all the custom main cycles with a generic one.
Also I want to make the kthreads sleep in a consistent
state in a common place when there is no work.


Changes against v8:

  + Fixed names of DEFINE() and INIT() macros. Please, find
    more comments in the 2nd patch.


Changes against v7:

  + Fix up all names of functions and macros to be prefixed
    by kthread_/KTHREAD_; This is done also for existing
    functions and macros, see the first two patches


Changes against v6:

  + no changes.


Changes against v5:

  + removed spin_trylock() from delayed_kthread_work_timer_fn();
    instead temporary released worked->lock() when calling
    del_timer_sync(); made sure that any queueing was blocked
    by work->canceling in the mealtime

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
for 4.7-rc2.

Comments against v8 can be found at
https://lkml.kernel.org/g/1465480326-31606-1-git-send-email-pmladek@suse.com


Petr Mladek (12):
  kthread: Rename probe_kthread_data() to kthread_probe_data()
  kthread: Kthread worker API cleanup
  kthread/smpboot: Do not park in kthread_create_on_cpu()
  kthread: Allow to call __kthread_create_on_node() with va_list args
  kthread: Add kthread_create_worker*()
  kthread: Add kthread_drain_worker()
  kthread: Add kthread_destroy_worker()
  kthread: Detect when a kthread work is used by more workers
  kthread: Initial support for delayed kthread work
  kthread: Allow to cancel kthread work
  kthread: Allow to modify delayed kthread work
  kthread: Better support freezable kthread workers

 Documentation/RCU/lockdep-splat.txt         |   2 +-
 arch/x86/kvm/i8254.c                        |  14 +-
 crypto/crypto_engine.c                      |  16 +-
 drivers/block/loop.c                        |   8 +-
 drivers/infiniband/sw/rdmavt/cq.c           |  10 +-
 drivers/md/dm.c                             |  10 +-
 drivers/media/pci/ivtv/ivtv-driver.c        |   6 +-
 drivers/media/pci/ivtv/ivtv-irq.c           |   2 +-
 drivers/net/ethernet/microchip/encx24j600.c |  10 +-
 drivers/spi/spi.c                           |  18 +-
 drivers/tty/serial/sc16is7xx.c              |  22 +-
 include/linux/kthread.h                     |  90 +++-
 kernel/kthread.c                            | 612 ++++++++++++++++++++++++----
 kernel/smpboot.c                            |   5 +
 kernel/workqueue.c                          |   2 +-
 sound/soc/intel/baytrail/sst-baytrail-ipc.c |   2 +-
 sound/soc/intel/common/sst-ipc.c            |   6 +-
 sound/soc/intel/haswell/sst-haswell-ipc.c   |   2 +-
 sound/soc/intel/skylake/skl-sst-ipc.c       |   2 +-
 19 files changed, 685 insertions(+), 154 deletions(-)

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
