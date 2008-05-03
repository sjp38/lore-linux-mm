Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m43LZlO9021178
	for <linux-mm@kvack.org>; Sat, 3 May 2008 17:35:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m43Lcank207110
	for <linux-mm@kvack.org>; Sat, 3 May 2008 15:38:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m43LcZC4024817
	for <linux-mm@kvack.org>; Sat, 3 May 2008 15:38:36 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 04 May 2008 03:08:14 +0530
Message-Id: <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
In-Reply-To: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 3/4] Add rlimit controller accounting and control
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch adds support for accounting and control of virtual address space
limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
The core of the accounting takes place during fork time in copy_process(),
may_expand_vm(), remove_vma_list() and exit_mmap(). There are some special
cases that are handled here as well (arch/ia64/kernel/perform.c,
arch/x86/kernel/ptrace.c, insert_special_mapping())

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 arch/ia64/kernel/perfmon.c   |    6 ++
 arch/x86/kernel/ds.c         |   10 ++++
 fs/exec.c                    |    4 +
 include/linux/rlimitcgroup.h |   20 +++++++++
 kernel/fork.c                |   12 +++++
 mm/mmap.c                    |   11 +++++
 mm/rlimitcgroup.c            |   87 +++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 149 insertions(+), 1 deletion(-)

diff -puN mm/rlimitcgroup.c~rlimit-controller-address-space-accounting mm/rlimitcgroup.c
--- linux-2.6.25/mm/rlimitcgroup.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/mm/rlimitcgroup.c	2008-05-04 02:53:20.000000000 +0530
@@ -44,6 +44,40 @@ struct rlimit_cgroup *rlimit_cgroup_from
 				struct rlimit_cgroup, css);
 }
 
+struct rlimit_cgroup *rlimit_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, rlimit_cgroup_subsys_id),
+				struct rlimit_cgroup, css);
+}
+
+int rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	int ret;
+	struct rlimit_cgroup *rcg;
+
+	rcu_read_lock();
+	rcg = rlimit_cgroup_from_task(rcu_dereference(mm->owner));
+	css_get(&rcg->css);
+	rcu_read_unlock();
+
+	ret = res_counter_charge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
+	css_put(&rcg->css);
+	return ret;
+}
+
+void rlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct rlimit_cgroup *rcg;
+
+	rcu_read_lock();
+	rcg = rlimit_cgroup_from_task(rcu_dereference(mm->owner));
+	css_get(&rcg->css);
+	rcu_read_unlock();
+
+	res_counter_uncharge(&rcg->as_res, (nr_pages << PAGE_SHIFT));
+	css_put(&rcg->css);
+}
+
 static struct cgroup_subsys_state *
 rlimit_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
@@ -65,6 +99,39 @@ static void rlimit_cgroup_destroy(struct
 	kfree(rlimit_cgroup_from_cgrp(cgrp));
 }
 
+/*
+ * TODO: get the attach callbacks to fail and disallow task movement.
+ */
+static void rlimit_cgroup_move_task(struct cgroup_subsys *ss,
+					struct cgroup *cgrp,
+					struct cgroup *old_cgrp,
+					struct task_struct *p)
+{
+	struct mm_struct *mm;
+	struct rlimit_cgroup *rcg, *old_rcg;
+
+	mm = get_task_mm(p);
+	if (mm == NULL)
+		return;
+
+	rcu_read_lock();
+	if (p != rcu_dereference(mm->owner))
+		goto out;
+
+	rcg = rlimit_cgroup_from_cgrp(cgrp);
+	old_rcg = rlimit_cgroup_from_cgrp(old_cgrp);
+
+	if (rcg == old_rcg)
+		goto out;
+
+	if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_rcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
+	rcu_read_unlock();
+	mmput(mm);
+}
+
 static int rlimit_cgroup_reset(struct cgroup *cgrp, unsigned int event)
 {
 	struct rlimit_cgroup *rcg;
@@ -131,11 +198,31 @@ static int rlimit_cgroup_populate(struct
 				ARRAY_SIZE(rlimit_cgroup_files));
 }
 
