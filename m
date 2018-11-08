Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F87D6B0656
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:54 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so41473281qks.4
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si1368359qvt.60.2018.11.08.12.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:53 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 07/12] locking/lockdep: Add support for nested terminal locks
Date: Thu,  8 Nov 2018 15:34:23 -0500
Message-Id: <1541709268-3766-8-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

There are use cases where we want to allow 2-level nesting of one
terminal lock underneath another one. So the terminal lock type is now
extended to support a new nested terminal lock where it can allow the
acquisition of another regular terminal lock underneath it.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/lockdep.h            |  9 ++++++++-
 kernel/locking/lockdep.c           | 15 +++++++++++++--
 kernel/locking/lockdep_internals.h |  2 +-
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index c5ff8c5..ed4d177 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -147,12 +147,16 @@ struct lock_class_stats {
  * 1) LOCKDEP_FLAG_NOVALIDATE: No full validation, just simple checks.
  * 2) LOCKDEP_FLAG_TERMINAL: This is a terminal lock where lock/unlock on
  *    another lock within its critical section is not allowed.
+ * 3) LOCKDEP_FLAG_TERMINAL_NESTED: This is a terminal lock that allows
+ *    one more regular terminal lock to be nested underneath it.
  */
 #define LOCKDEP_FLAG_NOVALIDATE 	(1 << 0)
 #define LOCKDEP_FLAG_TERMINAL		(1 << 1)
+#define LOCKDEP_FLAG_TERMINAL_NESTED	(1 << 2)
 
 #define LOCKDEP_NOCHECK_FLAGS		(LOCKDEP_FLAG_NOVALIDATE |\
-					 LOCKDEP_FLAG_TERMINAL)
+					 LOCKDEP_FLAG_TERMINAL   |\
+					 LOCKDEP_FLAG_TERMINAL_NESTED)
 
 /*
  * Map the lock object (the lock instance) to the lock-class object.
@@ -314,6 +318,8 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_NOVALIDATE; } while (0)
 #define lockdep_set_terminal_class(lock) \
 	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_TERMINAL; } while (0)
+#define lockdep_set_terminal_nested_class(lock) \
+	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_TERMINAL_NESTED; } while (0)
 
 /*
  * Compare locking classes
@@ -431,6 +437,7 @@ static inline void lockdep_on(void)
 
 #define lockdep_set_novalidate_class(lock)	do { } while (0)
 #define lockdep_set_terminal_class(lock)	do { } while (0)
+#define lockdep_set_terminal_nested_class(lock)	do { } while (0)
 
 /*
  * We don't define lockdep_match_class() and lockdep_match_key() for !LOCKDEP
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 02631a0..2b75613 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -3268,13 +3268,24 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	class_idx = class - lock_classes + 1;
 
 	if (depth) {
+		int prev_type;
+
 		hlock = curr->held_locks + depth - 1;
 
 		/*
-		 * Warn if the previous lock is a terminal lock.
+		 * Warn if the previous lock is a terminal lock or the
+		 * previous lock is a nested terminal lock and the current
+		 * one isn't a regular terminal lock.
 		 */
-		if (DEBUG_LOCKS_WARN_ON(hlock_is_terminal(hlock)))
+		prev_type = hlock_is_terminal(hlock);
+		if (DEBUG_LOCKS_WARN_ON((prev_type == LOCKDEP_FLAG_TERMINAL) ||
+			((prev_type == LOCKDEP_FLAG_TERMINAL_NESTED) &&
+			 (flags_is_terminal(class->flags) !=
+				LOCKDEP_FLAG_TERMINAL)))) {
+			pr_warn("Terminal lock error: prev lock = %s, curr lock = %s\n",
+				hlock->instance->name, class->name);
 			return 0;
+		}
 
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references) {
diff --git a/kernel/locking/lockdep_internals.h b/kernel/locking/lockdep_internals.h
index 271fba8..abe646a 100644
--- a/kernel/locking/lockdep_internals.h
+++ b/kernel/locking/lockdep_internals.h
@@ -215,5 +215,5 @@ static inline unsigned long debug_class_ops_read(struct lock_class *class)
 
 static inline unsigned int flags_is_terminal(unsigned int flags)
 {
-	return flags & LOCKDEP_FLAG_TERMINAL;
+	return flags & (LOCKDEP_FLAG_TERMINAL|LOCKDEP_FLAG_TERMINAL_NESTED);
 }
-- 
1.8.3.1
