Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 38A658D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:42:06 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDg1GI013287
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:12:01 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDg0X24067530
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:12:00 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDfwHq013665
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:42:00 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:06:20 +0530
Message-Id: <20110314133620.27435.24071.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 12/20] 12: uprobes: get the breakpoint address.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


On a breakpoint hit, return the address where the breakpoint was hit.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
---
 include/linux/uprobes.h |    5 +++++
 kernel/uprobes.c        |   11 +++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index c42975b..aef55de 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -146,6 +146,7 @@ extern void uprobe_free_utask(struct task_struct *tsk);
 
 struct vm_area_struct;
 extern void uprobe_mmap(struct vm_area_struct *vma);
+extern unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs);
 extern void uprobe_dup_mmap(struct mm_struct *old_mm, struct mm_struct *mm);
 extern void uprobes_free_xol_area(struct mm_struct *mm);
 #else /* CONFIG_UPROBES is not defined */
@@ -165,5 +166,9 @@ static inline void uprobe_dup_mmap(struct mm_struct *old_mm,
 static inline void uprobe_free_utask(struct task_struct *tsk) {}
 static inline void uprobe_mmap(struct vm_area_struct *vma) { }
 static inline void uprobes_free_xol_area(struct mm_struct *mm) {}
+static inline unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs)
+{
+	return 0;
+}
 #endif /* CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 9d3d402..307f0cd 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1044,6 +1044,17 @@ static void xol_free_insn_slot(struct task_struct *tsk, unsigned long slot_addr)
 						__func__, slot_addr);
 }
 
+/**
+ * uprobes_get_bkpt_addr - compute address of bkpt given post-bkpt regs
+ * @regs: Reflects the saved state of the task after it has hit a breakpoint
+ * instruction.
+ * Return the address of the breakpoint instruction.
+ */
+unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs)
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
