Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E7D918D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:40:29 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.4/8.13.1) with ESMTP id p2EDeJmx008477
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:10:19 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2EDeD622617562
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:10:13 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2EDeBqB007719
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 00:40:12 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Mon, 14 Mar 2011 19:04:33 +0530
Message-Id: <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page replacement.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


Provides Background page replacement using replace_page() routine.
Also provides routines to read an opcode from a given virtual address
and for verifying if a instruction is a breakpoint instruction.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Signed-off-by: Jim Keniston <jkenisto@us.ibm.com>
---
 arch/Kconfig            |   12 ++
 include/linux/uprobes.h |   70 ++++++++++++++
 kernel/Makefile         |    1 
 kernel/uprobes.c        |  230 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 313 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/uprobes.h
 create mode 100644 kernel/uprobes.c

diff --git a/arch/Kconfig b/arch/Kconfig
index f78c2be..c681f16 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -61,6 +61,18 @@ config OPTPROBES
 	depends on KPROBES && HAVE_OPTPROBES
 	depends on !PREEMPT
 
+config UPROBES
+	bool "User-space probes (EXPERIMENTAL)"
+	depends on ARCH_SUPPORTS_UPROBES
+	depends on MMU
+	select MM_OWNER
+	help
+	  Uprobes enables kernel subsystems to establish probepoints
+	  in user applications and execute handler functions when
+	  the probepoints are hit.
+
+	  If in doubt, say "N".
+
 config HAVE_EFFICIENT_UNALIGNED_ACCESS
 	bool
 	help
diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
new file mode 100644
index 0000000..350ccb0
--- /dev/null
+++ b/include/linux/uprobes.h
@@ -0,0 +1,70 @@
+#ifndef _LINUX_UPROBES_H
+#define _LINUX_UPROBES_H
+/*
+ * Userspace Probes (UProbes)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2010
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+
+#ifdef CONFIG_ARCH_SUPPORTS_UPROBES
+#include <asm/uprobes.h>
+#else
+/*
+ * ARCH_SUPPORTS_UPROBES is not defined.
+ */
+typedef u8 uprobe_opcode_t;
+
+/* Post-execution fixups.  Some architectures may define others. */
+#endif /* CONFIG_ARCH_SUPPORTS_UPROBES */
+
+/* No fixup needed */
+#define UPROBES_FIX_NONE	0x0
+/* Adjust IP back to vicinity of actual insn */
+#define UPROBES_FIX_IP	0x1
+/* Adjust the return address of a call insn */
+#define UPROBES_FIX_CALL	0x2
+/* Might sleep while doing Fixup */
+#define UPROBES_FIX_SLEEPY	0x4
+
+#ifndef UPROBES_FIX_DEFAULT
+#define UPROBES_FIX_DEFAULT UPROBES_FIX_IP
+#endif
+
+/* Unexported functions & macros for use by arch-specific code */
+#define uprobe_opcode_sz (sizeof(uprobe_opcode_t))
+
+/*
+ * Most architectures can use the default versions of @read_opcode(),
+ * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
+ *
+ * @set_ip:
+ *	Set the instruction pointer in @regs to @vaddr.
+ * @analyze_insn:
+ *	Analyze @user_bkpt->insn.  Return 0 if @user_bkpt->insn is an
+ *	instruction you can probe, or a negative errno (typically -%EPERM)
+ *	otherwise. Determine what sort of
+ * @pre_xol:
+ * @post_xol:
+ *	XOL-related fixups @post_xol() (and possibly @pre_xol()) will need
+ *	to do for this instruction, and annotate @user_bkpt accordingly.
+ *	You may modify @user_bkpt->insn (e.g., the x86_64 port does this
+ *	for rip-relative instructions).
+ */
+#endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/Makefile b/kernel/Makefile
index 353d3fe..d562285 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -107,6 +107,7 @@ obj-$(CONFIG_PERF_EVENTS) += perf_event.o
 obj-$(CONFIG_HAVE_HW_BREAKPOINT) += hw_breakpoint.o
 obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
 obj-$(CONFIG_PADATA) += padata.o
