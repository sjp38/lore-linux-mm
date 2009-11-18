Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 958A56B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 09:52:10 -0500 (EST)
From: Jiri Slaby <jslaby@novell.com>
Subject: [PATCH 09/16] MM: use ACCESS_ONCE for rlimits
Date: Wed, 18 Nov 2009 15:51:55 +0100
Message-Id: <1258555922-2064-9-git-send-email-jslaby@novell.com>
In-Reply-To: <4B040A03.2020508@gmail.com>
References: <4B040A03.2020508@gmail.com>
Sender: owner-linux-mm@kvack.org
To: jirislaby@gmail.com
Cc: mingo@elte.hu, nhorman@tuxdriver.com, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, marcin.slusarz@gmail.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, torvalds@linux-foundation.org, Jiri Slaby <jslaby@novell.com>, James Morris <jmorris@namei.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make sure compiler won't do weird things with limits. E.g. fetching
them twice may return 2 different values after writable limits are
implemented.

Signed-off-by: Jiri Slaby <jslaby@novell.com>
Cc: James Morris <jmorris@namei.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org
---
 mm/filemap.c |    3 ++-
 mm/mlock.c   |   15 +++++++++------
 mm/mmap.c    |   16 ++++++++++------
 mm/mremap.c  |    3 ++-
 4 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ef169f3..667e62e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1971,7 +1971,8 @@ EXPORT_SYMBOL(iov_iter_single_seg_count);
 inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk)
 {
 	struct inode *inode = file->f_mapping->host;
-	unsigned long limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
+	unsigned long limit = ACCESS_ONCE(current->signal->
+			rlim[RLIMIT_FSIZE].rlim_cur);
 
         if (unlikely(*pos < 0))
                 return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index bd6f0e4..9fcd392 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -25,7 +25,7 @@ int can_do_mlock(void)
 {
 	if (capable(CAP_IPC_LOCK))
 		return 1;
-	if (current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur != 0)
+	if (ACCESS_ONCE(current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur) != 0)
 		return 1;
 	return 0;
 }
@@ -490,7 +490,8 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	locked = len >> PAGE_SHIFT;
 	locked += current->mm->locked_vm;
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = ACCESS_ONCE(current->signal->
+			rlim[RLIMIT_MEMLOCK].rlim_cur);
 	lock_limit >>= PAGE_SHIFT;
 
 	/* check against resource limits */
@@ -553,7 +554,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	down_write(&current->mm->mmap_sem);
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = ACCESS_ONCE(current->signal->rlim[RLIMIT_MEMLOCK].
+			rlim_cur);
 	lock_limit >>= PAGE_SHIFT;
 
 	ret = -ENOMEM;
@@ -587,7 +589,8 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	int allowed = 0;
 
 	locked = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = ACCESS_ONCE(current->signal->
+			rlim[RLIMIT_MEMLOCK].rlim_cur);
 	if (lock_limit == RLIM_INFINITY)
 		allowed = 1;
 	lock_limit >>= PAGE_SHIFT;
@@ -621,12 +624,12 @@ int account_locked_memory(struct mm_struct *mm, struct rlimit *rlim,
 
 	down_write(&mm->mmap_sem);
 
-	lim = rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
+	lim = ACCESS_ONCE(rlim[RLIMIT_AS].rlim_cur) >> PAGE_SHIFT;
 	vm   = mm->total_vm + pgsz;
 	if (lim < vm)
 		goto out;
 
-	lim = rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
+	lim = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur) >> PAGE_SHIFT;
 	vm   = mm->locked_vm + pgsz;
 	if (lim < vm)
 		goto out;
diff --git a/mm/mmap.c b/mm/mmap.c
index 73f5e4b..5017ed5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -266,7 +266,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	 * segment grow beyond its set limit the in case where the limit is
 	 * not page aligned -Ram Gupta
 	 */
-	rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+	rlim = ACCESS_ONCE(current->signal->rlim[RLIMIT_DATA].rlim_cur);
 	if (rlim < RLIM_INFINITY && (brk - mm->start_brk) +
 			(mm->end_data - mm->start_data) > rlim)
 		goto out;
@@ -990,7 +990,8 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = ACCESS_ONCE(current->signal->
+				rlim[RLIMIT_MEMLOCK].rlim_cur);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
@@ -1565,7 +1566,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	/* Stack limit test */
-	if (size > rlim[RLIMIT_STACK].rlim_cur)
+	if (size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur))
 		return -ENOMEM;
 
 	/* mlock limit tests */
@@ -1573,7 +1574,8 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		unsigned long locked;
 		unsigned long limit;
 		locked = mm->locked_vm + grow;
-		limit = rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
+		limit = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
+		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
 			return -ENOMEM;
 	}
@@ -2026,7 +2028,8 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = ACCESS_ONCE(current->signal->
+				rlim[RLIMIT_MEMLOCK].rlim_cur);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
@@ -2240,7 +2243,8 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 	unsigned long cur = mm->total_vm;	/* pages */
 	unsigned long lim;
 
-	lim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
+	lim = ACCESS_ONCE(current->signal->rlim[RLIMIT_AS].rlim_cur);
+	lim >>= PAGE_SHIFT;
 
 	if (cur + npages > lim)
 		return 0;
diff --git a/mm/mremap.c b/mm/mremap.c
index 97bff25..809641b 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -358,7 +358,8 @@ unsigned long do_mremap(unsigned long addr,
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = mm->locked_vm << PAGE_SHIFT;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = ACCESS_ONCE(current->signal->
+				rlim[RLIMIT_MEMLOCK].rlim_cur);
 		locked += new_len - old_len;
 		ret = -EAGAIN;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