+static void rlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
+						struct cgroup *cgrp,
+						struct cgroup *old_cgrp,
+						struct task_struct *p)
+{
+	struct rlimit_cgroup *rcg, *old_rcg;
+	struct mm_struct *mm = get_task_mm(p);
+
+	BUG_ON(!mm);
+	rcg = rlimit_cgroup_from_cgrp(cgrp);
+	old_rcg = rlimit_cgroup_from_cgrp(old_cgrp);
+	if (res_counter_charge(&rcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_rcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
+	mmput(mm);
+}
+
 struct cgroup_subsys rlimit_cgroup_subsys = {
 	.name = "rlimit",
 	.subsys_id = rlimit_cgroup_subsys_id,
 	.create = rlimit_cgroup_create,
 	.destroy = rlimit_cgroup_destroy,
 	.populate = rlimit_cgroup_populate,
+	.attach = rlimit_cgroup_move_task,
+	.mm_owner_changed = rlimit_cgroup_mm_owner_changed,
 	.early_init = 0,
 };
diff -puN include/linux/rlimitcgroup.h~rlimit-controller-address-space-accounting include/linux/rlimitcgroup.h
--- linux-2.6.25/include/linux/rlimitcgroup.h~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/include/linux/rlimitcgroup.h	2008-05-04 02:54:07.000000000 +0530
@@ -16,4 +16,24 @@
 #ifndef LINUX_RLIMITCGROUP_H
 #define LINUX_RLIMITCGROUP_H
 
+#ifdef CONFIG_CGROUP_RLIMIT_CTLR
+
+int rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages);
+void rlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages);
+
+#else /* !CONFIG_CGROUP_RLIMIT_CTLR */
+
+static inline int
+rlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	return 0;
+}
+
+static inline void
+rlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+}
+
+#endif /* CONFIG_CGROUP_RLIMIT_CTLR */
+
 #endif /* LINUX_RLIMITCGROUP_H */
