Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A08C36B0024
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t18so10028677plo.9
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si4819991pgf.480.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 14/64] fs/coredump: teach about range locking
Date: Mon,  5 Feb 2018 02:27:04 +0100
Message-Id: <20180205012754.23615-15-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

coredump_wait() needs mmap_sem such that zap_threads()
is stable. The conversion is trivial as the mmap_sem
is only used in the same function context. No change
in semantics.

In addition, we need an mmrange in exec_mmap() as mmap_sem
is needed for de_thread() or coredump (for core_state and
changing tsk->mm) scenarios. No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 fs/coredump.c |  5 +++--
 fs/exec.c     | 18 ++++++++++--------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 1e2c87acac9b..ad91712498fc 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -412,17 +412,18 @@ static int coredump_wait(int exit_code, struct core_state *core_state)
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	int core_waiters = -EBUSY;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	init_completion(&core_state->startup);
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	if (!mm->core_state)
 		core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	if (core_waiters > 0) {
 		struct core_thread *ptr;
diff --git a/fs/exec.c b/fs/exec.c
index e46752874b47..a61ac9e81169 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -294,12 +294,13 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	int err;
 	struct vm_area_struct *vma = NULL;
 	struct mm_struct *mm = bprm->mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma)
 		return -ENOMEM;
 
-	if (down_write_killable(&mm->mmap_sem)) {
+	if (mm_write_lock_killable(mm, &mmrange)) {
 		err = -EINTR;
 		goto err_free;
 	}
@@ -324,11 +325,11 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 
 	mm->stack_vm = mm->total_vm = 1;
 	arch_bprm_mm_init(mm, vma);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 err_free:
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
@@ -739,7 +740,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	vm_flags = VM_STACK_FLAGS;
@@ -796,7 +797,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		ret = -EFAULT;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL(setup_arg_pages);
@@ -1011,6 +1012,7 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct *old_mm, *active_mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -1025,9 +1027,9 @@ static int exec_mmap(struct mm_struct *mm)
 		 * through with the exec.  We must hold mmap_sem around
 		 * checking core_state and changing tsk->mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+		mm_read_lock(old_mm, &mmrange);
 		if (unlikely(old_mm->core_state)) {
-			up_read(&old_mm->mmap_sem);
+			mm_read_unlock(old_mm, &mmrange);
 			return -EINTR;
 		}
 	}
@@ -1040,7 +1042,7 @@ static int exec_mmap(struct mm_struct *mm)
 	vmacache_flush(tsk);
 	task_unlock(tsk);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		mm_read_unlock(old_mm, &mmrange);
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
 		mm_update_next_owner(old_mm);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
