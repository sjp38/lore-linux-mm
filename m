Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D9F966B0032
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 21:32:45 -0400 (EDT)
Received: by mail-ve0-f201.google.com with SMTP id ox1so80233veb.4
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 18:32:44 -0700 (PDT)
From: Colin Cross <ccross@android.com>
Subject: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
Date: Wed,  3 Jul 2013 18:31:56 -0700
Message-Id: <1372901537-31033-1-git-send-email-ccross@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Colin Cross <ccross@android.com>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

Userspace processes often have multiple allocators that each do
anonymous mmaps to get memory.  When examining memory usage of
individual processes or systems as a whole, it is useful to be
able to break down the various heaps that were allocated by
each layer and examine their size, RSS, and physical memory
usage.

This patch adds a struct vma_name * containing a string to each
vma.  Every vma with the same name is guaranteed to point to
the same struct vma_name, allowing name equality comparisons
by comparing pointers.  The expected use case is a few names
used by many processes.

A new madvise2 syscall is added that takes a pointer and a size,
which along with the new behavior MADV_NAME can be used to
attach a name to an existing vma.

The names of named anonymous vmas are shown in /proc/pid/maps
as [anon:<name>].  The name of all named vmas are shown in
/proc/pid/smaps in a new "Name" field that is only present
for named vmas.

The only cost for non-named vmas added by this patch is the
check on the vm_name pointer.  For named vmas, it adds a
refcount update to splitting/merging/duplicating vmas,
and unmapping a named vma may require taking a global lock
if it is the last vma with that name.

Signed-off-by: Colin Cross <ccross@android.com>
---
 Documentation/filesystems/proc.txt     |   6 +
 fs/proc/task_mmu.c                     |  10 ++
 include/linux/mm.h                     |   7 +-
 include/linux/mm_types.h               |   3 +
 include/linux/syscalls.h               |   2 +
 include/uapi/asm-generic/mman-common.h |   1 +
 kernel/fork.c                          |   3 +
 kernel/sys_ni.c                        |   1 +
 mm/Makefile                            |   3 +-
 mm/madvise.c                           | 179 ++++++++++++++++++++-------
 mm/mempolicy.c                         |   2 +-
 mm/mlock.c                             |   2 +-
 mm/mmap.c                              |  45 +++++--
 mm/mprotect.c                          |   3 +-
 mm/nommu.c                             |   5 +
 mm/vma_name.c                          | 220 +++++++++++++++++++++++++++++++++
 16 files changed, 427 insertions(+), 65 deletions(-)
 create mode 100644 mm/vma_name.c

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index fd8d0d5..04eabf3 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -369,6 +369,8 @@ is not associated with a file:
  [stack:1001]             = the stack of the thread with tid 1001
  [vdso]                   = the "virtual dynamic shared object",
                             the kernel system call handler
+ [anon:<name>]            = an anonymous mapping that has been
+                            named by MADV_NAME
 
  or if empty, the mapping is anonymous.
 
@@ -419,6 +421,7 @@ KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:              374 kB
 VmFlags: rd ex mr mw me de
+Name:           name_from_MADV_NAME
 
 the first of these lines shows the same information as is displayed for the
 mapping in /proc/PID/maps.  The remaining lines show the size of the mapping
@@ -469,6 +472,9 @@ Note that there is no guarantee that every flag and associated mnemonic will
 be present in all further kernel releases. Things get changed, the flags may
 be vanished or the reverse -- new added.
 
+The "Name" field will only be present on a mapping that has had MADV_NAME
+called on it, and will show the name passed in by userspace.
+
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 3e636d8..6741031 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -335,6 +335,12 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 				pad_len_spaces(m, len);
 				seq_printf(m, "[stack:%d]", tid);
 			}
+			goto done;
+		}
+
+		if (vma->vm_name) {
+			pad_len_spaces(m, len);
+			seq_printf(m, "[anon:%s]", vma_name_str(vma->vm_name));
 		}
 	}
 
@@ -634,6 +640,10 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 
 	show_smap_vma_flags(m, vma);
 
