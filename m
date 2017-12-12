Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0426B0266
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:51 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v69so12713991wrb.3
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:51 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id w14si13032616wra.173.2017.12.12.09.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:50 -0800 (PST)
Message-Id: <20171212173334.267560774@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:33 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 12/16] x86/ldt: Reshuffle code
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=x86-ldt--Reshuffle-code.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

Restructure the code, so the following VMA changes do not create an
unreadable mess. No functional change.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/mmu_context.h |    4 +
 arch/x86/kernel/ldt.c              |  118 +++++++++++++++++--------------------
 2 files changed, 59 insertions(+), 63 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -39,6 +39,10 @@ static inline void load_mm_cr4(struct mm
 #endif
 
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
+#include <asm/ldt.h>
+
+#define LDT_ENTRIES_MAP_SIZE	(LDT_ENTRIES * LDT_ENTRY_SIZE)
+
 /*
  * ldt_structs can be allocated, used, and freed, but they are never
  * modified while live.
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -28,6 +28,12 @@
 #include <asm/mmu_context.h>
 #include <asm/syscalls.h>
 
+/* After calling this, the LDT is immutable. */
+static void finalize_ldt_struct(struct ldt_struct *ldt)
+{
+	paravirt_alloc_ldt(ldt->entries, ldt->nr_entries);
+}
+
 static void refresh_ldt_segments(void)
 {
 #ifdef CONFIG_X86_64
@@ -48,18 +54,32 @@ static void refresh_ldt_segments(void)
 }
 
 /* context.lock is held by the task which issued the smp function call */
-static void flush_ldt(void *__mm)
+static void __ldt_install(void *__mm)
 {
 	struct mm_struct *mm = __mm;
-	mm_context_t *pc;
+	struct ldt_struct *ldt = mm->context.ldt;
 
-	if (this_cpu_read(cpu_tlbstate.loaded_mm) != mm)
-		return;
+	if (this_cpu_read(cpu_tlbstate.loaded_mm) == mm &&
+	    !(current->flags & PF_KTHREAD)) {
+		unsigned int nentries = ldt ? ldt->nr_entries : 0;
+
+		set_ldt(ldt->entries, nentries);
+		refresh_ldt_segments();
+		set_tsk_thread_flag(current, TIF_LDT);
+	}
+}
 
-	pc = &mm->context;
-	set_ldt(pc->ldt->entries, pc->ldt->nr_entries);
+static void ldt_install_mm(struct mm_struct *mm, struct ldt_struct *ldt)
+{
+	mutex_lock(&mm->context.lock);
 
-	refresh_ldt_segments();
+	/* Synchronizes with READ_ONCE in load_mm_ldt. */
+	smp_store_release(&mm->context.ldt, ldt);
+
+	/* Activate the LDT for all CPUs using currents mm. */
+	on_each_cpu_mask(mm_cpumask(mm), __ldt_install, mm, true);
+
+	mutex_unlock(&mm->context.lock);
 }
 
 /* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
@@ -98,25 +118,6 @@ static struct ldt_struct *alloc_ldt_stru
 	return new_ldt;
 }
 
-/* After calling this, the LDT is immutable. */
-static void finalize_ldt_struct(struct ldt_struct *ldt)
-{
-	paravirt_alloc_ldt(ldt->entries, ldt->nr_entries);
-}
-
-static void install_ldt(struct mm_struct *mm, struct ldt_struct *ldt)
-{
-	mutex_lock(&mm->context.lock);
-
-	/* Synchronizes with READ_ONCE in load_mm_ldt. */
-	smp_store_release(&mm->context.ldt, ldt);
-
-	/* Activate the LDT for all CPUs using currents mm. */
-	on_each_cpu_mask(mm_cpumask(mm), flush_ldt, mm, true);
-
-	mutex_unlock(&mm->context.lock);
-}
-
 static void free_ldt_struct(struct ldt_struct *ldt)
 {
 	if (likely(!ldt))
@@ -164,6 +165,18 @@ int ldt_dup_context(struct mm_struct *ol
 }
 
 /*
+ * This can run unlocked because the mm is no longer in use. No need to
+ * clear LDT on the CPU either because that's called from __mm_drop() and
+ * the task which owned the mm is already dead. The context switch code has
+ * either cleared LDT or installed a new one.
+ */
+void destroy_context_ldt(struct mm_struct *mm)
+{
+	free_ldt_struct(mm->context.ldt);
+	mm->context.ldt = NULL;
+}
+
+/*
  * Touching the LDT entries with LAR makes sure that the CPU "caches" the
  * ACCESSED bit in the LDT entry which is already set when the entry is
  * stored.
@@ -193,54 +206,33 @@ void ldt_exit_user(struct pt_regs *regs)
 	ldt_touch_seg(regs->ss);
 }
 
-/*
- * No need to lock the MM as we are the last user
- *
- * 64bit: Don't touch the LDT register - we're already in the next thread.
- */
-void destroy_context_ldt(struct mm_struct *mm)
-{
-	free_ldt_struct(mm->context.ldt);
-	mm->context.ldt = NULL;
-}
-
-static int read_ldt(void __user *ptr, unsigned long bytecount)
+static int read_ldt(void __user *ptr, unsigned long nbytes)
 {
 	struct mm_struct *mm = current->mm;
-	unsigned long entries_size;
-	int retval;
+	struct ldt_struct *ldt;
+	unsigned long tocopy;
+	int ret = 0;
 
 	down_read(&mm->context.ldt_usr_sem);
 
-	if (!mm->context.ldt) {
-		retval = 0;
+	ldt = mm->context.ldt;
+	if (!ldt)
 		goto out_unlock;
-	}
 
-	if (bytecount > LDT_ENTRY_SIZE * LDT_ENTRIES)
-		bytecount = LDT_ENTRY_SIZE * LDT_ENTRIES;
+	if (nbytes > LDT_ENTRIES_MAP_SIZE)
+		nbytes = LDT_ENTRIES_MAP_SIZE;
 
-	entries_size = mm->context.ldt->nr_entries * LDT_ENTRY_SIZE;
-	if (entries_size > bytecount)
-		entries_size = bytecount;
-
-	if (copy_to_user(ptr, mm->context.ldt->entries, entries_size)) {
-		retval = -EFAULT;
+	ret = -EFAULT;
+	tocopy = min((unsigned long)ldt->nr_entries * LDT_ENTRY_SIZE, nbytes);
+	if (tocopy < nbytes && clear_user(ptr + tocopy, nbytes - tocopy))
 		goto out_unlock;
-	}
-
-	if (entries_size != bytecount) {
-		/* Zero-fill the rest and pretend we read bytecount bytes. */
-		if (clear_user(ptr + entries_size, bytecount - entries_size)) {
-			retval = -EFAULT;
-			goto out_unlock;
-		}
-	}
-	retval = bytecount;
 
+	if (copy_to_user(ptr, ldt->entries, tocopy))
+		goto out_unlock;
+	ret = nbytes;
 out_unlock:
 	up_read(&mm->context.ldt_usr_sem);
-	return retval;
+	return ret;
 }
 
 static int read_default_ldt(void __user *ptr, unsigned long bytecount)
@@ -317,7 +309,7 @@ static int write_ldt(void __user *ptr, u
 	new_ldt->entries[ldt_info.entry_number] = ldt;
 	finalize_ldt_struct(new_ldt);
 
-	install_ldt(mm, new_ldt);
+	ldt_install_mm(mm, new_ldt);
 	free_ldt_struct(old_ldt);
 	error = 0;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
