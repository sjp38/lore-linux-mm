Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4EDAHVZ015765
	for <linux-mm@kvack.org>; Wed, 14 May 2008 09:10:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4EDAAC6029500
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:10:11 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4EDA954011406
	for <linux-mm@kvack.org>; Wed, 14 May 2008 07:10:09 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Wed, 14 May 2008 18:39:51 +0530
Message-Id: <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
Subject: [-mm][PATCH 4/4] Add memrlimit controller accounting and control (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch adds support for accounting and control of virtual address space
limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
The core of the accounting takes place during fork time in copy_process(),
may_expand_vm(), remove_vma_list() and exit_mmap(). There are some special
cases that are handled here as well (arch/ia64/kernel/perform.c,
arch/x86/kernel/ptrace.c, insert_special_mapping())

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 arch/ia64/kernel/perfmon.c      |    6 ++
 arch/x86/kernel/ptrace.c        |   17 +++++--
 fs/exec.c                       |    5 ++
 include/linux/memrlimitcgroup.h |   21 ++++++++
 kernel/fork.c                   |    8 +++
 mm/memrlimitcgroup.c            |   94 ++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                       |   11 ++++
 7 files changed, 157 insertions(+), 5 deletions(-)

diff -puN arch/ia64/kernel/perfmon.c~memrlimit-controller-address-space-accounting-and-control arch/ia64/kernel/perfmon.c
--- linux-2.6.26-rc2/arch/ia64/kernel/perfmon.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/arch/ia64/kernel/perfmon.c	2008-05-14 18:09:32.000000000 +0530
@@ -40,6 +40,7 @@
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
 #include <linux/completion.h>
+#include <linux/memrlimitcgroup.h>
 
 #include <asm/errno.h>
 #include <asm/intrinsics.h>
@@ -2294,6 +2295,9 @@ pfm_smpl_buffer_alloc(struct task_struct
 
 	DPRINT(("sampling buffer rsize=%lu size=%lu bytes\n", rsize, size));
 
+	if (memrlimit_cgroup_charge_as(mm, size >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	/*
 	 * check requested size to avoid Denial-of-service attacks
 	 * XXX: may have to refine this test
@@ -2313,6 +2317,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	smpl_buf = pfm_rvmalloc(size);
 	if (smpl_buf == NULL) {
 		DPRINT(("Can't allocate sampling buffer\n"));
+		memrlimit_cgroup_uncharge_as(mm, size >> PAGE_SHIFT);
 		return -ENOMEM;
 	}
 
@@ -2390,6 +2395,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	return 0;
 
 error:
+	memrlimit_cgroup_uncharge_as(mm, size >> PAGE_SHIFT);
 	kmem_cache_free(vm_area_cachep, vma);
 error_kmem:
 	pfm_rvfree(smpl_buf, size);
diff -puN arch/x86/kernel/ds.c~memrlimit-controller-address-space-accounting-and-control arch/x86/kernel/ds.c
diff -puN fs/exec.c~memrlimit-controller-address-space-accounting-and-control fs/exec.c
--- linux-2.6.26-rc2/fs/exec.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/fs/exec.c	2008-05-14 18:09:32.000000000 +0530
@@ -52,6 +52,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
+#include <linux/memrlimitcgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -230,6 +231,9 @@ static int __bprm_mm_init(struct linux_b
 	if (!vma)
 		goto err;
 
+	if (memrlimit_cgroup_charge_as(mm, 1))
+		goto err;
+
 	down_write(&mm->mmap_sem);
 	vma->vm_mm = mm;
 
@@ -247,6 +251,7 @@ static int __bprm_mm_init(struct linux_b
 	err = insert_vm_struct(mm, vma);
 	if (err) {
 		up_write(&mm->mmap_sem);
+		memrlimit_cgroup_uncharge_as(mm, 1);
 		goto err;
 	}
 
diff -puN include/linux/memrlimitcgroup.h~memrlimit-controller-address-space-accounting-and-control include/linux/memrlimitcgroup.h
--- linux-2.6.26-rc2/include/linux/memrlimitcgroup.h~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/include/linux/memrlimitcgroup.h	2008-05-14 18:09:32.000000000 +0530
@@ -16,4 +16,25 @@
 #ifndef LINUX_MEMRLIMITCGROUP_H
 #define LINUX_MEMRLIMITCGROUP_H
 
+#ifdef CONFIG_CGROUP_MEMRLIMIT_CTLR
+
+int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages);
+void memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages);
+
+#else /* !CONFIG_CGROUP_RLIMIT_CTLR */
+
+static inline int
+memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	return 0;
+}
+
+static inline void
+memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+}
+
+#endif /* CONFIG_CGROUP_RLIMIT_CTLR */
+
+
 #endif /* LINUX_MEMRLIMITCGROUP_H */
diff -puN kernel/fork.c~memrlimit-controller-address-space-accounting-and-control kernel/fork.c
--- linux-2.6.26-rc2/kernel/fork.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/kernel/fork.c	2008-05-14 18:09:32.000000000 +0530
@@ -54,6 +54,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/memrlimitcgroup.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -267,6 +268,7 @@ static int dup_mmap(struct mm_struct *mm
 			mm->total_vm -= pages;
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
 								-pages);
+			memrlimit_cgroup_uncharge_as(mm, pages);
 			continue;
 		}
 		charge = 0;
@@ -596,6 +598,12 @@ static int copy_mm(unsigned long clone_f
 		atomic_inc(&oldmm->mm_users);
 		mm = oldmm;
 		goto good_mm;
+	} else {
+		down_read(&oldmm->mmap_sem);
+		retval = memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm);
+		up_read(&oldmm->mmap_sem);
+		if (retval)
+			goto fail_nomem;
 	}
 
 	retval = -ENOMEM;
