Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 261376B0009
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 16:32:30 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id o61-v6so5651812pld.5
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 13:32:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m24si4518132pgd.763.2018.03.02.13.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 13:32:26 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 2/2] x86/speculation: Use Indirect Branch Prediction Barrier in context switch
Date: Fri,  2 Mar 2018 13:32:10 -0800
Message-Id: <e25ad06fecab41d2d6ec82d1164e34f1d581d77d.1520026221.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1520026221.git.tim.c.chen@linux.intel.com>
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1520026221.git.tim.c.chen@linux.intel.com>
References: <cover.1520026221.git.tim.c.chen@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, ak@linux.intel.com, karahmed@amazon.de, pbonzini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@dominikbrodowski.net, gregkh@linux-foundation.org

commit: 18bf3c3ea8ece8f03b6fc58508f2dfd23c7711c7

Flush indirect branches when switching into a process that marked itself
non dumpable. This protects high value processes like gpg better,
without having too high performance overhead.

If done naA?vely, we could switch to a kernel idle thread and then back
to the original process, such as:

    process A -> idle -> process A

In such scenario, we do not have to do IBPB here even though the process
is non-dumpable, as we are switching back to the same process after a
hiatus.

To avoid the redundant IBPB, which is expensive, we track the last mm
user context ID. The cost is to have an extra u64 mm context id to track
the last mm we were using before switching to the init_mm used by idle.
Avoiding the extra IBPB is probably worth the extra memory for this
common scenario.

For those cases where tlb_defer_switch_to_init_mm() returns true (non
PCID), lazy tlb will defer switch to init_mm, so we will not be changing
the mm for the process A -> idle -> process A switch. So IBPB will be
skipped for this case.

Thanks to the reviewers and Andy Lutomirski for the suggestion of
using ctx_id which got rid of the problem of mm pointer recycling.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: David Woodhouse <dwmw@amazon.co.uk>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: ak@linux.intel.com
Cc: karahmed@amazon.de
Cc: arjan@linux.intel.com
Cc: torvalds@linux-foundation.org
Cc: linux@dominikbrodowski.net
Cc: peterz@infradead.org
Cc: bp@alien8.de
Cc: luto@kernel.org
Cc: pbonzini@redhat.com
Cc: gregkh@linux-foundation.org
Link: https://lkml.kernel.org/r/1517263487-3708-1-git-send-email-dwmw@amazon.co.uk
---
 arch/x86/include/asm/tlbflush.h |  2 ++
 arch/x86/mm/tlb.c               | 31 +++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 94146f6..99185a0 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -68,6 +68,8 @@ static inline void invpcid_flush_all_nonglobals(void)
 struct tlb_state {
 	struct mm_struct *active_mm;
 	int state;
+	/* last user mm's ctx id */
+	u64 last_ctx_id;
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index fa74bf5..eac92e2 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -10,6 +10,7 @@
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
+#include <asm/nospec-branch.h>
 #include <asm/cache.h>
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
@@ -106,6 +107,28 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	unsigned cpu = smp_processor_id();
 
 	if (likely(prev != next)) {
+		u64 last_ctx_id = this_cpu_read(cpu_tlbstate.last_ctx_id);
+
+		/*
+		 * Avoid user/user BTB poisoning by flushing the branch
+		 * predictor when switching between processes. This stops
+		 * one process from doing Spectre-v2 attacks on another.
+		 *
+		 * As an optimization, flush indirect branches only when
+		 * switching into processes that disable dumping. This
+		 * protects high value processes like gpg, without having
+		 * too high performance overhead. IBPB is *expensive*!
+		 *
+		 * This will not flush branches when switching into kernel
+		 * threads. It will also not flush if we switch to idle
+		 * thread and back to the same process. It will flush if we
+		 * switch to a different non-dumpable process.
+		 */
+		if (tsk && tsk->mm &&
+		    tsk->mm->context.ctx_id != last_ctx_id &&
+		    get_dumpable(tsk->mm) != SUID_DUMP_USER)
+			indirect_branch_prediction_barrier();
+
 		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
 			/*
 			 * If our current stack is in vmalloc space and isn't
@@ -120,6 +143,14 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
 		}
 
+		/*
+		 * Record last user mm's context id, so we can avoid
+		 * flushing branch buffer with IBPB if we switch back
+		 * to the same user.
+		 */
+		if (next != &init_mm)
+			this_cpu_write(cpu_tlbstate.last_ctx_id, next->context.ctx_id);
+
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		this_cpu_write(cpu_tlbstate.active_mm, next);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
