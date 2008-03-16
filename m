Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2GHVWcY020045
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 13:31:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2GHVWgd143010
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2GHVVPx009067
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:32 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Mar 2008 23:00:05 +0530
Message-Id: <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
In-Reply-To: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
Subject: [RFC][2/3] Account and control virtual address space allocations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch implements accounting and control of virtual address space.
Accounting is done when the virtual address space of any task/mm_struct
belonging to the cgroup is incremented or decremented. This patch
fails the expansion if the cgroup goes over its limit. A new function
mem_cgroup_update_as() is added to deal with the accounting of the virtual
address space usage of cgroups.

TODOs

1. IA64 has code in perfmon.c pfm_smpl_buffer_alloc(), which increments
   the total_vm of the mm_struct. This code has not yet been brought into
   virtual address space control
2. Only when CONFIG_MMU is enabled, is the virtual address space control
   enabled. Should we do this for nommu cases as well? My suspicion is
   that we don't have to.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 arch/x86/kernel/ptrace.c   |   10 +++++++++-
 include/linux/memcontrol.h |    7 +++++++
 init/Kconfig               |    4 +++-
 kernel/fork.c              |    9 +++++++--
 mm/memcontrol.c            |   37 +++++++++++++++++++++++++++++++++++++
 mm/memory.c                |    5 +++++
 mm/mmap.c                  |   22 ++++++++++++++++++++--
 mm/mremap.c                |   21 ++++++++++++++++++---
 8 files changed, 106 insertions(+), 9 deletions(-)

diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-16 22:57:40.000000000 +0530
@@ -525,6 +525,32 @@ unsigned long mem_cgroup_isolate_pages(u
 }
 
 /*
+ * Check if the current cgroup exceeds its address space limit.
+ * Returns 0 on success and 1 on failure.
+ */
+int mem_cgroup_update_as(struct mm_struct *mm, long nr_pages)
+{
+	int ret = 0;
+	struct mem_cgroup *mem;
+	if (mem_cgroup_subsys.disabled)
+		return ret;
+
+	rcu_read_lock();
+	mem = rcu_dereference(mm->mem_cgroup);
+	css_get(&mem->css);
+	rcu_read_unlock();
+
+	if (nr_pages > 0) {
+		if (res_counter_charge(&mem->as_res, (nr_pages * PAGE_SIZE)))
+			ret = 1;
+	} else
+		res_counter_uncharge(&mem->as_res, (-nr_pages * PAGE_SIZE));
+
+	css_put(&mem->css);
+	return ret;
+}
+
+/*
  * Charge the memory controller for page usage.
  * Return
  * 0 if the charge was successful
@@ -1103,6 +1129,17 @@ static void mem_cgroup_move_task(struct 
 		goto out;
 
 	css_get(&mem->css);
+	/*
+	 * For address space accounting, the charges are migrated.
+	 * We need to migrate it since all the future uncharge/charge will
+	 * now happen to the new cgroup. For consistency, we need to migrate
+	 * all charges, otherwise we could end up dropping charges from
+	 * the new cgroup (even though they were incurred in the current
+	 * group).
+	 */
+	if (res_counter_charge(&mem->as_res, mm->total_vm))
+		goto out;
+	res_counter_uncharge(&old_mem->as_res, mm->total_vm);
 	rcu_assign_pointer(mm->mem_cgroup, mem);
 	css_put(&old_mem->css);
 
