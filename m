Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id D05CF6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 13:45:33 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id x13so3152654qcv.36
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 10:45:33 -0700 (PDT)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id 18si26717954qgn.94.2014.08.12.10.45.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 Aug 2014 10:45:32 -0700 (PDT)
Message-ID: <1407865523.2633.3.camel@buesod1.americas.hpqcorp.net>
Subject: [PATCH] mm: introduce for_each_vma helpers
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 12 Aug 2014 10:45:23 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Robert Richter <rric@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, davidlohr@hp.com, aswin@hp.com

The most common way of iterating through the list of vmas, is via:
    for (vma = mm->mmap; vma; vma = vma->vm_next)

This patch replaces this logic with a new for_each_vma(vma) helper,
which 1) encapsulates this logic, and 2) make it easier to read.
It also updates most of the callers, so its a pretty good start.

Similarly, we also have for_each_vma_start(vma, start) when the user
does not want to start at the beginning of the list. And lastly the
for_each_vma_start_inc(vma, start, inc) helper in introduced to allow
users to create higher level special vma abstractions, such as with
the case of ELF binaries.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Robert Richter <rric@kernel.org>
---
Tested on x86-64, survives multiple kernel builds.
Not tested: nommu, s390, parisc, powerpc, oprofile.
Applies on Linus' latest.

 arch/parisc/kernel/cache.c                 |  6 +++---
 arch/powerpc/oprofile/cell/spu_task_sync.c |  2 +-
 arch/s390/mm/pgtable.c                     |  2 +-
 drivers/oprofile/buffer_sync.c             |  3 +--
 fs/binfmt_elf.c                            | 17 ++++++++++-------
 fs/binfmt_elf_fdpic.c                      | 18 +++++++++++-------
 fs/proc/base.c                             |  5 ++---
 fs/proc/task_mmu.c                         |  3 ++-
 include/linux/mm.h                         |  9 +++++++++
 kernel/events/uprobes.c                    |  4 ++--
 kernel/sys.c                               |  2 +-
 mm/ksm.c                                   |  2 +-
 mm/memcontrol.c                            |  9 ++++++---
 mm/mempolicy.c                             |  2 +-
 mm/migrate.c                               |  4 +++-
 mm/mlock.c                                 |  9 +++++----
 mm/mmap.c                                  |  8 ++++----
 mm/nommu.c                                 |  4 ++--
 mm/swapfile.c                              |  3 ++-
 19 files changed, 67 insertions(+), 45 deletions(-)

diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index f6448c7..7222b49 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -462,7 +462,7 @@ static inline unsigned long mm_total_size(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	unsigned long usize = 0;
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for_each_vma(vma)
 		usize += vma->vm_end - vma->vm_start;
 	return usize;
 }
