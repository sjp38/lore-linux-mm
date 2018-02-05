Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14BBE6B0024
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d21so7764356pll.12
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8-v6si6084657plk.393.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:04 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 17/64] kernel: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:07 +0100
Message-Id: <20180205012754.23615-18-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Most of the users are already aware of mmrange, so conversion
is straightforward. For those who don't, they all use mmap_sem
in the same function context. No change in semantics.

The dup_mmap() needs two ranges, one for the new and old mms.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 kernel/acct.c               |  5 +++--
 kernel/events/core.c        |  5 +++--
 kernel/events/uprobes.c     | 17 +++++++++--------
 kernel/fork.c               | 16 ++++++++++------
 kernel/futex.c              |  4 ++--
 kernel/sched/fair.c         |  5 +++--
 kernel/trace/trace_output.c |  5 +++--
 7 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index addf7732fb56..bc8826f68002 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -538,14 +538,15 @@ void acct_collect(long exitcode, int group_dead)
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index f0549e79978b..b21d0942d225 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8264,6 +8264,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	struct mm_struct *mm = NULL;
 	unsigned int count = 0;
 	unsigned long flags;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * We may observe TASK_TOMBSTONE, which means that the event tear-down
@@ -8279,7 +8280,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	if (!mm)
 		goto restart;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	raw_spin_lock_irqsave(&ifh->lock, flags);
 	list_for_each_entry(filter, &ifh->list, entry) {
@@ -8299,7 +8300,7 @@ static void perf_event_addr_filters_apply(struct perf_event *event)
 	event->addr_filters_gen++;
 	raw_spin_unlock_irqrestore(&ifh->lock, flags);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	mmput(mm);
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 60e12b39182c..df6da03d5dc1 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -818,7 +818,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		if (err && is_register)
 			goto free;
 
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		vma = find_vma(mm, info->vaddr);
 		if (!vma || !valid_vma(vma, is_register) ||
 		    file_inode(vma->vm_file) != uprobe->inode)
@@ -842,7 +842,7 @@ register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 		}
 
  unlock:
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
  free:
 		mmput(mm);
 		info = free_map_info(info);
@@ -984,7 +984,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 	int err = 0;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		unsigned long vaddr;
 		loff_t offset;
@@ -1001,7 +1001,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 		vaddr = offset_to_vaddr(vma, uprobe->offset);
 		err |= remove_breakpoint(uprobe, mm, vaddr, &mmrange);
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return err;
 }
@@ -1150,8 +1150,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 {
 	struct vm_area_struct *vma;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	if (mm->uprobes_state.xol_area) {
@@ -1181,7 +1182,7 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
 	/* pairs with get_xol_area() */
 	smp_store_release(&mm->uprobes_state.xol_area, area); /* ^^^ */
  fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return ret;
 }
@@ -1748,7 +1749,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	struct vm_area_struct *vma;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, bp_vaddr);
 	if (vma && vma->vm_start <= bp_vaddr) {
 		if (valid_vma(vma, false)) {
@@ -1766,7 +1767,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 
 	if (!uprobe && test_and_clear_bit(MMF_RECALC_UPROBES, &mm->flags))
 		mmf_recalc_uprobes(mm);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return uprobe;
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index 2113e252cb9d..060554e33111 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -401,9 +401,11 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	int retval;
 	unsigned long charge;
 	LIST_HEAD(uf);
+	DEFINE_RANGE_LOCK_FULL(old_mmrange);
+	DEFINE_RANGE_LOCK_FULL(mmrange); /* for the new mm */
 
 	uprobe_start_dup_mmap();
-	if (down_write_killable(&oldmm->mmap_sem)) {
+	if (mm_write_lock_killable(oldmm, &old_mmrange)) {
 		retval = -EINTR;
 		goto fail_uprobe_end;
 	}
@@ -412,7 +414,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+        mm_write_lock_nested(mm, &mmrange, SINGLE_DEPTH_NESTING);
 
 	/* No ordering required: file already has been exposed. */
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
@@ -522,9 +524,9 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &old_mmrange);
 	dup_userfaultfd_complete(&uf);
 fail_uprobe_end:
 	uprobe_end_dup_mmap();
@@ -554,9 +556,11 @@ static inline void mm_free_pgd(struct mm_struct *mm)
 #else
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	down_write(&oldmm->mmap_sem);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
+	mm_write_lock(oldmm, &mmrange);
 	RCU_INIT_POINTER(mm->exe_file, get_mm_exe_file(oldmm));
-	up_write(&oldmm->mmap_sem);
+	mm_write_unlock(oldmm, &mmrange);
 	return 0;
 }
 #define mm_alloc_pgd(mm)	(0)
diff --git a/kernel/futex.c b/kernel/futex.c
index 09a0d86f80a0..6764240e87bb 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -727,10 +727,10 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
 			       FAULT_FLAG_WRITE, NULL, &mmrange);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return ret < 0 ? ret : 0;
 }
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7b6535987500..01f8c533aa21 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2470,6 +2470,7 @@ void task_numa_work(struct callback_head *work)
 	struct vm_area_struct *vma;
 	unsigned long start, end;
 	unsigned long nr_pte_updates = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 	long pages, virtpages;
 
 	SCHED_WARN_ON(p != container_of(work, struct task_struct, numa_work));
@@ -2521,7 +2522,7 @@ void task_numa_work(struct callback_head *work)
 		return;
 
 
-	if (!down_read_trylock(&mm->mmap_sem))
+	if (!mm_read_trylock(mm, &mmrange))
 		return;
 	vma = find_vma(mm, start);
 	if (!vma) {
@@ -2589,7 +2590,7 @@ void task_numa_work(struct callback_head *work)
 		mm->numa_scan_offset = start;
 	else
 		reset_ptenuma_scan(p);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Make sure tasks use at least 32x as much time to run other code
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 90db994ac900..0c3f5193de41 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -395,8 +395,9 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 
 	if (mm) {
 		const struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_vma(mm, ip);
 		if (vma) {
 			file = vma->vm_file;
@@ -408,7 +409,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 				trace_seq_printf(s, "[+0x%lx]",
 						 ip - vmstart);
 		}
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 	if (ret && ((sym_flags & TRACE_ITER_SYM_ADDR) || !file))
 		trace_seq_printf(s, " <" IP_FMT ">", ip);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