+	if (vma->vm_name)
+		seq_printf(m, "Name:           %s\n",
+				vma_name_str(vma->vm_name));
+
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version = (vma != get_gate_vma(task->mm))
 			? vma->vm_start : 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bd5679d..5727611 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1486,7 +1486,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *);
+	struct mempolicy *, struct vma_name *);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
 	struct vm_area_struct *, unsigned long addr, int new_below);
@@ -1829,5 +1829,10 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+struct vma_name *vma_name_get_from_str(const char *name, size_t name_len);
+void vma_name_get(struct vma_name *vma_name);
+void vma_name_put(struct vma_name *vma_name);
+const char *vma_name_str(struct vma_name *vma_name);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ace9a5f..f2491ab 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -219,6 +219,8 @@ struct vm_region {
 						* this region */
 };
 
+struct vma_name;
+
 /*
  * This struct defines a memory VMM memory area. There is one of these
  * per VM-area/task.  A VM area is any part of the process virtual memory
@@ -289,6 +291,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct vma_name *vm_name;
 };
 
 struct core_thread {
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 4147d70..d3a4b65 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -841,4 +841,6 @@ asmlinkage long sys_process_vm_writev(pid_t pid,
 asmlinkage long sys_kcmp(pid_t pid1, pid_t pid2, int type,
 			 unsigned long idx1, unsigned long idx2);
 asmlinkage long sys_finit_module(int fd, const char __user *uargs, int flags);
+asmlinkage long sys_madvise2(unsigned long start, size_t len_in, int behavior,
+			     void * __user arg, size_t arg_len);
 #endif
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index 4164529..ecb8a41 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -51,6 +51,7 @@
 #define MADV_DONTDUMP   16		/* Explicity exclude from the core dump,
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
+#define MADV_NAME	18		/* Set a userspace visible name */
 
 /* compatibility flags */
 #define MAP_FILE	0
diff --git a/kernel/fork.c b/kernel/fork.c
index 41671a5..07d0e55 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -451,6 +451,9 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 			mutex_unlock(&mapping->i_mmap_mutex);
 		}
 
+		if (tmp->vm_name)
+			vma_name_get(tmp->vm_name);
+
 		/*
 		 * Clear hugetlb-related page reserves for children. This only
 		 * affects MAP_PRIVATE mappings. Faults generated by the child
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7078052..128fe64 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,6 +175,7 @@ cond_syscall(sys_mremap);
 cond_syscall(sys_remap_file_pages);
 cond_syscall(compat_sys_move_pages);
 cond_syscall(compat_sys_migrate_pages);
+cond_syscall(sys_madvise2);
 
 /* block-layer dependent */
 cond_syscall(sys_bdflush);
diff --git a/mm/Makefile b/mm/Makefile
index 72c5acb..586c91d 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,8 +17,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   util.o mmzone.o vmstat.o backing-dev.o \
 			   mm_init.o mmu_context.o percpu.o slab_common.o \
 			   compaction.o balloon_compaction.o \
-			   interval_tree.o $(mmu-y)
-
+			   interval_tree.o vma_name.o $(mmu-y)
 obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
diff --git a/mm/madvise.c b/mm/madvise.c
index 7055883..5cd80c9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -19,6 +19,8 @@
 #include <linux/blkdev.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/limits.h>
