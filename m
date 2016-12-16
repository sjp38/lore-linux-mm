Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7693E6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:23:13 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v84so133577409oie.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 00:23:13 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k4si3664197otd.216.2016.12.16.00.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 00:23:11 -0800 (PST)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH 4/4] [RFC!] mm: 'struct mm_struct' reference counting debugging
Date: Fri, 16 Dec 2016 09:22:02 +0100
Message-Id: <20161216082202.21044-4-vegard.nossum@oracle.com>
In-Reply-To: <20161216082202.21044-1-vegard.nossum@oracle.com>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vegard Nossum <vegard.nossum@oracle.com>

Reference counting bugs are hard to debug by their nature since the actual
manifestation of one can occur very far from where the error is introduced
(e.g. a missing get() only manifest as a use-after-free when the reference
count prematurely drops to 0, which could be arbitrarily long after where
the get() should have happened if there are other users). I wrote this patch
to try to track down a suspected 'mm_struct' reference counting bug.

The basic idea is to keep track of all references, not just with a reference
counter, but with an actual reference _list_. Whenever you get() or put() a
reference, you also add or remove yourself, respectively, from the reference
list. This really helps debugging because (for example) you always put a
specific reference, meaning that if that reference was not yours to put, you
will notice it immediately (rather than when the reference counter goes to 0
and you still have an active reference).

The main interface is in <linux/mm_ref_types.h> and <linux/mm_ref.h>, while
the implementation lives in mm/mm_ref.c. Since 'struct mm_struct' has both
->mm_users and ->mm_count, we introduce helpers for both of them, but use
the same data structure for each (struct mm_ref). The low-level rules (i.e.
the ones we have to follow, but which nobody else should really have to
care about since they use the higher-level interface) are:

 - after incrementing ->mm_count you also have to call get_mm_ref()

 - before decrementing ->mm_count you also have to call put_mm_ref()

 - after incrementing ->mm_users you also have to call get_mm_users_ref()

 - before decrementing ->mm_users you also have to call put_mm_users_ref()

The rules that most of the rest of the kernel will care about are:

 - functions that acquire and return a mm_struct should take a
   'struct mm_ref *' which it can pass on to mmget()/mmgrab()/etc.

 - functions that release an mm_struct passed as a parameter should also
   take a 'struct mm_ref *' which it can pass on to mmput()/mmdrop()/etc.

 - any function that temporarily acquires a mm_struct reference should
   use MM_REF() to define an on-stack reference and pass it on to
   mmget()/mmput()/mmgrab()/mmdrop()/etc.

 - any structure that holds an mm_struct pointer must also include a
   'struct mm_ref' member; when the mm_struct pointer is modified you
   would typically also call mmget()/mmgrab()/mmput()/mmdrop() and they
   should be called with this mm_ref

 - you can convert (for example) an on-stack reference to an in-struct
   reference using move_mm_ref(). This is semantically equivalent to
   (atomically) taking the new reference and dropping the old one, but
   doesn't actually need to modify the reference count

I don't really have any delusions about getting this into mainline
(_especially_ not without a CONFIG_MM_REF toggle and zero impact in the =n
case), but I'm posting it in case somebody would find it useful and maybe
to start a discussion about whether this is something that can be usefully
generalized to other core data structures with complicated
reference/ownership models.

The patch really does make it very explicit who holds every reference
taken and where references are implicitly transferred, for example in
finish_task_switch() where the ownership of the reference to 'oldmm' is
implicitly transferred from 'prev->mm' to 'rq->prev_mm', or in
flush_old_exec() where the ownership of the 'bprm->mm' is implicitly
transferred from 'bprm' to 'current->mm'. These ones are a bit subtle
because there is no explicit get()/put() in the code.

There are some users which haven't been converted by this patch (and
many more that haven't been tested) -- x86-64 defconfig should work out of
the box, though. The conversion for the rest of the kernel should be
mostly straightforward (the main challenge was fork/exec).

Thanks-to: Rik van Riel <riel@redhat.com>
Thanks-to: Matthew Wilcox <mawilcox@microsoft.com>
Thanks-to: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 arch/x86/kernel/cpu/common.c            |   2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  25 +++--
 drivers/vhost/vhost.c                   |   7 +-
 drivers/vhost/vhost.h                   |   1 +
 fs/exec.c                               |  20 +++-
 fs/proc/array.c                         |  15 +--
 fs/proc/base.c                          |  97 ++++++++++++-------
 fs/proc/internal.h                      |   4 +-
 fs/proc/task_mmu.c                      |  50 +++++++---
 include/linux/binfmts.h                 |   1 +
 include/linux/init_task.h               |   1 +
 include/linux/kvm_host.h                |   3 +
 include/linux/mm_ref.h                  |  48 ++++++++++
 include/linux/mm_ref_types.h            |  41 ++++++++
 include/linux/mm_types.h                |   8 ++
 include/linux/mmu_notifier.h            |   8 +-
 include/linux/sched.h                   |  42 +++++---
 kernel/cpuset.c                         |  22 +++--
 kernel/events/core.c                    |   5 +-
 kernel/exit.c                           |   5 +-
 kernel/fork.c                           |  51 ++++++----
 kernel/futex.c                          | 124 +++++++++++++-----------
 kernel/sched/core.c                     |  14 ++-
 kernel/sched/sched.h                    |   1 +
 kernel/sys.c                            |   5 +-
 kernel/trace/trace_output.c             |   5 +-
 kernel/tsacct.c                         |   5 +-
 mm/Makefile                             |   2 +-
 mm/init-mm.c                            |   6 ++
 mm/memory.c                             |   5 +-
 mm/mempolicy.c                          |   5 +-
 mm/migrate.c                            |   5 +-
 mm/mm_ref.c                             | 163 ++++++++++++++++++++++++++++++++
 mm/mmu_context.c                        |   9 +-
 mm/mmu_notifier.c                       |  20 ++--
 mm/oom_kill.c                           |  12 ++-
 mm/process_vm_access.c                  |   5 +-
 mm/swapfile.c                           |  29 +++---
 mm/util.c                               |   5 +-
 virt/kvm/async_pf.c                     |   9 +-
 virt/kvm/kvm_main.c                     |  16 +++-
 41 files changed, 668 insertions(+), 233 deletions(-)
 create mode 100644 include/linux/mm_ref.h
 create mode 100644 include/linux/mm_ref_types.h
 create mode 100644 mm/mm_ref.c

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index b580da4582e1..edf16f695130 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1555,7 +1555,7 @@ void cpu_init(void)
 	for (i = 0; i <= IO_BITMAP_LONGS; i++)
 		t->io_bitmap[i] = ~0UL;
 
-	mmgrab(&init_mm);
+	mmgrab(&init_mm, &me->mm_ref);
 	me->active_mm = &init_mm;
 	BUG_ON(me->mm);
 	enter_lazy_tlb(&init_mm, me);
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index e97f9ade99fc..498d311e1a80 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -34,8 +34,10 @@
 
 struct i915_mm_struct {
 	struct mm_struct *mm;
+	struct mm_ref mm_ref;
 	struct drm_i915_private *i915;
 	struct i915_mmu_notifier *mn;
+	struct mm_ref mn_ref;
 	struct hlist_node node;
 	struct kref kref;
 	struct work_struct work;
@@ -159,7 +161,7 @@ static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
 };
 
 static struct i915_mmu_notifier *
-i915_mmu_notifier_create(struct mm_struct *mm)
+i915_mmu_notifier_create(struct mm_struct *mm, struct mm_ref *mm_ref)
 {
 	struct i915_mmu_notifier *mn;
 	int ret;
@@ -178,7 +180,7 @@ i915_mmu_notifier_create(struct mm_struct *mm)
 	}
 
 	 /* Protected by mmap_sem (write-lock) */
-	ret = __mmu_notifier_register(&mn->mn, mm);
+	ret = __mmu_notifier_register(&mn->mn, mm, mm_ref);
 	if (ret) {
 		destroy_workqueue(mn->wq);
 		kfree(mn);
@@ -217,7 +219,7 @@ i915_mmu_notifier_find(struct i915_mm_struct *mm)
 	down_write(&mm->mm->mmap_sem);
 	mutex_lock(&mm->i915->mm_lock);
 	if ((mn = mm->mn) == NULL) {
-		mn = i915_mmu_notifier_create(mm->mm);
+		mn = i915_mmu_notifier_create(mm->mm, &mm->mn_ref);
 		if (!IS_ERR(mn))
 			mm->mn = mn;
 	}
@@ -260,12 +262,12 @@ i915_gem_userptr_init__mmu_notifier(struct drm_i915_gem_object *obj,
 
 static void
 i915_mmu_notifier_free(struct i915_mmu_notifier *mn,
-		       struct mm_struct *mm)
+		       struct mm_struct *mm, struct mm_ref *mm_ref)
 {
 	if (mn == NULL)
 		return;
 
-	mmu_notifier_unregister(&mn->mn, mm);
+	mmu_notifier_unregister(&mn->mn, mm, mm_ref);
 	destroy_workqueue(mn->wq);
 	kfree(mn);
 }
@@ -341,9 +343,11 @@ i915_gem_userptr_init__mm_struct(struct drm_i915_gem_object *obj)
 		mm->i915 = to_i915(obj->base.dev);
 
 		mm->mm = current->mm;
-		mmgrab(current->mm);
+		INIT_MM_REF(&mm->mm_ref);
+		mmgrab(current->mm, &mm->mm_ref);
 
 		mm->mn = NULL;
+		INIT_MM_REF(&mm->mn_ref);
 
 		/* Protected by dev_priv->mm_lock */
 		hash_add(dev_priv->mm_structs,
@@ -361,8 +365,8 @@ static void
 __i915_mm_struct_free__worker(struct work_struct *work)
 {
 	struct i915_mm_struct *mm = container_of(work, typeof(*mm), work);
-	i915_mmu_notifier_free(mm->mn, mm->mm);
-	mmdrop(mm->mm);
+	i915_mmu_notifier_free(mm->mn, mm->mm, &mm->mn_ref);
+	mmdrop(mm->mm, &mm->mm_ref);
 	kfree(mm);
 }
 
@@ -508,13 +512,14 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 	pvec = drm_malloc_gfp(npages, sizeof(struct page *), GFP_TEMPORARY);
 	if (pvec != NULL) {
 		struct mm_struct *mm = obj->userptr.mm->mm;
+		MM_REF(mm_ref);
 		unsigned int flags = 0;
 
 		if (!obj->userptr.read_only)
 			flags |= FOLL_WRITE;
 
 		ret = -EFAULT;
-		if (mmget_not_zero(mm)) {
+		if (mmget_not_zero(mm, &mm_ref)) {
 			down_read(&mm->mmap_sem);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
@@ -529,7 +534,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 				pinned += ret;
 			}
 			up_read(&mm->mmap_sem);
-			mmput(mm);
+			mmput(mm, &mm_ref);
 		}
 	}
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89c0e97..4470abf94fe8 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -407,6 +407,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 	dev->umem = NULL;
 	dev->iotlb = NULL;
 	dev->mm = NULL;
+	INIT_MM_REF(&dev->mm_ref);
 	dev->worker = NULL;
 	init_llist_head(&dev->work_list);
 	init_waitqueue_head(&dev->wait);
@@ -483,7 +484,7 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 	}
 
 	/* No owner, become one */
-	dev->mm = get_task_mm(current);
+	dev->mm = get_task_mm(current, &dev->mm_ref);
 	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
 	if (IS_ERR(worker)) {
 		err = PTR_ERR(worker);
@@ -507,7 +508,7 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 	dev->worker = NULL;
 err_worker:
 	if (dev->mm)
-		mmput(dev->mm);
+		mmput(dev->mm, &dev->mm_ref);
 	dev->mm = NULL;
 err_mm:
 	return err;
@@ -639,7 +640,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 		dev->worker = NULL;
 	}
 	if (dev->mm)
-		mmput(dev->mm);
+		mmput(dev->mm, &dev->mm_ref);
 	dev->mm = NULL;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_cleanup);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 78f3c5fc02e4..64fdcfa9cf67 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -151,6 +151,7 @@ struct vhost_msg_node {
 
 struct vhost_dev {
 	struct mm_struct *mm;
+	struct mm_ref mm_ref;
 	struct mutex mutex;
 	struct vhost_virtqueue **vqs;
 	int nvqs;
diff --git a/fs/exec.c b/fs/exec.c
index 4e497b9ee71e..13afedb2821d 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -380,7 +380,7 @@ static int bprm_mm_init(struct linux_binprm *bprm)
 	int err;
 	struct mm_struct *mm = NULL;
 
-	bprm->mm = mm = mm_alloc();
+	bprm->mm = mm = mm_alloc(&bprm->mm_ref);
 	err = -ENOMEM;
 	if (!mm)
 		goto err;
@@ -394,7 +394,7 @@ static int bprm_mm_init(struct linux_binprm *bprm)
 err:
 	if (mm) {
 		bprm->mm = NULL;
-		mmdrop(mm);
+		mmdrop(mm, &bprm->mm_ref);
 	}
 
 	return err;
@@ -996,6 +996,8 @@ static int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct *old_mm, *active_mm;
+	MM_REF(old_mm_ref);
+	MM_REF(active_mm_ref);
 
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
@@ -1015,9 +1017,14 @@ static int exec_mmap(struct mm_struct *mm)
 			up_read(&old_mm->mmap_sem);
 			return -EINTR;
 		}
+
+		move_mm_users_ref(old_mm, &current->mm_ref, &old_mm_ref);
 	}
 	task_lock(tsk);
