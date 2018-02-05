Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1475E6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 14:35:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m10so9380229pgq.1
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 11:35:09 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k4-v6si7287357pls.182.2018.02.05.11.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 11:35:07 -0800 (PST)
Subject: Re: [tip:x86/pti] x86/speculation: Use Indirect Branch Prediction
 Barrier in context switch
References: <1517263487-3708-1-git-send-email-dwmw@amazon.co.uk>
 <tip-18bf3c3ea8ece8f03b6fc58508f2dfd23c7711c7@git.kernel.org>
 <1517840309.31953.153.camel@infradead.org>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <a38f70bc-13a0-506a-2b8b-18877e6e6796@linux.intel.com>
Date: Mon, 5 Feb 2018 11:35:05 -0800
MIME-Version: 1.0
In-Reply-To: <1517840309.31953.153.camel@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, mingo@kernel.org, hpa@zytor.com, linux-kernel@vger.kernel.org, tglx@linutronix.de, luto@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>

On 02/05/2018 06:18 AM, David Woodhouse wrote:
> On Tue, 2018-01-30 at 14:39 -0800, tip-bot for Tim Chen wrote:
>> Thanks to the reviewers and Andy Lutomirski for the suggestion of
>> using ctx_id which got rid of the problem of mm pointer recycling.
> 
> That one doesn't backport well to 4.9. Suggestions welcome.
> 

Will something like the following work for 4.9 using active_mm?
This patch is not really tested, but just
want to put it out here to see if this is a reasonable backport.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index a7655f6..4994db2 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -9,6 +9,7 @@
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
+#include <asm/nospec-branch.h>
 #include <asm/cache.h>
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
@@ -75,6 +76,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			struct task_struct *tsk)
 {
 	unsigned cpu = smp_processor_id();
+#ifdef CONFIG_SMP
+	struct mm_struct *active_mm = this_cpu_read(cpu_tlbstate.active_mm);
+#endif
 
 	if (likely(prev != next)) {
 		if (IS_ENABLED(CONFIG_VMAP_STACK)) {
@@ -91,6 +95,28 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
 		}
 
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
+#ifdef CONFIG_SMP
+		    next != active_mm &&
+#endif
+		    get_dumpable(tsk->mm) != SUID_DUMP_USER)
+			indirect_branch_prediction_barrier();
+
 #ifdef CONFIG_SMP
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		this_cpu_write(cpu_tlbstate.active_mm, next);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
