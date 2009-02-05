Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3EDB96B004F
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:51:40 -0500 (EST)
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20090205194125.GA3129@elte.hu>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com>
	 <Pine.LNX.4.64.0901221658550.14302@blonde.anvils>
	 <8c5a844a0901221500m7af8ff45v169b6523ad9d7ad3@mail.gmail.com>
	 <20090122231358.GA27033@elte.hu>
	 <8c5a844a0901230310h7aa1ec83h60817de2b36212d8@mail.gmail.com>
	 <8c5a844a0901281331w4cea7ab2y305d5a1af96e313e@mail.gmail.com>
	 <20090129141929.GP24391@elte.hu>
	 <8c5a844a0902010319t20b853d0t6c156ecc84543f30@mail.gmail.com>
	 <20090201130058.GA486@elte.hu>
	 <8c5a844a0902050326v2155dbeaq5449f1e373f4245d@mail.gmail.com>
	 <20090205194125.GA3129@elte.hu>
Content-Type: text/plain
Date: Thu, 05 Feb 2009 20:51:30 +0100
Message-Id: <1233863490.4620.2.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Daniel Lowengrub <lowdanie@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-05 at 20:41 +0100, Ingo Molnar wrote:
> * Daniel Lowengrub <lowdanie@gmail.com> wrote:
> 
> > On Sun, Feb 1, 2009 at 3:00 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > >
> > >  you should time it:
> > >
> > >  time ./mmap-perf
> > >
> > > and compare the before/after results.
> > >
> > >        Ingo
> > >
> > 
> > I made a script that runs 'time ./mmap-perf' 100 times and outputs the
> > average.  The output on the standard kernel was:
> >
> >  real: 1.022600
> >  user: 0.135900
> >  system: 0.852600
> >
> > The output after the patch was:
> >
> >  real: 0.815400
> >  user: 0.113200
> >  system: 0.622200
> >
> > These results were consistent which isn't surprising considering the
> > fact that they themselves are averages.
> > What do you think?
> 
> Those nymbers look very convincing to me, a cool 25.4% speedup!
> mmap-perf is very MM intense - including vma lookup.

Right, except I'd rather see it using list_head than adding another
pointer.

Something like the below -- which doesn't compile, quick fwd port from
way back.

---

Subject: mm: replace vm_next with a list_head
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon Jan 26 10:02:00 CET 2009

Replace the vma list with a proper list_head.

XXX: nommu

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/kernel/osf_sys.c                |    2 
 arch/arm/mm/mmap.c                         |    2 
 arch/frv/mm/elf-fdpic.c                    |    4 
 arch/ia64/kernel/sys_ia64.c                |    2 
 arch/ia64/mm/hugetlbpage.c                 |    2 
 arch/mips/kernel/syscall.c                 |    2 
 arch/parisc/kernel/sys_parisc.c            |    4 
 arch/powerpc/mm/tlb_hash32.c               |    2 
 arch/powerpc/oprofile/cell/spu_task_sync.c |    4 
 arch/sh/mm/cache-sh4.c                     |    2 
 arch/sh/mm/mmap.c                          |    2 
 arch/sparc/kernel/sys_sparc_32.c           |    2 
 arch/sparc/kernel/sys_sparc_64.c           |    2 
 arch/sparc/mm/hugetlbpage.c                |    2 
 arch/um/kernel/tlb.c                       |   12 --
 arch/x86/kernel/sys_x86_64.c               |    2 
 arch/x86/mm/hugetlbpage.c                  |    2 
 drivers/oprofile/buffer_sync.c             |    4 
 fs/binfmt_elf.c                            |    4 
 fs/binfmt_elf_fdpic.c                      |    6 -
 fs/exec.c                                  |    6 -
 fs/hugetlbfs/inode.c                       |    2 
 fs/proc/task_mmu.c                         |   14 +--
 include/linux/init_task.h                  |    1 
 include/linux/mm.h                         |   39 ++++++++-
 include/linux/mm_types.h                   |    6 -
 ipc/shm.c                                  |    4 
 kernel/acct.c                              |    5 -
 kernel/auditsc.c                           |    4 
 kernel/fork.c                              |   12 --
 mm/madvise.c                               |    2 
 mm/memory.c                                |   14 +--
 mm/mempolicy.c                             |   12 +-
 mm/migrate.c                               |    2 
 mm/mlock.c                                 |    4 
 mm/mmap.c                                  |  125 ++++++++++++++---------------
 mm/mprotect.c                              |    2 
 mm/mremap.c                                |    7 -
 mm/msync.c                                 |    2 
 mm/swapfile.c                              |    2 
 40 files changed, 177 insertions(+), 152 deletions(-)

