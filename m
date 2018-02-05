Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4278E6B002D
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q2so11078598pgf.22
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si385783pgw.58.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 25/64] mm: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:15 +0100
Message-Id: <20180205012754.23615-26-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Most of the mmap_sem users are already aware of mmrange,
making the conversion straightforward. Those who don't,
simply use the mmap_sem within the same function context.
No change in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/filemap.c           |  4 ++--
 mm/frame_vector.c      |  4 ++--
 mm/gup.c               | 16 ++++++++--------
 mm/khugepaged.c        | 35 +++++++++++++++++++----------------
 mm/memcontrol.c        | 10 +++++-----
 mm/memory.c            |  9 +++++----
 mm/mempolicy.c         | 21 +++++++++++----------
 mm/migrate.c           | 10 ++++++----
 mm/mincore.c           |  4 ++--
 mm/mmap.c              | 30 +++++++++++++++++-------------
 mm/mprotect.c          | 14 ++++++++------
 mm/mremap.c            |  4 ++--
 mm/msync.c             |  9 +++++----
 mm/nommu.c             | 23 +++++++++++++----------
 mm/oom_kill.c          |  8 ++++----
 mm/pagewalk.c          |  4 ++--
 mm/process_vm_access.c |  4 ++--
 mm/shmem.c             |  2 +-
 mm/swapfile.c          |  7 ++++---
 mm/userfaultfd.c       | 24 ++++++++++++++----------
 mm/util.c              |  9 +++++----
 21 files changed, 137 insertions(+), 114 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6124ede79a4d..b56f93e14992 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1303,7 +1303,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			return 0;
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		if (flags & FAULT_FLAG_KILLABLE)
 			wait_on_page_locked_killable(page);
 		else
@@ -1315,7 +1315,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 
 			ret = __lock_page_killable(page);
 			if (ret) {
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, mmrange);
 				return 0;
 			}
 		} else
diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index d3dccd80c6ee..2074f6c4d6e9 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -47,7 +47,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
 		nr_frames = vec->nr_allocated;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	locked = 1;
 	vma = find_vma_intersection(mm, start, start + 1);
 	if (!vma) {
@@ -102,7 +102,7 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	} while (vma && vma->vm_flags & (VM_IO | VM_PFNMAP));
 out:
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	if (!ret)
 		ret = -EFAULT;
 	if (ret > 0)
diff --git a/mm/gup.c b/mm/gup.c
index 3d1b6dd11616..08d7c17e9f06 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -827,7 +827,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	}
 
 	if (ret & VM_FAULT_RETRY) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, mmrange);
 		if (!(fault_flags & FAULT_FLAG_TRIED)) {
 			*unlocked = true;
 			fault_flags &= ~FAULT_FLAG_ALLOW_RETRY;
@@ -911,7 +911,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 */
 		*locked = 1;
 		lock_dropped = true;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, mmrange);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
 				       pages, NULL, NULL, mmrange);
 		if (ret != 1) {
@@ -932,7 +932,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		 * We must let the caller know we temporarily dropped the lock
 		 * and so the critical section protected by it was lost.
 		 */
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		*locked = 0;
 	}
 	return pages_done;
@@ -992,11 +992,11 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 	long ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
 				      &locked, gup_flags | FOLL_TOUCH, &mmrange);
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
@@ -1184,7 +1184,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON_VMA(start < vma->vm_start, vma);
 	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
-	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
+	VM_BUG_ON_MM(!mm_is_locked(mm, mmrange), mm);
 
 	gup_flags = FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
 	if (vma->vm_flags & VM_LOCKONFAULT)
@@ -1239,7 +1239,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		 */
 		if (!locked) {
 			locked = 1;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			vma = find_vma(mm, nstart);
 		} else if (nstart >= vma->vm_end)
 			vma = vma->vm_next;
@@ -1271,7 +1271,7 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 		ret = 0;
 	}
 	if (locked)
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	return ret;	/* 0 or negative error code */
 }
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 0b91ce730160..9076d26d162a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -469,6 +469,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		free_mm_slot(mm_slot);
 		mmdrop(mm);
 	} else if (mm_slot) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/*
 		 * This is required to serialize against
 		 * khugepaged_test_exit() (which is guaranteed to run
@@ -477,8 +479,8 @@ void __khugepaged_exit(struct mm_struct *mm)
 		 * khugepaged has finished working on the pagetables
 		 * under the mmap_sem.
 		 */
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 }
 
