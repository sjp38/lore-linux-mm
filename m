Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7BA7NOc006301
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 06:07:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7BA7Nj5172550
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 04:07:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7BA7Mlw013883
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 04:07:23 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Mon, 11 Aug 2008 15:37:19 +0530
Message-Id: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
Subject: [-mm][PATCH 0/2] Memory rlimit fix crash on fork
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch fixes a crash that occurs when kernbench is set with memrlimit
set to 500M on my x86_64 box. The root cause for the failure is

1. We don't set mm->mmap to NULL for the process for which fork() failed
2. mmput() dereferences vma (in unmap_vmas, vma->vm_mm).

This patch fixes the problem by

1. Initializing mm->mmap to NULL prior to failing dup_mmap()
2. unmap_vmas() check if mm->mmap is NULL (vma is NULL)
3. Don't uncharge when do_fork() fails in exit_mmap()

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 kernel/fork.c |   19 ++++++++++---------
 mm/memory.c   |    6 +++++-
 mm/mmap.c     |    6 +++++-
 3 files changed, 20 insertions(+), 11 deletions(-)

diff -puN mm/mmap.c~memrlimit-fix-crash-on-fork mm/mmap.c
--- linux-2.6.27-rc1/mm/mmap.c~memrlimit-fix-crash-on-fork	2008-08-11 14:45:07.000000000 +0530
+++ linux-2.6.27-rc1-balbir/mm/mmap.c	2008-08-11 14:57:45.000000000 +0530
@@ -2104,6 +2104,7 @@ void exit_mmap(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
+	bool uncharge_as = true;
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
@@ -2118,6 +2119,8 @@ void exit_mmap(struct mm_struct *mm)
 		}
 	}
 	vma = mm->mmap;
+	if (!vma)
+		uncharge_as = false;
 	lru_add_drain();
 	flush_cache_mm(mm);
 	tlb = tlb_gather_mmu(mm, 1);
@@ -2125,7 +2128,8 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
+	if (uncharge_as)
+		memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
diff -puN kernel/fork.c~memrlimit-fix-crash-on-fork kernel/fork.c
--- linux-2.6.27-rc1/kernel/fork.c~memrlimit-fix-crash-on-fork	2008-08-11 14:45:07.000000000 +0530
+++ linux-2.6.27-rc1-balbir/kernel/fork.c	2008-08-11 14:56:04.000000000 +0530
@@ -274,15 +274,6 @@ static int dup_mmap(struct mm_struct *mm
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
-	/*
-	 * Uncharging as a result of failure is done by mmput()
-	 * in dup_mm()
-	 */
-	if (memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm)) {
-		retval = -ENOMEM;
-		goto out;
-	}
-
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
@@ -295,6 +286,16 @@ static int dup_mmap(struct mm_struct *mm
 	rb_parent = NULL;
 	pprev = &mm->mmap;
 
+	/*
+	 * Called after mm->mmap is set to NULL, so that the routines
+	 * following this function understand that fork failed (read
+	 * mmput).
+	 */
+	if (memrlimit_cgroup_charge_as(oldmm, oldmm->total_vm)) {
+		retval = -ENOMEM;
+		goto out;
+	}
+
 	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
 		struct file *file;
 
diff -puN mm/memory.c~memrlimit-fix-crash-on-fork mm/memory.c
--- linux-2.6.27-rc1/mm/memory.c~memrlimit-fix-crash-on-fork	2008-08-11 14:57:48.000000000 +0530
+++ linux-2.6.27-rc1-balbir/mm/memory.c	2008-08-11 14:58:33.000000000 +0530
@@ -901,8 +901,12 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm;
+
+	if (!vma)
+		return;
 
+	mm = vma->vm_mm;
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
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