Index: linux-2.6-fault/drivers/oprofile/buffer_sync.c
===================================================================
--- linux-2.6-fault.orig/drivers/oprofile/buffer_sync.c
+++ linux-2.6-fault/drivers/oprofile/buffer_sync.c
@@ -227,7 +227,7 @@ static unsigned long get_exec_dcookie(st
 	if (!mm)
 		goto out;
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -252,7 +252,7 @@ lookup_dcookie(struct mm_struct *mm, uns
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
 
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma = vma_next(vma)) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
 			continue;
Index: linux-2.6-fault/fs/binfmt_elf.c
===================================================================
--- linux-2.6-fault.orig/fs/binfmt_elf.c
+++ linux-2.6-fault/fs/binfmt_elf.c
@@ -1875,7 +1875,7 @@ static void free_note_info(struct elf_no
 static struct vm_area_struct *first_vma(struct task_struct *tsk,
 					struct vm_area_struct *gate_vma)
 {
-	struct vm_area_struct *ret = tsk->mm->mmap;
+	struct vm_area_struct *ret = __vma_next(&tsk->mm->mm_vmas, NULL);
 
 	if (ret)
 		return ret;
@@ -1890,7 +1890,7 @@ static struct vm_area_struct *next_vma(s
 {
 	struct vm_area_struct *ret;
 
-	ret = this_vma->vm_next;
+	ret = vma_next(this_vma);
 	if (ret)
 		return ret;
 	if (this_vma == gate_vma)
Index: linux-2.6-fault/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6-fault.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6-fault/fs/binfmt_elf_fdpic.c
@@ -1506,7 +1506,7 @@ static int elf_fdpic_dump_segments(struc
 {
 	struct vm_area_struct *vma;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned long addr;
 
 		if (!maydump(vma, mm_flags))
@@ -1561,7 +1561,7 @@ static int elf_fdpic_dump_segments(struc
 {
 	struct vm_area_struct *vma;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		if (!maydump(vma, mm_flags))
 			continue;
 
@@ -1747,7 +1747,7 @@ static int elf_fdpic_core_dump(long sign
 	mm_flags = current->mm->flags;
 
 	/* write program headers for segments dump */
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		struct elf_phdr phdr;
 		size_t sz;
 
Index: linux-2.6-fault/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6-fault.orig/fs/hugetlbfs/inode.c
+++ linux-2.6-fault/fs/hugetlbfs/inode.c
@@ -162,7 +162,7 @@ hugetlb_get_unmapped_area(struct file *f
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6-fault/fs/proc/task_mmu.c
===================================================================
--- linux-2.6-fault.orig/fs/proc/task_mmu.c
+++ linux-2.6-fault/fs/proc/task_mmu.c
@@ -126,7 +126,7 @@ static void *m_start(struct seq_file *m,
 	/* Start with last addr hint */
 	vma = find_vma(mm, last_addr);
 	if (last_addr && vma) {
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 		goto out;
 	}
 
@@ -136,9 +136,9 @@ static void *m_start(struct seq_file *m,
 	 */
 	vma = NULL;
 	if ((unsigned long)l < mm->map_count) {
-		vma = mm->mmap;
+		vma = __vma_next(&mm->mm_vmas, NULL);
 		while (l-- && vma)
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		goto out;
 	}
 
@@ -159,12 +159,12 @@ out:
 static void *m_next(struct seq_file *m, void *v, loff_t *pos)
 {
 	struct proc_maps_private *priv = m->private;
-	struct vm_area_struct *vma = v;
+	struct vm_area_struct *vma = v, *next;
 	struct vm_area_struct *tail_vma = priv->tail_vma;
 
 	(*pos)++;
-	if (vma && (vma != tail_vma) && vma->vm_next)
-		return vma->vm_next;
+	if (vma && (vma != tail_vma) && (next = vma_next(vma)))
+		return next;
 	vma_stop(priv, vma);
 	return (vma != tail_vma)? tail_vma: NULL;
 }
@@ -489,7 +489,7 @@ static ssize_t clear_refs_write(struct f
 			.mm = mm,
 		};
 		down_read(&mm->mmap_sem);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 			clear_refs_walk.private = vma;
 			if (!is_vm_hugetlb_page(vma))
 				walk_page_range(vma->vm_start, vma->vm_end,
Index: linux-2.6-fault/ipc/shm.c
===================================================================
--- linux-2.6-fault.orig/ipc/shm.c
+++ linux-2.6-fault/ipc/shm.c
@@ -992,7 +992,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 
 #ifdef CONFIG_MMU
 	while (vma) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/*
 		 * Check if the starting address would match, i.e. it's
@@ -1025,7 +1025,7 @@ SYSCALL_DEFINE1(shmdt, char __user *, sh
 	 */
 	size = PAGE_ALIGN(size);
 	while (vma && (loff_t)(vma->vm_end - addr) <= size) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 
 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops) &&
Index: linux-2.6-fault/kernel/acct.c
===================================================================
--- linux-2.6-fault.orig/kernel/acct.c
+++ linux-2.6-fault/kernel/acct.c
@@ -601,11 +601,8 @@ void acct_collect(long exitcode, int gro
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
 		down_read(&current->mm->mmap_sem);
-		vma = current->mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &current->mm->mm_vmas, vm_list)
 			vsize += vma->vm_end - vma->vm_start;
-			vma = vma->vm_next;
-		}
 		up_read(&current->mm->mmap_sem);
 	}
 
Index: linux-2.6-fault/kernel/auditsc.c
===================================================================
--- linux-2.6-fault.orig/kernel/auditsc.c
+++ linux-2.6-fault/kernel/auditsc.c
@@ -959,15 +959,13 @@ static void audit_log_task_info(struct a
 
 	if (mm) {
 		down_read(&mm->mmap_sem);
-		vma = mm->mmap;
-		while (vma) {
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
 			    vma->vm_file) {
 				audit_log_d_path(ab, "exe=",
 						 &vma->vm_file->f_path);
 				break;
 			}
-			vma = vma->vm_next;
 		}
 		up_read(&mm->mmap_sem);
 	}
Index: linux-2.6-fault/mm/madvise.c
===================================================================
--- linux-2.6-fault.orig/mm/madvise.c
+++ linux-2.6-fault/mm/madvise.c
@@ -351,7 +351,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, 
 		if (start >= end)
 			goto out;
 		if (prev)
-			vma = prev->vm_next;
+			vma = vma_next(prev);
 		else	/* madvise_remove dropped mmap_sem */
 			vma = find_vma(current->mm, start);
 	}
Index: linux-2.6-fault/mm/memory.c
===================================================================
--- linux-2.6-fault.orig/mm/memory.c
+++ linux-2.6-fault/mm/memory.c
@@ -274,11 +274,12 @@ void free_pgd_range(struct mmu_gather *t
 	} while (pgd++, addr = next, addr != end);
 }
 
-void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
+void free_pgtables(struct mmu_gather *tlb, struct list_head *vmas,
+		struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
-		struct vm_area_struct *next = vma->vm_next;
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		unsigned long addr = vma->vm_start;
 
 		/*
@@ -297,7 +298,7 @@ void free_pgtables(struct mmu_gather *tl
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
-				next = vma->vm_next;
+				next = __vma_next(vmas, vma);
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
@@ -955,7 +956,7 @@ static unsigned long unmap_page_range(st
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
+unsigned long unmap_vmas(struct mmu_gather **tlbp, struct list_head *vmas,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
@@ -969,7 +970,7 @@ unsigned long unmap_vmas(struct mmu_gath
 	struct mm_struct *mm = vma->vm_mm;
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end_addr; vma = vma_next(vma)) {
 		unsigned long end;
 
 		start = max(vma->vm_start, start_addr);
@@ -1058,7 +1059,8 @@ unsigned long zap_page_range(struct vm_a
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, &vma->vm_mm->mm_vmas, vma,
+			address, end, &nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
Index: linux-2.6-fault/mm/mempolicy.c
===================================================================
--- linux-2.6-fault.orig/mm/mempolicy.c
+++ linux-2.6-fault/mm/mempolicy.c
@@ -342,7 +342,7 @@ void mpol_rebind_mm(struct mm_struct *mm
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		mpol_rebind_policy(vma->vm_policy, new);
 	up_write(&mm->mmap_sem);
 }
@@ -494,9 +494,9 @@ check_range(struct mm_struct *mm, unsign
 	if (!first)
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for (vma = first; vma && vma->vm_start < end; vma = vma_next(vma)) {
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
+			if (!vma_next(vma) && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
@@ -553,7 +553,7 @@ static int mbind_range(struct vm_area_st
 
 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);
 		if (!err && vma->vm_end > end)
@@ -784,7 +784,7 @@ static int migrate_to_node(struct mm_str
 	nodes_clear(nmask);
 	node_set(source, nmask);
 
-	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
+	check_range(mm, __vma_next(&mm->mm_vmas, NULL)->vm_start, TASK_SIZE, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
 	if (!list_empty(&pagelist))
@@ -899,7 +899,7 @@ static struct page *new_vma_page(struct 
 		address = page_address_in_vma(page, vma);
 		if (address != -EFAULT)
 			break;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 
 	/*
Index: linux-2.6-fault/mm/mlock.c
===================================================================
--- linux-2.6-fault.orig/mm/mlock.c
+++ linux-2.6-fault/mm/mlock.c
@@ -521,7 +521,7 @@ static int do_mlock(unsigned long start,
 		if (nstart >= end)
 			break;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			break;
@@ -581,7 +581,7 @@ static int do_mlockall(int flags)
 	if (flags == MCL_FUTURE)
 		goto out;
 
-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned int newflags;
 
 		newflags = vma->vm_flags | VM_LOCKED;
Index: linux-2.6-fault/mm/mprotect.c
===================================================================
--- linux-2.6-fault.orig/mm/mprotect.c
+++ linux-2.6-fault/mm/mprotect.c
@@ -305,7 +305,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		if (nstart >= end)
 			goto out;
 
-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			goto out;
Index: linux-2.6-fault/mm/mremap.c
===================================================================
--- linux-2.6-fault.orig/mm/mremap.c
+++ linux-2.6-fault/mm/mremap.c
@@ -234,7 +234,7 @@ static unsigned long move_vma(struct vm_
 	if (excess) {
 		vma->vm_flags |= VM_ACCOUNT;
 		if (split)
-			vma->vm_next->vm_flags |= VM_ACCOUNT;
+			vma_next(vma)->vm_flags |= VM_ACCOUNT;
 	}
 
 	if (vm_flags & VM_LOCKED) {
@@ -368,8 +368,9 @@ unsigned long do_mremap(unsigned long ad
 	    !((flags & MREMAP_FIXED) && (addr != new_addr)) &&
 	    (old_len != new_len || !(flags & MREMAP_MAYMOVE))) {
 		unsigned long max_addr = TASK_SIZE;
-		if (vma->vm_next)
-			max_addr = vma->vm_next->vm_start;
+		struct vm_area_struct *next = vma_next(vma);
+		if (next)
+			max_addr = next->vm_start;
 		/* can we just expand the current mapping? */
 		if (max_addr - addr >= new_len) {
 			int pages = (new_len - old_len) >> PAGE_SHIFT;
Index: linux-2.6-fault/mm/msync.c
===================================================================
--- linux-2.6-fault.orig/mm/msync.c
+++ linux-2.6-fault/mm/msync.c
@@ -93,7 +93,7 @@ SYSCALL_DEFINE3(msync, unsigned long, st
 				error = 0;
 				goto out_unlock;
 			}
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		}
 	}
 out_unlock:
Index: linux-2.6-fault/mm/swapfile.c
===================================================================
--- linux-2.6-fault.orig/mm/swapfile.c
+++ linux-2.6-fault/mm/swapfile.c
@@ -848,7 +848,7 @@ static int unuse_mm(struct mm_struct *mm
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
 	}
Index: linux-2.6-fault/mm/migrate.c
===================================================================
--- linux-2.6-fault.orig/mm/migrate.c
+++ linux-2.6-fault/mm/migrate.c
@@ -1129,7 +1129,7 @@ int migrate_vmas(struct mm_struct *mm, c
  	struct vm_area_struct *vma;
  	int err = 0;
 
- 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)
Index: linux-2.6-fault/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-2.6-fault.orig/arch/alpha/kernel/osf_sys.c
+++ linux-2.6-fault/arch/alpha/kernel/osf_sys.c
@@ -1197,7 +1197,7 @@ arch_get_unmapped_area_1(unsigned long a
 		if (!vma || addr + len <= vma->vm_start)
 			return addr;
 		addr = vma->vm_end;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 }
 
Index: linux-2.6-fault/arch/arm/mm/mmap.c
===================================================================
--- linux-2.6-fault.orig/arch/arm/mm/mmap.c
+++ linux-2.6-fault/arch/arm/mm/mmap.c
@@ -86,7 +86,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6-fault/arch/frv/mm/elf-fdpic.c
===================================================================
--- linux-2.6-fault.orig/arch/frv/mm/elf-fdpic.c
+++ linux-2.6-fault/arch/frv/mm/elf-fdpic.c
@@ -86,7 +86,7 @@ unsigned long arch_get_unmapped_area(str
 
 		if (addr <= limit) {
 			vma = find_vma(current->mm, PAGE_SIZE);
-			for (; vma; vma = vma->vm_next) {
+			for (; vma; vma = vma_next(vma)) {
 				if (addr > limit)
 					break;
 				if (addr + len <= vma->vm_start)
@@ -101,7 +101,7 @@ unsigned long arch_get_unmapped_area(str
 	limit = TASK_SIZE - len;
 	if (addr <= limit) {
 		vma = find_vma(current->mm, addr);
-		for (; vma; vma = vma->vm_next) {
+		for (; vma; vma = vma_next(vma)) {
 			if (addr > limit)
 				break;
 			if (addr + len <= vma->vm_start)
Index: linux-2.6-fault/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-2.6-fault.orig/arch/ia64/kernel/sys_ia64.c
+++ linux-2.6-fault/arch/ia64/kernel/sys_ia64.c
@@ -58,7 +58,7 @@ arch_get_unmapped_area (struct file *fil
   full_search:
 	start_addr = addr = (addr + align_mask) & ~align_mask;
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr || RGN_MAP_LIMIT - len < REGION_OFFSET(addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
Index: linux-2.6-fault/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-2.6-fault.orig/arch/ia64/mm/hugetlbpage.c
+++ linux-2.6-fault/arch/ia64/mm/hugetlbpage.c
@@ -168,7 +168,7 @@ unsigned long hugetlb_get_unmapped_area(
 		addr = HPAGE_REGION_BASE;
 	else
 		addr = ALIGN(addr, HPAGE_SIZE);
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vma)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (REGION_OFFSET(addr) + len > RGN_MAP_LIMIT)
 			return -ENOMEM;
Index: linux-2.6-fault/arch/mips/kernel/syscall.c
===================================================================
--- linux-2.6-fault.orig/arch/mips/kernel/syscall.c
+++ linux-2.6-fault/arch/mips/kernel/syscall.c
@@ -115,7 +115,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (task_size - len < addr)
 			return -ENOMEM;
Index: linux-2.6-fault/arch/parisc/kernel/sys_parisc.c
===================================================================
--- linux-2.6-fault.orig/arch/parisc/kernel/sys_parisc.c
+++ linux-2.6-fault/arch/parisc/kernel/sys_parisc.c
@@ -39,7 +39,7 @@ static unsigned long get_unshared_area(u
 
 	addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
@@ -75,7 +75,7 @@ static unsigned long get_shared_area(str
 
 	addr = DCACHE_ALIGN(addr - offset) + offset;
 
-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
Index: linux-2.6-fault/arch/sh/mm/cache-sh4.c
===================================================================
--- linux-2.6-fault.orig/arch/sh/mm/cache-sh4.c
+++ linux-2.6-fault/arch/sh/mm/cache-sh4.c
@@ -402,7 +402,7 @@ void flush_cache_mm(struct mm_struct *mm
 		 * In this case there are reasonably sized ranges to flush,
 		 * iterate through the VMA list and take care of any aliases.
 		 */
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 			__flush_cache_mm(mm, vma->vm_start, vma->vm_end);
 	}
 
Index: linux-2.6-fault/include/linux/init_task.h
===================================================================
--- linux-2.6-fault.orig/include/linux/init_task.h
+++ linux-2.6-fault/include/linux/init_task.h
@@ -29,6 +29,7 @@ extern struct fs_struct init_fs;
 
 #define INIT_MM(name) \
 {			 					\
+	.mm_vmas	= LIST_HEAD_INIT(name.mm_vmas),		\
 	.mm_rb		= RB_ROOT,				\
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
Index: linux-2.6-fault/include/linux/mm.h
===================================================================
--- linux-2.6-fault.orig/include/linux/mm.h
+++ linux-2.6-fault/include/linux/mm.h
@@ -36,6 +36,7 @@ extern int sysctl_legacy_va_layout;
 
 extern unsigned long mmap_min_addr;
 
+#include <linux/sched.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -220,6 +221,42 @@ struct vm_operations_struct {
 #endif
 };
 
+static inline struct vm_area_struct *
+__vma_next(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.next == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.next, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_next(struct vm_area_struct *vma)
+{
+	return __vma_next(&vma->vm_mm->mm_vmas, vma);
+}
+
+static inline struct vm_area_struct *
+__vma_prev(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+
+	if (vma->vm_list.prev == head)
+		return NULL;
+
+	return list_entry(vma->vm_list.prev, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_prev(struct vm_area_struct *vma)
+{
+	return __vma_prev(&vma->vm_mm->mm_vmas, vma);
+}
+
 struct mmu_gather;
 struct inode;
 
@@ -759,7 +796,7 @@ int zap_vma_ptes(struct vm_area_struct *
 		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather **tlb, struct list_head *vmas,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
Index: linux-2.6-fault/kernel/fork.c
===================================================================
--- linux-2.6-fault.orig/kernel/fork.c
+++ linux-2.6-fault/kernel/fork.c
@@ -265,7 +265,7 @@ out:
 #ifdef CONFIG_MMU
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, **pprev;
+	struct vm_area_struct *mpnt, *tmp;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
@@ -279,7 +279,6 @@ static int dup_mmap(struct mm_struct *mm
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
-	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
@@ -288,9 +287,8 @@ static int dup_mmap(struct mm_struct *mm
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
-	pprev = &mm->mmap;
 
-	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
+	list_for_each_entry(mpnt, &oldmm->mm_vmas, vm_list) {
 		struct file *file;
 
 		if (mpnt->vm_flags & VM_DONTCOPY) {
@@ -318,7 +316,6 @@ static int dup_mmap(struct mm_struct *mm
 		vma_set_policy(tmp, pol);
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
-		tmp->vm_next = NULL;
 		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
@@ -350,9 +347,7 @@ static int dup_mmap(struct mm_struct *mm
 		/*
 		 * Link in the new vma and copy the page table entries.
 		 */
-		*pprev = tmp;
-		pprev = &tmp->vm_next;
-
+		list_add_tail(&tmp->vm_list, &mm->mm_vmas);
 		__vma_link_rb(mm, tmp, rb_link, rb_parent);
 		rb_link = &tmp->vm_rb.rb_right;
 		rb_parent = &tmp->vm_rb;
@@ -421,6 +416,7 @@ __setup("coredump_filter=", coredump_fil
 
 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
+	INIT_LIST_HEAD(&mm->mm_vmas);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
Index: linux-2.6-fault/mm/mmap.c
===================================================================
--- linux-2.6-fault.orig/mm/mmap.c
+++ linux-2.6-fault/mm/mmap.c
@@ -43,7 +43,7 @@
 #define arch_rebalance_pgtables(addr, len)		(addr)
 #endif
 
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
@@ -228,11 +228,10 @@ void unlink_file_vma(struct vm_area_stru
 /*
  * Close a vm structure and free it, returning the next.
  */
-static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
+static void remove_vma(struct vm_area_struct *vma)
 {
-	struct vm_area_struct *next = vma->vm_next;
-
 	might_sleep();
+	list_del(&vma->vm_list);
 	if (vma->vm_ops && vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file) {
@@ -242,7 +241,6 @@ static struct vm_area_struct *remove_vma
 	}
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
-	return next;
 }
 
 SYSCALL_DEFINE1(brk, unsigned long, brk)
@@ -334,11 +332,9 @@ void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
-	struct vm_area_struct *tmp = mm->mmap;
-	while (tmp) {
-		tmp = tmp->vm_next;
+	struct vm_area_struct *vma;
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		i++;
-	}
 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
 	i = browse_rb(&mm->mm_rb);
@@ -392,15 +388,15 @@ __vma_link_list(struct mm_struct *mm, st
 		struct vm_area_struct *prev, struct rb_node *rb_parent)
 {
 	if (prev) {
-		vma->vm_next = prev->vm_next;
-		prev->vm_next = vma;
+		list_add(&vma->vm_list, &prev->vm_list);
 	} else {
-		mm->mmap = vma;
-		if (rb_parent)
-			vma->vm_next = rb_entry(rb_parent,
+		if (rb_parent) {
+			struct vm_area_struct *next =
+				rb_entry(rb_parent,
 					struct vm_area_struct, vm_rb);
-		else
-			vma->vm_next = NULL;
+			list_add_tail(&vma->vm_list, &next->vm_list);
+		} else
+			list_add(&vma->vm_list, &mm->mm_vmas);
 	}
 }
 
@@ -489,7 +485,7 @@ static inline void
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
-	prev->vm_next = vma->vm_next;
+	list_del(&vma->vm_list);
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
@@ -506,7 +502,7 @@ void vma_adjust(struct vm_area_struct *v
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct vm_area_struct *next = vma->vm_next;
+	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
@@ -650,7 +646,7 @@ again:			remove_next = 1 + (end > next->
 		 * up the code too much to do both in one go.
 		 */
 		if (remove_next == 2) {
-			next = vma->vm_next;
+			next = vma_next(vma);
 			goto again;
 		}
 	}
@@ -769,13 +765,10 @@ struct vm_area_struct *vma_merge(struct 
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
-	if (prev)
-		next = prev->vm_next;
-	else
-		next = mm->mmap;
+	next = __vma_next(&mm->mm_vmas, prev);
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
-		next = next->vm_next;
+		next = vma_next(next);
 
 	/*
 	 * Can it merge with the predecessor?
@@ -834,7 +827,7 @@ struct anon_vma *find_mergeable_anon_vma
 	struct vm_area_struct *near;
 	unsigned long vm_flags;
 
-	near = vma->vm_next;
+	near = vma_next(vma);
 	if (!near)
 		goto try_prev;
 
@@ -917,6 +910,7 @@ unsigned long do_mmap_pgoff(struct file 
 	int error;
 	int accountable = 1;
 	unsigned long reqprot = prot;
+	LIST_HEAD(vmas);
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1243,7 +1237,8 @@ unmap_and_free_vma:
 	fput(file);
 
 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	list_add(&vma->vm_list, &vmas);
+	unmap_region(mm, &vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1294,7 +1289,7 @@ arch_get_unmapped_area(struct file *filp
 	}
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1505,14 +1500,11 @@ struct vm_area_struct *
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *vma = NULL, *prev = NULL;
+	struct vm_area_struct *prev = NULL, *next;
 	struct rb_node *rb_node;
 	if (!mm)
 		goto out;
 
-	/* Guard against addr being lower than the first VMA */
-	vma = mm->mmap;
-
 	/* Go through the RB tree quickly. */
 	rb_node = mm->mm_rb.rb_node;
 
@@ -1524,7 +1516,8 @@ find_vma_prev(struct mm_struct *mm, unsi
 			rb_node = rb_node->rb_left;
 		} else {
 			prev = vma_tmp;
-			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
+			next = __vma_next(&mm->mm_vmas, prev);
+			if (!next || (addr < next->vm_end))
 				break;
 			rb_node = rb_node->rb_right;
 		}
@@ -1532,7 +1525,7 @@ find_vma_prev(struct mm_struct *mm, unsi
 
 out:
 	*pprev = prev;
-	return prev ? prev->vm_next : vma;
+	return __vma_next(&mm->mm_vmas, prev);
 }
 
 /*
@@ -1748,16 +1741,19 @@ find_extend_vma(struct mm_struct * mm, u
  *
  * Called with the mm semaphore held.
  */
-static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
+static void remove_vma_list(struct mm_struct *mm, struct list_head *vmas,
+		struct vm_area_struct *vma)
 {
 	/* Update high watermark before we lower total_vm */
 	update_hiwater_vm(mm);
 	do {
+		struct vm_area_struct *next = __vma_next(vmas, vma);
 		long nrpages = vma_pages(vma);
 
 		mm->total_vm -= nrpages;
 		vm_stat_account(mm, vma->vm_flags, vma->vm_file, -nrpages);
-		vma = remove_vma(vma);
+		remove_vma(vma);
+		vma = next;
 	} while (vma);
 	validate_mm(mm);
 }
@@ -1767,21 +1763,22 @@ static void remove_vma_list(struct mm_st
  *
  * Called with the mm semaphore held.
  */
-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end)
 {
-	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
+	struct vm_area_struct *next = __vma_next(&mm->mm_vmas, prev);
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
+	unmap_vmas(&tlb, vmas, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
-				 next? next->vm_start: 0);
+	free_pgtables(tlb, vmas, vma,
+			prev ? prev->vm_end : FIRST_USER_ADDRESS,
+			next ? next->vm_start : 0);
 	tlb_finish_mmu(tlb, start, end);
 }
 
@@ -1791,21 +1788,18 @@ static void unmap_region(struct mm_struc
  */
 static void
 detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, unsigned long end)
+	       struct vm_area_struct *prev, unsigned long end,
+	       struct list_head *vmas)
 {
-	struct vm_area_struct **insertion_point;
-	struct vm_area_struct *tail_vma = NULL;
 	unsigned long addr;
 
-	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
+		struct vm_area_struct *next = vma_next(vma);
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
 		mm->map_count--;
-		tail_vma = vma;
-		vma = vma->vm_next;
+		list_move_tail(&vma->vm_list, vmas);
+		vma = next;
 	} while (vma && vma->vm_start < end);
-	*insertion_point = vma;
-	tail_vma->vm_next = NULL;
 	if (mm->unmap_area == arch_unmap_area)
 		addr = prev ? prev->vm_end : mm->mmap_base;
 	else
@@ -1879,6 +1873,7 @@ int do_munmap(struct mm_struct *mm, unsi
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
+	LIST_HEAD(vmas);
 
 	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
@@ -1918,7 +1913,7 @@ int do_munmap(struct mm_struct *mm, unsi
 		if (error)
 			return error;
 	}
-	vma = prev? prev->vm_next: mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, prev);
 
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
@@ -1930,18 +1925,18 @@ int do_munmap(struct mm_struct *mm, unsi
 				mm->locked_vm -= vma_pages(tmp);
 				munlock_vma_pages_all(tmp);
 			}
-			tmp = tmp->vm_next;
+			tmp = vma_next(tmp);
 		}
 	}
 
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
-	detach_vmas_to_be_unmapped(mm, vma, prev, end);
-	unmap_region(mm, vma, prev, start, end);
+	detach_vmas_to_be_unmapped(mm, vma, prev, end, &vmas);
+	unmap_region(mm, &vmas, vma, prev, start, end);
 
 	/* Fix up all other VM information */
-	remove_vma_list(mm, vma);
+	remove_vma_list(mm, &vmas, vma);
 
 	return 0;
 }
@@ -2082,7 +2077,8 @@ EXPORT_SYMBOL(do_brk);
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma;
+	LIST_HEAD(vmas);
+	struct vm_area_struct *vma, *next;
 	unsigned long nr_accounted = 0;
 	unsigned long end;
 
@@ -2094,30 +2090,31 @@ void exit_mmap(struct mm_struct *mm)
 		return;
 
 	if (mm->locked_vm) {
-		vma = mm->mmap;
+		vma = __vma_next(&mm->mm_vmas, NULL);
 		while (vma) {
 			if (vma->vm_flags & VM_LOCKED)
 				munlock_vma_pages_all(vma);
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		}
 	}
-	vma = mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, NULL);
 	lru_add_drain();
 	flush_cache_mm(mm);
+	detach_vmas_to_be_unmapped(mm, vma, NULL, -1, &vmas);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = unmap_vmas(&tlb, &vmas, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(tlb, &vmas, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
 	 * with preemption enabled, without holding any MM locks.
 	 */
-	while (vma)
-		vma = remove_vma(vma);
+	list_for_each_entry_safe(vma, next, &vmas, vm_list)
+		remove_vma(vma);
 
 	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
@@ -2393,14 +2390,14 @@ int mm_take_all_locks(struct mm_struct *
 
 	mutex_lock(&mm_all_locks_mutex);
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (signal_pending(current))
 			goto out_unlock;
 		if (vma->vm_file && vma->vm_file->f_mapping)
 			vm_lock_mapping(mm, vma->vm_file->f_mapping);
 	}
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (signal_pending(current))
 			goto out_unlock;
 		if (vma->anon_vma)
@@ -2463,7 +2460,7 @@ void mm_drop_all_locks(struct mm_struct 
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma)
 			vm_unlock_anon_vma(vma->anon_vma);
 		if (vma->vm_file && vma->vm_file->f_mapping)
Index: linux-2.6-fault/arch/powerpc/mm/tlb_hash32.c
===================================================================
--- linux-2.6-fault.orig/arch/powerpc/mm/tlb_hash32.c
+++ linux-2.6-fault/arch/powerpc/mm/tlb_hash32.c
@@ -157,7 +157,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 	 * unmap_region or exit_mmap, but not from vmtruncate on SMP -
 	 * but it seems dup_mmap is the only SMP case which gets here.
 	 */
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
Index: linux-2.6-fault/arch/powerpc/oprofile/cell/spu_task_sync.c
===================================================================
--- linux-2.6-fault.orig/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ linux-2.6-fault/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -329,7 +329,7 @@ get_exec_dcookie_and_offset(struct spu *
 
 	down_read(&mm->mmap_sem);
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -341,7 +341,7 @@ get_exec_dcookie_and_offset(struct spu *
 		break;
 	}
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
 		my_offset = spu_ref - vma->vm_start;
Index: linux-2.6-fault/arch/sh/mm/mmap.c
===================================================================
--- linux-2.6-fault.orig/arch/sh/mm/mmap.c
+++ linux-2.6-fault/arch/sh/mm/mmap.c
@@ -74,7 +74,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(mm->free_area_cache);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (unlikely(TASK_SIZE - len < addr)) {
 			/*
Index: linux-2.6-fault/arch/sparc/kernel/sys_sparc_32.c
===================================================================
--- linux-2.6-fault.orig/arch/sparc/kernel/sys_sparc_32.c
+++ linux-2.6-fault/arch/sparc/kernel/sys_sparc_32.c
@@ -63,7 +63,7 @@ unsigned long arch_get_unmapped_area(str
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (ARCH_SUN4C && addr < 0xe0000000 && 0x20000000 - len < addr) {
 			addr = PAGE_OFFSET;
Index: linux-2.6-fault/arch/sparc/kernel/sys_sparc_64.c
===================================================================
--- linux-2.6-fault.orig/arch/sparc/kernel/sys_sparc_64.c
+++ linux-2.6-fault/arch/sparc/kernel/sys_sparc_64.c
@@ -167,7 +167,7 @@ full_search:
 	else
 		addr = PAGE_ALIGN(addr);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
Index: linux-2.6-fault/arch/sparc/mm/hugetlbpage.c
===================================================================
--- linux-2.6-fault.orig/arch/sparc/mm/hugetlbpage.c
+++ linux-2.6-fault/arch/sparc/mm/hugetlbpage.c
@@ -54,7 +54,7 @@ static unsigned long hugetlb_get_unmappe
 full_search:
 	addr = ALIGN(addr, HPAGE_SIZE);
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
Index: linux-2.6-fault/arch/um/kernel/tlb.c
===================================================================
--- linux-2.6-fault.orig/arch/um/kernel/tlb.c
+++ linux-2.6-fault/arch/um/kernel/tlb.c
@@ -515,21 +515,17 @@ void flush_tlb_mm_range(struct mm_struct
 
 void flush_tlb_mm(struct mm_struct *mm)
 {
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 
-	while (vma != NULL) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		fix_range(mm, vma->vm_start, vma->vm_end, 0);
-		vma = vma->vm_next;
-	}
 }
 
 void force_flush_all(void)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma = mm->mmap;
+	struct vm_area_struct *vma;
 
-	while (vma != NULL) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		fix_range(mm, vma->vm_start, vma->vm_end, 1);
-		vma = vma->vm_next;
-	}
 }
Index: linux-2.6-fault/arch/x86/kernel/sys_x86_64.c
===================================================================
--- linux-2.6-fault.orig/arch/x86/kernel/sys_x86_64.c
+++ linux-2.6-fault/arch/x86/kernel/sys_x86_64.c
@@ -107,7 +107,7 @@ arch_get_unmapped_area(struct file *filp
 	start_addr = addr;
 
 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (end - len < addr) {
 			/*
Index: linux-2.6-fault/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6-fault.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6-fault/arch/x86/mm/hugetlbpage.c
@@ -275,7 +275,7 @@ static unsigned long hugetlb_get_unmappe
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));
 
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
Index: linux-2.6-fault/fs/exec.c
===================================================================
--- linux-2.6-fault.orig/fs/exec.c
+++ linux-2.6-fault/fs/exec.c
@@ -510,6 +510,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	struct vm_area_struct *next;
 	struct mmu_gather *tlb;
 
 	BUG_ON(new_start > new_end);
@@ -536,12 +537,13 @@ static int shift_arg_pages(struct vm_are
 
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
+	next = vma_next(vma);
 	if (new_end > old_start) {
 		/*
 		 * when the old and new regions overlap clear from new_end.
 		 */
 		free_pgd_range(tlb, new_end, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			next ? next->vm_start : 0);
 	} else {
 		/*
 		 * otherwise, clean from old_start; this is done to not touch
@@ -550,7 +552,7 @@ static int shift_arg_pages(struct vm_are
 		 * for the others its just a little faster.
 		 */
 		free_pgd_range(tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			next ? next->vm_start : 0);
 	}
 	tlb_finish_mmu(tlb, new_end, old_end);
 
Index: linux-2.6-fault/include/linux/mm_types.h
===================================================================
--- linux-2.6-fault.orig/include/linux/mm_types.h
+++ linux-2.6-fault/include/linux/mm_types.h
@@ -134,13 +134,11 @@ struct vm_area_struct {
 					   within vm_mm. */
 
 	/* linked list of VM areas per task, sorted by address */
-	struct vm_area_struct *vm_next;
+	struct list_head vm_list;
 
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
 
-	struct rb_node vm_rb;
-
 	/*
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap prio tree, or
@@ -196,7 +194,7 @@ struct core_state {
 };
 
 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct list_head mm_vmas;
 	struct rb_root mm_rb;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
