Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 294D928024F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:54:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so55360775wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 15:54:57 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id lq8si11169209wjb.83.2016.09.28.15.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 15:54:55 -0700 (PDT)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Date: Thu, 29 Sep 2016 00:54:40 +0200
Message-Id: <1475103281-7989-3-git-send-email-jann@thejh.net>
In-Reply-To: <1475103281-7989-1-git-send-email-jann@thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SELinux attempts to make it possible to whitelist trustworthy sources of
code that may be mapped into memory, and Android makes use of this feature.
To prevent an attacker from bypassing this by modifying R+X memory through
/proc/$pid/mem or PTRACE_POKETEXT, it is necessary to call a security hook
in check_vma_flags().

The new security hook security_forced_write() takes three arguments:

 - The modified VMA, so the security check can e.g. test for executability.
 - The subject performing the access. For remote accesses, this may be
   different from the target of the access. This can e.g. be used to create
   a security policy that permits a privileged debugger to set software
   breakpoints in the address space of a sandboxed process.
 - The target of the access. This is useful if only a subset of the
   processes on the system should be prevented from executing arbitrary
   code, as is the case on Android.

changed in v2:
 - fix comment (Janis Danisevsk)
 - simplify code a bit (Janis Danisevsk)

Signed-off-by: Jann Horn <jann@thejh.net>
Reviewed-by: Janis Danisevskis <jdanis@android.com>
---
 drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  4 +-
 fs/exec.c                               |  4 +-
 fs/proc/base.c                          | 68 +++++++++++++++++++++-------
 fs/proc/internal.h                      |  4 +-
 fs/proc/task_mmu.c                      |  4 +-
 fs/proc/task_nommu.c                    |  2 +-
 include/linux/lsm_hooks.h               |  9 ++++
 include/linux/mm.h                      | 12 ++++-
 include/linux/sched.h                   |  4 +-
 include/linux/security.h                | 10 +++++
 kernel/events/uprobes.c                 |  6 ++-
 kernel/fork.c                           |  6 ++-
 mm/gup.c                                | 80 +++++++++++++++++++++++++--------
 mm/memory.c                             | 22 ++++++---
 mm/nommu.c                              | 22 +++++----
 mm/process_vm_access.c                  |  8 ++--
 security/security.c                     |  8 ++++
 security/tomoyo/domain.c                |  2 +-
 virt/kvm/async_pf.c                     |  3 +-
 virt/kvm/kvm_main.c                     |  9 ++--
 22 files changed, 215 insertions(+), 77 deletions(-)

diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 5ce3603..873130d 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -758,7 +758,8 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
-		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
+		ret = get_user_pages_remote(task, mm, NULL, NULL, ptr,
+					    npages - pinned,
 					    !etnaviv_obj->userptr.ro, 0,
 					    pvec + pinned, NULL);
 		if (ret < 0)
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 2314c88..1633081 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -544,7 +544,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 			down_read(&mm->mmap_sem);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
-					(work->task, mm,
+					(work->task, mm, NULL, NULL,
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 !obj->userptr.read_only, 0,
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 75077a0..cbebfaa 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -572,8 +572,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages = get_user_pages_remote(owning_process, owning_mm,
-				user_virt, gup_num_pages,
+		npages = get_user_pages_remote(owning_process, owning_mm, NULL,
+				NULL, user_virt, gup_num_pages,
 				access_mask & ODP_WRITE_ALLOWED_BIT,
 				0, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
diff --git a/fs/exec.c b/fs/exec.c
index d607da8..c57a8f0 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -203,8 +203,8 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * We are doing an exec().  'current' is the process
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
-	ret = get_user_pages_remote(current, bprm->mm, pos, 1, write,
-			0, &page, NULL);
+	ret = get_user_pages_remote(current, bprm->mm, NULL, NULL, pos, 1,
+			write, 0, &page, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff --git a/fs/proc/base.c b/fs/proc/base.c
index ac0df4d..9575975 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -113,6 +113,11 @@ struct pid_entry {
 	union proc_op op;
 };
 
+struct mem_private {
+	struct mm_struct *mm;
+	const struct cred *object_cred;
+};
+
 #define NOD(NAME, MODE, IOP, FOP, OP) {			\
 	.name = (NAME),					\
 	.len  = sizeof(NAME) - 1,			\
@@ -252,7 +257,7 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 	 * Inherently racy -- command line shares address space
 	 * with code and data.
 	 */
-	rv = access_remote_vm(mm, arg_end - 1, &c, 1, 0);
+	rv = access_remote_vm(mm, NULL, NULL, arg_end - 1, &c, 1, 0);
 	if (rv <= 0)
 		goto out_free_page;
 
@@ -270,7 +275,8 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 			int nr_read;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -305,7 +311,8 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 			bool final;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -354,7 +361,8 @@ skip_argv:
 			bool final;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -403,7 +411,7 @@ static const struct file_operations proc_pid_cmdline_ops = {
 static int proc_pid_auxv(struct seq_file *m, struct pid_namespace *ns,
 			 struct pid *pid, struct task_struct *task)
 {
-	struct mm_struct *mm = mm_access(task, PTRACE_MODE_READ_FSCREDS);
+	struct mm_struct *mm = mm_access(task, NULL, PTRACE_MODE_READ_FSCREDS);
 	if (mm && !IS_ERR(mm)) {
 		unsigned int nwords = 0;
 		do {
@@ -801,13 +809,15 @@ static const struct file_operations proc_single_file_operations = {
 };
 
 
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
+struct mm_struct *proc_mem_open(struct inode *inode,
+				const struct cred **object_cred,
+				unsigned int mode)
 {
 	struct task_struct *task = get_proc_task(inode);
 	struct mm_struct *mm = ERR_PTR(-ESRCH);
 
 	if (task) {
-		mm = mm_access(task, mode | PTRACE_MODE_FSCREDS);
+		mm = mm_access(task, object_cred, mode | PTRACE_MODE_FSCREDS);
 		put_task_struct(task);
 
 		if (!IS_ERR_OR_NULL(mm)) {
@@ -823,7 +833,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 
 static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 {
-	struct mm_struct *mm = proc_mem_open(inode, mode);
+	struct mm_struct *mm = proc_mem_open(inode, NULL, mode);
 
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
@@ -834,18 +844,36 @@ static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 
 static int mem_open(struct inode *inode, struct file *file)
 {
-	int ret = __mem_open(inode, file, PTRACE_MODE_ATTACH);
+	struct mem_private *private = kmalloc(sizeof(*private), GFP_KERNEL);
+	struct mm_struct *mm;
+
+	if (!private)
+		return -ENOMEM;
+
+	mm = proc_mem_open(inode, &private->object_cred, PTRACE_MODE_ATTACH);
+
+	if (!mm)
+		private->object_cred = NULL;
+
+	if (IS_ERR(mm)) {
+		kfree(private);
+		return PTR_ERR(mm);
+	}
+
+	private->mm = mm;
+	file->private_data = private;
 
 	/* OK to pass negative loff_t, we can catch out-of-range */
 	file->f_mode |= FMODE_UNSIGNED_OFFSET;
 
-	return ret;
+	return 0;
 }
 
 static ssize_t mem_rw(struct file *file, char __user *buf,
 			size_t count, loff_t *ppos, int write)
 {
-	struct mm_struct *mm = file->private_data;
+	struct mem_private *private = file->private_data;
+	struct mm_struct *mm = private->mm;
 	unsigned long addr = *ppos;
 	ssize_t copied;
 	char *page;
@@ -869,7 +897,9 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 			break;
 		}
 
-		this_len = access_remote_vm(mm, addr, page, this_len, write);
+		this_len = access_remote_vm(mm, file->f_cred,
+					    private->object_cred, addr,
+					    page, this_len, write);
 		if (!this_len) {
 			if (!copied)
 				copied = -EIO;
@@ -924,9 +954,13 @@ loff_t mem_lseek(struct file *file, loff_t offset, int orig)
 
 static int mem_release(struct inode *inode, struct file *file)
 {
-	struct mm_struct *mm = file->private_data;
-	if (mm)
-		mmdrop(mm);
+	struct mem_private *private = file->private_data;
+
+	if (private->mm) {
+		mmdrop(private->mm);
+		put_cred(private->object_cred);
+	}
+	kfree(private);
 	return 0;
 }
 
@@ -981,7 +1015,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		max_len = min_t(size_t, PAGE_SIZE, count);
 		this_len = min(max_len, this_len);
 
-		retval = access_remote_vm(mm, (env_start + src),
+		retval = access_remote_vm(mm, NULL, NULL, (env_start + src),
 			page, this_len, 0);
 
 		if (retval <= 0) {
@@ -1873,7 +1907,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	if (!task)
 		goto out_notask;
 
-	mm = mm_access(task, PTRACE_MODE_READ_FSCREDS);
+	mm = mm_access(task, NULL, PTRACE_MODE_READ_FSCREDS);
 	if (IS_ERR_OR_NULL(mm))
 		goto out;
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 7931c55..53e4ad6 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -288,7 +288,9 @@ struct proc_maps_private {
 #endif
 };
 
-struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode);
+struct mm_struct *proc_mem_open(struct inode *inode,
+				const struct cred **object_cred,
+				unsigned int mode);
 
 extern const struct file_operations proc_pid_maps_operations;
 extern const struct file_operations proc_tid_maps_operations;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index f6fa99e..f7ab4aa 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -230,7 +230,7 @@ static int proc_maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
@@ -1443,7 +1443,7 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
 	file->private_data = mm;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index faacb0c..6243696 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -287,7 +287,7 @@ static int maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 101bf19..b62d989 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1154,6 +1154,11 @@
  *	to the @parent process for tracing.
  *	@parent contains the task_struct structure for debugger process.
  *	Return 0 if permission is granted.
+ * @forced_write:
+ *	Check whether @subject_cred is permitted to forcibly write to the
+ *	non-writable mapping @vma that belongs to a process with objective
+ *	credentials @object_cred.
+ *	Return 0 if permission is granted.
  * @capget:
  *	Get the @effective, @inheritable, and @permitted capability sets for
  *	the @target process.  The hook may also perform permission checking to
@@ -1317,6 +1322,9 @@ union security_list_options {
 	int (*ptrace_access_check)(struct task_struct *child,
 					unsigned int mode);
 	int (*ptrace_traceme)(struct task_struct *parent);
+	int (*forced_write)(struct vm_area_struct *vma,
+				const struct cred *subject_cred,
+				const struct cred *object_cred);
 	int (*capget)(struct task_struct *target, kernel_cap_t *effective,
 			kernel_cap_t *inheritable, kernel_cap_t *permitted);
 	int (*capset)(struct cred *new, const struct cred *old,
@@ -1629,6 +1637,7 @@ struct security_hook_heads {
 	struct list_head binder_transfer_file;
 	struct list_head ptrace_access_check;
 	struct list_head ptrace_traceme;
+	struct list_head forced_write;
 	struct list_head capget;
 	struct list_head capset;
 	struct list_head capable;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9..ef92319 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/cred.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1279,14 +1280,19 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 #endif
 
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
-extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, int write);
+extern int access_remote_vm(struct mm_struct *mm,
+		const struct cred *subject_cred, const struct cred *object_cred,
+		unsigned long addr, void *buf, int len, int write);
 
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		      const struct cred *subject_cred,
+		      const struct cred *object_cred,
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking);
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+			    const struct cred *subject_cred,
+			    const struct cred *object_cred,
 			    unsigned long start, unsigned long nr_pages,
 			    int write, int force, struct page **pages,
 			    struct vm_area_struct **vmas);
@@ -1296,6 +1302,8 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       const struct cred *subject_cred,
+			       const struct cred *object_cred,
 			       unsigned long start, unsigned long nr_pages,
 			       int write, int force, struct page **pages,
 			       unsigned int gup_flags);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 62c68e5..c792341 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2853,7 +2853,9 @@ extern struct mm_struct *get_task_mm(struct task_struct *task);
  * and ptrace_may_access with the mode parameter passed to it
  * succeeds.
  */
-extern struct mm_struct *mm_access(struct task_struct *task, unsigned int mode);
+extern struct mm_struct *mm_access(struct task_struct *task,
+				   const struct cred **object_cred,
+				   unsigned int mode);
 /* Remove the current tasks stale references to the old mm_struct */
 extern void mm_release(struct task_struct *, struct mm_struct *);
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 7831cd5..8f0dbce 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -193,6 +193,9 @@ int security_binder_transfer_file(struct task_struct *from,
 				  struct task_struct *to, struct file *file);
 int security_ptrace_access_check(struct task_struct *child, unsigned int mode);
 int security_ptrace_traceme(struct task_struct *parent);
+int security_forced_write(struct vm_area_struct *vma,
+			  const struct cred *subject_cred,
+			  const struct cred *object_cred);
 int security_capget(struct task_struct *target,
 		    kernel_cap_t *effective,
 		    kernel_cap_t *inheritable,
@@ -424,6 +427,13 @@ static inline int security_ptrace_traceme(struct task_struct *parent)
 	return cap_ptrace_traceme(parent);
 }
 
+static inline int security_forced_write(struct vm_area_struct *vma,
+					const struct cred *subject_cred,
+					const struct cred *object_cred)
+{
+	return 0;
+}
+
 static inline int security_capget(struct task_struct *target,
 				   kernel_cap_t *effective,
 				   kernel_cap_t *inheritable,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 8c50276..26021e1 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -300,7 +300,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 
 retry:
 	/* Read the page with vaddr into memory */
-	ret = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
+	ret = get_user_pages_remote(NULL, mm, NULL, NULL, vaddr, 1, 0, 1,
+				    &old_page, &vma);
 	if (ret <= 0)
 		return ret;
 
@@ -1710,7 +1711,8 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * but we treat this as a 'remote' access since it is
 	 * essentially a kernel access to the memory.
 	 */
-	result = get_user_pages_remote(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
+	result = get_user_pages_remote(NULL, mm, NULL, NULL, vaddr, 1, 0, 1,
+				       &page, NULL);
 	if (result < 0)
 		return result;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index beb3172..e6e1fd7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -847,7 +847,8 @@ struct mm_struct *get_task_mm(struct task_struct *task)
 }
 EXPORT_SYMBOL_GPL(get_task_mm);
 
-struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
+struct mm_struct *mm_access(struct task_struct *task,
+			    const struct cred **object_cred, unsigned int mode)
 {
 	struct mm_struct *mm;
 	int err;
@@ -862,6 +863,9 @@ struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
 		mmput(mm);
 		mm = ERR_PTR(-EACCES);
 	}
+	if (!IS_ERR_OR_NULL(mm) && object_cred)
+		*object_cred = get_task_cred(task);
+
 	mutex_unlock(&task->signal->cred_guard_mutex);
 
 	return mm;
diff --git a/mm/gup.c b/mm/gup.c
index 96b2b2f..481ab81 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2,6 +2,7 @@
 #include <linux/errno.h>
 #include <linux/err.h>
 #include <linux/spinlock.h>
+#include <linux/security.h>
 
 #include <linux/mm.h>
 #include <linux/memremap.h>
@@ -416,7 +417,17 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	return 0;
 }
 
-static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
+/*
+ * subject_cred must be the subjective credentials using which access is
+ * requested.
+ * object_cred must be the objective credentials of the target task at the time
+ * the mm_struct was acquired.
+ * Both of these may be NULL if FOLL_FORCE is unset or FOLL_WRITE is unset.
+ */
+static int check_vma_flags(struct vm_area_struct *vma,
+			   const struct cred *subject_cred,
+			   const struct cred *object_cred,
+			   unsigned long gup_flags)
 {
 	vm_flags_t vm_flags = vma->vm_flags;
 	int write = (gup_flags & FOLL_WRITE);
@@ -426,9 +437,19 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 		return -EFAULT;
 
 	if (write) {
+		/* If one of the cred parameters is missing and the WRITE and
+		 * FORCE flags are set, that's a kernel bug.
+		 */
+		if (WARN_ON((gup_flags & FOLL_FORCE) &&
+		    (subject_cred == NULL || object_cred == NULL)))
+			return -EFAULT;
+
 		if (!(vm_flags & VM_WRITE)) {
 			if (!(gup_flags & FOLL_FORCE))
 				return -EFAULT;
+			if (security_forced_write(vma, subject_cred,
+						  object_cred))
+				return -EFAULT;
 			/*
 			 * We used to let the write,force case do COW in a
 			 * VM_MAYWRITE VM_SHARED !VM_WRITE vma, so ptrace could
@@ -517,6 +538,8 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * you need some special @gup_flags.
  */
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		const struct cred *subject_cred,
+		const struct cred *object_cred,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
@@ -557,7 +580,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				goto next_page;
 			}
 
-			if (!vma || check_vma_flags(vma, gup_flags))
+			if (!vma || check_vma_flags(vma, subject_cred,
+						    object_cred, gup_flags))
 				return i ? : -EFAULT;
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
@@ -727,6 +751,8 @@ EXPORT_SYMBOL_GPL(fixup_user_fault);
 
 static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct mm_struct *mm,
+						const struct cred *subject_cred,
+						const struct cred *object_cred,
 						unsigned long start,
 						unsigned long nr_pages,
 						int write, int force,
@@ -755,8 +781,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	pages_done = 0;
 	lock_dropped = false;
 	for (;;) {
-		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+		ret = __get_user_pages(tsk, mm, subject_cred, object_cred,
+				       start, nr_pages, flags, pages, vmas,
+				       locked);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -795,8 +822,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		*locked = 1;
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
-		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+		ret = __get_user_pages(tsk, mm, subject_cred, object_cred,
+				       start, 1, flags | FOLL_TRIED, pages,
+				       NULL, NULL);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -846,9 +874,10 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   int write, int force, struct page **pages,
 			   int *locked)
 {
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       write, force, pages, NULL, locked, true,
-				       FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, current_cred(),
+				       current_real_cred(), start,
+				       nr_pages, write, force, pages, NULL,
+				       locked, true, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -863,6 +892,8 @@ EXPORT_SYMBOL(get_user_pages_locked);
  * respectively.
  */
 __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+					       const struct cred *subject_cred,
+					       const struct cred *object_cred,
 					       unsigned long start, unsigned long nr_pages,
 					       int write, int force, struct page **pages,
 					       unsigned int gup_flags)
@@ -870,8 +901,9 @@ __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct m
 	long ret;
 	int locked = 1;
 	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				      pages, NULL, &locked, false, gup_flags);
+	ret = __get_user_pages_locked(tsk, mm, subject_cred, object_cred, start,
+				      nr_pages, write, force, pages, NULL,
+				      &locked, false, gup_flags);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -898,7 +930,12 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+	/* None of the current callers actually pass write=1 together with
+	 * force=1, but pass in current_cred() and current_read_cred() in case
+	 * that changes in the future.
+	 */
+	return __get_user_pages_unlocked(current, current->mm, current_cred(),
+					 current_real_cred(), start, nr_pages,
 					 write, force, pages, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
@@ -959,12 +996,15 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+		const struct cred *subject_cred,
+		const struct cred *object_cred,
 		unsigned long start, unsigned long nr_pages,
 		int write, int force, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false,
+	return __get_user_pages_locked(tsk, mm, subject_cred, object_cred,
+				       start, nr_pages, write, force, pages,
+				       vmas, NULL, false,
 				       FOLL_TOUCH | FOLL_REMOTE);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
@@ -979,9 +1019,10 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 		int write, int force, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       write, force, pages, vmas, NULL, false,
-				       FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, current_cred(),
+				       current_real_cred(), start,
+				       nr_pages, write, force, pages, vmas,
+				       NULL, false, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1039,7 +1080,8 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * We made sure addr is within a VMA, so the following will
 	 * not result in a stack expansion that recurses back here.
 	 */
-	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
+	return __get_user_pages(current, mm, current_cred(),
+				current_real_cred(), start, nr_pages, gup_flags,
 				NULL, NULL, nonblocking);
 }
 
@@ -1125,7 +1167,7 @@ struct page *get_dump_page(unsigned long addr)
 	struct vm_area_struct *vma;
 	struct page *page;
 
-	if (__get_user_pages(current, current->mm, addr, 1,
+	if (__get_user_pages(current, current->mm, NULL, NULL, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
 			     NULL) < 1)
 		return NULL;
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d..8209d4f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3850,6 +3850,7 @@ EXPORT_SYMBOL_GPL(generic_access_phys);
  * given task for page fault accounting.
  */
 static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+		const struct cred *subject_cred, const struct cred *object_cred,
 		unsigned long addr, void *buf, int len, int write)
 {
 	struct vm_area_struct *vma;
@@ -3862,8 +3863,8 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		void *maddr;
 		struct page *page = NULL;
 
-		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				write, 1, &page, &vma);
+		ret = get_user_pages_remote(tsk, mm, subject_cred, object_cred,
+				addr, 1, write, 1, &page, &vma);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
@@ -3919,28 +3920,35 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
-int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, int write)
+int access_remote_vm(struct mm_struct *mm, const struct cred *subject_cred,
+		     const struct cred *object_cred, unsigned long addr,
+		     void *buf, int len, int write)
 {
-	return __access_remote_vm(NULL, mm, addr, buf, len, write);
+	return __access_remote_vm(NULL, mm, subject_cred, object_cred, addr,
+				  buf, len, write);
 }
 
 /*
  * Access another process' address space.
  * Source/target buffer must be kernel space,
- * Do not walk the page table directly, use get_user_pages
+ * Do not walk the page table directly, use get_user_pages.
+ * @tsk must be ptrace-stopped by current.
  */
 int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, int write)
 {
 	struct mm_struct *mm;
 	int ret;
+	const struct cred *object_cred;
 
 	mm = get_task_mm(tsk);
 	if (!mm)
 		return 0;
+	object_cred = get_task_cred(tsk);
 
-	ret = __access_remote_vm(tsk, mm, addr, buf, len, write);
+	ret = __access_remote_vm(tsk, mm, current_cred(), object_cred, addr,
+				 buf, len, write);
+	put_cred(object_cred);
 	mmput(mm);
 
 	return ret;
diff --git a/mm/nommu.c b/mm/nommu.c
index 95daf81..ebb03ba 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -110,6 +110,8 @@ unsigned int kobjsize(const void *objp)
 }
 
 long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		      const struct cred *subject_cred,
+		      const struct cred *object_cred,
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking)
@@ -170,8 +172,8 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 	if (force)
 		flags |= FOLL_FORCE;
 
-	return __get_user_pages(current, current->mm, start, nr_pages, flags,
-				pages, vmas, NULL);
+	return __get_user_pages(current, current->mm, NULL, NULL, start,
+				nr_pages, flags, pages, vmas, NULL);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -184,14 +186,16 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 EXPORT_SYMBOL(get_user_pages_locked);
 
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       const struct cred *subject_cred,
+			       const struct cred *object_cred,
 			       unsigned long start, unsigned long nr_pages,
 			       int write, int force, struct page **pages,
 			       unsigned int gup_flags)
 {
 	long ret;
 	down_read(&mm->mmap_sem);
-	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
-				NULL, NULL);
+	ret = __get_user_pages(tsk, mm, subject_cred, object_cred, start,
+				nr_pages, gup_flags, pages, NULL, NULL);
 	up_read(&mm->mmap_sem);
 	return ret;
 }
@@ -200,8 +204,9 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
-					 write, force, pages, 0);
+	return __get_user_pages_unlocked(current, current->mm, NULL, NULL,
+					 start, nr_pages, write, force, pages,
+					 0);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
@@ -1858,8 +1863,9 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
-int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, int write)
+int access_remote_vm(struct mm_struct *mm, const struct cred *subject_cred,
+		const struct cred *object_cred, unsigned long addr, void *buf,
+		int len, int write)
 {
 	return __access_remote_vm(NULL, mm, addr, buf, len, write);
 }
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 07514d4..9f2b6a1 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -103,9 +103,9 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * add FOLL_REMOTE because task/mm might not
 		 * current/current->mm
 		 */
-		pages = __get_user_pages_unlocked(task, mm, pa, pages,
-						  vm_write, 0, process_pages,
-						  FOLL_REMOTE);
+		pages = __get_user_pages_unlocked(task, mm, NULL, NULL, pa,
+						  pages, vm_write, 0,
+						  process_pages, FOLL_REMOTE);
 		if (pages <= 0)
 			return -EFAULT;
 
@@ -199,7 +199,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 		goto free_proc_pages;
 	}
 
-	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	mm = mm_access(task, NULL, PTRACE_MODE_ATTACH_REALCREDS);
 	if (!mm || IS_ERR(mm)) {
 		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
 		/*
diff --git a/security/security.c b/security/security.c
index 4838e7f..0c16a6c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -164,6 +164,13 @@ int security_ptrace_traceme(struct task_struct *parent)
 	return call_int_hook(ptrace_traceme, 0, parent);
 }
 
+int security_forced_write(struct vm_area_struct *vma,
+			  const struct cred *subject_cred,
+			  const struct cred *object_cred)
+{
+	return call_int_hook(forced_write, 0, vma, subject_cred, object_cred);
+}
+
 int security_capget(struct task_struct *target,
 		     kernel_cap_t *effective,
 		     kernel_cap_t *inheritable,
@@ -1582,6 +1589,7 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.ptrace_access_check),
 	.ptrace_traceme =
 		LIST_HEAD_INIT(security_hook_heads.ptrace_traceme),
+	.forced_write =	LIST_HEAD_INIT(security_hook_heads.forced_write),
 	.capget =	LIST_HEAD_INIT(security_hook_heads.capget),
 	.capset =	LIST_HEAD_INIT(security_hook_heads.capset),
 	.capable =	LIST_HEAD_INIT(security_hook_heads.capable),
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index ade7c6c..f5acc47 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -880,7 +880,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * (represented by bprm).  'current' is the process doing
 	 * the execve().
 	 */
-	if (get_user_pages_remote(current, bprm->mm, pos, 1,
+	if (get_user_pages_remote(current, bprm->mm, NULL, NULL, pos, 1,
 				0, 1, &page, NULL) <= 0)
 		return false;
 #else
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index db96688..e49acb7 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -84,7 +84,8 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * use FOLL_REMOTE.
 	 */
-	__get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL, FOLL_REMOTE);
+	__get_user_pages_unlocked(NULL, mm, NULL, NULL, addr, 1, 1, 0, NULL,
+				  FOLL_REMOTE);
 
 	kvm_async_page_present_sync(vcpu, apf);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 1950782..5bedffe 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1349,15 +1349,15 @@ static int get_user_page_nowait(unsigned long start, int write,
 	if (write)
 		flags |= FOLL_WRITE;
 
-	return __get_user_pages(current, current->mm, start, 1, flags, page,
-			NULL, NULL);
+	return __get_user_pages(current, current->mm, NULL, NULL, start, 1,
+			flags, page, NULL, NULL);
 }
 
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
 
-	rc = __get_user_pages(current, current->mm, addr, 1,
+	rc = __get_user_pages(current, current->mm, NULL, NULL, addr, 1,
 			      flags, NULL, NULL, NULL);
 	return rc == -EHWPOISON;
 }
@@ -1415,7 +1415,8 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		npages = get_user_page_nowait(addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
 	} else
-		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
+		npages = __get_user_pages_unlocked(current, current->mm, NULL,
+						   NULL, addr, 1,
 						   write_fault, 0, page,
 						   FOLL_TOUCH|FOLL_HWPOISON);
 	if (npages != 1)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
