Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E13636B0270
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 12:34:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w74so51260wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 09:34:59 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 63si34745wmq.251.2017.12.12.09.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 09:34:58 -0800 (PST)
Message-Id: <20171212173334.345422294@linutronix.de>
Date: Tue, 12 Dec 2017 18:32:34 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 13/16] x86/ldt: Introduce LDT write fault handler
References: <20171212173221.496222173@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-ldt--Introduce-LDT-fault-handler.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org

From: Thomas Gleixner <tglx@linutronix.de>

When the LDT is mapped RO, the CPU will write fault the first time it uses
a segment descriptor in order to set the ACCESS bit (for some reason it
doesn't always observe that it already preset). Catch the fault and set the
ACCESS bit in the handler.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/include/asm/mmu_context.h |    7 +++++++
 arch/x86/kernel/ldt.c              |   30 ++++++++++++++++++++++++++++++
 arch/x86/mm/fault.c                |   19 +++++++++++++++++++
 3 files changed, 56 insertions(+)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -76,6 +76,11 @@ static inline void init_new_context_ldt(
 int ldt_dup_context(struct mm_struct *oldmm, struct mm_struct *mm);
 void ldt_exit_user(struct pt_regs *regs);
 void destroy_context_ldt(struct mm_struct *mm);
+bool __ldt_write_fault(unsigned long address);
+static inline bool ldt_is_active(struct mm_struct *mm)
+{
+	return mm && mm->context.ldt != NULL;
+}
 #else	/* CONFIG_MODIFY_LDT_SYSCALL */
 static inline void init_new_context_ldt(struct task_struct *task,
 					struct mm_struct *mm) { }
@@ -86,6 +91,8 @@ static inline int ldt_dup_context(struct
 }
 static inline void ldt_exit_user(struct pt_regs *regs) { }
 static inline void destroy_context_ldt(struct mm_struct *mm) { }
+static inline bool __ldt_write_fault(unsigned long address) { return false; }
+static inline bool ldt_is_active(struct mm_struct *mm)  { return false; }
 #endif
 
 static inline void load_mm_ldt(struct mm_struct *mm, struct task_struct *tsk)
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -82,6 +82,36 @@ static void ldt_install_mm(struct mm_str
 	mutex_unlock(&mm->context.lock);
 }
 
+/*
+ * ldt_write_fault() already checked whether there is an ldt installed in
+ * __do_page_fault(), so it's safe to access it here because interrupts are
+ * disabled and any ipi which would change it is blocked until this
+ * returns.  The underlying page mapping cannot change as long as the ldt
+ * is the active one in the context.
+ *
+ * The fault error code is X86_PF_WRITE | X86_PF_PROT and checked in
+ * __do_page_fault() already. This happens when a segment is selected and
+ * the CPU tries to set the accessed bit in desc_struct.type because the
+ * LDT entries are mapped RO. Set it manually.
+ */
+bool __ldt_write_fault(unsigned long address)
+{
+	struct ldt_struct *ldt = current->mm->context.ldt;
+	unsigned long start, end, entry;
+	struct desc_struct *desc;
+
+	start = (unsigned long) ldt->entries;
+	end = start + ldt->nr_entries * LDT_ENTRY_SIZE;
+
+	if (address < start || address >= end)
+		return false;
+
+	desc = (struct desc_struct *) ldt->entries;
+	entry = (address - start) / LDT_ENTRY_SIZE;
+	desc[entry].type |= 0x01;
+	return true;
+}
+
 /* The caller must call finalize_ldt_struct on the result. LDT starts zeroed. */
 static struct ldt_struct *alloc_ldt_struct(unsigned int num_entries)
 {
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1234,6 +1234,22 @@ static inline bool smap_violation(int er
 }
 
 /*
+ * Handles the case where the CPU fails to set the accessed bit in a LDT
+ * entry because the entries are mapped RO.
+ */
+static inline bool ldt_write_fault(unsigned long ecode, unsigned long address,
+				   struct pt_regs *regs)
+{
+	if (!IS_ENABLED(CONFIG_MODIFY_LDT_SYSCALL))
+		return false;
+	if (!ldt_is_active(current->mm))
+		return false;
+	if (ecode != (X86_PF_WRITE | X86_PF_PROT))
+		return false;
+	return __ldt_write_fault(address);
+}
+
+/*
  * This routine handles page faults.  It determines the address,
  * and the problem, and then passes it off to one of the appropriate
  * routines.
@@ -1305,6 +1321,9 @@ static noinline void
 	if (unlikely(kprobes_fault(regs)))
 		return;
 
+	if (unlikely(ldt_write_fault(error_code, address, regs)))
+		return;
+
 	if (unlikely(error_code & X86_PF_RSVD))
 		pgtable_bad(regs, error_code, address);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
