Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1D50A8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:45:45 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 resend 03/12] mm: arch: make get_gate_vma take an mm_struct instead of a task_struct
Date: Wed, 23 Mar 2011 10:43:52 -0400
Message-Id: <1300891441-16280-4-git-send-email-wilsons@start.ca>
In-Reply-To: <1300891441-16280-1-git-send-email-wilsons@start.ca>
References: <1300891441-16280-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michel Lespinasse <walken@google.com>, Andi Kleen <ak@linux.intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Wilson <wilsons@start.ca>

Morally, the presence of a gate vma is more an attribute of a particular mm than
a particular task.  Moreover, dropping the dependency on task_struct will help
make both existing and future operations on mm's more flexible and convenient.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: Michel Lespinasse <walken@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/powerpc/kernel/vdso.c         |    2 +-
 arch/s390/kernel/vdso.c            |    2 +-
 arch/sh/kernel/vsyscall/vsyscall.c |    2 +-
 arch/x86/mm/init_64.c              |    6 +++---
 arch/x86/vdso/vdso32-setup.c       |   11 ++++++-----
 fs/binfmt_elf.c                    |    2 +-
 fs/proc/task_mmu.c                 |    8 +++++---
 include/linux/mm.h                 |    2 +-
 mm/memory.c                        |    4 ++--
 mm/mlock.c                         |    4 ++--
 10 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index fd87287..6169f17 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -830,7 +830,7 @@ int in_gate_area(struct task_struct *task, unsigned long addr)
 	return 0;
 }
 
-struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 	return NULL;
 }
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index f438d74..d19f305 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -347,7 +347,7 @@ int in_gate_area(struct task_struct *task, unsigned long addr)
 	return 0;
 }
 
-struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 	return NULL;
 }
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 242117c..3f9b6f4 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -94,7 +94,7 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
-struct vm_area_struct *get_gate_vma(struct task_struct *task)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 	return NULL;
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index c14a542..fa56f9b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -870,10 +870,10 @@ static struct vm_area_struct gate_vma = {
 	.vm_flags	= VM_READ | VM_EXEC
 };
 
-struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 #ifdef CONFIG_IA32_EMULATION
-	if (test_tsk_thread_flag(tsk, TIF_IA32))
+	if (!mm || mm->context.ia32_compat)
 		return NULL;
 #endif
 	return &gate_vma;
@@ -881,7 +881,7 @@ struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
 
 int in_gate_area(struct task_struct *task, unsigned long addr)
 {
-	struct vm_area_struct *vma = get_gate_vma(task);
+	struct vm_area_struct *vma = get_gate_vma(task->mm);
 
 	if (!vma)
 		return 0;
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 36df991..1f651f6 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -417,11 +417,12 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
-struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
-	struct mm_struct *mm = tsk->mm;
-
-	/* Check to see if this task was created in compat vdso mode */
+	/*
+	 * Check to see if the corresponding task was created in compat vdso
+	 * mode.
+	 */
 	if (mm && mm->context.vdso == (void *)VDSO_HIGH_BASE)
 		return &gate_vma;
 	return NULL;
@@ -429,7 +430,7 @@ struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
 
 int in_gate_area(struct task_struct *task, unsigned long addr)
 {
-	const struct vm_area_struct *vma = get_gate_vma(task);
+	const struct vm_area_struct *vma = get_gate_vma(task->mm);
 
 	return vma && addr >= vma->vm_start && addr < vma->vm_end;
 }
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index d5b640b..bbabdcc 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1906,7 +1906,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 	segs = current->mm->map_count;
 	segs += elf_core_extra_phdrs();
 
-	gate_vma = get_gate_vma(current);
+	gate_vma = get_gate_vma(current->mm);
 	if (gate_vma != NULL)
 		segs++;
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 60b9148..bb548d4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -126,7 +126,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
 		return NULL;
 	down_read(&mm->mmap_sem);
 
-	tail_vma = get_gate_vma(priv->task);
+	tail_vma = get_gate_vma(priv->task->mm);
 	priv->tail_vma = tail_vma;
 
 	/* Start with last addr hint */
@@ -277,7 +277,8 @@ static int show_map(struct seq_file *m, void *v)
 	show_map_vma(m, vma);
 
 	if (m->count < m->size)  /* vma is copied successfully */
-		m->version = (vma != get_gate_vma(task))? vma->vm_start: 0;
+		m->version = (vma != get_gate_vma(task->mm))
+			? vma->vm_start : 0;
 	return 0;
 }
 
@@ -436,7 +437,8 @@ static int show_smap(struct seq_file *m, void *v)
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
 	if (m->count < m->size)  /* vma is copied successfully */
-		m->version = (vma != get_gate_vma(task)) ? vma->vm_start : 0;
+		m->version = (vma != get_gate_vma(task->mm))
+			? vma->vm_start : 0;
 	return 0;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6385fc..b571921 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1568,7 +1568,7 @@ static inline bool kernel_page_present(struct page *page) { return true; }
 #endif /* CONFIG_HIBERNATION */
 #endif
 
-extern struct vm_area_struct *get_gate_vma(struct task_struct *tsk);
+extern struct vm_area_struct *get_gate_vma(struct mm_struct *mm);
 #ifdef	__HAVE_ARCH_GATE_AREA
 int in_gate_area_no_task(unsigned long addr);
 int in_gate_area(struct task_struct *task, unsigned long addr);
diff --git a/mm/memory.c b/mm/memory.c
index 5823698..aec7cbd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1439,7 +1439,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		vma = find_extend_vma(mm, start);
 		if (!vma && in_gate_area(tsk, start)) {
 			unsigned long pg = start & PAGE_MASK;
-			struct vm_area_struct *gate_vma = get_gate_vma(tsk);
+			struct vm_area_struct *gate_vma = get_gate_vma(tsk->mm);
 			pgd_t *pgd;
 			pud_t *pud;
 			pmd_t *pmd;
@@ -3439,7 +3439,7 @@ static int __init gate_vma_init(void)
 __initcall(gate_vma_init);
 #endif
 
-struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
+struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 #ifdef AT_SYSINFO_EHDR
 	return &gate_vma;
diff --git a/mm/mlock.c b/mm/mlock.c
index c3924c7f..2689a08c 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -237,7 +237,7 @@ long mlock_vma_pages_range(struct vm_area_struct *vma,
 
 	if (!((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
 			is_vm_hugetlb_page(vma) ||
-			vma == get_gate_vma(current))) {
+			vma == get_gate_vma(current->mm))) {
 
 		__mlock_vma_pages_range(vma, start, end, NULL);
 
@@ -332,7 +332,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	int lock = newflags & VM_LOCKED;
 
 	if (newflags == vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
-	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current))
+	    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current->mm))
 		goto out;	/* don't set VM_LOCKED,  don't count */
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
