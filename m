Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 747F36B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 07:36:29 -0500 (EST)
Received: by iafj26 with SMTP id j26so7581175iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 04:36:28 -0800 (PST)
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Subject: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Date: Sat, 14 Jan 2012 18:05:11 +0530
Message-Id: <1326544511-6547-1-git-send-email-siddhesh.poyarekar@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>

Memory mmaped by glibc for a thread stack currently shows up as a simple
anonymous map, which makes it difficult to differentiate between memory
usage of the thread on stack and other dynamic allocation. Since glibc
already uses MAP_STACK to request this mapping, the attached patch
uses this flag to add additional VM_STACK_FLAGS to the resulting vma
so that the mapping is treated as a stack and not any regular
anonymous mapping. Also, one may use vm_flags to decide if a vma is a
stack.

There is an additional complication with posix threads where the stack
guard for a thread stack may be larger than a page, unlike the case
for process stack where the stack guard is a page long. glibc
implements these guards by calling mprotect on the beginning page(s)
to remove all permissions. I have used this to remove vmas that have
the thread stack guard, from the /proc/maps output.

If accepted, this should also reflect in the man page for mmap since
MAP_STACK will no longer be a noop.

Signed-off-by: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
---
 fs/proc/task_mmu.c |    8 +++++---
 include/linux/mm.h |   17 +++++++++++++++++
 mm/mmap.c          |    3 +++
 3 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e418c5a..98b5275 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -227,7 +227,10 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 		pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
 	}
 
-	/* We don't show the stack guard page in /proc/maps */
+	/* We don't show the stack guard pages in /proc/maps */
+	if (thread_stack_guard(vma))
+		return;
+
 	start = vma->vm_start;
 	if (stack_guard_page_start(vma, start))
 		start += PAGE_SIZE;
@@ -259,8 +262,7 @@ static void show_map_vma(struct seq_file *m, struct vm_area_struct *vma)
 				if (vma->vm_start <= mm->brk &&
 						vma->vm_end >= mm->start_brk) {
 					name = "[heap]";
-				} else if (vma->vm_start <= mm->start_stack &&
-					   vma->vm_end >= mm->start_stack) {
+				} else if (vma_is_stack(vma)) {
 					name = "[stack]";
 				}
 			} else {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..9871e10 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1018,6 +1018,23 @@ static inline int vma_growsdown(struct vm_area_struct *vma, unsigned long addr)
 	return vma && (vma->vm_end == addr) && (vma->vm_flags & VM_GROWSDOWN);
 }
 
+static inline int vma_is_stack(struct vm_area_struct *vma)
+{
+	return vma && (vma->vm_flags & (VM_GROWSUP | VM_GROWSDOWN));
+}
+
+/*
+ * POSIX thread stack guards may be more than a page long and access to it
+ * should return an error (possibly a SIGSEGV). The glibc implementation does
+ * an mprotect(..., ..., PROT_NONE), so our guard vma has no permissions.
+ */
+static inline int thread_stack_guard(struct vm_area_struct *vma)
+{
+	return vma_is_stack(vma) &&
+		((vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC | VM_MAYSHARE)) == 0) &&
+		vma_is_stack((vma->vm_flags & VM_GROWSDOWN)?vma->vm_next:vma->vm_prev);
+}
+
 static inline int stack_guard_page_start(struct vm_area_struct *vma,
 					     unsigned long addr)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..2f9f540 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -992,6 +992,9 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	if (flags & MAP_STACK)
+		vm_flags |= VM_STACK_FLAGS;
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
