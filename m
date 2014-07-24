Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4B46B0039
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:50:58 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id e16so2104626lan.39
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:58 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id qd1si27656544lbb.11.2014.07.24.09.50.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 09:50:55 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id e16so2168748lan.11
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:50:54 -0700 (PDT)
Message-Id: <20140724165047.683455139@openvz.org>
Date: Thu, 24 Jul 2014 20:47:01 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 4/4] prctl: PR_SET_MM -- Introduce PR_SET_MM_MAP operation, v3
References: <20140724164657.452106845@openvz.org>
Content-Disposition: inline; filename=prctl-rework-new-mm-map-6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: gorcunov@openvz.org, keescook@chromium.org, tj@kernel.org, akpm@linux-foundation.org, avagin@openvz.org, ebiederm@xmission.com, hpa@zytor.com, serge.hallyn@canonical.com, xemul@parallels.com, segoon@openwall.com, kamezawa.hiroyu@jp.fujitsu.com, mtk.manpages@gmail.com, jln@google.com

During development of c/r we've noticed that in case if we need to
support user namespaces we face a problem with capabilities in
prctl(PR_SET_MM, ...) call, in particular once new user namespace
is created capable(CAP_SYS_RESOURCE) no longer passes.

A approach is to eliminate CAP_SYS_RESOURCE check but pass all
new values in one bundle, which would allow the kernel to make
more intensive test for sanity of values and same time allow us to
support checkpoint/restore of user namespaces.

Thus a new command PR_SET_MM_MAP introduced. It takes a pointer of
prctl_mm_map structure which carries all the members to be updated.

	prctl(PR_SET_MM, PR_SET_MM_MAP, struct prctl_mm_map *, size)

	struct prctl_mm_map {
		__u64	start_code;
		__u64	end_code;
		__u64	start_data;
		__u64	end_data;
		__u64	start_brk;
		__u64	brk;
		__u64	start_stack;
		__u64	arg_start;
		__u64	arg_end;
		__u64	env_start;
		__u64	env_end;
		__u64	*auxv;
		__u32	auxv_size;
		__u32	exe_fd;
	};

All members except @exe_fd correspond ones of struct mm_struct.
To figure out which available values these members may take here
are meanings of the members.

 - start_code, end_code: represent bounds of executable code area
 - start_data, end_data: represent bounds of data area
 - start_brk, brk: used to calculate bounds for brk() syscall
 - start_stack: used when accounting space needed for command
   line arguments, environment and shmat() syscall
 - arg_start, arg_end, env_start, env_end: represent memory area
   supplied for command line arguments and environment variables
 - auxv, auxv_size: carries auxiliary vector, Elf format specifics
 - exe_fd: file descriptor number for executable link (/proc/self/exe)

Thus we apply the following requirements to the values

1) Any member except @auxv, @auxv_size, @exe_fd is rather an address
   in user space thus it must be laying inside [mmap_min_addr, mmap_max_addr)
   interval.

2) While @[start|end]_code and @[start|end]_data may point to an nonexisting
   VMAs (say a program maps own new .text and .data segments during execution)
   the rest of members should belong to VMA which must exist.

3) Addresses must be ordered, ie @start_ member must not be greater or
   equal to appropriate @end_ member.

4) As in regular Elf loading procedure we require that @start_brk and
   @brk be greater than @end_data.

5) If RLIMIT_DATA rlimit is set to non-infinity new values should not
   exceed existing limit. Same applies to RLIMIT_STACK.

6) Auxiliary vector size must not exceed existing one (which is
   predefined as AT_VECTOR_SIZE and depends on architecture).

7) File descriptor passed in @exe_file should be pointing
   to executable file (because we use existing prctl_set_mm_exe_file_locked
   helper it ensures that the file we are going to use as exe link has all
   required permission granted).