+
 	active_mm = tsk->active_mm;
+	if (!old_mm)
+		move_mm_ref(active_mm, &tsk->mm_ref, &active_mm_ref);
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
@@ -1029,10 +1036,10 @@ static int exec_mmap(struct mm_struct *mm)
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
 		mm_update_next_owner(old_mm);
-		mmput(old_mm);
+		mmput(old_mm, &old_mm_ref);
 		return 0;
 	}
-	mmdrop(active_mm);
+	mmdrop(active_mm, &active_mm_ref);
 	return 0;
 }
 
@@ -1258,6 +1265,7 @@ int flush_old_exec(struct linux_binprm * bprm)
 	if (retval)
 		goto out;
 
+	move_mm_ref(bprm->mm, &bprm->mm_ref, &current->mm_ref);
 	bprm->mm = NULL;		/* We're using it now */
 
 	set_fs(USER_DS);
@@ -1674,6 +1682,8 @@ static int do_execveat_common(int fd, struct filename *filename,
 	if (!bprm)
 		goto out_files;
 
+	INIT_MM_REF(&bprm->mm_ref);
+
 	retval = prepare_bprm_creds(bprm);
 	if (retval)
 		goto out_free;
@@ -1760,7 +1770,7 @@ static int do_execveat_common(int fd, struct filename *filename,
 out:
 	if (bprm->mm) {
 		acct_arg_size(bprm, 0);
-		mmput(bprm->mm);
+		mmput(bprm->mm, &bprm->mm_ref);
 	}
 
 out_unmark:
diff --git a/fs/proc/array.c b/fs/proc/array.c
index 81818adb8e9e..3e02be82c2f4 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -367,14 +367,15 @@ static void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
-	struct mm_struct *mm = get_task_mm(task);
+	MM_REF(mm_ref);
+	struct mm_struct *mm = get_task_mm(task, &mm_ref);
 
 	task_name(m, task);
 	task_state(m, ns, pid, task);
 
 	if (mm) {
 		task_mem(m, mm);
-		mmput(mm);
+		mmput(mm, &mm_ref);
 	}
 	task_sig(m, task);
 	task_cap(m, task);
@@ -397,6 +398,7 @@ static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 	int num_threads = 0;
 	int permitted;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	unsigned long long start_time;
 	unsigned long cmin_flt = 0, cmaj_flt = 0;
 	unsigned long  min_flt = 0,  maj_flt = 0;
@@ -409,7 +411,7 @@ static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 	state = *get_task_state(task);
 	vsize = eip = esp = 0;
 	permitted = ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS | PTRACE_MODE_NOAUDIT);
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (mm) {
 		vsize = task_vsize(mm);
 		/*
@@ -562,7 +564,7 @@ static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
 
 	seq_putc(m, '\n');
 	if (mm)
-		mmput(mm);
+		mmput(mm, &mm_ref);
 	return 0;
 }
 
@@ -582,11 +584,12 @@ int proc_pid_statm(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
 	unsigned long size = 0, resident = 0, shared = 0, text = 0, data = 0;
-	struct mm_struct *mm = get_task_mm(task);
+	MM_REF(mm_ref);
+	struct mm_struct *mm = get_task_mm(task, &mm_ref);
 
 	if (mm) {
 		size = task_statm(mm, &shared, &text, &data, &resident);
-		mmput(mm);
+		mmput(mm, &mm_ref);
 	}
 	/*
 	 * For quick read, open code by putting numbers directly
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 87fd5bf07578..9c8bbfc0ab45 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -201,6 +201,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	char *page;
 	unsigned long count = _count;
 	unsigned long arg_start, arg_end, env_start, env_end;
@@ -214,7 +215,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 	tsk = get_proc_task(file_inode(file));
 	if (!tsk)
 		return -ESRCH;
-	mm = get_task_mm(tsk);
+	mm = get_task_mm(tsk, &mm_ref);
 	put_task_struct(tsk);
 	if (!mm)
 		return 0;
@@ -389,7 +390,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 out_free_page:
 	free_page((unsigned long)page);
 out_mmput:
-	mmput(mm);
+	mmput(mm, &mm_ref);
 	if (rv > 0)
 		*pos += rv;
 	return rv;
@@ -784,34 +785,50 @@ static const struct file_operations proc_single_file_operations = {
 };
 
 
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
+struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode, struct mm_ref *mm_ref)
 {
 	struct task_struct *task = get_proc_task(inode);
 	struct mm_struct *mm = ERR_PTR(-ESRCH);
+	MM_REF(tmp_ref);
 
 	if (task) {
-		mm = mm_access(task, mode | PTRACE_MODE_FSCREDS);
+		mm = mm_access(task, mode | PTRACE_MODE_FSCREDS, &tmp_ref);
 		put_task_struct(task);
 
 		if (!IS_ERR_OR_NULL(mm)) {
 			/* ensure this mm_struct can't be freed */
-			mmgrab(mm);
+			mmgrab(mm, mm_ref);
 			/* but do not pin its memory */
-			mmput(mm);
+			mmput(mm, &tmp_ref);
 		}
 	}
 
 	return mm;
 }
 
+struct mem_private {
+	struct mm_struct *mm;
+	struct mm_ref mm_ref;
+};
+
 static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 {
-	struct mm_struct *mm = proc_mem_open(inode, mode);
+	struct mem_private *priv;
+	struct mm_struct *mm;
 
-	if (IS_ERR(mm))
+	priv = kmalloc(sizeof(struct mem_private), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	INIT_MM_REF(&priv->mm_ref);
+	mm = proc_mem_open(inode, mode, &priv->mm_ref);
+	if (IS_ERR(mm)) {
+		kfree(priv);
 		return PTR_ERR(mm);
+	}
 
-	file->private_data = mm;
+	priv->mm = mm;
+	file->private_data = priv;
 	return 0;
 }
 
@@ -828,7 +845,9 @@ static int mem_open(struct inode *inode, struct file *file)
 static ssize_t mem_rw(struct file *file, char __user *buf,
 			size_t count, loff_t *ppos, int write)
 {
-	struct mm_struct *mm = file->private_data;
+	struct mem_private *priv = file->private_data;
+	struct mm_struct *mm = priv->mm;
+	MM_REF(mm_ref);
 	unsigned long addr = *ppos;
 	ssize_t copied;
 	char *page;
@@ -842,7 +861,7 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 		return -ENOMEM;
 
 	copied = 0;
-	if (!mmget_not_zero(mm))
+	if (!mmget_not_zero(mm, &mm_ref))
 		goto free;
 
 	/* Maybe we should limit FOLL_FORCE to actual ptrace users? */
@@ -877,7 +896,7 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 	}
 	*ppos = addr;
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 free:
 	free_page((unsigned long) page);
 	return copied;
@@ -913,9 +932,11 @@ loff_t mem_lseek(struct file *file, loff_t offset, int orig)
 
 static int mem_release(struct inode *inode, struct file *file)
 {
-	struct mm_struct *mm = file->private_data;
+	struct mem_private *priv = file->private_data;
+	struct mm_struct *mm = priv->mm;
 	if (mm)
-		mmdrop(mm);
+		mmdrop(mm, &priv->mm_ref);
+	kfree(priv);
 	return 0;
 }
 
@@ -935,10 +956,12 @@ static int environ_open(struct inode *inode, struct file *file)
 static ssize_t environ_read(struct file *file, char __user *buf,
 			size_t count, loff_t *ppos)
 {
+	struct mem_private *priv = file->private_data;
 	char *page;
 	unsigned long src = *ppos;
 	int ret = 0;
-	struct mm_struct *mm = file->private_data;
+	struct mm_struct *mm = priv->mm;
+	MM_REF(mm_ref);
 	unsigned long env_start, env_end;
 
 	/* Ensure the process spawned far enough to have an environment. */
@@ -950,7 +973,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		return -ENOMEM;
 
 	ret = 0;
-	if (!mmget_not_zero(mm))
+	if (!mmget_not_zero(mm, &mm_ref))
 		goto free;
 
 	down_read(&mm->mmap_sem);
@@ -988,7 +1011,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		count -= retval;
 	}
 	*ppos = src;
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 free:
 	free_page((unsigned long) page);
@@ -1010,7 +1033,8 @@ static int auxv_open(struct inode *inode, struct file *file)
 static ssize_t auxv_read(struct file *file, char __user *buf,
 			size_t count, loff_t *ppos)
 {
-	struct mm_struct *mm = file->private_data;
+	struct mem_private *priv = file->private_data;
+	struct mm_struct *mm = priv->mm;
 	unsigned int nwords = 0;
 
 	if (!mm)
@@ -1053,6 +1077,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 {
 	static DEFINE_MUTEX(oom_adj_mutex);
 	struct mm_struct *mm = NULL;
+	MM_REF(mm_ref);
 	struct task_struct *task;
 	int err = 0;
 
@@ -1093,7 +1118,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		if (p) {
 			if (atomic_read(&p->mm->mm_users) > 1) {
 				mm = p->mm;
-				mmgrab(mm);
+				mmgrab(mm, &mm_ref);
 			}
 			task_unlock(p);
 		}
@@ -1129,7 +1154,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 			task_unlock(p);
 		}
 		rcu_read_unlock();
-		mmdrop(mm);
+		mmdrop(mm, &mm_ref);
 	}
 err_unlock:
 	mutex_unlock(&oom_adj_mutex);
@@ -1875,6 +1900,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	unsigned long vm_start, vm_end;
 	bool exact_vma_exists = false;
 	struct mm_struct *mm = NULL;
+	MM_REF(mm_ref);
 	struct task_struct *task;
 	const struct cred *cred;
 	struct inode *inode;
@@ -1888,7 +1914,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	if (!task)
 		goto out_notask;
 
-	mm = mm_access(task, PTRACE_MODE_READ_FSCREDS);
+	mm = mm_access(task, PTRACE_MODE_READ_FSCREDS, &mm_ref);
 	if (IS_ERR_OR_NULL(mm))
 		goto out;
 
@@ -1898,7 +1924,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		up_read(&mm->mmap_sem);
 	}
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 	if (exact_vma_exists) {
 		if (task_dumpable(task)) {
@@ -1933,6 +1959,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	struct vm_area_struct *vma;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	int rc;
 
 	rc = -ENOENT;
@@ -1940,7 +1967,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	if (!task)
 		goto out;
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	put_task_struct(task);
 	if (!mm)
 		goto out;
@@ -1960,7 +1987,7 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	up_read(&mm->mmap_sem);
 
 out_mmput:
-	mmput(mm);
+	mmput(mm, &mm_ref);
 out:
 	return rc;
 }
@@ -2034,6 +2061,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	struct task_struct *task;
 	int result;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 
 	result = -ENOENT;
 	task = get_proc_task(dir);
@@ -2048,7 +2076,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	if (dname_to_vma_addr(dentry, &vm_start, &vm_end))
 		goto out_put_task;
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (!mm)
 		goto out_put_task;
 
@@ -2063,7 +2091,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 
 out_no_vma:
 	up_read(&mm->mmap_sem);
-	mmput(mm);
+	mmput(mm, &mm_ref);
 out_put_task:
 	put_task_struct(task);
 out:
@@ -2082,6 +2110,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	struct vm_area_struct *vma;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	unsigned long nr_files, pos, i;
 	struct flex_array *fa = NULL;
 	struct map_files_info info;
@@ -2101,7 +2130,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	if (!dir_emit_dots(file, ctx))
 		goto out_put_task;
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (!mm)
 		goto out_put_task;
 	down_read(&mm->mmap_sem);
@@ -2132,7 +2161,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 			if (fa)
 				flex_array_free(fa);
 			up_read(&mm->mmap_sem);
-			mmput(mm);
+			mmput(mm, &mm_ref);
 			goto out_put_task;
 		}
 		for (i = 0, vma = mm->mmap, pos = 2; vma;
@@ -2164,7 +2193,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	}
 	if (fa)
 		flex_array_free(fa);
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 out_put_task:
 	put_task_struct(task);
