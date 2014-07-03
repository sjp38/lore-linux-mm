Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id CFF476B0037
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:49:18 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id ty20so122548lab.31
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:49:18 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id d7si9793166laa.57.2014.07.03.05.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:49:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 2/5] vm_cgroup: private writable mappings accounting
Date: Thu, 3 Jul 2014 16:48:18 +0400
Message-ID: <bc17a32e1b15f0609f857e7815d5ded1ec59290c.1404383187.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

Address space that contributes to memory overcommit consists of two
parts - private writable mappings and shared memory. This patch adds
private writable mappings accounting.

The implementation is quite simple. Each mm holds a reference to the vm
cgroup it is accounted to. The reference is initialized with the current
cgroup on mm creation and released only on mm destruction. For
simplicity, task migrations as well as mm owner changes are not handled
yet, so an offline cgroup will be pinned in memory until all mm's
accounted to it die.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/mm_types.h  |    3 ++
 include/linux/vm_cgroup.h |   29 ++++++++++++++++++++
 kernel/fork.c             |   12 +++++++-
 mm/mmap.c                 |   43 +++++++++++++++++++++++------
 mm/mprotect.c             |    8 +++++-
 mm/mremap.c               |   15 ++++++++--
 mm/vm_cgroup.c            |   67 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 164 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 96c5750e3110..ae6c23524b8a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -419,6 +419,9 @@ struct mm_struct {
 	 */
 	struct task_struct __rcu *owner;
 #endif
+#ifdef CONFIG_CGROUP_VM
+	struct vm_cgroup *vmcg;		/* vm_cgroup this mm is accounted to */
+#endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file *exe_file;
diff --git a/include/linux/vm_cgroup.h b/include/linux/vm_cgroup.h
index b629c9affa4b..34ed936a0a10 100644
--- a/include/linux/vm_cgroup.h
+++ b/include/linux/vm_cgroup.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_VM_CGROUP_H
 #define _LINUX_VM_CGROUP_H
 
+struct mm_struct;
+
 #ifdef CONFIG_CGROUP_VM
 static inline bool vm_cgroup_disabled(void)
 {
@@ -8,11 +10,38 @@ static inline bool vm_cgroup_disabled(void)
 		return true;
 	return false;
 }
+
+extern void mm_init_vm_cgroup(struct mm_struct *mm, struct task_struct *p);
+extern void mm_release_vm_cgroup(struct mm_struct *mm);
+extern int vm_cgroup_charge_memory_mm(struct mm_struct *mm,
+				      unsigned long nr_pages);
+extern void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm,
+					 unsigned long nr_pages);
 #else /* !CONFIG_CGROUP_VM */
 static inline bool vm_cgroup_disabled(void)
 {
 	return true;
 }
+
+static inline void mm_init_vm_cgroup(struct mm_struct *mm,
+				     struct task_struct *p)
+{
+}
+
+static inline void mm_release_vm_cgroup(struct mm_struct *mm)
+{
+}
+
+static inline int vm_cgroup_charge_memory_mm(struct mm_struct *mm,
+					     unsigned long nr_pages)
+{
+	return 0;
+}
+
+static inline void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm,
+						unsigned long nr_pages)
+{
+}
 #endif /* CONFIG_CGROUP_VM */
 
 #endif /* _LINUX_VM_CGROUP_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index d2799d1fc952..8f96553f9fde 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -74,6 +74,7 @@
 #include <linux/uprobes.h>
 #include <linux/aio.h>
 #include <linux/compiler.h>
+#include <linux/vm_cgroup.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -394,8 +395,13 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		if (mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned long len = vma_pages(mpnt);
 
-			if (security_vm_enough_memory_mm(oldmm, len)) /* sic */
+			if (vm_cgroup_charge_memory_mm(mm, len))
 				goto fail_nomem;
+
+			if (security_vm_enough_memory_mm(oldmm, len)) {
+				vm_cgroup_uncharge_memory_mm(mm, len);
+				goto fail_nomem;
+			}
 			charge = len;
 		}
 		tmp = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
@@ -479,6 +485,7 @@ fail_nomem_policy:
 fail_nomem:
 	retval = -ENOMEM;
 	vm_unacct_memory(charge);
+	vm_cgroup_uncharge_memory_mm(mm, charge);
 	goto out;
 }
 
@@ -551,6 +558,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mmu_notifier_mm_init(mm);
+		mm_init_vm_cgroup(mm, current);
 		return mm;
 	}
 