+#include <linux/err.h>
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
@@ -44,12 +46,14 @@ static int madvise_need_mmap_write(int behavior)
  */
 static long madvise_behavior(struct vm_area_struct * vma,
 		     struct vm_area_struct **prev,
-		     unsigned long start, unsigned long end, int behavior)
+		     unsigned long start, unsigned long end, int behavior,
+		     void *arg, size_t arg_len)
 {
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
 	unsigned long new_flags = vma->vm_flags;
+	struct vma_name *new_name = vma->vm_name;
 
 	switch (behavior) {
 	case MADV_NORMAL:
@@ -93,16 +97,28 @@ static long madvise_behavior(struct vm_area_struct * vma,
 		if (error)
 			goto out;
 		break;
+	case MADV_NAME:
+		if (arg) {
+			new_name = vma_name_get_from_str(arg, arg_len);
+			if (!new_name) {
+				error = -ENOMEM;
+				goto out;
+			}
+		} else {
+			new_name = NULL;
+		}
+		break;
 	}
 
-	if (new_flags == vma->vm_flags) {
+	if (new_flags == vma->vm_flags && new_name == vma->vm_name) {
 		*prev = vma;
 		goto out;
 	}
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
-				vma->vm_file, pgoff, vma_policy(vma));
+				vma->vm_file, pgoff, vma_policy(vma),
+				new_name);
 	if (*prev) {
 		vma = *prev;
 		goto success;
@@ -127,8 +143,17 @@ success:
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
+	if (vma->vm_name != new_name) {
+		if (vma->vm_name)
+			vma_name_put(vma->vm_name);
+		if (new_name)
+			vma_name_get(new_name);
+		vma->vm_name = new_name;
+	}
 
 out:
+	if (behavior == MADV_NAME && new_name)
+		vma_name_put(new_name);
 	if (error == -ENOMEM)
 		error = -EAGAIN;
 	return error;
@@ -371,7 +396,8 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+		unsigned long start, unsigned long end, int behavior,
+		void *arg, size_t arg_len)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -381,7 +407,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
-		return madvise_behavior(vma, prev, start, end, behavior);
+		return madvise_behavior(vma, prev, start, end, behavior, arg,
+					arg_len);
 	}
 }
 
@@ -407,6 +434,7 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_NAME:
 		return 1;
 
 	default:
@@ -414,49 +442,52 @@ madvise_behavior_valid(int behavior)
 	}
 }
 
+static void *madvise_get_arg(int behavior, void __user *user_arg,
+			     size_t arg_len)
+{
+	void *arg;
+	size_t max = NAME_MAX;
+
+	if (behavior != MADV_NAME)
+		return NULL;
+
+	if (!arg_len)
+		return NULL;
+
+	if (!user_arg)
+		return NULL;
+
+	arg_len = min(arg_len, max);
+	arg = kmalloc(arg_len, GFP_KERNEL);
+	if (!arg)
+		return ERR_PTR(-ENOMEM);
+	if (copy_from_user(arg, user_arg, arg_len)) {
+		kfree(arg);
+		return ERR_PTR(-EFAULT);
+	}
+
+	return arg;
+}
+
+static void madvise_put_arg(int behavior, void *arg)
+{
+	if (behavior == MADV_NAME)
+		kfree(arg);
+}
+
 /*
- * The madvise(2) system call.
+ * The madvise2(2) system call.
  *
- * Applications can use madvise() to advise the kernel how it should
- * handle paging I/O in this VM area.  The idea is to help the kernel
- * use appropriate read-ahead and caching techniques.  The information
- * provided is advisory only, and can be safely disregarded by the
- * kernel without affecting the correct operation of the application.
- *
- * behavior values:
- *  MADV_NORMAL - the default behavior is to read clusters.  This
- *		results in some read-ahead and read-behind.
- *  MADV_RANDOM - the system should read the minimum amount of data
- *		on any access, since it is unlikely that the appli-
- *		cation will need more than what it asks for.
- *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
- *		once, so they can be aggressively read ahead, and
- *		can be freed soon after they are accessed.
- *  MADV_WILLNEED - the application is notifying the system to read
- *		some pages ahead.
- *  MADV_DONTNEED - the application is finished with the given range,
- *		so the kernel can free resources associated with it.
- *  MADV_REMOVE - the application wants to free up the given range of
- *		pages and associated backing store.
- *  MADV_DONTFORK - omit this area from child's address space when forking:
- *		typically, to avoid COWing pages pinned by get_user_pages().
- *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
- *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
- *		this area with pages of identical content from other such areas.
- *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
- *
- * return values:
- *  zero    - success
- *  -EINVAL - start + len < 0, start is not page-aligned,
- *		"behavior" is not a valid value, or application
- *		is attempting to release locked or shared pages.
- *  -ENOMEM - addresses in the specified range are not currently
- *		mapped, or are outside the AS of the process.
- *  -EIO    - an I/O error occurred while paging in data.
- *  -EBADF  - map exists, but area maps something that isn't a file.
- *  -EAGAIN - a kernel resource was temporarily unavailable.
+ * The same as madvise(2), but takes extra parameters.  Applications can use
+ * madvise2() for all the same behaviors as madvise(), ignoring the user_arg and
+ * arg_len arguments, or behavior values:
+ *  MADV_NAME - set name of memory region to string of length arg_len pointed
+ *		to by arg.  The string does not need to be NULL terminated.
+ *		Setting arg to NULL or arg_len to 0 will clear the existing
+ *		name.
  */
-SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
+SYSCALL_DEFINE5(madvise2, unsigned long, start, size_t, len_in, int, behavior,
+	void __user *, arg, size_t, arg_len)
 {
 	unsigned long end, tmp;
 	struct vm_area_struct * vma, *prev;
@@ -465,6 +496,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int write;
 	size_t len;
 	struct blk_plug plug;
+	void *madv_arg;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
@@ -489,6 +521,10 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	if (end == start)
 		return error;
 
+	madv_arg = madvise_get_arg(behavior, arg, arg_len);
+	if (IS_ERR(madv_arg))
+		return PTR_ERR(madv_arg);
+
 	write = madvise_need_mmap_write(behavior);
 	if (write)
 		down_write(&current->mm->mmap_sem);
@@ -525,7 +561,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, madv_arg,
+				    arg_len);
 		if (error)
 			goto out;
 		start = tmp;
@@ -546,5 +583,55 @@ out:
 	else
 		up_read(&current->mm->mmap_sem);
 
+	madvise_put_arg(behavior, madv_arg);
+
 	return error;
 }
+
+
+/*
+ * The madvise(2) system call.
+ *
+ * Applications can use madvise() to advise the kernel how it should
+ * handle paging I/O in this VM area.  The idea is to help the kernel
+ * use appropriate read-ahead and caching techniques.  The information
+ * provided is advisory only, and can be safely disregarded by the
+ * kernel without affecting the correct operation of the application.
+ *
+ * behavior values:
+ *  MADV_NORMAL - the default behavior is to read clusters.  This
+ *		results in some read-ahead and read-behind.
+ *  MADV_RANDOM - the system should read the minimum amount of data
+ *		on any access, since it is unlikely that the appli-
+ *		cation will need more than what it asks for.
+ *  MADV_SEQUENTIAL - pages in the given range will probably be accessed
+ *		once, so they can be aggressively read ahead, and
+ *		can be freed soon after they are accessed.
+ *  MADV_WILLNEED - the application is notifying the system to read
+ *		some pages ahead.
+ *  MADV_DONTNEED - the application is finished with the given range,
+ *		so the kernel can free resources associated with it.
+ *  MADV_REMOVE - the application wants to free up the given range of
+ *		pages and associated backing store.
+ *  MADV_DONTFORK - omit this area from child's address space when forking:
+ *		typically, to avoid COWing pages pinned by get_user_pages().
+ *  MADV_DOFORK - cancel MADV_DONTFORK: no longer omit this area when forking.
+ *  MADV_MERGEABLE - the application recommends that KSM try to merge pages in
+ *		this area with pages of identical content from other such areas.
+ *  MADV_UNMERGEABLE- cancel MADV_MERGEABLE: no longer merge pages with others.
+ *
+ * return values:
+ *  zero    - success
+ *  -EINVAL - start + len < 0, start is not page-aligned,
+ *		"behavior" is not a valid value, or application
+ *		is attempting to release locked or shared pages.
+ *  -ENOMEM - addresses in the specified range are not currently
+ *		mapped, or are outside the AS of the process.
+ *  -EIO    - an I/O error occurred while paging in data.
+ *  -EBADF  - map exists, but area maps something that isn't a file.
+ *  -EAGAIN - a kernel resource was temporarily unavailable.
+ */
+SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
+{
+	return sys_madvise2(start, len_in, behavior, NULL, 0);
+}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..11db490 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -728,7 +728,7 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
 				  vma->anon_vma, vma->vm_file, pgoff,
