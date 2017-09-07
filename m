Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D01B6B02F3
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:06 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 3so273410ity.3
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:06 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b81sor83405iod.159.2017.09.07.10.37.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:05 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 02/11] x86: always set IF before oopsing from page fault
Date: Thu,  7 Sep 2017 11:36:00 -0600
Message-Id: <20170907173609.22696-3-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>, x86@kernel.org

Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
that might sleep:

Aug 23 19:30:27 xpfo kernel: [   38.302714] BUG: sleeping function called from invalid context at ./include/linux/percpu-rwsem.h:33
Aug 23 19:30:27 xpfo kernel: [   38.303837] in_atomic(): 0, irqs_disabled(): 1, pid: 1970, name: lkdtm_xpfo_test
Aug 23 19:30:27 xpfo kernel: [   38.304758] CPU: 3 PID: 1970 Comm: lkdtm_xpfo_test Tainted: G      D         4.13.0-rc5+ #228
Aug 23 19:30:27 xpfo kernel: [   38.305813] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1 04/01/2014
Aug 23 19:30:27 xpfo kernel: [   38.306926] Call Trace:
Aug 23 19:30:27 xpfo kernel: [   38.307243]  dump_stack+0x63/0x8b
Aug 23 19:30:27 xpfo kernel: [   38.307665]  ___might_sleep+0xec/0x110
Aug 23 19:30:27 xpfo kernel: [   38.308139]  __might_sleep+0x45/0x80
Aug 23 19:30:27 xpfo kernel: [   38.308593]  exit_signals+0x21/0x1c0
Aug 23 19:30:27 xpfo kernel: [   38.309046]  ? blocking_notifier_call_chain+0x11/0x20
Aug 23 19:30:27 xpfo kernel: [   38.309677]  do_exit+0x98/0xbf0
Aug 23 19:30:27 xpfo kernel: [   38.310078]  ? smp_reader+0x27/0x40 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.310604]  ? kthread+0x10f/0x150
Aug 23 19:30:27 xpfo kernel: [   38.311045]  ? read_user_with_flags+0x60/0x60 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.311680]  rewind_stack_do_exit+0x17/0x20

To be safe, let's just always enable irqs.

The particular case I'm hitting is:

Aug 23 19:30:27 xpfo kernel: [   38.278615]  __bad_area_nosemaphore+0x1a9/0x1d0
Aug 23 19:30:27 xpfo kernel: [   38.278617]  bad_area_nosemaphore+0xf/0x20
Aug 23 19:30:27 xpfo kernel: [   38.278618]  __do_page_fault+0xd1/0x540
Aug 23 19:30:27 xpfo kernel: [   38.278620]  ? irq_work_queue+0x9b/0xb0
Aug 23 19:30:27 xpfo kernel: [   38.278623]  ? wake_up_klogd+0x36/0x40
Aug 23 19:30:27 xpfo kernel: [   38.278624]  trace_do_page_fault+0x3c/0xf0
Aug 23 19:30:27 xpfo kernel: [   38.278625]  do_async_page_fault+0x14/0x60
Aug 23 19:30:27 xpfo kernel: [   38.278627]  async_page_fault+0x28/0x30

When a fault is in kernel space which has been triggered by XPFO.

Signed-off-by: Tycho Andersen <tycho@docker.com>
CC: x86@kernel.org
---
 arch/x86/mm/fault.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 2a1fa10c6a98..7572ad4dae70 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -864,6 +864,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
 	/* Executive summary in case the body of the oops scrolled away */
 	printk(KERN_DEFAULT "CR2: %016lx\n", address);
 
+	/*
+	 * We're about to oops, which might kill the task. Make sure we're
+	 * allowed to sleep.
+	 */
+	flags |= X86_EFLAGS_IF;
+
 	oops_end(flags, regs, sig);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
