Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BAF116B00EF
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:06:04 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3471141bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:06:03 -0700 (PDT)
Subject: [PATCH mm] c/r: prctl: update prctl_set_mm_exe_file() after
 mm->num_exe_file_vmas removal
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:05:54 +0400
Message-ID: <20120407190554.10193.58306.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

[ fix for "c-r-prctl-add-ability-to-set-new-mm_struct-exe_file-v2" from mm tree ]

After removing mm->num_exe_file_vmas kernel keeps mm->exe_file until final mmput(),
it never becomes NULL while task is alive.

We can check for other mapped files in mm instead of checking mm->num_exe_file_vmas,
and mark mm with flag MMF_EXE_FILE_CHANGED in order to forbid second changing of mm->exe_file.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Matt Helsley <matthltc@us.ibm.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/sched.h |    1 +
 kernel/sys.c          |   31 +++++++++++++++++++------------
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 81a173c..ac61e51 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -437,6 +437,7 @@ extern int get_dumpable(struct mm_struct *mm);
 					/* leave room for more dump flags */
 #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
 #define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
+#define MMF_EXE_FILE_CHANGED	18	/* see prctl_set_mm_exe_file() */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 089cb11..c6cdef5 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1714,17 +1714,11 @@ static bool vma_flags_mismatch(struct vm_area_struct *vma,
 
 static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 {
+	struct vm_area_struct *vma;
 	struct file *exe_file;
 	struct dentry *dentry;
 	int err;
 
-	/*
-	 * Setting new mm::exe_file is only allowed when no VM_EXECUTABLE vma's
-	 * remain. So perform a quick test first.
-	 */
-	if (mm->num_exe_file_vmas)
-		return -EBUSY;
-
 	exe_file = fget(fd);
 	if (!exe_file)
 		return -EBADF;
@@ -1745,17 +1739,30 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (err)
 		goto exit;
 
+	down_write(&mm->mmap_sem);
+
+	/*
+	 * Forbid mm->exe_file change if there are mapped other files.
+	 */
+	err = -EBUSY;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_file && !path_equal(&vma->vm_file->f_path,
+						&exe_file->f_path))
+			goto exit_unlock;
+	}
+
 	/*
 	 * The symlink can be changed only once, just to disallow arbitrary
 	 * transitions malicious software might bring in. This means one
 	 * could make a snapshot over all processes running and monitor
 	 * /proc/pid/exe changes to notice unusual activity if needed.
 	 */
-	down_write(&mm->mmap_sem);
-	if (likely(!mm->exe_file))
-		set_mm_exe_file(mm, exe_file);
-	else
-		err = -EBUSY;
+	err = -EPERM;
+	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
+		goto exit_unlock;
+
+	set_mm_exe_file(mm, exe_file);
+exit_unlock:
 	up_write(&mm->mmap_sem);
 
 exit:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
