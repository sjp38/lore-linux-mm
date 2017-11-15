Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC04F6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:07:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t10so23897163pgo.20
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:07:51 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p9si18452014pls.538.2017.11.15.06.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:07:49 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/16] v6 kernel core pieces refcount conversions
Date: Wed, 15 Nov 2017 16:03:24 +0200
Message-Id: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

Changes in v6:
 * memory ordering differences are outlined in each patch
   together with potential problematic areas.
  Note: I didn't include any statements in individual patches
  on why I think the memory ordering changes do not matter
  in that particular case since ultimately these are only
  known by maintainers (unless explicitly documented) and
  very hard to figure out reliably from the code.
  Therefore maintainers are expected to double check the
  specific pointed functions and make the end decision.
 * rebase on top of today's linux-next/master  
 

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


Elena Reshetova (16):
  futex: convert futex_pi_state.refcount to refcount_t
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
 kernel/futex.c                   | 15 +++++++------
 kernel/groups.c                  |  2 +-
 kernel/kcov.c                    |  9 ++++----
 kernel/nsproxy.c                 |  6 +++---
 kernel/sched/fair.c              | 12 +++++------
 kernel/user.c                    |  8 +++----
 mm/backing-dev.c                 | 14 ++++++------
 26 files changed, 125 insertions(+), 113 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
