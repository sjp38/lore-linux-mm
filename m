Date: Mon, 25 Apr 2005 19:55:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: rlimit_as-checking-fix.patch
Message-Id: <20050425195556.092d0579.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Chris Wright <chrisw@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

review, please?



Address bug #4508: there's potential for wraparound in the various places
where we perform RLIMIT_AS checking.

(I'm a bit worried about acct_stack_growth().  Are we sure that vma->vm_mm is
always equal to current->mm?  If not, then we're comapring some other
process's total_vm with the calling process's rlimits).


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/mm.h |    1 +
 mm/mmap.c          |   24 +++++++++++++++++++-----
 mm/mremap.c        |    6 +++---
 3 files changed, 23 insertions(+), 8 deletions(-)

diff -puN mm/mmap.c~rlimit_as-checking-fix mm/mmap.c
--- 25/mm/mmap.c~rlimit_as-checking-fix	2005-04-25 19:54:35.685820728 -0700
+++ 25-akpm/mm/mmap.c	2005-04-25 19:54:41.867880912 -0700
@@ -1009,8 +1009,7 @@ munmap_back:
 	}
 
 	/* Check against address space limit. */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(mm, len))
 		return -ENOMEM;
 
 	if (accountable && (!(flags & MAP_NORESERVE) ||
@@ -1421,7 +1420,7 @@ static int acct_stack_growth(struct vm_a
 	struct rlimit *rlim = current->signal->rlim;
 
 	/* address space limit tests */
-	if (mm->total_vm + grow > rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT)
+	if (!may_expand_vm(mm, grow))
 		return -ENOMEM;
 
 	/* Stack limit test */
@@ -1848,8 +1847,7 @@ unsigned long do_brk(unsigned long addr,
 	}
 
 	/* Check against address space limits *after* clearing old maps... */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(mm, len))
 		return -ENOMEM;
 
 	if (mm->map_count > sysctl_max_map_count)
@@ -2019,3 +2017,19 @@ struct vm_area_struct *copy_vma(struct v
 	}
 	return new_vma;
 }
+
+/*
+ * Return true if the calling process may expand its vm space by the passed
+ * number of bytes.
+ */
+int may_expand_vm(struct mm_struct *mm, unsigned long nbytes)
+{
+	unsigned long cur = current->mm->total_vm;	/* pages */
+	unsigned long lim;
+
+	lim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
+
+	if (cur + nbytes > lim)
+		return 0;
+	return 1;
+}
diff -puN mm/mremap.c~rlimit_as-checking-fix mm/mremap.c
--- 25/mm/mremap.c~rlimit_as-checking-fix	2005-04-25 19:54:35.685820728 -0700
+++ 25-akpm/mm/mremap.c	2005-04-25 19:54:41.868880760 -0700
@@ -347,10 +347,10 @@ unsigned long do_mremap(unsigned long ad
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			goto out;
 	}
-	ret = -ENOMEM;
-	if ((current->mm->total_vm << PAGE_SHIFT) + (new_len - old_len)
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(current->mm, new_len - old_len)) {
+		ret = -ENOMEM;
 		goto out;
+	}
 
 	if (vma->vm_flags & VM_ACCOUNT) {
 		charged = (new_len - old_len) >> PAGE_SHIFT;
diff -puN include/linux/mm.h~rlimit_as-checking-fix include/linux/mm.h
--- 25/include/linux/mm.h~rlimit_as-checking-fix	2005-04-25 19:54:35.686820576 -0700
+++ 25-akpm/include/linux/mm.h	2005-04-25 19:54:41.869880608 -0700
@@ -726,6 +726,7 @@ extern void __vma_link_rb(struct mm_stru
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
+extern int may_expand_vm(struct mm_struct *mm, unsigned long nbytes);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
