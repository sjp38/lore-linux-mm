Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 207DB6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:22:12 -0500 (EST)
Received: by pfbg73 with SMTP id g73so17736688pfb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:22:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 29si15469185pfr.24.2015.12.03.17.15.05
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:15:05 -0800 (PST)
Subject: [PATCH 29/34] x86: separate out LDT init from context init
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:15:04 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011504.49720E0D@viggo.jf.intel.com>
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
---

 b/arch/x86/include/asm/mmu_context.h |   21 ++++++++++++++++-----
 b/arch/x86/kernel/ldt.c              |    4 ++--
 2 files changed, 18 insertions(+), 7 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~init-ldt-extricate arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~init-ldt-extricate	2015-12-03 16:21:31.585941570 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2015-12-03 16:21:31.590941797 -0800
@@ -53,15 +53,15 @@ struct ldt_struct {
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
@@ -105,6 +105,17 @@ static inline void enter_lazy_tlb(struct
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
diff -puN arch/x86/kernel/ldt.c~init-ldt-extricate arch/x86/kernel/ldt.c
--- a/arch/x86/kernel/ldt.c~init-ldt-extricate	2015-12-03 16:21:31.587941660 -0800
+++ b/arch/x86/kernel/ldt.c	2015-12-03 16:21:31.590941797 -0800
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