@@ -902,7 +904,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
-			down_read(&mm->mmap_sem);
+		        mm_read_lock(mm, mmrange);
 			if (hugepage_vma_revalidate(mm, address, &vmf.vma)) {
 				/* vma is no longer available, don't continue to swapin */
 				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
@@ -956,7 +958,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * sync compaction, and we do not need to hold the mmap_sem during
 	 * that. We will recheck the vma after taking it again in write mode.
 	 */
-	up_read(&mm->mmap_sem);
+        mm_read_unlock(mm, mmrange);
 	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page) {
 		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
@@ -968,11 +970,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 		goto out_nolock;
 	}
 
-	down_read(&mm->mmap_sem);
+        mm_read_lock(mm, mmrange);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
@@ -980,7 +982,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd) {
 		result = SCAN_PMD_NULL;
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
@@ -991,17 +993,17 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced, mmrange)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 		goto out_nolock;
 	}
 
-	up_read(&mm->mmap_sem);
+        mm_read_unlock(mm, mmrange);
 	/*
 	 * Prevent all access to pagetables with the exception of
 	 * gup_fast later handled by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
 	 */
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, mmrange);
 	result = hugepage_vma_revalidate(mm, address, &vma);
 	if (result)
 		goto out;
@@ -1084,7 +1086,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 	result = SCAN_SUCCEED;
 out_up_write:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, mmrange);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
@@ -1249,6 +1251,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	pmd_t *pmd, _pmd;
+ 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
@@ -1269,12 +1272,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 		 * re-fault. Not ideal, but it's more important to not disturb
 		 * the system too much.
 		 */
-		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+		if (mm_write_trylock(vma->vm_mm, &mmrange)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
 			/* assume page table is clear */
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
-			up_write(&vma->vm_mm->mmap_sem);
+		        mm_write_unlock(vma->vm_mm, &mmrange);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
@@ -1684,7 +1687,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	 * the next mm on the list.
 	 */
 	vma = NULL;
-	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
+	if (unlikely(!mm_read_trylock(mm, &mmrange)))
 		goto breakouterloop_mmap_sem;
 	if (likely(!khugepaged_test_exit(mm)))
 		vma = find_vma(mm, khugepaged_scan.address);
@@ -1729,7 +1732,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 				if (!shmem_huge_enabled(vma))
 					goto skip;
 				file = get_file(vma->vm_file);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &mmrange);
 				ret = 1;
 				khugepaged_scan_shmem(mm, file->f_mapping,
 						pgoff, hpage);
@@ -1750,7 +1753,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		}
 	}
 breakouterloop:
