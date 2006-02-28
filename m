Subject: [PATCH] Add mm->task_size and fix powerpc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1141106896.3767.34.camel@localhost.localdomain>
References: <1141105154.3767.27.camel@localhost.localdomain>
	 <20060227215416.2bfc1e18.akpm@osdl.org>
	 <1141106896.3767.34.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 28 Feb 2006 17:27:20 +1100
Message-Id: <1141108040.3767.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

This patch adds mm->task_size to keep track of the task size of a given
mm and uses that to fix the powerpc vdso so that it uses the mm task
size to decide what pages to fault in instead of the current thread
flags (which broke when ptracing).

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Index: linux-work/arch/powerpc/kernel/vdso.c
===================================================================
--- linux-work.orig/arch/powerpc/kernel/vdso.c	2005-11-29 10:56:02.000000000 +1100
+++ linux-work/arch/powerpc/kernel/vdso.c	2006-02-28 17:07:18.000000000 +1100
@@ -182,8 +182,8 @@ static struct page * vdso_vma_nopage(str
 	unsigned long offset = address - vma->vm_start;
 	struct page *pg;
 #ifdef CONFIG_PPC64
-	void *vbase = test_thread_flag(TIF_32BIT) ?
-		vdso32_kbase : vdso64_kbase;
+	void *vbase = (vma->vm_mm->task_size > TASK_SIZE_USER32) ?
+		vdso64_kbase : vdso32_kbase;
 #else
 	void *vbase = vdso32_kbase;
 #endif
Index: linux-work/fs/exec.c
===================================================================
--- linux-work.orig/fs/exec.c	2006-02-17 14:38:43.000000000 +1100
+++ linux-work/fs/exec.c	2006-02-28 17:05:50.000000000 +1100
@@ -885,6 +885,12 @@ int flush_old_exec(struct linux_binprm *
 	current->flags &= ~PF_RANDOMIZE;
 	flush_thread();
 
+	/* Set the new mm task size. We have to do that late because it may
+	 * depend on TIF_32BIT which is only updated in flush_thread() on
+	 * some architectures like powerpc
+	 */
+	current->mm->task_size = TASK_SIZE;
+
 	if (bprm->e_uid != current->euid || bprm->e_gid != current->egid || 
 	    file_permission(bprm->file, MAY_READ) ||
 	    (bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP)) {
Index: linux-work/include/linux/sched.h
===================================================================
--- linux-work.orig/include/linux/sched.h	2006-02-17 14:38:43.000000000 +1100
+++ linux-work/include/linux/sched.h	2006-02-28 17:03:52.000000000 +1100
@@ -299,6 +299,7 @@ struct mm_struct {
 				unsigned long pgoff, unsigned long flags);
 	void (*unmap_area) (struct mm_struct *mm, unsigned long addr);
         unsigned long mmap_base;		/* base of mmap area */
+	unsigned long task_size;		/* size of task vm space */
         unsigned long cached_hole_size;         /* if non-zero, the largest hole below free_area_cache */
 	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
 	pgd_t * pgd;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
