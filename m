Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94F526B1B90
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:56:58 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s70so71781123qks.4
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:56:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m37si12246403qtc.111.2018.11.19.10.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:56:57 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 04/17] locking/lockdep: Add DEFINE_TERMINAL_SPINLOCK() and related macros
Date: Mon, 19 Nov 2018 13:55:13 -0500
Message-Id: <1542653726-5655-5-git-send-email-longman@redhat.com>
In-Reply-To: <1542653726-5655-1-git-send-email-longman@redhat.com>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Waiman Long <longman@redhat.com>

Add new DEFINE_RAW_TERMINAL_SPINLOCK() and DEFINE_TERMINAL_SPINLOCK()
macro to define a raw terminal spinlock and a terminal spinlock.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/spinlock_types.h | 34 +++++++++++++++++++++++-----------
 kernel/printk/printk_safe.c    |  2 +-
 2 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/spinlock_types.h b/include/linux/spinlock_types.h
index 24b4e6f..6a8086e 100644
--- a/include/linux/spinlock_types.h
+++ b/include/linux/spinlock_types.h
@@ -33,9 +33,10 @@
 #define SPINLOCK_OWNER_INIT	((void *)-1L)
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-# define SPIN_DEP_MAP_INIT(lockname)	.dep_map = { .name = #lockname }
+# define SPIN_DEP_MAP_INIT(lockname, f) .dep_map = { .name = #lockname, \
+						     .flags = f }
 #else
-# define SPIN_DEP_MAP_INIT(lockname)
+# define SPIN_DEP_MAP_INIT(lockname, f)
 #endif
 
 #ifdef CONFIG_DEBUG_SPINLOCK
@@ -47,16 +48,22 @@
 # define SPIN_DEBUG_INIT(lockname)
 #endif
 
-#define __RAW_SPIN_LOCK_INITIALIZER(lockname)	\
-	{					\
-	.raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,	\
-	SPIN_DEBUG_INIT(lockname)		\
-	SPIN_DEP_MAP_INIT(lockname) }
+#define __RAW_SPIN_LOCK_INITIALIZER(lockname, f)	\
+	{						\
+	.raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,		\
+	SPIN_DEBUG_INIT(lockname)			\
+	SPIN_DEP_MAP_INIT(lockname, f) }
 
 #define __RAW_SPIN_LOCK_UNLOCKED(lockname)	\
-	(raw_spinlock_t) __RAW_SPIN_LOCK_INITIALIZER(lockname)
+	(raw_spinlock_t) __RAW_SPIN_LOCK_INITIALIZER(lockname, 0)
+
+#define __RAW_TERMINAL_SPIN_LOCK_UNLOCKED(lockname)	\
+	(raw_spinlock_t) __RAW_SPIN_LOCK_INITIALIZER(lockname, \
+						     LOCKDEP_FLAG_TERMINAL)
 
 #define DEFINE_RAW_SPINLOCK(x)	raw_spinlock_t x = __RAW_SPIN_LOCK_UNLOCKED(x)
+#define DEFINE_RAW_TERMINAL_SPINLOCK(x)	\
+		raw_spinlock_t x = __RAW_TERMINAL_SPIN_LOCK_UNLOCKED(x)
 
 typedef struct spinlock {
 	union {
@@ -72,13 +79,18 @@
 	};
 } spinlock_t;
 
-#define __SPIN_LOCK_INITIALIZER(lockname) \
-	{ { .rlock = __RAW_SPIN_LOCK_INITIALIZER(lockname) } }
+#define __SPIN_LOCK_INITIALIZER(lockname, f) \
+	{ { .rlock = __RAW_SPIN_LOCK_INITIALIZER(lockname, f) } }
 
 #define __SPIN_LOCK_UNLOCKED(lockname) \
-	(spinlock_t ) __SPIN_LOCK_INITIALIZER(lockname)
+	(spinlock_t) __SPIN_LOCK_INITIALIZER(lockname, 0)
+
+#define __TERMINAL_SPIN_LOCK_UNLOCKED(lockname) \
+	(spinlock_t) __SPIN_LOCK_INITIALIZER(lockname, LOCKDEP_FLAG_TERMINAL)
 
 #define DEFINE_SPINLOCK(x)	spinlock_t x = __SPIN_LOCK_UNLOCKED(x)
+#define DEFINE_TERMINAL_SPINLOCK(x) \
+				spinlock_t x = __TERMINAL_SPIN_LOCK_UNLOCKED(x)
 
 #include <linux/rwlock_types.h>
 
diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
index 0913b4d..8ff1033 100644
--- a/kernel/printk/printk_safe.c
+++ b/kernel/printk/printk_safe.c
@@ -192,7 +192,7 @@ static void report_message_lost(struct printk_safe_seq_buf *s)
 static void __printk_safe_flush(struct irq_work *work)
 {
 	static raw_spinlock_t read_lock =
-		__RAW_SPIN_LOCK_INITIALIZER(read_lock);
+		__RAW_SPIN_LOCK_UNLOCKED(read_lock);
 	struct printk_safe_seq_buf *s =
 		container_of(work, struct printk_safe_seq_buf, work);
 	unsigned long flags;
-- 
1.8.3.1