-	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
+        mm_read_unlock(mm, &mmrange); /* exit_mmap will destroy ptes after this */
 breakouterloop_mmap_sem:
 
 	spin_lock(&khugepaged_mm_lock);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a7ac5a14b22e..699d35ffee1a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4916,16 +4916,16 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 {
 	unsigned long precharge;
-	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	struct mm_walk mem_cgroup_count_precharge_walk = {
 		.pmd_entry = mem_cgroup_count_precharge_pte_range,
 		.mm = mm,
 	};
-	down_read(&mm->mmap_sem);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+	mm_read_lock(mm, &mmrange);
 	walk_page_range(0, mm->highest_vm_end,
 			&mem_cgroup_count_precharge_walk, &mmrange);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -5211,7 +5211,7 @@ static void mem_cgroup_move_charge(void)
 	atomic_inc(&mc.from->moving_account);
 	synchronize_rcu();
 retry:
-	if (unlikely(!down_read_trylock(&mc.mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mc.mm, &mmrange))) {
 		/*
 		 * Someone who are holding the mmap_sem might be waiting in
 		 * waitq. So we cancel all extra charges, wake up all waiters,
@@ -5230,7 +5230,7 @@ static void mem_cgroup_move_charge(void)
 	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk,
 			&mmrange);
 
-	up_read(&mc.mm->mmap_sem);
+	mm_read_unlock(mc.mm, &mmrange);
 	atomic_dec(&mc.from->moving_account);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 598a8c69e3d3..e3bf2879f7c3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4425,7 +4425,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	int write = gup_flags & FOLL_WRITE;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -4474,7 +4474,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return buf - old_buf;
 }
@@ -4525,11 +4525,12 @@ void print_vma_addr(char *prefix, unsigned long ip)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * we might be running from an atomic context so we cannot sleep
 	 */
-	if (!down_read_trylock(&mm->mmap_sem))
+	if (!mm_read_trylock(mm, &mmrange))
 		return;
 
 	vma = find_vma(mm, ip);
@@ -4548,7 +4549,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 #if defined(CONFIG_PROVE_LOCKING) || defined(CONFIG_DEBUG_ATOMIC_SLEEP)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 001dc176abc1..93b69c603e8d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -378,11 +378,12 @@ void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new)
 void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -842,10 +843,10 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -895,7 +896,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	return err;
 }
 
@@ -992,7 +993,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	/*
 	 * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
@@ -1073,7 +1074,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 		if (err < 0)
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1195,12 +1196,12 @@ static long do_mbind(unsigned long start, unsigned long len,
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			mm_write_lock(mm, &mmrange);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm, &mmrange);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1229,7 +1230,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	} else
 		putback_movable_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
  mpol_out:
 	mpol_put(new);
 	return err;
diff --git a/mm/migrate.c b/mm/migrate.c
index 7a6afc34dd54..e905d2aef7fa 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1486,8 +1486,9 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	struct page *page;
 	unsigned int follflags;
 	int err;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	err = -EFAULT;
 	vma = find_vma(mm, addr);
 	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
@@ -1540,7 +1541,7 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	 */
 	put_page(page);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return err;
 }
 
