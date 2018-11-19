Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4C96B1B8A
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:56:56 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v64so10147732qka.5
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:56:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 190si957531qkk.28.2018.11.19.10.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:56:54 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 02/17] locking/lockdep: Rework lockdep_set_novalidate_class()
Date: Mon, 19 Nov 2018 13:55:11 -0500
Message-Id: <1542653726-5655-3-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

The current lockdep_set_novalidate_class() implementation is like
a hack. It assigns a special class key for that lock and calls
lockdep_init_map() twice.

This patch changes the implementation to make it as a flag bit instead.
This will allow other special locking class types to be defined and
used in the lockdep code.  A new "type" field is added to both the
lockdep_map and lock_class structures.

The new field can now be used to designate a lock and a class object
as novalidate. The lockdep_set_novalidate_class() call, however, should
be called only after lock initialization which calls lockdep_init_map().

For 64-bit architectures, the new type field won't increase the size
of the lock_class structure. The lockdep_map structure won't change as
well for 64-bit architectures with CONFIG_LOCK_STAT configured.

Please note that lockdep_set_novalidate_class() should not be used at
all unless there is overwhelming reason to do so.  Hopefully we can
retired it in the near future.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/lockdep.h  | 17 ++++++++++++++---
 kernel/locking/lockdep.c | 14 +++++++-------
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index c5335df..8fe5b4f 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -58,8 +58,6 @@ struct lock_class_key {
 	struct lockdep_subclass_key	subkeys[MAX_LOCKDEP_SUBCLASSES];
 };
 
-extern struct lock_class_key __lockdep_no_validate__;
-
 #define LOCKSTAT_POINTS		4
 
 /*
@@ -94,6 +92,11 @@ struct lock_class {
 	struct list_head		locks_after, locks_before;
 
 	/*
+	 * Lock class type flags
+	 */
+	unsigned int			flags;
+
+	/*
 	 * Generation counter, when doing certain classes of graph walking,
 	 * to ensure that we check one node only once:
 	 */
@@ -140,6 +143,12 @@ struct lock_class_stats {
 #endif
 
 /*
+ * Lockdep class type flags
+ * 1) LOCKDEP_FLAG_NOVALIDATE: No full validation, just simple checks.
+ */
+#define LOCKDEP_FLAG_NOVALIDATE 	(1 << 0)
+
+/*
  * Map the lock object (the lock instance) to the lock-class object.
  * This is embedded into specific lock instances:
  */
@@ -147,6 +156,7 @@ struct lockdep_map {
 	struct lock_class_key		*key;
 	struct lock_class		*class_cache[NR_LOCKDEP_CACHING_CLASSES];
 	const char			*name;
+	unsigned int			flags;
 #ifdef CONFIG_LOCK_STAT
 	int				cpu;
 	unsigned long			ip;
@@ -294,7 +304,8 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
 				 (lock)->dep_map.key, sub)
 
 #define lockdep_set_novalidate_class(lock) \
-	lockdep_set_class_and_name(lock, &__lockdep_no_validate__, #lock)
+	do { (lock)->dep_map.flags |= LOCKDEP_FLAG_NOVALIDATE; } while (0)
+
 /*
  * Compare locking classes
  */
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 1efada2..493b567 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -692,10 +692,11 @@ static int count_matching_names(struct lock_class *new_class)
 	hlist_for_each_entry_rcu(class, hash_head, hash_entry) {
 		if (class->key == key) {
 			/*
-			 * Huh! same key, different name? Did someone trample
-			 * on some memory? We're most confused.
+			 * Huh! same key, different name or flags? Did someone
+			 * trample on some memory? We're most confused.
 			 */
-			WARN_ON_ONCE(class->name != lock->name);
+			WARN_ON_ONCE((class->name  != lock->name) ||
+				     (class->flags != lock->flags));
 			return class;
 		}
 	}
@@ -788,6 +789,7 @@ static bool assign_lock_key(struct lockdep_map *lock)
 	debug_atomic_inc(nr_unused_locks);
 	class->key = key;
 	class->name = lock->name;
+	class->flags = lock->flags;
 	class->subclass = subclass;
 	INIT_LIST_HEAD(&class->lock_entry);
 	INIT_LIST_HEAD(&class->locks_before);
@@ -3108,6 +3110,7 @@ static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
 		return;
 	}
 
+	lock->flags = 0;
 	lock->name = name;
 
 	/*
@@ -3152,9 +3155,6 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
 }
 EXPORT_SYMBOL_GPL(lockdep_init_map);
 
-struct lock_class_key __lockdep_no_validate__;
-EXPORT_SYMBOL_GPL(__lockdep_no_validate__);
-
 static int
 print_lock_nested_lock_not_held(struct task_struct *curr,
 				struct held_lock *hlock,
@@ -3215,7 +3215,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (unlikely(!debug_locks))
 		return 0;
 
-	if (!prove_locking || lock->key == &__lockdep_no_validate__)
+	if (!prove_locking || (lock->flags & LOCKDEP_FLAG_NOVALIDATE))
 		check = 0;
 
 	if (subclass < NR_LOCKDEP_CACHING_CLASSES)
-- 
1.8.3.1