@@ -2567,6 +2596,7 @@ static ssize_t proc_coredump_filter_read(struct file *file, char __user *buf,
 {
 	struct task_struct *task = get_proc_task(file_inode(file));
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	char buffer[PROC_NUMBUF];
 	size_t len;
 	int ret;
@@ -2575,12 +2605,12 @@ static ssize_t proc_coredump_filter_read(struct file *file, char __user *buf,
 		return -ESRCH;
 
 	ret = 0;
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (mm) {
 		len = snprintf(buffer, sizeof(buffer), "%08lx\n",
 			       ((mm->flags & MMF_DUMP_FILTER_MASK) >>
 				MMF_DUMP_FILTER_SHIFT));
-		mmput(mm);
+		mmput(mm, &mm_ref);
 		ret = simple_read_from_buffer(buf, count, ppos, buffer, len);
 	}
 
@@ -2596,6 +2626,7 @@ static ssize_t proc_coredump_filter_write(struct file *file,
 {
 	struct task_struct *task;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	unsigned int val;
 	int ret;
 	int i;
@@ -2610,7 +2641,7 @@ static ssize_t proc_coredump_filter_write(struct file *file,
 	if (!task)
 		goto out_no_task;
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (!mm)
 		goto out_no_mm;
 	ret = 0;
@@ -2622,7 +2653,7 @@ static ssize_t proc_coredump_filter_write(struct file *file,
 			clear_bit(i + MMF_DUMP_FILTER_SHIFT, &mm->flags);
 	}
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
  out_no_mm:
 	put_task_struct(task);
  out_no_task:
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 5378441ec1b7..9aed2e391b15 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -280,6 +280,8 @@ struct proc_maps_private {
 	struct inode *inode;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	struct mm_ref mm_open_ref;
+	struct mm_ref mm_start_ref;
 #ifdef CONFIG_MMU
 	struct vm_area_struct *tail_vma;
 #endif
@@ -288,7 +290,7 @@ struct proc_maps_private {
 #endif
 };
 
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
+struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode, struct mm_ref *mm_ref);
 
 extern const struct file_operations proc_pid_maps_operations;
 extern const struct file_operations proc_tid_maps_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c71975293dc8..06ed5d67dd84 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -133,7 +133,7 @@ static void vma_stop(struct proc_maps_private *priv)
 
 	release_task_mempolicy(priv);
 	up_read(&mm->mmap_sem);
-	mmput(mm);
+	mmput(mm, &priv->mm_start_ref);
 }
 
 static struct vm_area_struct *
@@ -167,7 +167,7 @@ static void *m_start(struct seq_file *m, loff_t *ppos)
 		return ERR_PTR(-ESRCH);
 
 	mm = priv->mm;
-	if (!mm || !mmget_not_zero(mm))
+	if (!mm || !mmget_not_zero(mm, &priv->mm_start_ref))
 		return NULL;
 
 	down_read(&mm->mmap_sem);
@@ -232,7 +232,9 @@ static int proc_maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	INIT_MM_REF(&priv->mm_open_ref);
+	INIT_MM_REF(&priv->mm_start_ref);
+	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ, &priv->mm_open_ref);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
@@ -249,7 +251,7 @@ static int proc_map_release(struct inode *inode, struct file *file)
 	struct proc_maps_private *priv = seq->private;
 
 	if (priv->mm)
-		mmdrop(priv->mm);
+		mmdrop(priv->mm, &priv->mm_open_ref);
 
 	return seq_release_private(inode, file);
 }
@@ -997,6 +999,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	struct task_struct *task;
 	char buffer[PROC_NUMBUF];
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	struct vm_area_struct *vma;
 	enum clear_refs_types type;
 	int itype;
@@ -1017,7 +1020,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	task = get_proc_task(file_inode(file));
 	if (!task)
 		return -ESRCH;
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	if (mm) {
 		struct clear_refs_private cp = {
 			.type = type,
@@ -1069,7 +1072,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		flush_tlb_mm(mm);
 		up_read(&mm->mmap_sem);
 out_mm:
-		mmput(mm);
+		mmput(mm, &mm_ref);
 	}
 	put_task_struct(task);
 
@@ -1340,10 +1343,17 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
  * determine which areas of memory are actually mapped and llseek to
  * skip over unmapped regions.
  */
+struct pagemap_private {
+	struct mm_struct *mm;
+	struct mm_ref mm_ref;
+};
+
 static ssize_t pagemap_read(struct file *file, char __user *buf,
 			    size_t count, loff_t *ppos)
 {
-	struct mm_struct *mm = file->private_data;
+	struct pagemap_private *priv = file->private_data;
+	struct mm_struct *mm = priv->mm;
+	MM_REF(mm_ref);
 	struct pagemapread pm;
 	struct mm_walk pagemap_walk = {};
 	unsigned long src;
@@ -1352,7 +1362,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 	unsigned long end_vaddr;
 	int ret = 0, copied = 0;
 
-	if (!mm || !mmget_not_zero(mm))
+	if (!mm || !mmget_not_zero(mm, &mm_ref))
 		goto out;
 
 	ret = -EINVAL;
@@ -1427,28 +1437,40 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 out_free:
 	kfree(pm.buffer);
 out_mm:
-	mmput(mm);
+	mmput(mm, &mm_ref);
 out:
 	return ret;
 }
 
 static int pagemap_open(struct inode *inode, struct file *file)
 {
+	struct pagemap_private *priv;
 	struct mm_struct *mm;
 
-	mm = proc_mem_open(inode, PTRACE_MODE_READ);
-	if (IS_ERR(mm))
+	priv = kmalloc(sizeof(struct pagemap_private), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	mm = proc_mem_open(inode, PTRACE_MODE_READ, &priv->mm_ref);
+	if (IS_ERR(mm)) {
+		kfree(priv);
 		return PTR_ERR(mm);
-	file->private_data = mm;
+	}
+
+	priv->mm = mm;
+	file->private_data = priv;
 	return 0;
 }
 
 static int pagemap_release(struct inode *inode, struct file *file)
 {
-	struct mm_struct *mm = file->private_data;
+	struct pagemap_private *priv = file->private_data;
+	struct mm_struct *mm = priv->mm;
 
 	if (mm)
-		mmdrop(mm);
+		mmdrop(mm, &priv->mm_ref);
+
+	kfree(priv);
 	return 0;
 }
 
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index 1303b570b18c..8bee41838bd5 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -21,6 +21,7 @@ struct linux_binprm {
 	struct page *page[MAX_ARG_PAGES];
 #endif
 	struct mm_struct *mm;
+	struct mm_ref mm_ref;
 	unsigned long p; /* current top of mem */
 	unsigned int
 		cred_prepared:1,/* true if creds already prepared (multiple
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 325f649d77ff..02c9ecf243d1 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -211,6 +211,7 @@ extern struct task_group root_task_group;
 	.cpus_allowed	= CPU_MASK_ALL,					\
 	.nr_cpus_allowed= NR_CPUS,					\
 	.mm		= NULL,						\
+	.mm_ref		= MM_REF_INIT(tsk.mm_ref),			\
 	.active_mm	= &init_mm,					\
 	.restart_block = {						\
 		.fn = do_no_restart_syscall,				\
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 01c0b9cc3915..635d4a84f03b 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -174,6 +174,7 @@ struct kvm_async_pf {
 	struct list_head queue;
 	struct kvm_vcpu *vcpu;
 	struct mm_struct *mm;
+	struct mm_ref mm_ref;
 	gva_t gva;
 	unsigned long addr;
 	struct kvm_arch_async_pf arch;
@@ -376,6 +377,7 @@ struct kvm {
 	spinlock_t mmu_lock;
 	struct mutex slots_lock;
 	struct mm_struct *mm; /* userspace tied to this vm */
+	struct mm_ref mm_ref;
 	struct kvm_memslots *memslots[KVM_ADDRESS_SPACE_NUM];
 	struct srcu_struct srcu;
 	struct srcu_struct irq_srcu;
@@ -424,6 +426,7 @@ struct kvm {
 
 #if defined(CONFIG_MMU_NOTIFIER) && defined(KVM_ARCH_WANT_MMU_NOTIFIER)
 	struct mmu_notifier mmu_notifier;
+	struct mm_ref mmu_notifier_ref;
 	unsigned long mmu_notifier_seq;
 	long mmu_notifier_count;
 #endif
diff --git a/include/linux/mm_ref.h b/include/linux/mm_ref.h
new file mode 100644
index 000000000000..0de29bd64542
--- /dev/null
+++ b/include/linux/mm_ref.h
@@ -0,0 +1,48 @@
+#ifndef LINUX_MM_REF_H
+#define LINUX_MM_REF_H
+
+#include <linux/mm_types.h>
+#include <linux/mm_ref_types.h>
+
+struct mm_struct;
+
+extern void INIT_MM_REF(struct mm_ref *ref);
+
+extern void _get_mm_ref(struct mm_struct *mm, struct list_head *list,
+	struct mm_ref *ref);
+extern void _put_mm_ref(struct mm_struct *mm, struct list_head *list,
+	struct mm_ref *ref);
+extern void _move_mm_ref(struct mm_struct *mm, struct list_head *list,
+	struct mm_ref *old_ref, struct mm_ref *new_ref);
+
+static inline void get_mm_ref(struct mm_struct *mm, struct mm_ref *ref)
+{
+	_get_mm_ref(mm, &mm->mm_count_list, ref);
+}
+
+static inline void put_mm_ref(struct mm_struct *mm, struct mm_ref *ref)
+{
+	_put_mm_ref(mm, &mm->mm_count_list, ref);
+}
+
+static inline void move_mm_ref(struct mm_struct *mm, struct mm_ref *old_ref, struct mm_ref *new_ref)
+{
+	_move_mm_ref(mm, &mm->mm_count_list, old_ref, new_ref);
+}
+
+static inline void get_mm_users_ref(struct mm_struct *mm, struct mm_ref *ref)
+{
+	_get_mm_ref(mm, &mm->mm_users_list, ref);
+}
+
+static inline void put_mm_users_ref(struct mm_struct *mm, struct mm_ref *ref)
+{
+	_put_mm_ref(mm, &mm->mm_users_list, ref);
+}
+
+static inline void move_mm_users_ref(struct mm_struct *mm, struct mm_ref *old_ref, struct mm_ref *new_ref)
+{
+	_move_mm_ref(mm, &mm->mm_users_list, old_ref, new_ref);
+}
+
+#endif
diff --git a/include/linux/mm_ref_types.h b/include/linux/mm_ref_types.h
new file mode 100644
index 000000000000..5c45995688bd
--- /dev/null
+++ b/include/linux/mm_ref_types.h
@@ -0,0 +1,41 @@
+#ifndef LINUX_MM_REF_TYPES_H
+#define LINUX_MM_REF_TYPES_H
+
+#include <linux/list.h>
+#include <linux/stacktrace.h>
+
+#define NR_MM_REF_STACK_ENTRIES 10
+
+enum mm_ref_state {
+	/*
+	 * Pick 0 as uninitialized so we have a chance at catching
+	 * uninitialized references by noticing that they are zero.
+	 *
+	 * The rest are random 32-bit integers.
+	 */
+	MM_REF_UNINITIALIZED	= 0,
+	MM_REF_INITIALIZED	= 0x28076894UL,
+	MM_REF_ACTIVE		= 0xdaf46189UL,
+	MM_REF_INACTIVE		= 0xf5358bafUL,
+};
+
+struct mm_ref {
+	/*
+	 * See ->mm_users_list/->mm_count_list in struct mm_struct.
+	 * Access is protected by ->mm_refs_lock.
+	 */
+	struct list_head list_entry;
+
+	enum mm_ref_state state;
+	int pid;
+	struct stack_trace trace;
+	unsigned long trace_entries[NR_MM_REF_STACK_ENTRIES];
+};
+
+#define MM_REF_INIT(name) \
+	{ LIST_HEAD_INIT(name.list_entry), MM_REF_INITIALIZED, }
+
+#define MM_REF(name) \
+	struct mm_ref name = MM_REF_INIT(name)
+
+#endif
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4a8acedf4b7d..520cde63305d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <linux/workqueue.h>
+#include <linux/mm_ref_types.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -407,8 +408,14 @@ struct mm_struct {
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long highest_vm_end;		/* highest vma end address */
 	pgd_t * pgd;
+
+	spinlock_t mm_refs_lock;		/* Protects mm_users_list and mm_count_list */
 	atomic_t mm_users;			/* How many users with user space? */
+	struct list_head mm_users_list;
+	struct mm_ref mm_users_ref;
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+	struct list_head mm_count_list;
+
 	atomic_long_t nr_ptes;			/* PTE page table pages */
 #if CONFIG_PGTABLE_LEVELS > 2
 	atomic_long_t nr_pmds;			/* PMD page table pages */
@@ -516,6 +523,7 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+	struct mm_ref async_put_ref;
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a1a210d59961..e67867bec2d1 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -201,13 +201,13 @@ static inline int mm_has_notifiers(struct mm_struct *mm)
 }
 
 extern int mmu_notifier_register(struct mmu_notifier *mn,
-				 struct mm_struct *mm);
+				 struct mm_struct *mm, struct mm_ref *mm_ref);
 extern int __mmu_notifier_register(struct mmu_notifier *mn,
-				   struct mm_struct *mm);
+				   struct mm_struct *mm, struct mm_ref *mm_ref);
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
-				    struct mm_struct *mm);
+				    struct mm_struct *mm, struct mm_ref *mm_ref);
 extern void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
-					       struct mm_struct *mm);
+					       struct mm_struct *mm, struct mm_ref *ref);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2ca3e15dad3b..293c64a15dfa 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -25,6 +25,7 @@ struct sched_param {
 #include <linux/errno.h>
 #include <linux/nodemask.h>
 #include <linux/mm_types.h>
+#include <linux/mm_ref.h>
 #include <linux/preempt.h>
 
 #include <asm/page.h>
@@ -808,6 +809,7 @@ struct signal_struct {
 					 * Only settable by CAP_SYS_RESOURCE. */
 	struct mm_struct *oom_mm;	/* recorded mm when the thread group got
 					 * killed by the oom killer */
+	struct mm_ref oom_mm_ref;
 
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
@@ -1546,7 +1548,16 @@ struct task_struct {
 	struct rb_node pushable_dl_tasks;
 #endif
 
+	/*
+	 * ->mm and ->active_mm share the mm_ref. Not ideal IMHO, but that's
+	 * how it's done. For kernel threads, ->mm == NULL, and for user
+	 * threads, ->mm == ->active_mm, so we only need one reference.
+	 *
+	 * See <Documentation/vm/active_mm.txt> for more information.
+	 */
 	struct mm_struct *mm, *active_mm;
+	struct mm_ref mm_ref;
+
 	/* per-thread vma caching */
 	u32 vmacache_seqnum;
 	struct vm_area_struct *vmacache[VMACACHE_SIZE];
@@ -2639,6 +2650,7 @@ extern union thread_union init_thread_union;
 extern struct task_struct init_task;
 
 extern struct   mm_struct init_mm;
+extern struct mm_ref init_mm_ref;
 
 extern struct pid_namespace init_pid_ns;
 
@@ -2870,17 +2882,19 @@ static inline unsigned long sigsp(unsigned long sp, struct ksignal *ksig)
 /*
  * Routines for handling mm_structs
  */
-extern struct mm_struct * mm_alloc(void);
+extern struct mm_struct * mm_alloc(struct mm_ref *ref);
 
-static inline void mmgrab(struct mm_struct *mm)
+static inline void mmgrab(struct mm_struct *mm, struct mm_ref *ref)
 {
 	atomic_inc(&mm->mm_count);
+	get_mm_ref(mm, ref);
 }
 
 /* mmdrop drops the mm and the page tables */
 extern void __mmdrop(struct mm_struct *);
-static inline void mmdrop(struct mm_struct *mm)
+static inline void mmdrop(struct mm_struct *mm, struct mm_ref *ref)
 {
+	put_mm_ref(mm, ref);
 	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
 		__mmdrop(mm);
 }
@@ -2891,41 +2905,47 @@ static inline void mmdrop_async_fn(struct work_struct *work)
 	__mmdrop(mm);
 }
 
-static inline void mmdrop_async(struct mm_struct *mm)
+static inline void mmdrop_async(struct mm_struct *mm, struct mm_ref *ref)
 {
+	put_mm_ref(mm, ref);
 	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
 		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
 		schedule_work(&mm->async_put_work);
 	}
 }
 
-static inline void mmget(struct mm_struct *mm)
+static inline void mmget(struct mm_struct *mm, struct mm_ref *ref)
 {
 	atomic_inc(&mm->mm_users);
+	get_mm_users_ref(mm, ref);
 }
 
-static inline bool mmget_not_zero(struct mm_struct *mm)
+static inline bool mmget_not_zero(struct mm_struct *mm, struct mm_ref *ref)
 {
-	return atomic_inc_not_zero(&mm->mm_users);
+	bool not_zero = atomic_inc_not_zero(&mm->mm_users);
+	if (not_zero)
+		get_mm_users_ref(mm, ref);
+
+	return not_zero;
 }
 
 /* mmput gets rid of the mappings and all user-space */
-extern void mmput(struct mm_struct *);
+extern void mmput(struct mm_struct *, struct mm_ref *);
 #ifdef CONFIG_MMU
 /* same as above but performs the slow path from the async context. Can
  * be called from the atomic context as well
  */
-extern void mmput_async(struct mm_struct *);
+extern void mmput_async(struct mm_struct *, struct mm_ref *ref);
 #endif
 
 /* Grab a reference to a task's mm, if it is not already going away */
-extern struct mm_struct *get_task_mm(struct task_struct *task);
+extern struct mm_struct *get_task_mm(struct task_struct *task, struct mm_ref *mm_ref);
 /*
  * Grab a reference to a task's mm, if it is not already going away
  * and ptrace_may_access with the mode parameter passed to it
  * succeeds.
  */
-extern struct mm_struct *mm_access(struct task_struct *task, unsigned int mode);
+extern struct mm_struct *mm_access(struct task_struct *task, unsigned int mode, struct mm_ref *mm_ref);
 /* Remove the current tasks stale references to the old mm_struct */
 extern void mm_release(struct task_struct *, struct mm_struct *);
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 29f815d2ef7e..66c5778f4052 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -994,6 +994,7 @@ static int update_cpumask(struct cpuset *cs, struct cpuset *trialcs,
 struct cpuset_migrate_mm_work {
 	struct work_struct	work;
 	struct mm_struct	*mm;
+	struct mm_ref		mm_ref;
 	nodemask_t		from;
 	nodemask_t		to;
 };
@@ -1005,24 +1006,25 @@ static void cpuset_migrate_mm_workfn(struct work_struct *work)
 
 	/* on a wq worker, no need to worry about %current's mems_allowed */
 	do_migrate_pages(mwork->mm, &mwork->from, &mwork->to, MPOL_MF_MOVE_ALL);
-	mmput(mwork->mm);
+	mmput(mwork->mm, &mwork->mm_ref);
 	kfree(mwork);
 }
 
 static void cpuset_migrate_mm(struct mm_struct *mm, const nodemask_t *from,
-							const nodemask_t *to)
+							const nodemask_t *to, struct mm_ref *mm_ref)
 {
 	struct cpuset_migrate_mm_work *mwork;
 
 	mwork = kzalloc(sizeof(*mwork), GFP_KERNEL);
 	if (mwork) {
 		mwork->mm = mm;
+		move_mm_users_ref(mm, mm_ref, &mwork->mm_ref);
 		mwork->from = *from;
 		mwork->to = *to;
 		INIT_WORK(&mwork->work, cpuset_migrate_mm_workfn);
 		queue_work(cpuset_migrate_mm_wq, &mwork->work);
 	} else {
-		mmput(mm);
+		mmput(mm, mm_ref);
 	}
 }
 
