Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8JEHKus020228
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 00:17:40 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8JE6VU31360088
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 00:06:36 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8JE6UPe025184
	for <linux-mm@kvack.org>; Sat, 20 Sep 2008 00:06:31 +1000
Date: Thu, 18 Sep 2008 23:38:23 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
	control (v4)
Message-ID: <20080919063823.GA27639@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <20080918135430.e2979ab1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080918135430.e2979ab1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2008-09-18 13:54:30]:

> On Wed, 14 May 2008 18:39:51 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > This patch adds support for accounting and control of virtual address space
> > limits.
> 
> 
> Large changes in linux-next's arch/x86/kernel/ptrace.c caused damage to
> the memrlimit patches.
> 
> I decided to retain the patches because it looks repairable.  The
> problem is this reject from
> memrlimit-add-memrlimit-controller-accounting-and-control.patch:
>

Andrew,

I could not apply mmotm to linux-next (both downloaded right now). I
applied the patches one-by-one resolving differences starting from #mm
in the series file.

Here is my fixed version of the patch, I compiled the patch, but could
not run it, since I could not create the full series of applied
patches. I compiled arch/x86/kernel/ds.o and ptrace.o. I've included
the patch below, please let me know if the code looks OK (via review)
and the patch applies. I'll test it once I can resonably resolve all
conflicts between linux-next and mmotm.


From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch adds support for accounting and control of virtual address space
limits. The accounting is done via the rlimit_cgroup_(un)charge_as functions.
The core of the accounting takes place during fork time in copy_process(),
may_expand_vm(), remove_vma_list() and exit_mmap().

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Pavel Emelianov <xemul@openvz.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/kernel/ptrace.c        |    1 
 include/linux/memrlimitcgroup.h |   21 ++++++
 kernel/fork.c                   |   14 ++++
 mm/memrlimitcgroup.c            |   92 ++++++++++++++++++++++++++++++
 mm/mmap.c                       |   17 ++++-
 5 files changed, 142 insertions(+), 3 deletions(-)

Index: linux-next/include/linux/memrlimitcgroup.h
===================================================================
--- linux-next.orig/include/linux/memrlimitcgroup.h	2008-09-18 23:19:26.000000000 -0700
+++ linux-next/include/linux/memrlimitcgroup.h	2008-09-18 23:19:29.000000000 -0700
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
Index: linux-next/kernel/fork.c
===================================================================
--- linux-next.orig/kernel/fork.c	2008-09-18 21:32:39.000000000 -0700
+++ linux-next/kernel/fork.c	2008-09-18 23:27:21.000000000 -0700
@@ -51,6 +51,7 @@
 #include <linux/acct.h>
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
+#include <linux/memrlimitcgroup.h>
 #include <linux/freezer.h>
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
@@ -263,7 +264,7 @@
 	struct vm_area_struct *mpnt, *tmp, **pprev;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
-	unsigned long charge;
+	unsigned long charge, uncharged = 0;
 	struct mempolicy *pol;
 
 	down_write(&oldmm->mmap_sem);
@@ -273,6 +274,15 @@
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
+	/*
+	 * Uncharging as a result of failure is done by mmput()
+	 * in dup_mm()
+	 */
+	if (memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm)) {
+		retval = -ENOMEM;
+		goto out;
+	}
+
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
@@ -293,6 +303,8 @@
 			mm->total_vm -= pages;
 			vm_stat_account(mm, mpnt->vm_flags, mpnt->vm_file,
 								-pages);
+			memrlimit_cgroup_uncharge_as(mm, pages);
+			uncharged += pages;
 			continue;
 		}
 		charge = 0;
Index: linux-next/mm/memrlimitcgroup.c
===================================================================
--- linux-next.orig/mm/memrlimitcgroup.c	2008-09-18 23:19:26.000000000 -0700
+++ linux-next/mm/memrlimitcgroup.c	2008-09-18 23:27:36.000000000 -0700
@@ -45,6 +45,38 @@
 				struct memrlimit_cgroup, css);
 }
 