diff -puN include/linux/memcontrol.h~memory-controller-virtual-address-space-accounting-and-control include/linux/memcontrol.h
--- linux-2.6.25-rc5/include/linux/memcontrol.h~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/include/linux/memcontrol.h	2008-03-16 22:57:40.000000000 +0530
@@ -54,6 +54,7 @@ int task_in_mem_cgroup(struct task_struc
 extern int mem_cgroup_prepare_migration(struct page *page);
 extern void mem_cgroup_end_migration(struct page *page);
 extern void mem_cgroup_page_migration(struct page *page, struct page *newpage);
+extern int mem_cgroup_update_as(struct mm_struct *mm, long nr_pages);
 
 /*
  * For memory reclaim.
@@ -172,6 +173,12 @@ static inline long mem_cgroup_calc_recla
 {
 	return 0;
 }
+
+static inline int mem_cgroup_update_as(struct mm_struct *mm, long nr_pages)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff -puN mm/mmap.c~memory-controller-virtual-address-space-accounting-and-control mm/mmap.c
--- linux-2.6.25-rc5/mm/mmap.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/mmap.c	2008-03-16 22:57:40.000000000 +0530
@@ -1117,6 +1117,9 @@ munmap_back:
 		}
 	}
 
+	if (mem_cgroup_update_as(mm, len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	/*
 	 * Can we just expand an old private anonymous mapping?
 	 * The VM_SHARED test is necessary because shmem_zero_setup
@@ -1226,8 +1229,11 @@ unmap_and_free_vma:
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
-	if (charged)
+	if (charged) {
+		mem_cgroup_update_as(mm, -charged);
 		vm_unacct_memory(charged);
+	}
+unacct_as_error:
 	return error;
 }
 
@@ -1555,6 +1561,9 @@ static int acct_stack_growth(struct vm_a
 	if (security_vm_enough_memory(grow))
 		return -ENOMEM;
 
+	if (mem_cgroup_update_as(mm, grow))
+		return -ENOMEM;
+
 	/* Ok, everything looks good - let it rip */
 	mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
@@ -2003,9 +2012,14 @@ unsigned long do_brk(unsigned long addr,
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;
 
-	if (security_vm_enough_memory(len >> PAGE_SHIFT))
+	if (mem_cgroup_update_as(mm, (len >> PAGE_SHIFT)))
 		return -ENOMEM;
 
+	if (security_vm_enough_memory(len >> PAGE_SHIFT)) {
+		mem_cgroup_update_as(mm, -(len >> PAGE_SHIFT));
+		return -ENOMEM;
+	}
+
 	/* Can we just expand an old private anonymous mapping? */
 	if (vma_merge(mm, prev, addr, addr + len, flags,
 					NULL, NULL, pgoff, NULL))
@@ -2236,6 +2250,9 @@ int install_special_mapping(struct mm_st
 	if (unlikely(vma == NULL))
 		return -ENOMEM;
 
+	if (mem_cgroup_update_as(mm, len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -2248,6 +2265,7 @@ int install_special_mapping(struct mm_st
 
 	if (unlikely(insert_vm_struct(mm, vma))) {
 		kmem_cache_free(vm_area_cachep, vma);
+		mem_cgroup_update_as(mm, -(len >> PAGE_SHIFT));
 		return -ENOMEM;
 	}
 
diff -puN arch/x86/kernel/ptrace.c~memory-controller-virtual-address-space-accounting-and-control arch/x86/kernel/ptrace.c
--- linux-2.6.25-rc5/arch/x86/kernel/ptrace.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/arch/x86/kernel/ptrace.c	2008-03-16 22:57:40.000000000 +0530
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
 
+	mem_cgroup_update_as(current->mm, -old_size);
+
 	if (size == 0)
 		goto out;
 
@@ -816,10 +819,15 @@ static int ptrace_bts_realloc(struct tas
 			goto out;
 	}
 
+	if (mem_cgroup_update_as(current->mm, size))
+		goto out;
+
 	ret = ds_allocate((void **)&child->thread.ds_area_msr,
 			  size << PAGE_SHIFT);
-	if (ret < 0)
+	if (ret < 0) {
+		mem_cgroup_update_as(current->mm, -size);
 		goto out;
+	}
 
 	current->mm->total_vm  += size;
 	current->mm->locked_vm += size;
diff -puN kernel/fork.c~memory-controller-virtual-address-space-accounting-and-control kernel/fork.c
--- linux-2.6.25-rc5/kernel/fork.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/kernel/fork.c	2008-03-16 22:57:40.000000000 +0530
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/memcontrol.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -237,6 +238,7 @@ static int dup_mmap(struct mm_struct *mm
 
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
+		unsigned int len = vma_pages(mpnt);
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
 			long pages = vma_pages(mpnt);
@@ -247,11 +249,12 @@ static int dup_mmap(struct mm_struct *mm
 		}
 		charge = 0;
 		if (mpnt->vm_flags & VM_ACCOUNT) {
-			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			if (security_vm_enough_memory(len))
 				goto fail_nomem;
 			charge = len;
 		}
+		if (mem_cgroup_update_as(mm, len))
+			goto fail_nomem_as;
 		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (!tmp)
 			goto fail_nomem;
@@ -311,8 +314,10 @@ out:
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
-	retval = -ENOMEM;
+	mem_cgroup_update_as(mm, -charge);
 	vm_unacct_memory(charge);
+fail_nomem_as:
+	retval = -ENOMEM;
 	goto out;
 }
 
diff -puN mm/mremap.c~memory-controller-virtual-address-space-accounting-and-control mm/mremap.c
--- linux-2.6.25-rc5/mm/mremap.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/mremap.c	2008-03-16 22:57:40.000000000 +0530
@@ -174,10 +174,15 @@ static unsigned long move_vma(struct vm_
 	if (mm->map_count >= sysctl_max_map_count - 3)
 		return -ENOMEM;
 
+	if (mem_cgroup_update_as(mm, new_len >> PAGE_SHIFT))
+		return -ENOMEM;
+
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff);
-	if (!new_vma)
+	if (!new_vma) {
+		mem_cgroup_update_as(mm, -(new_len >> PAGE_SHIFT));
 		return -ENOMEM;
+	}
 
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
 	if (moved_len < old_len) {
@@ -187,6 +192,7 @@ static unsigned long move_vma(struct vm_
 		 * and then proceed to unmap new area instead of old.
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len);
+		mem_cgroup_update_as(mm, -(new_len >> PAGE_SHIFT));
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
@@ -347,10 +353,17 @@ unsigned long do_mremap(unsigned long ad
 		goto out;
 	}
 
+	if (mem_cgroup_update_as(mm, (new_len - old_len) >> PAGE_SHIFT)) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
 	if (vma->vm_flags & VM_ACCOUNT) {
 		charged = (new_len - old_len) >> PAGE_SHIFT;
-		if (security_vm_enough_memory(charged))
+		if (security_vm_enough_memory(charged)) {
+			mem_cgroup_update_as(mm, -charged);
 			goto out_nc;
+		}
 	}
 
 	/* old_len exactly to the end of the area..
@@ -406,8 +419,10 @@ unsigned long do_mremap(unsigned long ad
 		ret = move_vma(vma, addr, old_len, new_len, new_addr);
 	}
 out:
-	if (ret & ~PAGE_MASK)
+	if (ret & ~PAGE_MASK) {
 		vm_unacct_memory(charged);
+		mem_cgroup_update_as(mm, -charged);
+	}
 out_nc:
 	return ret;
 }
diff -puN init/Kconfig~memory-controller-virtual-address-space-accounting-and-control init/Kconfig
--- linux-2.6.25-rc5/init/Kconfig~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/init/Kconfig	2008-03-16 22:57:40.000000000 +0530
@@ -369,7 +369,9 @@ config CGROUP_MEM_RES_CTLR
 	depends on CGROUPS && RESOURCE_COUNTERS
 	help
 	  Provides a memory resource controller that manages both page cache and
-	  RSS memory.
+	  RSS memory. It also provide accounting and control of address
+	  space allocations (along the lines of RLIMIT_AS) for cgroups
+	  when CONFIG_MMU is enabled.
 
 	  Note that setting this option increases fixed memory overhead
 	  associated with each page of memory in the system by 4/8 bytes
diff -puN mm/swapfile.c~memory-controller-virtual-address-space-accounting-and-control mm/swapfile.c
diff -puN mm/memory.c~memory-controller-virtual-address-space-accounting-and-control mm/memory.c
--- linux-2.6.25-rc5/mm/memory.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memory.c	2008-03-16 22:57:40.000000000 +0530
@@ -838,6 +838,11 @@ unsigned long unmap_vmas(struct mmu_gath
 
 		if (vma->vm_flags & VM_ACCOUNT)
 			*nr_accounted += (end - start) >> PAGE_SHIFT;
+		/*
+		 * Unaccount used virtual memory for cgroups
+		 */
+		mem_cgroup_update_as(vma->vm_mm,
+					((long)(start - end)) >> PAGE_SHIFT);
 
 		while (start != end) {
 			if (!tlb_start_valid) {
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
