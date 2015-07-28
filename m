Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4EA6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:39:59 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so162747025wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:39:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fe6si37554437wjc.66.2015.07.28.07.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 07:39:57 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [RFC PATCH 00/14] kthread: Use kthread worker API more widely
Date: Tue, 28 Jul 2015 16:39:17 +0200
Message-Id: <1438094371-8326-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. Sometimes, it is hard to say if they are done
correctly. They are also harder to maintain if there is
a generic problem found in the area.

I have proposed a so-called kthread iterant API to improve the situation,
see https://lkml.org/lkml/2015/6/5/555. The RFC opened and/or answered
several questions.

This RFC is reaction on Tejun's suggestion to use the existing kthread
worker API instead of a new one, see https://lkml.org/lkml/2015/6/9/77.
I wanted to give it a try.


Structure of this patch set:
----------------------------

1st..6th patches: improve the existing kthread worker API

7th, 8th, 11th patches: converts three kthreads into the new API,
     namely: RCU gp kthreas, khugepaged, my favorite ring buffer
     benchmark

12th..14th patches: show how we could further improve the API

9th, 10th patches:  do some further clean up of the ring buffer
     benchmark; they allow easier conversion into the new API;
     but they might be applied independently


TODO:
-----

If people like the kthread worker API, it will need more love.
The following ideas come to my mind:

  + allow to pass void *data via struct kthread_work;
  + hide struct kthread_worker in kthread.c and make the API
    more safe
  + allow to cancel work


I have tested this patches against today's Linux tree, aka 4.2.0-rc4+.

Petr Mladek (14):
  kthread: Allow to call __kthread_create_on_node() with va_list args
  kthread: Add create_kthread_worker*()
  kthread: Add drain_kthread_worker()
  kthread: Add destroy_kthread_worker()
  kthread: Add wakeup_and_destroy_kthread_worker()
  kthread: Add kthread_worker_created()
  mm/huge_page: Convert khugepaged() into kthread worker API
  rcu: Convert RCU gp kthreads into kthread worker API
  ring_buffer: Initialize completions statically in the benchmark
  ring_buffer: Fix more races when terminating the producer in the
    benchmark
  ring_buffer: Use kthread worker API for the producer kthread in the
    benchmark
  kthread_worker: Better support freezable kthread workers
  kthread_worker: Add set_kthread_worker_user_nice()
  kthread_worker: Add set_kthread_worker_scheduler*()

 include/linux/kthread.h              |  29 +++
 kernel/kthread.c                     | 359 +++++++++++++++++++++++++++++++----
 kernel/rcu/tree.c                    | 182 +++++++++---------
 kernel/rcu/tree.h                    |   4 +-
 kernel/trace/ring_buffer_benchmark.c | 150 ++++++++-------
 mm/huge_memory.c                     |  83 ++++----
 6 files changed, 584 insertions(+), 223 deletions(-)

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
