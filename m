Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4176B0268
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:15:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r6so10062624pfj.14
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:15:56 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g207si712128pfb.413.2017.10.20.05.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:15:54 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/15] v5 kernel core pieces refcount conversions
Date: Fri, 20 Oct 2017 15:15:42 +0300
Message-Id: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

Note: this is just a fresh rebase on top of linux-next.
No functional changes.
 

Changes in v5:
 * Kees catched that the following changes in
   perf_event_context.refcount and futex_pi_state.refcount
   are not correct now when ARCH_HAS_REFCOUNT is enabled:
    -	WARN_ON(!atomic_inc_not_zero(refcount));
    +	refcount_inc(refcount);
   So they are now changed back to using refcount_inc_not_zero. 

Changes in v4:
 * just rebase and corrections on linux-next/master

Changes in v3:
 * SoB chain corrected
 * minor corrections based on v2 feedback
 * rebase on linux-next/master as of today

Changes in v2:
 * dropped already merged patches
 * rebase on top of linux-next/master
 * Now by default refcount_t = atomic_t (*) and uses all atomic
   standard operations unless CONFIG_REFCOUNT_FULL is enabled.
   This is a compromise for the systems that are critical on
   performance (such as net) and cannot accept even slight delay
   on the refcounter operations.

This series, for core kernel components, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
If there are no objections to the patches, please merge them via respective trees.


Elena Reshetova (15):
  sched: convert sighand_struct.count to refcount_t
  sched: convert signal_struct.sigcnt to refcount_t
  sched: convert user_struct.__count to refcount_t
  sched: convert numa_group.refcount to refcount_t
  sched/task_struct: convert task_struct.usage to refcount_t
  sched/task_struct: convert task_struct.stack_refcount to refcount_t
  perf: convert perf_event_context.refcount to refcount_t
  perf/ring_buffer: convert ring_buffer.refcount to refcount_t
  perf/ring_buffer: convert ring_buffer.aux_refcount to refcount_t
  uprobes: convert uprobe.ref to refcount_t
  nsproxy: convert nsproxy.count to refcount_t
  groups: convert group_info.usage to refcount_t
  creds: convert cred.usage to refcount_t
  kcov: convert kcov.refcount to refcount_t
  bdi: convert bdi_writeback_congested.refcnt from atomic_t to
    refcount_t

 fs/exec.c                        |  4 ++--
 fs/proc/task_nommu.c             |  2 +-
 include/linux/backing-dev-defs.h |  3 ++-
 include/linux/backing-dev.h      |  4 ++--
 include/linux/cred.h             | 13 ++++++------
 include/linux/init_task.h        |  7 +++---
 include/linux/nsproxy.h          |  6 +++---
 include/linux/perf_event.h       |  3 ++-
 include/linux/sched.h            |  5 +++--
 include/linux/sched/signal.h     |  5 +++--
 include/linux/sched/task.h       |  4 ++--
 include/linux/sched/task_stack.h |  2 +-
 include/linux/sched/user.h       |  5 +++--
 kernel/cred.c                    | 46 ++++++++++++++++++++--------------------
 kernel/events/core.c             | 18 ++++++++--------
 kernel/events/internal.h         |  5 +++--
 kernel/events/ring_buffer.c      |  8 +++----
 kernel/events/uprobes.c          |  8 +++----
 kernel/fork.c                    | 24 ++++++++++-----------
 kernel/groups.c                  |  2 +-
 kernel/kcov.c                    |  9 ++++----
 kernel/nsproxy.c                 |  6 +++---
 kernel/sched/fair.c              | 12 +++++------
 kernel/user.c                    |  8 +++----
 mm/backing-dev.c                 | 14 ++++++------
 25 files changed, 117 insertions(+), 106 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