@@ -1107,11 +1109,12 @@ static void update_tasks_nodemask(struct cpuset *cs)
 	css_task_iter_start(&cs->css, &it);
 	while ((task = css_task_iter_next(&it))) {
 		struct mm_struct *mm;
+		MM_REF(mm_ref);
 		bool migrate;
 
 		cpuset_change_task_nodemask(task, &newmems);
 
-		mm = get_task_mm(task);
+		mm = get_task_mm(task, &mm_ref);
 		if (!mm)
 			continue;
 
@@ -1119,9 +1122,9 @@ static void update_tasks_nodemask(struct cpuset *cs)
 
 		mpol_rebind_mm(mm, &cs->mems_allowed);
 		if (migrate)
-			cpuset_migrate_mm(mm, &cs->old_mems_allowed, &newmems);
+			cpuset_migrate_mm(mm, &cs->old_mems_allowed, &newmems, &mm_ref);
 		else
-			mmput(mm);
+			mmput(mm, &mm_ref);
 	}
 	css_task_iter_end(&it);
 
@@ -1556,7 +1559,8 @@ static void cpuset_attach(struct cgroup_taskset *tset)
 	 */
 	cpuset_attach_nodemask_to = cs->effective_mems;
 	cgroup_taskset_for_each_leader(leader, css, tset) {
-		struct mm_struct *mm = get_task_mm(leader);
+		MM_REF(mm_ref);
+		struct mm_struct *mm = get_task_mm(leader, &mm_ref);
 
 		if (mm) {
 			mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
@@ -1571,9 +1575,9 @@ static void cpuset_attach(struct cgroup_taskset *tset)
 			 */
 			if (is_memory_migrate(cs))
 				cpuset_migrate_mm(mm, &oldcs->old_mems_allowed,
-						  &cpuset_attach_nodemask_to);
+						  &cpuset_attach_nodemask_to, &mm_ref);
 			else
-				mmput(mm);
+				mmput(mm, &mm_ref);
 		}
 	}
 
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 02c8421f8c01..2909d6db3b7a 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7965,6 +7965,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	struct task_struct *task = READ_ONCE(event->ctx->task);
 	struct perf_addr_filter *filter;
 	struct mm_struct *mm = NULL;
+	MM_REF(mm_ref);
 	unsigned int count = 0;
 	unsigned long flags;
 
@@ -7975,7 +7976,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	if (task == TASK_TOMBSTONE)
 		return;
 
-	mm = get_task_mm(event->ctx->task);
+	mm = get_task_mm(event->ctx->task, &mm_ref);
 	if (!mm)
 		goto restart;
 
@@ -8001,7 +8002,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 
 	up_read(&mm->mmap_sem);
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 restart:
 	perf_event_stop(event, 1);
diff --git a/kernel/exit.c b/kernel/exit.c
index b12753840050..d367ef9bcfe6 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -462,6 +462,7 @@ void mm_update_next_owner(struct mm_struct *mm)
 static void exit_mm(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
+	MM_REF(mm_ref);
 	struct core_state *core_state;
 
 	mm_release(tsk, mm);
@@ -500,7 +501,7 @@ static void exit_mm(struct task_struct *tsk)
 		__set_task_state(tsk, TASK_RUNNING);
 		down_read(&mm->mmap_sem);
 	}
-	mmgrab(mm);
+	mmgrab(mm, &mm_ref);
 	BUG_ON(mm != tsk->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
@@ -509,7 +510,7 @@ static void exit_mm(struct task_struct *tsk)
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
-	mmput(mm);
+	mmput(mm, &mm_ref);
 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim();
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index f9c32dc6ccbc..a431a52375d7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -367,7 +367,7 @@ static inline void free_signal_struct(struct signal_struct *sig)
 	 * pgd_dtor so postpone it to the async context
 	 */
 	if (sig->oom_mm)
-		mmdrop_async(sig->oom_mm);
+		mmdrop_async(sig->oom_mm, &sig->oom_mm_ref);
 	kmem_cache_free(signal_cachep, sig);
 }
 
@@ -745,13 +745,22 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 #endif
 }
 
-static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
+static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p, struct mm_ref *mm_ref)
 {
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
+
 	atomic_set(&mm->mm_users, 1);
+	INIT_LIST_HEAD(&mm->mm_users_list);
+	INIT_MM_REF(&mm->mm_users_ref);
+
 	atomic_set(&mm->mm_count, 1);
+	INIT_LIST_HEAD(&mm->mm_count_list);
+
+	get_mm_ref(mm, mm_ref);
+	get_mm_users_ref(mm, &mm->mm_users_ref);
+
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
@@ -821,7 +830,7 @@ static void check_mm(struct mm_struct *mm)
 /*
  * Allocate and initialize an mm_struct.
  */
-struct mm_struct *mm_alloc(void)
+struct mm_struct *mm_alloc(struct mm_ref *ref)
 {
 	struct mm_struct *mm;
 
@@ -830,7 +839,7 @@ struct mm_struct *mm_alloc(void)
 		return NULL;
 
 	memset(mm, 0, sizeof(*mm));
-	return mm_init(mm, current);
+	return mm_init(mm, current, ref);
 }
 
 /*
@@ -868,16 +877,17 @@ static inline void __mmput(struct mm_struct *mm)
 	if (mm->binfmt)
 		module_put(mm->binfmt->module);
 	set_bit(MMF_OOM_SKIP, &mm->flags);
-	mmdrop(mm);
+	mmdrop(mm, &mm->mm_users_ref);
 }
 
 /*
  * Decrement the use count and release all resources for an mm.
  */
-void mmput(struct mm_struct *mm)
+void mmput(struct mm_struct *mm, struct mm_ref *ref)
 {
 	might_sleep();
 
+	put_mm_users_ref(mm, ref);
 	if (atomic_dec_and_test(&mm->mm_users))
 		__mmput(mm);
 }
@@ -890,8 +900,9 @@ static void mmput_async_fn(struct work_struct *work)
 	__mmput(mm);
 }
 