@@ -1638,8 +1639,9 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 				const void __user **pages, int *status)
 {
 	unsigned long i;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -1666,7 +1668,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 /*
diff --git a/mm/mincore.c b/mm/mincore.c
index a6875a34aac0..1255098449b8 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -259,9 +259,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp, &mmrange);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 		if (retval <= 0)
 			break;
diff --git a/mm/mmap.c b/mm/mmap.c
index 8f0eb88a5d5e..e10d005f7e2f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -191,7 +191,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	LIST_HEAD(uf);
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 #ifdef CONFIG_COMPAT_BRK
@@ -244,7 +244,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 set_brk:
 	mm->brk = brk;
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate)
 		mm_populate(oldbrk, newbrk - oldbrk);
@@ -252,7 +252,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return retval;
 }
 
@@ -2762,11 +2762,11 @@ int vm_munmap(unsigned long start, size_t len)
 	LIST_HEAD(uf);
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	ret = do_munmap(mm, start, len, &uf, &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
 }
@@ -2808,7 +2808,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
 		return ret;
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	vma = find_vma(mm, start);
@@ -2871,7 +2871,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 			    prot, flags, pgoff, &populate, NULL, &mmrange);
 	fput(file);
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	if (populate)
 		mm_populate(ret, populate);
 	if (!IS_ERR_VALUE(ret))
@@ -2882,9 +2882,11 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+ 	DEFINE_RANGE_LOCK_FULL(mmrange);
+
+	if (unlikely(mm_read_trylock(mm, &mmrange))) {
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 #endif
 }
@@ -2996,12 +2998,12 @@ int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
 	LIST_HEAD(uf);
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	ret = do_brk_flags(addr, len, flags, &uf, &mmrange);
 	populate = ((mm->def_flags & VM_LOCKED) != 0);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate && !ret)
 		mm_populate(addr, len);
@@ -3048,6 +3050,8 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 
 	if (unlikely(mm_is_oom_victim(mm))) {
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
 		/*
 		 * Wait for oom_reap_task() to stop working on this
 		 * mm. Because MMF_OOM_SKIP is already set before
@@ -3061,8 +3065,8 @@ void exit_mmap(struct mm_struct *mm)
 		 * is found not NULL while holding the task_lock.
 		 */
 		set_bit(MMF_OOM_SKIP, &mm->flags);
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index b84a70720319..2f39450ae959 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -424,7 +424,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 
 	reqprot = prot;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	/*
@@ -514,7 +514,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 		prot = reqprot;
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return error;
 }
 
@@ -536,6 +536,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 {
 	int pkey;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/* No flags supported yet. */
 	if (flags)
@@ -544,7 +545,7 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	if (init_val & ~PKEY_ACCESS_MASK)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	pkey = mm_pkey_alloc(current->mm);
 
 	ret = -ENOSPC;
@@ -558,17 +559,18 @@ SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
 	}
 	ret = pkey;
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
 SYSCALL_DEFINE1(pkey_free, int, pkey)
 {
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	ret = mm_pkey_free(current->mm, pkey);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	/*
 	 * We could provie warnings or errors if any VMA still
diff --git a/mm/mremap.c b/mm/mremap.c
index 21a9e2a2baa2..cc56d13e5e67 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -557,7 +557,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (!new_len)
 		return ret;
 
-	if (down_write_killable(&current->mm->mmap_sem))
+	if (mm_write_lock_killable(current->mm, &mmrange))
 		return -EINTR;
 
 	if (flags & MREMAP_FIXED) {
@@ -641,7 +641,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		vm_unacct_memory(charged);
 		locked = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	if (locked && new_len > old_len)
 		mm_populate(new_addr + old_len, new_len - old_len);
 	userfaultfd_unmap_complete(mm, &uf_unmap_early);
diff --git a/mm/msync.c b/mm/msync.c
index ef30a429623a..2524b4708e78 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -36,6 +36,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	struct vm_area_struct *vma;
 	int unmapped_error = 0;
 	int error = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
@@ -55,7 +56,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -86,12 +87,12 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 			error = vfs_fsync_range(file, fstart, fend, 1);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm, &mmrange);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -102,7 +103,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 out:
 	return error ? : unmapped_error;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 1805f0a788b3..575525e86961 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -187,10 +187,10 @@ static long __get_user_pages_unlocked(struct task_struct *tsk,
 	long ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
 			       NULL, NULL, &mmrange);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 
@@ -253,12 +253,13 @@ void *vmalloc_user(unsigned long size)
 	ret = __vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);
 	if (ret) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm, &mmrange);
 		vma = find_vma(current->mm, (unsigned long)ret);
 		if (vma)
 			vma->vm_flags |= VM_USERMAP;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm, &mmrange);
 	}
 
 	return ret;
@@ -1651,9 +1652,9 @@ int vm_munmap(unsigned long addr, size_t len)
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	ret = do_munmap(mm, addr, len, NULL, &mmrange);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 EXPORT_SYMBOL(vm_munmap);
@@ -1739,10 +1740,11 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		unsigned long, new_addr)
 {
 	unsigned long ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 	return ret;
 }
 
@@ -1815,8 +1817,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1838,7 +1841,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return len;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2288e1cb1bc9..6bf9cb38bfe1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -508,7 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mutex_lock(&oom_lock);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		ret = false;
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
@@ -521,7 +521,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * notifiers cannot block for unbounded amount of time
 	 */
 	if (mm_has_blockable_invalidate_notifiers(mm, &mmrange)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		schedule_timeout_idle(HZ);
 		goto unlock_oom;
 	}
@@ -533,7 +533,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
 	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
 	}
