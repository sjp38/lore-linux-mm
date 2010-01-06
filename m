Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 645D16B003D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 10:25:00 -0500 (EST)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] MM: use helpers for rlimits
Date: Wed,  6 Jan 2010 16:24:36 +0100
Message-Id: <1262791479-26594-8-git-send-email-jslaby@suse.cz>
In-Reply-To: <1262791479-26594-1-git-send-email-jslaby@suse.cz>
References: <1262791479-26594-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
To: jirislaby@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Make sure compiler won't do weird things with limits. E.g. fetching
them twice may return 2 different values after writable limits are
implemented.

I.e. either use rlimit helpers added in
3e10e716abf3c71bdb5d86b8f507f9e72236c9cd
or ACCESS_ONCE if not applicable.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/filemap.c |    2 +-
 mm/mlock.c   |   12 ++++++------
 mm/mmap.c    |   13 +++++++------
 mm/mremap.c  |    2 +-
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 96ac6b0..4450b75 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1950,7 +1950,7 @@ EXPORT_SYMBOL(iov_iter_single_seg_count);
 inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, int isblk)
 {
 	struct inode *inode = file->f_mapping->host;
-	unsigned long limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
+	unsigned long limit = rlimit(RLIMIT_FSIZE);
 
         if (unlikely(*pos < 0))
                 return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index 2b8335a..8f4e2df 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -25,7 +25,7 @@ int can_do_mlock(void)
 {
 	if (capable(CAP_IPC_LOCK))
 		return 1;
-	if (current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur != 0)
+	if (rlimit(RLIMIT_MEMLOCK) != 0)
 		return 1;
 	return 0;
 }
@@ -487,7 +487,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	locked = len >> PAGE_SHIFT;
 	locked += current->mm->locked_vm;
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
 	/* check against resource limits */
@@ -550,7 +550,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	down_write(&current->mm->mmap_sem);
 
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
 
 	ret = -ENOMEM;
@@ -584,7 +584,7 @@ int user_shm_lock(size_t size, struct user_struct *user)
 	int allowed = 0;
 
 	locked = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	if (lock_limit == RLIM_INFINITY)
 		allowed = 1;
 	lock_limit >>= PAGE_SHIFT;
@@ -618,12 +618,12 @@ int account_locked_memory(struct mm_struct *mm, struct rlimit *rlim,
 
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
index ee22989..7805ac5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -265,7 +265,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	 * segment grow beyond its set limit the in case where the limit is
 	 * not page aligned -Ram Gupta
 	 */
-	rlim = current->signal->rlim[RLIMIT_DATA].rlim_cur;
+	rlim = rlimit(RLIMIT_DATA);
 	if (rlim < RLIM_INFINITY && (brk - mm->start_brk) +
 			(mm->end_data - mm->start_data) > rlim)
 		goto out;
@@ -967,7 +967,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
@@ -1599,7 +1599,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		return -ENOMEM;
 
 	/* Stack limit test */
-	if (size > rlim[RLIMIT_STACK].rlim_cur)
+	if (size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur))
 		return -ENOMEM;
 
 	/* mlock limit tests */
@@ -1607,7 +1607,8 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 		unsigned long locked;
 		unsigned long limit;
 		locked = mm->locked_vm + grow;
-		limit = rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
+		limit = ACCESS_ONCE(rlim[RLIMIT_MEMLOCK].rlim_cur);
+		limit >>= PAGE_SHIFT;
 		if (locked > limit && !capable(CAP_IPC_LOCK))
 			return -ENOMEM;
 	}
@@ -2074,7 +2075,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 		unsigned long locked, lock_limit;
 		locked = len >> PAGE_SHIFT;
 		locked += mm->locked_vm;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
@@ -2288,7 +2289,7 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 	unsigned long cur = mm->total_vm;	/* pages */
 	unsigned long lim;
 
-	lim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
+	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
 
 	if (cur + npages > lim)
 		return 0;
diff --git a/mm/mremap.c b/mm/mremap.c
index 8451908..4c4c803 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -285,7 +285,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (vma->vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
 		locked = mm->locked_vm << PAGE_SHIFT;
-		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
+		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		locked += new_len - old_len;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			goto Eagain;
-- 
1.6.5.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
