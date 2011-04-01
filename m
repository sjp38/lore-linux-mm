Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 104868D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:43:43 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p31EcXNw002028
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:38:33 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p31EheaE2216044
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:40 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p31EhcaB010708
	for <linux-mm@kvack.org>; Sat, 2 Apr 2011 01:43:40 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 01 Apr 2011 20:03:58 +0530
Message-Id: <20110401143358.15455.53804.sendpatchset@localhost6.localdomain6>
In-Reply-To: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
References: <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
Subject: [PATCH v3 2.6.39-rc1-tip 8/26]  8: uprobes: store/restore original instruction.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Steven Rostedt <rostedt@goodmis.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>


On the first probe insertion, copy the original instruction and opcode.
If multiple vmas map the same text area corresponding to an inode, we
only need to copy the instruction just once.
The copied instruction is further copied to a designated slot on probe
hit.  Its also used at the time of probe removal to restore the original
instruction.
opcode is used to analyze the instruction and determine the fixups.
Determining fixups at probe hit time would result in doing the same
operation on every probe hit. Hence Instruction analysis using the
opcode is done at probe insertion time.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/uprobes.c |  119 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index ff3f15e..d3ae4cb 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -71,6 +71,7 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 			unsigned long vaddr, uprobe_opcode_t opcode)
 {
 	struct page *old_page, *new_page;
+	struct address_space *mapping;
 	void *vaddr_old, *vaddr_new;
 	struct vm_area_struct *vma;
 	spinlock_t *ptl;
@@ -93,6 +94,18 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 	if (!valid_vma(vma))
 		goto put_out;
 
+	mapping = uprobe->inode->i_mapping;
+	if (mapping != vma->vm_file->f_mapping)
+		goto put_out;
+
+	addr = vma->vm_start + uprobe->offset;
+	addr -= vma->vm_pgoff << PAGE_SHIFT;
+	if (addr > ULONG_MAX)
+		goto put_out;
+
+	if (vaddr != (unsigned long) addr)
+		goto put_out;
+
 	/* Allocate a page */
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vaddr);
 	if (!new_page) {
@@ -111,7 +124,6 @@ static int write_opcode(struct task_struct *tsk, struct uprobe * uprobe,
 
 	memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
 	/* poke the new insn in, ASSUMES we don't cross page boundary */
-	addr = vaddr;
 	vaddr &= ~PAGE_MASK;
 	memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
 
@@ -460,24 +472,117 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
+static int __copy_insn(struct address_space *mapping, char *insn,
+			unsigned long nbytes, unsigned long offset)
+{
+	struct page *page;
+	void *vaddr;
+	unsigned long off1;
+	loff_t idx;
+
+	idx = offset >> PAGE_CACHE_SHIFT;
+	off1 = offset &= ~PAGE_MASK;
+	page = grab_cache_page(mapping, (unsigned long)idx);
+	if (!page)
+		return -ENOMEM;
+
+	vaddr = kmap_atomic(page, KM_USER0);
+	memcpy(insn, vaddr + off1, nbytes);
+	kunmap_atomic(vaddr, KM_USER0);
+	unlock_page(page);
+	page_cache_release(page);
+	return 0;
+}
+
+static int copy_insn(struct uprobe *uprobe, unsigned long addr)
+{
+	struct address_space *mapping;
+	int bytes;
+	unsigned long nbytes;
+
+	addr &= ~PAGE_MASK;
+	nbytes = PAGE_SIZE - addr;
+	mapping = uprobe->inode->i_mapping;
+
+	/* Instruction at end of binary; copy only available bytes */
+	if (uprobe->offset + MAX_UINSN_BYTES > uprobe->inode->i_size)
+		bytes = uprobe->inode->i_size - uprobe->offset;
+	else
+		bytes = MAX_UINSN_BYTES;
+
+	/* Instruction at the page-boundary; copy bytes in second page */
+	if (nbytes < bytes) {
+		if (__copy_insn(mapping, uprobe->insn + nbytes,
+				bytes - nbytes, uprobe->offset + nbytes))
+			return -ENOMEM;
+		bytes = nbytes;
+	}
+	return __copy_insn(mapping, uprobe->insn, bytes, uprobe->offset);
+}
+
+static struct task_struct *uprobes_get_mm_owner(struct mm_struct *mm)
+{
+	struct task_struct *tsk;
+
+	rcu_read_lock();
+	tsk = rcu_dereference(mm->owner);
+	if (tsk)
+		get_task_struct(tsk);
+	rcu_read_unlock();
+	return tsk;
+}
+
 static int install_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
 {
-	int ret = 0;
+	struct task_struct *tsk = uprobes_get_mm_owner(mm);
+	int ret;
 
-	/*TODO: install breakpoint */
-	if (!ret)
+	if (!tsk)	/* task is probably exiting; bail-out */
+		return -ESRCH;
+
+	if (!uprobe->copy) {
+		ret = copy_insn(uprobe, mm->uprobes_vaddr);
+		if (ret)
+			goto put_return;
+		if (is_bkpt_insn(uprobe->insn)) {
+			print_insert_fail(tsk, mm->uprobes_vaddr,
+				"breakpoint instruction already exists");
+			ret = -EEXIST;
+			goto put_return;
+		}
+		ret = analyze_insn(tsk, uprobe);
+		if (ret) {
+			print_insert_fail(tsk, mm->uprobes_vaddr,
+					"instruction type cannot be probed");
+			goto put_return;
+		}
+		uprobe->copy = 1;
+	}
+
+	ret = set_bkpt(tsk, uprobe, mm->uprobes_vaddr);
+	if (ret < 0)
+		print_insert_fail(tsk, mm->uprobes_vaddr,
+					"failed to insert bkpt instruction");
+	else
 		atomic_inc(&mm->uprobes_count);
+
+put_return:
+	put_task_struct(tsk);
 	return ret;
 }
 
 static int remove_uprobe(struct mm_struct *mm, struct uprobe *uprobe)
 {
-	int ret = 0;
+	struct task_struct *tsk = uprobes_get_mm_owner(mm);
+	int ret;
 
-	/*TODO: remove breakpoint */
+	if (!tsk)	/* task is probably exiting; bail-out */
+		return -ESRCH;
+
+	ret = set_orig_insn(tsk, uprobe, mm->uprobes_vaddr, true);
 	if (!ret)
 		atomic_dec(&mm->uprobes_count);
-
+	put_task_struct(tsk);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
