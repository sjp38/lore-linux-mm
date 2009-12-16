Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 508866B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:06:48 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG36ido030551
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:06:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A7F745DE53
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:06:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 956EB45DE4D
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:06:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63D051DB8047
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:06:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E41701DB803C
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:06:42 +0900 (JST)
Date: Wed, 16 Dec 2009 12:03:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 3/11] mm accessor for fs
Message-Id: <20091216120337.493b3084.kamezawa.hiroyu@jp.fujitsu.com>
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

Replace mmap_sem access with mm_accessor. for /fs layer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/aio.c              |   10 +++++-----
 fs/binfmt_aout.c      |   32 ++++++++++++++++----------------
 fs/binfmt_elf.c       |   24 ++++++++++++------------
 fs/binfmt_elf_fdpic.c |   18 +++++++++---------
 fs/binfmt_flat.c      |   12 ++++++------
 fs/binfmt_som.c       |   12 ++++++------
 fs/ceph/file.c        |    4 ++--
 fs/exec.c             |   22 +++++++++++-----------
 fs/fuse/dev.c         |    4 ++--
 fs/fuse/file.c        |    4 ++--
 fs/nfs/direct.c       |    8 ++++----
 fs/proc/array.c       |    4 ++--
 fs/proc/base.c        |    4 ++--
 fs/proc/task_mmu.c    |   14 +++++++-------
 fs/proc/task_nommu.c  |   16 ++++++++--------
 15 files changed, 94 insertions(+), 94 deletions(-)

Index: mmotm-mm-accessor/fs/proc/task_mmu.c
===================================================================
--- mmotm-mm-accessor.orig/fs/proc/task_mmu.c
+++ mmotm-mm-accessor/fs/proc/task_mmu.c
@@ -85,7 +85,7 @@ static void vma_stop(struct proc_maps_pr
 {
 	if (vma && vma != priv->tail_vma) {
 		struct mm_struct *mm = vma->vm_mm;
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		mmput(mm);
 	}
 }
@@ -119,7 +119,7 @@ static void *m_start(struct seq_file *m,
 	mm = mm_for_maps(priv->task);
 	if (!mm)
 		return NULL;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	tail_vma = get_gate_vma(priv->task);
 	priv->tail_vma = tail_vma;
@@ -152,7 +152,7 @@ out:
 
 	/* End of vmas has been reached */
 	m->version = (tail_vma != NULL)? 0: -1UL;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 	return tail_vma;
 }
@@ -515,7 +515,7 @@ static ssize_t clear_refs_write(struct f
 			.pmd_entry = clear_refs_pte_range,
 			.mm = mm,
 		};
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			clear_refs_walk.private = vma;
 			if (is_vm_hugetlb_page(vma))
@@ -537,7 +537,7 @@ static ssize_t clear_refs_write(struct f
 					&clear_refs_walk);
 		}
 		flush_tlb_mm(mm);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		mmput(mm);
 	}
 	put_task_struct(task);
@@ -765,10 +765,10 @@ static ssize_t pagemap_read(struct file 
 	if (!pages)
 		goto out_mm;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = get_user_pages(current, current->mm, uaddr, pagecount,
 			     1, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	if (ret < 0)
 		goto out_free;
Index: mmotm-mm-accessor/fs/proc/array.c
===================================================================
--- mmotm-mm-accessor.orig/fs/proc/array.c
+++ mmotm-mm-accessor/fs/proc/array.c
@@ -394,13 +394,13 @@ static inline void task_show_stack_usage
 	struct mm_struct	*mm = get_task_mm(task);
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		vma = find_vma(mm, task->stack_start);
 		if (vma)
 			seq_printf(m, "Stack usage:\t%lu kB\n",
 				get_stack_usage_in_bytes(vma, task) >> 10);
 
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		mmput(mm);
 	}
 }
Index: mmotm-mm-accessor/fs/proc/base.c
===================================================================
--- mmotm-mm-accessor.orig/fs/proc/base.c
+++ mmotm-mm-accessor/fs/proc/base.c
@@ -1450,11 +1450,11 @@ struct file *get_mm_exe_file(struct mm_s
 
 	/* We need mmap_sem to protect against races with removal of
 	 * VM_EXECUTABLE vmas */
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	exe_file = mm->exe_file;
 	if (exe_file)
 		get_file(exe_file);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return exe_file;
 }
 
