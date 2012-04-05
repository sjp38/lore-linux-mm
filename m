Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id DC3936B00E8
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 18:21:57 -0400 (EDT)
Date: Fri, 6 Apr 2012 00:21:27 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/6] uprobes: teach find_active_uprobe() to provide the
	"is_swbp" info
Message-ID: <20120405222127.GC19166@redhat.com>
References: <20120405222024.GA19154@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405222024.GA19154@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

A separate patch to simplify the review, and for the documentation.

The patch adds another "int *is_swbp" argument to find_active_uprobe(),
so far its only caller doesn't use this info.

With this patch find_active_uprobe() additionally does:

	- if find_vma() + ->vm_start check fails, *is_swbp = -EFAULT

	- otherwise, if valid_vma() + find_uprobe() fails, we return
	  the result of is_swbp_at_addr_fast(), can be -EFAULT too.

IOW. If find_active_uprobe(&is_swbp) returns NULL, the caller can look
at is_swbp to figure out if the current insn is bp or not, or if we
can't access this memory.

Note: I think that performance-wise this change is fine. This adds
is_swbp_at_addr_fast(), but only if we race with uprobe_unregister()
or we hit the "normal" int3 but this mm has uprobes as well. And even
in this case the slow read_opcode() path is very unlikely, this insn
recently triggered do_int3(), __copy_from_user_inatomic() shouldn't
fail in the likely case.
---
 kernel/events/uprobes.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 2050b1a..054c00f 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1497,7 +1497,7 @@ int __weak is_swbp_at_addr_fast(unsigned long vaddr)
 	return is_swbp_insn(&opcode);
 }
 
-static struct uprobe *find_active_uprobe(unsigned long bp_vaddr)
+static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 {
 	struct mm_struct *mm = current->mm;
 	struct uprobe *uprobe = NULL;
@@ -1505,15 +1505,21 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr)
 
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, bp_vaddr);
+	if (vma && vma->vm_start <= bp_vaddr) {
+		if (valid_vma(vma, false)) {
+			struct inode *inode;
+			loff_t offset;
+
+			inode = vma->vm_file->f_mapping->host;
+			offset = bp_vaddr - vma->vm_start;
+			offset += (vma->vm_pgoff << PAGE_SHIFT);
+			uprobe = find_uprobe(inode, offset);
+		}
 
-	if (vma && vma->vm_start <= bp_vaddr && valid_vma(vma, false)) {
-		struct inode *inode;
-		loff_t offset;
-
-		inode = vma->vm_file->f_mapping->host;
-		offset = bp_vaddr - vma->vm_start;
-		offset += (vma->vm_pgoff << PAGE_SHIFT);
-		uprobe = find_uprobe(inode, offset);
+		if (!uprobe)
+			*is_swbp = is_swbp_at_addr_fast(bp_vaddr);
+	} else {
+		*is_swbp = -EFAULT;
 	}
 
 	srcu_read_unlock_raw(&uprobes_srcu, current->uprobe_srcu_id);
@@ -1532,9 +1538,10 @@ static void handle_swbp(struct pt_regs *regs)
 	struct uprobe_task *utask;
 	struct uprobe *uprobe;
 	unsigned long bp_vaddr;
+	int is_swbp;
 
 	bp_vaddr = uprobe_get_swbp_addr(regs);
-	uprobe = find_active_uprobe(bp_vaddr);
+	uprobe = find_active_uprobe(bp_vaddr, &is_swbp);
 
 	if (!uprobe) {
 		/* No matching uprobe; signal SIGTRAP. */
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