@@ -578,7 +578,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 44a2507c94fd..55a4dcc519cd 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -301,7 +301,7 @@ int walk_page_range(unsigned long start, unsigned long end,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
+	VM_BUG_ON_MM(!mm_is_locked(walk->mm, mmrange), walk->mm);
 
 	vma = find_vma(walk->mm, start);
 	do {
@@ -345,7 +345,7 @@ int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk,
 	if (!walk->mm)
 		return -EINVAL;
 
-	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+	VM_BUG_ON(!mm_is_locked(walk->mm, mmrange));
 	VM_BUG_ON(!vma);
 	walk->vma = vma;
 	err = walk_page_test(vma->vm_start, vma->vm_end, walk, mmrange);
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index ff6772b86195..aaccb8972f83 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -110,12 +110,12 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * access remotely because task/mm might not
 		 * current/current->mm
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		pages = get_user_pages_remote(task, mm, pa, pages, flags,
 					      process_pages, NULL, &locked,
 					      &mmrange);
 		if (locked)
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm, &mmrange);
 		if (pages <= 0)
 			return -EFAULT;
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 1907688b75ee..8a99281bf502 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1961,7 +1961,7 @@ static int shmem_fault(struct vm_fault *vmf)
 			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
-				up_read(&vma->vm_mm->mmap_sem);
+				mm_read_unlock(vma->vm_mm, vmf->lockrange);
 				ret = VM_FAULT_RETRY;
 			}
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 006047b16814..d9c6ca32b94f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1958,15 +1958,16 @@ static int unuse_mm(struct mm_struct *mm,
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		/*
 		 * Activate page so shrink_inactive_list is unlikely to unmap
 		 * its ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
@@ -1974,7 +1975,7 @@ static int unuse_mm(struct mm_struct *mm,
 			break;
 		cond_resched();
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return (ret < 0)? ret: 0;
 }
 
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 39791b81ede7..8ad13bea799d 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -155,7 +155,8 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 					      unsigned long dst_start,
 					      unsigned long src_start,
 					      unsigned long len,
-					      bool zeropage)
+					      bool zeropage,
+					      struct range_lock *mmrange)
 {
 	int vm_alloc_shared = dst_vma->vm_flags & VM_SHARED;
 	int vm_shared = dst_vma->vm_flags & VM_SHARED;
@@ -177,7 +178,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	 * feature is not supported.
 	 */
 	if (zeropage) {
-		up_read(&dst_mm->mmap_sem);
+		mm_read_unlock(dst_mm, mmrange);
 		return -EINVAL;
 	}
 
@@ -275,7 +276,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 		cond_resched();
 
 		if (unlikely(err == -EFAULT)) {
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, mmrange);
 			BUG_ON(!page);
 
 			err = copy_huge_page_from_user(page,
@@ -285,7 +286,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				err = -EFAULT;
 				goto out;
 			}
-			down_read(&dst_mm->mmap_sem);
+			mm_read_lock(dst_mm, mmrange);
 
 			dst_vma = NULL;
 			goto retry;
@@ -305,7 +306,7 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, mmrange);
 out:
 	if (page) {
 		/*
@@ -367,7 +368,8 @@ extern ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 				      unsigned long dst_start,
 				      unsigned long src_start,
 				      unsigned long len,
-				      bool zeropage);
+				      bool zeropage,
+				      struct range_lock *mmrange);
 #endif /* CONFIG_HUGETLB_PAGE */
 
 static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
@@ -412,6 +414,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	unsigned long src_addr, dst_addr;
 	long copied;
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * Sanitize the command parameters:
@@ -428,7 +431,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	copied = 0;
 	page = NULL;
 retry:
-	down_read(&dst_mm->mmap_sem);
+	mm_read_lock(dst_mm, &mmrange);
 
 	/*
 	 * Make sure the vma is not shared, that the dst range is
@@ -468,7 +471,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	 */
 	if (is_vm_hugetlb_page(dst_vma))
 		return  __mcopy_atomic_hugetlb(dst_mm, dst_vma, dst_start,
-						src_start, len, zeropage);
+					       src_start, len, zeropage,
+					       &mmrange);
 
 	if (!vma_is_anonymous(dst_vma) && !vma_is_shmem(dst_vma))
 		goto out_unlock;
@@ -523,7 +527,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 		if (unlikely(err == -EFAULT)) {
 			void *page_kaddr;
 
-			up_read(&dst_mm->mmap_sem);
+			mm_read_unlock(dst_mm, &mmrange);
 			BUG_ON(!page);
 
 			page_kaddr = kmap(page);
@@ -552,7 +556,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
 	}
 
 out_unlock:
-	up_read(&dst_mm->mmap_sem);
+	mm_read_unlock(dst_mm, &mmrange);
 out:
 	if (page)
 		put_page(page);
diff --git a/mm/util.c b/mm/util.c
index b0ec1d88bb71..e17c6c74cc23 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -351,11 +351,11 @@ unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 
 	ret = security_mmap_file(file, prot, flag);
 	if (!ret) {
-		if (down_write_killable(&mm->mmap_sem))
+		if (mm_write_lock_killable(mm, &mmrange))
 			return -EINTR;
 		ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
 				    &populate, &uf, &mmrange);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		userfaultfd_unmap_complete(mm, &uf);
 		if (populate)
 			mm_populate(ret, populate);
@@ -715,18 +715,19 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	int res = 0;
 	unsigned int len;
 	struct mm_struct *mm = get_task_mm(task);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	unsigned long arg_start, arg_end, env_start, env_end;
 	if (!mm)
 		goto out;
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	len = arg_end - arg_start;
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
