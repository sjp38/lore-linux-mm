Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B502B6B1BF1
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:40 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id v64so10151021qka.5
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si1166412qkf.87.2018.11.19.10.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:39 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 11/17] locking/rwsem: Mark rwsem.wait_lock as a terminal lock
Date: Mon, 19 Nov 2018 13:55:20 -0500
Message-Id: <1542653726-5655-12-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

The wait_lock in a rwsem is always acquired with IRQ disabled. For the
rwsem-xadd.c implementation, no other lock will be called while holding
the wait_lock. So it satisfies the condition of being a terminal lock.
By marking it as terminal,  the lockdep overhead will be reduced.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/rwsem.h       | 11 ++++++++++-
 kernel/locking/rwsem-xadd.c |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 67dbb57..a2a2385 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -77,16 +77,25 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 # define __RWSEM_DEP_MAP_INIT(lockname)
 #endif
 
+/*
+ * The wait_lock is marked as a terminal lock to reduce lockdep overhead
+ * when the rwsem-xadd.c is used. This is implied when
+ * CONFIG_RWSEM_SPIN_ON_OWNER is true. The rwsem-spinlock.c implementation
+ * allows calling wake_up_process() while holding the wait_lock. So it
+ * can't be marked as terminal in this case.
+ */
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 #define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL
+#define __RWSEM_WAIT_LOCK_INIT(x)	__RAW_TERMINAL_SPIN_LOCK_UNLOCKED(x)
 #else
 #define __RWSEM_OPT_INIT(lockname)
+#define __RWSEM_WAIT_LOCK_INIT(x)	__RAW_SPIN_LOCK_UNLOCKED(x)
 #endif
 
 #define __RWSEM_INITIALIZER(name)				\
 	{ __RWSEM_INIT_COUNT(name),				\
 	  .wait_list = LIST_HEAD_INIT((name).wait_list),	\
-	  .wait_lock = __RAW_SPIN_LOCK_UNLOCKED(name.wait_lock)	\
+	  .wait_lock = __RWSEM_WAIT_LOCK_INIT(name.wait_lock)	\
 	  __RWSEM_OPT_INIT(name)				\
 	  __RWSEM_DEP_MAP_INIT(name) }
 
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 09b1800..3dbe593 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -85,6 +85,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 #endif
 	atomic_long_set(&sem->count, RWSEM_UNLOCKED_VALUE);
 	raw_spin_lock_init(&sem->wait_lock);
+	lockdep_set_terminal_class(&sem->wait_lock);
 	INIT_LIST_HEAD(&sem->wait_list);
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	sem->owner = NULL;
-- 
1.8.3.1
