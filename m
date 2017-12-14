Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3496B025F
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t65so4478275pfe.22
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u1si2787868pgv.481.2017.12.14.03.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.797295832@infradead.org>
Date: Thu, 14 Dec 2017 12:27:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 14/17] x86/ldt: Reshuffle code
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=x86-ldt--Reshuffle-code.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

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
@@ -48,18 +54,31 @@ static void refresh_ldt_segments(void)
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
@@ -131,6 +132,18 @@ static void free_ldt_struct(struct ldt_s
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
  * Called on fork from arch_dup_mmap(). Just copy the current LDT state,
  * the new task is not running, so nothing can be installed.
  */
@@ -163,54 +176,33 @@ int ldt_dup_context(struct mm_struct *ol
 	return retval;
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
@@ -287,7 +279,7 @@ static int write_ldt(void __user *ptr, u
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
