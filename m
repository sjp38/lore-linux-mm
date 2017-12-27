Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 360E76B0275
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:49:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id o16so10008185wmf.4
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:49:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 89si12915222wrg.320.2017.12.27.08.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:49:33 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 16/74] x86/ldt: Prevent LDT inheritance on exec
Date: Wed, 27 Dec 2017 17:45:49 +0100
Message-Id: <20171227164614.757983636@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bpetkov@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, dan.j.williams@intel.com, hughd@google.com, keescook@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Thomas Gleixner <tglx@linutronix.de>

commit a4828f81037f491b2cc986595e3a969a6eeb2fb5 upstream.

The LDT is inherited across fork() or exec(), but that makes no sense
at all because exec() is supposed to start the process clean.

The reason why this happens is that init_new_context_ldt() is called from
init_new_context() which obviously needs to be called for both fork() and
exec().

It would be surprising if anything relies on that behaviour, so it seems to
be safe to remove that misfeature.

Split the context initialization into two parts. Clear the LDT pointer and
initialize the mutex from the general context init and move the LDT
duplication to arch_dup_mmap() which is only called on fork().

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Andy Lutomirsky <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: dan.j.williams@intel.com
Cc: hughd@google.com
Cc: keescook@google.com
Cc: kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/mmu_context.h    |   21 ++++++++++++++-------
 arch/x86/kernel/ldt.c                 |   18 +++++-------------
 tools/testing/selftests/x86/ldt_gdt.c |    9 +++------
 3 files changed, 22 insertions(+), 26 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -57,11 +57,17 @@ struct ldt_struct {
 /*
  * Used for LDT copy/destruction.
  */
-int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm);
+static inline void init_new_context_ldt(struct mm_struct *mm)
+{
+	mm->context.ldt = NULL;
+	init_rwsem(&mm->context.ldt_usr_sem);
+}
+int ldt_dup_context(struct mm_struct *oldmm, struct mm_struct *mm);
 void destroy_context_ldt(struct mm_struct *mm);
 #else	/* CONFIG_MODIFY_LDT_SYSCALL */
-static inline int init_new_context_ldt(struct task_struct *tsk,
-				       struct mm_struct *mm)
+static inline void init_new_context_ldt(struct mm_struct *mm) { }
+static inline int ldt_dup_context(struct mm_struct *oldmm,
+				  struct mm_struct *mm)
 {
 	return 0;
 }
@@ -137,15 +143,16 @@ static inline int init_new_context(struc
 	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	atomic64_set(&mm->context.tlb_gen, 0);
 
-	#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
 	if (cpu_feature_enabled(X86_FEATURE_OSPKE)) {
 		/* pkey 0 is the default and always allocated */
 		mm->context.pkey_allocation_map = 0x1;
 		/* -1 means unallocated or invalid */
 		mm->context.execute_only_pkey = -1;
 	}
-	#endif
-	return init_new_context_ldt(tsk, mm);
+#endif
+	init_new_context_ldt(mm);
+	return 0;
 }
 static inline void destroy_context(struct mm_struct *mm)
 {
@@ -181,7 +188,7 @@ do {						\
 static inline int arch_dup_mmap(struct mm_struct *oldmm, struct mm_struct *mm)
 {
 	paravirt_arch_dup_mmap(oldmm, mm);
-	return 0;
+	return ldt_dup_context(oldmm, mm);
 }
 
 static inline void arch_exit_mmap(struct mm_struct *mm)
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -131,28 +131,20 @@ static void free_ldt_struct(struct ldt_s
 }
 
 /*
- * we do not have to muck with descriptors here, that is
- * done in switch_mm() as needed.
+ * Called on fork from arch_dup_mmap(). Just copy the current LDT state,
+ * the new task is not running, so nothing can be installed.
  */
-int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm)
+int ldt_dup_context(struct mm_struct *old_mm, struct mm_struct *mm)
 {
 	struct ldt_struct *new_ldt;
-	struct mm_struct *old_mm;
 	int retval = 0;
 
-	init_rwsem(&mm->context.ldt_usr_sem);
-
-	old_mm = current->mm;
-	if (!old_mm) {
-		mm->context.ldt = NULL;
+	if (!old_mm)
 		return 0;
-	}
 
 	mutex_lock(&old_mm->context.lock);
-	if (!old_mm->context.ldt) {
-		mm->context.ldt = NULL;
+	if (!old_mm->context.ldt)
 		goto out_unlock;
-	}
 
 	new_ldt = alloc_ldt_struct(old_mm->context.ldt->nr_entries);
 	if (!new_ldt) {
--- a/tools/testing/selftests/x86/ldt_gdt.c
+++ b/tools/testing/selftests/x86/ldt_gdt.c
@@ -627,13 +627,10 @@ static void do_multicpu_tests(void)
 static int finish_exec_test(void)
 {
 	/*
-	 * In a sensible world, this would be check_invalid_segment(0, 1);
-	 * For better or for worse, though, the LDT is inherited across exec.
-	 * We can probably change this safely, but for now we test it.
+	 * Older kernel versions did inherit the LDT on exec() which is
+	 * wrong because exec() starts from a clean state.
 	 */
-	check_valid_segment(0, 1,
-			    AR_DPL3 | AR_TYPE_XRCODE | AR_S | AR_P | AR_DB,
-			    42, true);
+	check_invalid_segment(0, 1);
 
 	return nerrs ? 1 : 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
