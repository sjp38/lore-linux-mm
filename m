Message-ID: <4692D616.4010004@oracle.com>
Date: Mon, 09 Jul 2007 17:43:02 -0700
From: Herbert van den Bergh <Herbert.van.den.Bergh@oracle.com>
MIME-Version: 1.0
Subject: [PATCH] include private data mappings in RLIMIT_DATA limit
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Dave McCracken <dave.mccracken@oracle.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

This patch changes how the kernel limits memory allocations that are
controlled by setrlimit() using the RLIMIT_DATA resource.  Currently the
kernel can limit the size of a process data, bss, and heap, but does not
limit the amount of process private memory that can be allocated with
the mmap() call.  Since malloc() calls mmap() to allocate process memory
once brk() calls can no longer grow the heap, process private memory
allocations cannot be limited with RLIMIT_DATA.

With this patch, not only memory in the data segment of a process, but
also private data mappings, both file-based and anonymous, are counted
toward the RLIMIT_DATA resource limit.  Executable mappings, such as
text segments of shared objects, are not counted toward the private data
limit.  The result is that malloc() will fail once the combined size of
the data segment and private data mappings reaches this limit.

This brings the Linux behavior in line with what is documented in the
POSIX man page for setrlimit(3p).

Signed-off-by: Herbert van den Bergh (herbert.van.den.bergh@oracle.com)
Signed-off-by: Dave McCracken (dave.mccracken@oracle.com)

--- linux-2.6.22/fs/proc/task_mmu.c.orig	2007-07-08 16:32:17.000000000 -0700
+++ linux-2.6.22/fs/proc/task_mmu.c	2007-07-09 14:41:50.000000000 -0700
@@ -31,7 +31,7 @@ char *task_mem(struct mm_struct *mm, cha
 	if (hiwater_rss < mm->hiwater_rss)
 		hiwater_rss = mm->hiwater_rss;
 
-	data = mm->total_vm - mm->shared_vm - mm->stack_vm;
+	data = mm->total_vm - mm->shared_vm - mm->stack_vm - mm->exec_vm;
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	buffer += sprintf(buffer,
--- linux-2.6.22/mm/mprotect.c.orig	2007-07-08 16:32:17.000000000 -0700
+++ linux-2.6.22/mm/mprotect.c	2007-07-09 14:41:50.000000000 -0700
@@ -162,6 +162,22 @@ mprotect_fixup(struct vm_area_struct *vm
 		}
 	}
 
+	/* 
+	 * Check against private data size limit. When execute permission
+	 * is removed, the mapping is counted toward the private data size.
+	 */
+	if (!(newflags & VM_EXEC) && (vma->vm_flags & VM_EXEC)) {
+		unsigned long rlim;
+		rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+		if (rlim < RLIM_INFINITY) {
+			unsigned long priv_vm;
+			priv_vm = mm->total_vm - mm->shared_vm - mm->exec_vm;
+			priv_vm <<= PAGE_SHIFT;
+			if (priv_vm + (end - start) > rlim)
+				return -ENOMEM;
+		}
+	}
+
 	/*
 	 * First try to merge with previous and/or next vma.
 	 */
--- linux-2.6.22/mm/mremap.c.orig	2007-07-08 16:32:17.000000000 -0700
+++ linux-2.6.22/mm/mremap.c	2007-07-09 14:41:50.000000000 -0700
@@ -343,6 +343,23 @@ unsigned long do_mremap(unsigned long ad
 		goto out;
 	}
 
+	/*
+	 * Check against private data size limit. Count memory allocations 
+	 * which are not shared and not executable code as private data.
+	 */
+	if (!(vma->vm_flags & (VM_EXEC|VM_SHARED))) {
+		unsigned long rlim;
+		rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+		if (rlim < RLIM_INFINITY) {
+			unsigned long priv_vm;
+			struct mm_struct *mm = current->mm;
+			priv_vm = mm->total_vm - mm->shared_vm - mm->exec_vm;
+			priv_vm <<= PAGE_SHIFT;
+			if (priv_vm + (new_len - old_len) > rlim)
+				goto out;
+		}
+	}
+
 	if (vma->vm_flags & VM_ACCOUNT) {
 		charged = (new_len - old_len) >> PAGE_SHIFT;
 		if (security_vm_enough_memory(charged))
--- linux-2.6.22/mm/mmap.c.orig	2007-07-08 16:32:17.000000000 -0700
+++ linux-2.6.22/mm/mmap.c	2007-07-09 14:41:50.000000000 -0700
@@ -245,16 +245,6 @@ asmlinkage unsigned long sys_brk(unsigne
 	if (brk < mm->end_code)
 		goto out;
 
-	/*
-	 * Check against rlimit here. If this check is done later after the test
-	 * of oldbrk with newbrk then it can escape the test and let the data
-	 * segment grow beyond its set limit the in case where the limit is
-	 * not page aligned -Ram Gupta
-	 */
-	rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
-	if (rlim < RLIM_INFINITY && brk - mm->start_data > rlim)
-		goto out;
-
 	newbrk = PAGE_ALIGN(brk);
 	oldbrk = PAGE_ALIGN(mm->brk);
 	if (oldbrk == newbrk)
@@ -267,6 +257,19 @@ asmlinkage unsigned long sys_brk(unsigne
 		goto out;
 	}
 
+	/*
+	 * Check against private data size limit. Count memory allocations 
+	 * which are not shared and not executable code as private data.
+	 */
+	rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+	if (rlim < RLIM_INFINITY) {
+		unsigned long priv_vm;
+		priv_vm = mm->total_vm - mm->shared_vm - mm->exec_vm;
+		priv_vm <<= PAGE_SHIFT;
+		if (priv_vm + (newbrk-oldbrk) > rlim)
+			goto out;
+	}
+
 	/* Check against existing mmap mappings. */
 	if (find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE))
 		goto out;
@@ -875,7 +878,8 @@ void vm_stat_account(struct mm_struct *m
 		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
 
 	if (file) {
-		mm->shared_vm += pages;
+		if (flags & VM_SHARED)
+			mm->shared_vm += pages;
 		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
 			mm->exec_vm += pages;
 	} else if (flags & stack_flags)
@@ -1041,6 +1045,21 @@ munmap_back:
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
+	/*
+	 * Check against private data size limit. Count memory allocations 
+	 * which are not shared and not executable code as private data.
+	 */
+	if (!(vm_flags & (VM_SHARED|VM_EXEC))) {
+		unsigned long rlim, priv_vm;
+		rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+		if (rlim < RLIM_INFINITY) {
+			priv_vm = mm->total_vm - mm->shared_vm - mm->exec_vm;
+			priv_vm <<= PAGE_SHIFT;
+			if (priv_vm + len > rlim)
+				return -ENOMEM;
+		}
+	}
+
 	if (accountable && (!(flags & MAP_NORESERVE) ||
 			    sysctl_overcommit_memory == OVERCOMMIT_NEVER)) {
 		if (vm_flags & VM_SHARED) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