+static struct memrlimit_cgroup *
+memrlimit_cgroup_from_task(struct task_struct *p)
+{
+	return container_of(task_subsys_state(p, memrlimit_cgroup_subsys_id),
+				struct memrlimit_cgroup, css);
+}
+
+/*
+ * Charge the cgroup for address space usage - mmap(), malloc() (through
+ * brk(), sbrk()), stack expansion, mremap(), etc - called with
+ * mmap_sem held.
+ */
+int memrlimit_cgroup_charge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct memrlimit_cgroup *memrcg;
+
+	memrcg = memrlimit_cgroup_from_task(mm->owner);
+	return res_counter_charge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
+}
+
+/*
+ * Uncharge the cgroup, as the address space of one of the tasks is
+ * decreasing - called with mmap_sem held.
+ */
+void memrlimit_cgroup_uncharge_as(struct mm_struct *mm, unsigned long nr_pages)
+{
+	struct memrlimit_cgroup *memrcg;
+
+	memrcg = memrlimit_cgroup_from_task(mm->owner);
+	res_counter_uncharge(&memrcg->as_res, (nr_pages << PAGE_SHIFT));
+}
+
 static struct cgroup_subsys_state *
 memrlimit_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
@@ -121,11 +153,71 @@
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
+	/*
+	 * Hold mmap_sem, so that total_vm does not change underneath us
+	 */
+	down_read(&mm->mmap_sem);
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
+	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
+	rcu_read_unlock();
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+}
+
+/*
+ * This callback is called with mmap_sem held
+ */
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
+	if (res_counter_charge(&memrcg->as_res, (mm->total_vm << PAGE_SHIFT)))
+		goto out;
+	res_counter_uncharge(&old_memrcg->as_res, (mm->total_vm << PAGE_SHIFT));
+out:
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
Index: linux-next/mm/mmap.c
===================================================================
--- linux-next.orig/mm/mmap.c	2008-09-18 23:00:18.000000000 -0700
+++ linux-next/mm/mmap.c	2008-09-18 23:27:21.000000000 -0700
@@ -23,6 +23,7 @@
 #include <linux/hugetlb.h>
 #include <linux/profile.h>
 #include <linux/module.h>
+#include <linux/memrlimitcgroup.h>
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
@@ -1756,6 +1757,7 @@
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
+		memrlimit_cgroup_uncharge_as(mm, nrpages);
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
 		vma = remove_vma(vma);
 	} while (vma);
@@ -2106,6 +2108,7 @@
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
+	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
@@ -2128,6 +2131,9 @@
 	struct vm_area_struct * __vma, * prev;
 	struct rb_node ** rb_link, * rb_parent;
 
+	if (memrlimit_cgroup_charge_as(mm, vma_pages(vma)))
+		return -ENOMEM;
+
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
 	 * until its first write fault, when page's anon_vma and index
@@ -2146,12 +2152,15 @@
 	}
 	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
 	if (__vma && __vma->vm_start < vma->vm_end)
-		return -ENOMEM;
+		goto err;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
-		return -ENOMEM;
+		goto err;
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	return 0;
+err:
+	memrlimit_cgroup_uncharge_as(mm, vma_pages(vma));
+	return -ENOMEM;
 }
 
 /*
@@ -2224,6 +2233,10 @@
 
 	if (cur + npages > lim)
 		return 0;
+
+	if (memrlimit_cgroup_charge_as(mm, npages))
+		return 0;
+
 	return 1;
 }
 
Index: linux-next/arch/x86/kernel/ds.c
===================================================================
--- linux-next.orig/arch/x86/kernel/ds.c	2008-09-18 23:28:07.000000000 -0700
+++ linux-next/arch/x86/kernel/ds.c	2008-09-18 23:33:55.000000000 -0700
@@ -30,6 +30,7 @@
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
+#include <linux/memrlimitcgroup.h>
 
 
 /*
@@ -339,19 +340,22 @@
 
 	pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
+	if (memrlimit_cgroup_charge_as(current->mm, pgsz << PAGE_SHIFT))
+		return NULL;
+
 	rlim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
 	vm   = current->mm->total_vm  + pgsz;
 	if (rlim < vm)
-		return NULL;
+		goto uncharge;
 
 	rlim = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
 	vm   = current->mm->locked_vm  + pgsz;
 	if (rlim < vm)
-		return NULL;
+		goto uncharge;
 
 	buffer = kzalloc(size, GFP_KERNEL);
 	if (!buffer)
-		return NULL;
+		goto uncharge;
 
 	current->mm->total_vm  += pgsz;
 	current->mm->locked_vm += pgsz;
@@ -360,6 +364,9 @@
 		*pages = pgsz;
 
 	return buffer;
+uncharge:
+	memrlimit_cgroup_uncharge_as(current->mm, pgsz << PAGE_SHIFT);
+	return NULL;
 }
 
 static int ds_request(struct task_struct *task, void *base, size_t size,

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