diff -puN mm/memrlimitcgroup.c~memrlimit-controller-address-space-accounting-and-control mm/memrlimitcgroup.c
--- linux-2.6.26-rc2/mm/memrlimitcgroup.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/mm/memrlimitcgroup.c	2008-05-14 18:09:32.000000000 +0530
@@ -45,6 +45,41 @@ static struct memrlimit_cgroup *memrlimi
 				struct memrlimit_cgroup, css);
 }
 
+static struct memrlimit_cgroup *
+memrlimit_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, memrlimit_cgroup_subsys_id),
+				struct memrlimit_cgroup, css);
+}
+
+int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	int ret;
+	struct memrlimit_cgroup *memrcg;
+
+	rcu_read_lock();
+	memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
+	css_get(&memrcg->css);
+	rcu_read_unlock();
+
+	ret = res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
+	css_put(&memrcg->css);
+	return ret;
+}
+
+void memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct memrlimit_cgroup *memrcg;
+
+	rcu_read_lock();
+	memrcg = memrlimit_cgroup_from_task(rcu_dereference(mm->owner));
+	css_get(&memrcg->css);
+	rcu_read_unlock();
+
+	res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
+	css_put(&memrcg->css);
+}
+
 static struct cgroup_subsys_state *
 memrlimit_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
@@ -134,11 +169,70 @@ static int memrlimit_cgroup_populate(str
 				ARRAY_SIZE(memrlimit_cgroup_files));
 }
 
+static void memrlimit_cgroup_move_task(struct cgroup_subsys *ss,
+					struct cgroup *cgrp,
+					struct cgroup *old_cgrp,
+					struct task_struct *p)
+{
+	struct mm_struct *mm;
+	struct memrlimit_cgroup *memrcg, *old_memrcg;
+
+	mm = get_task_mm(p);
+	if (mm == NULL)
+		return;
+
+	rcu_read_lock();
+	if (p != rcu_dereference(mm->owner))
+		goto out;
+
+	memrcg = memrlimit_cgroup_from_cgrp(cgrp);
+	old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
+
+	if (memrcg == old_memrcg)
+		goto out;
+
+	/*
+	 * Hold mmap_sem, so that total_vm does not change underneath us
+	 */
+	down_read(&mm->mmap_sem);
+	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
+	up_read(&mm->mmap_sem);
+	rcu_read_unlock();
+	mmput(mm);
+}
+
+static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
+						struct cgroup *cgrp,
+						struct cgroup *old_cgrp,
+						struct task_struct *p)
+{
+	struct memrlimit_cgroup *memrcg, *old_memrcg;
+	struct mm_struct *mm = get_task_mm(p);
+
+	BUG_ON(!mm);
+	memrcg = memrlimit_cgroup_from_cgrp(cgrp);
+	old_memrcg = memrlimit_cgroup_from_cgrp(old_cgrp);
+
+	down_read(&mm->mmap_sem);
+	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
+}
+
 struct cgroup_subsys memrlimit_cgroup_subsys = {
 	.name = "memrlimit",
 	.subsys_id = memrlimit_cgroup_subsys_id,
 	.create = memrlimit_cgroup_create,
 	.destroy = memrlimit_cgroup_destroy,
 	.populate = memrlimit_cgroup_populate,
+	.attach = memrlimit_cgroup_move_task,
+	.mm_owner_changed = memrlimit_cgroup_mm_owner_changed,
 	.early_init = 0,
 };
