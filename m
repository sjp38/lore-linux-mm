Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 578686B02AF
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 23:04:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so22429642wml.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:04:55 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id u8si22586969wmd.98.2016.11.02.20.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 20:04:53 -0700 (PDT)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH 2/3] mm: add LSM hook for writes to readonly memory
Date: Thu,  3 Nov 2016 04:04:42 +0100
Message-Id: <1478142286-18427-2-git-send-email-jann@thejh.net>
In-Reply-To: <1478142286-18427-1-git-send-email-jann@thejh.net>
References: <1478142286-18427-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SELinux attempts to make it possible to whitelist trustworthy sources of
code that may be mapped into memory, and Android makes use of this feature.
To prevent an attacker from bypassing this by modifying R+X memory through
/proc/$pid/mem, PTRACE_POKETEXT or DMA, it is necessary to call a security
hook in check_vma_flags().

PTRACE_POKETEXT can also be mitigated by blocking ptrace access, and
/proc/$pid/mem can also be blocked at the VFS layer, but DMA is harder to
deal with: Some driver functions (e.g. videobuf_dma_init_user_locked)
write to user-specified DMA mappings even if those mappings are readonly
or R+X.

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

changed in v3:
 - rebase
 - no need to pass in creds in populate_vma_page_range()
 - reword check_vma_flags() comment (Ingo Molnar)
 - use helper struct gup_creds (Ingo Molnar)

Signed-off-by: Jann Horn <jann@thejh.net>
---
 drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  5 ++-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  2 +-
 fs/exec.c                               |  2 +-
 fs/proc/base.c                          | 70 +++++++++++++++++++++++++--------
 fs/proc/internal.h                      |  4 +-
 fs/proc/task_mmu.c                      |  4 +-
 fs/proc/task_nommu.c                    |  2 +-
 include/linux/lsm_hooks.h               |  9 +++++
 include/linux/mm.h                      | 19 ++++++++-
 include/linux/sched.h                   |  4 +-
 include/linux/security.h                |  8 ++++
 kernel/events/uprobes.c                 |  8 ++--
 kernel/fork.c                           |  6 ++-
 mm/gup.c                                | 66 ++++++++++++++++++++++---------
 mm/memory.c                             | 22 ++++++-----
 mm/nommu.c                              | 13 +++---
 mm/process_vm_access.c                  |  4 +-
 security/security.c                     | 14 +++++++
 security/tomoyo/domain.c                |  4 +-
 virt/kvm/async_pf.c                     |  2 +-
 virt/kvm/kvm_main.c                     |  4 +-
 22 files changed, 200 insertions(+), 74 deletions(-)

diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index 0370b842d9cc..a10bb860b8b7 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -762,8 +762,9 @@ static struct page **etnaviv_gem_userptr_do_get_pages(
 
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
-		ret = get_user_pages_remote(task, mm, ptr, npages - pinned,
-					    flags, pvec + pinned, NULL);
+		ret = get_user_pages_remote(task, mm, NULL, ptr,
+					    npages - pinned, flags,
+					    pvec + pinned, NULL);
 		if (ret < 0)
 			break;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index c6f780f5abc9..d5d2e69baabe 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -518,7 +518,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
 			down_read(&mm->mmap_sem);
 			while (pinned < npages) {
 				ret = get_user_pages_remote
-					(work->task, mm,
+					(work->task, mm, NULL,
 					 obj->userptr.ptr + pinned * PAGE_SIZE,
 					 npages - pinned,
 					 flags,
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 1f0fe3217f23..cb4e805dc0ac 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -577,7 +577,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 		 * cases).
 		 */
 		npages = get_user_pages_remote(owning_process, owning_mm,
-				user_virt, gup_num_pages,
+				NULL, user_virt, gup_num_pages,
 				flags, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
 
diff --git a/fs/exec.c b/fs/exec.c
index dbc2dd2f0829..3d9ee5a52ca4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -208,7 +208,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * We are doing an exec().  'current' is the process
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
-	ret = get_user_pages_remote(current, bprm->mm, pos, 1, gup_flags,
+	ret = get_user_pages_remote(current, bprm->mm, NULL, pos, 1, gup_flags,
 			&page, NULL);
 	if (ret <= 0)
 		return NULL;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index ca651ac00660..e9542240408c 100644
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
+	rv = access_remote_vm(mm, NULL, arg_end - 1, &c, 1, 0);
 	if (rv <= 0)
 		goto out_free_page;
 
@@ -270,7 +275,8 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 			int nr_read;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -305,7 +311,8 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 			bool final;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -354,7 +361,8 @@ static ssize_t proc_pid_cmdline_read(struct file *file, char __user *buf,
 			bool final;
 
 			_count = min3(count, len, PAGE_SIZE);
-			nr_read = access_remote_vm(mm, p, page, _count, 0);
+			nr_read = access_remote_vm(mm, NULL, p, page,
+						   _count, 0);
 			if (nr_read < 0)
 				rv = nr_read;
 			if (nr_read <= 0)
@@ -784,13 +792,15 @@ static const struct file_operations proc_single_file_operations = {
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
@@ -806,7 +816,7 @@ struct mm_struct *proc_mem_open(struct inode *inode, unsigned int mode)
 
 static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 {
-	struct mm_struct *mm = proc_mem_open(inode, mode);
+	struct mm_struct *mm = proc_mem_open(inode, NULL, mode);
 
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
@@ -817,22 +827,41 @@ static int __mem_open(struct inode *inode, struct file *file, unsigned int mode)
 
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
 	unsigned int flags;
+	struct gup_creds creds;
 
 	if (!mm)
 		return 0;
@@ -850,6 +879,9 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 	if (write)
 		flags |= FOLL_WRITE;
 
+	creds.subject = file->f_cred;
+	creds.object = private->object_cred;
+
 	while (count > 0) {
 		int this_len = min_t(int, count, PAGE_SIZE);
 
@@ -858,7 +890,8 @@ static ssize_t mem_rw(struct file *file, char __user *buf,
 			break;
 		}
 
-		this_len = access_remote_vm(mm, addr, page, this_len, flags);
+		this_len = access_remote_vm(mm, &creds, addr, page, this_len,
+					    flags);
 		if (!this_len) {
 			if (!copied)
 				copied = -EIO;
@@ -913,9 +946,13 @@ loff_t mem_lseek(struct file *file, loff_t offset, int orig)
 
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
 
@@ -970,7 +1007,8 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		max_len = min_t(size_t, PAGE_SIZE, count);
 		this_len = min(max_len, this_len);
 
-		retval = access_remote_vm(mm, (env_start + src), page, this_len, 0);
+		retval = access_remote_vm(mm, NULL, (env_start + src),
+					  page, this_len, 0);
 
 		if (retval <= 0) {
 			ret = retval;
@@ -1888,7 +1926,7 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	if (!task)
 		goto out_notask;
 
-	mm = mm_access(task, PTRACE_MODE_READ_FSCREDS);
+	mm = mm_access(task, NULL, PTRACE_MODE_READ_FSCREDS);
 	if (IS_ERR_OR_NULL(mm))
 		goto out;
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 5378441ec1b7..1b5b737ba5a7 100644
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
index 35b92d81692f..fc5024dd8ee6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -232,7 +232,7 @@ static int proc_maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
@@ -1436,7 +1436,7 @@ static int pagemap_open(struct inode *inode, struct file *file)
 {
 	struct mm_struct *mm;
 
-	mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(mm))
 		return PTR_ERR(mm);
 	file->private_data = mm;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 37175621e890..cb6e0f612c6b 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -279,7 +279,7 @@ static int maps_open(struct inode *inode, struct file *file,
 		return -ENOMEM;
 
 	priv->inode = inode;
-	priv->mm = proc_mem_open(inode, PTRACE_MODE_READ);
+	priv->mm = proc_mem_open(inode, NULL, PTRACE_MODE_READ);
 	if (IS_ERR(priv->mm)) {
 		int err = PTR_ERR(priv->mm);
 
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 558adfa5c8a8..cfa2d454fb3f 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -27,6 +27,7 @@
 #include <linux/security.h>
 #include <linux/init.h>
 #include <linux/rculist.h>
+#include <linux/mm.h>
 
 /**
  * Security hooks for program execution operations.
@@ -1181,6 +1182,11 @@
  *	to the @parent process for tracing.
  *	@parent contains the task_struct structure for debugger process.
  *	Return 0 if permission is granted.
+ * @forced_write:
+ *	Check whether @creds->subject is permitted to forcibly write to the
+ *	non-writable mapping @vma that belongs to a process with objective
+ *	credentials @creds->object.
+ *	Return 0 if permission is granted.
  * @capget:
  *	Get the @effective, @inheritable, and @permitted capability sets for
  *	the @target process.  The hook may also perform permission checking to
@@ -1344,6 +1350,8 @@ union security_list_options {
 	int (*ptrace_access_check)(struct task_struct *child,
 					unsigned int mode);
 	int (*ptrace_traceme)(struct task_struct *parent);
+	int (*forced_write)(struct vm_area_struct *vma,
+			const struct gup_creds *creds);
 	int (*capget)(struct task_struct *target, kernel_cap_t *effective,
 			kernel_cap_t *inheritable, kernel_cap_t *permitted);
 	int (*capset)(struct cred *new, const struct cred *old,
@@ -1661,6 +1669,7 @@ struct security_hook_heads {
 	struct list_head binder_transfer_file;
 	struct list_head ptrace_access_check;
 	struct list_head ptrace_traceme;
+	struct list_head forced_write;
 	struct list_head capget;
 	struct list_head capset;
 	struct list_head capable;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d73aeaf..e67639d6661a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -23,6 +23,7 @@
 #include <linux/page_ext.h>
 #include <linux/err.h>
 #include <linux/page_ref.h>
+#include <linux/cred.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1266,12 +1267,25 @@ static inline int fixup_user_fault(struct task_struct *tsk,
 }
 #endif
 
+/*
+ * used to pass security information to LSMs through get_user_pages* for forced
+ * writes (FOLL_WRITE|FOLL_FORCE)
+ */
+struct gup_creds {
+	const struct cred *subject; /* who is trying to write? */
+	const struct cred *object; /* whose memory is written to? */
+};
+/* use when current is writing to its own memory */
+#define GUP_CREDS_CURRENT ((struct gup_creds *)0x1UL)
+
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len,
 		unsigned int gup_flags);
-extern int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, unsigned int gup_flags);
+extern int access_remote_vm(struct mm_struct *mm,
+		const struct gup_creds *creds, unsigned long addr, void *buf,
+		int len, unsigned int gup_flags);
 
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+			    const struct gup_creds *creds,
 			    unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
@@ -1281,6 +1295,7 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       const struct gup_creds *creds,
 			       unsigned long start, unsigned long nr_pages,
 			       struct page **pages, unsigned int gup_flags);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b0ec92..c8d6e85292c5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2913,7 +2913,9 @@ extern struct mm_struct *get_task_mm(struct task_struct *task);
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
index c2125e9093e8..e9229e263d39 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -193,6 +193,8 @@ int security_binder_transfer_file(struct task_struct *from,
 				  struct task_struct *to, struct file *file);
 int security_ptrace_access_check(struct task_struct *child, unsigned int mode);
 int security_ptrace_traceme(struct task_struct *parent);
+int security_forced_write(struct vm_area_struct *vma,
+			  const struct gup_creds *creds);
 int security_capget(struct task_struct *target,
 		    kernel_cap_t *effective,
 		    kernel_cap_t *inheritable,
@@ -429,6 +431,12 @@ static inline int security_ptrace_traceme(struct task_struct *parent)
 	return cap_ptrace_traceme(parent);
 }
 
+static inline int security_forced_write(struct vm_area_struct *vma,
+					const struct gup_creds *creds)
+{
+	return 0;
+}
+
 static inline int security_capget(struct task_struct *target,
 				   kernel_cap_t *effective,
 				   kernel_cap_t *inheritable,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index f9ec9add2164..7d91c732cfc5 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -300,8 +300,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 
 retry:
 	/* Read the page with vaddr into memory */
-	ret = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &old_page,
-			&vma);
+	ret = get_user_pages_remote(NULL, mm, NULL, vaddr, 1, FOLL_FORCE,
+			&old_page, &vma);
 	if (ret <= 0)
 		return ret;
 
@@ -1711,8 +1711,8 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 	 * but we treat this as a 'remote' access since it is
 	 * essentially a kernel access to the memory.
 	 */
-	result = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &page,
-			NULL);
+	result = get_user_pages_remote(NULL, mm, NULL, vaddr, 1, FOLL_FORCE,
+				       &page, NULL);
 	if (result < 0)
 		return result;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 623259fc794d..997432afad63 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -993,7 +993,8 @@ struct mm_struct *get_task_mm(struct task_struct *task)
 }
 EXPORT_SYMBOL_GPL(get_task_mm);
 
-struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
+struct mm_struct *mm_access(struct task_struct *task,
+			    const struct cred **object_cred, unsigned int mode)
 {
 	struct mm_struct *mm;
 	int err;
@@ -1008,6 +1009,9 @@ struct mm_struct *mm_access(struct task_struct *task, unsigned int mode)
 		mmput(mm);
 		mm = ERR_PTR(-EACCES);
 	}
+	if (!IS_ERR_OR_NULL(mm) && object_cred)
+		*object_cred = get_task_cred(task);
+
 	mutex_unlock(&task->signal->cred_guard_mutex);
 
 	return mm;
diff --git a/mm/gup.c b/mm/gup.c
index ec4f82704b6f..b702e3929fa8 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2,6 +2,7 @@
 #include <linux/errno.h>
 #include <linux/err.h>
 #include <linux/spinlock.h>
+#include <linux/security.h>
 
 #include <linux/mm.h>
 #include <linux/memremap.h>
@@ -426,7 +427,15 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	return 0;
 }
 
-static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
+/*
+ * @creds->subject is the subject on whose behalf memory is accessed.
+ * @creds->object contains the objective credentials of the target task at the
+ * time the mm_struct was looked up.
+ * @creds may be NULL if FOLL_FORCE is unset or FOLL_WRITE is unset.
+ */
+static int check_vma_flags(struct vm_area_struct *vma,
+			   const struct gup_creds *creds,
+			   unsigned long gup_flags)
 {
 	vm_flags_t vm_flags = vma->vm_flags;
 	int write = (gup_flags & FOLL_WRITE);
@@ -436,9 +445,18 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 		return -EFAULT;
 
 	if (write) {
+		/*
+		 * If one of the cred parameters is missing and the WRITE and
+		 * FORCE flags are set, that's a kernel bug.
+		 */
+		if (WARN_ON((gup_flags & FOLL_FORCE) && creds == NULL))
+			return -EFAULT;
+
 		if (!(vm_flags & VM_WRITE)) {
 			if (!(gup_flags & FOLL_FORCE))
 				return -EFAULT;
+			if (security_forced_write(vma, creds))
+				return -EFAULT;
 			/*
 			 * We used to let the write,force case do COW in a
 			 * VM_MAYWRITE VM_SHARED !VM_WRITE vma, so ptrace could
@@ -527,6 +545,7 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
  * you need some special @gup_flags.
  */
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		const struct gup_creds *creds,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
@@ -567,7 +586,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				goto next_page;
 			}
 
-			if (!vma || check_vma_flags(vma, gup_flags))
+			if (!vma || check_vma_flags(vma, creds, gup_flags))
 				return i ? : -EFAULT;
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
@@ -736,6 +755,7 @@ EXPORT_SYMBOL_GPL(fixup_user_fault);
 
 static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct mm_struct *mm,
+						const struct gup_creds *creds,
 						unsigned long start,
 						unsigned long nr_pages,
 						struct page **pages,
@@ -759,8 +779,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	pages_done = 0;
 	lock_dropped = false;
 	for (;;) {
-		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+		ret = __get_user_pages(tsk, mm, creds, start, nr_pages, flags,
+				       pages, vmas, locked);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -799,8 +819,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		*locked = 1;
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
-		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+		ret = __get_user_pages(tsk, mm, creds, start, 1,
+				       flags | FOLL_TRIED, pages, NULL, NULL);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -850,9 +870,9 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   unsigned int gup_flags, struct page **pages,
 			   int *locked)
 {
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, NULL, locked, true,
-				       gup_flags | FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, GUP_CREDS_CURRENT,
+				       start, nr_pages, pages, NULL, locked,
+				       true, gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -867,6 +887,7 @@ EXPORT_SYMBOL(get_user_pages_locked);
  * respectively.
  */
 __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+					       const struct gup_creds *creds,
 					       unsigned long start, unsigned long nr_pages,
 					       struct page **pages, unsigned int gup_flags)
 {
@@ -874,8 +895,8 @@ __always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct m
 	int locked = 1;
 
 	down_read(&mm->mmap_sem);
-	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, pages, NULL,
-				      &locked, false, gup_flags);
+	ret = __get_user_pages_locked(tsk, mm, creds, start, nr_pages, pages,
+				      NULL, &locked, false, gup_flags);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -902,7 +923,13 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
 {
-	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+	/*
+	 * None of the current callers actually pass write=1 together with
+	 * force=1, but pass in current_cred() and current_read_cred() in case
+	 * that changes in the future.
+	 */
+	return __get_user_pages_unlocked(current, current->mm,
+					 GUP_CREDS_CURRENT, start, nr_pages,
 					 pages, gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
@@ -961,12 +988,13 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
 long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
+		const struct gup_creds *creds,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
-				       NULL, false,
+	return __get_user_pages_locked(tsk, mm, creds, start, nr_pages, pages,
+				       vmas, NULL, false,
 				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
@@ -981,9 +1009,9 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, vmas, NULL, false,
-				       gup_flags | FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, GUP_CREDS_CURRENT,
+				       start, nr_pages, pages, vmas, NULL,
+				       false, gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1041,7 +1069,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * We made sure addr is within a VMA, so the following will
 	 * not result in a stack expansion that recurses back here.
 	 */
-	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
+	return __get_user_pages(current, mm, NULL, start, nr_pages, gup_flags,
 				NULL, NULL, nonblocking);
 }
 
@@ -1127,7 +1155,7 @@ struct page *get_dump_page(unsigned long addr)
 	struct vm_area_struct *vma;
 	struct page *page;
 
-	if (__get_user_pages(current, current->mm, addr, 1,
+	if (__get_user_pages(current, current->mm, NULL, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
 			     NULL) < 1)
 		return NULL;
diff --git a/mm/memory.c b/mm/memory.c
index e18c57bdc75c..2a8ec5ab7550 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3869,6 +3869,7 @@ EXPORT_SYMBOL_GPL(generic_access_phys);
  * given task for page fault accounting.
  */
 static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
+		const struct gup_creds *creds,
 		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
 	struct vm_area_struct *vma;
@@ -3882,8 +3883,8 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		void *maddr;
 		struct page *page = NULL;
 
-		ret = get_user_pages_remote(tsk, mm, addr, 1,
-				gup_flags, &page, &vma);
+		ret = get_user_pages_remote(tsk, mm, creds,
+				addr, 1, gup_flags, &page, &vma);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
 			break;
@@ -3939,29 +3940,32 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
-int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, unsigned int gup_flags)
+int access_remote_vm(struct mm_struct *mm, const struct gup_creds *creds,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
-	return __access_remote_vm(NULL, mm, addr, buf, len, gup_flags);
+	return __access_remote_vm(NULL, mm, creds, addr, buf, len, gup_flags);
 }
 
 /*
  * Access another process' address space.
  * Source/target buffer must be kernel space,
- * Do not walk the page table directly, use get_user_pages
+ * Do not walk the page table directly, use get_user_pages.
+ * @tsk must be ptrace-stopped by current.
  */
 int access_process_vm(struct task_struct *tsk, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags)
 {
 	struct mm_struct *mm;
 	int ret;
+	struct gup_creds creds;
 
 	mm = get_task_mm(tsk);
 	if (!mm)
 		return 0;
-
-	ret = __access_remote_vm(tsk, mm, addr, buf, len, gup_flags);
-
+	creds.subject = current_cred();
+	creds.object = get_task_cred(tsk);
+	ret = __access_remote_vm(tsk, mm, &creds, addr, buf, len, gup_flags);
+	put_cred(creds.object);
 	mmput(mm);
 
 	return ret;
diff --git a/mm/nommu.c b/mm/nommu.c
index 8b8faaf2a9e9..222cebcdc231 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -177,13 +177,14 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 EXPORT_SYMBOL(get_user_pages_locked);
 
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+			       const struct gup_creds *creds,
 			       unsigned long start, unsigned long nr_pages,
 			       struct page **pages, unsigned int gup_flags)
 {
 	long ret;
 	down_read(&mm->mmap_sem);
-	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
-				NULL, NULL);
+	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages, NULL,
+			       NULL);
 	up_read(&mm->mmap_sem);
 	return ret;
 }
@@ -192,8 +193,8 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     struct page **pages, unsigned int gup_flags)
 {
-	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
-					 pages, gup_flags);
+	return __get_user_pages_unlocked(current, current->mm, NULL,
+					 start, nr_pages, pages, gup_flags);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
@@ -1851,8 +1852,8 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  *
  * The caller must hold a reference on @mm.
  */
-int access_remote_vm(struct mm_struct *mm, unsigned long addr,
-		void *buf, int len, unsigned int gup_flags)
+int access_remote_vm(struct mm_struct *mm, const struct gup_creds *creds,
+		unsigned long addr, void *buf, int len, unsigned int gup_flags)
 {
 	return __access_remote_vm(NULL, mm, addr, buf, len, gup_flags);
 }
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index be8dc8d1edb9..671d53548bd9 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -107,7 +107,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * add FOLL_REMOTE because task/mm might not
 		 * current/current->mm
 		 */
-		pages = __get_user_pages_unlocked(task, mm, pa, pages,
+		pages = __get_user_pages_unlocked(task, mm, NULL, pa, pages,
 						  process_pages, flags);
 		if (pages <= 0)
 			return -EFAULT;
@@ -202,7 +202,7 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 		goto free_proc_pages;
 	}
 
-	mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	mm = mm_access(task, NULL, PTRACE_MODE_ATTACH_REALCREDS);
 	if (!mm || IS_ERR(mm)) {
 		rc = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
 		/*
diff --git a/security/security.c b/security/security.c
index f825304f04a7..00573d98aec0 100644
--- a/security/security.c
+++ b/security/security.c
@@ -164,6 +164,19 @@ int security_ptrace_traceme(struct task_struct *parent)
 	return call_int_hook(ptrace_traceme, 0, parent);
 }
 
+int security_forced_write(struct vm_area_struct *vma,
+			  const struct gup_creds *creds)
+{
+	struct gup_creds current_creds;
+
+	if (creds == GUP_CREDS_CURRENT) {
+		current_creds.subject = current_cred();
+		current_creds.object = current_real_cred();
+		creds = &current_creds;
+	}
+	return call_int_hook(forced_write, 0, vma, creds);
+}
+
 int security_capget(struct task_struct *target,
 		     kernel_cap_t *effective,
 		     kernel_cap_t *inheritable,
@@ -1603,6 +1616,7 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.ptrace_access_check),
 	.ptrace_traceme =
 		LIST_HEAD_INIT(security_hook_heads.ptrace_traceme),
+	.forced_write =	LIST_HEAD_INIT(security_hook_heads.forced_write),
 	.capget =	LIST_HEAD_INIT(security_hook_heads.capget),
 	.capset =	LIST_HEAD_INIT(security_hook_heads.capset),
 	.capable =	LIST_HEAD_INIT(security_hook_heads.capable),
diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 682b73af7766..9373fc0c7f8e 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -880,8 +880,8 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	 * (represented by bprm).  'current' is the process doing
 	 * the execve().
 	 */
-	if (get_user_pages_remote(current, bprm->mm, pos, 1,
-				FOLL_FORCE, &page, NULL) <= 0)
+	if (get_user_pages_remote(current, bprm->mm, NULL, pos, 1, FOLL_FORCE,
+				  &page, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 8035cc1eb955..2ec0a4a0f502 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -84,7 +84,7 @@ static void async_pf_execute(struct work_struct *work)
 	 * mm and might be done in another context, so we must
 	 * use FOLL_REMOTE.
 	 */
-	__get_user_pages_unlocked(NULL, mm, addr, 1, NULL,
+	__get_user_pages_unlocked(NULL, mm, NULL, addr, 1, NULL,
 			FOLL_WRITE | FOLL_REMOTE);
 
 	kvm_async_page_present_sync(vcpu, apf);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2907b7b78654..8df6969cfce1 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1420,8 +1420,8 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		if (write_fault)
 			flags |= FOLL_WRITE;
 
-		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
-						   page, flags);
+		npages = __get_user_pages_unlocked(current, current->mm, NULL,
+						   addr, 1, page, flags);
 	}
 	if (npages != 1)
 		return npages;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
