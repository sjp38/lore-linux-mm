Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7286B006C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:33:59 -0500 (EST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2011 17:03:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAIBXjKN4501514
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:03:45 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAIBXiVa024019
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 17:03:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 18 Nov 2011 16:37:43 +0530
Message-Id: <20111118110743.10512.50949.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v7 3.2-rc2 6/30] uprobes: define fixups.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


During the first insertion of a probepoint, instruction is analyzed for
fixups and cached in the per-uprobe struct. On a probehit, the cached
fixup is used. Fixup analysis and caching is done in arch-specific
code.

Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index fa2b663..dd308fa 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -33,6 +33,17 @@ struct vm_area_struct;
 #define MAX_UINSN_BYTES 4
 #endif
 
+#define uprobe_opcode_sz sizeof(uprobe_opcode_t)
+
+/* Post-execution fixups.  Some architectures may define others. */
+
+/* No fixup needed */
+#define UPROBES_FIX_NONE	0x0
+/* Adjust IP back to vicinity of actual insn */
+#define UPROBES_FIX_IP	0x1
+/* Adjust the return address of a call insn */
+#define UPROBES_FIX_CALL	0x2
+
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
 	/*
@@ -53,6 +64,7 @@ struct uprobe {
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;
 	int			copy;
+	u16			fixups;
 	u8			insn[MAX_UINSN_BYTES];
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
