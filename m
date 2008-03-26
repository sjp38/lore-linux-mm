Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QIq98O023821
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 14:52:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QIrdXS193044
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QIrcuv003420
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:38 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 00:20:17 +0530
Message-Id: <20080326185017.9465.29950.sendpatchset@localhost.localdomain>
In-Reply-To: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
Subject: [RFC][2/3] Account and control virtual address space allocations (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Changelog v2
------------
Change the accounting to what is already present in the kernel. Split
the address space accounting into mem_cgroup_charge_as and
mem_cgroup_uncharge_as. At the time of VM expansion, call
mem_cgroup_cannot_expand_as to check if the new allocation will push
us over the limit

This patch implements accounting and control of virtual address space.
Accounting is done when the virtual address space of any task/mm_struct
belonging to the cgroup is incremented or decremented. This patch
fails the expansion if the cgroup goes over its limit.

TODOs

1. Only when CONFIG_MMU is enabled, is the virtual address space control
   enabled. Should we do this for nommu cases as well? My suspicion is
   that we don't have to.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 arch/ia64/kernel/perfmon.c  |    2 +
 arch/x86/kernel/ptrace.c    |    7 +++
 fs/exec.c                   |    2 +
 include/linux/memcontrol.h  |   26 +++++++++++++
 include/linux/res_counter.h |   19 ++++++++--
 init/Kconfig                |    2 -
 kernel/fork.c               |   17 +++++++--
 mm/memcontrol.c             |   83 ++++++++++++++++++++++++++++++++++++++++++++
 mm/mmap.c                   |   11 +++++
 mm/mremap.c                 |    2 +
 10 files changed, 163 insertions(+), 8 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-27 00:18:16.000000000 +0530
@@ -526,6 +526,76 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+/*
+ * Charge the address space usage for cgroup. This routine is most
+ * likely to be called from places that expand the total_vm of a mm_struct.
+ */
+void mem_cgroup_charge_as(struct mm_struct *mm, long nr_pages)
+{
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_subsys.disabled)
+		return;
+
+	rcu_read_lock();
+	mem = rcu_dereference(mm->mem_cgroup);
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	res_counter_charge(&mem->as_res, (nr_pages * PAGE_SIZE));
+	css_put(&mem->css);
+}
+
+/*
+ * Uncharge the address space usage for cgroup. This routine is most
+ * likely to be called from places that shrink the total_vm of a mm_struct.
+ */
+void mem_cgroup_uncharge_as(struct mm_struct *mm, long nr_pages)
+{
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_subsys.disabled)
+		return;
+
+	rcu_read_lock();
+	mem = rcu_dereference(mm->mem_cgroup);
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	res_counter_uncharge(&mem->as_res, (nr_pages * PAGE_SIZE));
+	css_put(&mem->css);
+}
+
+/*
+ * Check if the address space of the cgroup can be expanded.
+ * Returns 0 on success, anything else indicates failure
+ */
+int mem_cgroup_cannot_expand_as(struct mm_struct *mm, long nr_pages)
+{
+	int ret = 0;
+	struct mem_cgroup *mem;
+
+	if (mem_cgroup_subsys.disabled)
+		return ret;
+
+	rcu_read_lock();
+	mem = rcu_dereference(mm->mem_cgroup);
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	if (!res_counter_check_charge(&mem->as_res, (nr_pages * PAGE_SIZE)))
+		ret = -ENOMEM;
+	css_put(&mem->css);
+	if (ret) {
+		printk("cannot expand as %d\n", ret);
+		dump_stack();
+	}
+	return ret;
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR_AS */
+
 /*
  * Charge the memory controller for page usage.
  * Return
@@ -1111,6 +1181,19 @@ static void mem_cgroup_move_task(struct 
 		goto out;
 
 	css_get(&mem->css);
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+	/*
+	 * For address space accounting, the charges are migrated.
+	 * We need to migrate it since all the future uncharge/charge will
+	 * now happen to the new cgroup. For consistency, we need to migrate
+	 * all charges, otherwise we could end up dropping charges from
+	 * the new cgroup (even though they were incurred in the current
+	 * group).
+	 */
+	if (res_counter_charge(&mem->as_res, (mm->total_vm * PAGE_SIZE)))
+		goto out;
+	res_counter_uncharge(&old_mem->as_res, (mm->total_vm * PAGE_SIZE));
+#endif
 	rcu_assign_pointer(mm->mem_cgroup, mem);
 	css_put(&old_mem->css);
 
diff -puN include/linux/memcontrol.h~memory-controller-virtual-address-space-accounting-and-control include/linux/memcontrol.h
--- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h	2008-03-26 18:57:21.000000000 +0530
@@ -54,7 +54,6 @@ int task_in_mem_cgroup(struct task_struc
 extern int mem_cgroup_prepare_migration(struct page *page);
 extern void mem_cgroup_end_migration(struct page *page);
 extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
-
 /*
  * For memory reclaim.
  */
@@ -172,7 +171,32 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+
+extern void mem_cgroup_charge_as(struct mm_struct *mm, long nr_pages);
+extern void mem_cgroup_uncharge_as(struct mm_struct *mm, long nr_pages);
+extern int mem_cgroup_cannot_expand_as(struct mm_struct *mm, long nr_pages);
+
+#else /* CONFIG_CGROUP_MEM_RES_CTLR */
+
+static inline void mem_cgroup_charge_as(struct mm_struct *mm, long nr_pages)
+{
+}
+
+static inline void mem_cgroup_uncharge_as(struct mm_struct *mm, long nr_pages)
+{
+}
+
+static inline int
+mem_cgroup_cannot_expand_as(struct mm_struct *mm, long nr_pages)
+{
+	return 0;
+}
+
+#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
+
 #endif /* _LINUX_MEMCONTROL_H */
 
diff -puN mm/mmap.c~memory-controller-virtual-address-space-accounting-and-control mm/mmap.c
--- linux-2.6.25-rc5/mm/mmap.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/mmap.c	2008-03-26 22:37:25.000000000 +0530
@@ -1205,6 +1205,7 @@ munmap_back:
 		atomic_inc(&inode->i_writecount);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
+	mem_cgroup_charge_as(mm, len >> PAGE_SHIFT);
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
@@ -1557,6 +1558,7 @@ static int acct_stack_growth(struct vm_a
 
 	/* Ok, everything looks good - let it rip */
 	mm->total_vm += grow;
+	mem_cgroup_charge_as(mm, grow);
 	if (vma->vm_flags & VM_LOCKED)
 		mm->locked_vm += grow;
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, grow);
@@ -1730,6 +1732,7 @@ static void remove_vma_list(struct mm_st
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
+		mem_cgroup_uncharge_as(mm, nrpages);
 		if (vma->vm_flags & VM_LOCKED)
 			mm->locked_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
@@ -2029,6 +2032,7 @@ unsigned long do_brk(unsigned long addr,
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	mm->total_vm += len >> PAGE_SHIFT;
+	mem_cgroup_charge_as(mm, len >> PAGE_SHIFT);
 	if (flags & VM_LOCKED) {
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
@@ -2056,6 +2060,7 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	mem_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
@@ -2098,7 +2103,8 @@ int insert_vm_struct(struct mm_struct * 
 	if (__vma && __vma->vm_start < vma->vm_end)
 		return -ENOMEM;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
-	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
+	     (security_vm_enough_memory_mm(mm, vma_pages(vma)) ||
+		mem_cgroup_cannot_expand_as(mm, vma_pages(vma))))
 		return -ENOMEM;
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
@@ -2174,6 +2180,8 @@ int may_expand_vm(struct mm_struct *mm, 
 
 	if (cur + npages > lim)
 		return 0;
+	if (mem_cgroup_cannot_expand_as(mm, npages))
+		return 0;
 	return 1;
 }
 
@@ -2252,6 +2260,7 @@ int install_special_mapping(struct mm_st
 	}
 
 	mm->total_vm += len >> PAGE_SHIFT;
+	mem_cgroup_charge_as(mm, len >> PAGE_SHIFT);
 
 	return 0;
 }
diff -puN arch/x86/kernel/ptrace.c~memory-controller-virtual-address-space-accounting-and-control arch/x86/kernel/ptrace.c
--- linux-2.6.25-rc5/arch/x86/kernel/ptrace.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/arch/x86/kernel/ptrace.c	2008-03-26 19:05:51.000000000 +0530
@@ -20,6 +20,7 @@
 #include <linux/audit.h>
 #include <linux/seccomp.h>
 #include <linux/signal.h>
+#include <linux/memcontrol.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -787,6 +788,8 @@ static int ptrace_bts_realloc(struct tas
 	current->mm->total_vm  -= old_size;
 	current->mm->locked_vm -= old_size;
 
+	mem_cgroup_uncharge_as(current->mm, old_size);
+
 	if (size == 0)
 		goto out;
 
@@ -803,6 +806,9 @@ static int ptrace_bts_realloc(struct tas
 			goto out;
 	}
 
+	if (mem_cgroup_cannot_expand_as(current->mm, size))
+		goto out;
+
 	rlim = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
 	vm = current->mm->locked_vm  + size;
 	if (rlim < vm) {
@@ -823,6 +829,7 @@ static int ptrace_bts_realloc(struct tas
 
 	current->mm->total_vm  += size;
 	current->mm->locked_vm += size;
+	mem_cgroup_charge_as(current->mm, size);
 
 out:
 	if (child->thread.ds_area_msr)
diff -puN kernel/fork.c~memory-controller-virtual-address-space-accounting-and-control kernel/fork.c
--- linux-2.6.25-rc5/kernel/fork.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/fork.c	2008-03-26 22:36:17.000000000 +0530
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/memcontrol.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -237,17 +238,18 @@ static int dup_mmap(struct mm_struct *mm
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
+		unsigned int len = vma_pages(mpnt);
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
 			long pages = vma_pages(mpnt);
 			mm->total_vm -= pages;
+			mem_cgroup_uncharge_as(mm, pages);
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
 								-pages);
 			continue;
 		}
 		charge = 0;
 		if (mpnt->vm_flags & VM_ACCOUNT) {
-			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			if (security_vm_enough_memory(len))
 				goto fail_nomem;
 			charge = len;
@@ -311,8 +313,8 @@ out:
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
-	retval = -ENOMEM;
 	vm_unacct_memory(charge);
+	retval = -ENOMEM;
 	goto out;
 }
 
@@ -1047,6 +1049,17 @@ static struct task_struct *copy_process(
 	DEBUG_LOCKS_WARN_ON(!p->hardirqs_enabled);
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
+
+	/*
+	 * It's OK to duplicate the charges of current->mm on fork
+	 */
+	if (current->mm && !(clone_flags & CLONE_VM)) {
+		if (mem_cgroup_cannot_expand_as(current->mm,
+						current->mm->total_vm))
+			goto bad_fork_free;
+		mem_cgroup_charge_as(current->mm, current->mm->total_vm);
+	}
+
 	retval = -EAGAIN;
 	if (atomic_read(&p->user->processes) >=
 			p->signal->rlim[RLIMIT_NPROC].rlim_cur) {
diff -puN mm/mremap.c~memory-controller-virtual-address-space-accounting-and-control mm/mremap.c
--- linux-2.6.25-rc5/mm/mremap.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/mremap.c	2008-03-26 19:08:18.000000000 +0530
@@ -213,6 +213,7 @@ static unsigned long move_vma(struct vm_
 	 */
 	hiwater_vm = mm->hiwater_vm;
 	mm->total_vm += new_len >> PAGE_SHIFT;
+	mem_cgroup_charge_as(mm, new_len >> PAGE_SHIFT);
 	vm_stat_account(mm, vma->vm_flags, vma->vm_file, new_len>>PAGE_SHIFT);
 
 	if (do_munmap(mm, old_addr, old_len) < 0) {
@@ -370,6 +371,7 @@ unsigned long do_mremap(unsigned long ad
 				addr + new_len, vma->vm_pgoff, NULL);
 
 			mm->total_vm += pages;
+			mem_cgroup_charge_as(mm, pages);
 			vm_stat_account(mm, vma->vm_flags, vma->vm_file, pages);
 			if (vma->vm_flags & VM_LOCKED) {
 				mm->locked_vm += pages;
diff -puN init/Kconfig~memory-controller-virtual-address-space-accounting-and-control init/Kconfig
--- linux-2.6.25-rc5/init/Kconfig~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/init/Kconfig	2008-03-26 18:06:49.000000000 +0530
@@ -381,7 +381,7 @@ config CGROUP_MEM_RES_CTLR
 
 config CGROUP_MEM_RES_CTLR_AS
 	bool "Virtual Address Space Controller for Control Groups"
-	depends on CGROUP_MEM_RES_CTLR
+	depends on CGROUP_MEM_RES_CTLR && MMU
 	help
 	  Provides control over the maximum amount of virtual address space
 	  that can be consumed by the tasks in the cgroup. Setting a reasonable
diff -puN mm/swapfile.c~memory-controller-virtual-address-space-accounting-and-control mm/swapfile.c
diff -puN mm/memory.c~memory-controller-virtual-address-space-accounting-and-control mm/memory.c
diff -puN arch/ia64/kernel/perfmon.c~memory-controller-virtual-address-space-accounting-and-control arch/ia64/kernel/perfmon.c
--- linux-2.6.25-rc5/arch/ia64/kernel/perfmon.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:32:02.000000000 +0530
+++ linux-2.6.25-rc5-balbir/arch/ia64/kernel/perfmon.c	2008-03-26 16:41:42.000000000 +0530
@@ -40,6 +40,7 @@
 #include <linux/capability.h>
 #include <linux/rcupdate.h>
 #include <linux/completion.h>
+#include <linux/memcontrol.h>
 
 #include <asm/errno.h>
 #include <asm/intrinsics.h>
@@ -2375,6 +2376,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	insert_vm_struct(mm, vma);
 
 	mm->total_vm  += size >> PAGE_SHIFT;
+	mem_cgroup_charge_as(mm, (size >> PAGE_SHIFT));
 	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
 							vma_pages(vma));
 	up_write(&task->mm->mmap_sem);
diff -puN include/linux/res_counter.h~memory-controller-virtual-address-space-accounting-and-control include/linux/res_counter.h
--- linux-2.6.25-rc5/include/linux/res_counter.h~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 18:53:22.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/res_counter.h	2008-03-26 20:09:06.000000000 +0530
@@ -104,9 +104,10 @@ int res_counter_charge(struct res_counte
 void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
 void res_counter_uncharge(struct res_counter *counter, unsigned long val);
 
-static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
+static inline bool res_counter_limit_check_locked(struct res_counter *cnt,
+							unsigned long val)
 {
-	if (cnt->usage < cnt->limit)
+	if (cnt->usage + val < cnt->limit)
 		return true;
 
 	return false;
@@ -122,7 +123,19 @@ static inline bool res_counter_check_und
 	unsigned long flags;
 
 	spin_lock_irqsave(&cnt->lock, flags);
-	ret = res_counter_limit_check_locked(cnt);
+	ret = res_counter_limit_check_locked(cnt, 0);
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
+static inline bool res_counter_check_charge(struct res_counter *cnt,
+						unsigned long val)
+{
+	bool ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	ret = res_counter_limit_check_locked(cnt, val);
 	spin_unlock_irqrestore(&cnt->lock, flags);
 	return ret;
 }
diff -puN fs/exec.c~memory-controller-virtual-address-space-accounting-and-control fs/exec.c
--- linux-2.6.25-rc5/fs/exec.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 23:32:59.000000000 +0530
+++ linux-2.6.25-rc5-balbir/fs/exec.c	2008-03-26 23:34:02.000000000 +0530
@@ -51,6 +51,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
+#include <linux/memcontrol.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -250,6 +251,7 @@ static int __bprm_mm_init(struct linux_b
 	}
 
 	mm->stack_vm = mm->total_vm = 1;
+	mem_cgroup_charge_as(mm, 1);
 	up_write(&mm->mmap_sem);
 
 	bprm->p = vma->vm_end - sizeof(void *);
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