diff -puN mm/mmap.c~rlimit-controller-address-space-accounting mm/mmap.c
--- linux-2.6.25/mm/mmap.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/mm/mmap.c	2008-05-04 02:53:20.000000000 +0530
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/rlimitcgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1730,6 +1731,7 @@ static void remove_vma_list(struct mm_st
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
+		rlimit_cgroup_uncharge_as(mm, nrpages);
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
@@ -2056,6 +2058,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	rlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
@@ -2174,6 +2177,10 @@ int may_expand_vm(struct mm_struct *mm, 
 
 	if (cur + npages > lim)
 		return 0;
+
+	if (rlimit_cgroup_charge_as(mm, npages))
+		return 0;
+
 	return 1;
 }
 
@@ -2236,6 +2243,9 @@ int install_special_mapping(struct mm_st
 	if (unlikely(vma == NULL))
 		return -ENOMEM;
 
+	if (rlimit_cgroup_charge_as(mm, len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -2248,6 +2258,7 @@ int install_special_mapping(struct mm_st
 
 	if (unlikely(insert_vm_struct(mm, vma))) {
 		kmem_cache_free(vm_area_cachep, vma);
+		rlimit_cgroup_uncharge_as(mm, len >> PAGE_SHIFT);
 		return -ENOMEM;
 	}
 
diff -puN arch/ia64/kernel/perfmon.c~rlimit-controller-address-space-accounting arch/ia64/kernel/perfmon.c
--- linux-2.6.25/arch/ia64/kernel/perfmon.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/arch/ia64/kernel/perfmon.c	2008-05-04 02:53:20.000000000 +0530
@@ -40,6 +40,7 @@
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
 #include <linux/completion.h>
+#include <linux/rlimitcgroup.h>
 
 #include <asm/errno.h>
 #include <asm/intrinsics.h>
@@ -2300,6 +2301,9 @@ pfm_smpl_buffer_alloc(struct task_struct
 	 * if ((mm->total_vm << PAGE_SHIFT) + len> task->rlim[RLIMIT_AS].rlim_cur)
 	 * 	return -ENOMEM;
 	 */
+	if (rlimit_cgroup_charge_as(mm, size >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	if (size > task->signal->rlim[RLIMIT_MEMLOCK].rlim_cur)
 		return -ENOMEM;
 
@@ -2311,6 +2315,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	smpl_buf = pfm_rvmalloc(size);
 	if (smpl_buf == NULL) {
 		DPRINT(("Can't allocate sampling buffer\n"));
+		rlimit_cgroup_uncharge_as(mm, size >> PAGE_SHIFT);
 		return -ENOMEM;
 	}
 
@@ -2390,6 +2395,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 error:
 	kmem_cache_free(vm_area_cachep, vma);
 error_kmem:
+	rlimit_cgroup_uncharge_as(mm, size >> PAGE_SHIFT);
 	pfm_rvfree(smpl_buf, size);
 
 	return -ENOMEM;
diff -puN arch/x86/kernel/ptrace.c~rlimit-controller-address-space-accounting arch/x86/kernel/ptrace.c
diff -puN fs/exec.c~rlimit-controller-address-space-accounting fs/exec.c
--- linux-2.6.25/fs/exec.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/fs/exec.c	2008-05-04 02:53:20.000000000 +0530
@@ -51,6 +51,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
+#include <linux/rlimitcgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -229,6 +230,9 @@ static int __bprm_mm_init(struct linux_b
 	if (!vma)
 		goto err;
 
+	if (rlimit_cgroup_charge_as(mm, 1))
+		goto err;
+
 	down_write(&mm->mmap_sem);
 	vma->vm_mm = mm;
 
diff -puN kernel/fork.c~rlimit-controller-address-space-accounting kernel/fork.c
--- linux-2.6.25/kernel/fork.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/kernel/fork.c	2008-05-04 02:53:20.000000000 +0530
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/rlimitcgroup.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -243,6 +244,7 @@ static int dup_mmap(struct mm_struct *mm
 			mm->total_vm -= pages;
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
 								-pages);
+			rlimit_cgroup_uncharge_as(mm, pages);
 			continue;
 		}
 		charge = 0;
@@ -1053,6 +1055,15 @@ static struct task_struct *copy_process(
 	DEBUG_LOCKS_WARN_ON(!p->hardirqs_enabled);
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
+
+	/*
+	 * We need to duplicate the address space charges on fork
+	 */
+	if (current->mm && !(clone_flags & CLONE_VM)) {
+		if (rlimit_cgroup_charge_as(current->mm, current->mm->total_vm))
+			goto bad_fork_free;
+	}
+
 	retval = -EAGAIN;
 	if (atomic_read(&p->user->processes) >=
 			p->signal->rlim[RLIMIT_NPROC].rlim_cur) {
@@ -1406,6 +1417,7 @@ bad_fork_cleanup_count:
 	put_group_info(p->group_info);
 	atomic_dec(&p->user->processes);
 	free_uid(p->user);
+	rlimit_cgroup_uncharge_as(current->mm, current->mm->total_vm);
 bad_fork_free:
 	free_task(p);
 fork_out:
diff -puN mm/mremap.c~rlimit-controller-address-space-accounting mm/mremap.c
diff -puN arch/x86/kernel/ds.c~rlimit-controller-address-space-accounting arch/x86/kernel/ds.c
--- linux-2.6.25/arch/x86/kernel/ds.c~rlimit-controller-address-space-accounting	2008-05-04 02:53:20.000000000 +0530
+++ linux-2.6.25-balbir/arch/x86/kernel/ds.c	2008-05-04 02:53:20.000000000 +0530
@@ -29,6 +29,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/rlimitcgroup.h>
 
 
 /*
@@ -348,9 +349,14 @@ static inline void *ds_allocate_buffer(s
 	if (rlim < vm)
 		return 0;
 
+	if (rlimit_cgroup_charge_as(current->mm, pgsz))
+		return 0;
+
 	buffer = kzalloc(size, GFP_KERNEL);
-	if (!buffer)
+	if (!buffer) {
+		rlimit_cgroup_uncharge_as(current->mm, pgsz);
 		return 0;
+	}
 
 	current->mm->total_vm  += pgsz;
 	current->mm->locked_vm += pgsz;
@@ -480,6 +486,8 @@ static int ds_release(struct task_struct
 	kfree(context->buffer[qual]);
 	context->buffer[qual] = 0;
 
+	rlimit_cgroup_uncharge_as(current->mm, context->pages[qual]);
+
 	current->mm->total_vm  -= context->pages[qual];
 	current->mm->locked_vm -= context->pages[qual];
 	context->pages[qual] = 0;
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
