Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0CE86B0261
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:31:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so155415869lfw.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:31:15 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id jo1si9453996wjb.272.2016.08.05.06.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 06:37:44 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] x86/mm: disable preemption during CR3 read+write
Date: Fri,  5 Aug 2016 15:37:39 +0200
Message-Id: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

Usually current->mm (and therefore mm->pgd) stays the same during the
lifetime of a task so it does not matter if a task gets preempted during
the read and write of the CR3.

But then, there is this scenario on x86-UP:
TaskA is in do_exit() and exit_mm() sets current->mm = NULL followed by
mmput() -> exit_mmap() -> tlb_finish_mmu() -> tlb_flush_mmu() ->
tlb_flush_mmu_tlbonly() -> tlb_flush() -> flush_tlb_mm_range() ->
__flush_tlb_up() -> __flush_tlb() ->  __native_flush_tlb().

At this point current->mm is NULL but current->active_mm still points to
the "old" mm.
Let's preempt taskA _after_ native_read_cr3() by taskB. TaskB has its
own mm so CR3 has changed.
Now preempt back to taskA. TaskA has no ->mm set so it borrows taskB's
mm and so CR3 remains unchanged. Once taskA gets active it continues
where it was interrupted and that means it writes its old CR3 value
back. Everything is fine because userland won't need its memory
anymore.

Now the fun part. Let's preempt taskA one more time and get back to
taskB. This time switch_mm() won't do a thing because oldmm
(->active_mm) is the same as mm (as per context_switch()). So we remain
with a bad CR3 / pgd and return to userland.
The next thing that happens is handle_mm_fault() with an address for the
execution of its code in userland. handle_mm_fault() realizes that it
has a PTE with proper rights so it returns doing nothing. But the CPU
looks at the wrong pgd and insists that something is wrong and faults
again. And again. And one more timea?|

This pagefault circle continues until the scheduler gets tired of it and
puts another task on the CPU. It gets little difficult if the task is a
RT task with a high priority. The system will either freeze or it gets
fixed by the software watchdog thread which usually runs at RT-max prio.
But waiting for the watchdog will increase the latency of the RT task
which is no good.

Cc: stable@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/x86/include/asm/tlbflush.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 4e5be94e079a..1ee065954e24 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -135,7 +135,14 @@ static inline void cr4_set_bits_and_update_boot(unsigned long mask)
 
 static inline void __native_flush_tlb(void)
 {
+	/*
+	 * if current->mm == NULL then we borrow a mm which may change during a
+	 * task switch and therefore we must not be preempted while we write CR3
+	 * back.
+	 */
+	preempt_disable();
 	native_write_cr3(native_read_cr3());
+	preempt_enable();
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
