Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0736B006C
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 14:12:28 -0500 (EST)
Date: Mon, 28 Nov 2011 20:07:14 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/5] uprobes: introduce uprobe_xol_slots[NR_CPUS]
Message-ID: <20111128190714.GD4602@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111128190614.GA4602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111128190614.GA4602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

This patch adds uprobe_xol_slots[UPROBES_XOL_SLOT_BYTES][NR_CPUS] array.
Each CPU has its own slot for xol (used in the next patch).

We "export" this data to the user-space via set_fixmap(PAGE_KERNEL_VSYSCALL).

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/include/asm/fixmap.h |    9 +++++++++
 arch/x86/kernel/uprobes.c     |   10 ++++++++++
 include/linux/uprobes.h       |    1 +
 kernel/uprobes.c              |    4 ++++
 4 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index 460c74e..a902e19 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -81,6 +81,15 @@ enum fixed_addresses {
 	VVAR_PAGE,
 	VSYSCALL_HPET,
 #endif
+
+#ifdef CONFIG_UPROBES
+	#define UPROBES_XOL_SLOT_BYTES  128
+
+	UPROBE_XOL_LAST_PAGE,
+	UPROBE_XOL_FIRST_PAGE = UPROBE_XOL_LAST_PAGE
+			      + NR_CPUS * UPROBES_XOL_SLOT_BYTES / PAGE_SIZE,
+#endif
+
 	FIX_DBGP_BASE,
 	FIX_EARLYCON_MEM_BASE,
 #ifdef CONFIG_PROVIDE_OHCI1394_DMA_INIT
diff --git a/arch/x86/kernel/uprobes.c b/arch/x86/kernel/uprobes.c
index 4140137..ebb280c 100644
--- a/arch/x86/kernel/uprobes.c
+++ b/arch/x86/kernel/uprobes.c
@@ -664,3 +664,13 @@ bool can_skip_xol(struct pt_regs *regs, struct uprobe *u)
 	u->flags &= ~UPROBES_SKIP_SSTEP;
 	return false;
 }
+
+void __init map_uprobe_xol_slots(void *pages)
+{
+	int idx = UPROBE_XOL_FIRST_PAGE;
+
+	do {
+		__set_fixmap(idx, __pa(pages), PAGE_KERNEL_VSYSCALL);
+		pages += PAGE_SIZE;
+	} while (idx-- != UPROBE_XOL_LAST_PAGE);
+}
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index d590d66..bb59a66 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -142,6 +142,7 @@ extern bool uprobe_deny_signal(void);
 extern bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u);
 extern void __weak set_xol_ip(struct pt_regs *regs);
 extern void uprobe_switch_to(struct task_struct *);
+extern void map_uprobe_xol_slots(void *);
 #else /* CONFIG_UPROBES is not defined */
 static inline int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer)
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 9c509dc..20007da 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1342,6 +1342,9 @@ bool __weak can_skip_xol(struct pt_regs *regs, struct uprobe *u)
 	return false;
 }
 
+static unsigned char
+uprobe_xol_slots[UPROBES_XOL_SLOT_BYTES][NR_CPUS] __page_aligned_bss;
+
 void __weak set_xol_ip(struct pt_regs *regs)
 {
 	set_instruction_pointer(regs, current->utask->xol_vaddr);
@@ -1490,6 +1493,7 @@ static int __init init_uprobes(void)
 		mutex_init(&uprobes_mmap_mutex[i]);
 	}
 	init_bulkref(&uprobes_srcu);
+	map_uprobe_xol_slots(uprobe_xol_slots);
 	return register_die_notifier(&uprobe_exception_nb);
 }
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
