Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 284566B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 13:14:51 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3234644bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 10:14:49 -0700 (PDT)
Message-ID: <4F79DE84.8020807@openvz.org>
Date: Mon, 02 Apr 2012 21:14:44 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120331201324.GA17565@redhat.com> <20120331203912.GB687@moon> <4F79755B.3030703@openvz.org> <20120402144821.GA3334@redhat.com> <4F79D1AF.7080100@openvz.org> <20120402162733.GI7607@moon>
In-Reply-To: <20120402162733.GI7607@moon>
Content-Type: multipart/mixed;
 boundary="------------020001050501020607050609"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

This is a multi-part message in MIME format.
--------------020001050501020607050609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Cyrill Gorcunov wrote:
> On Mon, Apr 02, 2012 at 08:19:59PM +0400, Konstantin Khlebnikov wrote:
>> Oleg Nesterov wrote:
>>> On 04/02, Konstantin Khlebnikov wrote:
>>>>
>>>> In this patch I leave mm->exe_file lockless.
>>>> After exec/fork we can change it only for current task and only if mm->mm_users == 1.
>>>>
>>>> something like this:
>>>>
>>>> task_lock(current);
>>>
>>> OK, this protects against the race with get_task_mm()
>>>
>>>> if (atomic_read(&current->mm->mm_users) == 1)
>>>
>>> this means PR_SET_MM_EXE_FILE can fail simply because someone did
>>> get_task_mm(). Or the caller is multithreaded.
>>
>> This is sad, seems like we should keep mm->exe_file protection by mm->mmap_sem.
>> So, I'll rework this patch...
>
> Ah, it's about locking. I misundertand it at first.
> Oleg, forget about my email then.

Yes, it's about locking. Please review patch for your code from attachment.

--------------020001050501020607050609
Content-Type: text/plain;
 name="diff-pr-set-mm-exe-file-without-vm_executable"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="diff-pr-set-mm-exe-file-without-vm_executable"

diff --git a/include/linux/sched.h b/include/linux/sched.h
index cff94cd..4a41270 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -437,6 +437,7 @@ extern int get_dumpable(struct mm_struct *mm);
 					/* leave room for more dump flags */
 #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
 #define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
+#define MMF_EXE_FILE_CHANGED	18	/* see prctl(PR_SET_MM_EXE_FILE) */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/sys.c b/kernel/sys.c
index da660f3..b217069 100644
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
@@ -1745,17 +1739,28 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (err)
 		goto exit;
 
+	down_write(&mm->mmap_sem);
+	/*
+	 * Forbid mm->exe_file change if there are mapped some other files.
+	 */
+	err = -EEXIST;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_file &&
+		    !path_equal(&vma->vm_file->f_path, &exe_file->f_path))
+			goto out_unlock;
+	}
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
+	err = -EBUSY;
+	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
+		goto out_unlock;
+	set_mm_exe_file(mm, exe_file);
+	err = 0;
+out_unlock:
 	up_write(&mm->mmap_sem);
 
 exit:

--------------020001050501020607050609--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
