Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 330FC6B006C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:03:58 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 10 Nov 2011 19:58:24 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAJ0OYs1884234
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:00:24 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAJ3PE7021993
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 06:03:26 +1100
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2011 00:08:26 +0530
Message-Id: <20111110183826.11361.17633.sendpatchset@srdronam.in.ibm.com>
In-Reply-To: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
References: <20111110183725.11361.57827.sendpatchset@srdronam.in.ibm.com>
Subject: [PATCH v6 3.2-rc1 5/28]   Uprobes: copy of the original instruction.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>


When inserting the first probepoint, save a copy of the original
instruction.  This copy is later used for fixup analysis, copied to the slot
on probe-hit and for restoring the original instruction.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---

Changelog: (Since v5)
- Uprobes no more depends on MM_OWNER; No reference to task_structs
  while inserting/removing a probe.
- Uses read_mapping_page instead of grab_cache_page so that the pages
  have valid content.

 include/linux/uprobes.h |   12 +++++
 kernel/uprobes.c        |  111 +++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 113 insertions(+), 10 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index b4de058..fa2b663 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -26,6 +26,12 @@
 #include <linux/rbtree.h>
 
 struct vm_area_struct;
+#ifdef CONFIG_ARCH_SUPPORTS_UPROBES
+#include <asm/uprobes.h>
+#else
+
+#define MAX_UINSN_BYTES 4
+#endif
 
 struct uprobe_consumer {
 	int (*handler)(struct uprobe_consumer *self, struct pt_regs *regs);
@@ -46,9 +52,15 @@ struct uprobe {
 	struct uprobe_consumer	*consumers;
 	struct inode		*inode;		/* Also hold a ref to inode */
 	loff_t			offset;
+	int			copy;
+	u8			insn[MAX_UINSN_BYTES];
 };
 
 #ifdef CONFIG_UPROBES
+extern int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
+							unsigned long vaddr);
+extern int __weak set_orig_insn(struct mm_struct *mm, struct uprobe *uprobe,
+					unsigned long vaddr, bool verify);
 extern int register_uprobe(struct inode *inode, loff_t offset,
 				struct uprobe_consumer *consumer);
 extern void unregister_uprobe(struct inode *inode, loff_t offset,
diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 1baae40..f4574fd 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -23,6 +23,7 @@
 
 #include <linux/kernel.h>
 #include <linux/highmem.h>
+#include <linux/pagemap.h>	/* read_mapping_page */
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/uprobes.h>
@@ -82,6 +83,20 @@ static bool valid_vma(struct vm_area_struct *vma, bool is_reg)
 	return false;
 }
 
+int __weak set_bkpt(struct mm_struct *mm, struct uprobe *uprobe,
+						unsigned long vaddr)
+{
+	/* placeholder: yet to be implemented */
+	return 0;
+}
+
+int __weak set_orig_insn(struct mm_struct *mm, struct uprobe *uprobe,
+					unsigned long vaddr, bool verify)
+{
+	/* placeholder: yet to be implemented */
+	return 0;
+}
+
 static int match_uprobe(struct uprobe *l, struct uprobe *r)
 {
 	if (l->inode < r->inode)
@@ -251,8 +266,71 @@ static bool del_consumer(struct uprobe *uprobe,
 	return ret;
 }
 
-static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
+static int __copy_insn(struct address_space *mapping,
+			struct vm_area_struct *vma, char *insn,
+			unsigned long nbytes, unsigned long offset)
+{
+	struct file *filp = vma->vm_file;
+	struct page *page;
+	void *vaddr;
+	unsigned long off1;
+	unsigned long idx;
+
+	if (!filp)
+		return -EINVAL;
+
+	idx = (unsigned long)(offset >> PAGE_CACHE_SHIFT);
+	off1 = offset &= ~PAGE_MASK;
+
+	/*
+	 * Ensure that the page that has the original instruction is
+	 * populated and in page-cache.
+	 */
+	page = read_mapping_page(mapping, idx, filp);
+	if (IS_ERR(page))
+		return -ENOMEM;
+
+	vaddr = kmap_atomic(page);
+	memcpy(insn, vaddr + off1, nbytes);
+	kunmap_atomic(vaddr);
+	page_cache_release(page);
+	return 0;
+}
+
+static int copy_insn(struct uprobe *uprobe, struct vm_area_struct *vma,
+					unsigned long addr)
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
+		if (__copy_insn(mapping, vma, uprobe->insn + nbytes,
+				bytes - nbytes, uprobe->offset + nbytes))
+			return -ENOMEM;
+
+		bytes = nbytes;
+	}
+	return __copy_insn(mapping, vma, uprobe->insn, bytes, uprobe->offset);
+}
+
+static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
+				struct vm_area_struct *vma, loff_t vaddr)
 {
+	unsigned long addr;
+	int ret = -EINVAL;
+
 	/*
 	 * Probe is to be deleted;
 	 * Dont know if somebody already inserted the probe;
@@ -261,15 +339,27 @@ static int install_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
 	if (!uprobe->consumers)
 		return -EEXIST;
 
-	atomic_inc(&mm->mm_uprobes_count);
-	return 0;
+	addr = (unsigned long)vaddr;
+	if (!uprobe->copy) {
+		ret = copy_insn(uprobe, vma, addr);
+		if (ret)
+			return ret;
+
+		/* TODO : Analysis and verification of instruction */
+		uprobe->copy = 1;
+	}
+	ret = set_bkpt(mm, uprobe, addr);
+	if (!ret)
+		atomic_inc(&mm->mm_uprobes_count);
+
+	return ret;
 }
 
-static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe)
+static void remove_breakpoint(struct mm_struct *mm, struct uprobe *uprobe,
+							loff_t vaddr)
 {
-	/* Placeholder: Yet to be implemented */
-	atomic_dec(&mm->mm_uprobes_count);
-	return;
+	if (!set_orig_insn(mm, uprobe, (unsigned long)vaddr, true))
+		atomic_dec(&mm->mm_uprobes_count);
 }
 
 static void delete_uprobe(struct uprobe *uprobe)
@@ -385,7 +475,7 @@ static int __register_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		ret = install_breakpoint(mm, uprobe);
+		ret = install_breakpoint(mm, uprobe, vma, vi->vaddr);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 		if (ret && ret == -EEXIST)
@@ -436,7 +526,7 @@ static void __unregister_uprobe(struct inode *inode, loff_t offset,
 			mmput(mm);
 			continue;
 		}
-		remove_breakpoint(mm, uprobe);
+		remove_breakpoint(mm, uprobe, vi->vaddr);
 		up_read(&mm->mmap_sem);
 		mmput(mm);
 	}
@@ -627,7 +717,8 @@ int mmap_uprobe(struct vm_area_struct *vma)
 				put_uprobe(uprobe);
 				continue;
 			}
-			ret = install_breakpoint(vma->vm_mm, uprobe);
+			ret = install_breakpoint(vma->vm_mm, uprobe, vma,
+								vaddr);
 			if (ret == -EEXIST) {
 				atomic_inc(&vma->vm_mm->mm_uprobes_count);
 				ret = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
