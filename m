Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 474916B064A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 15:35:30 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id h68so41541332qke.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 12:35:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f64si3730483qtd.182.2018.11.08.12.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 12:35:29 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 01/12] locking/lockdep: Rework lockdep_set_novalidate_class()
Date: Thu,  8 Nov 2018 15:34:17 -0500
Message-Id: <1541709268-3766-2-git-send-email-longman@redhat.com>
In-Reply-To: <1541709268-3766-1-git-send-email-longman@redhat.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

The current lockdep_set_novalidate_class() implementation is like
a hack. It assigns a special class key for that lock and calls
lockdep_init_map() twice.

This patch changes the implementation to make it more general so that
it can be used by other special lock class types. A new "type" field
is added to both the lockdep_map and lock_class structures.

The new field can now be used to designate a lock and a class object
as novalidate. The lockdep_set_novalidate_class() call, however, should
be called before lock initialization which calls lockdep_init_map().

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/lockdep.h  | 14 +++++++++++---
 kernel/locking/lockdep.c | 14 +++++++-------
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 1fd82ff..18f9607 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -58,8 +58,6 @@ struct lock_class_key {
 	struct lockdep_subclass_key	subkeys[MAX_LOCKDEP_SUBCLASSES];
 };
 
-extern struct lock_class_key __lockdep_no_validate__;
-
 #define LOCKSTAT_POINTS		4
 
 /*
@@ -102,6 +100,8 @@ struct lock_class {
 	int				name_version;
 	const char			*name;
 
+	unsigned int			flags;
+
 #ifdef CONFIG_LOCK_STAT
 	unsigned long			contention_point[LOCKSTAT_POINTS];
 	unsigned long			contending_point[LOCKSTAT_POINTS];
@@ -142,6 +142,12 @@ struct lock_class_stats {
 #endif
 
 /*
+ * Lockdep class flags
+ * 1) LOCKDEP_FLAG_NOVALIDATE: No full validation, just simple checks.
+ */
+#define LOCKDEP_FLAG_NOVALIDATE 	(1 << 0)
+
+/*
  * Map the lock object (the lock instance) to the lock-class object.
  * This is embedded into specific lock instances:
  */
@@ -149,6 +155,7 @@ struct lockdep_map {
 	struct lock_class_key		*key;
 	struct lock_class		*class_cache[NR_LOCKDEP_CACHING_CLASSES];
 	const char			*name;
+	unsigned int			flags;
 #ifdef CONFIG_LOCK_STAT
 	int				cpu;
 	unsigned long			ip;
@@ -296,7 +303,8 @@ extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
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
