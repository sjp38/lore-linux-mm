Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D785E6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so41118wmc.6
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:45 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 91si13145634wrf.176.2017.12.12.09.34.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:44 -0800 (PST)
Message-Id: <20171212173333.429772742@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:23 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 02/16] x86/ldt: Rework locking
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=x86-ldt--Rework-locking.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

The LDT is duplicated on fork() and on exec(), which is wrong as exec()
should start from a clean state, i.e. without LDT. To fix this the LDT
duplication code will be moved into arch_dup_mmap() which is only called
for fork().

This introduces a locking problem. arch_dup_mmap() holds mmap_sem of the
parent process, but the LDT duplication code needs to acquire
mm->context.lock to access the LDT data safely, which is the reverse lock
order of write_ldt() where mmap_sem nests into context.lock.

Solve this by introducing a new rw semaphore which serializes the
read/write_ldt() syscall operations and use context.lock to protect the
actual installment of the LDT descriptor.

So context.lock stabilizes mm->context.ldt and can nest inside of the new
semaphore or mmap_sem.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/mmu.h         |    4 +++-
 arch/x86/include/asm/mmu_context.h |    2 ++
 arch/x86/kernel/ldt.c              |   33 +++++++++++++++++++++------------
 3 files changed, 26 insertions(+), 13 deletions(-)

--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -3,6 +3,7 @@
 #define _ASM_X86_MMU_H
 
 #include <linux/spinlock.h>
+#include <linux/rwsem.h>
 #include <linux/mutex.h>
 #include <linux/atomic.h>
 
@@ -27,7 +28,8 @@ typedef struct {
 	atomic64_t tlb_gen;
 
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
-	struct ldt_struct *ldt;
+	struct rw_semaphore	ldt_usr_sem;
+	struct ldt_struct	*ldt;
 #endif
 
 #ifdef CONFIG_X86_64
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -132,6 +132,8 @@ void enter_lazy_tlb(struct mm_struct *mm
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	mutex_init(&mm->context.lock);
+
 	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	atomic64_set(&mm->context.tlb_gen, 0);
 
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -5,6 +5,11 @@
  * Copyright (C) 2002 Andi Kleen
  *
  * This handles calls from both 32bit and 64bit mode.
+ *
+ * Lock order:
+ *	contex.ldt_usr_sem
+ *	  mmap_sem
+ *	    context.lock
  */
 
 #include <linux/errno.h>
@@ -42,7 +47,7 @@ static void refresh_ldt_segments(void)
 #endif
 }
 
-/* context.lock is held for us, so we don't need any locking. */
+/* context.lock is held by the task which issued the smp function call */
 static void flush_ldt(void *__mm)
 {
 	struct mm_struct *mm = __mm;
@@ -99,15 +104,17 @@ static void finalize_ldt_struct(struct l
 	paravirt_alloc_ldt(ldt->entries, ldt->nr_entries);
 }
 
-/* context.lock is held */
-static void install_ldt(struct mm_struct *current_mm,
-			struct ldt_struct *ldt)
+static void install_ldt(struct mm_struct *mm, struct ldt_struct *ldt)
 {
+	mutex_lock(&mm->context.lock);
+
 	/* Synchronizes with READ_ONCE in load_mm_ldt. */
-	smp_store_release(&current_mm->context.ldt, ldt);
+	smp_store_release(&mm->context.ldt, ldt);
 
-	/* Activate the LDT for all CPUs using current_mm. */
-	on_each_cpu_mask(mm_cpumask(current_mm), flush_ldt, current_mm, true);
+	/* Activate the LDT for all CPUs using currents mm. */
+	on_each_cpu_mask(mm_cpumask(mm), flush_ldt, mm, true);
+
+	mutex_unlock(&mm->context.lock);
 }
 
 static void free_ldt_struct(struct ldt_struct *ldt)
@@ -133,7 +140,8 @@ int init_new_context_ldt(struct task_str
 	struct mm_struct *old_mm;
 	int retval = 0;
 
-	mutex_init(&mm->context.lock);
+	init_rwsem(&mm->context.ldt_usr_sem);
+
 	old_mm = current->mm;
 	if (!old_mm) {
 		mm->context.ldt = NULL;
@@ -180,7 +188,7 @@ static int read_ldt(void __user *ptr, un
 	unsigned long entries_size;
 	int retval;
 
-	mutex_lock(&mm->context.lock);
+	down_read(&mm->context.ldt_usr_sem);
 
 	if (!mm->context.ldt) {
 		retval = 0;
@@ -209,7 +217,7 @@ static int read_ldt(void __user *ptr, un
 	retval = bytecount;
 
 out_unlock:
-	mutex_unlock(&mm->context.lock);
+	up_read(&mm->context.ldt_usr_sem);
 	return retval;
 }
 
@@ -269,7 +277,8 @@ static int write_ldt(void __user *ptr, u
 			ldt.avl = 0;
 	}
 
-	mutex_lock(&mm->context.lock);
+	if (down_write_killable(&mm->context.ldt_usr_sem))
+		return -EINTR;
 
 	old_ldt       = mm->context.ldt;
 	old_nr_entries = old_ldt ? old_ldt->nr_entries : 0;
@@ -291,7 +300,7 @@ static int write_ldt(void __user *ptr, u
 	error = 0;
 
 out_unlock:
-	mutex_unlock(&mm->context.lock);
+	up_write(&mm->context.ldt_usr_sem);
 out:
 	return error;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
