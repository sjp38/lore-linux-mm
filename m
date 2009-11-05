Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B9B6F6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:21:13 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5C92182C748
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:27:56 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id s0O2jRCwEOYh for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 15:27:56 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B99DE82C6E1
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:28:29 -0500 (EST)
Date: Thu, 5 Nov 2009 14:20:47 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
 instead
In-Reply-To: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
Message-ID: <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

From: Christoph Lamter <cl@linux-foundation.org>
Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter instead

Instead of a rw semaphore use a mutex and a per cpu counter for the number
of the current readers. read locking then becomes very cheap requiring only
the increment of a per cpu counter.

Write locking is more expensive since the writer must scan the percpu array
and wait until all readers are complete. Since the readers are not holding
semaphores we have no wait queue from which the writer could wakeup. In this
draft we simply wait for one millisecond between scans of the percpu
array. A different solution must be found there.

Patch is on top of -next and the percpu counter patches that I posted
yesterday. The patch adds another per cpu counter to the file and anon rss
counters.

Signed-off-by: Christoph Lamter <cl@linux-foundation.org>

---
 include/linux/mm_types.h |   68 ++++++++++++++++++++++++++++++++++++++---------
 mm/init-mm.c             |    2 -
 2 files changed, 56 insertions(+), 14 deletions(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2009-11-05 13:03:11.000000000 -0600
+++ linux-2.6/include/linux/mm_types.h	2009-11-05 13:06:31.000000000 -0600
@@ -14,6 +14,7 @@
 #include <linux/page-debug-flags.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
+#include <linux/percpu.h>

 #ifndef AT_VECTOR_SIZE_ARCH
 #define AT_VECTOR_SIZE_ARCH 0
@@ -27,6 +28,7 @@ struct address_space;
 struct mm_counter {
 	long file;
 	long anon;
+	long readers;
 };

 /*
@@ -214,7 +216,7 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
-	struct rw_semaphore sem;
+	struct mutex lock;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */

 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
@@ -285,64 +287,104 @@ struct mm_struct {
 #endif
 };

+static inline int mm_readers(struct mm_struct *mm)
+{
+	int cpu;
+	int readers = 0;
+
+	for_each_possible_cpu(cpu)
+		readers += per_cpu(mm->rss->readers, cpu);
+
+	return readers;
+}
+
 static inline void mm_reader_lock(struct mm_struct *mm)
 {
-	down_read(&mm->sem);
+redo:
+	this_cpu_inc(mm->rss->readers);
+	if (mutex_is_locked(&mm->lock)) {
+		this_cpu_dec(mm->rss->readers);
+		/* Need to wait till mutex is released */
+		mutex_lock(&mm->lock);
+		mutex_unlock(&mm->lock);
+		goto redo;
+	}
 }

 static inline void mm_reader_unlock(struct mm_struct *mm)
 {
-	up_read(&mm->sem);
+	this_cpu_dec(mm->rss->readers);
 }

 static inline int mm_reader_trylock(struct mm_struct *mm)
 {
-	return down_read_trylock(&mm->sem);
+	this_cpu_inc(mm->rss->readers);
+	if (mutex_is_locked(&mm->lock)) {
+		this_cpu_dec(mm->rss->readers);
+		return 0;
+	}
+	return 1;
 }

 static inline void mm_writer_lock(struct mm_struct *mm)
 {
-	down_write(&mm->sem);
+redo:
+	mutex_lock(&mm->lock);
+	if (mm_readers(mm) == 0)
+		return;
+
+	mutex_unlock(&mm->lock);
+	msleep(1);
+	goto redo;
 }

 static inline void mm_writer_unlock(struct mm_struct *mm)
 {
-	up_write(&mm->sem);
+	mutex_unlock(&mm->lock);
 }

 static inline int mm_writer_trylock(struct mm_struct *mm)
 {
-	return down_write_trylock(&mm->sem);
+	if (!mutex_trylock(&mm->lock))
+		goto fail;
+
+	if (mm_readers(mm) == 0)
+		return 1;
+
+	mutex_unlock(&mm->lock);
+fail:
+	return 0;
 }

 static inline int mm_locked(struct mm_struct *mm)
 {
-	return rwsem_is_locked(&mm->sem);
+	return mutex_is_locked(&mm->lock) || mm_readers(mm);
 }

 static inline void mm_writer_to_reader_lock(struct mm_struct *mm)
 {
-	downgrade_write(&mm->sem);
+	this_cpu_inc(mm->rss->readers);
+	mutex_unlock(&mm->lock);
 }

 static inline void mm_writer_lock_nested(struct mm_struct *mm, int x)
 {
-	down_write_nested(&mm->sem, x);
+	mutex_lock_nested(&mm->lock, x);
 }

 static inline void mm_lock_init(struct mm_struct *mm)
 {
-	init_rwsem(&mm->sem);
+	mutex_init(&mm->lock);
 }

 static inline void mm_lock_prefetch(struct mm_struct *mm)
 {
-	prefetchw(&mm->sem);
+	prefetchw(&mm->lock);
 }

 static inline void mm_nest_lock(spinlock_t *s, struct mm_struct *mm)
 {
-	spin_lock_nest_lock(s, &mm->sem);
+	spin_lock_nest_lock(s, &mm->lock);
 }

 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: linux-2.6/mm/init-mm.c
===================================================================
--- linux-2.6.orig/mm/init-mm.c	2009-11-05 13:02:54.000000000 -0600
+++ linux-2.6/mm/init-mm.c	2009-11-05 13:03:22.000000000 -0600
@@ -15,7 +15,7 @@ struct mm_struct init_mm = {
 	.pgd		= swapper_pg_dir,
 	.mm_users	= ATOMIC_INIT(2),
 	.mm_count	= ATOMIC_INIT(1),
-	.sem		= __RWSEM_INITIALIZER(init_mm.sem),
+	.lock		= __MUTEX_INITIALIZER(init_mm.lock),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	.cpu_vm_mask	= CPU_MASK_ALL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
