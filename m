Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3776B026B
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u70so10089292pfa.2
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x81si704111pfk.539.2017.10.20.05.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:06 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/15] sched: convert signal_struct.sigcnt to refcount_t
Date: Fri, 20 Oct 2017 15:15:44 +0300
Message-Id: <1508501757-15784-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable signal_struct.sigcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/sched/signal.h | 2 +-
 kernel/fork.c                | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
index b40fbf7..856d957 100644
--- a/include/linux/sched/signal.h
+++ b/include/linux/sched/signal.h
@@ -77,7 +77,7 @@ struct thread_group_cputimer {
  * the locking of signal_struct.
  */
 struct signal_struct {
-	atomic_t		sigcnt;
+	refcount_t		sigcnt;
 	atomic_t		live;
 	int			nr_threads;
 	struct list_head	thread_head;
diff --git a/kernel/fork.c b/kernel/fork.c
index ab4ddc9..869850b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -642,7 +642,7 @@ static inline void free_signal_struct(struct signal_struct *sig)
 
 static inline void put_signal_struct(struct signal_struct *sig)
 {
-	if (atomic_dec_and_test(&sig->sigcnt))
+	if (refcount_dec_and_test(&sig->sigcnt))
 		free_signal_struct(sig);
 }
 
@@ -1443,7 +1443,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 
 	sig->nr_threads = 1;
 	atomic_set(&sig->live, 1);
-	atomic_set(&sig->sigcnt, 1);
+	refcount_set(&sig->sigcnt, 1);
 
 	/* list_add(thread_node, thread_head) without INIT_LIST_HEAD() */
 	sig->thread_head = (struct list_head)LIST_HEAD_INIT(tsk->thread_node);
@@ -1950,7 +1950,7 @@ static __latent_entropy struct task_struct *copy_process(
 		} else {
 			current->signal->nr_threads++;
 			atomic_inc(&current->signal->live);
-			atomic_inc(&current->signal->sigcnt);
+			refcount_inc(&current->signal->sigcnt);
 			list_add_tail_rcu(&p->thread_group,
 					  &p->group_leader->thread_group);
 			list_add_tail_rcu(&p->thread_node,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
