Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02CDD6B000D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:46:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so270646pgv.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 05:46:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z20-v6si9746580pfj.337.2018.07.23.05.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 05:46:11 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 038/107] x86/mm: Give each mm TLB flush generation a unique ID
Date: Mon, 23 Jul 2018 14:41:32 +0200
Message-Id: <20180723122414.789067704@linuxfoundation.org>
In-Reply-To: <20180723122413.003644357@linuxfoundation.org>
References: <20180723122413.003644357@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>, "Matt Helsley (VMware)" <matt.helsley@gmail.com>, Alexey Makhalov <amakhalov@vmware.com>, Bo Gan <ganb@vmware.com>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit f39681ed0f48498b80455095376f11535feea332 upstream.

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
Signed-off-by: Srivatsa S. Bhat <srivatsa@csail.mit.edu>
Reviewed-by: Matt Helsley (VMware) <matt.helsley@gmail.com>
Reviewed-by: Alexey Makhalov <amakhalov@vmware.com>
Reviewed-by: Bo Gan <ganb@vmware.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

 arch/x86/include/asm/mmu.h         |   15 +++++++++++++--
 arch/x86/include/asm/mmu_context.h |    4 ++++
 arch/x86/mm/tlb.c                  |    2 ++
 3 files changed, 19 insertions(+), 2 deletions(-)

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
@@ -105,6 +108,7 @@ static inline void enter_lazy_tlb(struct
 static inline int init_new_context(struct task_struct *tsk,
 				   struct mm_struct *mm)
 {
+	mm->context.ctx_id = atomic64_inc_return(&last_mm_ctx_id);
 	init_new_context_ldt(tsk, mm);
 	return 0;
 }
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