Now about where these members are involved inside kernel code:

 - @start_code and @end_code are used in /proc/$pid/[stat|statm] output;

 - @start_data and @end_data are used in /proc/$pid/[stat|statm] output,
   also they are considered if there enough space for brk() syscall
   result if RLIMIT_DATA is set;

 - @start_brk shown in /proc/$pid/stat output and accounted in brk()
   syscall if RLIMIT_DATA is set; also this member is tested to
   find a symbolic name of mmap event for perf system (we choose
   if event is generated for "heap" area); one more aplication is
   selinux -- we test if a process has PROCESS__EXECHEAP permission
   if trying to make heap area being executable with mprotect() syscall;

 - @brk is a current value for brk() syscall which lays inside heap
   area, it's shown in /proc/$pid/stat. When syscall brk() succesfully
   provides new memory area to a user space upon brk() completion the
   mm::brk is updated to carry new value;

   Both @start_brk and @brk are actively used in /proc/$pid/maps
   and /proc/$pid/smaps output to find a symbolic name "heap" for
   VMA being scanned;

 - @start_stack is printed out in /proc/$pid/stat and used to
   find a symbolic name "stack" for task and threads in
   /proc/$pid/maps and /proc/$pid/smaps output, and as the same
   as with @start_brk -- perf system uses it for event naming.
   Also kernel treat this member as a start address of where
   to map vDSO pages and to check if there is enough space
   for shmat() syscall;

 - @arg_start, @arg_end, @env_start and @env_end are printed out
   in /proc/$pid/stat. Another access to the data these members
   represent is to read /proc/$pid/environ or /proc/$pid/cmdline.
   Any attempt to read these areas kernel tests with access_process_vm
   helper so a user must have enough rights for this action;

 - @auxv and @auxv_size may be read from /proc/$pid/auxv. Strictly
   speaking kernel doesn't care much about which exactly data is
   sitting there because it is solely for userspace;

 - @exe_fd is referred from /proc/$pid/exe and when generating
   coredump. We uses prctl_set_mm_exe_file_locked helper to update
   this member, so exe-file link modification remains one-shot
   action.

Still note that updating exe-file link now doesn't require sys-resource
capability anymore, after all there is no much profit in preventing setup
own file link (there are a number of ways to execute own code -- ptrace,
ld-preload, so that the only reliable way to find which exactly code
is executed is to inspect running program memory). Still we require
the caller to be at least user-namespace root user.

I believe the old interface should be deprecated and ripped off
in a couple of kernel releases if no one against.

To test if new interface is implemented in the kernel one
can pass PR_SET_MM_MAP_SIZE opcode and the kernel returns
the size of currently supported struct prctl_mm_map.

v2:
 - compact macros (by keescook@)
 - wrap new code with CONFIG_ (by akpm@)

v3 (by jln@):
 - use __prctl_check_order for brk and start_brk
 - use may_adjust_brk helper
 - make sure that only root can update @exe_fd link

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
 include/uapi/linux/prctl.h |   25 +++++
 kernel/sys.c               |  211 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 235 insertions(+), 1 deletion(-)

Index: linux-2.6.git/include/uapi/linux/prctl.h
===================================================================
--- linux-2.6.git.orig/include/uapi/linux/prctl.h
+++ linux-2.6.git/include/uapi/linux/prctl.h
@@ -119,6 +119,31 @@
 # define PR_SET_MM_ENV_END		11
 # define PR_SET_MM_AUXV			12
 # define PR_SET_MM_EXE_FILE		13
