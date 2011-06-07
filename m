Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A20FB6B00E8
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:07:21 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p57D19FW008841
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:01:09 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p57D6aNZ802958
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:06:36 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57D7Gg9025247
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 23:07:17 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Tue, 07 Jun 2011 18:30:26 +0530
Message-Id: <20110607130026.28590.37383.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v4 3.0-rc2-tip 11/22] 11: uprobes: get the breakpoint address.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>


On a breakpoint hit, return the address where the breakpoint was hit.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
---
 include/linux/uprobes.h |    5 +++++
 kernel/uprobes.c        |   11 +++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 4590e9a..838fbaa 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -161,6 +161,7 @@ struct vm_area_struct;
 extern int mmap_uprobe(struct vm_area_struct *vma);
 extern void dup_mmap_uprobe(struct mm_struct *old_mm, struct mm_struct *mm);
 extern void free_uprobes_xol_area(struct mm_struct *mm);
+extern unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
@@ -181,5 +182,9 @@ static inline int mmap_uprobe(struct vm_area_struct *vma)
 }
 static inline void free_uprobe_utask(struct task_struct *tsk) {}
 static inline void free_uprobes_xol_area(struct mm_struct *mm) {}
+static inline unsigned long get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return 0;
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index d19c3b0..fa9e9ba 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1263,6 +1263,17 @@ static void xol_free_insn_slot(struct task_struct *tsk)
 						__func__, slot_addr);
 }
 
+/**
+ * get_uprobe_bkpt_addr - compute address of bkpt given post-bkpt regs
+ * @regs: Reflects the saved state of the task after it has hit a breakpoint
+ * instruction.
+ * Return the address of the breakpoint instruction.
+ */
+unsigned long __weak get_uprobe_bkpt_addr(struct pt_regs *regs)
+{
+	return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
+}
+
 /*
  * Called with no locks held.
  * Called in context of a exiting or a exec-ing thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
