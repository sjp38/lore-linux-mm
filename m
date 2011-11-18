Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2D56B00AF
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:38:50 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:08:46 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBcgcO3739836
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:08:42 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBcfE1000987
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 22:38:42 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:42:39 +0530
Message-Id: <20111118111239.10512.46179.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 30/30] x86: skip singlestep where possible
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


Check and skip singlestepping underlying instructions where possible.

For now handles single byte as well as few multibyte nop instructions.
However can be extended to other instructions too.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/x86/kernel/uprobes.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 3f0eb4e..f59053f 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -602,3 +602,47 @@ void abort_xol(struct pt_regs *regs, struct uprobe *uprobe)
 	handle_riprel_post_xol(uprobe, regs, NULL);
 	set_instruction_pointer(regs, utask->vaddr);
 }
+
+/*
+ * Skip these instructions:
+ *
+ * 0f 19 90 90 90 90 90		nopl   -0x6f6f6f70(%rax)
+ * 0f 1f 00			nopl (%rax)
+ * 0f 1f 40 00			nopl 0x0(%rax)
+ * 0f 1f 44 00 00		nopl 0x0(%rax,%rax,1)
+ * 0f 1f 80 00 00 00 00		nopl 0x0(%rax)
+ * 0f 1f 84 00 00 00 00		nopl 0x0(%rax,%rax,1)
+ * 66 0f 1f 44 00 00 00		nopw 0x0(%rax,%rax,1)
+ * 66 0f 1f 84 00 00 00		nopw 0x0(%rax,%rax,1)
+ * 66 87 c0			xchg %eax,%eax
+ * 66 90			nop
+ * 87 c0			xchg %eax,%eax
+ * 90 				nop
+ */
+
+bool can_skip_xol(struct pt_regs *regs, struct uprobe *u)
+{
+	int i;
+
+	for (i = 0; i < MAX_UINSN_BYTES; i++) {
+		if ((u->insn[i] == 0x66))
+			continue;
+
+		if (u->insn[i] == 0x90)
+			return true;
+
+		if ((u->insn[i] == 0x0f) && (u->insn[i+1] == 0x1f))
+			return true;
+
+		if ((u->insn[i] == 0x0f) && (u->insn[i+1] == 0x19))
+			return true;
+
+		if ((u->insn[i] == 0x87) && (u->insn[i+1] == 0xc0))
+			return true;
+
+		break;
+	}
+
+	u->flags &= ~UPROBES_SKIP_SSTEP;
+	return false;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
