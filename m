Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C851F6B0047
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:05:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG35nxO024974
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:05:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D6CA45DE51
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:05:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DE0745DE52
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:05:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17BCB1DB803F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:05:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 940891DB8040
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:05:48 +0900 (JST)
Date: Wed, 16 Dec 2009 12:02:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 2/11] mm accessor for kernel core
Message-Id: <20091216120243.6626a463.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Replacing mmap_sem with mm_accessor functions for
  kernel/
  mm/
  ipc

layers.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c          |   14 +++++++-------
 ipc/shm.c                   |    8 ++++----
 kernel/acct.c               |    4 ++--
 kernel/auditsc.c            |    4 ++--
 kernel/exit.c               |    8 ++++----
 kernel/fork.c               |   10 +++++-----
 kernel/trace/trace_output.c |    4 ++--
 mm/fremap.c                 |   12 ++++++------
 mm/ksm.c                    |   32 ++++++++++++++++----------------
 mm/madvise.c                |   12 ++++++------
 mm/memory.c                 |   10 +++++-----
 mm/mempolicy.c              |   28 ++++++++++++++--------------
 mm/migrate.c                |    8 ++++----
 mm/mincore.c                |    4 ++--
 mm/mlock.c                  |   26 +++++++++++++-------------
 mm/mmap.c                   |   20 ++++++++++----------
 mm/mmu_notifier.c           |    4 ++--
 mm/mprotect.c               |    4 ++--
 mm/mremap.c                 |    4 ++--
 mm/msync.c                  |    8 ++++----
 mm/nommu.c                  |   16 ++++++++--------
 mm/rmap.c                   |   13 ++++++-------
 mm/swapfile.c               |    6 +++---
 mm/util.c                   |    4 ++--
 24 files changed, 131 insertions(+), 132 deletions(-)

Index: mmotm-mm-accessor/kernel/acct.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/acct.c
+++ mmotm-mm-accessor/kernel/acct.c
@@ -609,13 +609,13 @@ void acct_collect(long exitcode, int gro
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
Index: mmotm-mm-accessor/kernel/auditsc.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/auditsc.c
+++ mmotm-mm-accessor/kernel/auditsc.c
@@ -960,7 +960,7 @@ static void audit_log_task_info(struct a
 	audit_log_untrustedstring(ab, name);
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		vma = mm->mmap;
 		while (vma) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
@@ -971,7 +971,7 @@ static void audit_log_task_info(struct a
 			}
 			vma = vma->vm_next;
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	}
 	audit_log_task_context(ab);
 }