diff -puN mm/mmap.c~memrlimit-controller-address-space-accounting-and-control mm/mmap.c
--- linux-2.6.26-rc2/mm/mmap.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/mm/mmap.c	2008-05-14 18:09:32.000000000 +0530
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/memrlimitcgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1730,6 +1731,7 @@ static void remove_vma_list(struct mm_st
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
+		memrlimit_cgroup_uncharge_as(mm, nrpages);
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
@@ -2056,6 +2058,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
@@ -2174,6 +2177,10 @@ int may_expand_vm(struct mm_struct *mm, 
 
 	if (cur + npages > lim)
 		return 0;
+
+	if (memrlimit_cgroup_charge_as(mm, npages))
+		return 0;
+
 	return 1;
 }
 
@@ -2236,6 +2243,9 @@ int install_special_mapping(struct mm_st
 	if (unlikely(vma == NULL))
 		return -ENOMEM;
 
+	if (memrlimit_cgroup_charge_as(mm, len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -2248,6 +2258,7 @@ int install_special_mapping(struct mm_st
 
 	if (unlikely(insert_vm_struct(mm, vma))) {
 		kmem_cache_free(vm_area_cachep, vma);
+		memrlimit_cgroup_uncharge_as(mm, len >> PAGE_SHIFT);
 		return -ENOMEM;
 	}
 
diff -puN arch/x86/kernel/ptrace.c~memrlimit-controller-address-space-accounting-and-control arch/x86/kernel/ptrace.c
--- linux-2.6.26-rc2/arch/x86/kernel/ptrace.c~memrlimit-controller-address-space-accounting-and-control	2008-05-14 18:09:32.000000000 +0530
+++ linux-2.6.26-rc2-balbir/arch/x86/kernel/ptrace.c	2008-05-14 18:09:32.000000000 +0530
@@ -20,6 +20,7 @@
 #include <linux/audit.h>
 #include <linux/seccomp.h>
 #include <linux/signal.h>
+#include <linux/memrlimitcgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -782,21 +783,25 @@ static int ptrace_bts_realloc(struct tas
 
 	current->mm->total_vm  -= old_size;
 	current->mm->locked_vm -= old_size;
+	memrlimit_cgroup_uncharge_as(mm, old_size);
 
 	if (size == 0)
 		goto out;
 
+	if (memrlimit_cgroup_charge_as(current->mm, size))
+		goto out;
+
 	rlim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
 	vm = current->mm->total_vm  + size;
 	if (rlim < vm) {
 		ret = -ENOMEM;
 
 		if (!reduce_size)
-			goto out;
+			goto out_uncharge;
 
 		size = rlim - current->mm->total_vm;
 		if (size <= 0)
-			goto out;
+			goto out_uncharge;
 	}
 
 	rlim = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
@@ -805,21 +810,23 @@ static int ptrace_bts_realloc(struct tas
 		ret = -ENOMEM;
 
 		if (!reduce_size)
-			goto out;
+			goto out_uncharge;
 
 		size = rlim - current->mm->locked_vm;
 		if (size <= 0)
-			goto out;
+			goto out_uncharge;
 	}
 
 	ret = ds_allocate((void **)&child->thread.ds_area_msr,
 			  size << PAGE_SHIFT);
 	if (ret < 0)
-		goto out;
+		goto out_uncharge;
 
 	current->mm->total_vm  += size;
 	current->mm->locked_vm += size;
 
+out_uncharge:
+	memrlimit_cgroup_uncharge_as(mm, size);
 out:
 	if (child->thread.ds_area_msr)
 		set_tsk_thread_flag(child, TIF_DS_AREA_MSR);
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