-void mmput_async(struct mm_struct *mm)
+void mmput_async(struct mm_struct *mm, struct mm_ref *ref)
 {
+	put_mm_users_ref(mm, ref);
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		INIT_WORK(&mm->async_put_work, mmput_async_fn);
 		schedule_work(&mm->async_put_work);
@@ -979,7 +990,7 @@ EXPORT_SYMBOL(get_task_exe_file);
  * bumping up the use count.  User must release the mm via mmput()
  * after use.  Typically used by /proc and ptrace.
  */
-struct mm_struct *get_task_mm(struct task_struct *task)
+struct mm_struct *get_task_mm(struct task_struct *task, struct mm_ref *mm_ref)
 {
 	struct mm_struct *mm;
 
@@ -989,14 +1000,14 @@ struct mm_struct *get_task_mm(struct task_struct *task)
 		if (task->flags & PF_KTHREAD)
 			mm = NULL;
 		else
-			mmget(mm);
+			mmget(mm, mm_ref);
 	}
 	task_unlock(task);
 	return mm;
 }
 EXPORT_SYMBOL_GPL(get_task_mm);
 
-struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
+struct mm_struct *mm_access(struct task_struct *task, unsigned int mode, struct mm_ref *mm_ref)
 {
 	struct mm_struct *mm;
 	int err;
@@ -1005,10 +1016,10 @@ struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
 	if (err)
 		return ERR_PTR(err);
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, mm_ref);
 	if (mm && mm != current->mm &&
 			!ptrace_may_access(task, mode)) {
-		mmput(mm);
+		mmput(mm, mm_ref);
 		mm = ERR_PTR(-EACCES);
 	}
 	mutex_unlock(&task->signal->cred_guard_mutex);
@@ -1115,7 +1126,7 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
  * Allocate a new mm structure and copy contents from the
  * mm structure of the passed in task structure.
  */
-static struct mm_struct *dup_mm(struct task_struct *tsk)
+static struct mm_struct *dup_mm(struct task_struct *tsk, struct mm_ref *ref)
 {
 	struct mm_struct *mm, *oldmm = current->mm;
 	int err;
@@ -1126,7 +1137,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 
 	memcpy(mm, oldmm, sizeof(*mm));
 
-	if (!mm_init(mm, tsk))
+	if (!mm_init(mm, tsk, ref))
 		goto fail_nomem;
 
 	err = dup_mmap(mm, oldmm);
@@ -1144,7 +1155,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 free_pt:
 	/* don't put binfmt in mmput, we haven't got module yet */
 	mm->binfmt = NULL;
-	mmput(mm);
+	mmput(mm, ref);
 
 fail_nomem:
 	return NULL;
@@ -1163,6 +1174,7 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 
 	tsk->mm = NULL;
 	tsk->active_mm = NULL;
+	INIT_MM_REF(&tsk->mm_ref);
 
 	/*
 	 * Are we cloning a kernel thread?
@@ -1177,13 +1189,13 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 	vmacache_flush(tsk);
 
 	if (clone_flags & CLONE_VM) {
-		mmget(oldmm);
+		mmget(oldmm, &tsk->mm_ref);
 		mm = oldmm;
 		goto good_mm;
 	}
 
 	retval = -ENOMEM;
-	mm = dup_mm(tsk);
+	mm = dup_mm(tsk, &tsk->mm_ref);
 	if (!mm)
 		goto fail_nomem;
 
@@ -1360,6 +1372,9 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sig->oom_score_adj = current->signal->oom_score_adj;
 	sig->oom_score_adj_min = current->signal->oom_score_adj_min;
 
+	sig->oom_mm = NULL;
+	INIT_MM_REF(&sig->oom_mm_ref);
+
 	sig->has_child_subreaper = current->signal->has_child_subreaper ||
 				   current->signal->is_child_subreaper;
 
@@ -1839,7 +1854,7 @@ static __latent_entropy struct task_struct *copy_process(
 	exit_task_namespaces(p);
 bad_fork_cleanup_mm:
 	if (p->mm)
-		mmput(p->mm);
+		mmput(p->mm, &p->mm_ref);
 bad_fork_cleanup_signal:
 	if (!(clone_flags & CLONE_THREAD))
 		free_signal_struct(p->signal);
diff --git a/kernel/futex.c b/kernel/futex.c
index cbe6056c17c1..3a279ee2166b 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -240,6 +240,7 @@ struct futex_q {
 	struct task_struct *task;
 	spinlock_t *lock_ptr;
 	union futex_key key;
+	struct mm_ref mm_ref;
 	struct futex_pi_state *pi_state;
 	struct rt_mutex_waiter *rt_waiter;
 	union futex_key *requeue_pi_key;
@@ -249,6 +250,7 @@ struct futex_q {
 static const struct futex_q futex_q_init = {
 	/* list gets initialized in queue_me()*/
 	.key = FUTEX_KEY_INIT,
+	/* .mm_ref must be initialized for each futex_q */
 	.bitset = FUTEX_BITSET_MATCH_ANY
 };
 
@@ -336,9 +338,9 @@ static inline bool should_fail_futex(bool fshared)
 }
 #endif /* CONFIG_FAIL_FUTEX */
 
-static inline void futex_get_mm(union futex_key *key)
+static inline void futex_get_mm(union futex_key *key, struct mm_ref *ref)
 {
-	mmgrab(key->private.mm);
+	mmgrab(key->private.mm, ref);
 	/*
 	 * Ensure futex_get_mm() implies a full barrier such that
 	 * get_futex_key() implies a full barrier. This is relied upon
@@ -417,7 +419,7 @@ static inline int match_futex(union futex_key *key1, union futex_key *key2)
  * Can be called while holding spinlocks.
  *
  */
-static void get_futex_key_refs(union futex_key *key)
+static void get_futex_key_refs(union futex_key *key, struct mm_ref *ref)
 {
 	if (!key->both.ptr)
 		return;
@@ -437,7 +439,7 @@ static void get_futex_key_refs(union futex_key *key)
 		ihold(key->shared.inode); /* implies smp_mb(); (B) */
 		break;
 	case FUT_OFF_MMSHARED:
-		futex_get_mm(key); /* implies smp_mb(); (B) */
+		futex_get_mm(key, ref); /* implies smp_mb(); (B) */
 		break;
 	default:
 		/*
@@ -455,7 +457,7 @@ static void get_futex_key_refs(union futex_key *key)
  * a no-op for private futexes, see comment in the get
  * counterpart.
  */
-static void drop_futex_key_refs(union futex_key *key)
+static void drop_futex_key_refs(union futex_key *key, struct mm_ref *ref)
 {
 	if (!key->both.ptr) {
 		/* If we're here then we tried to put a key we failed to get */
@@ -471,7 +473,7 @@ static void drop_futex_key_refs(union futex_key *key)
 		iput(key->shared.inode);
 		break;
 	case FUT_OFF_MMSHARED:
-		mmdrop(key->private.mm);
+		mmdrop(key->private.mm, ref);
 		break;
 	}
 }
@@ -495,7 +497,7 @@ static void drop_futex_key_refs(union futex_key *key)
  * lock_page() might sleep, the caller should not hold a spinlock.
  */
 static int
-get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
+get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw, struct mm_ref *mm_ref)
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
@@ -527,7 +529,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 	if (!fshared) {
 		key->private.mm = mm;
 		key->private.address = address;
-		get_futex_key_refs(key);  /* implies smp_mb(); (B) */
+		get_futex_key_refs(key, mm_ref);  /* implies smp_mb(); (B) */
 		return 0;
 	}
 
@@ -630,7 +632,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 		key->private.mm = mm;
 		key->private.address = address;
 
-		get_futex_key_refs(key); /* implies smp_mb(); (B) */
+		get_futex_key_refs(key, mm_ref); /* implies smp_mb(); (B) */
 
 	} else {
 		struct inode *inode;
@@ -701,9 +703,9 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 	return err;
 }
 
-static inline void put_futex_key(union futex_key *key)
+static inline void put_futex_key(union futex_key *key, struct mm_ref *mm_ref)
 {
-	drop_futex_key_refs(key);
+	drop_futex_key_refs(key, mm_ref);
 }
 
 /**
@@ -1414,13 +1416,14 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
 	union futex_key key = FUTEX_KEY_INIT;
+	MM_REF(mm_ref);
 	int ret;
 	WAKE_Q(wake_q);
 
 	if (!bitset)
 		return -EINVAL;
 
-	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &key, VERIFY_READ);
+	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &key, VERIFY_READ, &mm_ref);
 	if (unlikely(ret != 0))
 		goto out;
 
@@ -1452,7 +1455,7 @@ futex_wake(u32 __user *uaddr, unsigned int flags, int nr_wake, u32 bitset)
 	spin_unlock(&hb->lock);
 	wake_up_q(&wake_q);
 out_put_key:
-	put_futex_key(&key);
+	put_futex_key(&key, &mm_ref);
 out:
 	return ret;
 }
@@ -1466,16 +1469,18 @@ futex_wake_op(u32 __user *uaddr1, unsigned int flags, u32 __user *uaddr2,
 	      int nr_wake, int nr_wake2, int op)
 {
 	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
+	MM_REF(mm_ref1);
+	MM_REF(mm_ref2);
 	struct futex_hash_bucket *hb1, *hb2;
 	struct futex_q *this, *next;
 	int ret, op_ret;
 	WAKE_Q(wake_q);
 
 retry:
-	ret = get_futex_key(uaddr1, flags & FLAGS_SHARED, &key1, VERIFY_READ);
+	ret = get_futex_key(uaddr1, flags & FLAGS_SHARED, &key1, VERIFY_READ, &mm_ref1);
 	if (unlikely(ret != 0))
 		goto out;
-	ret = get_futex_key(uaddr2, flags & FLAGS_SHARED, &key2, VERIFY_WRITE);
+	ret = get_futex_key(uaddr2, flags & FLAGS_SHARED, &key2, VERIFY_WRITE, &mm_ref2);
 	if (unlikely(ret != 0))
 		goto out_put_key1;
 
@@ -1510,8 +1515,8 @@ futex_wake_op(u32 __user *uaddr1, unsigned int flags, u32 __user *uaddr2,
 		if (!(flags & FLAGS_SHARED))
 			goto retry_private;
 
-		put_futex_key(&key2);
-		put_futex_key(&key1);
+		put_futex_key(&key2, &mm_ref2);
+		put_futex_key(&key1, &mm_ref1);
 		goto retry;
 	}
 
@@ -1547,9 +1552,9 @@ futex_wake_op(u32 __user *uaddr1, unsigned int flags, u32 __user *uaddr2,
 	double_unlock_hb(hb1, hb2);
 	wake_up_q(&wake_q);
 out_put_keys:
-	put_futex_key(&key2);
+	put_futex_key(&key2, &mm_ref2);
 out_put_key1:
-	put_futex_key(&key1);
+	put_futex_key(&key1, &mm_ref1);
 out:
 	return ret;
 }
@@ -1563,7 +1568,7 @@ futex_wake_op(u32 __user *uaddr1, unsigned int flags, u32 __user *uaddr2,
  */
 static inline
 void requeue_futex(struct futex_q *q, struct futex_hash_bucket *hb1,
-		   struct futex_hash_bucket *hb2, union futex_key *key2)
+		   struct futex_hash_bucket *hb2, union futex_key *key2, struct mm_ref *mm_ref2)
 {
 
 	/*
@@ -1577,7 +1582,7 @@ void requeue_futex(struct futex_q *q, struct futex_hash_bucket *hb1,
 		plist_add(&q->list, &hb2->chain);
 		q->lock_ptr = &hb2->lock;
 	}
-	get_futex_key_refs(key2);
+	get_futex_key_refs(key2, mm_ref2);
 	q->key = *key2;
 }
 
@@ -1597,9 +1602,9 @@ void requeue_futex(struct futex_q *q, struct futex_hash_bucket *hb1,
  */
 static inline
 void requeue_pi_wake_futex(struct futex_q *q, union futex_key *key,
-			   struct futex_hash_bucket *hb)
+			   struct futex_hash_bucket *hb, struct mm_ref *ref)
 {
-	get_futex_key_refs(key);
+	get_futex_key_refs(key, ref);
 	q->key = *key;
 
 	__unqueue_futex(q);
@@ -1636,7 +1641,8 @@ static int futex_proxy_trylock_atomic(u32 __user *pifutex,
 				 struct futex_hash_bucket *hb1,
 				 struct futex_hash_bucket *hb2,
 				 union futex_key *key1, union futex_key *key2,
-				 struct futex_pi_state **ps, int set_waiters)
+				 struct futex_pi_state **ps, int set_waiters,
+				 struct mm_ref *mm_ref2)
 {
 	struct futex_q *top_waiter = NULL;
 	u32 curval;
@@ -1675,7 +1681,7 @@ static int futex_proxy_trylock_atomic(u32 __user *pifutex,
 	ret = futex_lock_pi_atomic(pifutex, hb2, key2, ps, top_waiter->task,
 				   set_waiters);
 	if (ret == 1) {
-		requeue_pi_wake_futex(top_waiter, key2, hb2);
+		requeue_pi_wake_futex(top_waiter, key2, hb2, mm_ref2);
 		return vpid;
 	}
 	return ret;
@@ -1704,6 +1710,8 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 			 u32 *cmpval, int requeue_pi)
 {
 	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
+	MM_REF(mm_ref1);
+	MM_REF(mm_ref2);
 	int drop_count = 0, task_count = 0, ret;
 	struct futex_pi_state *pi_state = NULL;
 	struct futex_hash_bucket *hb1, *hb2;
@@ -1739,11 +1747,11 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 	}
 
 retry:
-	ret = get_futex_key(uaddr1, flags & FLAGS_SHARED, &key1, VERIFY_READ);
+	ret = get_futex_key(uaddr1, flags & FLAGS_SHARED, &key1, VERIFY_READ, &mm_ref1);
 	if (unlikely(ret != 0))
 		goto out;
 	ret = get_futex_key(uaddr2, flags & FLAGS_SHARED, &key2,
-			    requeue_pi ? VERIFY_WRITE : VERIFY_READ);
+			    requeue_pi ? VERIFY_WRITE : VERIFY_READ, &mm_ref2);
 	if (unlikely(ret != 0))
 		goto out_put_key1;
 