+obj-$(CONFIG_UPROBES) += uprobes.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
new file mode 100644
index 0000000..4f0f61b
--- /dev/null
+++ b/kernel/uprobes.c
@@ -0,0 +1,230 @@
+/*
+ * Userspace Probes (UProbes)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2008-2010
+ * Authors:
+ *	Srikar Dronamraju
+ *	Jim Keniston
+ */
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/slab.h>
+#include <linux/uprobes.h>
+#include <linux/rmap.h> /* needed for anon_vma_prepare */
+
+struct uprobe {
+	u8			insn[MAX_UINSN_BYTES];
+	u16			fixups;
+};
+
+/*
+ * Called with tsk->mm->mmap_sem held (either for read or write and
+ * with a reference to tsk->mm.
+ */
+static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
+			unsigned long vaddr, uprobe_opcode_t opcode)
+{
+	struct page *old_page, *new_page;
+	void *vaddr_old, *vaddr_new;
+	struct vm_area_struct *vma;
+	spinlock_t *ptl;
+	pte_t *orig_pte;
+	unsigned long addr;
+	int ret = -EINVAL;
+
+	/* Read the page with vaddr into memory */
+	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
+	if (ret <= 0)
+		return -EINVAL;
+	ret = -EINVAL;
+
+	/*
+	 * check if the page we are interested is read-only mapped
+	 * Since we are interested in text pages, Our pages of interest
+	 * should be mapped read-only.
+	 */
+	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
+						(VM_READ|VM_EXEC))
+		goto put_out;
+
+	/* Allocate a page */
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
+	if (!new_page) {
+		ret = -ENOMEM;
+		goto put_out;
+	}
+
+	/*
+	 * lock page will serialize against do_wp_page()'s
+	 * PageAnon() handling
+	 */
+	lock_page(old_page);
+	/* copy the page now that we've got it stable */
+	vaddr_old = kmap_atomic(old_page, KM_USER0);
+	vaddr_new = kmap_atomic(new_page, KM_USER1);
+
+	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
+	/* poke the new insn in, ASSUMES we don't cross page boundary */
+	addr = vaddr;
+	vaddr &= ~PAGE_MASK;
+	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
+
+	kunmap_atomic(vaddr_new, KM_USER1);
+	kunmap_atomic(vaddr_old, KM_USER0);
+
+	orig_pte = page_check_address(old_page, tsk->mm, addr, &ptl, 0);
+	if (!orig_pte)
+		goto unlock_out;
+	pte_unmap_unlock(orig_pte, ptl);
+
+	lock_page(new_page);
+	if (!anon_vma_prepare(vma))
+		/* flip pages, do_wp_page() will fail pte_same() and bail */
+		ret = replace_page(vma, old_page, new_page, *orig_pte);
+
+	unlock_page(new_page);
+	if (ret != 0)
+		page_cache_release(new_page);
+unlock_out:
+	unlock_page(old_page);
+
+put_out:
+	put_page(old_page); /* we did a get_page in the beginning */
+	return ret;
+}
+
+/**
+ * read_opcode - read the opcode at a given virtual address.
+ * @tsk: the probed task.
+ * @vaddr: the virtual address to store the opcode.
+ * @opcode: location to store the read opcode.
+ *
+ * For task @tsk, read the opcode at @vaddr and store it in @opcode.
+ * Return 0 (success) or a negative errno.
+ */
+int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
+						uprobe_opcode_t *opcode)
+{
+	struct vm_area_struct *vma;
+	struct page *page;
+	void *vaddr_new;
+	int ret;
+
+	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
+	if (ret <= 0)
+		return -EFAULT;
+	ret = -EFAULT;
+
+	/*
+	 * check if the page we are interested is read-only mapped
+	 * Since we are interested in text pages, Our pages of interest
+	 * should be mapped read-only.
+	 */
+	if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) ==
+						(VM_READ|VM_EXEC))
+		goto put_out;
+
+	lock_page(page);
+	vaddr_new = kmap_atomic(page, KM_USER0);
+	vaddr &= ~PAGE_MASK;
+	memcpy(&opcode, vaddr_new + vaddr, uprobe_opcode_sz);
+	kunmap_atomic(vaddr_new, KM_USER0);
+	unlock_page(page);
+	ret =  uprobe_opcode_sz;
+
+put_out:
+	put_page(page); /* we did a get_page in the beginning */
+	return ret;
+}
+
+/**
+ * set_bkpt - store breakpoint at a given address.
+ * @tsk: the probed task.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ *
+ * For task @tsk, store the breakpoint instruction at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
+int __weak set_bkpt(struct task_struct *tsk, struct uprobe *uprobe,
+						unsigned long vaddr)
+{
+	return write_opcode(tsk, uprobe, vaddr, UPROBES_BKPT_INSN);
+}
+
+/**
+ * set_orig_insn - Restore the original instruction.
+ * @tsk: the probed task.
+ * @uprobe: the probepoint information.
+ * @vaddr: the virtual address to insert the opcode.
+ * @verify: if true, verify existance of breakpoint instruction.
+ *
+ * For task @tsk, restore the original opcode (opcode) at @vaddr.
+ * Return 0 (success) or a negative errno.
+ */
+int __weak set_orig_insn(struct task_struct *tsk, struct uprobe *uprobe,
+				unsigned long vaddr, bool verify)
+{
+	if (verify) {
+		uprobe_opcode_t opcode;
+		int result = read_opcode(tsk, vaddr, &opcode);
+		if (result)
+			return result;
+		if (opcode != UPROBES_BKPT_INSN)
+			return -EINVAL;
+	}
+	return write_opcode(tsk, uprobe, vaddr,
+			*(uprobe_opcode_t *) uprobe->insn);
+}
+
+static void print_insert_fail(struct task_struct *tsk,
+			unsigned long vaddr, const char *why)
+{
+	printk(KERN_ERR "Can't place breakpoint at pid %d vaddr %#lx: %s\n",
+					tsk->pid, vaddr, why);
+}
+
+/*
+ * uprobes_resume_can_sleep - Check if fixup might result in sleep.
+ * @uprobes: the probepoint information.
+ *
+ * Returns true if fixup might result in sleep.
+ */
+static bool uprobes_resume_can_sleep(struct uprobe *uprobe)
+{
+	return uprobe->fixups & UPROBES_FIX_SLEEPY;
+}
+
+/**
+ * is_bkpt_insn - check if instruction is breakpoint instruction.
+ * @insn: instruction to be checked.
+ * Default implementation of is_bkpt_insn
+ * Returns true if @insn is a breakpoint instruction.
+ */
+bool __weak is_bkpt_insn(u8 *insn)
+{
+	uprobe_opcode_t opcode;
+
+	memcpy(&opcode, insn, UPROBES_BKPT_INSN_SIZE);
+	return (opcode == UPROBES_BKPT_INSN);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