-				  new_pol);
+				  new_pol, vma->vm_name);
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
diff --git a/mm/mlock.c b/mm/mlock.c
index 79b7cf7..df2ea44 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -287,7 +287,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
-			  vma->vm_file, pgoff, vma_policy(vma));
+			  vma->vm_file, pgoff, vma_policy(vma), vma->vm_name);
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mmap.c b/mm/mmap.c
index f681e18..4ddd1a7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -251,6 +251,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	if (vma->vm_name)
+		vma_name_put(vma->vm_name);
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
@@ -864,6 +866,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 		if (next->anon_vma)
 			anon_vma_merge(vma, next);
+		if (next->vm_name)
+			vma_name_put(next->vm_name);
 		mm->map_count--;
 		vma_set_policy(vma, vma_policy(next));
 		kmem_cache_free(vm_area_cachep, next);
@@ -893,7 +897,8 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+			struct file *file, unsigned long vm_flags,
+			struct vma_name *name)
 {
 	if (vma->vm_flags ^ vm_flags)
 		return 0;
@@ -901,6 +906,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
+	if (vma->vm_name != name)
+		return 0;
 	return 1;
 }
 
@@ -931,9 +938,10 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  */
 static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff,
+	struct vma_name *name)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, name) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
@@ -950,9 +958,10 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
-	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
+	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff,
+	struct vma_name *name)
 {
-	if (is_mergeable_vma(vma, file, vm_flags) &&
+	if (is_mergeable_vma(vma, file, vm_flags, name) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
@@ -963,7 +972,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
 }
 
 /*
- * Given a mapping request (addr,end,vm_flags,file,pgoff), figure out
+ * Given a mapping request (addr,end,vm_flags,file,pgoff, name), figure out
  * whether that can be merged with its predecessor or its successor.
  * Or both (it neatly fills a hole).
  *
@@ -995,7 +1004,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
-			pgoff_t pgoff, struct mempolicy *policy)
+			pgoff_t pgoff, struct mempolicy *policy,
+			struct vma_name *name)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1022,14 +1032,14 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (prev && prev->vm_end == addr &&
   			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags,
-						anon_vma, file, pgoff)) {
+						anon_vma, file, pgoff, name)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
 		if (next && end == next->vm_start &&
 				mpol_equal(policy, vma_policy(next)) &&
 				can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen) &&
+					anon_vma, file, pgoff+pglen, name) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1050,7 +1060,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (next && end == next->vm_start &&
  			mpol_equal(policy, vma_policy(next)) &&
 			can_vma_merge_before(next, vm_flags,
-					anon_vma, file, pgoff+pglen)) {
+					anon_vma, file, pgoff+pglen, name)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = vma_adjust(prev, prev->vm_start,
 				addr, prev->vm_pgoff, NULL);
@@ -1519,7 +1529,8 @@ munmap_back:
 	/*
 	 * Can we just expand an old mapping?
 	 */
-	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff, NULL);
+	vma = vma_merge(mm, prev, addr, addr + len, vm_flags, NULL, file, pgoff,
+			NULL, NULL);
 	if (vma)
 		goto out;
 
@@ -2443,6 +2454,9 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 	if (new->vm_file)
 		get_file(new->vm_file);
 
+	if (new->vm_name)
+		vma_name_get(new->vm_name);
+
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
 
@@ -2461,6 +2475,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 		new->vm_ops->close(new);
 	if (new->vm_file)
 		fput(new->vm_file);
+	if (new->vm_name)
+		vma_name_put(new->vm_name);
 	unlink_anon_vmas(new);
  out_free_mpol:
 	mpol_put(pol);
@@ -2663,7 +2679,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-					NULL, NULL, pgoff, NULL);
+					NULL, NULL, pgoff, NULL, NULL);
 	if (vma)
 		goto out;
 
@@ -2821,7 +2837,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			vma->vm_name);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
@@ -2860,6 +2877,8 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 				goto out_free_mempol;
 			if (new_vma->vm_file)
 				get_file(new_vma->vm_file);
