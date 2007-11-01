Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA14fPiw028767
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:25 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA14fO5P107092
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA14fOs0012591
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Message-Id: <20071101044124.550166000@us.ibm.com>
References: <20071101033508.720885000@us.ibm.com>
Date: Wed, 31 Oct 2007 20:35:10 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 2/3] [RFC][PATCH] Add spinlock in mm to protext exe reference
Content-Disposition: inline; filename=proc_pid_exe_avoid_mmap_sem
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ftp.linux.org.uk>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

The new and relatively unused (compared to VM ops) mm_struct exe file reference
uses the mmap semaphore. It may be preferrable to avoid using the mmap
semaphore at some point in the future. This patch demonstrates one way to avoid
using the mmap semaphore for the exe file reference inside /proc/pid/exe ops.

Unfortunately we can't entirely avoid using the mmap semaphore because we need
to drop the exe file reference when the VMA mapping the executable file does --
otherwise we'd pin mounted filesystems until all applications executed from
them exitted.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---
 include/linux/sched.h |    1 +
 mm/mmap.c             |   17 +++++++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

Index: linux-2.6.23/include/linux/sched.h
===================================================================
--- linux-2.6.23.orig/include/linux/sched.h
+++ linux-2.6.23/include/linux/sched.h
@@ -432,10 +432,11 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
+	spinlock_t exe_file_lock;
 	struct file *exe_file;
 };
 
 struct sighand_struct {
 	atomic_t		count;
Index: linux-2.6.23/mm/mmap.c
===================================================================
--- linux-2.6.23.orig/mm/mmap.c
+++ linux-2.6.23/mm/mmap.c
@@ -1706,27 +1706,27 @@ find_extend_vma(struct mm_struct * mm, u
  * reference; only puts old ones */
 void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	struct file *old_exe_file;
 
-	down_write(&mm->mmap_sem);
+	spin_lock(&mm->exe_file_lock);
 	old_exe_file = mm->exe_file;
 	mm->exe_file = new_exe_file;
-	up_write(&mm->mmap_sem);
+	spin_unlock(&mm->exe_file_lock);
 	if (old_exe_file)
 		fput(old_exe_file);
 }
 
 struct file *get_mm_exe_file(struct mm_struct *mm)
 {
 	struct file *exe_file;
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->exe_file_lock);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->exe_file_lock);
 	return exe_file;
 }
 #endif
 
 /*
@@ -1744,14 +1744,19 @@ static void remove_vma_list(struct mm_st
 
 		mm->total_vm -= nrpages;
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
+		spin_lock(&mm->exe_file_lock);
 		if (mm->exe_file && (vma->vm_file == mm->exe_file)) {
-			fput(mm->exe_file);
+			struct file *old_exe_file = mm->exe_file;
+
 			mm->exe_file = NULL;
-		}
+			spin_unlock(&mm->exe_file_lock);
+			fput(old_exe_file);
+		} else
+			spin_unlock(&mm->exe_file_lock);
 		vma = remove_vma(vma);
 	} while (vma);
 	validate_mm(mm);
 }
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
