Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 949C46B0038
	for <linux-mm@kvack.org>; Sun, 13 Nov 2016 21:06:46 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a20so19893158wme.5
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 18:06:46 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id tr13si21578191wjb.191.2016.11.13.18.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Nov 2016 18:06:45 -0800 (PST)
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 14 Nov 2016 00:14:07 +0000
Message-ID: <lsq.1479082447.387293900@decadent.org.uk>
Subject: [PATCH 3.2 065/152] x86/mm: Disable preemption during CR3 read+write
In-Reply-To: <lsq.1479082446.271293126@decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: akpm@linux-foundation.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Borislav Petkov <bp@alien8.de>

3.2.84-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

commit 5cf0791da5c162ebc14b01eb01631cfa7ed4fa6e upstream.

There's a subtle preemption race on UP kernels:

Usually current->mm (and therefore mm->pgd) stays the same during the
lifetime of a task so it does not matter if a task gets preempted during
the read and write of the CR3.

But then, there is this scenario on x86-UP:

TaskA is in do_exit() and exit_mm() sets current->mm = NULL followed by:

 -> mmput()
 -> exit_mmap()
 -> tlb_finish_mmu()
 -> tlb_flush_mmu()
 -> tlb_flush_mmu_tlbonly()
 -> tlb_flush()
 -> flush_tlb_mm_range()
 -> __flush_tlb_up()
 -> __flush_tlb()
 ->  __native_flush_tlb()

At this point current->mm is NULL but current->active_mm still points to
the "old" mm.

Let's preempt taskA _after_ native_read_cr3() by taskB. TaskB has its
own mm so CR3 has changed.

Now preempt back to taskA. TaskA has no ->mm set so it borrows taskB's
mm and so CR3 remains unchanged. Once taskA gets active it continues
where it was interrupted and that means it writes its old CR3 value
back. Everything is fine because userland won't need its memory
anymore.

Now the fun part:

Let's preempt taskA one more time and get back to taskB. This
time switch_mm() won't do a thing because oldmm (->active_mm)
is the same as mm (as per context_switch()). So we remain
with a bad CR3 / PGD and return to userland.

The next thing that happens is handle_mm_fault() with an address for
the execution of its code in userland. handle_mm_fault() realizes that
it has a PTE with proper rights so it returns doing nothing. But the
CPU looks at the wrong PGD and insists that something is wrong and
faults again. And again. And one more timea?|

This pagefault circle continues until the scheduler gets tired of it and
puts another task on the CPU. It gets little difficult if the task is a
RT task with a high priority. The system will either freeze or it gets
fixed by the software watchdog thread which usually runs at RT-max prio.
But waiting for the watchdog will increase the latency of the RT task
which is no good.

Fix this by disabling preemption across the critical code section.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Borislav Petkov <bp@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1470404259-26290-1-git-send-email-bigeasy@linutronix.de
[ Prettified the changelog. ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/tlbflush.h | 7 +++++++
 1 file changed, 7 insertions(+)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -17,7 +17,14 @@
 
 static inline void __native_flush_tlb(void)
 {
+	/*
+	 * If current->mm == NULL then we borrow a mm which may change during a
+	 * task switch and therefore we must not be preempted while we write CR3
+	 * back:
+	 */
+	preempt_disable();
 	native_write_cr3(native_read_cr3());
+	preempt_enable();
 }
 
 static inline void __native_flush_tlb_global(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