Index: mmotm-mm-accessor/kernel/exit.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/exit.c
+++ mmotm-mm-accessor/kernel/exit.c
@@ -656,11 +656,11 @@ static void exit_mm(struct task_struct *
 	 * will increment ->nr_threads for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	core_state = mm->core_state;
 	if (core_state) {
 		struct core_thread self;
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 
 		self.task = tsk;
 		self.next = xchg(&core_state->dumper.next, &self);
@@ -678,14 +678,14 @@ static void exit_mm(struct task_struct *
 			schedule();
 		}
 		__set_task_state(tsk, TASK_RUNNING);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 	}
 	atomic_inc(&mm->mm_count);
 	BUG_ON(mm != tsk->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	enter_lazy_tlb(mm, current);
 	/* We don't want this task to be frozen prematurely */
 	clear_freeze_flag(tsk);
Index: mmotm-mm-accessor/kernel/fork.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/fork.c
+++ mmotm-mm-accessor/kernel/fork.c
@@ -285,12 +285,12 @@ static int dup_mmap(struct mm_struct *mm
 	unsigned long charge;
 	struct mempolicy *pol;
 
-	down_write(&oldmm->mmap_sem);
+	mm_write_lock(oldmm);
 	flush_cache_dup_mm(oldmm);
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	mm_write_lock_nested(mm, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
@@ -387,9 +387,9 @@ static int dup_mmap(struct mm_struct *mm
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
@@ -448,7 +448,7 @@ static struct mm_struct * mm_init(struct
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	mm_lock_init(mm);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ?
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
Index: mmotm-mm-accessor/kernel/trace/trace_output.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/trace/trace_output.c
+++ mmotm-mm-accessor/kernel/trace/trace_output.c
@@ -376,7 +376,7 @@ int seq_print_user_ip(struct trace_seq *
 	if (mm) {
 		const struct vm_area_struct *vma;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -388,7 +388,7 @@ int seq_print_user_ip(struct trace_seq *
 				ret = trace_seq_printf(s, "[+0x%lx]",
 						       ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		ret = trace_seq_printf(s, " <" IP_FMT ">", ip);
Index: mmotm-mm-accessor/mm/fremap.c
===================================================================
--- mmotm-mm-accessor.orig/mm/fremap.c
+++ mmotm-mm-accessor/mm/fremap.c
@@ -149,7 +149,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 #endif
 
 	/* We need down_write() to change vma->vm_flags. */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
  retry:
 	vma = find_vma(mm, start);
 
@@ -180,8 +180,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 		}
 
 		if (!has_write_lock) {
-			up_read(&mm->mmap_sem);
-			down_write(&mm->mmap_sem);
+			mm_read_unlock(mm);
+			mm_write_lock(mm);
 			has_write_lock = 1;
 			goto retry;
 		}
@@ -237,7 +237,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 			mlock_vma_pages_range(vma, start, start + size);
 		} else {
 			if (unlikely(has_write_lock)) {
-				downgrade_write(&mm->mmap_sem);
+				mm_write_to_read_lock(mm);
 				has_write_lock = 0;
 			}
 			make_pages_present(start, start+size);
@@ -252,9 +252,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsign
 
 out:
 	if (likely(!has_write_lock))
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	else
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 
 	return err;
 }
Index: mmotm-mm-accessor/mm/ksm.c
===================================================================
--- mmotm-mm-accessor.orig/mm/ksm.c
+++ mmotm-mm-accessor/mm/ksm.c
@@ -417,7 +417,7 @@ static void break_cow(struct rmap_item *
 	 */
 	drop_anon_vma(rmap_item);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	if (ksm_test_exit(mm))
 		goto out;
 	vma = find_vma(mm, addr);
@@ -427,7 +427,7 @@ static void break_cow(struct rmap_item *
 		goto out;
 	break_ksm(vma, addr);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 }
 
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
@@ -437,7 +437,7 @@ static struct page *get_mergeable_page(s
 	struct vm_area_struct *vma;
 	struct page *page;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	if (ksm_test_exit(mm))
 		goto out;
 	vma = find_vma(mm, addr);
@@ -456,7 +456,7 @@ static struct page *get_mergeable_page(s
 		put_page(page);
 out:		page = NULL;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return page;
 }
 
@@ -642,7 +642,7 @@ static int unmerge_and_remove_all_rmap_i
 	for (mm_slot = ksm_scan.mm_slot;
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (ksm_test_exit(mm))
 				break;
@@ -666,11 +666,11 @@ static int unmerge_and_remove_all_rmap_i
 
 			free_mm_slot(mm_slot);
 			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm);
 			mmdrop(mm);
 		} else {
 			spin_unlock(&ksm_mmlist_lock);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm);
 		}
 	}
 
@@ -678,7 +678,7 @@ static int unmerge_and_remove_all_rmap_i
 	return 0;
 
 error:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -905,7 +905,7 @@ static int try_to_merge_with_ksm_page(st
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	if (ksm_test_exit(mm))
 		goto out;
 	vma = find_vma(mm, rmap_item->address);
@@ -919,7 +919,7 @@ static int try_to_merge_with_ksm_page(st
 	/* Must get reference to anon_vma while still holding mmap_sem */
 	hold_anon_vma(rmap_item, vma->anon_vma);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return err;
 }
 
@@ -1276,7 +1276,7 @@ next_mm:
 	}
 
 	mm = slot->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	if (ksm_test_exit(mm))
 		vma = NULL;
 	else
@@ -1305,7 +1305,7 @@ next_mm:
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm);
 				return rmap_item;
 			}
 			if (*page)
@@ -1344,11 +1344,11 @@ next_mm:
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		mmdrop(mm);
 	} else {
 		spin_unlock(&ksm_mmlist_lock);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	}
 
 	/* Repeat until we've completed scanning the whole list */
@@ -1513,8 +1513,8 @@ void __ksm_exit(struct mm_struct *mm)
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		mm_write_lock(mm);
+		mm_writer_unlock(mm);
 	}
 }
 
Index: mmotm-mm-accessor/mm/madvise.c
===================================================================
--- mmotm-mm-accessor.orig/mm/madvise.c
+++ mmotm-mm-accessor/mm/madvise.c
@@ -212,9 +212,9 @@ static long madvise_remove(struct vm_are
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
 	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	error = vmtruncate_range(mapping->host, offset, endoff);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	return error;
 }
 
@@ -343,9 +343,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, 
 
 	write = madvise_need_mmap_write(behavior);
 	if (write)
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 	else
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 
 	if (start & ~PAGE_MASK)
 		goto out;
@@ -408,9 +408,9 @@ SYSCALL_DEFINE3(madvise, unsigned long, 
 	}
 out:
 	if (write)
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 	else
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 	return error;
 }
Index: mmotm-mm-accessor/mm/memory.c
===================================================================
--- mmotm-mm-accessor.orig/mm/memory.c
+++ mmotm-mm-accessor/mm/memory.c
@@ -3284,7 +3284,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -3331,7 +3331,7 @@ int access_process_vm(struct task_struct
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 
 	return buf - old_buf;
@@ -3352,7 +3352,7 @@ void print_vma_addr(char *prefix, unsign
 	if (preempt_count())
 		return;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	vma = find_vma(mm, ip);
 	if (vma && vma->vm_file) {
 		struct file *f = vma->vm_file;
@@ -3372,7 +3372,7 @@ void print_vma_addr(char *prefix, unsign
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(mm);
 }
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -3394,7 +3394,7 @@ void might_fault(void)
 	 * providing helpers like get_user_atomic.
 	 */
 	if (!in_atomic() && current->mm)
-		might_lock_read(&current->mm->mmap_sem);
+		mm_read_might_lock(current->mm);
 }
 EXPORT_SYMBOL(might_fault);
 #endif
Index: mmotm-mm-accessor/mm/mempolicy.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mempolicy.c
+++ mmotm-mm-accessor/mm/mempolicy.c
@@ -365,10 +365,10 @@ void mpol_rebind_mm(struct mm_struct *mm
 {
 	struct vm_area_struct *vma;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 }
 
 static const struct mempolicy_operations mpol_ops[MPOL_MAX] = {
@@ -638,13 +638,13 @@ static long do_set_mempolicy(unsigned sh
 	 * with no 'mm'.
 	 */
 	if (mm)
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm);
 	task_lock(current);
 	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
 		task_unlock(current);
 		if (mm)
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm);
 		mpol_put(new);
 		goto out;
 	}
@@ -656,7 +656,7 @@ static long do_set_mempolicy(unsigned sh
 		current->il_next = first_node(new->v.nodes);
 	task_unlock(current);
 	if (mm)
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 
 	mpol_put(old);
 	ret = 0;
@@ -734,10 +734,10 @@ static long do_get_mempolicy(int *policy
 		 * vma/shared policy at addr is NULL.  We
 		 * want to return MPOL_DEFAULT in this case.
 		 */
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -774,7 +774,7 @@ static long do_get_mempolicy(int *policy
 	}
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 		vma = NULL;
 	}
 
@@ -788,7 +788,7 @@ static long do_get_mempolicy(int *policy
  out:
 	mpol_cond_put(pol);
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 	return err;
 }
 
@@ -856,7 +856,7 @@ int do_migrate_pages(struct mm_struct *m
 	if (err)
 		return err;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
 	if (err)
@@ -922,7 +922,7 @@ int do_migrate_pages(struct mm_struct *m
 			break;
 	}
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (err < 0)
 		return err;
 	return busy;
@@ -1027,12 +1027,12 @@ static long do_mbind(unsigned long start
 	{
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
-			down_write(&mm->mmap_sem);
+			mm_write_lock(mm);
 			task_lock(current);
 			err = mpol_set_nodemask(new, nmask, scratch);
 			task_unlock(current);
 			if (err)
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm);
 		} else
 			err = -ENOMEM;
 		NODEMASK_SCRATCH_FREE(scratch);
@@ -1058,7 +1058,7 @@ static long do_mbind(unsigned long start
 	} else
 		putback_lru_pages(&pagelist);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
  mpol_out:
 	mpol_put(new);
 	return err;
Index: mmotm-mm-accessor/mm/mlock.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mlock.c
+++ mmotm-mm-accessor/mm/mlock.c
@@ -161,7 +161,7 @@ static long __mlock_vma_pages_range(stru
 	VM_BUG_ON(end   & ~PAGE_MASK);
 	VM_BUG_ON(start < vma->vm_start);
 	VM_BUG_ON(end   > vma->vm_end);
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON(!mm_is_locked(mm));
 
 	gup_flags = FOLL_TOUCH | FOLL_GET;
 	if (vma->vm_flags & VM_WRITE)
@@ -480,7 +480,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
 
 	lru_add_drain_all();	/* flush pagevec */
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 
@@ -493,7 +493,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, st
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = do_mlock(start, len, 1);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return error;
 }
 
@@ -501,11 +501,11 @@ SYSCALL_DEFINE2(munlock, unsigned long, 
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 	ret = do_mlock(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return ret;
 }
 
@@ -548,7 +548,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 
 	lru_add_drain_all();	/* flush pagevec */
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
@@ -557,7 +557,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 out:
 	return ret;
 }
@@ -566,9 +566,9 @@ SYSCALL_DEFINE0(munlockall)
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	ret = do_mlockall(0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return ret;
 }
 
@@ -616,7 +616,7 @@ int account_locked_memory(struct mm_stru
 
 	pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 	lim = ACCESS_ONCE(rlim[RLIMIT_AS].rlim_cur) >> PAGE_SHIFT;
 	vm   = mm->total_vm + pgsz;
@@ -633,7 +633,7 @@ int account_locked_memory(struct mm_stru
 
 	error = 0;
  out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return error;
 }
 
@@ -641,10 +641,10 @@ void refund_locked_memory(struct mm_stru
 {
 	unsigned long pgsz = PAGE_ALIGN(size) >> PAGE_SHIFT;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 	mm->total_vm  -= pgsz;
 	mm->locked_vm -= pgsz;
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 }
Index: mmotm-mm-accessor/mm/mmap.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mmap.c
+++ mmotm-mm-accessor/mm/mmap.c
@@ -249,7 +249,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	struct mm_struct *mm = current->mm;
 	unsigned long min_brk;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 #ifdef CONFIG_COMPAT_BRK
 	min_brk = mm->end_code;
@@ -293,7 +293,7 @@ set_brk:
 	mm->brk = brk;
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return retval;
 }
 
@@ -1999,18 +1999,18 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
 
 	profile_munmap(addr);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return ret;
 }
 
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(mm_read_trylock(mm))) {
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	}
 #endif
 }
@@ -2368,7 +2368,7 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		mm_nest_spin_lock(&anon_vma->lock, mm);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->lock. If some other vma in this mm shares
@@ -2398,7 +2398,7 @@ static void vm_lock_mapping(struct mm_st
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
+		mm_nest_spin_lock(&mapping->i_mmap_lock, mm);
 	}
 }
 
@@ -2439,7 +2439,7 @@ int mm_take_all_locks(struct mm_struct *
 	struct vm_area_struct *vma;
 	int ret = -EINTR;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -2510,7 +2510,7 @@ void mm_drop_all_locks(struct mm_struct 
 {
 	struct vm_area_struct *vma;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
Index: mmotm-mm-accessor/mm/migrate.c
===================================================================
--- mmotm-mm-accessor.orig/mm/migrate.c
+++ mmotm-mm-accessor/mm/migrate.c
@@ -791,7 +791,7 @@ static int do_move_page_to_node_array(st
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	/*
 	 * Build a list of pages to migrate
@@ -855,7 +855,7 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm, 0);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return err;
 }
 
@@ -954,7 +954,7 @@ static void do_pages_stat_array(struct m
 {
 	unsigned long i;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	for (i = 0; i < nr_pages; i++) {
 		unsigned long addr = (unsigned long)(*pages);
@@ -985,7 +985,7 @@ set_status:
 		status++;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 }
 
 /*
Index: mmotm-mm-accessor/mm/mincore.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mincore.c
+++ mmotm-mm-accessor/mm/mincore.c
@@ -246,9 +246,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, 
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		retval = do_mincore(start, tmp, min(pages, PAGE_SIZE));
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (retval <= 0)
 			break;
Index: mmotm-mm-accessor/mm/mmu_notifier.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mmu_notifier.c
+++ mmotm-mm-accessor/mm/mmu_notifier.c
@@ -176,7 +176,7 @@ static int do_mmu_notifier_register(stru
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
 		goto out_cleanup;
@@ -204,7 +204,7 @@ static int do_mmu_notifier_register(stru
 	mm_drop_all_locks(mm);
 out_cleanup:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 	/* kfree() does nothing if mmu_notifier_mm is NULL */
 	kfree(mmu_notifier_mm);
 out:
Index: mmotm-mm-accessor/mm/mremap.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mremap.c
+++ mmotm-mm-accessor/mm/mremap.c
@@ -442,8 +442,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, a
 {
 	unsigned long ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return ret;
 }
Index: mmotm-mm-accessor/mm/rmap.c
===================================================================
--- mmotm-mm-accessor.orig/mm/rmap.c
+++ mmotm-mm-accessor/mm/rmap.c
@@ -376,8 +376,7 @@ int page_referenced_one(struct page *pag
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
-			rwsem_is_locked(&mm->mmap_sem))
+	if (mm != current->mm && has_swap_token(mm) && mm_is_locked(mm))
 		referenced++;
 
 out_unmap:
@@ -879,12 +878,12 @@ out_mlock:
 	 * vmscan could retry to move the page to unevictable lru if the
 	 * page is actually mlocked.
 	 */
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+	if (mm_read_trylock(vma->vm_mm)) {
 		if (vma->vm_flags & VM_LOCKED) {
 			mlock_vma_page(page);
 			ret = SWAP_MLOCK;
 		}
-		up_read(&vma->vm_mm->mmap_sem);
+		mm_read_unlock(vma->vm_mm);
 	}
 	return ret;
 }
@@ -955,10 +954,10 @@ static int try_to_unmap_cluster(unsigned
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
 	 * keep the sem while scanning the cluster for mlocking pages.
 	 */
-	if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
+	if (mm_read_trylock(vma->vm_mm)) {
 		locked_vma = (vma->vm_flags & VM_LOCKED);
 		if (!locked_vma)
-			up_read(&vma->vm_mm->mmap_sem); /* don't need it */
+			mm_read_unlock(vma->vm_mm); /* don't need it */
 	}
 
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -1001,7 +1000,7 @@ static int try_to_unmap_cluster(unsigned
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	if (locked_vma)
-		up_read(&vma->vm_mm->mmap_sem);
+		mm_read_unlock(vma->vm_mm);
 	return ret;
 }
 
Index: mmotm-mm-accessor/mm/mprotect.c
===================================================================
--- mmotm-mm-accessor.orig/mm/mprotect.c
+++ mmotm-mm-accessor/mm/mprotect.c
@@ -250,7 +250,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 	vm_flags = calc_vm_prot_bits(prot);
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	vma = find_vma_prev(current->mm, start, &prev);
 	error = -ENOMEM;
@@ -315,6 +315,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		}
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return error;
 }
Index: mmotm-mm-accessor/mm/msync.c
===================================================================
--- mmotm-mm-accessor.orig/mm/msync.c
+++ mmotm-mm-accessor/mm/msync.c
@@ -54,7 +54,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -81,12 +81,12 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			mm_read_unlock(mm);
 			error = vfs_fsync(file, file->f_path.dentry, 0);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			mm_read_lock(mm);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -97,7 +97,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 out:
 	return error ? : unmapped_error;
 }
Index: mmotm-mm-accessor/mm/nommu.c
===================================================================
--- mmotm-mm-accessor.orig/mm/nommu.c
+++ mmotm-mm-accessor/mm/nommu.c
@@ -242,11 +242,11 @@ void *vmalloc_user(unsigned long size)
 	if (ret) {
 		struct vm_area_struct *vma;
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(&current->mm);
 		vma = find_vma(current->mm, (unsigned long)ret);
 		if (vma)
 			vma->vm_flags |= VM_USERMAP;
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(&current->mm);
 	}
 
 	return ret;
@@ -1591,9 +1591,9 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
 	int ret;
 	struct mm_struct *mm = current->mm;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return ret;
 }
 
@@ -1676,9 +1676,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, a
 {
 	unsigned long ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return ret;
 }
 
@@ -1881,7 +1881,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1901,7 +1901,7 @@ int access_process_vm(struct task_struct
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 	return len;
 }
Index: mmotm-mm-accessor/mm/swapfile.c
===================================================================
--- mmotm-mm-accessor.orig/mm/swapfile.c
+++ mmotm-mm-accessor/mm/swapfile.c
@@ -970,21 +970,21 @@ static int unuse_mm(struct mm_struct *mm
 	struct vm_area_struct *vma;
 	int ret = 0;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm)) {
 		/*
 		 * Activate page so shrink_inactive_list is unlikely to unmap
 		 * its ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return (ret < 0)? ret: 0;
 }
 
Index: mmotm-mm-accessor/mm/util.c
===================================================================
--- mmotm-mm-accessor.orig/mm/util.c
+++ mmotm-mm-accessor/mm/util.c
@@ -259,10 +259,10 @@ int __attribute__((weak)) get_user_pages
 	struct mm_struct *mm = current->mm;
 	int ret;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	ret = get_user_pages(current, mm, start, nr_pages,
 					write, 0, pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/ipc/shm.c
===================================================================
--- mmotm-mm-accessor.orig/ipc/shm.c
+++ mmotm-mm-accessor/ipc/shm.c
@@ -901,7 +901,7 @@ long do_shmat(int shmid, char __user *sh
 	sfd->file = shp->shm_file;
 	sfd->vm_ops = NULL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
 		if (find_vma_intersection(current->mm, addr, addr + size))
@@ -921,7 +921,7 @@ long do_shmat(int shmid, char __user *sh
 	if (IS_ERR_VALUE(user_addr))
 		err = (long)user_addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	fput(file);
 
@@ -981,7 +981,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 	/*
 	 * This function tries to be smart and unmap shm segments that
@@ -1061,7 +1061,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 
 #endif
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return retval;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