@@ -1779,8 +1787,8 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 			if (!(flags & FLAGS_SHARED))
 				goto retry_private;
 
-			put_futex_key(&key2);
-			put_futex_key(&key1);
+			put_futex_key(&key2, &mm_ref2);
+			put_futex_key(&key1, &mm_ref1);
 			goto retry;
 		}
 		if (curval != *cmpval) {
@@ -1797,7 +1805,7 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 		 * faults rather in the requeue loop below.
 		 */
 		ret = futex_proxy_trylock_atomic(uaddr2, hb1, hb2, &key1,
-						 &key2, &pi_state, nr_requeue);
+						 &key2, &pi_state, nr_requeue, &mm_ref2);
 
 		/*
 		 * At this point the top_waiter has either taken uaddr2 or is
@@ -1836,8 +1844,8 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 		case -EFAULT:
 			double_unlock_hb(hb1, hb2);
 			hb_waiters_dec(hb2);
-			put_futex_key(&key2);
-			put_futex_key(&key1);
+			put_futex_key(&key2, &mm_ref2);
+			put_futex_key(&key1, &mm_ref1);
 			ret = fault_in_user_writeable(uaddr2);
 			if (!ret)
 				goto retry;
@@ -1851,8 +1859,8 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 			 */
 			double_unlock_hb(hb1, hb2);
 			hb_waiters_dec(hb2);
-			put_futex_key(&key2);
-			put_futex_key(&key1);
+			put_futex_key(&key2, &mm_ref2);
+			put_futex_key(&key1, &mm_ref1);
 			cond_resched();
 			goto retry;
 		default:
@@ -1921,7 +1929,7 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 				 * value. It will drop the refcount after
 				 * doing so.
 				 */
-				requeue_pi_wake_futex(this, &key2, hb2);
+				requeue_pi_wake_futex(this, &key2, hb2, &mm_ref2);
 				drop_count++;
 				continue;
 			} else if (ret) {
@@ -1942,7 +1950,7 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 				break;
 			}
 		}
-		requeue_futex(this, hb1, hb2, &key2);
+		requeue_futex(this, hb1, hb2, &key2, &mm_ref2);
 		drop_count++;
 	}
 
@@ -1965,12 +1973,12 @@ static int futex_requeue(u32 __user *uaddr1, unsigned int flags,
 	 * hold the references to key1.
 	 */
 	while (--drop_count >= 0)
-		drop_futex_key_refs(&key1);
+		drop_futex_key_refs(&key1, &mm_ref1);
 
 out_put_keys:
-	put_futex_key(&key2);
+	put_futex_key(&key2, &mm_ref2);
 out_put_key1:
-	put_futex_key(&key1);
+	put_futex_key(&key1, &mm_ref1);
 out:
 	return ret ? ret : task_count;
 }
@@ -2091,7 +2099,7 @@ static int unqueue_me(struct futex_q *q)
 		ret = 1;
 	}
 
-	drop_futex_key_refs(&q->key);
+	drop_futex_key_refs(&q->key, &q->mm_ref);
 	return ret;
 }
 
@@ -2365,7 +2373,7 @@ static int futex_wait_setup(u32 __user *uaddr, u32 val, unsigned int flags,
 	 * while the syscall executes.
 	 */
 retry:
-	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &q->key, VERIFY_READ);
+	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &q->key, VERIFY_READ, &q->mm_ref);
 	if (unlikely(ret != 0))
 		return ret;
 
@@ -2384,7 +2392,7 @@ static int futex_wait_setup(u32 __user *uaddr, u32 val, unsigned int flags,
 		if (!(flags & FLAGS_SHARED))
 			goto retry_private;
 
-		put_futex_key(&q->key);
+		put_futex_key(&q->key, &q->mm_ref);
 		goto retry;
 	}
 
@@ -2395,7 +2403,7 @@ static int futex_wait_setup(u32 __user *uaddr, u32 val, unsigned int flags,
 
 out:
 	if (ret)
-		put_futex_key(&q->key);
+		put_futex_key(&q->key, &q->mm_ref);
 	return ret;
 }
 
@@ -2408,6 +2416,8 @@ static int futex_wait(u32 __user *uaddr, unsigned int flags, u32 val,
 	struct futex_q q = futex_q_init;
 	int ret;
 
+	INIT_MM_REF(&q.mm_ref);
+
 	if (!bitset)
 		return -EINVAL;
 	q.bitset = bitset;
@@ -2507,6 +2517,8 @@ static int futex_lock_pi(u32 __user *uaddr, unsigned int flags,
 	struct futex_q q = futex_q_init;
 	int res, ret;
 
+	INIT_MM_REF(&q.mm_ref);
+
 	if (refill_pi_state_cache())
 		return -ENOMEM;
 
@@ -2519,7 +2531,7 @@ static int futex_lock_pi(u32 __user *uaddr, unsigned int flags,
 	}
 
 retry:
-	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &q.key, VERIFY_WRITE);
+	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &q.key, VERIFY_WRITE, &q.mm_ref);
 	if (unlikely(ret != 0))
 		goto out;
 
