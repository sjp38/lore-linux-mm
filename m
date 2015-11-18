Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8C882F64
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:26:14 -0500 (EST)
Received: by wmww144 with SMTP id w144so197031577wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:26:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m135si4803163wmb.47.2015.11.18.05.26.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:26:13 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 00/22] kthread: Use kthread worker API more widely
Date: Wed, 18 Nov 2015 14:25:05 +0100
Message-Id: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-watchdog@vger.kernel.org, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Maxim Levitsky <maximlevitsky@gmail.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

My intention is to make it easier to manipulate and maintain kthreads.
Especially, I want to replace all the custom main cycles with a
generic one. Also I want to make the kthreads sleep in a consistent
state in a common place when there is no work.

My first attempt was with a brand new API (iterant kthread), see
http://thread.gmane.org/gmane.linux.kernel.api/11892 . But I was
directed to improve the existing kthread worker API. This is
the 3rd iteration of the new direction.


1st patch: add support to check if a timer callback is being called

2nd..12th patches: improve the existing kthread worker API

13th..18th, 20th, 22nd patches: convert several kthreads into
      the kthread worker API, namely: khugepaged, ring buffer
      benchmark, hung_task, kmemleak, ipmi, IB/fmr_pool,
      memstick/r592, intel_powerclamp
      
21st, 23rd patches: do some preparation steps; they usually do
      some clean up that makes sense even without the conversion.

  
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
for 4.4-rc1.

Petr Mladek (22):
  timer: Allow to check when the timer callback has not finished yet
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
  kthread: Use try_lock_kthread_work() in flush_kthread_work()
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

 drivers/char/ipmi/ipmi_si_intf.c     | 116 ++++---
 drivers/infiniband/core/fmr_pool.c   |  54 ++-
 drivers/memstick/host/r592.c         |  61 ++--
 drivers/memstick/host/r592.h         |   5 +-
 drivers/thermal/intel_powerclamp.c   | 302 +++++++++--------
 include/linux/kthread.h              |  56 ++++
 include/linux/timer.h                |   2 +
 kernel/hung_task.c                   |  41 ++-
 kernel/kthread.c                     | 618 +++++++++++++++++++++++++++++++----
 kernel/smpboot.c                     |   5 +
 kernel/time/timer.c                  |  24 ++
 kernel/trace/ring_buffer_benchmark.c | 133 ++++----
 mm/huge_memory.c                     | 134 ++++----
 mm/kmemleak.c                        |  86 +++--
 14 files changed, 1142 insertions(+), 495 deletions(-)

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

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