+			if (new_vma->vm_name)
+				vma_name_get(new_vma->vm_name);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			vma_link(mm, new_vma, prev, rb_link, rb_parent);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..3fd33f2 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -271,7 +271,8 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	 */
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
-			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
+			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
+			vma->vm_name);
 	if (*pprev) {
 		vma = *pprev;
 		goto success;
diff --git a/mm/nommu.c b/mm/nommu.c
index 298884d..8c28572 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -809,6 +809,8 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	if (vma->vm_name)
+		vma_name_put(vma->vm_name);
 	put_nommu_region(vma->vm_region);
 	kmem_cache_free(vm_area_cachep, vma);
 }
@@ -1576,6 +1578,9 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new->vm_ops && new->vm_ops->open)
 		new->vm_ops->open(new);
 
+	if (new->vm_name)
+		vma_name_get(new->vm_name);
+
 	delete_vma_from_mm(vma);
 	down_write(&nommu_region_sem);
 	delete_nommu_region(vma->vm_region);
diff --git a/mm/vma_name.c b/mm/vma_name.c
new file mode 100644
index 0000000..0e65fe4
--- /dev/null
+++ b/mm/vma_name.c
@@ -0,0 +1,220 @@
+/*
+ * vma_name.c
+ *
+ * Copyright (C) 2013 Google, Inc.
+ *
+ * Author: Colin Cross <ccross@android.com>
+ *
+ * This file creates a cache of strings holding names for VMAs.  If
+ * vma_name_get_from_str is called with a string that is already used to
+ * name a VMA it is guaranteed to return the existing vma_name struct.  This
+ * allows string equality checking by comparing the struct vma_name address.
+ * The vma_name structures are stored in an rb tree, with the hash, length,
+ * and string used as the key.  The vma_name is refcount protected, and the
+ * rbtree is protected by a rwlock.  The write lock is required to decrement
+ * any vma_name refcount from 1 to 0.
+ */
+
+#include <linux/atomic.h>
+#include <linux/dcache.h>  /* for full_name_hash() and struct qstr */
+#include <linux/err.h>
+#include <linux/kernel.h>
+#include <linux/limits.h>
+#include <linux/mm.h>
+#include <linux/rbtree.h>
+#include <linux/rwlock.h>
+#include <linux/slab.h>
+
+static struct rb_root vma_name_cache = RB_ROOT;
+static DEFINE_RWLOCK(vma_name_cache_lock);
+
+/* refcounted cached name for one or more VMAs */
+struct vma_name {
+	struct rb_node rb_node;
+	atomic_t refcount;
+
+	unsigned int hash;
+	unsigned int name_len;
+	char name[0];
+};
+
+/**
+ * vma_name_get
+ *
+ * Increment the refcount of an existing vma_name.  No locks are needed because
+ * the caller should already be holding a reference, so refcount >= 1.
+ */
+void vma_name_get(struct vma_name *vma_name)
+{
+	if (WARN_ON(!vma_name))
+		return;
+
+	WARN_ON(!atomic_read(&vma_name->refcount));
+
+	atomic_inc(&vma_name->refcount);
+}
+
+/**
+ * vma_name_put
+ *
+ * Decrement the refcount of an existing vma_name and free it if necessary.
+ * No locks needed, takes the cache lock if it needs to remove the vma_name from
+ * the cache.
+ */
+void vma_name_put(struct vma_name *vma_name)
+{
+	int ret;
+
+	if (WARN_ON(!vma_name))
+		return;
+
+	WARN_ON(!atomic_read(&vma_name->refcount));
+
+	/* fast path: refcount > 1, decrement and return */
+	if (atomic_add_unless(&vma_name->refcount, -1, 1))
+		return;
+
+	/* slow path: take the lock, decrement, and erase node if count is 0 */
+	write_lock(&vma_name_cache_lock);
+
+	ret = atomic_dec_return(&vma_name->refcount);
+	if (ret == 0)
+		rb_erase(&vma_name->rb_node, &vma_name_cache);
+
+	write_unlock(&vma_name_cache_lock);
+
+	if (ret == 0)
+		kfree(vma_name);
+}
+
+/*
+ * Find an existing struct vma_name node in the rb tree with matching hash and
+ * name.  Returns the existing struct if found, without incrementing the
+ * refcount.  If not found, adds new_vma_name to the rb tree if not NULL, and
+ * returns new_vma_name.  Can be used to search the tree by passing new_vma_name
+ * NULL.  Must be called with the read lock held if new_vma_name is NULL,
+ * or the write lock if it is non-NULL.
+ */
+static struct vma_name *vma_name_tree_find_or_insert(struct qstr *name,
+						struct vma_name *new_vma_name)
+{
+	struct vma_name *vma_name;
+	struct rb_node **node = &vma_name_cache.rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*node) {
+		int cmp;
+
+		vma_name = container_of(*node, struct vma_name, rb_node);
+
+		cmp = name->hash - vma_name->hash;
+		if (cmp == 0)
+			cmp = name->len - vma_name->name_len;
+		if (cmp == 0)
+			cmp = strncmp(name->name, vma_name->name, name->len);
+
+		parent = *node;
+		if (cmp < 0)
+			node = &((*node)->rb_left);
+		else if (cmp > 0)
+			node = &((*node)->rb_right);
+		else
+			return vma_name;
+	}
+
+	if (new_vma_name) {
+		rb_link_node(&new_vma_name->rb_node, parent, node);
+		rb_insert_color(&new_vma_name->rb_node, &vma_name_cache);
+	}
+
+	return new_vma_name;
+}
+
+/*
+ * allocate a new vma_name structure and initialize it with the passed in name.
+ */
+static struct vma_name *vma_name_create(struct qstr *name)
+{
+	struct vma_name *vma_name;
+
+	vma_name = kmalloc(sizeof(struct vma_name) + name->len + 1, GFP_KERNEL);
+	if (!vma_name)
+		return NULL;
+
+	memcpy(vma_name->name, name->name, name->len);
+	vma_name->name[name->len] = 0;
+	vma_name->name_len = name->len;
+	vma_name->hash = name->hash;
+	atomic_set(&vma_name->refcount, 1);
+
+	return vma_name;
+}
+
+/**
+ * vma_name_get_from_str
+ *
+ * Find an existing struct vma_name * with name arg, or create a new one if
+ * none exists.  First tries to find an existing one, if that fails then
+ * drop the lock, allocate a new one, take the lock, and search again.  If
+ * there is still no existing one, add the new one to the list.  Returns
+ * NULL on error.
+ */
+struct vma_name *vma_name_get_from_str(const char *name, size_t name_len)
+{
+	struct vma_name *vma_name;
+	struct vma_name *new_vma_name = NULL;
+	struct qstr qstr = QSTR_INIT(name, strnlen(name, name_len));
+
+	if (!qstr.len)
+		return NULL;
+
+	qstr.hash = full_name_hash(name, qstr.len);
+
+	/* first look for an existing one */
+	read_lock(&vma_name_cache_lock);
+
+	vma_name = vma_name_tree_find_or_insert(&qstr, NULL);
+	if (vma_name)
+		vma_name_get(vma_name);
+
+	read_unlock(&vma_name_cache_lock);
+
+	if (vma_name)
+		return vma_name;
+
+	/* no existing one, allocate a new vma_name without the lock held */
+	new_vma_name = vma_name_create(&qstr);
+	if (!new_vma_name)
+		return NULL;
+
+	/* check again for existing ones that were added while we allocated */
+	write_lock(&vma_name_cache_lock);
+
+	vma_name = vma_name_tree_find_or_insert(&qstr, new_vma_name);
+	if (vma_name == new_vma_name) {
+		/* new node was inserted */
+		vma_name = new_vma_name;
+	} else {
+		/* raced with another insert of the same name */
+		vma_name_get(vma_name);
+		kfree(new_vma_name);
+	}
+
+	write_unlock(&vma_name_cache_lock);
+
+	return vma_name;
+}
+
+/**
+ * vma_name_str
+ *
+ * Returns a pointer to the NULL terminated string holding the name of the
+ * vma.  Must be called with a reference to the vma_name held.
+ */
+const char *vma_name_str(struct vma_name *vma_name)
+{
+	if (WARN_ON(!vma_name))
+		return NULL;
+
+	return vma_name->name;
+}
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
