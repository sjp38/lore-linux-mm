Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7884F6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:03:48 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 10 Nov 2011 19:01:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ0fXJ2154566
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:00:41 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ3ePZ031725
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:03:41 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:08:41 +0530
Message-Id: <20111110183841.11361.36652.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 6/28]   Uprobes: define fixups.
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