+# define PR_SET_MM_MAP			14
+# define PR_SET_MM_MAP_SIZE		15
+
+/*
+ * This structure provides new memory descriptor
+ * map which mostly modifies /proc/pid/stat[m]
+ * output for a task. This mostly done in a
+ * sake of checkpoint/restore functionality.
+ */
+struct prctl_mm_map {
+	__u64	start_code;		/* code section bounds */
+	__u64	end_code;
+	__u64	start_data;		/* data section bounds */
+	__u64	end_data;
+	__u64	start_brk;		/* heap for brk() syscall */
+	__u64	brk;
+	__u64	start_stack;		/* stack starts at */
+	__u64	arg_start;		/* command line arguments bounds */
+	__u64	arg_end;
+	__u64	env_start;		/* environment variables bounds */
+	__u64	env_end;
+	__u64	*auxv;			/* auxiliary vector */
+	__u32	auxv_size;		/* vector size */
+	__u32	exe_fd;			/* /proc/$pid/exe link file */
+};
 
 /*
  * Set specific pid that is allowed to ptrace the current task.
Index: linux-2.6.git/kernel/sys.c
===================================================================
--- linux-2.6.git.orig/kernel/sys.c
+++ linux-2.6.git/kernel/sys.c
@@ -1687,6 +1687,208 @@ exit:
 	return err;
 }
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+/*
+ * WARNING: we don't require any capability here so be very careful
+ * in what is allowed for modification from userspace.
+ */
+static int validate_prctl_map_locked(struct prctl_mm_map *prctl_map)
+{
+	unsigned long mmap_max_addr = TASK_SIZE;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *stack_vma;
+	int error = 0;
+
+	/*
+	 * Make sure the members are not somewhere outside
+	 * of allowed address space.
+	 */
+#define __prctl_check_addr_space(__member)					\
+	({									\
+		int __rc;							\
+		if ((unsigned long)prctl_map->__member < mmap_max_addr &&	\
+		    (unsigned long)prctl_map->__member >= mmap_min_addr)	\
+			__rc = 0;						\
+		else								\
+			__rc = -EINVAL;						\
+		__rc;								\
+	})
+	error |= __prctl_check_addr_space(start_code);
+	error |= __prctl_check_addr_space(end_code);
+	error |= __prctl_check_addr_space(start_data);
+	error |= __prctl_check_addr_space(end_data);
+	error |= __prctl_check_addr_space(start_stack);
+	error |= __prctl_check_addr_space(start_brk);
+	error |= __prctl_check_addr_space(brk);
+	error |= __prctl_check_addr_space(arg_start);
+	error |= __prctl_check_addr_space(arg_end);
+	error |= __prctl_check_addr_space(env_start);
+	error |= __prctl_check_addr_space(env_end);
+	if (error)
+		goto out;
+#undef __prctl_check_addr_space
+
+	/*
+	 * Stack, brk, command line arguments and environment must exist.
+	 */
+	stack_vma = find_vma(mm, (unsigned long)prctl_map->start_stack);
+	if (!stack_vma) {
+		error = -EINVAL;
+		goto out;
+	}
+#define __prctl_check_vma(__member)						\
+	find_vma(mm, (unsigned long)prctl_map->__member) ? 0 : -EINVAL
+	error |= __prctl_check_vma(start_brk);
+	error |= __prctl_check_vma(brk);
+	error |= __prctl_check_vma(arg_start);
+	error |= __prctl_check_vma(arg_end);
+	error |= __prctl_check_vma(env_start);
+	error |= __prctl_check_vma(env_end);
+	if (error)
+		goto out;
+#undef __prctl_check_vma
+
+	/*
+	 * Make sure the pairs are ordered.
+	 */
+#define __prctl_check_order(__m1, __op, __m2)					\
+	((unsigned long)prctl_map->__m1 __op					\
+	 (unsigned long)prctl_map->__m2) ? 0 : -EINVAL
+	error |= __prctl_check_order(start_code, <, end_code);
+	error |= __prctl_check_order(start_data, <, end_data);
+	error |= __prctl_check_order(start_brk, <=, brk);
+	error |= __prctl_check_order(arg_start,  <, arg_end);
+	error |= __prctl_check_order(env_start,  <, env_end);
+	if (error)
+		goto out;
+#undef __prctl_check_order
+
+	error = -EINVAL;
+
+	/*
+	 * @brk should be after @end_data in traditional maps.
+	 */
+	if (prctl_map->start_brk <= prctl_map->end_data ||
+	    prctl_map->brk <= prctl_map->end_data)
+		goto out;
+
+	/*
+	 * Neither we should allow to override limits if they set.
+	 */
+	if (may_adjust_brk(rlimit(RLIMIT_DATA), prctl_map->brk,
+			   prctl_map->start_brk, prctl_map->end_data,
+			   prctl_map->start_data))
+			goto out;
+
+#ifdef CONFIG_STACK_GROWSUP
+	if (may_adjust_brk(rlimit(RLIMIT_STACK),
+			   stack_vma->vm_end,
+			   prctl_map->start_stack, 0, 0))
+#else
+	if (may_adjust_brk(rlimit(RLIMIT_STACK),
+			   prctl_map->start_stack,
+			   stack_vma->vm_start, 0, 0))
+#endif
+		goto out;
+
+	/*
+	 * Someone is trying to cheat the auxv vector.
+	 */
+	if (prctl_map->auxv_size) {
+		if (!prctl_map->auxv ||
+		    prctl_map->auxv_size > sizeof(mm->saved_auxv))
+			goto out;
+	}
+
+	/*
+	 * Finally, make sure the caller has the rights to
+	 * change /proc/pid/exe link: only local root should
+	 * be allowed to.
+	 */
+	if (prctl_map->exe_fd != (u32)-1) {
+		struct user_namespace *ns = current_user_ns();
+		const struct cred *cred = current_cred();
+
+		if (!uid_eq(cred->uid, make_kuid(ns, 0)) ||
+		    !gid_eq(cred->gid, make_kgid(ns, 0)))
+			goto out;
+	}
+
+	error = 0;
+out:
+	return error;
+}
+
+static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data_size)
+{
+	struct prctl_mm_map prctl_map = { .exe_fd = (u32)-1, };
+	unsigned long user_auxv[AT_VECTOR_SIZE];
+	struct mm_struct *mm = current->mm;
+	int error = -EINVAL;
+
+	BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
+
+	if (opt == PR_SET_MM_MAP_SIZE)
+		return put_user((unsigned int)sizeof(prctl_map),
+				(unsigned int __user *)addr);
+
+	if (data_size != sizeof(prctl_map))
+		return -EINVAL;
+
+	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
+		return -EFAULT;
+
+	down_read(&mm->mmap_sem);
+
+	if (validate_prctl_map_locked(&prctl_map))
+		goto out;
+
+	if (prctl_map.auxv_size) {
+		up_read(&mm->mmap_sem);
+		memset(user_auxv, 0, sizeof(user_auxv));
+		error = copy_from_user(user_auxv,
+				       (const void __user *)prctl_map.auxv,
+				       prctl_map.auxv_size);
+		down_read(&mm->mmap_sem);
+		if (error)
+			goto out;
+	}
+
+	if (prctl_map.exe_fd != (u32)-1) {
+		error = prctl_set_mm_exe_file_locked(mm, prctl_map.exe_fd);
+		if (error)
+			goto out;
+	}
+
+	if (prctl_map.auxv_size) {
+		/* Last entry always must be AT_NULL */
+		user_auxv[AT_VECTOR_SIZE - 2] = AT_NULL;
+		user_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
+
+		task_lock(current);
+		memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
+		task_unlock(current);
+	}
+
+	mm->start_code	= prctl_map.start_code;
+	mm->end_code	= prctl_map.end_code;
+	mm->start_data	= prctl_map.start_data;
+	mm->end_data	= prctl_map.end_data;
+	mm->start_brk	= prctl_map.start_brk;
+	mm->brk		= prctl_map.brk;
+	mm->start_stack	= prctl_map.start_stack;
+	mm->arg_start	= prctl_map.arg_start;
+	mm->arg_end	= prctl_map.arg_end;
+	mm->env_start	= prctl_map.env_start;
+	mm->env_end	= prctl_map.env_end;
+
+	error = 0;
+out:
+	up_read(&mm->mmap_sem);
+	return error;
+}
+#endif /* CONFIG_CHECKPOINT_RESTORE */
+
 static int prctl_set_mm(int opt, unsigned long addr,
 			unsigned long arg4, unsigned long arg5)
 {
@@ -1695,9 +1897,16 @@ static int prctl_set_mm(int opt, unsigne
 	struct vm_area_struct *vma;
 	int error;
 
-	if (arg5 || (arg4 && opt != PR_SET_MM_AUXV))
+	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
+			      opt != PR_SET_MM_MAP &&
+			      opt != PR_SET_MM_MAP_SIZE)))
 		return -EINVAL;
 
+#ifdef CONFIG_CHECKPOINT_RESTORE
+	if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
+		return prctl_set_mm_map(opt, (const void __user *)addr, arg4);
+#endif
+
 	if (!capable(CAP_SYS_RESOURCE))
 		return -EPERM;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