@@ -2547,7 +2559,7 @@ static int futex_lock_pi(u32 __user *uaddr, unsigned int flags,
 			 * - The user space value changed.
 			 */
 			queue_unlock(hb);
-			put_futex_key(&q.key);
+			put_futex_key(&q.key, &q.mm_ref);
 			cond_resched();
 			goto retry;
 		default:
@@ -2601,7 +2613,7 @@ static int futex_lock_pi(u32 __user *uaddr, unsigned int flags,
 	queue_unlock(hb);
 
 out_put_key:
-	put_futex_key(&q.key);
+	put_futex_key(&q.key, &q.mm_ref);
 out:
 	if (to)
 		destroy_hrtimer_on_stack(&to->timer);
@@ -2617,7 +2629,7 @@ static int futex_lock_pi(u32 __user *uaddr, unsigned int flags,
 	if (!(flags & FLAGS_SHARED))
 		goto retry_private;
 
-	put_futex_key(&q.key);
+	put_futex_key(&q.key, &q.mm_ref);
 	goto retry;
 }
 
@@ -2630,6 +2642,7 @@ static int futex_unlock_pi(u32 __user *uaddr, unsigned int flags)
 {
 	u32 uninitialized_var(curval), uval, vpid = task_pid_vnr(current);
 	union futex_key key = FUTEX_KEY_INIT;
+	MM_REF(mm_ref);
 	struct futex_hash_bucket *hb;
 	struct futex_q *match;
 	int ret;
@@ -2643,7 +2656,7 @@ static int futex_unlock_pi(u32 __user *uaddr, unsigned int flags)
 	if ((uval & FUTEX_TID_MASK) != vpid)
 		return -EPERM;
 
-	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &key, VERIFY_WRITE);
+	ret = get_futex_key(uaddr, flags & FLAGS_SHARED, &key, VERIFY_WRITE, &mm_ref);
 	if (ret)
 		return ret;
 
@@ -2676,7 +2689,7 @@ static int futex_unlock_pi(u32 __user *uaddr, unsigned int flags)
 		 */
 		if (ret == -EAGAIN) {
 			spin_unlock(&hb->lock);
-			put_futex_key(&key);
+			put_futex_key(&key, &mm_ref);
 			goto retry;
 		}
 		/*
@@ -2704,12 +2717,12 @@ static int futex_unlock_pi(u32 __user *uaddr, unsigned int flags)
 out_unlock:
 	spin_unlock(&hb->lock);
 out_putkey:
-	put_futex_key(&key);
+	put_futex_key(&key, &mm_ref);
 	return ret;
 
 pi_faulted:
 	spin_unlock(&hb->lock);
-	put_futex_key(&key);
+	put_futex_key(&key, &mm_ref);
 
 	ret = fault_in_user_writeable(uaddr);
 	if (!ret)
@@ -2816,9 +2829,12 @@ static int futex_wait_requeue_pi(u32 __user *uaddr, unsigned int flags,
 	struct rt_mutex *pi_mutex = NULL;
 	struct futex_hash_bucket *hb;
 	union futex_key key2 = FUTEX_KEY_INIT;
+	MM_REF(mm_ref2);
 	struct futex_q q = futex_q_init;
 	int res, ret;
 
+	INIT_MM_REF(&q.mm_ref);
+
 	if (uaddr == uaddr2)
 		return -EINVAL;
 
@@ -2844,7 +2860,7 @@ static int futex_wait_requeue_pi(u32 __user *uaddr, unsigned int flags,
 	RB_CLEAR_NODE(&rt_waiter.tree_entry);
 	rt_waiter.task = NULL;
 
-	ret = get_futex_key(uaddr2, flags & FLAGS_SHARED, &key2, VERIFY_WRITE);
+	ret = get_futex_key(uaddr2, flags & FLAGS_SHARED, &key2, VERIFY_WRITE, &mm_ref2);
 	if (unlikely(ret != 0))
 		goto out;
 
@@ -2951,9 +2967,9 @@ static int futex_wait_requeue_pi(u32 __user *uaddr, unsigned int flags,
 	}
 
 out_put_keys:
-	put_futex_key(&q.key);
+	put_futex_key(&q.key, &q.mm_ref);
 out_key2:
-	put_futex_key(&key2);
+	put_futex_key(&key2, &mm_ref2);
 
 out:
 	if (to) {
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index ee1fb0070544..460c57d0d9af 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2771,7 +2771,7 @@ static struct rq *finish_task_switch(struct task_struct *prev)
 
 	fire_sched_in_preempt_notifiers(current);
 	if (mm)
-		mmdrop(mm);
+		mmdrop(mm, &rq->prev_mm_ref);
 	if (unlikely(prev_state == TASK_DEAD)) {
 		if (prev->sched_class->task_dead)
 			prev->sched_class->task_dead(prev);
@@ -2877,12 +2877,14 @@ context_switch(struct rq *rq, struct task_struct *prev,
 
 	if (!mm) {
 		next->active_mm = oldmm;
-		mmgrab(oldmm);
+		mmgrab(oldmm, &next->mm_ref);
 		enter_lazy_tlb(oldmm, next);
 	} else
 		switch_mm_irqs_off(oldmm, mm, next);
 
 	if (!prev->mm) {
+		if (oldmm)
+			move_mm_ref(oldmm, &prev->mm_ref, &rq->prev_mm_ref);
 		prev->active_mm = NULL;
 		rq->prev_mm = oldmm;
 	}
@@ -5472,7 +5474,7 @@ void idle_task_exit(void)
 		switch_mm_irqs_off(mm, &init_mm, current);
 		finish_arch_post_lock_switch();
 	}
-	mmdrop(mm);
+	mmdrop(mm, &current->mm_ref);
 }
 
 /*
@@ -7640,6 +7642,10 @@ void __init sched_init(void)
 		rq->balance_callback = NULL;
 		rq->active_balance = 0;
 		rq->next_balance = jiffies;
+
+		BUG_ON(rq->prev_mm != NULL);
+		INIT_MM_REF(&rq->prev_mm_ref);
+
 		rq->push_cpu = 0;
 		rq->cpu = i;
 		rq->online = 0;
@@ -7667,7 +7673,7 @@ void __init sched_init(void)
 	/*
 	 * The boot idle thread does lazy MMU switching as well:
 	 */
-	mmgrab(&init_mm);
+	mmgrab(&init_mm, &init_mm_ref);
 	enter_lazy_tlb(&init_mm, current);
 
 	/*
diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 055f935d4421..98680abb882a 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -636,6 +636,7 @@ struct rq {
 	struct task_struct *curr, *idle, *stop;
 	unsigned long next_balance;
 	struct mm_struct *prev_mm;
+	struct mm_ref prev_mm_ref;
 
 	unsigned int clock_skip_update;
 	u64 clock;
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be418157..01a5bd227a53 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1603,11 +1603,12 @@ static void k_getrusage(struct task_struct *p, int who, struct rusage *r)
 	cputime_to_timeval(stime, &r->ru_stime);
 
 	if (who != RUSAGE_CHILDREN) {
-		struct mm_struct *mm = get_task_mm(p);
+		MM_REF(mm_ref);
+		struct mm_struct *mm = get_task_mm(p, &mm_ref);
 
 		if (mm) {
 			setmax_mm_hiwater_rss(&maxrss, mm);
-			mmput(mm);
+			mmput(mm, &mm_ref);
 		}
 	}
 	r->ru_maxrss = maxrss * (PAGE_SIZE / 1024); /* convert pages to KBs */
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 3fc20422c166..decd72ec58e1 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -1046,6 +1046,7 @@ static enum print_line_t trace_user_stack_print(struct trace_iterator *iter,
 	struct userstack_entry *field;
 	struct trace_seq *s = &iter->seq;
 	struct mm_struct *mm = NULL;
+	MM_REF(mm_ref);
 	unsigned int i;
 
 	trace_assign_type(field, iter->ent);
@@ -1061,7 +1062,7 @@ static enum print_line_t trace_user_stack_print(struct trace_iterator *iter,
 		rcu_read_lock();
 		task = find_task_by_vpid(field->tgid);
 		if (task)
-			mm = get_task_mm(task);
+			mm = get_task_mm(task, &mm_ref);
 		rcu_read_unlock();
 	}
 
@@ -1084,7 +1085,7 @@ static enum print_line_t trace_user_stack_print(struct trace_iterator *iter,
 	}
 
 	if (mm)
-		mmput(mm);
+		mmput(mm, &mm_ref);
 
 	return trace_handle_return(s);
 }
diff --git a/kernel/tsacct.c b/kernel/tsacct.c
index f8e26ab963ed..58595a3dca3f 100644
--- a/kernel/tsacct.c
+++ b/kernel/tsacct.c
@@ -92,18 +92,19 @@ void bacct_add_tsk(struct user_namespace *user_ns,
 void xacct_add_tsk(struct taskstats *stats, struct task_struct *p)
 {
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 
 	/* convert pages-nsec/1024 to Mbyte-usec, see __acct_update_integrals */
 	stats->coremem = p->acct_rss_mem1 * PAGE_SIZE;
 	do_div(stats->coremem, 1000 * KB);
 	stats->virtmem = p->acct_vm_mem1 * PAGE_SIZE;
 	do_div(stats->virtmem, 1000 * KB);
-	mm = get_task_mm(p);
+	mm = get_task_mm(p, &mm_ref);
 	if (mm) {
 		/* adjust to KB unit */
 		stats->hiwater_rss   = get_mm_hiwater_rss(mm) * PAGE_SIZE / KB;
 		stats->hiwater_vm    = get_mm_hiwater_vm(mm)  * PAGE_SIZE / KB;
-		mmput(mm);
+		mmput(mm, &mm_ref);
 	}
 	stats->read_char	= p->ioac.rchar & KB_MASK;
 	stats->write_char	= p->ioac.wchar & KB_MASK;
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a9f76b..1d6acdf0a4a7 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -37,7 +37,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o vmacache.o \
 			   interval_tree.o list_lru.o workingset.o \
-			   debug.o $(mmu-y)
+			   debug.o mm_ref.o $(mmu-y)
 
 obj-y += init-mm.o
 
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a56a851908d2..deb315a4c240 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -16,10 +16,16 @@
 struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
 	.pgd		= swapper_pg_dir,
+	.mm_refs_lock	= __SPIN_LOCK_UNLOCKED(init_mm.mm_refs_lock),
 	.mm_users	= ATOMIC_INIT(2),
+	.mm_users_list	= LIST_HEAD_INIT(init_mm.mm_users_list),
+	.mm_users_ref	= MM_REF_INIT(init_mm.mm_users_ref),
 	.mm_count	= ATOMIC_INIT(1),
+	.mm_count_list	= LIST_HEAD_INIT(init_mm.mm_count_list),
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
 	INIT_MM_CONTEXT(init_mm)
 };
+
+MM_REF(init_mm_ref);
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..3be253b54c04 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3954,15 +3954,16 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags)
 {
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	int ret;
 
-	mm = get_task_mm(tsk);
+	mm = get_task_mm(tsk, &mm_ref);
 	if (!mm)
 		return 0;
 
 	ret = __access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 	return ret;
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b859af06b87..4790274af596 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1374,6 +1374,7 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 {
 	const struct cred *cred = current_cred(), *tcred;
 	struct mm_struct *mm = NULL;
+	MM_REF(mm_ref);
 	struct task_struct *task;
 	nodemask_t task_nodes;
 	int err;
@@ -1439,7 +1440,7 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 	if (err)
 		goto out_put;
 
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	put_task_struct(task);
 
 	if (!mm) {
@@ -1450,7 +1451,7 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 	err = do_migrate_pages(mm, old, new,
 		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 out:
 	NODEMASK_SCRATCH_FREE(scratch);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 99250aee1ac1..593942dabbc1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1659,6 +1659,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	const struct cred *cred = current_cred(), *tcred;
 	struct task_struct *task;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	int err;
 	nodemask_t task_nodes;
 
@@ -1699,7 +1700,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 		goto out;
 
 	task_nodes = cpuset_mems_allowed(task);
-	mm = get_task_mm(task);
+	mm = get_task_mm(task, &mm_ref);
 	put_task_struct(task);
 
 	if (!mm)
@@ -1711,7 +1712,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	else
 		err = do_pages_stat(mm, nr_pages, pages, status);
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 	return err;
 
 out:
diff --git a/mm/mm_ref.c b/mm/mm_ref.c
new file mode 100644
index 000000000000..cf14334aec58
--- /dev/null
+++ b/mm/mm_ref.c
@@ -0,0 +1,163 @@
+#include <linux/list.h>
+#include <linux/mm_ref.h>
+#include <linux/mm_types.h>
+#include <linux/sched.h>
+#include <linux/stacktrace.h>
+
+static void _mm_ref_save_trace(struct mm_ref *ref)
+{
+	ref->pid = current->pid;
+
+	/* Save stack trace */
+	ref->trace.nr_entries = 0;
+	ref->trace.entries = ref->trace_entries;
+	ref->trace.max_entries = NR_MM_REF_STACK_ENTRIES;
+	ref->trace.skip = 1;
+	save_stack_trace(&ref->trace);
+}
+
+void INIT_MM_REF(struct mm_ref *ref)
+{
+	_mm_ref_save_trace(ref);
+	INIT_LIST_HEAD(&ref->list_entry);
+	ref->state = MM_REF_INITIALIZED;
+}
+
+static void dump_refs_list(const char *label, struct list_head *list)
+{
+	struct mm_ref *ref;
+
+	if (list_empty(list)) {
+		printk(KERN_ERR "%s: no refs\n", label);
+		return;
+	}
+
+	printk(KERN_ERR "%s:\n", label);
+	list_for_each_entry(ref, list, list_entry) {
+		printk(KERN_ERR " - %p %x acquired by %d at:%s\n",
+			ref, ref->state,
+			ref->pid,
+			ref->state == MM_REF_ACTIVE ? "" : " (bogus)");
+		if (ref->state == MM_REF_ACTIVE)
+			print_stack_trace(&ref->trace, 2);
+	}
+}
+
+static void dump_refs(struct mm_struct *mm)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mm->mm_refs_lock, flags);
+	printk(KERN_ERR "mm_users = %u\n", atomic_read(&mm->mm_users));
+	dump_refs_list("mm_users_list", &mm->mm_users_list);
+	printk(KERN_ERR "mm_count = %u\n", atomic_read(&mm->mm_count));
+	dump_refs_list("mm_count_list", &mm->mm_count_list);
+	spin_unlock_irqrestore(&mm->mm_refs_lock, flags);
+}
+
+static bool _mm_ref_expect_inactive(struct mm_struct *mm, struct mm_ref *ref)
+{
+	if (ref->state == MM_REF_INITIALIZED || ref->state == MM_REF_INACTIVE)
+		return true;
+
+	if (ref->state == MM_REF_ACTIVE) {
+		printk(KERN_ERR "trying to overwrite active ref %p to mm %p\n", ref, mm);
+		printk(KERN_ERR "previous ref taken by %d at:\n", ref->pid);
+		print_stack_trace(&ref->trace, 0);
+	} else {
+		printk(KERN_ERR "trying to overwrite ref %p in unknown state %x to mm %p\n",
+			ref, ref->state, mm);
+	}
+
+	return false;
+}
+
+static bool _mm_ref_expect_active(struct mm_struct *mm, struct mm_ref *ref)
+{
+	if (ref->state == MM_REF_ACTIVE)
+		return true;
+
+	if (ref->state == MM_REF_INITIALIZED || ref->state == MM_REF_INACTIVE) {
+		printk(KERN_ERR "trying to put inactive ref %p to mm %p\n", ref, mm);
+		if (ref->state == MM_REF_INITIALIZED)
+			printk(KERN_ERR "ref initialized by %d at:\n", ref->pid);
+		else
+			printk(KERN_ERR "previous ref dropped by %d at:\n", ref->pid);
+		print_stack_trace(&ref->trace, 0);
+	} else {
+		printk(KERN_ERR "trying to put ref %p in unknown state %x to mm %p\n",
+			ref, ref->state, mm);
+	}
+
+	return false;
+}
+
+void _get_mm_ref(struct mm_struct *mm, struct list_head *list, struct mm_ref *ref)
+{
+	unsigned long flags;
+
+	if (!_mm_ref_expect_inactive(mm, ref)) {
+		dump_refs(mm);
+		BUG();
+	}
+
+	_mm_ref_save_trace(ref);
+
+	spin_lock_irqsave(&mm->mm_refs_lock, flags);
+	list_add_tail(&ref->list_entry, list);
+	spin_unlock_irqrestore(&mm->mm_refs_lock, flags);
+
+	ref->state = MM_REF_ACTIVE;
+}
+
+void _put_mm_ref(struct mm_struct *mm, struct list_head *list, struct mm_ref *ref)
+{
+	unsigned long flags;
+
+	if (!_mm_ref_expect_active(mm, ref)) {
+		dump_refs(mm);
+		BUG();
+	}
+
+	_mm_ref_save_trace(ref);
+
+	spin_lock_irqsave(&mm->mm_refs_lock, flags);
+	BUG_ON(list_empty(&ref->list_entry));
+	list_del_init(&ref->list_entry);
+	spin_unlock_irqrestore(&mm->mm_refs_lock, flags);
+
+	ref->state = MM_REF_INACTIVE;
+}
+
+/*
+ * TODO: we have a choice here whether to ignore mm == NULL or
+ * treat it as an error.
+ * TODO: there's also a question about whether old_ref == new_ref
+ * is an error or not.
+ */
+void _move_mm_ref(struct mm_struct *mm, struct list_head *list,
+	struct mm_ref *old_ref, struct mm_ref *new_ref)
+{
+	unsigned long flags;
+
+	if (!_mm_ref_expect_active(mm, old_ref)) {
+		dump_refs(mm);
+		BUG();
+	}
+	if (!_mm_ref_expect_inactive(mm, new_ref)) {
+		dump_refs(mm);
+		BUG();
+	}
+
+	_mm_ref_save_trace(old_ref);
+	_mm_ref_save_trace(new_ref);
+
+	spin_lock_irqsave(&mm->mm_refs_lock, flags);
+	BUG_ON(list_empty(&old_ref->list_entry));
+	list_del_init(&old_ref->list_entry);
+	list_add_tail(&new_ref->list_entry, list);
+	spin_unlock_irqrestore(&mm->mm_refs_lock, flags);
+
+	old_ref->state = MM_REF_INACTIVE;
+	new_ref->state = MM_REF_ACTIVE;
+}
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index daf67bb02b4a..3e28db145982 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -20,12 +20,14 @@
 void use_mm(struct mm_struct *mm)
 {
 	struct mm_struct *active_mm;
+	struct mm_ref active_mm_ref;
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
 	active_mm = tsk->active_mm;
 	if (active_mm != mm) {
-		mmgrab(mm);
+		move_mm_ref(mm, &tsk->mm_ref, &active_mm_ref);
+		mmgrab(mm, &tsk->mm_ref);
 		tsk->active_mm = mm;
 	}
 	tsk->mm = mm;
@@ -35,8 +37,9 @@ void use_mm(struct mm_struct *mm)
 	finish_arch_post_lock_switch();
 #endif
 
-	if (active_mm != mm)
-		mmdrop(active_mm);
+	if (active_mm != mm) {
+		mmdrop(active_mm, &active_mm_ref);
+	}
 }
 EXPORT_SYMBOL_GPL(use_mm);
 
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 32bc9f2ff7eb..8187d46c8d05 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -244,7 +244,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
 				    struct mm_struct *mm,
-				    int take_mmap_sem)
+				    int take_mmap_sem, struct mm_ref *mm_ref)
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
@@ -275,7 +275,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		mm->mmu_notifier_mm = mmu_notifier_mm;
 		mmu_notifier_mm = NULL;
 	}
-	mmgrab(mm);
+	mmgrab(mm, mm_ref);
 
 	/*
 	 * Serialize the update against mmu_notifier_unregister. A
@@ -312,9 +312,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
  * after exit_mmap. ->release will always be called before exit_mmap
  * frees the pages.
  */
-int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm, struct mm_ref *mm_ref)
 {
-	return do_mmu_notifier_register(mn, mm, 1);
+	return do_mmu_notifier_register(mn, mm, 1, mm_ref);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
@@ -322,9 +322,9 @@ EXPORT_SYMBOL_GPL(mmu_notifier_register);
  * Same as mmu_notifier_register but here the caller must hold the
  * mmap_sem in write mode.
  */
-int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm, struct mm_ref *mm_ref)
 {
-	return do_mmu_notifier_register(mn, mm, 0);
+	return do_mmu_notifier_register(mn, mm, 0, mm_ref);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 
@@ -346,7 +346,7 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
  * and only after mmu_notifier_unregister returned we're guaranteed
  * that ->release or any other method can't run anymore.
  */
-void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm, struct mm_ref *mm_ref)
 {
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
@@ -383,7 +383,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
-	mmdrop(mm);
+	mmdrop(mm, mm_ref);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
@@ -391,7 +391,7 @@ EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
  * Same as mmu_notifier_unregister but no callback and no srcu synchronization.
  */
 void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
-					struct mm_struct *mm)
+					struct mm_struct *mm, struct mm_ref *mm_ref)
 {
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	/*
@@ -402,7 +402,7 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
-	mmdrop(mm);
+	mmdrop(mm, mm_ref);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ead093c6f2a6..0aa0b364ec0e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -463,6 +463,7 @@ static DEFINE_SPINLOCK(oom_reaper_lock);
 
 static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
+	MM_REF(mm_ref);
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	struct zap_details details = {.check_swap_entries = true,
@@ -495,7 +496,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * that the mmput_async is called only when we have reaped something
 	 * and delayed __mmput doesn't matter that much
 	 */
-	if (!mmget_not_zero(mm)) {
+	if (!mmget_not_zero(mm, &mm_ref)) {
 		up_read(&mm->mmap_sem);
 		goto unlock_oom;
 	}
@@ -547,7 +548,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * different context because we shouldn't risk we get stuck there and
 	 * put the oom_reaper out of the way.
 	 */
-	mmput_async(mm);
+	mmput_async(mm, &mm_ref);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -660,7 +661,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
-		mmgrab(tsk->signal->oom_mm);
+		mmgrab(tsk->signal->oom_mm, &tsk->signal->oom_mm_ref);
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
@@ -812,6 +813,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	struct task_struct *child;
 	struct task_struct *t;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
@@ -877,7 +879,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 
 	/* Get a reference to safely compare mm after task_unlock(victim) */
 	mm = victim->mm;
-	mmgrab(mm);
+	mmgrab(mm, &mm_ref);
 	/*
 	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
 	 * the OOM victim from depleting the memory reserves from the user
@@ -928,7 +930,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	if (can_oom_reap)
 		wake_oom_reaper(victim);
 
-	mmdrop(mm);
+	mmdrop(mm, &mm_ref);
 	put_task_struct(victim);
 }
 #undef K
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index be8dc8d1edb9..8eef73c5ed81 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -155,6 +155,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 	struct page *pp_stack[PVM_MAX_PP_ARRAY_COUNT];
 	struct page **process_pages = pp_stack;
 	struct mm_struct *mm;
+	MM_REF(mm_ref);
 	unsigned long i;
 	ssize_t rc = 0;
 	unsigned long nr_pages = 0;
@@ -202,7 +203,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 		goto free_proc_pages;
 	}
 
-	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS, &mm_ref);
 	if (!mm || IS_ERR(mm)) {
 		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
 		/*
@@ -228,7 +229,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 	if (total_len)
 		rc = total_len;
 
-	mmput(mm);
+	mmput(mm, &mm_ref);
 
 put_task_struct:
 	put_task_struct(task);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8c92829326cb..781122d8be77 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1376,6 +1376,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
+	MM_REF(start_mm_ref);
 	volatile unsigned char *swap_map; /* swap_map is accessed without
 					   * locking. Mark it as volatile
 					   * to prevent compiler doing
@@ -1402,7 +1403,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	 * that.
 	 */
 	start_mm = &init_mm;
-	mmget(&init_mm);
+	mmget(&init_mm, &start_mm_ref);
 
 	/*
 	 * Keep on scanning until all entries have gone.  Usually,
@@ -1449,9 +1450,9 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 * Don't hold on to start_mm if it looks like exiting.
 		 */
 		if (atomic_read(&start_mm->mm_users) == 1) {
-			mmput(start_mm);
+			mmput(start_mm, &start_mm_ref);
 			start_mm = &init_mm;
-			mmget(&init_mm);
+			mmget(&init_mm, &start_mm_ref);
 		}
 
 		/*
@@ -1485,19 +1486,22 @@ int try_to_unuse(unsigned int type, bool frontswap,
 			int set_start_mm = (*swap_map >= swcount);
 			struct list_head *p = &start_mm->mmlist;
 			struct mm_struct *new_start_mm = start_mm;
+			MM_REF(new_start_mm_ref);
 			struct mm_struct *prev_mm = start_mm;
+			MM_REF(prev_mm_ref);
 			struct mm_struct *mm;
+			MM_REF(mm_ref);
 
-			mmget(new_start_mm);
-			mmget(prev_mm);
+			mmget(new_start_mm, &new_start_mm_ref);
+			mmget(prev_mm, &prev_mm_ref);
 			spin_lock(&mmlist_lock);
 			while (swap_count(*swap_map) && !retval &&
 					(p = p->next) != &start_mm->mmlist) {
 				mm = list_entry(p, struct mm_struct, mmlist);
-				if (!mmget_not_zero(mm))
+				if (!mmget_not_zero(mm, &mm_ref))
 					continue;
 				spin_unlock(&mmlist_lock);
-				mmput(prev_mm);
+				mmput(prev_mm, &prev_mm_ref);
 				prev_mm = mm;
 
 				cond_resched();
@@ -1511,17 +1515,18 @@ int try_to_unuse(unsigned int type, bool frontswap,
 					retval = unuse_mm(mm, entry, page);
 
 				if (set_start_mm && *swap_map < swcount) {
-					mmput(new_start_mm);
-					mmget(mm);
+					mmput(new_start_mm, &new_start_mm_ref);
+					mmget(mm, &mm_ref);
 					new_start_mm = mm;
 					set_start_mm = 0;
 				}
 				spin_lock(&mmlist_lock);
 			}
 			spin_unlock(&mmlist_lock);
-			mmput(prev_mm);
-			mmput(start_mm);
+			mmput(prev_mm, &prev_mm_ref);
+			mmput(start_mm, &start_mm_ref);
 			start_mm = new_start_mm;
+			move_mm_users_ref(start_mm, &new_start_mm_ref, &start_mm_ref);
 		}
 		if (retval) {
 			unlock_page(page);
@@ -1590,7 +1595,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		}
 	}
 
-	mmput(start_mm);
+	mmput(start_mm, &start_mm_ref);
 	return retval;
 }
 
diff --git a/mm/util.c b/mm/util.c
index 1a41553db866..9bace6820707 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -607,7 +607,8 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 {
 	int res = 0;
 	unsigned int len;
-	struct mm_struct *mm = get_task_mm(task);
+	MM_REF(mm_ref);
+	struct mm_struct *mm = get_task_mm(task, &mm_ref);
 	unsigned long arg_start, arg_end, env_start, env_end;
 	if (!mm)
 		goto out;
@@ -647,7 +648,7 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 		}
 	}
 out_mm:
-	mmput(mm);
+	mmput(mm, &mm_ref);
 out:
 	return res;
 }
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 9ec9cef2b207..972084e84bd6 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -108,7 +108,7 @@ static void async_pf_execute(struct work_struct *work)
 	if (swait_active(&vcpu->wq))
 		swake_up(&vcpu->wq);
 
-	mmput(mm);
+	mmput(mm, &apf->mm_ref);
 	kvm_put_kvm(vcpu->kvm);
 }
 
@@ -135,7 +135,7 @@ void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu)
 		flush_work(&work->work);
 #else
 		if (cancel_work_sync(&work->work)) {
-			mmput(work->mm);
+			mmput(work->mm, &work->mm_ref);
 			kvm_put_kvm(vcpu->kvm); /* == work->vcpu->kvm */
 			kmem_cache_free(async_pf_cache, work);
 		}
@@ -200,7 +200,8 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 	work->addr = hva;
 	work->arch = *arch;
 	work->mm = current->mm;
-	mmget(work->mm);
+	INIT_MM_REF(&work->mm_ref);
+	mmget(work->mm, &work->mm_ref);
 	kvm_get_kvm(work->vcpu->kvm);
 
 	/* this can't really happen otherwise gfn_to_pfn_async
@@ -218,7 +219,7 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 	return 1;
 retry_sync:
 	kvm_put_kvm(work->vcpu->kvm);
-	mmput(work->mm);
+	mmput(work->mm, &work->mm_ref);
 	kmem_cache_free(async_pf_cache, work);
 	return 0;
 }
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 43914b981691..d608457033d5 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -482,7 +482,8 @@ static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
 static int kvm_init_mmu_notifier(struct kvm *kvm)
 {
 	kvm->mmu_notifier.ops = &kvm_mmu_notifier_ops;
-	return mmu_notifier_register(&kvm->mmu_notifier, current->mm);
+	return mmu_notifier_register(&kvm->mmu_notifier, current->mm,
+		&kvm->mmu_notifier_ref);
 }
 
 #else  /* !(CONFIG_MMU_NOTIFIER && KVM_ARCH_WANT_MMU_NOTIFIER) */
@@ -608,12 +609,13 @@ static struct kvm *kvm_create_vm(unsigned long type)
 {
 	int r, i;
 	struct kvm *kvm = kvm_arch_alloc_vm();
+	MM_REF(mm_ref);
 
 	if (!kvm)
 		return ERR_PTR(-ENOMEM);
 
 	spin_lock_init(&kvm->mmu_lock);
-	mmgrab(current->mm);
+	mmgrab(current->mm, &kvm->mm_ref);
 	kvm->mm = current->mm;
 	kvm_eventfd_init(kvm);
 	mutex_init(&kvm->lock);
@@ -654,6 +656,7 @@ static struct kvm *kvm_create_vm(unsigned long type)
 			goto out_err;
 	}
 
+	INIT_MM_REF(&kvm->mmu_notifier_ref);
 	r = kvm_init_mmu_notifier(kvm);
 	if (r)
 		goto out_err;
@@ -677,8 +680,9 @@ static struct kvm *kvm_create_vm(unsigned long type)
 		kfree(kvm->buses[i]);
 	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++)
 		kvm_free_memslots(kvm, kvm->memslots[i]);
