Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 98AEE6B002C
	for <linux-mm@kvack.org>; Sat, 15 Oct 2011 15:05:49 -0400 (EDT)
Date: Sat, 15 Oct 2011 21:01:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 4/X] uprobes: xol_add_vma: misc cleanups
Message-ID: <20111015190131.GE30243@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20111015190007.GA30243@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111015190007.GA30243@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, LKML <linux-kernel@vger.kernel.org>

1. get_task_mm(current)/mmput is not needed, we can use ->mm directly.

   It can't be NULL or use_mm'ed(), otherwise we are buggy anyway.

2. use IS_ERR_VALUE() after do_mmap_pgoff().

3. No need to read vma->vm_start, it must be equal to addr returned
   by do_mmap_pgoff().

4. No need to pass vmas => &vma to get_user_pages().
---
 kernel/uprobes.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/kernel/uprobes.c b/kernel/uprobes.c
index 6fe2b20..5c2554c 100644
--- a/kernel/uprobes.c
+++ b/kernel/uprobes.c
@@ -1051,9 +1051,7 @@ static int xol_add_vma(struct uprobes_xol_area *area)
 	unsigned long addr;
 	int ret;
 
-	mm = get_task_mm(current);
-	if (!mm)
-		return -ESRCH;
+	mm = current->mm;
 
 	down_write(&mm->mmap_sem);
 	ret = -EALREADY;
@@ -1076,24 +1074,23 @@ static int xol_add_vma(struct uprobes_xol_area *area)
 	addr = do_mmap_pgoff(NULL, addr, PAGE_SIZE, PROT_EXEC, MAP_PRIVATE, 0);
 	revert_creds(curr_cred);
 
-	if (addr & ~PAGE_MASK)
+	if (IS_ERR_VALUE(addr))
 		goto fail;
 
 	vma = find_vma(mm, addr);
 	/* Don't expand vma on mremap(). */
 	vma->vm_flags |= VM_DONTEXPAND | VM_DONTCOPY;
-	area->vaddr = vma->vm_start;
-	if (get_user_pages(current, mm, area->vaddr, 1, 1, 1, &area->page,
-				&vma) != 1) {
+	if (get_user_pages(current, mm, addr, 1, 1, 1,
+					&area->page, NULL) != 1) {
 		do_munmap(mm, addr, PAGE_SIZE);
 		goto fail;
 	}
 
+	area->vaddr = addr;
 	mm->uprobes_xol_area = area;
 	ret = 0;
 fail:
 	up_write(&mm->mmap_sem);
-	mmput(mm);
 	return ret;
 }
 
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