@@ -495,7 +495,7 @@ void flush_cache_mm(struct mm_struct *mm)
 	}
 
 	if (mm->context == mfsp(3)) {
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		for_each_vma(vma) {
 			flush_user_dcache_range_asm(vma->vm_start, vma->vm_end);
 			if ((vma->vm_flags & VM_EXEC) == 0)
 				continue;
@@ -505,7 +505,7 @@ void flush_cache_mm(struct mm_struct *mm)
 	}
 
 	pgd = mm->pgd;
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		unsigned long addr;
 
 		for (addr = vma->vm_start; addr < vma->vm_end;
diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 28f1af2..862d076 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -335,7 +335,7 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 			 mm->exe_file->f_dentry->d_name.name);
 	}
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
 		my_offset = spu_ref - vma->vm_start;
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 19daa53..d57a614 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1260,7 +1260,7 @@ static inline void thp_split_mm(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 
-	for (vma = mm->mmap; vma != NULL; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		thp_split_vma(vma);
 		vma->vm_flags &= ~VM_HUGEPAGE;
 		vma->vm_flags |= VM_NOHUGEPAGE;
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index d93b2b6..415a0c0 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -243,8 +243,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
 
-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
-
+	for_each_vma_start(vma, find_vma(mm, addr)) {
 		if (addr < vma->vm_start || addr >= vma->vm_end)
 			continue;
 
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 3892c1a..fd25e7f 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1406,6 +1406,7 @@ static void fill_siginfo_note(struct memelfnote *note, user_siginfo_t *csigdata,
 static int fill_files_note(struct memelfnote *note)
 {
 	struct vm_area_struct *vma;
+	struct mm_struct *mm = current->mm;
 	unsigned count, size, names_ofs, remaining, n;
 	user_long_t *data;
 	user_long_t *start_end_ofs;
@@ -1428,7 +1429,8 @@ static int fill_files_note(struct memelfnote *note)
 	name_base = name_curpos = ((char *)data) + names_ofs;
 	remaining = size - names_ofs;
 	count = 0;
-	for (vma = current->mm->mmap; vma != NULL; vma = vma->vm_next) {
+
+	for_each_vma(vma) {
 		struct file *file;
 		const char *filename;
 
@@ -1993,6 +1995,10 @@ static struct vm_area_struct *next_vma(struct vm_area_struct *this_vma,
 	return gate_vma;
 }
 
+#define for_each_vma_gate(vma)						\
+	for_each_vma_start_inc((vma), first_vma(current, gate_vma),	\
+			       next_vma((vma), gate_vma))
+
 static void fill_extnum_info(struct elfhdr *elf, struct elf_shdr *shdr4extnum,
 			     elf_addr_t e_shoff, int segs)
 {
@@ -2015,8 +2021,7 @@ static size_t elf_core_vma_data_size(struct vm_area_struct *gate_vma,
 	struct vm_area_struct *vma;
 	size_t size = 0;
 
-	for (vma = first_vma(current, gate_vma); vma != NULL;
-	     vma = next_vma(vma, gate_vma))
+	for_each_vma_gate(vma)
 		size += vma_dump_size(vma, mm_flags);
 	return size;
 }
@@ -2128,8 +2133,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 		goto end_coredump;
 
 	/* Write program headers for segments dump */
-	for (vma = first_vma(current, gate_vma); vma != NULL;
-			vma = next_vma(vma, gate_vma)) {
+	for_each_vma_gate(vma) {
 		struct elf_phdr phdr;
 
 		phdr.p_type = PT_LOAD;
@@ -2164,8 +2168,7 @@ static int elf_core_dump(struct coredump_params *cprm)
 	if (!dump_skip(cprm, dataoff - cprm->written))
 		goto end_coredump;
 
-	for (vma = first_vma(current, gate_vma); vma != NULL;
-			vma = next_vma(vma, gate_vma)) {
+	for_each_vma_gate(vma) {
 		unsigned long addr;
 		unsigned long end;
 
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index fe2a643..aea8ac7 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1484,9 +1484,10 @@ static void fill_extnum_info(struct elfhdr *elf, struct elf_shdr *shdr4extnum,
  */
 static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 {
+	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		unsigned long addr;
 
 		if (!maydump(vma, cprm->mm_flags))
@@ -1520,11 +1521,13 @@ static bool elf_fdpic_dump_segments(struct coredump_params *cprm)
 static size_t elf_core_vma_data_size(unsigned long mm_flags)
 {
 	struct vm_area_struct *vma;
+	struct mm_struct *mm = current->mm;
 	size_t size = 0;
 
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next)
+	for_each_vma(vma) {
 		if (maydump(vma, mm_flags))
 			size += vma->vm_end - vma->vm_start;
+	}
 	return size;
 }
 
@@ -1563,6 +1566,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	elf_addr_t e_shoff;
 	struct core_thread *ct;
 	struct elf_thread_status *tmp;
+	struct mm_struct *mm = current->mm;
 
 	/*
 	 * We no longer stop all VM operations.
@@ -1598,7 +1602,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 		goto cleanup;
 #endif
 
-	for (ct = current->mm->core_state->dumper.next;
+	for (ct = mm->core_state->dumper.next;
 					ct; ct = ct->next) {
 		tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
 		if (!tmp)
@@ -1621,7 +1625,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	fill_prstatus(prstatus, current, cprm->siginfo->si_signo);
 	elf_core_copy_regs(&prstatus->pr_reg, cprm->regs);
 
-	segs = current->mm->map_count;
+	segs = mm->map_count;
 	segs += elf_core_extra_phdrs();
 
 	/* for notes section */
@@ -1642,12 +1646,12 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 	 */
 
 	fill_note(notes + 0, "CORE", NT_PRSTATUS, sizeof(*prstatus), prstatus);
-	fill_psinfo(psinfo, current->group_leader, current->mm);
+	fill_psinfo(psinfo, current->group_leader, mm);
 	fill_note(notes + 1, "CORE", NT_PRPSINFO, sizeof(*psinfo), psinfo);
 
 	numnote = 2;
 
-	auxv = (elf_addr_t *) current->mm->saved_auxv;
+	auxv = (elf_addr_t *) mm->saved_auxv;
 
 	i = 0;
 	do
@@ -1713,7 +1717,7 @@ static int elf_fdpic_core_dump(struct coredump_params *cprm)
 		goto end_coredump;
 
 	/* write program headers for segments dump */
-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		struct elf_phdr phdr;
 		size_t sz;
 
diff --git a/fs/proc/base.c b/fs/proc/base.c
index baf852b..2438695 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1872,7 +1872,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	struct vm_area_struct *vma;
 	struct task_struct *task;
 	struct mm_struct *mm;
-	unsigned long nr_files, pos, i;
+	unsigned long nr_files, pos = 2, i;
 	struct flex_array *fa = NULL;
 	struct map_files_info info;
 	struct map_files_info *p;
@@ -1911,8 +1911,7 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	 * otherwise we get lockdep complained, since filldir()
 	 * routine might require mmap_sem taken in might_fault().
 	 */
-
-	for (vma = mm->mmap, pos = 2; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (vma->vm_file && ++pos > ctx->pos)
 			nr_files++;
 	}
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dfc791c..ba7f71c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -831,7 +831,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		down_read(&mm->mmap_sem);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+
+		for_each_vma(vma) {
 			cp.vma = vma;
 			if (is_vm_hugetlb_page(vma))
 				continue;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..a5ffacd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1734,6 +1734,15 @@ struct vm_area_struct *vma_interval_tree_iter_first(struct rb_root *root,
 struct vm_area_struct *vma_interval_tree_iter_next(struct vm_area_struct *node,
 				unsigned long start, unsigned long last);
 
+#define for_each_vma(vma)					\
+	for ((vma) = mm->mmap; (vma); (vma) = (vma)->vm_next)
+
+#define for_each_vma_start(vma, start)				\
+	for ((vma) = (start); (vma); (vma) = (vma)->vm_next)
+
+#define for_each_vma_start_inc(vma, start, inc)			\
+	for ((vma) = (start); (vma); (vma) = (inc))
+
 #define vma_interval_tree_foreach(vma, root, start, last)		\
 	for (vma = vma_interval_tree_iter_first(root, start, last);	\
 	     vma; vma = vma_interval_tree_iter_next(vma, start, last))
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1d0af8a..fccd3fe 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -969,7 +969,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 	int err = 0;
 
 	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		unsigned long vaddr;
 		loff_t offset;
 
@@ -1651,7 +1651,7 @@ static void mmf_recalc_uprobes(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (!valid_vma(vma, false))
 			continue;
 		/*
diff --git a/kernel/sys.c b/kernel/sys.c
index ce81291..2827d5b 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1663,7 +1663,7 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
 	if (mm->exe_file) {
 		struct vm_area_struct *vma;
 
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
+		for_each_vma(vma)
 			if (vma->vm_file &&
 			    path_equal(&vma->vm_file->f_path,
 				       &mm->exe_file->f_path))
diff --git a/mm/ksm.c b/mm/ksm.c
index fb75902..6092b2a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -780,7 +780,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
 		down_read(&mm->mmap_sem);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		for_each_vma(vma) {
 			if (ksm_test_exit(mm))
 				break;
 			if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ec4dcf1..b9383c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5918,7 +5918,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 
 	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		struct mm_walk mem_cgroup_count_precharge_walk = {
 			.pmd_entry = mem_cgroup_count_precharge_pte_range,
 			.mm = mm,
@@ -6180,23 +6180,26 @@ retry:
 		cond_resched();
 		goto retry;
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+
+	for_each_vma(vma) {
 		int ret;
 		struct mm_walk mem_cgroup_move_charge_walk = {
 			.pmd_entry = mem_cgroup_move_charge_pte_range,
 			.mm = mm,
 			.private = vma,
 		};
+
 		if (is_vm_hugetlb_page(vma))
 			continue;
 		ret = walk_page_range(vma->vm_start, vma->vm_end,
 						&mem_cgroup_move_charge_walk);
-		if (ret)
+		if (ret) {
 			/*
 			 * means we have consumed all precharges and failed in
 			 * doing additional charge. Just abandon here.
 			 */
 			break;
+		}
 	}
 	up_read(&mm->mmap_sem);
 }
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8f5330d..8abc94f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -453,7 +453,7 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 	struct vm_area_struct *vma;
 
 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	for_each_vma(vma)
 		mpol_rebind_policy(vma->vm_policy, new, MPOL_REBIND_ONCE);
 	up_write(&mm->mmap_sem);
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index f78ec9b..0a62a2d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1544,7 +1544,9 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
  	struct vm_area_struct *vma;
  	int err = 0;
 
-	for (vma = mm->mmap; vma && !err; vma = vma->vm_next) {
+	for_each_vma(vma) {
+		if (err)
+			break;
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)
diff --git a/mm/mlock.c b/mm/mlock.c
index ce84cb0..434b4b0 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -771,16 +771,17 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 
 static int do_mlockall(int flags)
 {
-	struct vm_area_struct * vma, * prev = NULL;
+	struct vm_area_struct *vma, *prev = NULL;
+	struct mm_struct *mm = current->mm;
 
 	if (flags & MCL_FUTURE)
-		current->mm->def_flags |= VM_LOCKED;
+		mm->def_flags |= VM_LOCKED;
 	else
-		current->mm->def_flags &= ~VM_LOCKED;
+		mm->def_flags &= ~VM_LOCKED;
 	if (flags == MCL_FUTURE)
 		goto out;
 
-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	for_each_vma(vma) {
 		vm_flags_t newflags;
 
 		newflags = vma->vm_flags & ~VM_LOCKED;
diff --git a/mm/mmap.c b/mm/mmap.c
index c1f2ea4..7255274 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -574,7 +574,7 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 		max(addr, vma->vm_start)) >> PAGE_SHIFT;
 
 	/* Iterate over the rest of the overlaps */
-	for (vma = vma->vm_next; vma; vma = vma->vm_next) {
+	for_each_vma_start(vma, vma->vm_next) {
 		unsigned long overlap_len;
 
 		if (vma->vm_start > end)
@@ -3108,14 +3108,14 @@ int mm_take_all_locks(struct mm_struct *mm)
 
 	mutex_lock(&mm_all_locks_mutex);
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (signal_pending(current))
 			goto out_unlock;
 		if (vma->vm_file && vma->vm_file->f_mapping)
 			vm_lock_mapping(mm, vma->vm_file->f_mapping);
 	}
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (signal_pending(current))
 			goto out_unlock;
 		if (vma->anon_vma)
@@ -3178,7 +3178,7 @@ void mm_drop_all_locks(struct mm_struct *mm)
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (vma->anon_vma)
 			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
 				vm_unlock_anon_vma(avc->anon_vma);
diff --git a/mm/nommu.c b/mm/nommu.c
index a881d96..c150415 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -843,7 +843,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 
 	/* trawl the list (there may be multiple mappings in which addr
 	 * resides) */
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end > addr) {
@@ -892,7 +892,7 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 
 	/* trawl the list (there may be multiple mappings in which addr
 	 * resides) */
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	for_each_vma(vma) {
 		if (vma->vm_start < addr)
 			continue;
 		if (vma->vm_start > addr)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e..eeb1d24 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1266,7 +1266,8 @@ static int unuse_mm(struct mm_struct *mm,
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+
+	for_each_vma(vma) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
 	}
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
