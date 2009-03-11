Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9746D6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 05:55:51 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 9so260844ywk.26
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 02:55:48 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 11 Mar 2009 11:55:48 +0200
Message-ID: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
Subject: [PATCH 1/2] mm: use list.h for vma list
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Use the linked list defined list.h for the list of vmas that's stored
in the mm_struct structure.  Wrapper functions "vma_next" and
"vma_prev" are also implemented.  Functions that operate on more than
one vma are now given a list of vmas as input.

Signed-off-by: Daniel Lowengrub
---
diff -uNr linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c
linux-2.6.28.7/arch/alpha/kernel/osf_sys.c
--- linux-2.6.28.7.vanilla/arch/alpha/kernel/osf_sys.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/alpha/kernel/osf_sys.c	2009-02-28
23:34:42.000000000 +0200
@@ -1197,7 +1197,7 @@
 		if (!vma || addr + len <= vma->vm_start)
 			return addr;
 		addr = vma->vm_end;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}
 }

diff -uNr linux-2.6.28.7.vanilla/arch/arm/mm/mmap.c
linux-2.6.28.7/arch/arm/mm/mmap.c
--- linux-2.6.28.7.vanilla/arch/arm/mm/mmap.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/arm/mm/mmap.c	2009-02-28 23:35:31.000000000 +0200
@@ -86,7 +86,7 @@
 	else
 		addr = PAGE_ALIGN(addr);

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma->vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
diff -uNr linux-2.6.28.7.vanilla/arch/frv/mm/elf-fdpic.c
linux-2.6.28.7/arch/frv/mm/elf-fdpic.c
--- linux-2.6.28.7.vanilla/arch/frv/mm/elf-fdpic.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/frv/mm/elf-fdpic.c	2009-02-28 23:36:26.000000000 +0200
@@ -86,7 +86,7 @@

 		if (addr <= limit) {
 			vma = find_vma(current->mm, PAGE_SIZE);
-			for (; vma; vma = vma->vm_next) {
+			for (; vma; vma = vma_next(vma)) {
 				if (addr > limit)
 					break;
 				if (addr + len <= vma->vm_start)
@@ -101,7 +101,7 @@
 	limit = TASK_SIZE - len;
 	if (addr <= limit) {
 		vma = find_vma(current->mm, addr);
-		for (; vma; vma = vma->vm_next) {
+		for (; vma; vma = vma_next(vma)) {
 			if (addr > limit)
 				break;
 			if (addr + len <= vma->vm_start)
diff -uNr linux-2.6.28.7.vanilla/arch/ia64/kernel/sys_ia64.c
linux-2.6.28.7/arch/ia64/kernel/sys_ia64.c
--- linux-2.6.28.7.vanilla/arch/ia64/kernel/sys_ia64.c	2009-03-06
15:32:58.000000000 +0200
+++ linux-2.6.28.7/arch/ia64/kernel/sys_ia64.c	2009-02-28
23:37:20.000000000 +0200
@@ -58,7 +58,7 @@
   full_search:
 	start_addr = addr = (addr + align_mask) & ~align_mask;

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr || RGN_MAP_LIMIT - len < REGION_OFFSET(addr)) {
 			if (start_addr != TASK_UNMAPPED_BASE) {
diff -uNr linux-2.6.28.7.vanilla/arch/ia64/mm/hugetlbpage.c
linux-2.6.28.7/arch/ia64/mm/hugetlbpage.c
--- linux-2.6.28.7.vanilla/arch/ia64/mm/hugetlbpage.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/ia64/mm/hugetlbpage.c	2009-02-28
23:37:59.000000000 +0200
@@ -168,7 +168,7 @@
 		addr = HPAGE_REGION_BASE;
 	else
 		addr = ALIGN(addr, HPAGE_SIZE);
-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vmm_next(vma)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (REGION_OFFSET(addr) + len > RGN_MAP_LIMIT)
 			return -ENOMEM;
diff -uNr linux-2.6.28.7.vanilla/arch/mips/kernel/syscall.c
linux-2.6.28.7/arch/mips/kernel/syscall.c
--- linux-2.6.28.7.vanilla/arch/mips/kernel/syscall.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/mips/kernel/syscall.c	2009-02-28
23:38:47.000000000 +0200
@@ -115,7 +115,7 @@
 	else
 		addr = PAGE_ALIGN(addr);

-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (task_size - len < addr)
 			return -ENOMEM;
diff -uNr linux-2.6.28.7.vanilla/arch/parisc/kernel/sys_parisc.c
linux-2.6.28.7/arch/parisc/kernel/sys_parisc.c
--- linux-2.6.28.7.vanilla/arch/parisc/kernel/sys_parisc.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/parisc/kernel/sys_parisc.c	2009-02-28
23:40:54.000000000 +0200
@@ -39,7 +39,7 @@

 	addr = PAGE_ALIGN(addr);

-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
@@ -75,7 +75,7 @@

 	addr = DCACHE_ALIGN(addr - offset) + offset;

-	for (vma = find_vma(current->mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(current->mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr)
 			return -ENOMEM;
diff -uNr linux-2.6.28.7.vanilla/arch/parisc/mm/fault.c
linux-2.6.28.7/arch/parisc/mm/fault.c
--- linux-2.6.28.7.vanilla/arch/parisc/mm/fault.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/parisc/mm/fault.c	2009-03-06 09:16:30.000000000 +0200
@@ -130,9 +130,9 @@
 					tree = tree->vm_avl_left;
 				} else {
 					prev = tree;
-					if (prev->vm_next == NULL)
+					if (vma_next(prev) == NULL)
 						break;
-					if (prev->vm_next->vm_start > addr)
+					if (vma_next(prev)->vm_start > addr)
 						break;
 					tree = tree->vm_avl_right;
 				}
diff -uNr linux-2.6.28.7.vanilla/arch/powerpc/mm/tlb_32.c
linux-2.6.28.7/arch/powerpc/mm/tlb_32.c
--- linux-2.6.28.7.vanilla/arch/powerpc/mm/tlb_32.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/powerpc/mm/tlb_32.c	2009-02-28 23:59:03.000000000 +0200
@@ -156,7 +156,7 @@
 	 * unmap_region or exit_mmap, but not from vmtruncate on SMP -
 	 * but it seems dup_mmap is the only SMP case which gets here.
 	 */
-	for (mp = mm->mmap; mp != NULL; mp = mp->vm_next)
+	list_for_each_entry(mp, &mm->mm_vmas, vm_list)
 		flush_range(mp->vm_mm, mp->vm_start, mp->vm_end);
 	FINISH_FLUSH;
 }
diff -uNr linux-2.6.28.7.vanilla/arch/powerpc/oprofile/cell/spu_task_sync.c
linux-2.6.28.7/arch/powerpc/oprofile/cell/spu_task_sync.c
--- linux-2.6.28.7.vanilla/arch/powerpc/oprofile/cell/spu_task_sync.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/powerpc/oprofile/cell/spu_task_sync.c	2009-03-01
00:01:57.000000000 +0200
@@ -329,7 +329,7 @@

 	down_read(&mm->mmap_sem);

-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -341,7 +341,7 @@
 		break;
 	}

-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
 			continue;
 		my_offset = spu_ref - vma->vm_start;
diff -uNr linux-2.6.28.7.vanilla/arch/sh/kernel/sys_sh.c
linux-2.6.28.7/arch/sh/kernel/sys_sh.c
--- linux-2.6.28.7.vanilla/arch/sh/kernel/sys_sh.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/sh/kernel/sys_sh.c	2009-03-01 00:06:49.000000000 +0200
@@ -87,7 +87,7 @@
 	else
 		addr = PAGE_ALIGN(mm->free_area_cache);

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (unlikely(TASK_SIZE - len < addr)) {
 			/*
diff -uNr linux-2.6.28.7.vanilla/arch/sh/mm/cache-sh4.c
linux-2.6.28.7/arch/sh/mm/cache-sh4.c
--- linux-2.6.28.7.vanilla/arch/sh/mm/cache-sh4.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/sh/mm/cache-sh4.c	2009-02-28 23:42:33.000000000 +0200
@@ -402,7 +402,7 @@
 		 * In this case there are reasonably sized ranges to flush,
 		 * iterate through the VMA list and take care of any aliases.
 		 */
-		for (vma = mm->mmap; vma; vma = vma->vm_next)
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 			__flush_cache_mm(mm, vma->vm_start, vma->vm_end);
 	}

diff -uNr linux-2.6.28.7.vanilla/arch/sparc/kernel/sys_sparc.c
linux-2.6.28.7/arch/sparc/kernel/sys_sparc.c
--- linux-2.6.28.7.vanilla/arch/sparc/kernel/sys_sparc.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/sparc/kernel/sys_sparc.c	2009-03-01
00:08:26.000000000 +0200
@@ -63,7 +63,7 @@
 	else
 		addr = PAGE_ALIGN(addr);

-	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+	for (vmm = find_vma(current->mm, addr); ; vmm = vma_next(vmm)) {
 		/* At this point:  (!vmm || addr < vmm->vm_end). */
 		if (ARCH_SUN4C && addr < 0xe0000000 && 0x20000000 - len < addr) {
 			addr = PAGE_OFFSET;
diff -uNr linux-2.6.28.7.vanilla/arch/sparc64/kernel/sys_sparc.c
linux-2.6.28.7/arch/sparc64/kernel/sys_sparc.c
--- linux-2.6.28.7.vanilla/arch/sparc64/kernel/sys_sparc.c	2009-03-06
15:33:30.000000000 +0200
+++ linux-2.6.28.7/arch/sparc64/kernel/sys_sparc.c	2009-03-06
09:11:44.000000000 +0200
@@ -166,7 +166,7 @@
 	else
 		addr = PAGE_ALIGN(addr);

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
diff -uNr linux-2.6.28.7.vanilla/arch/sparc64/mm/hugetlbpage.c
linux-2.6.28.7/arch/sparc64/mm/hugetlbpage.c
--- linux-2.6.28.7.vanilla/arch/sparc64/mm/hugetlbpage.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/sparc64/mm/hugetlbpage.c	2009-03-06
09:13:55.000000000 +0200
@@ -54,7 +54,7 @@
 full_search:
 	addr = ALIGN(addr, HPAGE_SIZE);

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (addr < VA_EXCLUDE_START &&
 		    (addr + len) >= VA_EXCLUDE_START) {
diff -uNr linux-2.6.28.7.vanilla/arch/um/kernel/tlb.c
linux-2.6.28.7/arch/um/kernel/tlb.c
--- linux-2.6.28.7.vanilla/arch/um/kernel/tlb.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/um/kernel/tlb.c	2009-03-01 00:14:38.000000000 +0200
@@ -515,21 +515,17 @@

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
diff -uNr linux-2.6.28.7.vanilla/arch/x86/kernel/sys_x86_64.c
linux-2.6.28.7/arch/x86/kernel/sys_x86_64.c
--- linux-2.6.28.7.vanilla/arch/x86/kernel/sys_x86_64.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/x86/kernel/sys_x86_64.c	2009-03-01
00:15:46.000000000 +0200
@@ -107,7 +107,7 @@
 	start_addr = addr;

 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (end - len < addr) {
 			/*
diff -uNr linux-2.6.28.7.vanilla/arch/x86/mm/hugetlbpage.c
linux-2.6.28.7/arch/x86/mm/hugetlbpage.c
--- linux-2.6.28.7.vanilla/arch/x86/mm/hugetlbpage.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/arch/x86/mm/hugetlbpage.c	2009-03-01 00:16:22.000000000 +0200
@@ -275,7 +275,7 @@
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
diff -uNr linux-2.6.28.7.vanilla/drivers/oprofile/buffer_sync.c
linux-2.6.28.7/drivers/oprofile/buffer_sync.c
--- linux-2.6.28.7.vanilla/drivers/oprofile/buffer_sync.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/drivers/oprofile/buffer_sync.c	2009-03-06
14:19:31.000000000 +0200
@@ -220,7 +220,7 @@
 	if (!mm)
 		goto out;

-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (!vma->vm_file)
 			continue;
 		if (!(vma->vm_flags & VM_EXECUTABLE))
@@ -245,7 +245,7 @@
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;

-	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); vma; vma_next(vma)) {

 		if (addr < vma->vm_start || addr >= vma->vm_end)
 			continue;
diff -uNr linux-2.6.28.7.vanilla/fs/binfmt_elf.c linux-2.6.28.7/fs/binfmt_elf.c
--- linux-2.6.28.7.vanilla/fs/binfmt_elf.c	2009-03-06 15:33:24.000000000 +0200
+++ linux-2.6.28.7/fs/binfmt_elf.c	2009-02-28 23:28:19.000000000 +0200
@@ -1869,7 +1869,7 @@
 static struct vm_area_struct *first_vma(struct task_struct *tsk,
 					struct vm_area_struct *gate_vma)
 {
-	struct vm_area_struct *ret = tsk->mm->mmap;
+	struct vm_area_struct *ret = __vma_next(&tsk->mm->mm_vmas, NULL);

 	if (ret)
 		return ret;
@@ -1884,7 +1884,7 @@
 {
 	struct vm_area_struct *ret;

-	ret = this_vma->vm_next;
+	ret = vma_next(this_vma);
 	if (ret)
 		return ret;
 	if (this_vma == gate_vma)
diff -uNr linux-2.6.28.7.vanilla/fs/binfmt_elf_fdpic.c
linux-2.6.28.7/fs/binfmt_elf_fdpic.c
--- linux-2.6.28.7.vanilla/fs/binfmt_elf_fdpic.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/fs/binfmt_elf_fdpic.c	2009-02-28 20:47:47.000000000 +0200
@@ -1509,7 +1509,7 @@
 {
 	struct vm_area_struct *vma;

-	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned long addr;

 		if (!maydump(vma, mm_flags))
@@ -1761,13 +1761,12 @@
 	mm_flags = current->mm->flags;

 	/* write program headers for segments dump */
-	for (
 #ifdef CONFIG_MMU
-		vma = current->mm->mmap; vma; vma = vma->vm_next
+		list_for_each_entry(vma, &current->mm->mm_vmas, vm_list)
 #else
-			vml = current->mm->context.vmlist; vml; vml = vml->next
+		for(vml = current->mm->context.vmlist; vml; vml = vml->next)
 #endif
-	     ) {
+	     {
 		struct elf_phdr phdr;
 		size_t sz;

diff -uNr linux-2.6.28.7.vanilla/fs/exec.c linux-2.6.28.7/fs/exec.c
--- linux-2.6.28.7.vanilla/fs/exec.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/fs/exec.c	2009-03-01 00:21:01.000000000 +0200
@@ -517,6 +517,7 @@
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
+	struct vm_area_struct *next;
 	struct mmu_gather *tlb;

 	BUG_ON(new_start > new_end);
@@ -543,12 +544,13 @@

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
@@ -557,7 +559,7 @@
 		 * for the others its just a little faster.
 		 */
 		free_pgd_range(tlb, old_start, old_end, new_end,
-			vma->vm_next ? vma->vm_next->vm_start : 0);
+			next ? next->vm_start : 0);
 	}
 	tlb_finish_mmu(tlb, new_end, old_end);

diff -uNr linux-2.6.28.7.vanilla/fs/hugetlbfs/inode.c
linux-2.6.28.7/fs/hugetlbfs/inode.c
--- linux-2.6.28.7.vanilla/fs/hugetlbfs/inode.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/fs/hugetlbfs/inode.c	2009-02-28 23:26:18.000000000 +0200
@@ -162,7 +162,7 @@
 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));

-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
diff -uNr linux-2.6.28.7.vanilla/fs/proc/task_mmu.c
linux-2.6.28.7/fs/proc/task_mmu.c
--- linux-2.6.28.7.vanilla/fs/proc/task_mmu.c	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/fs/proc/task_mmu.c	2009-02-28 20:54:28.000000000 +0200
@@ -126,7 +126,7 @@
 	/* Start with last addr hint */
 	vma = find_vma(mm, last_addr);
 	if (last_addr && vma) {
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 		goto out;
 	}

@@ -136,9 +136,9 @@
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

@@ -159,12 +159,12 @@
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
@@ -485,7 +485,7 @@
 			.mm = mm,
 		};
 		down_read(&mm->mmap_sem);
-		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 			clear_refs_walk.private = vma;
 			if (!is_vm_hugetlb_page(vma))
 				walk_page_range(vma->vm_start, vma->vm_end,
diff -uNr linux-2.6.28.7.vanilla/include/linux/init_task.h
linux-2.6.28.7/include/linux/init_task.h
--- linux-2.6.28.7.vanilla/include/linux/init_task.h	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/include/linux/init_task.h	2009-02-28 23:45:15.000000000 +0200
@@ -27,7 +27,8 @@
 }

 #define INIT_MM(name) \
-{			 					\
+{			                                        \
+        .mm_vmas = LIST_HEAD_INIT(name.mm_vmas),		\
 	.mm_rb		= RB_ROOT,				\
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
diff -uNr linux-2.6.28.7.vanilla/include/linux/mm.h
linux-2.6.28.7/include/linux/mm.h
--- linux-2.6.28.7.vanilla/include/linux/mm.h	2009-03-06
15:32:58.000000000 +0200
+++ linux-2.6.28.7/include/linux/mm.h	2009-03-11 10:51:28.000000000 +0200
@@ -35,7 +35,7 @@
 #endif

 extern unsigned long mmap_min_addr;
-
+#include <linux/sched.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -212,6 +212,40 @@
 		const nodemask_t *to, unsigned long flags);
 #endif
 };
+/* Interface for the list_head prev and next pointers.  They
+ * don't let you wrap around the vm_list.
+ */
+static inline struct vm_area_struct *
+__vma_next(struct list_head *head, struct vm_area_struct *vma)
+{
+	if (unlikely(!vma))
+		vma = container_of(head, struct vm_area_struct, vm_list);
+	if (vma->vm_list.next == head)
+		return NULL;
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
+	if (vma->vm_list.prev == head)
+		return NULL;
+	return list_entry(vma->vm_list.prev, struct vm_area_struct, vm_list);
+}
+
+static inline struct vm_area_struct *
+vma_prev(struct vm_area_struct *vma)
+{
+	return __vma_prev(&vma->vm_mm->mm_vmas, vma);
+}

 struct mmu_gather;
 struct inode;
@@ -747,7 +781,7 @@
 		unsigned long size);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
-unsigned long unmap_vmas(struct mmu_gather **tlb,
+unsigned long unmap_vmas(struct mmu_gather **tlb, struct list_head *vmas,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
diff -uNr linux-2.6.28.7.vanilla/include/linux/mm_types.h
linux-2.6.28.7/include/linux/mm_types.h
--- linux-2.6.28.7.vanilla/include/linux/mm_types.h	2008-12-25
01:26:37.000000000 +0200
+++ linux-2.6.28.7/include/linux/mm_types.h	2009-02-27 12:14:25.000000000 +0200
@@ -109,7 +109,7 @@
 					   within vm_mm. */

 	/* linked list of VM areas per task, sorted by address */
-	struct vm_area_struct *vm_next;
+	struct list_head vm_list;

 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
 	unsigned long vm_flags;		/* Flags, see mm.h. */
@@ -171,7 +171,7 @@
 };

 struct mm_struct {
-	struct vm_area_struct * mmap;		/* list of VMAs */
+	struct list_head mm_vmas;		/* list of VMAs */
 	struct rb_root mm_rb;
 	struct vm_area_struct * mmap_cache;	/* last find_vma result */
 	unsigned long (*get_unmapped_area) (struct file *filp,
diff -uNr linux-2.6.28.7.vanilla/ipc/shm.c linux-2.6.28.7/ipc/shm.c
--- linux-2.6.28.7.vanilla/ipc/shm.c	2009-03-06 15:33:24.000000000 +0200
+++ linux-2.6.28.7/ipc/shm.c	2009-02-28 20:58:27.000000000 +0200
@@ -1001,7 +1001,7 @@
 	vma = find_vma(mm, addr);

 	while (vma) {
-		next = vma->vm_next;
+		next = vma_next(vma);

 		/*
 		 * Check if the starting address would match, i.e. it's
@@ -1034,7 +1034,7 @@
 	 */
 	size = PAGE_ALIGN(size);
 	while (vma && (loff_t)(vma->vm_end - addr) <= size) {
-		next = vma->vm_next;
+		next = vma_next(vma);

 		/* finding a matching vma now does not alter retval */
 		if ((vma->vm_ops == &shm_vm_ops) &&
diff -uNr linux-2.6.28.7.vanilla/kernel/acct.c linux-2.6.28.7/kernel/acct.c
--- linux-2.6.28.7.vanilla/kernel/acct.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/kernel/acct.c	2009-02-28 21:02:51.000000000 +0200
@@ -602,11 +602,8 @@
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

diff -uNr linux-2.6.28.7.vanilla/kernel/auditsc.c
linux-2.6.28.7/kernel/auditsc.c
--- linux-2.6.28.7.vanilla/kernel/auditsc.c	2008-12-25 01:26:37.000000000 +0200
+++ linux-2.6.28.7/kernel/auditsc.c	2009-03-06 13:12:03.000000000 +0200
@@ -941,15 +941,13 @@

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
diff -uNr linux-2.6.28.7.vanilla/kernel/fork.c linux-2.6.28.7/kernel/fork.c
--- linux-2.6.28.7.vanilla/kernel/fork.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/kernel/fork.c	2009-02-28 23:54:03.000000000 +0200
@@ -257,7 +257,7 @@
 #ifdef CONFIG_MMU
 static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
-	struct vm_area_struct *mpnt, *tmp, **pprev;
+	struct vm_area_struct *mpnt, *tmp;
 	struct rb_node **rb_link, *rb_parent;
 	int retval;
 	unsigned long charge;
@@ -271,7 +271,6 @@
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);

 	mm->locked_vm = 0;
-	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
@@ -280,9 +279,8 @@
 	mm->mm_rb = RB_ROOT;
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
-	pprev = &mm->mmap;

-	for (mpnt = oldmm->mmap; mpnt; mpnt = mpnt->vm_next) {
+	list_for_each_entry(mpnt, &oldmm->mm_vmas, vm_list) {
 		struct file *file;

 		if (mpnt->vm_flags & VM_DONTCOPY) {
@@ -310,7 +308,6 @@
 		vma_set_policy(tmp, pol);
 		tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
-		tmp->vm_next = NULL;
 		anon_vma_link(tmp);
 		file = tmp->vm_file;
 		if (file) {
@@ -342,9 +339,7 @@
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
@@ -401,6 +396,7 @@

 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
+	INIT_LIST_HEAD(&mm->mm_vmas);
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
diff -uNr linux-2.6.28.7.vanilla/mm/internal.h linux-2.6.28.7/mm/internal.h
--- linux-2.6.28.7.vanilla/mm/internal.h	2008-12-25 01:26:37.000000000 +0200
+++ linux-2.6.28.7/mm/internal.h	2009-03-11 10:52:10.000000000 +0200
@@ -13,7 +13,8 @@

 #include <linux/mm.h>

-void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather *tlb, struct list_head *vmas,
+		struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);

 extern void prep_compound_page(struct page *page, unsigned long order);
diff -uNr linux-2.6.28.7.vanilla/mm/madvise.c linux-2.6.28.7/mm/madvise.c
--- linux-2.6.28.7.vanilla/mm/madvise.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/madvise.c	2009-02-28 21:05:37.000000000 +0200
@@ -351,7 +351,7 @@
 		if (start >= end)
 			goto out;
 		if (prev)
-			vma = prev->vm_next;
+			vma = vma_next(prev);
 		else	/* madvise_remove dropped mmap_sem */
 			vma = find_vma(current->mm, start);
 	}
diff -uNr linux-2.6.28.7.vanilla/mm/memory.c linux-2.6.28.7/mm/memory.c
--- linux-2.6.28.7.vanilla/mm/memory.c	2009-03-06 15:33:24.000000000 +0200
+++ linux-2.6.28.7/mm/memory.c	2009-03-11 10:55:05.000000000 +0200
@@ -274,11 +274,12 @@
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
@@ -297,7 +298,7 @@
 			while (next && next->vm_start <= vma->vm_end + PMD_SIZE
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
-				next = vma->vm_next;
+				next = __vma_next(vmas, vma);
 				anon_vma_unlink(vma);
 				unlink_file_vma(vma);
 			}
@@ -888,7 +889,7 @@
  * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
  * drops the lock and schedules.
  */
-unsigned long unmap_vmas(struct mmu_gather **tlbp,
+unsigned long unmap_vmas(struct mmu_gather **tlbp, struct list_head *vmas,
 		struct vm_area_struct *vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *details)
@@ -902,7 +903,7 @@
 	struct mm_struct *mm = vma->vm_mm;

 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
-	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+	for ( ; vma && vma->vm_start < end_addr; vma = __vma_next(vmas, vma)) {
 		unsigned long end;

 		start = max(vma->vm_start, start_addr);
@@ -988,7 +989,8 @@
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
-	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
+	end = unmap_vmas(&tlb, &mm->mm_vmas, vma, address, end,
+			&nr_accounted, details);
 	if (tlb)
 		tlb_finish_mmu(tlb, address, end);
 	return end;
diff -uNr linux-2.6.28.7.vanilla/mm/mempolicy.c linux-2.6.28.7/mm/mempolicy.c
--- linux-2.6.28.7.vanilla/mm/mempolicy.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/mempolicy.c	2009-03-11 10:57:43.000000000 +0200
@@ -342,7 +342,7 @@
 	struct vm_area_struct *vma;

 	down_write(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next)
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list)
 		mpol_rebind_policy(vma->vm_policy, new);
 	up_write(&mm->mmap_sem);
 }
@@ -494,9 +494,9 @@
 	if (!first)
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for (vma = first; vma && vma->vm_start < end; vma = vma_next(vma)) {
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
-			if (!vma->vm_next && vma->vm_end < end)
+			if (!vma->vma_next(vma) && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
@@ -553,7 +553,7 @@

 	err = 0;
 	for (; vma && vma->vm_start < end; vma = next) {
-		next = vma->vm_next;
+		next = vma_next(vma);
 		if (vma->vm_start < start)
 			err = split_vma(vma->vm_mm, vma, start, 1);
 		if (!err && vma->vm_end > end)
@@ -784,8 +784,8 @@
 	nodes_clear(nmask);
 	node_set(source, nmask);

-	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
-			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
+	check_range(mm, __vma_next(&mm->mm_vmas, NULL)->vm_start, TASK_SIZE,
+		&nmask, flags | MPOL_MF_DISCONTIG_OK, &pagelist);

 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest);
@@ -899,7 +899,7 @@
 		address = page_address_in_vma(page, vma);
 		if (address != -EFAULT)
 			break;
-		vma = vma->vm_next;
+		vma = vma_next(vma);
 	}

 	/*
diff -uNr linux-2.6.28.7.vanilla/mm/migrate.c linux-2.6.28.7/mm/migrate.c
--- linux-2.6.28.7.vanilla/mm/migrate.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/migrate.c	2009-03-11 10:58:48.000000000 +0200
@@ -1139,7 +1139,7 @@
  	struct vm_area_struct *vma;
  	int err = 0;

- 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
  			err = vma->vm_ops->migrate(vma, to, from, flags);
  			if (err)
diff -uNr linux-2.6.28.7.vanilla/mm/mlock.c linux-2.6.28.7/mm/mlock.c
--- linux-2.6.28.7.vanilla/mm/mlock.c	2009-03-06 15:33:24.000000000 +0200
+++ linux-2.6.28.7/mm/mlock.c	2009-03-11 10:59:29.000000000 +0200
@@ -480,7 +480,7 @@
 		if (nstart >= end)
 			break;

-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			break;
@@ -540,7 +540,7 @@
 	if (flags == MCL_FUTURE)
 		goto out;

-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	list_for_each_entry(vma, &current->mm->mm_vmas, vm_list) {
 		unsigned int newflags;

 		newflags = vma->vm_flags | VM_LOCKED;
diff -uNr linux-2.6.28.7.vanilla/mm/mmap.c linux-2.6.28.7/mm/mmap.c
--- linux-2.6.28.7.vanilla/mm/mmap.c	2009-03-06 15:33:30.000000000 +0200
+++ linux-2.6.28.7/mm/mmap.c	2009-03-11 11:03:57.000000000 +0200
@@ -43,7 +43,7 @@
 #define arch_rebalance_pgtables(addr, len)		(addr)
 #endif

-static void unmap_region(struct mm_struct *mm,
+static void unmap_region(struct mm_struct *mm, struct list_head *vmas,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);

@@ -226,13 +226,12 @@
 }

 /*
- * Close a vm structure and free it, returning the next.
+ * Close a vm structure and free it.
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
@@ -242,7 +241,6 @@
 	}
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
-	return next;
 }

 SYSCALL_DEFINE1(brk, unsigned long, brk)
@@ -334,11 +332,9 @@
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
@@ -392,15 +388,14 @@
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
+			struct vm_area_struct *next = rb_entry(rb_parent,
 					struct vm_area_struct, vm_rb);
-		else
-			vma->vm_next = NULL;
+			list_add_tail(&vma->vm_list, &next->vm_list);
+		} else
+			list_add(&vma->vm_list, &mm->mm_vmas);
 	}
 }

@@ -490,7 +485,7 @@
 __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev)
 {
-	prev->vm_next = vma->vm_next;
+	list_del(&vma->vm_list);
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
@@ -507,7 +502,7 @@
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct vm_area_struct *next = vma->vm_next;
+	struct vm_area_struct *next = vma_next(vma);
 	struct vm_area_struct *importer = NULL;
 	struct address_space *mapping = NULL;
 	struct prio_tree_root *root = NULL;
@@ -651,7 +646,7 @@
 		 * up the code too much to do both in one go.
 		 */
 		if (remove_next == 2) {
-			next = vma->vm_next;
+			next = vma_next(vma);
 			goto again;
 		}
 	}
@@ -770,13 +765,10 @@
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
@@ -835,7 +827,7 @@
 	struct vm_area_struct *near;
 	unsigned long vm_flags;

-	near = vma->vm_next;
+	near = vma_next(vma);
 	if (!near)
 		goto try_prev;

@@ -1101,7 +1093,7 @@
 	struct rb_node **rb_link, *rb_parent;
 	unsigned long charged = 0;
 	struct inode *inode =  file ? file->f_path.dentry->d_inode : NULL;
-
+	LIST_HEAD(vmas);
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
@@ -1249,7 +1241,8 @@
 	fput(file);

 	/* Undo any partial mapping done by a device driver. */
-	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
+	list_add(&vma->vm_list, &vmas);
+	unmap_region(mm, &vmas, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
@@ -1300,7 +1293,7 @@
 	}

 full_search:
-	for (vma = find_vma(mm, addr); ; vma = vma->vm_next) {
+	for (vma = find_vma(mm, addr); ; vma = vma_next(vma)) {
 		/* At this point:  (!vma || addr < vma->vm_end). */
 		if (TASK_SIZE - len < addr) {
 			/*
@@ -1511,14 +1504,11 @@
 find_vma_prev(struct mm_struct *mm, unsigned long addr,
 			struct vm_area_struct **pprev)
 {
-	struct vm_area_struct *vma = NULL, *prev = NULL;
+	struct vm_area_struct *next, *prev = NULL;
 	struct rb_node * rb_node;
 	if (!mm)
 		goto out;

-	/* Guard against addr being lower than the first VMA */
-	vma = mm->mmap;
-
 	/* Go through the RB tree quickly. */
 	rb_node = mm->mm_rb.rb_node;

@@ -1530,7 +1520,8 @@
 			rb_node = rb_node->rb_left;
 		} else {
 			prev = vma_tmp;
-			if (!prev->vm_next || (addr < prev->vm_next->vm_end))
+			next = __vma_next(&mm->mm_vmas, prev);
+			if (!next || (addr < next->vm_end))
 				break;
 			rb_node = rb_node->rb_right;
 		}
@@ -1538,7 +1529,7 @@

 out:
 	*pprev = prev;
-	return prev ? prev->vm_next : vma;
+	return __vma_next(&mm->mm_vmas, prev);
 }

 /*
@@ -1754,16 +1745,19 @@
  *
  * Called with the mm semaphore held.
  */
-static void remove_vma_list(struct mm_struct *mm, struct vm_area_struct *vma)
+static void remove_vma_list(struct mm_struct *mm, struct list_head *vmas,
+			struct vm_area_struct *vma)
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
@@ -1773,21 +1767,22 @@
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
+		prev ? prev->vm_end : FIRST_USER_ADDRESS,
+		next ? next->vm_start : 0);
 	tlb_finish_mmu(tlb, start, end);
 }

@@ -1797,21 +1792,17 @@
  */
 static void
 detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
-	struct vm_area_struct *prev, unsigned long end)
+			struct vm_area_struct *prev, unsigned long end,
+			struct list_head *vmas)
 {
-	struct vm_area_struct **insertion_point;
-	struct vm_area_struct *tail_vma = NULL;
 	unsigned long addr;
-
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
@@ -1885,7 +1876,7 @@
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
-
+	LIST_HEAD(vmas);
 	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;

@@ -1924,7 +1915,7 @@
 		if (error)
 			return error;
 	}
-	vma = prev? prev->vm_next: mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, prev);

 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
@@ -1936,18 +1927,18 @@
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
@@ -2088,7 +2079,8 @@
 void exit_mmap(struct mm_struct *mm)
 {
 	struct mmu_gather *tlb;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma, *next;
+	LIST_HEAD(vmas);
 	unsigned long nr_accounted = 0;
 	unsigned long end;

@@ -2096,36 +2088,37 @@
 	mmu_notifier_release(mm);

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

 	arch_exit_mmap(mm);

-	vma = mm->mmap;
+	vma = __vma_next(&mm->mm_vmas, NULL);
 	if (!vma)	/* Can happen if dup_mmap() received an OOM */
 		return;

 	lru_add_drain();
 	flush_cache_mm(mm);
+	detach_vmas_to_be_unmapped(mm, vma, NULL, -1, &vmas);
 	tlb = tlb_gather_mmu(mm, 1);
 	/* Don't update_hiwater_rss(mm) here, do_exit already did */
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
@@ -2401,14 +2394,14 @@

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
@@ -2471,7 +2464,7 @@
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));

-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma)
 			vm_unlock_anon_vma(vma->anon_vma);
 		if (vma->vm_file && vma->vm_file->f_mapping)
diff -uNr linux-2.6.28.7.vanilla/mm/mprotect.c linux-2.6.28.7/mm/mprotect.c
--- linux-2.6.28.7.vanilla/mm/mprotect.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/mprotect.c	2009-02-28 23:25:42.000000000 +0200
@@ -307,7 +307,7 @@
 		if (nstart >= end)
 			goto out;

-		vma = prev->vm_next;
+		vma = vma_next(prev);
 		if (!vma || vma->vm_start != nstart) {
 			error = -ENOMEM;
 			goto out;
diff -uNr linux-2.6.28.7.vanilla/mm/mremap.c linux-2.6.28.7/mm/mremap.c
--- linux-2.6.28.7.vanilla/mm/mremap.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/mremap.c	2009-02-28 23:31:00.000000000 +0200
@@ -234,7 +234,7 @@
 	if (excess) {
 		vma->vm_flags |= VM_ACCOUNT;
 		if (split)
-			vma->vm_next->vm_flags |= VM_ACCOUNT;
+			vma_next(vma)->vm_flags |= VM_ACCOUNT;
 	}

 	if (vm_flags & VM_LOCKED) {
@@ -368,8 +368,9 @@
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
diff -uNr linux-2.6.28.7.vanilla/mm/msync.c linux-2.6.28.7/mm/msync.c
--- linux-2.6.28.7.vanilla/mm/msync.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/msync.c	2009-02-28 23:31:36.000000000 +0200
@@ -93,7 +93,7 @@
 				error = 0;
 				goto out_unlock;
 			}
-			vma = vma->vm_next;
+			vma = vma_next(vma);
 		}
 	}
 out_unlock:
diff -uNr linux-2.6.28.7.vanilla/mm/swapfile.c linux-2.6.28.7/mm/swapfile.c
--- linux-2.6.28.7.vanilla/mm/swapfile.c	2009-03-06 15:32:58.000000000 +0200
+++ linux-2.6.28.7/mm/swapfile.c	2009-03-11 11:04:48.000000000 +0200
@@ -683,7 +683,7 @@
 		down_read(&mm->mmap_sem);
 		lock_page(page);
 	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+	list_for_each_entry(vma, &mm->mm_vmas, vm_list) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