Index: mmotm-mm-accessor/fs/proc/task_nommu.c
===================================================================
--- mmotm-mm-accessor.orig/fs/proc/task_nommu.c
+++ mmotm-mm-accessor/fs/proc/task_nommu.c
@@ -21,7 +21,7 @@ void task_mem(struct seq_file *m, struct
 	struct rb_node *p;
 	unsigned long bytes = 0, sbytes = 0, slack = 0, size;
         
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 
@@ -73,7 +73,7 @@ void task_mem(struct seq_file *m, struct
 		"Shared:\t%8lu bytes\n",
 		bytes, slack, sbytes);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 }
 
 unsigned long task_vsize(struct mm_struct *mm)
@@ -82,12 +82,12 @@ unsigned long task_vsize(struct mm_struc
 	struct rb_node *p;
 	unsigned long vsize = 0;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		vsize += vma->vm_end - vma->vm_start;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return vsize;
 }
 
@@ -99,7 +99,7 @@ int task_statm(struct mm_struct *mm, int
 	struct rb_node *p;
 	int size = kobjsize(mm);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p)) {
 		vma = rb_entry(p, struct vm_area_struct, vm_rb);
 		size += kobjsize(vma);
@@ -114,7 +114,7 @@ int task_statm(struct mm_struct *mm, int
 		>> PAGE_SHIFT;
 	*data = (PAGE_ALIGN(mm->start_stack) - (mm->start_data & PAGE_MASK))
 		>> PAGE_SHIFT;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	size >>= PAGE_SHIFT;
 	size += *text + *data;
 	*resident = size;
@@ -193,7 +193,7 @@ static void *m_start(struct seq_file *m,
 		priv->task = NULL;
 		return NULL;
 	}
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	/* start from the Nth VMA */
 	for (p = rb_first(&mm->mm_rb); p; p = rb_next(p))
@@ -208,7 +208,7 @@ static void m_stop(struct seq_file *m, v
 
 	if (priv->task) {
 		struct mm_struct *mm = priv->task->mm;
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		mmput(mm);
 		put_task_struct(priv->task);
 	}
Index: mmotm-mm-accessor/fs/exec.c
===================================================================
--- mmotm-mm-accessor.orig/fs/exec.c
+++ mmotm-mm-accessor/fs/exec.c
@@ -233,7 +233,7 @@ static int __bprm_mm_init(struct linux_b
 	if (!vma)
 		return -ENOMEM;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	vma->vm_mm = mm;
 
 	/*
@@ -251,11 +251,11 @@ static int __bprm_mm_init(struct linux_b
 		goto err;
 
 	mm->stack_vm = mm->total_vm = 1;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	bprm->p = vma->vm_end - sizeof(void *);
 	return 0;
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
 	return err;
@@ -600,7 +600,7 @@ int setup_arg_pages(struct linux_binprm 
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	vm_flags = VM_STACK_FLAGS;
 
 	/*
@@ -637,7 +637,7 @@ int setup_arg_pages(struct linux_binprm 
 		ret = -EFAULT;
 
 out_unlock:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return ret;
 }
 EXPORT_SYMBOL(setup_arg_pages);
@@ -711,9 +711,9 @@ static int exec_mmap(struct mm_struct *m
 		 * through with the exec.  We must hold mmap_sem around
 		 * checking core_state and changing tsk->mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+		mm_read_lock(old_mm);
 		if (unlikely(old_mm->core_state)) {
-			up_read(&old_mm->mmap_sem);
+			mm_read_unlock(old_mm);
 			return -EINTR;
 		}
 	}
@@ -725,7 +725,7 @@ static int exec_mmap(struct mm_struct *m
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		mm_read_unlock(old_mm);
 		BUG_ON(active_mm != old_mm);
 		mm_update_next_owner(old_mm);
 		mmput(old_mm);
@@ -1642,7 +1642,7 @@ static int coredump_wait(int exit_code, 
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 	core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	if (unlikely(core_waiters < 0))
 		goto fail;
@@ -1790,12 +1790,12 @@ void do_coredump(long signr, int exit_co
 		goto fail;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	/*
 	 * If another thread got here first, or we are not dumpable, bail out.
 	 */
 	if (mm->core_state || !get_dumpable(mm)) {
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 		put_cred(cred);
 		goto fail;
 	}
Index: mmotm-mm-accessor/fs/aio.c
===================================================================
--- mmotm-mm-accessor.orig/fs/aio.c
+++ mmotm-mm-accessor/fs/aio.c
@@ -103,9 +103,9 @@ static void aio_free_ring(struct kioctx 
 		put_page(info->ring_pages[i]);
 
 	if (info->mmap_size) {
-		down_write(&ctx->mm->mmap_sem);
+		mm_write_lock(ctx->mm);
 		do_munmap(ctx->mm, info->mmap_base, info->mmap_size);
-		up_write(&ctx->mm->mmap_sem);
+		mm_write_unlock(ctx->mm);
 	}
 
 	if (info->ring_pages && info->ring_pages != info->internal_pages)
@@ -144,12 +144,12 @@ static int aio_setup_ring(struct kioctx 
 
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
-	down_write(&ctx->mm->mmap_sem);
+	mm_write_lock(ctx->mm);
 	info->mmap_base = do_mmap(NULL, 0, info->mmap_size, 
 				  PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE,
 				  0);
 	if (IS_ERR((void *)info->mmap_base)) {
-		up_write(&ctx->mm->mmap_sem);
+		mm_write_unlock(ctx->mm);
 		info->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
@@ -159,7 +159,7 @@ static int aio_setup_ring(struct kioctx 
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 
 					1, 0, info->ring_pages, NULL);
-	up_write(&ctx->mm->mmap_sem);
+	mm_write_unlock(ctx->mm);
 
 	if (unlikely(info->nr_pages != nr_pages)) {
 		aio_free_ring(ctx);
Index: mmotm-mm-accessor/fs/binfmt_som.c
===================================================================
--- mmotm-mm-accessor.orig/fs/binfmt_som.c
+++ mmotm-mm-accessor/fs/binfmt_som.c
@@ -147,10 +147,10 @@ static int map_som_binary(struct file *f
 	code_size = SOM_PAGEALIGN(hpuxhdr->exec_tsize);
 	current->mm->start_code = code_start;
 	current->mm->end_code = code_start + code_size;
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retval = do_mmap(file, code_start, code_size, prot,
 			flags, SOM_PAGESTART(hpuxhdr->exec_tfile));
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
@@ -158,20 +158,20 @@ static int map_som_binary(struct file *f
 	data_size = SOM_PAGEALIGN(hpuxhdr->exec_dsize);
 	current->mm->start_data = data_start;
 	current->mm->end_data = bss_start = data_start + data_size;
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retval = do_mmap(file, data_start, data_size,
 			prot | PROT_WRITE, flags,
 			SOM_PAGESTART(hpuxhdr->exec_dfile));
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
 	som_brk = bss_start + SOM_PAGEALIGN(hpuxhdr->exec_bsize);
 	current->mm->start_brk = current->mm->brk = som_brk;
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retval = do_mmap(NULL, bss_start, som_brk - bss_start,
 			prot | PROT_WRITE, MAP_FIXED | MAP_PRIVATE, 0);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (retval > 0 || retval < -1024)
 		retval = 0;
 out:
Index: mmotm-mm-accessor/fs/binfmt_flat.c
===================================================================
--- mmotm-mm-accessor.orig/fs/binfmt_flat.c
+++ mmotm-mm-accessor/fs/binfmt_flat.c
@@ -539,10 +539,10 @@ static int load_flat_file(struct linux_b
 		 */
 		DBG_FLT("BINFMT_FLAT: ROM mapping of file (we hope)\n");
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		textpos = do_mmap(bprm->file, 0, text_len, PROT_READ|PROT_EXEC,
 				  MAP_PRIVATE|MAP_EXECUTABLE, 0);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (!textpos || IS_ERR_VALUE(textpos)) {
 			if (!textpos)
 				textpos = (unsigned long) -ENOMEM;
@@ -553,10 +553,10 @@ static int load_flat_file(struct linux_b
 
 		len = data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
 		len = PAGE_ALIGN(len);
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		realdatastart = do_mmap(0, 0, len,
 			PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (realdatastart == 0 || IS_ERR_VALUE(realdatastart)) {
 			if (!realdatastart)
@@ -600,10 +600,10 @@ static int load_flat_file(struct linux_b
 
 		len = text_len + data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
 		len = PAGE_ALIGN(len);
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		textpos = do_mmap(0, 0, len,
 			PROT_READ | PROT_EXEC | PROT_WRITE, MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (!textpos || IS_ERR_VALUE(textpos)) {
 			if (!textpos)
Index: mmotm-mm-accessor/fs/binfmt_elf_fdpic.c
===================================================================
--- mmotm-mm-accessor.orig/fs/binfmt_elf_fdpic.c
+++ mmotm-mm-accessor/fs/binfmt_elf_fdpic.c
@@ -377,7 +377,7 @@ static int load_elf_fdpic_binary(struct 
 	if (stack_size < PAGE_SIZE * 2)
 		stack_size = PAGE_SIZE * 2;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	current->mm->start_brk = do_mmap(NULL, 0, stack_size,
 					 PROT_READ | PROT_WRITE | PROT_EXEC,
 					 MAP_PRIVATE | MAP_ANONYMOUS |
@@ -385,13 +385,13 @@ static int load_elf_fdpic_binary(struct 
 					 0);
 
 	if (IS_ERR_VALUE(current->mm->start_brk)) {
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		retval = current->mm->start_brk;
 		current->mm->start_brk = 0;
 		goto error_kill;
 	}
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	current->mm->brk = current->mm->start_brk;
 	current->mm->context.end_brk = current->mm->start_brk;
@@ -944,10 +944,10 @@ static int elf_fdpic_map_file_constdisp_
 	if (params->flags & ELF_FDPIC_FLAG_EXECUTABLE)
 		mflags |= MAP_EXECUTABLE;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	maddr = do_mmap(NULL, load_addr, top - base,
 			PROT_READ | PROT_WRITE | PROT_EXEC, mflags, 0);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	if (IS_ERR_VALUE(maddr))
 		return (int) maddr;
 
@@ -1093,10 +1093,10 @@ static int elf_fdpic_map_file_by_direct_
 
 		/* create the mapping */
 		disp = phdr->p_vaddr & ~PAGE_MASK;
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm);
 		maddr = do_mmap(file, maddr, phdr->p_memsz + disp, prot, flags,
 				phdr->p_offset - disp);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm);
 
 		kdebug("mmap[%d] <file> sz=%lx pr=%x fl=%x of=%lx --> %08lx",
 		       loop, phdr->p_memsz + disp, prot, flags,
@@ -1141,10 +1141,10 @@ static int elf_fdpic_map_file_by_direct_
 			unsigned long xmaddr;
 
 			flags |= MAP_FIXED | MAP_ANONYMOUS;
-			down_write(&mm->mmap_sem);
+			mm_write_lock(mm);
 			xmaddr = do_mmap(NULL, xaddr, excess - excess1,
 					 prot, flags, 0);
-			up_write(&mm->mmap_sem);
+			mm_write_unlock(mm);
 
 			kdebug("mmap[%d] <anon>"
 			       " ad=%lx sz=%lx pr=%x fl=%x of=0 --> %08lx",
Index: mmotm-mm-accessor/fs/binfmt_elf.c
===================================================================
--- mmotm-mm-accessor.orig/fs/binfmt_elf.c
+++ mmotm-mm-accessor/fs/binfmt_elf.c
@@ -81,9 +81,9 @@ static int set_brk(unsigned long start, 
 	end = ELF_PAGEALIGN(end);
 	if (end > start) {
 		unsigned long addr;
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		addr = do_brk(start, end - start);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (BAD_ADDR(addr))
 			return addr;
 	}
@@ -332,7 +332,7 @@ static unsigned long elf_map(struct file
 	if (!size)
 		return addr;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	/*
 	* total_size is the size of the ELF (interpreter) image.
 	* The _first_ mmap needs to know the full size, otherwise
@@ -349,7 +349,7 @@ static unsigned long elf_map(struct file
 	} else
 		map_addr = do_mmap(filep, addr, size, prot, type, off);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	return(map_addr);
 }
 
@@ -517,9 +517,9 @@ static unsigned long load_elf_interp(str
 		elf_bss = ELF_PAGESTART(elf_bss + ELF_MIN_ALIGN - 1);
 
 		/* Map the last of the bss segment */
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_brk(elf_bss, last_bss - elf_bss);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (BAD_ADDR(error))
 			goto out_close;
 	}
@@ -978,10 +978,10 @@ static int load_elf_binary(struct linux_
 		   and some applications "depend" upon this behavior.
 		   Since we do not have the power to recompile these, we
 		   emulate the SVr4 behavior. Sigh. */
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 	}
 
 #ifdef ELF_PLAT_INIT
@@ -1066,7 +1066,7 @@ static int load_elf_library(struct file 
 		eppnt++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	error = do_mmap(file,
 			ELF_PAGESTART(eppnt->p_vaddr),
 			(eppnt->p_filesz +
@@ -1075,7 +1075,7 @@ static int load_elf_library(struct file 
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			(eppnt->p_offset -
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (error != ELF_PAGESTART(eppnt->p_vaddr))
 		goto out_free_ph;
 
@@ -1089,9 +1089,9 @@ static int load_elf_library(struct file 
 			    ELF_MIN_ALIGN - 1);
 	bss = eppnt->p_memsz + eppnt->p_vaddr;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		do_brk(len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 	}
 	error = 0;
 
Index: mmotm-mm-accessor/fs/binfmt_aout.c
===================================================================
--- mmotm-mm-accessor.orig/fs/binfmt_aout.c
+++ mmotm-mm-accessor/fs/binfmt_aout.c
@@ -50,9 +50,9 @@ static int set_brk(unsigned long start, 
 	end = PAGE_ALIGN(end);
 	if (end > start) {
 		unsigned long addr;
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		addr = do_brk(start, end - start);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (BAD_ADDR(addr))
 			return addr;
 	}
@@ -290,9 +290,9 @@ static int load_aout_binary(struct linux
 		pos = 32;
 		map_size = ex.a_text+ex.a_data;
 #endif
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_brk(text_addr & PAGE_MASK, map_size);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (error != (text_addr & PAGE_MASK)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -323,9 +323,9 @@ static int load_aout_binary(struct linux
 
 		if (!bprm->file->f_op->mmap||((fd_offset & ~PAGE_MASK) != 0)) {
 			loff_t pos = fd_offset;
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			do_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 			bprm->file->f_op->read(bprm->file,
 					(char __user *)N_TXTADDR(ex),
 					ex.a_text+ex.a_data, &pos);
@@ -335,24 +335,24 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -429,9 +429,9 @@ static int load_aout_library(struct file
 			       "N_TXTOFF is not page aligned. Please convert library: %s\n",
 			       file->f_path.dentry->d_name.name);
 		}
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		do_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		
 		file->f_op->read(file, (char __user *)start_addr,
 			ex.a_text + ex.a_data, &pos);
@@ -442,12 +442,12 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	retval = error;
 	if (error != start_addr)
 		goto out;
@@ -455,9 +455,9 @@ static int load_aout_library(struct file
 	len = PAGE_ALIGN(ex.a_text + ex.a_data);
 	bss = ex.a_text + ex.a_data + ex.a_bss;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_brk(start_addr + len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		retval = error;
 		if (error != start_addr + len)
 			goto out;
Index: mmotm-mm-accessor/fs/ceph/file.c
===================================================================
--- mmotm-mm-accessor.orig/fs/ceph/file.c
+++ mmotm-mm-accessor/fs/ceph/file.c
@@ -279,10 +279,10 @@ static struct page **get_direct_page_vec
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	rc = get_user_pages(current, current->mm, (unsigned long)data,
 			    num_pages, 0, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	if (rc < 0)
 		goto fail;
 	return pages;
Index: mmotm-mm-accessor/fs/fuse/dev.c
===================================================================
--- mmotm-mm-accessor.orig/fs/fuse/dev.c
+++ mmotm-mm-accessor/fs/fuse/dev.c
@@ -551,10 +551,10 @@ static int fuse_copy_fill(struct fuse_co
 		cs->iov++;
 		cs->nr_segs--;
 	}
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	err = get_user_pages(current, current->mm, cs->addr, 1, cs->write, 0,
 			     &cs->pg, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	if (err < 0)
 		return err;
 	BUG_ON(err != 1);
Index: mmotm-mm-accessor/fs/nfs/direct.c
===================================================================
--- mmotm-mm-accessor.orig/fs/nfs/direct.c
+++ mmotm-mm-accessor/fs/nfs/direct.c
@@ -309,10 +309,10 @@ static ssize_t nfs_direct_read_schedule_
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 		if (result < 0) {
 			nfs_readdata_free(data);
 			break;
@@ -730,10 +730,10 @@ static ssize_t nfs_direct_write_schedule
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 		if (result < 0) {
 			nfs_writedata_free(data);
 			break;
Index: mmotm-mm-accessor/fs/fuse/file.c
===================================================================
--- mmotm-mm-accessor.orig/fs/fuse/file.c
+++ mmotm-mm-accessor/fs/fuse/file.c
@@ -991,10 +991,10 @@ static int fuse_get_user_pages(struct fu
 	nbytes = min_t(size_t, nbytes, FUSE_MAX_PAGES_PER_REQ << PAGE_SHIFT);
 	npages = (nbytes + offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	npages = clamp(npages, 1, FUSE_MAX_PAGES_PER_REQ);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	npages = get_user_pages(current, current->mm, user_addr, npages, !write,
 				0, req->pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	if (npages < 0)
 		return npages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
