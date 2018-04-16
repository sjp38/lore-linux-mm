Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF9216B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 03:04:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n10so762293pgq.3
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 00:04:22 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b3si9127617pgc.479.2018.04.16.00.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 00:04:21 -0700 (PDT)
From: Youquan Song <youquan.song@intel.com>
Subject: [PATCH 11/23] x86/mm: Give each mm TLB flush generation a unique ID
Date: Mon, 16 Apr 2018 14:32:50 -0400
Message-Id: <1523903583-14881-11-git-send-email-youquan.song@intel.com>
In-Reply-To: <1523903583-14881-1-git-send-email-youquan.song@intel.com>
References: <1523903583-14881-1-git-send-email-youquan.song@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: youquan.song@intel.com
Cc: youquan.song@linux.intel.com, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

From: Andy Lutomirski <luto@kernel.org>

(cherry picked from commit f39681ed0f48498b80455095376f11535feea332)

This adds two new variables to mmu_context_t: ctx_id and tlb_gen.
ctx_id uniquely identifies the mm_struct and will never be reused.
For a given mm_struct (and hence ctx_id), tlb_gen is a monotonic
count of the number of times that a TLB flush has been requested.
The pair (ctx_id, tlb_gen) can be used as an identifier for TLB
flush actions and will be used in subsequent patches to reliably
determine whether all needed TLB flushes have occurred on a given
CPU.

This patch is split out for ease of review.  By itself, it has no
real effect other than creating and updating the new variables.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/413a91c24dab3ed0caa5f4e4d017d87b0857f920.1498751203.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
[Youquan Song: port to 4.4]
Signed-off-by: Youquan Song <youquan.song@linux.intel.com>
---
 arch/x86/include/asm/mmu.h         | 15 +++++++++++++--
 arch/x86/include/asm/mmu_context.h |  4 ++++
 arch/x86/kernel/ldt.c              |  1 +
 arch/x86/mm/tlb.c                  |  2 ++
 4 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index 7680b76..3359dfe 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -3,12 +3,18 @@
 
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
+#include <linux/atomic.h>
 
 /*
- * The x86 doesn't have a mmu context, but
- * we put the segment information here.
+ * x86 has arch-specific MMU state beyond what lives in mm_struct.
  */
 typedef struct {
+	/*
+	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
+	 * be reused, and zero is not a valid ctx_id.
+	 */
+	u64 ctx_id;
+
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	struct ldt_struct *ldt;
 #endif
@@ -24,6 +30,11 @@ typedef struct {
 	atomic_t perf_rdpmc_allowed;	/* nonzero if rdpmc is allowed */
 } mm_context_t;
 
+#define INIT_MM_CONTEXT(mm)						\
+	.context = {							\
+		.ctx_id = 1,						\
+	}
+
 void leave_mm(int cpu);
 
 #endif /* _ASM_X86_MMU_H */
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 9bfc5fd..24bc41a 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -11,6 +11,9 @@
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
 #include <asm/mpx.h>
+
+extern atomic64_t last_mm_ctx_id;
+
 #ifndef CONFIG_PARAVIRT
 static inline void paravirt_activate_mm(struct mm_struct *prev,
 					struct mm_struct *next)
@@ -58,6 +61,7 @@ void destroy_context(struct mm_struct *mm);
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	return 0;
 }
 static inline void destroy_context(struct mm_struct *mm) {}
diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index bc42936..323590e 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -125,6 +125,7 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	struct mm_struct *old_mm;
 	int retval = 0;
 
+	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	mutex_init(&mm->context.lock);
 	old_mm = current->mm;
 	if (!old_mm) {
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 7cad01af..efec198 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -29,6 +29,8 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
+
 struct flush_tlb_info {
 	struct mm_struct *flush_mm;
 	unsigned long flush_start;
-- 
1.9.1
