Date: Wed, 13 Aug 2003 09:58:14 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] Deprecate /proc/#/statm
Message-ID: <20030813075814.GA6182@k3.hellgate.ch>
References: <20030811090213.GA11939@k3.hellgate.ch> <20030811160222.GE3170@holomorphy.com> <20030811215235.GB13180@k3.hellgate.ch> <20030811221646.GF3170@holomorphy.com> <20030812104046.GA6606@k3.hellgate.ch> <20030813003620.GG3170@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030813003620.GG3170@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Aug 2003 17:36:20 -0700, William Lee Irwin III wrote:
> Best to just delete the code instead of the #if 0

Like this?

Roger

diff -ur linux-2.5.orig/fs/proc/array.c linux-2.5/fs/proc/array.c
--- linux-2.5.orig/fs/proc/array.c	2003-08-13 09:50:15.485989476 +0200
+++ linux-2.5/fs/proc/array.c	2003-08-13 09:45:03.646004248 +0200
@@ -388,19 +388,10 @@
 	return res;
 }
 
-extern int task_statm(struct mm_struct *, int *, int *, int *, int *);
 int proc_pid_statm(struct task_struct *task, char *buffer)
 {
 	int size = 0, resident = 0, shared = 0, text = 0, lib = 0, data = 0;
-	struct mm_struct *mm = get_task_mm(task);
-	
-	if (mm) {
-		down_read(&mm->mmap_sem);
-		size = task_statm(mm, &shared, &text, &data, &resident);
-		up_read(&mm->mmap_sem);
-
-		mmput(mm);
-	}
+	/* TODO Rip /proc/#/statm out in 2.7 */
 
 	return sprintf(buffer,"%d %d %d %d %d %d %d\n",
 		       size, resident, shared, text, lib, data, 0);
diff -ur linux-2.5.orig/fs/proc/task_mmu.c linux-2.5/fs/proc/task_mmu.c
--- linux-2.5.orig/fs/proc/task_mmu.c	2003-08-13 09:45:57.507057766 +0200
+++ linux-2.5/fs/proc/task_mmu.c	2003-08-13 09:41:41.844772701 +0200
@@ -48,33 +48,6 @@
 	return PAGE_SIZE * mm->total_vm;
 }
 
-int task_statm(struct mm_struct *mm, int *shared, int *text,
-	       int *data, int *resident)
-{
-	struct vm_area_struct *vma;
-	int size = 0;
-
-	*resident = mm->rss;
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		int pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
-
-		size += pages;
-		if (is_vm_hugetlb_page(vma)) {
-			if (!(vma->vm_flags & VM_DONTCOPY))
-				*shared += pages;
-			continue;
-		}
-		if (vma->vm_flags & VM_SHARED || !list_empty(&vma->shared))
-			*shared += pages;
-		if (vma->vm_flags & VM_EXECUTABLE)
-			*text += pages;
-		else
-			*data += pages;
-	}
-
-	return size;
-}
-
 static int show_map(struct seq_file *m, void *v)
 {
 	struct vm_area_struct *map = v;
diff -ur linux-2.5.orig/fs/proc/task_nommu.c linux-2.5/fs/proc/task_nommu.c
--- linux-2.5.orig/fs/proc/task_nommu.c	2003-08-13 09:45:57.509057471 +0200
+++ linux-2.5/fs/proc/task_nommu.c	2003-08-13 09:42:06.212178570 +0200
@@ -75,28 +75,6 @@
 	return vsize;
 }
 
-int task_statm(struct mm_struct *mm, int *shared, int *text,
-	       int *data, int *resident)
-{
-	struct mm_tblock_struct *tbp;
-	int size = kobjsize(mm);
-	
-	for (tbp = &mm->context.tblock; tbp; tbp = tbp->next) {
-		if (tbp->next)
-			size += kobjsize(tbp->next);
-		if (tbp->rblock) {
-			size += kobjsize(tbp->rblock);
-			size += kobjsize(tbp->rblock->kblock);
-		}
-	}
-
-	size += (*text = mm->end_code - mm->start_code);
-	size += (*data = mm->start_stack - mm->start_data);
-
-	*resident = size;
-	return size;
-}
-
 /*
  * Albert D. Cahalan suggested to fake entries for the traditional
  * sections here.  This might be worth investigating.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
