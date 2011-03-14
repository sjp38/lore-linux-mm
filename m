Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9C74B8D0046
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:41:34 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDfTfo016366
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:11:29 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDfTGH4411642
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:11:29 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDfTfV021955
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:11:31 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:05:50 +0530
Message-Id: <20110314133550.27435.62287.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 9/20]  9: x86: architecture specific task information.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


On X86_64, we need to support rip relative instructions.
Rip relative instructions are handled by saving the scratch register
on probe hit and then retrieving the previously saved scratch register
after single-step. This value stored at probe hit is specific to each
task. Hence this is implemented as part of uprobe_task_arch_info.

Since x86_32 has no support for rip relative instructions, we dont need to
bother for x86_32.

Signed-off-by: Jim Keniston <jkenisto@linux.vnet.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/include/asm/uprobes.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/uprobes.h b/arch/x86/include/asm/uprobes.h
index 0063207..e38950f 100644
--- a/arch/x86/include/asm/uprobes.h
+++ b/arch/x86/include/asm/uprobes.h
@@ -34,8 +34,13 @@ typedef u8 uprobe_opcode_t;
 struct uprobe_arch_info {
 	unsigned long rip_rela_target_address;
 };
+
+struct uprobe_task_arch_info {
+	unsigned long saved_scratch_register;
+};
 #else
 struct uprobe_arch_info {};
+struct uprobe_task_arch_info {};
 #endif
 struct uprobe;
 extern int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
