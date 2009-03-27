Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 16DCE6B004D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:37:06 -0400 (EDT)
Date: Thu, 26 Mar 2009 22:44:33 -0700 (PDT)
Message-Id: <20090326.224433.150749170.davem@davemloft.net>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1238132287.20197.47.camel@pasglop>
References: <1238106824.16498.7.camel@pasglop>
	<20090326.220409.72126250.davem@davemloft.net>
	<1238132287.20197.47.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: benh@kernel.crashing.org
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 27 Mar 2009 16:38:07 +1100

> If you look at context_switch() in kernel/sched.c, it increments
> mm_count when using the pevious guy's mm as the "active_mm" of a kernel
> thread, not mm_user.

Yawn...

arch/sparc/include/asm/mmu_context_64.h:
static inline void switch_mm(struct mm_struct *old_mm, struct mm_struct *mm, struct task_struct *tsk)
{
...
	spin_lock_irqsave(&mm->context.lock, flags);
	ctx_valid = CTX_VALID(mm->context);
	if (!ctx_valid)
		get_new_mmu_context(mm);
 ...
	cpu = smp_processor_id();
	if (!ctx_valid || !cpu_isset(cpu, mm->cpu_vm_mask)) {
		cpu_set(cpu, mm->cpu_vm_mask);
		__flush_tlb_mm(CTX_HWBITS(mm->context),
			       SECONDARY_CONTEXT);
	}
	spin_unlock_irqrestore(&mm->context.lock, flags);
...

We unconditionally check if the CPU is set in the mask, even
when the mm isn't changing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
