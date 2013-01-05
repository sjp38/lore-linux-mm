Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E00466B0070
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 19:35:04 -0500 (EST)
Date: Sat, 5 Jan 2013 01:34:55 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH 1/2] lockdep, rwsem: provide down_write_nest_lock()
In-Reply-To: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
Message-ID: <alpine.LNX.2.00.1301050134420.2946@pobox.suse.cz>
References: <alpine.LNX.2.00.1301041317150.9143@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

down_write_nest_lock() provides means to annotate locking scenario where 
an outter lock is guaranteed to serialize the order nested locks are being 
acquired.

This is an analogy to already existing mutex_lock_nest_lock() and
spin_lock_nest_lock().

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 include/linux/lockdep.h |    3 +++
 include/linux/rwsem.h   |    9 +++++++++
 kernel/rwsem.c          |   10 ++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 00e4637..2bca44b 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -524,14 +524,17 @@ static inline void print_irqtrace_events(struct task_struct *curr)
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 # ifdef CONFIG_PROVE_LOCKING
 #  define rwsem_acquire(l, s, t, i)		lock_acquire(l, s, t, 0, 2, NULL, i)
+#  define rwsem_acquire_nest(l, s, t, n, i)	lock_acquire(l, s, t, 0, 2, n, i)
 #  define rwsem_acquire_read(l, s, t, i)	lock_acquire(l, s, t, 1, 2, NULL, i)
 # else
 #  define rwsem_acquire(l, s, t, i)		lock_acquire(l, s, t, 0, 1, NULL, i)
+#  define rwsem_acquire_nest(l, s, t, n, i)	lock_acquire(l, s, t, 0, 1, n, i)
 #  define rwsem_acquire_read(l, s, t, i)	lock_acquire(l, s, t, 1, 1, NULL, i)
 # endif
 # define rwsem_release(l, n, i)			lock_release(l, n, i)
 #else
 # define rwsem_acquire(l, s, t, i)		do { } while (0)
+# define rwsem_acquire_nest(l, s, t, n, i)	do { } while (0)
 # define rwsem_acquire_read(l, s, t, i)		do { } while (0)
 # define rwsem_release(l, n, i)			do { } while (0)
 #endif
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 54bd7cd..413cc11 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -125,8 +125,17 @@ extern void downgrade_write(struct rw_semaphore *sem);
  */
 extern void down_read_nested(struct rw_semaphore *sem, int subclass);
 extern void down_write_nested(struct rw_semaphore *sem, int subclass);
+extern void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest_lock);
+
+# define down_write_nest_lock(sem, nest_lock)			\
+do {								\
+	typecheck(struct lockdep_map *, &(nest_lock)->dep_map);	\
+	_down_write_nest_lock(sem, &(nest_lock)->dep_map);	\
+} while (0);
+
 #else
 # define down_read_nested(sem, subclass)		down_read(sem)
+# define down_write_nest_lock(sem, nest_lock)	down_read(sem)
 # define down_write_nested(sem, subclass)	down_write(sem)
 #endif
 
diff --git a/kernel/rwsem.c b/kernel/rwsem.c
index 6850f53..b3c6c3f 100644
--- a/kernel/rwsem.c
+++ b/kernel/rwsem.c
@@ -116,6 +116,16 @@ void down_read_nested(struct rw_semaphore *sem, int subclass)
 
 EXPORT_SYMBOL(down_read_nested);
 
+void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
+{
+	might_sleep();
+	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
+
+	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+}
+
+EXPORT_SYMBOL(_down_write_nest_lock);
+
 void down_write_nested(struct rw_semaphore *sem, int subclass)
 {
 	might_sleep();
-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
