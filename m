Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 465846B026E
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 12:46:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g202so309831229pfb.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 09:46:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wm4si30027990pab.235.2016.09.05.09.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 09:46:39 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.7 001/143] x86/mm: Disable preemption during CR3 read+write
Date: Mon,  5 Sep 2016 18:42:57 +0200
Message-Id: <20160905164430.652351752@linuxfoundation.org>
In-Reply-To: <20160905164430.593075551@linuxfoundation.org>
References: <20160905164430.593075551@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bp@suse.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.7-stable review patch.  If anyone has any objections, please let me know.

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |    7 +++++++
 1 file changed, 7 insertions(+)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -135,7 +135,14 @@ static inline void cr4_set_bits_and_upda
 
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
 
 static inline void __native_flush_tlb_global_irq_disabled(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