+	move_mm_ref(kvm->mm, &kvm->mm_ref, &mm_ref);
 	kvm_arch_free_vm(kvm);
-	mmdrop(current->mm);
+	mmdrop(current->mm, &mm_ref);
 	return ERR_PTR(r);
 }
 
@@ -713,6 +717,7 @@ static void kvm_destroy_vm(struct kvm *kvm)
 {
 	int i;
 	struct mm_struct *mm = kvm->mm;
+	MM_REF(mm_ref);
 
 	kvm_destroy_vm_debugfs(kvm);
 	kvm_arch_sync_events(kvm);
@@ -724,7 +729,7 @@ static void kvm_destroy_vm(struct kvm *kvm)
 		kvm_io_bus_destroy(kvm->buses[i]);
 	kvm_coalesced_mmio_free(kvm);
 #if defined(CONFIG_MMU_NOTIFIER) && defined(KVM_ARCH_WANT_MMU_NOTIFIER)
-	mmu_notifier_unregister(&kvm->mmu_notifier, kvm->mm);
+	mmu_notifier_unregister(&kvm->mmu_notifier, kvm->mm, &kvm->mmu_notifier_ref);
 #else
 	kvm_arch_flush_shadow_all(kvm);
 #endif
@@ -734,10 +739,11 @@ static void kvm_destroy_vm(struct kvm *kvm)
 		kvm_free_memslots(kvm, kvm->memslots[i]);
 	cleanup_srcu_struct(&kvm->irq_srcu);
 	cleanup_srcu_struct(&kvm->srcu);
+	move_mm_ref(mm, &kvm->mm_ref, &mm_ref);
 	kvm_arch_free_vm(kvm);
 	preempt_notifier_dec();
 	hardware_disable_all();
-	mmdrop(mm);
+	mmdrop(mm, &mm_ref);
 }
 
 void kvm_get_kvm(struct kvm *kvm)
-- 
2.11.0.1.gaa10c3f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
