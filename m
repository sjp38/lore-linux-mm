Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 36C476B0037
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:50:57 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id l4so2524737lbv.30
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:56 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id zt5si27591569lbb.48.2014.07.24.09.50.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 09:50:54 -0700 (PDT)
Received: by mail-la0-f48.google.com with SMTP id gl10so2107183lab.7
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:54 -0700 (PDT)
Message-Id: <20140724165047.597307734@openvz.org>
Date: Thu, 24 Jul 2014 20:47:00 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 3/4] prctl: PR_SET_MM -- Factor out mmap_sem when update mm::exe_file
References: <20140724164657.452106845@openvz.org>
Content-Disposition: inline; filename=prctl-rework-prctl_set_mm_exe_file-locked
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gorcunov@openvz.org, keescook@chromium.org, tj@kernel.org, akpm@linux-foundation.org, avagin@openvz.org, ebiederm@xmission.com, hpa@zytor.com, serge.hallyn@canonical.com, xemul@parallels.com, segoon@openwall.com, kamezawa.hiroyu@jp.fujitsu.com, mtk.manpages@gmail.com, jln@google.com

Instead of taking mm->mmap_sem inside prctl_set_mm_exe_file move
it out of and rename the helper to prctl_set_mm_exe_file_locked.
This will allow to reuse this function in a next patch.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Vagin <avagin@openvz.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Julien Tinnes <jln@google.com>
---
 kernel/sys.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

Index: linux-2.6.git/kernel/sys.c
===================================================================
--- linux-2.6.git.orig/kernel/sys.c
+++ linux-2.6.git/kernel/sys.c
@@ -1628,12 +1628,14 @@ SYSCALL_DEFINE1(umask, int, mask)
 	return mask;
 }
 
-static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
+static int prctl_set_mm_exe_file_locked(struct mm_struct *mm, unsigned int fd)
 {
 	struct fd exe;
 	struct inode *inode;
 	int err;
 
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
 	exe = fdget(fd);
 	if (!exe.file)
 		return -EBADF;
@@ -1654,8 +1656,6 @@ static int prctl_set_mm_exe_file(struct
 	if (err)
 		goto exit;
 
-	down_write(&mm->mmap_sem);
-
 	/*
 	 * Forbid mm->exe_file change if old file still mapped.
 	 */
@@ -1667,7 +1667,7 @@ static int prctl_set_mm_exe_file(struct
 			if (vma->vm_file &&
 			    path_equal(&vma->vm_file->f_path,
 				       &mm->exe_file->f_path))
-				goto exit_unlock;
+				goto exit;
 	}
 
 	/*
@@ -1678,13 +1678,10 @@ static int prctl_set_mm_exe_file(struct
 	 */
 	err = -EPERM;
 	if (test_and_set_bit(MMF_EXE_FILE_CHANGED, &mm->flags))
-		goto exit_unlock;
+		goto exit;
 
 	err = 0;
 	set_mm_exe_file(mm, exe.file);	/* this grabs a reference to exe.file */
-exit_unlock:
-	up_write(&mm->mmap_sem);
-
 exit:
 	fdput(exe);
 	return err;
@@ -1704,8 +1701,12 @@ static int prctl_set_mm(int opt, unsigne
 	if (!capable(CAP_SYS_RESOURCE))
 		return -EPERM;
 
-	if (opt == PR_SET_MM_EXE_FILE)
-		return prctl_set_mm_exe_file(mm, (unsigned int)addr);
+	if (opt == PR_SET_MM_EXE_FILE) {
+		down_write(&mm->mmap_sem);
+		error = prctl_set_mm_exe_file_locked(mm, (unsigned int)addr);
+		up_write(&mm->mmap_sem);
+		return error;
+	}
 
 	if (addr >= TASK_SIZE || addr < mmap_min_addr)
 		return -EINVAL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
