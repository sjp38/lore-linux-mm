Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 41EE06B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:04:56 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so144804948wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 06:04:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13si30939730wjr.154.2015.09.21.06.04.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 06:04:54 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC v2 00/18] kthread: Use kthread worker API more widely
Date: Mon, 21 Sep 2015 15:03:41 +0200
Message-Id: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

My intention is to make it easier to manipulate kthreads. This RFC tries
to use the kthread worker API. It is based on comments from the
first attempt. See https://lkml.org/lkml/2015/7/28/648 and
the list of changes below.

1st..8th patches: improve the existing kthread worker API

9th, 12th, 17th patches: convert three kthreads into the new API,
     namely: khugepaged, ring buffer benchmark, RCU gp kthreads[*]

10th, 11th patches: fix potential problems in the ring buffer
      benchmark; also sent separately

13th patch: small fix for RCU kthread; also sent separately;
     being tested by Paul

14th..16th patches: preparation steps for the RCU threads
     conversion; they are needed _only_ if we split GP start
     and QS handling into separate works[*]

18th patch: does a possible improvement of the kthread worker API;
     it adds an extra parameter to the create*() functions, so I
     rather put it into this draft
     

[*] IMPORTANT: I tried to split RCU GP start and GS state handling
    into separate works this time. But there is a problem with
    a race in rcu_gp_kthread_worker_poke(). It might queue
    the wrong work. It can be detected and fixed by the work
    itself but it is a bit ugly. Alternative solution is to
    do both operations in one work. But then we sleep too much
    in the work which is ugly as well. Any idea is appreciated.
    

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
for 4.3-rc2.

Petr Mladek (18):
  kthread: Allow to call __kthread_create_on_node() with va_list args
  kthread: Add create_kthread_worker*()
  kthread: Add drain_kthread_worker()
  kthread: Add destroy_kthread_worker()
  kthread: Add pending flag to kthread work
  kthread: Initial support for delayed kthread work
  kthread: Allow to cancel kthread work
  kthread: Allow to modify delayed kthread work
  mm/huge_page: Convert khugepaged() into kthread worker API
  ring_buffer: Do no not complete benchmark reader too early
  ring_buffer: Fix more races when terminating the producer in the
    benchmark
  ring_buffer: Convert benchmark kthreads into kthread worker API
  rcu: Finish folding ->fqs_state into ->gp_state
  rcu: Store first_gp_fqs into struct rcu_state
  rcu: Clean up timeouts for forcing the quiescent state
  rcu: Check actual RCU_GP_FLAG_FQS when handling quiescent state
  rcu: Convert RCU gp kthreads into kthread worker API
  kthread: Better support freezable kthread workers

 include/linux/kthread.h              |  67 +++++
 kernel/kthread.c                     | 544 ++++++++++++++++++++++++++++++++---
 kernel/rcu/tree.c                    | 407 ++++++++++++++++----------
 kernel/rcu/tree.h                    |  24 +-
 kernel/rcu/tree_plugin.h             |  16 +-
 kernel/rcu/tree_trace.c              |   2 +-
 kernel/trace/ring_buffer_benchmark.c | 194 ++++++-------
 mm/huge_memory.c                     | 116 ++++----
 8 files changed, 1017 insertions(+), 353 deletions(-)

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
