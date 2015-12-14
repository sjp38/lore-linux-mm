Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA196B0273
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:42 -0500 (EST)
Received: by pfbu66 with SMTP id u66so65620667pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:42 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id t74si18779133pfa.170.2015.12.14.11.06.27
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:27 -0800 (PST)
Subject: [PATCH 27/32] x86: separate out LDT init from context init
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:26 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190626.26611062@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The arch-specific mm_context_t is a great place to put
protection-key allocation state.

But, we need to initialize the allocation state because pkey 0 is
always "allocated".  All of the runtime initialization of
mm_context_t is done in *_ldt() manipulation functions.  This
renames the existing LDT functions like this:

	init_new_context() -> init_new_context_ldt()
	destroy_context() -> destroy_context_ldt()

and makes init_new_context() and destroy_context() available for
generic use.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/mmu_context.h |   21 ++++++++++++++++-----
 b/arch/x86/kernel/ldt.c              |    4 ++--
 2 files changed, 18 insertions(+), 7 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~pkeys-72-init-ldt-extricate arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~pkeys-72-init-ldt-extricate	2015-12-14 10:42:51.088174309 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-14 10:42:51.093174534 -0800
@@ -52,15 +52,15 @@ struct ldt_struct {
 /*
  * Used for LDT copy/destruction.
  */
-int init_new_context(struct task_struct *tsk, struct mm_struct *mm);
-void destroy_context(struct mm_struct *mm);
+int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm);
+void destroy_context_ldt(struct mm_struct *mm);
 #else	/* CONFIG_MODIFY_LDT_SYSCALL */
-static inline int init_new_context(struct task_struct *tsk,
-				   struct mm_struct *mm)
+static inline int init_new_context_ldt(struct task_struct *tsk,
+				       struct mm_struct *mm)
 {
 	return 0;
 }
-static inline void destroy_context(struct mm_struct *mm) {}
+static inline void destroy_context_ldt(struct mm_struct *mm) {}
 #endif
 
 static inline void load_mm_ldt(struct mm_struct *mm)
@@ -104,6 +104,17 @@ static inline void enter_lazy_tlb(struct
 #endif
 }
 
+static inline int init_new_context(struct task_struct *tsk,
+				   struct mm_struct *mm)
+{
+	init_new_context_ldt(tsk, mm);
+	return 0;
+}
+static inline void destroy_context(struct mm_struct *mm)
+{
+	destroy_context_ldt(mm);
+}
+
 static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			     struct task_struct *tsk)
 {
diff -puN arch/x86/kernel/ldt.c~pkeys-72-init-ldt-extricate arch/x86/kernel/ldt.c
--- a/arch/x86/kernel/ldt.c~pkeys-72-init-ldt-extricate	2015-12-14 10:42:51.090174399 -0800
+++ b/arch/x86/kernel/ldt.c	2015-12-14 10:42:51.094174578 -0800
@@ -103,7 +103,7 @@ static void free_ldt_struct(struct ldt_s
  * we do not have to muck with descriptors here, that is
  * done in switch_mm() as needed.
  */
-int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
+int init_new_context_ldt(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct ldt_struct *new_ldt;
 	struct mm_struct *old_mm;
@@ -144,7 +144,7 @@ out_unlock:
  *
  * 64bit: Don't touch the LDT register - we're already in the next thread.
  */
-void destroy_context(struct mm_struct *mm)
+void destroy_context_ldt(struct mm_struct *mm)
 {
 	free_ldt_struct(mm->context.ldt);
 	mm->context.ldt = NULL;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