@@ -599,6 +607,7 @@ struct mm_struct *mm_alloc(void)
 void __mmdrop(struct mm_struct *mm)
 {
 	BUG_ON(mm == &init_mm);
+	mm_release_vm_cgroup(mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
@@ -857,6 +866,7 @@ fail_nocontext:
 	 * If init_new_context() failed, we cannot use mmput() to free the mm
 	 * because it calls destroy_context()
 	 */
+	mm_release_vm_cgroup(mm);
 	mm_free_pgd(mm);
 	free_mm(mm);
 	return NULL;
diff --git a/mm/mmap.c b/mm/mmap.c
index 129b847d30cc..9ba9e932e132 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -40,6 +40,7 @@
 #include <linux/notifier.h>
 #include <linux/memory.h>
 #include <linux/printk.h>
+#include <linux/vm_cgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1535,8 +1536,12 @@ munmap_back:
 	 */
 	if (accountable_mapping(file, vm_flags)) {
 		charged = len >> PAGE_SHIFT;
-		if (security_vm_enough_memory_mm(mm, charged))
+		if (vm_cgroup_charge_memory_mm(mm, charged))
 			return -ENOMEM;
+		if (security_vm_enough_memory_mm(mm, charged)) {
+			vm_cgroup_uncharge_memory_mm(mm, charged);
+			return -ENOMEM;
+		}
 		vm_flags |= VM_ACCOUNT;
 	}
 
@@ -1652,8 +1657,10 @@ unmap_and_free_vma:
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
 unacct_error:
-	if (charged)
+	if (charged) {
 		vm_unacct_memory(charged);
+		vm_cgroup_uncharge_memory_mm(mm, charged);
+	}
 	return error;
 }
 
@@ -2084,12 +2091,16 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 	if (is_hugepage_only_range(vma->vm_mm, new_start, size))
 		return -EFAULT;
 
+	if (vm_cgroup_charge_memory_mm(mm, grow))
+		return -ENOMEM;
 	/*
 	 * Overcommit..  This must be the final test, as it will
 	 * update security statistics.
 	 */
-	if (security_vm_enough_memory_mm(mm, grow))
+	if (security_vm_enough_memory_mm(mm, grow)) {
+		vm_cgroup_uncharge_memory_mm(mm, grow);
 		return -ENOMEM;
+	}
 
 	/* Ok, everything looks good - let it rip */
 	if (vma->vm_flags & VM_LOCKED)
@@ -2341,6 +2352,7 @@ static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
 		vma = remove_vma(vma);
 	} while (vma);
 	vm_unacct_memory(nr_accounted);
+	vm_cgroup_uncharge_memory_mm(mm, nr_accounted);
 	validate_mm(mm);
 }
 
@@ -2603,6 +2615,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	unsigned long flags;
 	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
+	unsigned long charged;
 	int error;
 
 	len = PAGE_ALIGN(len);
@@ -2642,8 +2655,13 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	if (mm->map_count > sysctl_max_map_count)
 		return -ENOMEM;
 
-	if (security_vm_enough_memory_mm(mm, len >> PAGE_SHIFT))
+	charged = len >> PAGE_SHIFT;
+	if (vm_cgroup_charge_memory_mm(mm, charged))
+		return -ENOMEM;
+	if (security_vm_enough_memory_mm(mm, charged)) {
+		vm_cgroup_uncharge_memory_mm(mm, charged);
 		return -ENOMEM;
+	}
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
@@ -2656,7 +2674,8 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	 */
 	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma) {
-		vm_unacct_memory(len >> PAGE_SHIFT);
+		vm_unacct_memory(charged);
+		vm_cgroup_uncharge_memory_mm(mm, charged);
 		return -ENOMEM;
 	}
 
@@ -2738,6 +2757,7 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
+	vm_cgroup_uncharge_memory_mm(mm, nr_accounted);
 
 	WARN_ON(atomic_long_read(&mm->nr_ptes) >
 			(FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
@@ -2771,9 +2791,16 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
 			   &prev, &rb_link, &rb_parent))
 		return -ENOMEM;
-	if ((vma->vm_flags & VM_ACCOUNT) &&
-	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
-		return -ENOMEM;
+	if ((vma->vm_flags & VM_ACCOUNT)) {
+		unsigned long charged = vma_pages(vma);
+
+		if (vm_cgroup_charge_memory_mm(mm, charged))
+			return -ENOMEM;
+		if (security_vm_enough_memory_mm(mm, charged)) {
+			vm_cgroup_uncharge_memory_mm(mm, charged);
+			return -ENOMEM;
+		}
+	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index c43d557941f8..f76d1cadb3c1 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/perf_event.h>
 #include <linux/ksm.h>
+#include <linux/vm_cgroup.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -283,8 +284,12 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 		if (!(oldflags & (VM_ACCOUNT|VM_WRITE|VM_HUGETLB|
 						VM_SHARED|VM_NORESERVE))) {
 			charged = nrpages;
-			if (security_vm_enough_memory_mm(mm, charged))
+			if (vm_cgroup_charge_memory_mm(mm, charged))
 				return -ENOMEM;
+			if (security_vm_enough_memory_mm(mm, charged)) {
+				vm_cgroup_uncharge_memory_mm(mm, charged);
+				return -ENOMEM;
+			}
 			newflags |= VM_ACCOUNT;
 		}
 	}
