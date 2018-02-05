Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 845776B0011
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:05 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 64so18569563pgc.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bi10-v6si6075450plb.113.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:04 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 11/64] prctl: teach about range locking
Date: Mon,  5 Feb 2018 02:27:01 +0100
Message-Id: <20180205012754.23615-12-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

And pass along pointers where needed. No changes in
semantics by using mm locking helpers.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 kernel/sys.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 31a2866b7abd..a9c659c42bd6 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1769,6 +1769,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	struct file *old_exe, *exe_file;
 	struct inode *inode;
 	int err;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	exe = fdget(fd);
 	if (!exe.file)
@@ -1797,7 +1798,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (exe_file) {
 		struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+	        mm_read_lock(mm, &mmrange);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (!vma->vm_file)
 				continue;
@@ -1806,7 +1807,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 				goto exit_err;
 		}
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		fput(exe_file);
 	}
 
@@ -1820,7 +1821,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	fdput(exe);
 	return err;
 exit_err:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	fput(exe_file);
 	goto exit;
 }
@@ -1923,6 +1924,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	unsigned long user_auxv[AT_VECTOR_SIZE];
 	struct mm_struct *mm = current->mm;
 	int error;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
 	BUILD_BUG_ON(sizeof(struct prctl_mm_map) > 256);
@@ -1959,7 +1961,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 			return error;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	/*
 	 * We don't validate if these members are pointing to
@@ -1996,7 +1998,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (prctl_map.auxv_size)
 		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 }
 #endif /* CONFIG_CHECKPOINT_RESTORE */
@@ -2038,6 +2040,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	struct prctl_mm_map prctl_map;
 	struct vm_area_struct *vma;
 	int error;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
 			      opt != PR_SET_MM_MAP &&
@@ -2063,7 +2066,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = find_vma(mm, addr);
 
 	prctl_map.start_code	= mm->start_code;
@@ -2156,7 +2159,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return error;
 }
 
@@ -2196,6 +2199,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	struct task_struct *me = current;
 	unsigned char comm[sizeof(me->comm)];
 	long error;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	error = security_task_prctl(option, arg2, arg3, arg4, arg5);
 	if (error != -ENOSYS)
@@ -2379,13 +2383,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case PR_SET_THP_DISABLE:
 		if (arg3 || arg4 || arg5)
 			return -EINVAL;
-		if (down_write_killable(&me->mm->mmap_sem))
+		if (mm_write_lock_killable(me->mm, &mmrange))
 			return -EINTR;
 		if (arg2)
 			set_bit(MMF_DISABLE_THP, &me->mm->flags);
 		else
 			clear_bit(MMF_DISABLE_THP, &me->mm->flags);
-		up_write(&me->mm->mmap_sem);
+		mm_write_unlock(me->mm, &mmrange);
 		break;
 	case PR_MPX_ENABLE_MANAGEMENT:
 		if (arg2 || arg3 || arg4 || arg5)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