@@ -338,6 +343,7 @@ success:
 
 fail:
 	vm_unacct_memory(charged);
+	vm_cgroup_uncharge_memory_mm(mm, charged);
 	return error;
 }
 
diff --git a/mm/mremap.c b/mm/mremap.c
index 05f1180e9f21..1cf5709acce5 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
 #include <linux/sched/sysctl.h>
+#include <linux/vm_cgroup.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -313,6 +314,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (do_munmap(mm, old_addr, old_len) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);
+		vm_cgroup_uncharge_memory_mm(mm, excess >> PAGE_SHIFT);
 		excess = 0;
 	}
 	mm->hiwater_vm = hiwater_vm;
@@ -374,8 +376,13 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 
 	if (vma->vm_flags & VM_ACCOUNT) {
 		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
-		if (security_vm_enough_memory_mm(mm, charged))
+
+		if (vm_cgroup_charge_memory_mm(mm, charged))
+			goto Efault;
+		if (security_vm_enough_memory_mm(mm, charged)) {
+			vm_cgroup_uncharge_memory_mm(mm, charged);
 			goto Efault;
+		}
 		*p = charged;
 	}
 
@@ -447,7 +454,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 		goto out;
 out1:
 	vm_unacct_memory(charged);
-
+	vm_cgroup_uncharge_memory_mm(mm, charged);
 out:
 	return ret;
 }
@@ -578,8 +585,10 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
 	}
 out:
-	if (ret & ~PAGE_MASK)
+	if (ret & ~PAGE_MASK) {
 		vm_unacct_memory(charged);
+		vm_cgroup_uncharge_memory_mm(mm, charged);
+	}
 	up_write(&current->mm->mmap_sem);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
diff --git a/mm/vm_cgroup.c b/mm/vm_cgroup.c
index 7f5b81482748..4dd693b34e33 100644
--- a/mm/vm_cgroup.c
+++ b/mm/vm_cgroup.c
@@ -2,6 +2,7 @@
 #include <linux/res_counter.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
+#include <linux/rcupdate.h>
 #include <linux/vm_cgroup.h>
 
 struct vm_cgroup {
@@ -25,6 +26,72 @@ static struct vm_cgroup *vm_cgroup_from_css(struct cgroup_subsys_state *s)
 	return s ? container_of(s, struct vm_cgroup, css) : NULL;
 }
 
+static struct vm_cgroup *vm_cgroup_from_task(struct task_struct *p)
+{
+	return vm_cgroup_from_css(task_css(p, vm_cgrp_id));
+}
+
+static struct vm_cgroup *get_vm_cgroup_from_task(struct task_struct *p)
+{
+	struct vm_cgroup *vmcg;
+
+	rcu_read_lock();
+	do {
+		vmcg = vm_cgroup_from_task(p);
+	} while (!css_tryget_online(&vmcg->css));
+	rcu_read_unlock();
+
+	return vmcg;
+}
+
+void mm_init_vm_cgroup(struct mm_struct *mm, struct task_struct *p)
+{
+	if (!vm_cgroup_disabled())
+		mm->vmcg = get_vm_cgroup_from_task(p);
+}
+
+void mm_release_vm_cgroup(struct mm_struct *mm)
+{
+	struct vm_cgroup *vmcg = mm->vmcg;
+
+	if (vmcg)
+		css_put(&vmcg->css);
+}
+
+static int vm_cgroup_do_charge(struct vm_cgroup *vmcg,
+			       unsigned long nr_pages)
+{
+	unsigned long val = nr_pages << PAGE_SHIFT;
+	struct res_counter *fail_res;
+
+	return res_counter_charge(&vmcg->res, val, &fail_res);
+}
+
+static void vm_cgroup_do_uncharge(struct vm_cgroup *vmcg,
+				  unsigned long nr_pages)
+{
+	unsigned long val = nr_pages << PAGE_SHIFT;
+
+	res_counter_uncharge(&vmcg->res, val);
+}
+
+int vm_cgroup_charge_memory_mm(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct vm_cgroup *vmcg = mm->vmcg;
+
+	if (vmcg)
+		return vm_cgroup_do_charge(vmcg, nr_pages);
+	return 0;
+}
+
+void vm_cgroup_uncharge_memory_mm(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct vm_cgroup *vmcg = mm->vmcg;
+
+	if (vmcg)
+		vm_cgroup_do_uncharge(vmcg, nr_pages);
+}
+
 static struct cgroup_subsys_state *
 vm_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
