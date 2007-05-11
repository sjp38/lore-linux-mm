Message-Id: <20070511132321.984615201@chello.nl>
References: <20070511131541.992688403@chello.nl>
Date: Fri, 11 May 2007 15:15:43 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/2] mm: change mmap_sem over to the scalable rw_mutex
Content-Disposition: inline; filename=use_rwmutex.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Change the mmap_sem over to the new rw_mtuex.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/kernel/osf_sys.c                    |    4 
 arch/alpha/kernel/traps.c                      |    4 
 arch/alpha/mm/fault.c                          |    8 -
 arch/arm/kernel/sys_arm.c                      |    8 -
 arch/arm/kernel/traps.c                        |    6 -
 arch/arm/mm/fault.c                            |   10 -
 arch/arm26/kernel/sys_arm.c                    |    8 -
 arch/arm26/mm/fault.c                          |    4 
 arch/avr32/kernel/sys_avr32.c                  |    4 
 arch/avr32/mm/fault.c                          |   12 +-
 arch/blackfin/kernel/sys_bfin.c                |    4 
 arch/cris/arch-v32/drivers/cryptocop.c         |    8 -
 arch/cris/kernel/sys_cris.c                    |    4 
 arch/cris/mm/fault.c                           |   12 +-
 arch/frv/kernel/sys_frv.c                      |    8 -
 arch/frv/mm/fault.c                            |   10 -
 arch/h8300/kernel/sys_h8300.c                  |    8 -
 arch/i386/kernel/sys_i386.c                    |    4 
 arch/i386/kernel/sysenter.c                    |    4 
 arch/i386/lib/usercopy.c                       |    8 -
 arch/i386/mm/fault.c                           |   16 +--
 arch/ia64/ia32/binfmt_elf32.c                  |   24 ++--
 arch/ia64/ia32/sys_ia32.c                      |   28 ++---
 arch/ia64/kernel/perfmon.c                     |   12 +-
 arch/ia64/kernel/sys_ia64.c                    |   14 +-
 arch/ia64/mm/fault.c                           |   16 +--
 arch/ia64/mm/init.c                            |   12 +-
 arch/m32r/kernel/sys_m32r.c                    |    4 
 arch/m32r/mm/fault.c                           |   16 +--
 arch/m68k/kernel/sys_m68k.c                    |    8 -
 arch/m68k/mm/fault.c                           |   10 -
 arch/m68knommu/kernel/sys_m68k.c               |    4 
 arch/mips/kernel/irixelf.c                     |   36 +++----
 arch/mips/kernel/linux32.c                     |    4 
 arch/mips/kernel/syscall.c                     |    4 
 arch/mips/kernel/sysirix.c                     |   16 +--
 arch/mips/mm/fault.c                           |   12 +-
 arch/parisc/kernel/sys_parisc.c                |    4 
 arch/parisc/kernel/traps.c                     |    6 -
 arch/parisc/mm/fault.c                         |    8 -
 arch/powerpc/kernel/syscalls.c                 |    4 
 arch/powerpc/kernel/vdso.c                     |    6 -
 arch/powerpc/mm/fault.c                        |   18 +--
 arch/powerpc/mm/tlb_32.c                       |    2 
 arch/powerpc/platforms/cell/spufs/fault.c      |    6 -
 arch/ppc/mm/fault.c                            |   14 +-
 arch/s390/kernel/compat_linux.c                |    4 
 arch/s390/kernel/sys_s390.c                    |    4 
 arch/s390/lib/uaccess_pt.c                     |   10 -
 arch/s390/mm/fault.c                           |   16 +--
 arch/sh/kernel/sys_sh.c                        |    4 
 arch/sh/kernel/vsyscall/vsyscall.c             |    4 
 arch/sh/mm/cache-sh4.c                         |    2 
 arch/sh/mm/fault.c                             |   12 +-
 arch/sh64/kernel/sys_sh64.c                    |    4 
 arch/sh64/mm/fault.c                           |   12 +-
 arch/sparc/kernel/sys_sparc.c                  |    8 -
 arch/sparc/kernel/sys_sunos.c                  |    8 -
 arch/sparc/mm/fault.c                          |   18 +--
 arch/sparc64/kernel/binfmt_aout32.c            |   36 +++----
 arch/sparc64/kernel/sys_sparc.c                |   12 +-
 arch/sparc64/kernel/sys_sparc32.c              |    4 
 arch/sparc64/kernel/sys_sunos32.c              |    8 -
 arch/sparc64/mm/fault.c                        |   14 +-
 arch/sparc64/solaris/misc.c                    |    4 
 arch/um/kernel/syscall.c                       |    4 
 arch/um/kernel/trap.c                          |    8 -
 arch/v850/kernel/syscalls.c                    |    4 
 arch/x86_64/ia32/ia32_aout.c                   |   32 +++---
 arch/x86_64/ia32/ia32_binfmt.c                 |    6 -
 arch/x86_64/ia32/sys_ia32.c                    |    8 -
 arch/x86_64/ia32/syscall32.c                   |    4 
 arch/x86_64/kernel/sys_x86_64.c                |    4 
 arch/x86_64/mm/fault.c                         |   16 +--
 arch/x86_64/mm/pageattr.c                      |   10 -
 arch/xtensa/kernel/syscall.c                   |    4 
 arch/xtensa/mm/fault.c                         |   12 +-
 drivers/char/drm/drm_bufs.c                    |    8 -
 drivers/char/drm/i810_dma.c                    |    8 -
 drivers/char/drm/i830_dma.c                    |    8 -
 drivers/char/drm/via_dmablit.c                 |    4 
 drivers/char/mem.c                             |    6 -
 drivers/dma/iovlock.c                          |    4 
 drivers/infiniband/core/umem.c                 |   18 +--
 drivers/infiniband/hw/ipath/ipath_user_pages.c |   18 +--
 drivers/media/video/cafe_ccic.c                |    2 
 drivers/media/video/ivtv/ivtv-udma.c           |    4 
 drivers/media/video/ivtv/ivtv-yuv.c            |    4 
 drivers/media/video/video-buf.c                |    4 
 drivers/oprofile/buffer_sync.c                 |   12 +-
 drivers/scsi/sg.c                              |    4 
 drivers/scsi/st.c                              |    4 
 drivers/video/pvr2fb.c                         |    4 
 fs/aio.c                                       |   10 -
 fs/binfmt_aout.c                               |   40 +++----
 fs/binfmt_elf.c                                |   32 +++---
 fs/binfmt_elf_fdpic.c                          |   18 +--
 fs/binfmt_flat.c                               |   12 +-
 fs/binfmt_som.c                                |   12 +-
 fs/bio.c                                       |    4 
 fs/block_dev.c                                 |    4 
 fs/direct-io.c                                 |    4 
 fs/exec.c                                      |   22 ++--
 fs/fuse/dev.c                                  |    4 
 fs/fuse/file.c                                 |    4 
 fs/hugetlbfs/inode.c                           |    2 
 fs/nfs/direct.c                                |    8 -
 fs/proc/task_mmu.c                             |   14 +-
 fs/proc/task_nommu.c                           |   20 +--
 fs/splice.c                                    |    6 -
 include/linux/futex.h                          |    2 
 include/linux/init_task.h                      |    1 
 include/linux/mempolicy.h                      |    2 
 include/linux/sched.h                          |    3 
 include/linux/uaccess.h                        |    4 
 ipc/shm.c                                      |    8 -
 kernel/acct.c                                  |    6 -
 kernel/auditsc.c                               |    4 
 kernel/cpuset.c                                |    6 -
 kernel/exit.c                                  |   14 +-
 kernel/fork.c                                  |   19 ++-
 kernel/futex.c                                 |  128 ++++++++++++-------------
 kernel/relay.c                                 |    2 
 mm/filemap.c                                   |    6 -
 mm/fremap.c                                    |   12 +-
 mm/madvise.c                                   |   21 +---
 mm/memory.c                                    |   32 +++---
 mm/mempolicy.c                                 |   24 ++--
 mm/migrate.c                                   |   12 +-
 mm/mincore.c                                   |    4 
 mm/mlock.c                                     |   18 +--
 mm/mmap.c                                      |   26 ++---
 mm/mprotect.c                                  |    6 -
 mm/mremap.c                                    |    6 -
 mm/msync.c                                     |    8 -
 mm/nommu.c                                     |   18 +--
 mm/prio_tree.c                                 |    6 -
 mm/rmap.c                                      |    6 -
 mm/swapfile.c                                  |    6 -
 139 files changed, 740 insertions(+), 736 deletions(-)

Index: linux-2.6/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-2.6.orig/arch/alpha/kernel/osf_sys.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/alpha/kernel/osf_sys.c	2007-05-11 15:06:00.000000000 +0200
@@ -193,9 +193,9 @@ osf_mmap(unsigned long addr, unsigned lo
 			goto out;
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
  out:
Index: linux-2.6/arch/alpha/kernel/traps.c
===================================================================
--- linux-2.6.orig/arch/alpha/kernel/traps.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/alpha/kernel/traps.c	2007-05-11 15:06:00.000000000 +0200
@@ -1048,12 +1048,12 @@ give_sigsegv:
 		info.si_code = SEGV_ACCERR;
 	else {
 		struct mm_struct *mm = current->mm;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		if (find_vma(mm, (unsigned long)va))
 			info.si_code = SEGV_ACCERR;
 		else
 			info.si_code = SEGV_MAPERR;
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 	}
 	info.si_addr = va;
 	send_sig_info(SIGSEGV, &info, current);
Index: linux-2.6/arch/alpha/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/alpha/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/alpha/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -115,7 +115,7 @@ do_page_fault(unsigned long address, uns
 		goto vmalloc_fault;
 #endif
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -147,7 +147,7 @@ do_page_fault(unsigned long address, uns
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
 	fault = handle_mm_fault(mm, vma, address, cause > 0);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	switch (fault) {
 	      case VM_FAULT_MINOR:
@@ -168,7 +168,7 @@ do_page_fault(unsigned long address, uns
 	/* Something tried to access memory that isn't in our memory map.
 	   Fix it, but check if it's kernel or user first.  */
  bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	if (user_mode(regs))
 		goto do_sigsegv;
@@ -194,7 +194,7 @@ do_page_fault(unsigned long address, uns
  out_of_memory:
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk(KERN_ALERT "VM: killing process %s(%d)\n",
Index: linux-2.6/arch/arm/kernel/sys_arm.c
===================================================================
--- linux-2.6.orig/arch/arm/kernel/sys_arm.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/arm/kernel/sys_arm.c	2007-05-11 15:06:00.000000000 +0200
@@ -72,9 +72,9 @@ inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -118,9 +118,9 @@ sys_arm_mremap(unsigned long addr, unsig
 	if (flags & MREMAP_FIXED && new_addr < FIRST_USER_ADDRESS)
 		goto out;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 out:
 	return ret;
Index: linux-2.6/arch/arm/kernel/traps.c
===================================================================
--- linux-2.6.orig/arch/arm/kernel/traps.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/arm/kernel/traps.c	2007-05-11 15:06:00.000000000 +0200
@@ -504,7 +504,7 @@ asmlinkage int arm_syscall(int no, struc
 		spinlock_t *ptl;
 
 		regs->ARM_cpsr &= ~PSR_C_BIT;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		pgd = pgd_offset(mm, addr);
 		if (!pgd_present(*pgd))
 			goto bad_access;
@@ -523,11 +523,11 @@ asmlinkage int arm_syscall(int no, struc
 			regs->ARM_cpsr |= PSR_C_BIT;
 		}
 		pte_unmap_unlock(pte, ptl);
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		return val;
 
 		bad_access:
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		/* simulate a write access fault */
 		do_DataAbort(addr, 15 + (1 << 11), regs);
 		return -1;
Index: linux-2.6/arch/arm/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/arm/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -203,9 +203,9 @@ survive:
 	/*
 	 * If we are out of memory for pid1, sleep for a while and retry
 	 */
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	yield();
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	goto survive;
 
 check_stack:
@@ -237,14 +237,14 @@ do_page_fault(unsigned long addr, unsign
 	 * validly references user space from well defined areas of the code,
 	 * we can bug out early if this is from code which shouldn't.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!down_read_trylock(&mm->mmap_lock)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->ARM_pc))
 			goto no_context;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	fault = __do_page_fault(mm, addr, fsr, tsk);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Handle the "normal" case first - VM_FAULT_MAJOR / VM_FAULT_MINOR
Index: linux-2.6/arch/arm26/kernel/sys_arm.c
===================================================================
--- linux-2.6.orig/arch/arm26/kernel/sys_arm.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/arm26/kernel/sys_arm.c	2007-05-11 15:06:00.000000000 +0200
@@ -77,9 +77,9 @@ inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -127,9 +127,9 @@ sys_arm_mremap(unsigned long addr, unsig
 	if (flags & MREMAP_FIXED && new_addr < FIRST_USER_ADDRESS)
 		goto out;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 out:
 	return ret;
Index: linux-2.6/arch/arm26/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm26/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/arm26/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -218,9 +218,9 @@ int do_page_fault(unsigned long addr, un
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	fault = __do_page_fault(mm, addr, fsr, tsk);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Handle the "normal" case first
Index: linux-2.6/arch/avr32/kernel/sys_avr32.c
===================================================================
--- linux-2.6.orig/arch/avr32/kernel/sys_avr32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/avr32/kernel/sys_avr32.c	2007-05-11 15:06:00.000000000 +0200
@@ -41,9 +41,9 @@ asmlinkage long sys_mmap2(unsigned long 
 			return error;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, offset);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/avr32/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/avr32/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/avr32/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -97,7 +97,7 @@ asmlinkage void do_page_fault(unsigned l
 
 	local_irq_enable();
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -159,7 +159,7 @@ survive:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 	/*
@@ -167,7 +167,7 @@ survive:
 	 * map. Fix it, but check if it's kernel or user first...
 	 */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	if (user_mode(regs)) {
 		if (exception_trace)
@@ -221,10 +221,10 @@ no_context:
 	 * that made us unable to handle the page fault gracefully.
 	 */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: Killing process %s\n", tsk->comm);
@@ -233,7 +233,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Kernel mode? Handle exceptions or die */
 	signr = SIGBUS;
Index: linux-2.6/arch/cris/arch-v32/drivers/cryptocop.c
===================================================================
--- linux-2.6.orig/arch/cris/arch-v32/drivers/cryptocop.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/cris/arch-v32/drivers/cryptocop.c	2007-05-11 15:06:00.000000000 +0200
@@ -2715,7 +2715,7 @@ static int cryptocop_ioctl_process(struc
 	}
 
 	/* Acquire the mm page semaphore. */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 
 	err = get_user_pages(current,
 			     current->mm,
@@ -2727,7 +2727,7 @@ static int cryptocop_ioctl_process(struc
 			     NULL);
 
 	if (err < 0) {
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		nooutpages = noinpages = 0;
 		DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages indata\n"));
 		goto error_cleanup;
@@ -2742,7 +2742,7 @@ static int cryptocop_ioctl_process(struc
 				     0, /* no force */
 				     outpages,
 				     NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		if (err < 0) {
 			nooutpages = 0;
 			DEBUG_API(printk("cryptocop_ioctl_process: get_user_pages outdata\n"));
@@ -2750,7 +2750,7 @@ static int cryptocop_ioctl_process(struc
 		}
 		nooutpages = err;
 	} else {
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 	}
 
 	/* Add 6 to nooutpages to make room for possibly inserted buffers for storing digest and
Index: linux-2.6/arch/cris/kernel/sys_cris.c
===================================================================
--- linux-2.6.orig/arch/cris/kernel/sys_cris.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/cris/kernel/sys_cris.c	2007-05-11 15:06:00.000000000 +0200
@@ -60,9 +60,9 @@ do_mmap2(unsigned long addr, unsigned lo
                         goto out;
         }
 
-        down_write(&current->mm->mmap_sem);
+        rw_mutex_write_lock(&current->mm->mmap_lock);
         error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-        up_write(&current->mm->mmap_sem);
+        rw_mutex_write_unlock(&current->mm->mmap_lock);
 
         if (file)
                 fput(file);
Index: linux-2.6/arch/cris/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/cris/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/cris/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -104,7 +104,7 @@
  *  than >= VMALLOC_START.
  *
  *  Revision 1.12  2001/04/04 10:51:14  bjornw
- *  mmap_sem is grabbed for reading
+ *  mmap_lock is grabbed for reading
  *
  *  Revision 1.11  2001/03/23 07:36:07  starvik
  *  Corrected according to review remarks
@@ -235,7 +235,7 @@ do_page_fault(unsigned long address, str
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -296,7 +296,7 @@ do_page_fault(unsigned long address, str
 		goto out_of_memory;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 	/*
@@ -305,7 +305,7 @@ do_page_fault(unsigned long address, str
 	 */
 
  bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
  bad_area_nosemaphore:
 	DPG(show_registers(regs));
@@ -356,14 +356,14 @@ do_page_fault(unsigned long address, str
 	 */
 
  out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	printk("VM: killing process %s\n", tsk->comm);
 	if (user_mode(regs))
 		do_exit(SIGKILL);
 	goto no_context;
 
  do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/frv/kernel/sys_frv.c
===================================================================
--- linux-2.6.orig/arch/frv/kernel/sys_frv.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/frv/kernel/sys_frv.c	2007-05-11 15:06:00.000000000 +0200
@@ -68,9 +68,9 @@ asmlinkage long sys_mmap2(unsigned long 
 
 	pgoff >>= (PAGE_SHIFT - 12);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -113,9 +113,9 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/frv/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/frv/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -81,7 +81,7 @@ asmlinkage void do_page_fault(int datamm
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma(mm, ear0);
 	if (!vma)
@@ -175,7 +175,7 @@ asmlinkage void do_page_fault(int datamm
 		goto out_of_memory;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -183,7 +183,7 @@ asmlinkage void do_page_fault(int datamm
  * Fix it, but check if it's kernel or user first..
  */
  bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (user_mode(__frame)) {
@@ -255,14 +255,14 @@ asmlinkage void do_page_fault(int datamm
  * us unable to handle the page fault gracefully.
  */
  out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	printk("VM: killing process %s\n", current->comm);
 	if (user_mode(__frame))
 		do_exit(SIGKILL);
 	goto no_context;
 
  do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/h8300/kernel/sys_h8300.c
===================================================================
--- linux-2.6.orig/arch/h8300/kernel/sys_h8300.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/h8300/kernel/sys_h8300.c	2007-05-11 15:06:00.000000000 +0200
@@ -59,9 +59,9 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -146,9 +146,9 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/i386/kernel/sys_i386.c
===================================================================
--- linux-2.6.orig/arch/i386/kernel/sys_i386.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/i386/kernel/sys_i386.c	2007-05-11 15:06:00.000000000 +0200
@@ -55,9 +55,9 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/i386/kernel/sysenter.c
===================================================================
--- linux-2.6.orig/arch/i386/kernel/sysenter.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/i386/kernel/sysenter.c	2007-05-11 15:06:00.000000000 +0200
@@ -271,7 +271,7 @@ int arch_setup_additional_pages(struct l
 	int ret = 0;
 	bool compat;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 
 	/* Test compat mode once here, in case someone
 	   changes it via sysctl */
@@ -312,7 +312,7 @@ int arch_setup_additional_pages(struct l
 		(void *)VDSO_SYM(&SYSENTER_RETURN);
 
   up_fail:
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 
 	return ret;
 }
Index: linux-2.6/arch/i386/lib/usercopy.c
===================================================================
--- linux-2.6.orig/arch/i386/lib/usercopy.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/i386/lib/usercopy.c	2007-05-11 15:06:00.000000000 +0200
@@ -744,18 +744,18 @@ unsigned long __copy_to_user_ll(void __u
 				len = n;
 
 survive:
-			down_read(&current->mm->mmap_sem);
+			rw_mutex_read_lock(&current->mm->mmap_lock);
 			retval = get_user_pages(current, current->mm,
 					(unsigned long )to, 1, 1, 0, &pg, NULL);
 
 			if (retval == -ENOMEM && is_init(current)) {
-				up_read(&current->mm->mmap_sem);
+				rw_mutex_read_unlock(&current->mm->mmap_lock);
 				congestion_wait(WRITE, HZ/50);
 				goto survive;
 			}
 
 			if (retval != 1) {
-				up_read(&current->mm->mmap_sem);
+				rw_mutex_read_unlock(&current->mm->mmap_lock);
 		       		break;
 		       	}
 
@@ -764,7 +764,7 @@ survive:
 			kunmap_atomic(maddr, KM_USER0);
 			set_page_dirty_lock(pg);
 			put_page(pg);
-			up_read(&current->mm->mmap_sem);
+			rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 			from += len;
 			to += len;
Index: linux-2.6/arch/i386/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/i386/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -356,7 +356,7 @@ fastcall void __kprobes do_page_fault(st
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunatly, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
+	 * erroneous fault occurring in a code path which already holds mmap_lock
 	 * we will deadlock attempting to validate the fault against the
 	 * address space.  Luckily the kernel only validly references user
 	 * space from well defined areas of code, which are listed in the
@@ -368,11 +368,11 @@ fastcall void __kprobes do_page_fault(st
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!rw_mutex_read_trylock(&mm->mmap_lock)) {
 		if ((error_code & 4) == 0 &&
 		    !search_exception_tables(regs->eip))
 			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	vma = find_vma(mm, address);
@@ -445,7 +445,7 @@ good_area:
 		if (bit < 32)
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -453,7 +453,7 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -575,10 +575,10 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(tsk)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -587,7 +587,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & 4))
Index: linux-2.6/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6.orig/arch/ia64/ia32/binfmt_elf32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/ia32/binfmt_elf32.c	2007-05-11 15:06:00.000000000 +0200
@@ -99,15 +99,15 @@ ia64_elf32_init (struct pt_regs *regs)
 		vma->vm_page_prot = PAGE_SHARED;
 		vma->vm_flags = VM_READ|VM_MAYREAD|VM_RESERVED;
 		vma->vm_ops = &ia32_shared_page_vm_ops;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		{
 			if (insert_vm_struct(current->mm, vma)) {
 				kmem_cache_free(vm_area_cachep, vma);
-				up_write(&current->mm->mmap_sem);
+				rw_mutex_write_unlock(&current->mm->mmap_lock);
 				BUG();
 			}
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 	/*
@@ -125,15 +125,15 @@ ia64_elf32_init (struct pt_regs *regs)
 		vma->vm_flags = VM_READ | VM_MAYREAD | VM_EXEC
 				| VM_MAYEXEC | VM_RESERVED;
 		vma->vm_ops = &ia32_gate_page_vm_ops;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		{
 			if (insert_vm_struct(current->mm, vma)) {
 				kmem_cache_free(vm_area_cachep, vma);
-				up_write(&current->mm->mmap_sem);
+				rw_mutex_write_unlock(&current->mm->mmap_lock);
 				BUG();
 			}
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 	/*
@@ -147,15 +147,15 @@ ia64_elf32_init (struct pt_regs *regs)
 		vma->vm_end = vma->vm_start + PAGE_ALIGN(IA32_LDT_ENTRIES*IA32_LDT_ENTRY_SIZE);
 		vma->vm_page_prot = PAGE_SHARED;
 		vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		{
 			if (insert_vm_struct(current->mm, vma)) {
 				kmem_cache_free(vm_area_cachep, vma);
-				up_write(&current->mm->mmap_sem);
+				rw_mutex_write_unlock(&current->mm->mmap_lock);
 				BUG();
 			}
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 	ia64_psr(regs)->ac = 0;		/* turn off alignment checking */
@@ -215,7 +215,7 @@ ia32_setup_arg_pages (struct linux_binpr
 	if (!mpnt)
 		return -ENOMEM;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	{
 		mpnt->vm_mm = current->mm;
 		mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
@@ -229,7 +229,7 @@ ia32_setup_arg_pages (struct linux_binpr
 		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC)?
 					PAGE_COPY_EXEC: PAGE_COPY;
 		if ((ret = insert_vm_struct(current->mm, mpnt))) {
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 			kmem_cache_free(vm_area_cachep, mpnt);
 			return ret;
 		}
@@ -244,7 +244,7 @@ ia32_setup_arg_pages (struct linux_binpr
 		}
 		stack_base += PAGE_SIZE;
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	/* Can't do it in ia64_elf32_init(). Needs to be done before calls to
 	   elf32_map() */
Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c	2007-05-11 15:06:00.000000000 +0200
@@ -213,12 +213,12 @@ mmap_subpage (struct file *file, unsigne
 	if (old_prot)
 		copy_from_user(page, (void __user *) PAGE_START(start), PAGE_SIZE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	{
 		ret = do_mmap(NULL, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
 			      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (IS_ERR((void *) ret))
 		goto out;
@@ -471,7 +471,7 @@ __ia32_set_pp(unsigned int start, unsign
 static void
 ia32_set_pp(unsigned int start, unsigned int end, int flags)
 {
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (flags & MAP_FIXED) {
 		/*
 		 * MAP_FIXED may lead to overlapping mmap. When this happens,
@@ -489,7 +489,7 @@ ia32_set_pp(unsigned int start, unsigned
 		if (offset_in_page(end))
 			__ia32_set_pp(PAGE_START(end), end, flags);
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 }
 
 /*
@@ -559,7 +559,7 @@ ia32_unset_pp(unsigned int *startp, unsi
 	unsigned int start = *startp, end = *endp;
 	int ret = 0;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	__ia32_delete_pp_range(PAGE_ALIGN(start), PAGE_START(end));
 
@@ -594,7 +594,7 @@ ia32_unset_pp(unsigned int *startp, unsi
 	}
 
  out:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
 
@@ -652,7 +652,7 @@ ia32_compare_pp(unsigned int *startp, un
 	unsigned int start = *startp, end = *endp;
 	int retval = 0;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	if (end < PAGE_ALIGN(start)) {
 		retval = __ia32_compare_pp(start, end);
@@ -677,7 +677,7 @@ ia32_compare_pp(unsigned int *startp, un
 	}
 
  out:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return retval;
 }
 
@@ -745,11 +745,11 @@ ia32_copy_partial_page_list(struct task_
 		p->thread.ppl = ia32_init_pp_list();
 		if (!p->thread.ppl)
 			return -ENOMEM;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		{
 			retval = __ia32_copy_pp_list(p->thread.ppl);
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 	return retval;
@@ -821,7 +821,7 @@ emulate_mmap (struct file *file, unsigne
 	DBG("mmap_body: mapping [0x%lx-0x%lx) %s with poff 0x%llx\n", pstart, pend,
 	    is_congruent ? "congruent" : "not congruent", poff);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	{
 		if (!(flags & MAP_ANONYMOUS) && is_congruent)
 			ret = do_mmap(file, pstart, pend - pstart, prot, flags | MAP_FIXED, poff);
@@ -830,7 +830,7 @@ emulate_mmap (struct file *file, unsigne
 				      prot | ((flags & MAP_ANONYMOUS) ? 0 : PROT_WRITE),
 				      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (IS_ERR((void *) ret))
 		return ret;
@@ -904,11 +904,11 @@ ia32_do_mmap (struct file *file, unsigne
 	}
 	mutex_unlock(&ia32_mmap_mutex);
 #else
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	{
 		addr = do_mmap(file, addr, len, prot, flags, offset);
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 #endif
 	DBG("ia32_do_mmap: returning 0x%lx\n", addr);
 	return addr;
Index: linux-2.6/arch/ia64/kernel/perfmon.c
===================================================================
--- linux-2.6.orig/arch/ia64/kernel/perfmon.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/kernel/perfmon.c	2007-05-11 15:06:00.000000000 +0200
@@ -1451,13 +1451,13 @@ pfm_remove_smpl_mapping(struct task_stru
 	/*
 	 * does the actual unmapping
 	 */
-	down_write(&task->mm->mmap_sem);
+	rw_mutex_write_lock(&task->mm->mmap_lock);
 
 	DPRINT(("down_write done smpl_vaddr=%p size=%lu\n", vaddr, size));
 
 	r = pfm_do_munmap(task->mm, (unsigned long)vaddr, size, 0);
 
-	up_write(&task->mm->mmap_sem);
+	rw_mutex_write_unlock(&task->mm->mmap_lock);
 	if (r !=0) {
 		printk(KERN_ERR "perfmon: [%d] unable to unmap sampling buffer @%p size=%lu\n", task->pid, vaddr, size);
 	}
@@ -2366,13 +2366,13 @@ pfm_smpl_buffer_alloc(struct task_struct
 	 * now we atomically find some area in the address space and
 	 * remap the buffer in it.
 	 */
-	down_write(&task->mm->mmap_sem);
+	rw_mutex_write_lock(&task->mm->mmap_lock);
 
 	/* find some free area in address space, must have mmap sem held */
 	vma->vm_start = pfm_get_unmapped_area(NULL, 0, size, 0, MAP_PRIVATE|MAP_ANONYMOUS, 0);
 	if (vma->vm_start == 0UL) {
 		DPRINT(("Cannot find unmapped area for size %ld\n", size));
-		up_write(&task->mm->mmap_sem);
+		rw_mutex_write_unlock(&task->mm->mmap_lock);
 		goto error;
 	}
 	vma->vm_end = vma->vm_start + size;
@@ -2383,7 +2383,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	/* can only be applied to current task, need to have the mm semaphore held when called */
 	if (pfm_remap_buffer(vma, (unsigned long)smpl_buf, vma->vm_start, size)) {
 		DPRINT(("Can't remap buffer\n"));
-		up_write(&task->mm->mmap_sem);
+		rw_mutex_write_unlock(&task->mm->mmap_lock);
 		goto error;
 	}
 
@@ -2398,7 +2398,7 @@ pfm_smpl_buffer_alloc(struct task_struct
 	mm->total_vm  += size >> PAGE_SHIFT;
 	vm_stat_account(vma->vm_mm, vma->vm_flags, vma->vm_file,
 							vma_pages(vma));
-	up_write(&task->mm->mmap_sem);
+	rw_mutex_write_unlock(&task->mm->mmap_lock);
 
 	/*
 	 * keep track of user level virtual address
Index: linux-2.6/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-2.6.orig/arch/ia64/kernel/sys_ia64.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/kernel/sys_ia64.c	2007-05-11 15:06:00.000000000 +0200
@@ -106,9 +106,9 @@ ia64_brk (unsigned long brk)
 	/*
 	 * Most of this replicates the code in sys_brk() except for an additional safety
 	 * check and the clearing of r8.  However, we can't call sys_brk() because we need
-	 * to acquire the mmap_sem before we can do the test...
+	 * to acquire the mmap_lock before we can do the test...
 	 */
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 
 	if (brk < mm->end_code)
 		goto out;
@@ -144,7 +144,7 @@ set_brk:
 	mm->brk = brk;
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	force_successful_syscall_return();
 	return retval;
 }
@@ -209,9 +209,9 @@ do_mmap2 (unsigned long addr, unsigned l
 		goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 out:	if (file)
 		fput(file);
@@ -254,11 +254,11 @@ ia64_mremap (unsigned long addr, unsigne
 					unsigned long flags,
 					unsigned long new_addr);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	{
 		addr = do_mremap(addr, old_len, new_len, flags, new_addr);
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (IS_ERR((void *) addr))
 		return addr;
Index: linux-2.6/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -93,8 +93,8 @@ ia64_do_page_fault (unsigned long addres
 	struct siginfo si;
 	unsigned long mask;
 
-	/* mmap_sem is performance critical.... */
-	prefetchw(&mm->mmap_sem);
+	/* mmap_lock is performance critical.... */
+	prefetchw(&mm->mmap_lock);
 
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the fault..
@@ -105,7 +105,7 @@ ia64_do_page_fault (unsigned long addres
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 	/*
 	 * If fault is in region 5 and we are in the kernel, we may already
-	 * have the mmap_sem (pfn_valid macro is called during mmap). There
+	 * have the mmap_lock (pfn_valid macro is called during mmap). There
 	 * is no vma for region 5 addr's anyway, so skip getting the semaphore
 	 * and go directly to the exception handling code.
 	 */
@@ -121,7 +121,7 @@ ia64_do_page_fault (unsigned long addres
 					SIGSEGV) == NOTIFY_STOP)
 		return;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma_prev(mm, address, &prev_vma);
 	if (!vma)
@@ -180,7 +180,7 @@ ia64_do_page_fault (unsigned long addres
 	      default:
 		BUG();
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
   check_expansion:
@@ -209,7 +209,7 @@ ia64_do_page_fault (unsigned long addres
 	goto good_area;
 
   bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 #ifdef CONFIG_VIRTUAL_MEM_MAP
   bad_area_no_up:
 #endif
@@ -278,10 +278,10 @@ ia64_do_page_fault (unsigned long addres
 	return;
 
   out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk(KERN_CRIT "VM: killing process %s\n", current->comm);
Index: linux-2.6/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/init.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ia64/mm/init.c	2007-05-11 15:06:00.000000000 +0200
@@ -183,13 +183,13 @@ ia64_init_addr_space (void)
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = protection_map[VM_DATA_DEFAULT_FLAGS & 0x7];
 		vma->vm_flags = VM_DATA_DEFAULT_FLAGS|VM_GROWSUP|VM_ACCOUNT;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		if (insert_vm_struct(current->mm, vma)) {
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 			kmem_cache_free(vm_area_cachep, vma);
 			return;
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 	/* map NaT-page at address zero to speed up speculative dereferencing of NULL: */
@@ -200,13 +200,13 @@ ia64_init_addr_space (void)
 			vma->vm_end = PAGE_SIZE;
 			vma->vm_page_prot = __pgprot(pgprot_val(PAGE_READONLY) | _PAGE_MA_NAT);
 			vma->vm_flags = VM_READ | VM_MAYREAD | VM_IO | VM_RESERVED;
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			if (insert_vm_struct(current->mm, vma)) {
-				up_write(&current->mm->mmap_sem);
+				rw_mutex_write_unlock(&current->mm->mmap_lock);
 				kmem_cache_free(vm_area_cachep, vma);
 				return;
 			}
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 		}
 	}
 }
Index: linux-2.6/arch/m32r/kernel/sys_m32r.c
===================================================================
--- linux-2.6.orig/arch/m32r/kernel/sys_m32r.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/m32r/kernel/sys_m32r.c	2007-05-11 15:06:00.000000000 +0200
@@ -109,9 +109,9 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/m32r/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/m32r/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -120,7 +120,7 @@ asmlinkage void do_page_fault(struct pt_
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunatly, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
+	 * erroneous fault occurring in a code path which already holds mmap_lock
 	 * we will deadlock attempting to validate the fault against the
 	 * address space.  Luckily the kernel only validly references user
 	 * space from well defined areas of code, which are listed in the
@@ -132,11 +132,11 @@ asmlinkage void do_page_fault(struct pt_
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!down_read_trylock(&mm->mmap_lock)) {
 		if ((error_code & ACE_USERMODE) == 0 &&
 		    !search_exception_tables(regs->psw))
 			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	vma = find_vma(mm, address);
@@ -210,7 +210,7 @@ survive:
 			BUG();
 	}
 	set_thread_fault_code(0);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -218,7 +218,7 @@ survive:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -271,10 +271,10 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(tsk)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -283,7 +283,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Kernel mode? Handle exception or die */
 	if (!(error_code & ACE_USERMODE))
Index: linux-2.6/arch/m68k/kernel/sys_m68k.c
===================================================================
--- linux-2.6.orig/arch/m68k/kernel/sys_m68k.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/m68k/kernel/sys_m68k.c	2007-05-11 15:06:00.000000000 +0200
@@ -62,9 +62,9 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -149,9 +149,9 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/m68k/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m68k/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/m68k/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -102,7 +102,7 @@ int do_page_fault(struct pt_regs *regs, 
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -172,7 +172,7 @@ good_area:
 		goto out_of_memory;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return 0;
 
 /*
@@ -180,10 +180,10 @@ good_area:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 
@@ -214,6 +214,6 @@ acc_err:
 	current->thread.faddr = address;
 
 send_sig:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return send_fault_sig(regs);
 }
Index: linux-2.6/arch/m68knommu/kernel/sys_m68k.c
===================================================================
--- linux-2.6.orig/arch/m68knommu/kernel/sys_m68k.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/m68knommu/kernel/sys_m68k.c	2007-05-11 15:06:00.000000000 +0200
@@ -60,9 +60,9 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/mips/kernel/irixelf.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/irixelf.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/mips/kernel/irixelf.c	2007-05-11 15:06:00.000000000 +0200
@@ -154,9 +154,9 @@ static void set_brk(unsigned long start,
 	end = PAGE_ALIGN(end);
 	if (end <= start)
 		return;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	do_brk(start, end - start);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 }
 
 
@@ -339,12 +339,12 @@ static unsigned int load_irix_interp(str
 			         (unsigned long)
 			         (eppnt->p_offset & 0xfffff000));
 
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			error = do_mmap(interpreter, vaddr,
 			eppnt->p_filesz + (eppnt->p_vaddr & 0xfff),
 			elf_prot, elf_type,
 			eppnt->p_offset & 0xfffff000);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 			if (error < 0 && error > -1024) {
 				printk("Aieee IRIX interp mmap error=%d\n",
@@ -396,9 +396,9 @@ static unsigned int load_irix_interp(str
 
 	/* Map the last of the bss segment */
 	if (last_bss > len) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		do_brk(len, (last_bss - len));
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 	kfree(elf_phdata);
 
@@ -511,12 +511,12 @@ static inline void map_executable(struct
 		prot  = (epp->p_flags & PF_R) ? PROT_READ : 0;
 		prot |= (epp->p_flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (epp->p_flags & PF_X) ? PROT_EXEC : 0;
-	        down_write(&current->mm->mmap_sem);
+	        rw_mutex_write_lock(&current->mm->mmap_lock);
 		(void) do_mmap(fp, (epp->p_vaddr & 0xfffff000),
 			       (epp->p_filesz + (epp->p_vaddr & 0xfff)),
 			       prot, EXEC_MAP_FLAGS,
 			       (epp->p_offset & 0xfffff000));
-	        up_write(&current->mm->mmap_sem);
+	        rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		/* Fixup location tracking vars. */
 		if ((epp->p_vaddr & 0xfffff000) < *estack)
@@ -580,9 +580,9 @@ static void irix_map_prda_page(void)
 	unsigned long v;
 	struct prda *pp;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	v =  do_brk (PRDA_ADDRESS, PAGE_SIZE);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (v < 0)
 		return;
@@ -795,10 +795,10 @@ static int load_irix_binary(struct linux
 	 * Since we do not have the power to recompile these, we
 	 * emulate the SVr4 behavior.  Sigh.
 	 */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	(void) do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
 		       MAP_FIXED | MAP_PRIVATE, 0);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 #endif
 
 	start_thread(regs, elf_entry, bprm->p);
@@ -868,14 +868,14 @@ static int load_irix_library(struct file
 	while (elf_phdata->p_type != PT_LOAD) elf_phdata++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap(file,
 			elf_phdata->p_vaddr & 0xfffff000,
 			elf_phdata->p_filesz + (elf_phdata->p_vaddr & 0xfff),
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			elf_phdata->p_offset & 0xfffff000);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	k = elf_phdata->p_vaddr + elf_phdata->p_filesz;
 	if (k > elf_bss) elf_bss = k;
@@ -890,9 +890,9 @@ static int load_irix_library(struct file
 	len = (elf_phdata->p_filesz + elf_phdata->p_vaddr+ 0xfff) & 0xfffff000;
 	bss = elf_phdata->p_memsz + elf_phdata->p_vaddr;
 	if (bss > len) {
-	  down_write(&current->mm->mmap_sem);
+	  rw_mutex_write_lock(&current->mm->mmap_lock);
 	  do_brk(len, bss-len);
-	  up_write(&current->mm->mmap_sem);
+	  rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 	kfree(elf_phdata);
 	return 0;
@@ -956,12 +956,12 @@ unsigned long irix_mapelf(int fd, struct
 		prot |= (flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (flags & PF_X) ? PROT_EXEC : 0;
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		retval = do_mmap(filp, (vaddr & 0xfffff000),
 				 (filesz + (vaddr & 0xfff)),
 				 prot, (MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE),
 				 (offset & 0xfffff000));
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (retval != (vaddr & 0xfffff000)) {
 			printk("irix_mapelf: do_mmap fails with %d!\n", retval);
Index: linux-2.6/arch/mips/kernel/linux32.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/linux32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/mips/kernel/linux32.c	2007-05-11 15:06:00.000000000 +0200
@@ -119,9 +119,9 @@ sys32_mmap2(unsigned long addr, unsigned
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 
Index: linux-2.6/arch/mips/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/syscall.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/mips/kernel/syscall.c	2007-05-11 15:06:00.000000000 +0200
@@ -130,9 +130,9 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/mips/kernel/sysirix.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/sysirix.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/mips/kernel/sysirix.c	2007-05-11 15:06:00.000000000 +0200
@@ -460,7 +460,7 @@ asmlinkage int irix_syssgi(struct pt_reg
 		pmd_t *pmdp;
 		pte_t *ptep;
 
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		pgdp = pgd_offset(mm, addr);
 		pudp = pud_offset(pgdp, addr);
 		pmdp = pmd_offset(pudp, addr);
@@ -475,7 +475,7 @@ asmlinkage int irix_syssgi(struct pt_reg
 				                   PAGE_SHIFT, pageno);
 			}
 		}
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		break;
 	}
 
@@ -523,7 +523,7 @@ asmlinkage int irix_brk(unsigned long br
 	struct mm_struct *mm = current->mm;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	if (brk < mm->end_code) {
 		ret = -ENOMEM;
 		goto out;
@@ -576,7 +576,7 @@ asmlinkage int irix_brk(unsigned long br
 	ret = 0;
 
 out:
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return ret;
 }
 
@@ -1051,9 +1051,9 @@ asmlinkage unsigned long irix_mmap32(uns
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file, addr, len, prot, flags, offset);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 
@@ -1536,9 +1536,9 @@ asmlinkage int irix_mmap64(struct pt_reg
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/mips/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/mips/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -71,7 +71,7 @@ asmlinkage void do_page_fault(struct pt_
 	if (in_atomic() || !mm)
 		goto bad_area_nosemaphore;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -117,7 +117,7 @@ survive:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -125,7 +125,7 @@ survive:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -173,10 +173,10 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(tsk)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -185,7 +185,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!user_mode(regs))
Index: linux-2.6/arch/parisc/kernel/sys_parisc.c
===================================================================
--- linux-2.6.orig/arch/parisc/kernel/sys_parisc.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/parisc/kernel/sys_parisc.c	2007-05-11 15:06:00.000000000 +0200
@@ -137,9 +137,9 @@ static unsigned long do_mmap2(unsigned l
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file != NULL)
 		fput(file);
Index: linux-2.6/arch/parisc/kernel/traps.c
===================================================================
--- linux-2.6.orig/arch/parisc/kernel/traps.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/parisc/kernel/traps.c	2007-05-11 15:06:00.000000000 +0200
@@ -710,7 +710,7 @@ void handle_interruption(int code, struc
 		if (user_mode(regs)) {
 			struct vm_area_struct *vma;
 
-			down_read(&current->mm->mmap_sem);
+			rw_mutex_read_lock(&current->mm->mmap_lock);
 			vma = find_vma(current->mm,regs->iaoq[0]);
 			if (vma && (regs->iaoq[0] >= vma->vm_start)
 				&& (vma->vm_flags & VM_EXEC)) {
@@ -718,10 +718,10 @@ void handle_interruption(int code, struc
 				fault_address = regs->iaoq[0];
 				fault_space = regs->iasq[0];
 
-				up_read(&current->mm->mmap_sem);
+				rw_mutex_read_unlock(&current->mm->mmap_lock);
 				break; /* call do_page_fault() */
 			}
-			up_read(&current->mm->mmap_sem);
+			rw_mutex_read_unlock(&current->mm->mmap_lock);
 		}
 		/* Fall Through */
 	case 27: 
Index: linux-2.6/arch/parisc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/parisc/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/parisc/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -151,7 +151,7 @@ void do_page_fault(struct pt_regs *regs,
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma_prev(mm, address, &prev_vma);
 	if (!vma || address < vma->vm_start)
 		goto check_expansion;
@@ -190,7 +190,7 @@ good_area:
 	      default:
 		goto out_of_memory;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 check_expansion:
@@ -202,7 +202,7 @@ check_expansion:
  * Something tried to access memory that isn't in our memory map..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	if (user_mode(regs)) {
 		struct siginfo si;
@@ -259,7 +259,7 @@ no_context:
 	parisc_terminate("Bad Address (null pointer deref?)", regs, code, address);
 
   out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	printk(KERN_CRIT "VM: killing process %s\n", current->comm);
 	if (user_mode(regs))
 		do_exit(SIGKILL);
Index: linux-2.6/arch/powerpc/kernel/syscalls.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/syscalls.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/powerpc/kernel/syscalls.c	2007-05-11 15:06:00.000000000 +0200
@@ -175,9 +175,9 @@ static inline unsigned long do_mmap2(uns
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mmap_pgoff(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/powerpc/kernel/vdso.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/vdso.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/powerpc/kernel/vdso.c	2007-05-11 15:06:00.000000000 +0200
@@ -214,7 +214,7 @@ int arch_setup_additional_pages(struct l
 	 * at vdso_base which is the "natural" base for it, but we might fail
 	 * and end up putting it elsewhere.
 	 */
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	vdso_base = get_unmapped_area(NULL, vdso_base,
 				      vdso_pages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
@@ -248,11 +248,11 @@ int arch_setup_additional_pages(struct l
 	/* Put vDSO base into mm struct */
 	current->mm->context.vdso_base = vdso_base;
 
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return 0;
 
  fail_mmapsem:
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return rc;
 }
 
Index: linux-2.6/arch/powerpc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/powerpc/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -199,7 +199,7 @@ int __kprobes do_page_fault(struct pt_re
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
+	 * erroneous fault occurring in a code path which already holds mmap_lock
 	 * we will deadlock attempting to validate the fault against the
 	 * address space.  Luckily the kernel only validly references user
 	 * space from well defined areas of code, which are listed in the
@@ -211,11 +211,11 @@ int __kprobes do_page_fault(struct pt_re
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!down_read_trylock(&mm->mmap_lock)) {
 		if (!user_mode(regs) && !search_exception_tables(regs->nip))
 			goto bad_area_nosemaphore;
 
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	vma = find_vma(mm, address);
@@ -306,7 +306,7 @@ good_area:
 				pte_update(ptep, 0, _PAGE_HWEXEC);
 				_tlbie(address);
 				pte_unmap_unlock(ptep, ptl);
-				up_read(&mm->mmap_sem);
+				rw_mutex_read_unlock(&mm->mmap_lock);
 				return 0;
 			}
 			pte_unmap_unlock(ptep, ptl);
@@ -347,11 +347,11 @@ good_area:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return 0;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses cause a SIGSEGV */
@@ -373,10 +373,10 @@ bad_area_nosemaphore:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", current->comm);
@@ -385,7 +385,7 @@ out_of_memory:
 	return SIGKILL;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (user_mode(regs)) {
 		info.si_signo = SIGBUS;
 		info.si_errno = 0;
Index: linux-2.6/arch/powerpc/mm/tlb_32.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/powerpc/mm/tlb_32.c	2007-05-11 15:06:00.000000000 +0200
@@ -150,7 +150,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 
 	/*
 	 * It is safe to go down the mm's list of vmas when called
-	 * from dup_mmap, holding mmap_sem.  It would also be safe from
+	 * from dup_mmap, holding mmap_lock.  It would also be safe from
 	 * unmap_region or exit_mmap, but not from vmtruncate on SMP -
 	 * but it seems dup_mmap is the only SMP case which gets here.
 	 */
Index: linux-2.6/arch/ppc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/ppc/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/ppc/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -130,7 +130,7 @@ int do_page_fault(struct pt_regs *regs, 
 	if (in_atomic() || mm == NULL)
 		return SIGSEGV;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -228,7 +228,7 @@ good_area:
 				pte_update(ptep, 0, _PAGE_HWEXEC);
 				_tlbie(address);
 				pte_unmap_unlock(ptep, ptl);
-				up_read(&mm->mmap_sem);
+				rw_mutex_read_unlock(&mm->mmap_lock);
 				return 0;
 			}
 			pte_unmap_unlock(ptep, ptl);
@@ -264,7 +264,7 @@ good_area:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	/*
 	 * keep track of tlb+htab misses that are good addrs but
 	 * just need pte's created via handle_mm_fault()
@@ -274,7 +274,7 @@ good_area:
 	return 0;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	pte_errors++;
 
 	/* User mode accesses cause a SIGSEGV */
@@ -290,10 +290,10 @@ bad_area:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", current->comm);
@@ -302,7 +302,7 @@ out_of_memory:
 	return SIGKILL;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	info.si_signo = SIGBUS;
 	info.si_errno = 0;
 	info.si_code = BUS_ADRERR;
Index: linux-2.6/arch/s390/kernel/compat_linux.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/compat_linux.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/s390/kernel/compat_linux.c	2007-05-11 15:06:00.000000000 +0200
@@ -860,14 +860,14 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	if (!IS_ERR((void *) error) && error + len >= 0x80000000ULL) {
 		/* Result is out of bounds.  */
 		do_munmap(current->mm, addr, len);
 		error = -ENOMEM;
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/s390/kernel/sys_s390.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/sys_s390.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/s390/kernel/sys_s390.c	2007-05-11 15:06:00.000000000 +0200
@@ -64,9 +64,9 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/s390/lib/uaccess_pt.c
===================================================================
--- linux-2.6.orig/arch/s390/lib/uaccess_pt.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/s390/lib/uaccess_pt.c	2007-05-11 15:06:00.000000000 +0200
@@ -23,7 +23,7 @@ static int __handle_fault(struct mm_stru
 
 	if (in_atomic())
 		return ret;
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (unlikely(!vma))
 		goto out;
@@ -60,21 +60,21 @@ survive:
 	}
 	ret = 0;
 out:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return ret;
 
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", current->comm);
 	return ret;
 
 out_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	current->thread.prot_addr = address;
 	current->thread.trap_no = 0x11;
 	force_sig(SIGBUS, current);
Index: linux-2.6/arch/s390/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/s390/mm/fault.c	2007-05-11 15:06:15.000000000 +0200
@@ -210,10 +210,10 @@ static int do_out_of_memory(struct pt_re
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(tsk)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		return 1;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -229,7 +229,7 @@ static void do_sigbus(struct pt_regs *re
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
 	 * or user mode.
@@ -261,7 +261,7 @@ static int signal_return(struct mm_struc
 	if (rc)
 		return -EFAULT;
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	clear_tsk_thread_flag(current, TIF_SINGLE_STEP);
 #ifdef CONFIG_COMPAT
 	compat = test_tsk_thread_flag(current, TIF_31BIT);
@@ -330,7 +330,7 @@ do_exception(struct pt_regs *regs, unsig
 	 */
 	local_irq_enable();
 
-	down_read(&mm->mmap_sem);
+        rw_mutex_read_lock(&mm->mmap_lock);
 
 	si_code = SEGV_MAPERR;
 	vma = find_vma(mm, address);
@@ -341,7 +341,7 @@ do_exception(struct pt_regs *regs, unsig
 	if (unlikely((space == 2) && !(vma->vm_flags & VM_EXEC)))
 		if (!signal_return(mm, regs, address, error_code))
 			/*
-			 * signal_return() has done an up_read(&mm->mmap_sem)
+			 * signal_return() has done an rw_mutex_read_unlock(&mm->mmap_lock)
 			 * if it returns 0.
 			 */
 			return;
@@ -392,7 +392,7 @@ survive:
 		BUG();
 	}
 
-        up_read(&mm->mmap_sem);
+        rw_mutex_read_unlock(&mm->mmap_lock);
 	/*
 	 * The instruction that caused the program check will
 	 * be repeated. Don't signal single step via SIGTRAP.
@@ -405,7 +405,7 @@ survive:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+        rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (regs->psw.mask & PSW_MASK_PSTATE) {
Index: linux-2.6/arch/sh/kernel/sys_sh.c
===================================================================
--- linux-2.6.orig/arch/sh/kernel/sys_sh.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh/kernel/sys_sh.c	2007-05-11 15:06:00.000000000 +0200
@@ -152,9 +152,9 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sh/kernel/vsyscall/vsyscall.c
===================================================================
--- linux-2.6.orig/arch/sh/kernel/vsyscall/vsyscall.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh/kernel/vsyscall/vsyscall.c	2007-05-11 15:06:00.000000000 +0200
@@ -64,7 +64,7 @@ int arch_setup_additional_pages(struct l
 	unsigned long addr;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
@@ -82,7 +82,7 @@ int arch_setup_additional_pages(struct l
 	current->mm->context.vdso = (void *)addr;
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return ret;
 }
 
Index: linux-2.6/arch/sh/mm/cache-sh4.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/cache-sh4.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh/mm/cache-sh4.c	2007-05-11 15:06:00.000000000 +0200
@@ -372,7 +372,7 @@ loop_exit:
  * need to flush the I-cache, since aliases don't matter for that.  We
  * should try that.
  *
- * Caller takes mm->mmap_sem.
+ * Caller takes mm->mmap_lock.
  */
 void flush_cache_mm(struct mm_struct *mm)
 {
Index: linux-2.6/arch/sh/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -131,7 +131,7 @@ asmlinkage void __kprobes do_page_fault(
 	if (in_atomic() || !mm)
 		goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma(mm, address);
 	if (!vma)
@@ -177,7 +177,7 @@ survive:
 			BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -185,7 +185,7 @@ survive:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	if (user_mode(regs)) {
@@ -232,10 +232,10 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -244,7 +244,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/sh64/kernel/sys_sh64.c
===================================================================
--- linux-2.6.orig/arch/sh64/kernel/sys_sh64.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh64/kernel/sys_sh64.c	2007-05-11 15:06:00.000000000 +0200
@@ -147,9 +147,9 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sh64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sh64/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sh64/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -157,7 +157,7 @@ asmlinkage void do_page_fault(struct pt_
 		goto no_context;
 
 	/* TLB misses upon some cache flushes get done under cli() */
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = find_vma(mm, address);
 
@@ -249,7 +249,7 @@ survive:
 
 no_pte:
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -260,7 +260,7 @@ bad_area:
 #ifdef DEBUG_FAULT
 	printk("fault:bad area\n");
 #endif
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	if (user_mode(regs)) {
 		static int count=0;
@@ -324,10 +324,10 @@ out_of_memory:
 		goto survive;
 	}
 	printk("fault:Out of memory\n");
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", tsk->comm);
@@ -337,7 +337,7 @@ out_of_memory:
 
 do_sigbus:
 	printk("fault:Do sigbus\n");
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/sparc/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/sys_sparc.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc/kernel/sys_sparc.c	2007-05-11 15:06:00.000000000 +0200
@@ -252,9 +252,9 @@ static unsigned long do_mmap2(unsigned l
 	len = PAGE_ALIGN(len);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -308,7 +308,7 @@ asmlinkage unsigned long sparc_mremap(un
 	if (old_len > TASK_SIZE - PAGE_SIZE ||
 	    new_len > TASK_SIZE - PAGE_SIZE)
 		goto out;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (flags & MREMAP_FIXED) {
 		if (ARCH_SUN4C_SUN4 &&
 		    new_addr < 0xe0000000 &&
@@ -343,7 +343,7 @@ asmlinkage unsigned long sparc_mremap(un
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 out:
 	return ret;       
 }
Index: linux-2.6/arch/sparc/kernel/sys_sunos.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/sys_sunos.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc/kernel/sys_sunos.c	2007-05-11 15:06:00.000000000 +0200
@@ -120,9 +120,9 @@ asmlinkage unsigned long sunos_mmap(unsi
 	}
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (!ret_type)
 		retval = ((retval < PAGE_OFFSET) ? 0 : retval);
 
@@ -149,7 +149,7 @@ asmlinkage int sunos_brk(unsigned long b
 	unsigned long rlim;
 	unsigned long newbrk, oldbrk;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (ARCH_SUN4C_SUN4) {
 		if (brk >= 0x20000000 && brk < 0xe0000000) {
 			goto out;
@@ -211,7 +211,7 @@ asmlinkage int sunos_brk(unsigned long b
 	do_brk(oldbrk, newbrk-oldbrk);
 	retval = 0;
 out:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return retval;
 }
 
Index: linux-2.6/arch/sparc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -251,7 +251,7 @@ asmlinkage void do_sparc_fault(struct pt
         if (in_atomic() || !mm)
                 goto no_context;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/*
 	 * The kernel referencing a bad kernel pointer can lock up
@@ -302,7 +302,7 @@ good_area:
 		current->min_flt++;
 		break;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 	/*
@@ -310,7 +310,7 @@ good_area:
 	 * Fix it, but check if it's kernel or user first..
 	 */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -366,14 +366,14 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	printk("VM: killing process %s\n", tsk->comm);
 	if (from_user)
 		do_exit(SIGKILL);
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	info.si_signo = SIGBUS;
 	info.si_errno = 0;
 	info.si_code = BUS_ADRERR;
@@ -513,7 +513,7 @@ inline void force_user_fault(unsigned lo
 	printk("wf<pid=%d,wr=%d,addr=%08lx>\n",
 	       tsk->pid, write, address);
 #endif
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if(!vma)
 		goto bad_area;
@@ -537,10 +537,10 @@ good_area:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 #if 0
 	printk("Window whee %s [%d]: segfaults at %08lx\n",
 	       tsk->comm, tsk->pid, address);
@@ -555,7 +555,7 @@ bad_area:
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	info.si_signo = SIGBUS;
 	info.si_errno = 0;
 	info.si_code = BUS_ADRERR;
Index: linux-2.6/arch/sparc64/kernel/binfmt_aout32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/binfmt_aout32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/kernel/binfmt_aout32.c	2007-05-11 15:06:00.000000000 +0200
@@ -48,9 +48,9 @@ static void set_brk(unsigned long start,
 	end = PAGE_ALIGN(end);
 	if (end <= start)
 		return;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	do_brk(start, end - start);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 }
 
 /*
@@ -248,14 +248,14 @@ static int load_aout32_binary(struct lin
 	if (N_MAGIC(ex) == NMAGIC) {
 		loff_t pos = fd_offset;
 		/* Fuck me plenty... */
-		down_write(&current->mm->mmap_sem);	
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(N_TXTADDR(ex), ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		bprm->file->f_op->read(bprm->file, (char __user *)N_TXTADDR(ex),
 			  ex.a_text, &pos);
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(N_DATADDR(ex), ex.a_data);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		bprm->file->f_op->read(bprm->file, (char __user *)N_DATADDR(ex),
 			  ex.a_data, &pos);
 		goto beyond_if;
@@ -263,10 +263,10 @@ static int load_aout32_binary(struct lin
 
 	if (N_MAGIC(ex) == OMAGIC) {
 		loff_t pos = fd_offset;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		do_brk(N_TXTADDR(ex) & PAGE_MASK,
 			ex.a_text+ex.a_data + PAGE_SIZE - 1);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		bprm->file->f_op->read(bprm->file, (char __user *)N_TXTADDR(ex),
 			  ex.a_text+ex.a_data, &pos);
 	} else {
@@ -280,33 +280,33 @@ static int load_aout32_binary(struct lin
 
 		if (!bprm->file->f_op->mmap) {
 			loff_t pos = fd_offset;
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			do_brk(0, ex.a_text+ex.a_data);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 			bprm->file->f_op->read(bprm->file,
 				  (char __user *)N_TXTADDR(ex),
 				  ex.a_text+ex.a_data, &pos);
 			goto beyond_if;
 		}
 
-	        down_write(&current->mm->mmap_sem);
+	        rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-	        up_write(&current->mm->mmap_sem);
+	        rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-	        down_write(&current->mm->mmap_sem);
+	        rw_mutex_write_lock(&current->mm->mmap_lock);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-	        up_write(&current->mm->mmap_sem);
+	        rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -378,12 +378,12 @@ static int load_aout32_library(struct fi
 	start_addr =  ex.a_entry & 0xfffff000;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	retval = error;
 	if (error != start_addr)
 		goto out;
@@ -391,9 +391,9 @@ static int load_aout32_library(struct fi
 	len = PAGE_ALIGN(ex.a_text + ex.a_data);
 	bss = ex.a_text + ex.a_data + ex.a_bss;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(start_addr + len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		retval = error;
 		if (error != start_addr + len)
 			goto out;
Index: linux-2.6/arch/sparc64/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sparc.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/kernel/sys_sparc.c	2007-05-11 15:06:00.000000000 +0200
@@ -584,9 +584,9 @@ asmlinkage unsigned long sys_mmap(unsign
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	len = PAGE_ALIGN(len);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
@@ -601,9 +601,9 @@ asmlinkage long sys64_munmap(unsigned lo
 	if (invalid_64bit_range(addr, len))
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_munmap(current->mm, addr, len);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
 
@@ -625,7 +625,7 @@ asmlinkage unsigned long sys64_mremap(un
 	if (unlikely(invalid_64bit_range(addr, old_len)))
 		goto out;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (flags & MREMAP_FIXED) {
 		if (invalid_64bit_range(new_addr, new_len))
 			goto out_sem;
@@ -655,7 +655,7 @@ asmlinkage unsigned long sys64_mremap(un
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 out:
 	return ret;       
 }
Index: linux-2.6/arch/sparc64/kernel/sys_sparc32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sparc32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/kernel/sys_sparc32.c	2007-05-11 15:06:00.000000000 +0200
@@ -921,7 +921,7 @@ asmlinkage unsigned long sys32_mremap(un
 		goto out;
 	if (addr > STACK_TOP32 - old_len)
 		goto out;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (flags & MREMAP_FIXED) {
 		if (new_addr > STACK_TOP32 - new_len)
 			goto out_sem;
@@ -951,7 +951,7 @@ asmlinkage unsigned long sys32_mremap(un
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 out:
 	return ret;       
 }
Index: linux-2.6/arch/sparc64/kernel/sys_sunos32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sunos32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/kernel/sys_sunos32.c	2007-05-11 15:06:00.000000000 +0200
@@ -100,12 +100,12 @@ asmlinkage u32 sunos_mmap(u32 addr, u32 
 	flags &= ~_MAP_NEW;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags,
 			 (unsigned long) off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (!ret_type)
 		retval = ((retval < 0xf0000000) ? 0 : retval);
 out_putf:
@@ -126,7 +126,7 @@ asmlinkage int sunos_brk(u32 baddr)
 	unsigned long rlim;
 	unsigned long newbrk, oldbrk, brk = (unsigned long) baddr;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (brk < current->mm->end_code)
 		goto out;
 	newbrk = PAGE_ALIGN(brk);
@@ -169,7 +169,7 @@ asmlinkage int sunos_brk(u32 baddr)
 	do_brk(oldbrk, newbrk-oldbrk);
 	retval = 0;
 out:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return retval;
 }
 
Index: linux-2.6/arch/sparc64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sparc64/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -125,7 +125,7 @@ static void bad_kernel_pc(struct pt_regs
 }
 
 /*
- * We now make sure that mmap_sem is held in all paths that call 
+ * We now make sure that mmap_lock is held in all paths that call
  * this. Additionally, to prevent kswapd from ripping ptes from
  * under us, raise interrupts around the time that we look at the
  * pte, kswapd will have to wait to get his smp ipi response from
@@ -319,13 +319,13 @@ asmlinkage void __kprobes do_sparc64_fau
 		address &= 0xffffffff;
 	}
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!down_read_trylock(&mm->mmap_lock)) {
 		if ((regs->tstate & TSTATE_PRIV) &&
 		    !search_exception_tables(regs->tpc)) {
 			insn = get_fault_insn(regs, insn);
 			goto handle_kernel_fault;
 		}
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	vma = find_vma(mm, address);
@@ -430,7 +430,7 @@ good_area:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	mm_rss = get_mm_rss(mm);
 #ifdef CONFIG_HUGETLB_PAGE
@@ -453,7 +453,7 @@ good_area:
 	 */
 bad_area:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 handle_kernel_fault:
 	do_kernel_fault(regs, si_code, fault_code, insn, address);
@@ -465,7 +465,7 @@ handle_kernel_fault:
  */
 out_of_memory:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	printk("VM: killing process %s\n", current->comm);
 	if (!(regs->tstate & TSTATE_PRIV))
 		do_exit(SIGKILL);
@@ -477,7 +477,7 @@ intr_or_no_mm:
 
 do_sigbus:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
Index: linux-2.6/arch/sparc64/solaris/misc.c
===================================================================
--- linux-2.6.orig/arch/sparc64/solaris/misc.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/sparc64/solaris/misc.c	2007-05-11 15:06:00.000000000 +0200
@@ -95,12 +95,12 @@ static u32 do_solaris_mmap(u32 addr, u32
 	ret_type = flags & _MAP_NEW;
 	flags &= ~_MAP_NEW;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags, off);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if(!ret_type)
 		retval = ((retval < STACK_TOP32) ? 0 : retval);
 	                        
Index: linux-2.6/arch/um/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/syscall.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/um/kernel/syscall.c	2007-05-11 15:06:00.000000000 +0200
@@ -63,9 +63,9 @@ long sys_mmap2(unsigned long addr, unsig
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/um/kernel/trap.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/trap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/um/kernel/trap.c	2007-05-11 15:06:00.000000000 +0200
@@ -53,7 +53,7 @@ int handle_page_fault(unsigned long addr
 	if (in_atomic())
 		goto out_nosemaphore;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if(!vma)
 		goto out;
@@ -111,7 +111,7 @@ survive:
 #endif
 	flush_tlb_page(vma, address);
 out:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 out_nosemaphore:
 	return(err);
 
@@ -121,9 +121,9 @@ out_nosemaphore:
  */
 out_of_memory:
 	if (is_init(current)) {
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	goto out;
Index: linux-2.6/arch/v850/kernel/syscalls.c
===================================================================
--- linux-2.6.orig/arch/v850/kernel/syscalls.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/v850/kernel/syscalls.c	2007-05-11 15:06:00.000000000 +0200
@@ -165,9 +165,9 @@ do_mmap2 (unsigned long addr, size_t len
 			goto out;
 	}
 	
-	down_write (&current->mm->mmap_sem);
+	down_write (&current->mm->mmap_lock);
 	ret = do_mmap_pgoff (file, addr, len, prot, flags, pgoff);
-	up_write (&current->mm->mmap_sem);
+	up_write (&current->mm->mmap_lock);
 	if (file)
 		fput (file);
 out:
Index: linux-2.6/arch/x86_64/ia32/ia32_aout.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/ia32_aout.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/ia32/ia32_aout.c	2007-05-11 15:06:00.000000000 +0200
@@ -112,9 +112,9 @@ static void set_brk(unsigned long start,
 	end = PAGE_ALIGN(end);
 	if (end <= start)
 		return;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	do_brk(start, end - start);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 }
 
 #ifdef CORE_DUMP
@@ -324,9 +324,9 @@ static int load_aout_binary(struct linux
 		pos = 32;
 		map_size = ex.a_text+ex.a_data;
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(text_addr & PAGE_MASK, map_size);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (error != (text_addr & PAGE_MASK)) {
 			send_sig(SIGKILL, current, 0);
@@ -364,9 +364,9 @@ static int load_aout_binary(struct linux
 
 		if (!bprm->file->f_op->mmap||((fd_offset & ~PAGE_MASK) != 0)) {
 			loff_t pos = fd_offset;
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			do_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 			bprm->file->f_op->read(bprm->file,
 					(char __user *)N_TXTADDR(ex),
 					ex.a_text+ex.a_data, &pos);
@@ -376,24 +376,24 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE | MAP_32BIT,
 			fd_offset);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE | MAP_32BIT,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -475,9 +475,9 @@ static int load_aout_library(struct file
 			error_time = jiffies;
 		}
 #endif
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		do_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		
 		file->f_op->read(file, (char __user *)start_addr,
 			ex.a_text + ex.a_data, &pos);
@@ -488,12 +488,12 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_32BIT,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	retval = error;
 	if (error != start_addr)
 		goto out;
@@ -501,9 +501,9 @@ static int load_aout_library(struct file
 	len = PAGE_ALIGN(ex.a_text + ex.a_data);
 	bss = ex.a_text + ex.a_data + ex.a_bss;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(start_addr + len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		retval = error;
 		if (error != start_addr + len)
 			goto out;
Index: linux-2.6/arch/x86_64/ia32/ia32_binfmt.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/ia32_binfmt.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/ia32/ia32_binfmt.c	2007-05-11 15:06:00.000000000 +0200
@@ -306,7 +306,7 @@ int ia32_setup_arg_pages(struct linux_bi
 	if (!mpnt) 
 		return -ENOMEM; 
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	{
 		mpnt->vm_mm = mm;
 		mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
@@ -320,7 +320,7 @@ int ia32_setup_arg_pages(struct linux_bi
  		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC) ? 
  			PAGE_COPY_EXEC : PAGE_COPY;
 		if ((ret = insert_vm_struct(mm, mpnt))) {
-			up_write(&mm->mmap_sem);
+			rw_mutex_write_unlock(&mm->mmap_lock);
 			kmem_cache_free(vm_area_cachep, mpnt);
 			return ret;
 		}
@@ -335,7 +335,7 @@ int ia32_setup_arg_pages(struct linux_bi
 		}
 		stack_base += PAGE_SIZE;
 	}
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	
 	return 0;
 }
Index: linux-2.6/arch/x86_64/ia32/sys_ia32.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/sys_ia32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/ia32/sys_ia32.c	2007-05-11 15:06:00.000000000 +0200
@@ -242,12 +242,12 @@ sys32_mmap(struct mmap_arg_struct __user
 	}
 	
 	mm = current->mm; 
-	down_write(&mm->mmap_sem); 
+	rw_mutex_write_lock(&mm->mmap_lock);
 	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset>>PAGE_SHIFT);
 	if (file)
 		fput(file);
 
-	up_write(&mm->mmap_sem); 
+	rw_mutex_write_unlock(&mm->mmap_lock);
 
 	return retval;
 }
@@ -708,9 +708,9 @@ asmlinkage long sys32_mmap2(unsigned lon
 			return -EBADF;
 	}
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/x86_64/ia32/syscall32.c
===================================================================
--- linux-2.6.orig/arch/x86_64/ia32/syscall32.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/ia32/syscall32.c	2007-05-11 15:06:00.000000000 +0200
@@ -30,7 +30,7 @@ int syscall32_setup_pages(struct linux_b
 	struct mm_struct *mm = current->mm;
 	int ret;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
 	 *
@@ -45,7 +45,7 @@ int syscall32_setup_pages(struct linux_b
 				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC|
 				      VM_ALWAYSDUMP,
 				      syscall32_pages);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return ret;
 }
 
Index: linux-2.6/arch/x86_64/kernel/sys_x86_64.c
===================================================================
--- linux-2.6.orig/arch/x86_64/kernel/sys_x86_64.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/kernel/sys_x86_64.c	2007-05-11 15:06:00.000000000 +0200
@@ -54,9 +54,9 @@ asmlinkage long sys_mmap(unsigned long a
 		if (!file)
 			goto out;
 	}
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/x86_64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/x86_64/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -323,7 +323,7 @@ asmlinkage void __kprobes do_page_fault(
 
 	tsk = current;
 	mm = tsk->mm;
-	prefetchw(&mm->mmap_sem);
+	prefetchw(&mm->mmap_lock);
 
 	/* get the address */
 	__asm__("movq %%cr2,%0":"=r" (address));
@@ -388,7 +388,7 @@ asmlinkage void __kprobes do_page_fault(
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunatly, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
+	 * erroneous fault occurring in a code path which already holds mmap_lock
 	 * we will deadlock attempting to validate the fault against the
 	 * address space.  Luckily the kernel only validly references user
 	 * space from well defined areas of code, which are listed in the
@@ -400,11 +400,11 @@ asmlinkage void __kprobes do_page_fault(
 	 * source.  If this is invalid we can skip the address space check,
 	 * thus avoiding the deadlock.
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!rw_mutex_read_trylock(&mm->mmap_lock)) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->rip))
 			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 
 	vma = find_vma(mm, address);
@@ -463,7 +463,7 @@ good_area:
 		goto out_of_memory;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 /*
@@ -471,7 +471,7 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -556,7 +556,7 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
 		goto again;
@@ -567,7 +567,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & PF_USER))
Index: linux-2.6/arch/x86_64/mm/pageattr.c
===================================================================
--- linux-2.6.orig/arch/x86_64/mm/pageattr.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/x86_64/mm/pageattr.c	2007-05-11 15:06:00.000000000 +0200
@@ -90,7 +90,7 @@ static inline void flush_map(struct list
 	on_each_cpu(flush_kernel_map, l, 1, 1);
 }
 
-static LIST_HEAD(deferred_pages); /* protected by init_mm.mmap_sem */
+static LIST_HEAD(deferred_pages); /* protected by init_mm.mmap_lock */
 
 static inline void save_page(struct page *fpage)
 {
@@ -189,7 +189,7 @@ int change_page_attr_addr(unsigned long 
 		kernel_map = 1;
 	}
 
-	down_write(&init_mm.mmap_sem);
+	rw_mutex_write_lock(&init_mm.mmap_lock);
 	for (i = 0; i < numpages; i++, address += PAGE_SIZE) {
 		unsigned long pfn = __pa(address) >> PAGE_SHIFT;
 
@@ -210,7 +210,7 @@ int change_page_attr_addr(unsigned long 
 						 PAGE_KERNEL_EXEC);
 		} 
 	} 	
-	up_write(&init_mm.mmap_sem); 
+	rw_mutex_write_unlock(&init_mm.mmap_lock);
 	return err;
 }
 
@@ -226,9 +226,9 @@ void global_flush_tlb(void)
 	struct page *pg, *next;
 	struct list_head l;
 
-	down_read(&init_mm.mmap_sem);
+	rw_mutex_read_lock(&init_mm.mmap_lock);
 	list_replace_init(&deferred_pages, &l);
-	up_read(&init_mm.mmap_sem);
+	rw_mutex_read_unlock(&init_mm.mmap_lock);
 
 	flush_map(&l);
 
Index: linux-2.6/arch/xtensa/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/xtensa/kernel/syscall.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/xtensa/kernel/syscall.c	2007-05-11 15:06:00.000000000 +0200
@@ -72,9 +72,9 @@ asmlinkage long xtensa_mmap2(unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/xtensa/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/xtensa/mm/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/xtensa/mm/fault.c	2007-05-11 15:06:00.000000000 +0200
@@ -68,7 +68,7 @@ void do_page_fault(struct pt_regs *regs)
 	       address, exccause, regs->pc, is_write? "w":"", is_exec? "x":"");
 #endif
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 
 	if (!vma)
@@ -117,14 +117,14 @@ survive:
 		BUG();
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return;
 
 	/* Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (user_mode(regs)) {
 		current->thread.bad_vaddr = address;
 		current->thread.error_code = is_write;
@@ -143,10 +143,10 @@ bad_area:
 	 * us unable to handle the page fault gracefully.
 	 */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (is_init(current)) {
 		yield();
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		goto survive;
 	}
 	printk("VM: killing process %s\n", current->comm);
@@ -156,7 +156,7 @@ out_of_memory:
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 
 	/* Send a sigbus, regardless of whether we were in kernel
 	 * or user mode.
Index: linux-2.6/drivers/char/drm/drm_bufs.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/drm_bufs.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/char/drm/drm_bufs.c	2007-05-11 15:06:00.000000000 +0200
@@ -1582,17 +1582,17 @@ int drm_mapbufs(struct inode *inode, str
 				goto done;
 			}
 
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			virtual = do_mmap(filp, 0, map->size,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, token);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 		} else {
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			virtual = do_mmap(filp, 0, dma->byte_count,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, 0);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 		}
 		if (virtual > -1024UL) {
 			/* Real error */
Index: linux-2.6/drivers/char/drm/i810_dma.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/i810_dma.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/char/drm/i810_dma.c	2007-05-11 15:06:00.000000000 +0200
@@ -132,7 +132,7 @@ static int i810_map_buffer(drm_buf_t * b
 	if (buf_priv->currently_mapped == I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	old_fops = filp->f_op;
 	filp->f_op = &i810_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -147,7 +147,7 @@ static int i810_map_buffer(drm_buf_t * b
 		retcode = PTR_ERR(buf_priv->virtual);
 		buf_priv->virtual = NULL;
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	return retcode;
 }
@@ -160,11 +160,11 @@ static int i810_unmap_buffer(drm_buf_t *
 	if (buf_priv->currently_mapped != I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	buf_priv->currently_mapped = I810_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: linux-2.6/drivers/char/drm/i830_dma.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/i830_dma.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/char/drm/i830_dma.c	2007-05-11 15:06:00.000000000 +0200
@@ -135,7 +135,7 @@ static int i830_map_buffer(drm_buf_t * b
 	if (buf_priv->currently_mapped == I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	old_fops = filp->f_op;
 	filp->f_op = &i830_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -151,7 +151,7 @@ static int i830_map_buffer(drm_buf_t * b
 	} else {
 		buf_priv->virtual = (void __user *)virtual;
 	}
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	return retcode;
 }
@@ -164,11 +164,11 @@ static int i830_unmap_buffer(drm_buf_t *
 	if (buf_priv->currently_mapped != I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	buf_priv->currently_mapped = I830_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: linux-2.6/drivers/char/drm/via_dmablit.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/via_dmablit.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/char/drm/via_dmablit.c	2007-05-11 15:06:00.000000000 +0200
@@ -239,14 +239,14 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == (vsg->pages = vmalloc(sizeof(struct page *) * vsg->num_pages)))
 		return DRM_ERR(ENOMEM);
 	memset(vsg->pages, 0, sizeof(struct page *) * vsg->num_pages);
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	ret = get_user_pages(current, current->mm,
 			     (unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
 
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 	if (ret != vsg->num_pages) {
 		if (ret < 0) 
 			return ret;
Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/char/mem.c	2007-05-11 15:06:00.000000000 +0200
@@ -630,7 +630,7 @@ static inline size_t read_zero_pagealign
 
 	mm = current->mm;
 	/* Oops, this was forgotten before. -ben */
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/* For private mappings, just map in zero pages. */
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
@@ -655,7 +655,7 @@ static inline size_t read_zero_pagealign
 			goto out_up;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	
 	/* The shared case is hard. Let's do the conventional zeroing. */ 
 	do {
@@ -669,7 +669,7 @@ static inline size_t read_zero_pagealign
 
 	return size;
 out_up:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return size;
 }
 
Index: linux-2.6/drivers/dma/iovlock.c
===================================================================
--- linux-2.6.orig/drivers/dma/iovlock.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/dma/iovlock.c	2007-05-11 15:06:00.000000000 +0200
@@ -97,7 +97,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		ret = get_user_pages(
 			current,
 			current->mm,
@@ -107,7 +107,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 			0,	/* force */
 			page_list->pages,
 			NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 		if (ret != page_list->nr_pages) {
 			err = -ENOMEM;
Index: linux-2.6/drivers/infiniband/hw/ipath/ipath_user_pages.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/hw/ipath/ipath_user_pages.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/infiniband/hw/ipath/ipath_user_pages.c	2007-05-11 15:06:00.000000000 +0200
@@ -50,7 +50,7 @@ static void __ipath_release_user_pages(s
 	}
 }
 
-/* call with current->mm->mmap_sem held */
+/* call with current->mm->mmap_lock held */
 static int __get_user_pages(unsigned long start_page, size_t num_pages,
 			struct page **p, struct vm_area_struct **vma)
 {
@@ -162,11 +162,11 @@ int ipath_get_user_pages(unsigned long s
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	ret = __get_user_pages(start_page, num_pages, p, NULL);
 
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	return ret;
 }
@@ -188,24 +188,24 @@ int ipath_get_user_pages_nocopy(unsigned
 	struct vm_area_struct *vma;
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	ret = __get_user_pages(page, 1, p, &vma);
 
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	return ret;
 }
 
 void ipath_release_user_pages(struct page **p, size_t num_pages)
 {
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	__ipath_release_user_pages(p, num_pages, 1);
 
 	current->mm->locked_vm -= num_pages;
 
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 }
 
 struct ipath_user_pages_work {
@@ -219,9 +219,9 @@ static void user_pages_account(struct wo
 	struct ipath_user_pages_work *work =
 		container_of(_work, struct ipath_user_pages_work, work);
 
-	down_write(&work->mm->mmap_sem);
+	rw_mutex_write_lock(&work->mm->mmap_lock);
 	work->mm->locked_vm -= work->num_pages;
-	up_write(&work->mm->mmap_sem);
+	rw_mutex_write_unlock(&work->mm->mmap_lock);
 	mmput(work->mm);
 	kfree(work);
 }
Index: linux-2.6/drivers/media/video/cafe_ccic.c
===================================================================
--- linux-2.6.orig/drivers/media/video/cafe_ccic.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/media/video/cafe_ccic.c	2007-05-11 15:06:00.000000000 +0200
@@ -1375,7 +1375,7 @@ static void cafe_v4l_vm_open(struct vm_a
 {
 	struct cafe_sio_buffer *sbuf = vma->vm_private_data;
 	/*
-	 * Locking: done under mmap_sem, so we don't need to
+	 * Locking: done under mmap_lock, so we don't need to
 	 * go back to the camera lock here.
 	 */
 	sbuf->mapcount++;
Index: linux-2.6/drivers/media/video/video-buf.c
===================================================================
--- linux-2.6.orig/drivers/media/video/video-buf.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/media/video/video-buf.c	2007-05-11 15:06:00.000000000 +0200
@@ -150,12 +150,12 @@ int videobuf_dma_init_user(struct videob
 
 	dma->varea = (void *) data;
 
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	err = get_user_pages(current,current->mm,
 			     data & PAGE_MASK, dma->nr_pages,
 			     rw == READ, 1, /* force */
 			     dma->pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
 		dprintk(1,"get_user_pages: err=%d [%d]\n",err,dma->nr_pages);
Index: linux-2.6/drivers/oprofile/buffer_sync.c
===================================================================
--- linux-2.6.orig/drivers/oprofile/buffer_sync.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/oprofile/buffer_sync.c	2007-05-11 15:06:00.000000000 +0200
@@ -81,11 +81,11 @@ static int munmap_notify(struct notifier
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * mpnt;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -93,7 +93,7 @@ static int munmap_notify(struct notifier
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return 0;
 }
 
@@ -366,7 +366,7 @@ static void release_mm(struct mm_struct 
 {
 	if (!mm)
 		return;
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 }
 
@@ -375,7 +375,7 @@ static struct mm_struct * take_tasks_mm(
 {
 	struct mm_struct * mm = get_task_mm(task);
 	if (mm)
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	return mm;
 }
 
@@ -486,7 +486,7 @@ typedef enum {
 
 /* Sync one of the CPU's buffers into the global event buffer.
  * Here we need to go through each batch of samples punctuated
- * by context switch notes, taking the task's mmap_sem and doing
+ * by context switch notes, taking the task's mmap_lock and doing
  * lookup in task->mm->mmap to convert EIP into dcookie/offset
  * value.
  */
Index: linux-2.6/drivers/scsi/sg.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sg.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/scsi/sg.c	2007-05-11 15:06:00.000000000 +0200
@@ -1716,7 +1716,7 @@ st_map_user_pages(struct scatterlist *sg
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages(
 		current,
@@ -1727,7 +1727,7 @@ st_map_user_pages(struct scatterlist *sg
 		0, /* don't force */
 		pages,
 		NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
Index: linux-2.6/drivers/scsi/st.c
===================================================================
--- linux-2.6.orig/drivers/scsi/st.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/scsi/st.c	2007-05-11 15:06:00.000000000 +0200
@@ -4420,7 +4420,7 @@ static int sgl_map_user_pages(struct sca
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages(
 		current,
@@ -4431,7 +4431,7 @@ static int sgl_map_user_pages(struct sca
 		0, /* don't force */
 		pages,
 		NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
Index: linux-2.6/drivers/video/pvr2fb.c
===================================================================
--- linux-2.6.orig/drivers/video/pvr2fb.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/video/pvr2fb.c	2007-05-11 15:06:00.000000000 +0200
@@ -688,10 +688,10 @@ static ssize_t pvr2fb_write(struct fb_in
 	if (!pages)
 		return -ENOMEM;
 	
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	ret = get_user_pages(current, current->mm, (unsigned long)buf,
 			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;
Index: linux-2.6/fs/aio.c
===================================================================
--- linux-2.6.orig/fs/aio.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/aio.c	2007-05-11 15:06:00.000000000 +0200
@@ -87,9 +87,9 @@ static void aio_free_ring(struct kioctx 
 		put_page(info->ring_pages[i]);
 
 	if (info->mmap_size) {
-		down_write(&ctx->mm->mmap_sem);
+		rw_mutex_write_lock(&ctx->mm->mmap_lock);
 		do_munmap(ctx->mm, info->mmap_base, info->mmap_size);
-		up_write(&ctx->mm->mmap_sem);
+		rw_mutex_write_unlock(&ctx->mm->mmap_lock);
 	}
 
 	if (info->ring_pages && info->ring_pages != info->internal_pages)
@@ -128,12 +128,12 @@ static int aio_setup_ring(struct kioctx 
 
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
-	down_write(&ctx->mm->mmap_sem);
+	rw_mutex_write_lock(&ctx->mm->mmap_lock);
 	info->mmap_base = do_mmap(NULL, 0, info->mmap_size, 
 				  PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE,
 				  0);
 	if (IS_ERR((void *)info->mmap_base)) {
-		up_write(&ctx->mm->mmap_sem);
+		rw_mutex_write_unlock(&ctx->mm->mmap_lock);
 		info->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
@@ -143,7 +143,7 @@ static int aio_setup_ring(struct kioctx 
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 
 					1, 0, info->ring_pages, NULL);
-	up_write(&ctx->mm->mmap_sem);
+	rw_mutex_write_unlock(&ctx->mm->mmap_lock);
 
 	if (unlikely(info->nr_pages != nr_pages)) {
 		aio_free_ring(ctx);
Index: linux-2.6/fs/binfmt_aout.c
===================================================================
--- linux-2.6.orig/fs/binfmt_aout.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/binfmt_aout.c	2007-05-11 15:06:00.000000000 +0200
@@ -49,9 +49,9 @@ static int set_brk(unsigned long start, 
 	end = PAGE_ALIGN(end);
 	if (end > start) {
 		unsigned long addr;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		addr = do_brk(start, end - start);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (BAD_ADDR(addr))
 			return addr;
 	}
@@ -331,14 +331,14 @@ static int load_aout_binary(struct linux
 		loff_t pos = fd_offset;
 		/* Fuck me plenty... */
 		/* <AOL></AOL> */
-		down_write(&current->mm->mmap_sem);	
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(N_TXTADDR(ex), ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		bprm->file->f_op->read(bprm->file, (char *) N_TXTADDR(ex),
 			  ex.a_text, &pos);
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(N_DATADDR(ex), ex.a_data);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		bprm->file->f_op->read(bprm->file, (char *) N_DATADDR(ex),
 			  ex.a_data, &pos);
 		goto beyond_if;
@@ -358,9 +358,9 @@ static int load_aout_binary(struct linux
 		pos = 32;
 		map_size = ex.a_text+ex.a_data;
 #endif
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(text_addr & PAGE_MASK, map_size);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (error != (text_addr & PAGE_MASK)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -395,9 +395,9 @@ static int load_aout_binary(struct linux
 
 		if (!bprm->file->f_op->mmap||((fd_offset & ~PAGE_MASK) != 0)) {
 			loff_t pos = fd_offset;
-			down_write(&current->mm->mmap_sem);
+			rw_mutex_write_lock(&current->mm->mmap_lock);
 			do_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
-			up_write(&current->mm->mmap_sem);
+			rw_mutex_write_unlock(&current->mm->mmap_lock);
 			bprm->file->f_op->read(bprm->file,
 					(char __user *)N_TXTADDR(ex),
 					ex.a_text+ex.a_data, &pos);
@@ -407,24 +407,24 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -509,9 +509,9 @@ static int load_aout_library(struct file
 			       file->f_path.dentry->d_name.name);
 			error_time = jiffies;
 		}
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		do_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		
 		file->f_op->read(file, (char __user *)start_addr,
 			ex.a_text + ex.a_data, &pos);
@@ -522,12 +522,12 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	retval = error;
 	if (error != start_addr)
 		goto out;
@@ -535,9 +535,9 @@ static int load_aout_library(struct file
 	len = PAGE_ALIGN(ex.a_text + ex.a_data);
 	bss = ex.a_text + ex.a_data + ex.a_bss;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(start_addr + len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		retval = error;
 		if (error != start_addr + len)
 			goto out;
Index: linux-2.6/fs/binfmt_elf.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/binfmt_elf.c	2007-05-11 15:06:00.000000000 +0200
@@ -88,9 +88,9 @@ static int set_brk(unsigned long start, 
 	end = ELF_PAGEALIGN(end);
 	if (end > start) {
 		unsigned long addr;
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		addr = do_brk(start, end - start);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (BAD_ADDR(addr))
 			return addr;
 	}
@@ -290,7 +290,7 @@ static unsigned long elf_map(struct file
 	unsigned long map_addr;
 	unsigned long pageoffset = ELF_PAGEOFFSET(eppnt->p_vaddr);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	/* mmap() will return -EINVAL if given a zero size, but a
 	 * segment with zero filesize is perfectly valid */
 	if (eppnt->p_filesz + pageoffset)
@@ -299,7 +299,7 @@ static unsigned long elf_map(struct file
 				   eppnt->p_offset - pageoffset);
 	else
 		map_addr = ELF_PAGESTART(addr);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return(map_addr);
 }
 
@@ -435,9 +435,9 @@ static unsigned long load_elf_interp(str
 
 	/* Map the last of the bss segment */
 	if (last_bss > elf_bss) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_brk(elf_bss, last_bss - elf_bss);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (BAD_ADDR(error))
 			goto out_close;
 	}
@@ -477,9 +477,9 @@ static unsigned long load_aout_interp(st
 		goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);	
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	do_brk(0, text_data);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (!interpreter->f_op || !interpreter->f_op->read)
 		goto out;
 	if (interpreter->f_op->read(interpreter, addr, text_data, &offset) < 0)
@@ -487,10 +487,10 @@ static unsigned long load_aout_interp(st
 	flush_icache_range((unsigned long)addr,
 	                   (unsigned long)addr + text_data);
 
-	down_write(&current->mm->mmap_sem);	
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	do_brk(ELF_PAGESTART(text_data + ELF_MIN_ALIGN - 1),
 		interp_ex->a_bss);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	elf_entry = interp_ex->a_entry;
 
 out:
@@ -1005,10 +1005,10 @@ static int load_elf_binary(struct linux_
 		   and some applications "depend" upon this behavior.
 		   Since we do not have the power to recompile these, we
 		   emulate the SVr4 behavior. Sigh. */
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		error = do_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 
 #ifdef ELF_PLAT_INIT
@@ -1104,7 +1104,7 @@ static int load_elf_library(struct file 
 		eppnt++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap(file,
 			ELF_PAGESTART(eppnt->p_vaddr),
 			(eppnt->p_filesz +
@@ -1113,7 +1113,7 @@ static int load_elf_library(struct file 
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			(eppnt->p_offset -
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (error != ELF_PAGESTART(eppnt->p_vaddr))
 		goto out_free_ph;
 
@@ -1127,9 +1127,9 @@ static int load_elf_library(struct file 
 			    ELF_MIN_ALIGN - 1);
 	bss = eppnt->p_memsz + eppnt->p_vaddr;
 	if (bss > len) {
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		do_brk(len, bss - len);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	}
 	error = 0;
 
Index: linux-2.6/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf_fdpic.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/binfmt_elf_fdpic.c	2007-05-11 15:06:00.000000000 +0200
@@ -370,14 +370,14 @@ static int load_elf_fdpic_binary(struct 
 	if (stack_size < PAGE_SIZE * 2)
 		stack_size = PAGE_SIZE * 2;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	current->mm->start_brk = do_mmap(NULL, 0, stack_size,
 					 PROT_READ | PROT_WRITE | PROT_EXEC,
 					 MAP_PRIVATE | MAP_ANONYMOUS | MAP_GROWSDOWN,
 					 0);
 
 	if (IS_ERR_VALUE(current->mm->start_brk)) {
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		retval = current->mm->start_brk;
 		current->mm->start_brk = 0;
 		goto error_kill;
@@ -388,7 +388,7 @@ static int load_elf_fdpic_binary(struct 
 	if (!IS_ERR_VALUE(do_mremap(current->mm->start_brk, stack_size,
 				    fullsize, 0, 0)))
 		stack_size = fullsize;
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	current->mm->brk = current->mm->start_brk;
 	current->mm->context.end_brk = current->mm->start_brk;
@@ -904,10 +904,10 @@ static int elf_fdpic_map_file_constdisp_
 	if (params->flags & ELF_FDPIC_FLAG_EXECUTABLE)
 		mflags |= MAP_EXECUTABLE;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	maddr = do_mmap(NULL, load_addr, top - base,
 			PROT_READ | PROT_WRITE | PROT_EXEC, mflags, 0);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	if (IS_ERR_VALUE(maddr))
 		return (int) maddr;
 
@@ -1050,10 +1050,10 @@ static int elf_fdpic_map_file_by_direct_
 
 		/* create the mapping */
 		disp = phdr->p_vaddr & ~PAGE_MASK;
-		down_write(&mm->mmap_sem);
+		rw_mutex_write_lock(&mm->mmap_lock);
 		maddr = do_mmap(file, maddr, phdr->p_memsz + disp, prot, flags,
 				phdr->p_offset - disp);
-		up_write(&mm->mmap_sem);
+		rw_mutex_write_unlock(&mm->mmap_lock);
 
 		kdebug("mmap[%d] <file> sz=%lx pr=%x fl=%x of=%lx --> %08lx",
 		       loop, phdr->p_memsz + disp, prot, flags,
@@ -1096,10 +1096,10 @@ static int elf_fdpic_map_file_by_direct_
 			unsigned long xmaddr;
 
 			flags |= MAP_FIXED | MAP_ANONYMOUS;
-			down_write(&mm->mmap_sem);
+			rw_mutex_write_lock(&mm->mmap_lock);
 			xmaddr = do_mmap(NULL, xaddr, excess - excess1,
 					 prot, flags, 0);
-			up_write(&mm->mmap_sem);
+			rw_mutex_write_unlock(&mm->mmap_lock);
 
 			kdebug("mmap[%d] <anon>"
 			       " ad=%lx sz=%lx pr=%x fl=%x of=0 --> %08lx",
Index: linux-2.6/fs/binfmt_flat.c
===================================================================
--- linux-2.6.orig/fs/binfmt_flat.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/binfmt_flat.c	2007-05-11 15:06:00.000000000 +0200
@@ -529,9 +529,9 @@ static int load_flat_file(struct linux_b
 		 */
 		DBG_FLT("BINFMT_FLAT: ROM mapping of file (we hope)\n");
 
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		textpos = do_mmap(bprm->file, 0, text_len, PROT_READ|PROT_EXEC, MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 		if (!textpos  || textpos >= (unsigned long) -4096) {
 			if (!textpos)
 				textpos = (unsigned long) -ENOMEM;
@@ -541,7 +541,7 @@ static int load_flat_file(struct linux_b
 		}
 
 		len = data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		realdatastart = do_mmap(0, 0, len,
 			PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
@@ -552,7 +552,7 @@ static int load_flat_file(struct linux_b
 					reallen, MREMAP_FIXED, realdatastart);
 			}
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (realdatastart == 0 || realdatastart >= (unsigned long)-4096) {
 			if (!realdatastart)
@@ -593,7 +593,7 @@ static int load_flat_file(struct linux_b
 	} else {
 
 		len = text_len + data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 		textpos = do_mmap(0, 0, len,
 			PROT_READ | PROT_EXEC | PROT_WRITE, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
@@ -604,7 +604,7 @@ static int load_flat_file(struct linux_b
 					MREMAP_FIXED, textpos);
 			}
 		}
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 		if (!textpos  || textpos >= (unsigned long) -4096) {
 			if (!textpos)
Index: linux-2.6/fs/binfmt_som.c
===================================================================
--- linux-2.6.orig/fs/binfmt_som.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/binfmt_som.c	2007-05-11 15:06:00.000000000 +0200
@@ -148,10 +148,10 @@ static int map_som_binary(struct file *f
 	code_size = SOM_PAGEALIGN(hpuxhdr->exec_tsize);
 	current->mm->start_code = code_start;
 	current->mm->end_code = code_start + code_size;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file, code_start, code_size, prot,
 			flags, SOM_PAGESTART(hpuxhdr->exec_tfile));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
@@ -159,20 +159,20 @@ static int map_som_binary(struct file *f
 	data_size = SOM_PAGEALIGN(hpuxhdr->exec_dsize);
 	current->mm->start_data = data_start;
 	current->mm->end_data = bss_start = data_start + data_size;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(file, data_start, data_size,
 			prot | PROT_WRITE, flags,
 			SOM_PAGESTART(hpuxhdr->exec_dfile));
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
 	som_brk = bss_start + SOM_PAGEALIGN(hpuxhdr->exec_bsize);
 	current->mm->start_brk = current->mm->brk = som_brk;
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	retval = do_mmap(NULL, bss_start, som_brk - bss_start,
 			prot | PROT_WRITE, MAP_FIXED | MAP_PRIVATE, 0);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	if (retval > 0 || retval < -1024)
 		retval = 0;
 out:
Index: linux-2.6/fs/bio.c
===================================================================
--- linux-2.6.orig/fs/bio.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/bio.c	2007-05-11 15:06:00.000000000 +0200
@@ -646,11 +646,11 @@ static struct bio *__bio_map_user_iov(re
 		const int local_nr_pages = end - start;
 		const int page_limit = cur_page + local_nr_pages;
 		
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		ret = get_user_pages(current, current->mm, uaddr,
 				     local_nr_pages,
 				     write_to_vm, 0, &pages[cur_page], NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 		if (ret < local_nr_pages) {
 			ret = -EFAULT;
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/block_dev.c	2007-05-11 15:06:00.000000000 +0200
@@ -221,10 +221,10 @@ static struct page *blk_get_page(unsigne
 	if (pvec->idx == pvec->nr) {
 		nr_pages = PAGES_SPANNED(addr, count);
 		nr_pages = min(nr_pages, VEC_SIZE);
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		ret = get_user_pages(current, current->mm, addr, nr_pages,
 				     rw == READ, 0, pvec->page, NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		if (ret < 0)
 			return ERR_PTR(ret);
 		pvec->nr = ret;
Index: linux-2.6/fs/direct-io.c
===================================================================
--- linux-2.6.orig/fs/direct-io.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/direct-io.c	2007-05-11 15:06:00.000000000 +0200
@@ -150,7 +150,7 @@ static int dio_refill_pages(struct dio *
 	int nr_pages;
 
 	nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	ret = get_user_pages(
 		current,			/* Task for fault acounting */
 		current->mm,			/* whose pages? */
@@ -160,7 +160,7 @@ static int dio_refill_pages(struct dio *
 		0,				/* force (?) */
 		&dio->pages[0],
 		NULL);				/* vmas */
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	if (ret < 0 && dio->blocks_available && (dio->rw & WRITE)) {
 		struct page *page = ZERO_PAGE(dio->curr_user_address);
Index: linux-2.6/fs/exec.c
===================================================================
--- linux-2.6.orig/fs/exec.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/exec.c	2007-05-11 15:06:00.000000000 +0200
@@ -302,7 +302,7 @@ EXPORT_SYMBOL(copy_strings_kernel);
  * This routine is used to map in a page into an address space: needed by
  * execve() for the initial stack and environment pages.
  *
- * vma->vm_mm->mmap_sem is held for writing.
+ * vma->vm_mm->mmap_lock is held for writing.
  */
 void install_arg_page(struct vm_area_struct *vma,
 			struct page *page, unsigned long address)
@@ -410,7 +410,7 @@ int setup_arg_pages(struct linux_binprm 
 	if (!mpnt)
 		return -ENOMEM;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	{
 		mpnt->vm_mm = mm;
 #ifdef CONFIG_STACK_GROWSUP
@@ -432,7 +432,7 @@ int setup_arg_pages(struct linux_binprm 
 		mpnt->vm_flags |= mm->def_flags;
 		mpnt->vm_page_prot = protection_map[mpnt->vm_flags & 0x7];
 		if ((ret = insert_vm_struct(mm, mpnt))) {
-			up_write(&mm->mmap_sem);
+			rw_mutex_write_unlock(&mm->mmap_lock);
 			kmem_cache_free(vm_area_cachep, mpnt);
 			return ret;
 		}
@@ -447,7 +447,7 @@ int setup_arg_pages(struct linux_binprm 
 		}
 		stack_base += PAGE_SIZE;
 	}
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	
 	return 0;
 }
@@ -539,14 +539,14 @@ static int exec_mmap(struct mm_struct *m
 		/*
 		 * Make sure that if there is a core dump in progress
 		 * for the old mm, we get out and die instead of going
-		 * through with the exec.  We must hold mmap_sem around
+		 * through with the exec.  We must hold mmap_lock around
 		 * checking core_waiters and changing tsk->mm.  The
 		 * core-inducing thread will increment core_waiters for
 		 * each thread whose ->mm == old_mm.
 		 */
-		down_read(&old_mm->mmap_sem);
+		rw_mutex_read_lock(&old_mm->mmap_lock);
 		if (unlikely(old_mm->core_waiters)) {
-			up_read(&old_mm->mmap_sem);
+			rw_mutex_read_unlock(&old_mm->mmap_lock);
 			return -EINTR;
 		}
 	}
@@ -558,7 +558,7 @@ static int exec_mmap(struct mm_struct *m
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		rw_mutex_read_unlock(&old_mm->mmap_lock);
 		BUG_ON(active_mm != old_mm);
 		mmput(old_mm);
 		return 0;
@@ -1454,7 +1454,7 @@ static int coredump_wait(int exit_code)
 	mm->core_startup_done = &startup_done;
 
 	core_waiters = zap_threads(tsk, mm, exit_code);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 
 	if (unlikely(core_waiters < 0))
 		goto fail;
@@ -1491,9 +1491,9 @@ int do_coredump(long signr, int exit_cod
 	binfmt = current->binfmt;
 	if (!binfmt || !binfmt->core_dump)
 		goto fail;
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	if (!mm->dumpable) {
-		up_write(&mm->mmap_sem);
+		rw_mutex_write_unlock(&mm->mmap_lock);
 		goto fail;
 	}
 
Index: linux-2.6/fs/fuse/dev.c
===================================================================
--- linux-2.6.orig/fs/fuse/dev.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/fuse/dev.c	2007-05-11 15:06:00.000000000 +0200
@@ -492,10 +492,10 @@ static int fuse_copy_fill(struct fuse_co
 		cs->iov ++;
 		cs->nr_segs --;
 	}
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	err = get_user_pages(current, current->mm, cs->addr, 1, cs->write, 0,
 			     &cs->pg, NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 	if (err < 0)
 		return err;
 	BUG_ON(err != 1);
Index: linux-2.6/fs/fuse/file.c
===================================================================
--- linux-2.6.orig/fs/fuse/file.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/fuse/file.c	2007-05-11 15:06:00.000000000 +0200
@@ -516,10 +516,10 @@ static int fuse_get_user_pages(struct fu
 	nbytes = min(nbytes, (unsigned) FUSE_MAX_PAGES_PER_REQ << PAGE_SHIFT);
 	npages = (nbytes + offset + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	npages = min(max(npages, 1), FUSE_MAX_PAGES_PER_REQ);
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	npages = get_user_pages(current, current->mm, user_addr, npages, write,
 				0, req->pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 	if (npages < 0)
 		return npages;
 
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/hugetlbfs/inode.c	2007-05-11 15:06:00.000000000 +0200
@@ -96,7 +96,7 @@ out:
 }
 
 /*
- * Called under down_write(mmap_sem).
+ * Called under rw_mutex_write_lock(mmap_lock).
  */
 
 #ifndef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
Index: linux-2.6/fs/nfs/direct.c
===================================================================
--- linux-2.6.orig/fs/nfs/direct.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/nfs/direct.c	2007-05-11 15:06:00.000000000 +0200
@@ -275,10 +275,10 @@ static ssize_t nfs_direct_read_schedule(
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 1, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		if (unlikely(result < data->npages)) {
 			if (result > 0)
 				nfs_direct_release_pages(data->pagevec, result);
@@ -606,10 +606,10 @@ static ssize_t nfs_direct_write_schedule
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		result = get_user_pages(current, current->mm, user_addr,
 					data->npages, 0, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		if (unlikely(result < data->npages)) {
 			if (result > 0)
 				nfs_direct_release_pages(data->pagevec, result);
Index: linux-2.6/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.orig/fs/proc/task_mmu.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/proc/task_mmu.c	2007-05-11 15:06:00.000000000 +0200
@@ -85,7 +85,7 @@ int proc_exe_link(struct inode *inode, s
 	}
 	if (!mm)
 		goto out;
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vma = mm->mmap;
 	while (vma) {
@@ -100,7 +100,7 @@ int proc_exe_link(struct inode *inode, s
 		result = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 out:
 	return result;
@@ -363,12 +363,12 @@ void clear_refs_smap(struct mm_struct *m
 {
 	struct vm_area_struct *vma;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 			walk_page_range(vma, clear_refs_pte_range, NULL);
 	flush_tlb_mm(mm);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 }
 
 static void *m_start(struct seq_file *m, loff_t *pos)
@@ -402,7 +402,7 @@ static void *m_start(struct seq_file *m,
 		return NULL;
 
 	priv->tail_vma = tail_vma = get_gate_vma(priv->task);
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/* Start with last addr hint */
 	if (last_addr && (vma = find_vma(mm, last_addr))) {
@@ -431,7 +431,7 @@ out:
 
 	/* End of vmas has been reached */
 	m->version = (tail_vma != NULL)? 0: -1UL;
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 	return tail_vma;
 }
@@ -440,7 +440,7 @@ static void vma_stop(struct proc_maps_pr
 {
 	if (vma && vma != priv->tail_vma) {
 		struct mm_struct *mm = vma->vm_mm;
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		mmput(mm);
 	}
 }
Index: linux-2.6/fs/proc/task_nommu.c
===================================================================
--- linux-2.6.orig/fs/proc/task_nommu.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/proc/task_nommu.c	2007-05-11 15:06:00.000000000 +0200
@@ -17,7 +17,7 @@ char *task_mem(struct mm_struct *mm, cha
 	struct vm_list_struct *vml;
 	unsigned long bytes = 0, sbytes = 0, slack = 0;
         
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	for (vml = mm->context.vmlist; vml; vml = vml->next) {
 		if (!vml->vma)
 			continue;
@@ -64,7 +64,7 @@ char *task_mem(struct mm_struct *mm, cha
 		"Shared:\t%8lu bytes\n",
 		bytes, slack, sbytes);
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return buffer;
 }
 
@@ -73,12 +73,12 @@ unsigned long task_vsize(struct mm_struc
 	struct vm_list_struct *tbp;
 	unsigned long vsize = 0;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	for (tbp = mm->context.vmlist; tbp; tbp = tbp->next) {
 		if (tbp->vma)
 			vsize += kobjsize((void *) tbp->vma->vm_start);
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return vsize;
 }
 
@@ -88,7 +88,7 @@ int task_statm(struct mm_struct *mm, int
 	struct vm_list_struct *tbp;
 	int size = kobjsize(mm);
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	for (tbp = mm->context.vmlist; tbp; tbp = tbp->next) {
 		size += kobjsize(tbp);
 		if (tbp->vma) {
@@ -99,7 +99,7 @@ int task_statm(struct mm_struct *mm, int
 
 	size += (*text = mm->end_code - mm->start_code);
 	size += (*data = mm->start_stack - mm->start_data);
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	*resident = size;
 	return size;
 }
@@ -114,7 +114,7 @@ int proc_exe_link(struct inode *inode, s
 
 	if (!mm)
 		goto out;
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	vml = mm->context.vmlist;
 	vma = NULL;
@@ -132,7 +132,7 @@ int proc_exe_link(struct inode *inode, s
 		result = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 out:
 	return result;
@@ -172,7 +172,7 @@ static void *m_start(struct seq_file *m,
 		return NULL;
 	}
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/* start from the Nth VMA */
 	for (vml = mm->context.vmlist; vml; vml = vml->next)
@@ -187,7 +187,7 @@ static void m_stop(struct seq_file *m, v
 
 	if (priv->task) {
 		struct mm_struct *mm = priv->task->mm;
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 		mmput(mm);
 		put_task_struct(priv->task);
 	}
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/fs/splice.c	2007-05-11 15:06:00.000000000 +0200
@@ -1143,10 +1143,10 @@ static int get_iovec_page_array(const st
 	int buffers = 0, error = 0;
 
 	/*
-	 * It's ok to take the mmap_sem for reading, even
+	 * It's ok to take the mmap_lock for reading, even
 	 * across a "get_user()".
 	 */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 
 	while (nr_vecs) {
 		unsigned long off, npages;
@@ -1232,7 +1232,7 @@ static int get_iovec_page_array(const st
 		iov++;
 	}
 
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	if (buffers)
 		return buffers;
Index: linux-2.6/include/linux/init_task.h
===================================================================
--- linux-2.6.orig/include/linux/init_task.h	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/include/linux/init_task.h	2007-05-11 15:06:00.000000000 +0200
@@ -50,7 +50,6 @@
 	.pgd		= swapper_pg_dir, 			\
 	.mm_users	= ATOMIC_INIT(2), 			\
 	.mm_count	= ATOMIC_INIT(1), 			\
-	.mmap_sem	= __RWSEM_INITIALIZER(name.mmap_sem),	\
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
Index: linux-2.6/include/linux/mempolicy.h
===================================================================
--- linux-2.6.orig/include/linux/mempolicy.h	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/include/linux/mempolicy.h	2007-05-11 15:06:00.000000000 +0200
@@ -50,7 +50,7 @@ struct mm_struct;
  * Locking policy for interlave:
  * In process context there is no locking because only the process accesses
  * its own state. All vma manipulation is somewhat protected by a down_read on
- * mmap_sem.
+ * mmap_lock.
  *
  * Freeing policy:
  * When policy is MPOL_BIND v.zonelist is kmalloc'ed and must be kfree'd.
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/include/linux/sched.h	2007-05-11 15:06:00.000000000 +0200
@@ -74,6 +74,7 @@ struct sched_param {
 #include <linux/topology.h>
 #include <linux/seccomp.h>
 #include <linux/rcupdate.h>
+#include <linux/rwmutex.h>
 #include <linux/futex.h>
 #include <linux/rtmutex.h>
 
@@ -335,7 +336,7 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
-	struct rw_semaphore mmap_sem;
+	struct rw_mutex mmap_lock;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.  These are globally strung
Index: linux-2.6/include/linux/uaccess.h
===================================================================
--- linux-2.6.orig/include/linux/uaccess.h	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/include/linux/uaccess.h	2007-05-11 15:06:15.000000000 +0200
@@ -62,9 +62,9 @@ static inline unsigned long __copy_from_
  * Safely read from address @addr into variable @revtal.  If a kernel fault
  * happens, handle that and return -EFAULT.
  * We ensure that the __get_user() is executed in atomic context so that
- * do_page_fault() doesn't attempt to take mmap_sem.  This makes
+ * do_page_fault() doesn't attempt to take mmap_lock.  This makes
  * probe_kernel_address() suitable for use within regions where the caller
- * already holds mmap_sem, or other locks which nest inside mmap_sem.
+ * already holds mmap_lock, or other locks which nest inside mmap_lock.
  * This must be a macro because __get_user() needs to know the types of the
  * args.
  *
Index: linux-2.6/ipc/shm.c
===================================================================
--- linux-2.6.orig/ipc/shm.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/ipc/shm.c	2007-05-11 15:06:00.000000000 +0200
@@ -924,7 +924,7 @@ long do_shmat(int shmid, char __user *sh
 	sfd->file = shp->shm_file;
 	sfd->vm_ops = NULL;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	if (addr && !(shmflg & SHM_REMAP)) {
 		err = -EINVAL;
 		if (find_vma_intersection(current->mm, addr, addr + size))
@@ -944,7 +944,7 @@ long do_shmat(int shmid, char __user *sh
 	if (IS_ERR_VALUE(user_addr))
 		err = (long)user_addr;
 invalid:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	fput(file);
 
@@ -1002,7 +1002,7 @@ asmlinkage long sys_shmdt(char __user *s
 	if (addr & ~PAGE_MASK)
 		return retval;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 
 	/*
 	 * This function tries to be smart and unmap shm segments that
@@ -1070,7 +1070,7 @@ asmlinkage long sys_shmdt(char __user *s
 		vma = next;
 	}
 
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return retval;
 }
 
Index: linux-2.6/kernel/acct.c
===================================================================
--- linux-2.6.orig/kernel/acct.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/acct.c	2007-05-11 15:06:00.000000000 +0200
@@ -39,7 +39,7 @@
  *  is one more bug... 10/11/98, AV.
  *
  *	Oh, fsck... Oopsable SMP race in do_process_acct() - we must hold
- * ->mmap_sem to walk the vma list of current->mm. Nasty, since it leaks
+ * ->mmap_lock to walk the vma list of current->mm. Nasty, since it leaks
  * a struct file opened for write. Fixed. 2/6/2000, AV.
  */
 
@@ -539,13 +539,13 @@ void acct_collect(long exitcode, int gro
 
 	if (group_dead && current->mm) {
 		struct vm_area_struct *vma;
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		vma = current->mm->mmap;
 		while (vma) {
 			vsize += vma->vm_end - vma->vm_start;
 			vma = vma->vm_next;
 		}
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 	}
 
 	spin_lock_irq(&current->sighand->siglock);
Index: linux-2.6/kernel/auditsc.c
===================================================================
--- linux-2.6.orig/kernel/auditsc.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/auditsc.c	2007-05-11 15:06:00.000000000 +0200
@@ -778,7 +778,7 @@ static void audit_log_task_info(struct a
 	audit_log_untrustedstring(ab, name);
 
 	if (mm) {
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		vma = mm->mmap;
 		while (vma) {
 			if ((vma->vm_flags & VM_EXECUTABLE) &&
@@ -790,7 +790,7 @@ static void audit_log_task_info(struct a
 			}
 			vma = vma->vm_next;
 		}
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 	}
 	audit_log_task_context(ab);
 }
Index: linux-2.6/kernel/cpuset.c
===================================================================
--- linux-2.6.orig/kernel/cpuset.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/cpuset.c	2007-05-11 15:06:00.000000000 +0200
@@ -618,7 +618,7 @@ static void guarantee_online_mems(const 
  * called with or without manage_mutex held.  Thanks in part to
  * 'the_top_cpuset_hack', the tasks cpuset pointer will never
  * be NULL.  This routine also might acquire callback_mutex and
- * current->mm->mmap_sem during call.
+ * current->mm->mmap_lock during call.
  *
  * Reading current->cpuset->mems_generation doesn't need task_lock
  * to guard the current->cpuset derefence, because it is guarded
@@ -909,7 +909,7 @@ static void cpuset_migrate_mm(struct mm_
  *
  * Call with manage_mutex held.  May take callback_mutex during call.
  * Will take tasklist_lock, scan tasklist for tasks in cpuset cs,
- * lock each such tasks mm->mmap_sem, scan its vma's and rebind
+ * lock each such tasks mm->mmap_lock, scan its vma's and rebind
  * their mempolicies to the cpusets new mems_allowed.
  */
 
@@ -1012,7 +1012,7 @@ static int update_nodemask(struct cpuset
 	 * Now that we've dropped the tasklist spinlock, we can
 	 * rebind the vma mempolicies of each mm in mmarray[] to their
 	 * new cpuset, and release that mm.  The mpol_rebind_mm()
-	 * call takes mmap_sem, which we couldn't take while holding
+	 * call takes mmap_lock, which we couldn't take while holding
 	 * tasklist_lock.  Forks can happen again now - the mpol_copy()
 	 * cpuset_being_rebound check will catch such forks, and rebind
 	 * their vma mempolicies too.  Because we still hold the global
Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/exit.c	2007-05-11 15:06:00.000000000 +0200
@@ -554,28 +554,28 @@ static void exit_mm(struct task_struct *
 		return;
 	/*
 	 * Serialize with any possible pending coredump.
-	 * We must hold mmap_sem around checking core_waiters
+	 * We must hold mmap_lock around checking core_waiters
 	 * and clearing tsk->mm.  The core-inducing thread
 	 * will increment core_waiters for each thread in the
 	 * group with ->mm != NULL.
 	 */
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	if (mm->core_waiters) {
-		up_read(&mm->mmap_sem);
-		down_write(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
+		rw_mutex_write_lock(&mm->mmap_lock);
 		if (!--mm->core_waiters)
 			complete(mm->core_startup_done);
-		up_write(&mm->mmap_sem);
+		rw_mutex_write_unlock(&mm->mmap_lock);
 
 		wait_for_completion(&mm->core_done);
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	}
 	atomic_inc(&mm->mm_count);
 	BUG_ON(mm != tsk->active_mm);
 	/* more a memory barrier than a real lock */
 	task_lock(tsk);
 	tsk->mm = NULL;
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mmput(mm);
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/fork.c	2007-05-11 15:06:00.000000000 +0200
@@ -155,6 +155,8 @@ void __init fork_init(unsigned long memp
 	init_task.signal->rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
+
+	rw_mutex_init(&init_mm.mmap_lock);
 }
 
 static struct task_struct *dup_task_struct(struct task_struct *orig)
@@ -201,12 +203,12 @@ static inline int dup_mmap(struct mm_str
 	unsigned long charge;
 	struct mempolicy *pol;
 
-	down_write(&oldmm->mmap_sem);
+	rw_mutex_write_lock(&oldmm->mmap_lock);
 	flush_cache_dup_mm(oldmm);
 	/*
 	 * Not linked in yet - no deadlock potential:
 	 */
-	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
+	rw_mutex_write_lock_nested(&mm->mmap_lock, SINGLE_DEPTH_NESTING);
 
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
@@ -289,9 +291,9 @@ static inline int dup_mmap(struct mm_str
 	arch_dup_mmap(oldmm, mm);
 	retval = 0;
 out:
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	flush_tlb_mm(oldmm);
-	up_write(&oldmm->mmap_sem);
+	rw_mutex_write_unlock(&oldmm->mmap_lock);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
@@ -322,7 +324,12 @@ static inline void mm_free_pgd(struct mm
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
 #define allocate_mm()	(kmem_cache_alloc(mm_cachep, GFP_KERNEL))
-#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
+
+static void free_mm(struct mm_struct *mm)
+{
+	rw_mutex_destroy(&mm->mmap_lock);
+	kmem_cache_free(mm_cachep, mm);
+}
 
 #include <linux/init_task.h>
 
@@ -330,7 +337,7 @@ static struct mm_struct * mm_init(struct
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	rw_mutex_init(&mm->mmap_lock);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_waiters = 0;
 	mm->nr_ptes = 0;
Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/futex.c	2007-05-11 15:06:00.000000000 +0200
@@ -157,7 +157,7 @@ static inline int match_futex(union fute
  * get_futex_key - Get parameters which are the keys for a futex.
  * @uaddr: virtual address of the futex
  * @shared: NULL for a PROCESS_PRIVATE futex,
- *	&current->mm->mmap_sem for a PROCESS_SHARED futex
+ *	&current->mm->mmap_lock for a PROCESS_SHARED futex
  * @key: address where result is stored.
  *
  * Returns a negative error code or 0
@@ -168,10 +168,10 @@ static inline int match_futex(union fute
  * We can usually work out the index without swapping in the page.
  *
  * fshared is NULL for PROCESS_PRIVATE futexes
- * For other futexes, it points to &current->mm->mmap_sem and
+ * For other futexes, it points to &current->mm->mmap_lock and
  * caller must have taken the reader lock. but NOT any spinlocks.
  */
-int get_futex_key(u32 __user *uaddr, struct rw_semaphore *fshared,
+int get_futex_key(u32 __user *uaddr, struct rw_mutex *fshared,
 		  union futex_key *key)
 {
 	unsigned long address = (unsigned long)uaddr;
@@ -315,10 +315,10 @@ static inline int get_futex_value_locked
 
 /*
  * Fault handling.
- * if fshared is non NULL, current->mm->mmap_sem is already held
+ * if fshared is non NULL, current->mm->mmap_lock is already held
  */
 static int futex_handle_fault(unsigned long address,
-			      struct rw_semaphore *fshared, int attempt)
+			      struct rw_mutex *fshared, int attempt)
 {
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
@@ -328,7 +328,7 @@ static int futex_handle_fault(unsigned l
 		return ret;
 
 	if (!fshared)
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, address);
 	if (vma && address >= vma->vm_start &&
 	    (vma->vm_flags & VM_WRITE)) {
@@ -344,7 +344,7 @@ static int futex_handle_fault(unsigned l
 		}
 	}
 	if (!fshared)
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 	return ret;
 }
 
@@ -688,7 +688,7 @@ double_lock_hb(struct futex_hash_bucket 
  * Wake up all waiters hashed on the physical page that is mapped
  * to this virtual address:
  */
-static int futex_wake(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int futex_wake(u32 __user *uaddr, struct rw_mutex *fshared,
 		      int nr_wake)
 {
 	struct futex_hash_bucket *hb;
@@ -698,7 +698,7 @@ static int futex_wake(u32 __user *uaddr,
 	int ret;
 
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
@@ -723,7 +723,7 @@ static int futex_wake(u32 __user *uaddr,
 	spin_unlock(&hb->lock);
 out:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 }
 
@@ -791,7 +791,7 @@ retry:
  * one physical page to another physical page (PI-futex uaddr2)
  */
 static int futex_requeue_pi(u32 __user *uaddr1,
-			    struct rw_semaphore *fshared,
+			    struct rw_mutex *fshared,
 			    u32 __user *uaddr2,
 			    int nr_wake, int nr_requeue, u32 *cmpval)
 {
@@ -812,7 +812,7 @@ retry:
 	 * First take all the futex related locks:
 	 */
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
@@ -837,11 +837,11 @@ retry:
 				spin_unlock(&hb2->lock);
 
 			/*
-			 * If we would have faulted, release mmap_sem, fault
+			 * If we would have faulted, release mmap_lock, fault
 			 * it in and start all over again.
 			 */
 			if (fshared)
-				up_read(fshared);
+				rw_mutex_read_unlock(fshared);
 
 			ret = get_user(curval, uaddr1);
 
@@ -976,7 +976,7 @@ out_unlock:
 
 out:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 }
 
@@ -985,7 +985,7 @@ out:
  * to this virtual address:
  */
 static int
-futex_wake_op(u32 __user *uaddr1, struct rw_semaphore *fshared,
+futex_wake_op(u32 __user *uaddr1, struct rw_mutex *fshared,
 	      u32 __user *uaddr2,
 	      int nr_wake, int nr_wake2, int op)
 {
@@ -997,7 +997,7 @@ futex_wake_op(u32 __user *uaddr1, struct
 
 retryfull:
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
@@ -1039,7 +1039,7 @@ retry:
 		 * *(int __user *)uaddr2, but we can't modify it
 		 * non-atomically.  Therefore, if get_user below is not
 		 * enough, we need to handle the fault ourselves, while
-		 * still holding the mmap_sem.
+		 * still holding the mmap_lock.
 		 */
 		if (attempt++) {
 			ret = futex_handle_fault((unsigned long)uaddr2,
@@ -1050,11 +1050,11 @@ retry:
 		}
 
 		/*
-		 * If we would have faulted, release mmap_sem,
+		 * If we would have faulted, release mmap_lock,
 		 * fault it in and start all over again.
 		 */
 		if (fshared)
-			up_read(fshared);
+			rw_mutex_read_unlock(fshared);
 
 		ret = get_user(dummy, uaddr2);
 		if (ret)
@@ -1092,7 +1092,7 @@ retry:
 		spin_unlock(&hb2->lock);
 out:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 }
 
@@ -1100,7 +1100,7 @@ out:
  * Requeue all waiters hashed on one physical page to another
  * physical page.
  */
-static int futex_requeue(u32 __user *uaddr1, struct rw_semaphore *fshared,
+static int futex_requeue(u32 __user *uaddr1, struct rw_mutex *fshared,
 			 u32 __user *uaddr2,
 			 int nr_wake, int nr_requeue, u32 *cmpval)
 {
@@ -1112,7 +1112,7 @@ static int futex_requeue(u32 __user *uad
 
  retry:
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
@@ -1137,11 +1137,11 @@ static int futex_requeue(u32 __user *uad
 				spin_unlock(&hb2->lock);
 
 			/*
-			 * If we would have faulted, release mmap_sem, fault
+			 * If we would have faulted, release mmap_lock, fault
 			 * it in and start all over again.
 			 */
 			if (fshared)
-				up_read(fshared);
+				rw_mutex_read_unlock(fshared);
 
 			ret = get_user(curval, uaddr1);
 
@@ -1195,7 +1195,7 @@ out_unlock:
 
 out:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 }
 
@@ -1329,7 +1329,7 @@ static void unqueue_me_pi(struct futex_q
  * The cur->mm semaphore must be  held, it is released at return of this
  * function.
  */
-static int fixup_pi_state_owner(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int fixup_pi_state_owner(u32 __user *uaddr, struct rw_mutex *fshared,
 				struct futex_q *q,
 				struct futex_hash_bucket *hb,
 				struct task_struct *curr)
@@ -1358,7 +1358,7 @@ static int fixup_pi_state_owner(u32 __us
 	/* Unqueue and drop the lock */
 	unqueue_me_pi(q);
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	/*
 	 * We own it, so we have to replace the pending owner
 	 * TID. This must be atomic as we have preserve the
@@ -1386,7 +1386,7 @@ static int fixup_pi_state_owner(u32 __us
 #define ARG3_SHARED  1
 
 static long futex_wait_restart(struct restart_block *restart);
-static int futex_wait(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int futex_wait(u32 __user *uaddr, struct rw_mutex *fshared,
 		      u32 val, ktime_t *abs_time)
 {
 	struct task_struct *curr = current;
@@ -1401,7 +1401,7 @@ static int futex_wait(u32 __user *uaddr,
 	q.pi_state = NULL;
  retry:
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1435,11 +1435,11 @@ static int futex_wait(u32 __user *uaddr,
 		queue_unlock(&q, hb);
 
 		/*
-		 * If we would have faulted, release mmap_sem, fault it in and
+		 * If we would have faulted, release mmap_lock, fault it in and
 		 * start all over again.
 		 */
 		if (fshared)
-			up_read(fshared);
+			rw_mutex_read_unlock(fshared);
 
 		ret = get_user(uval, uaddr);
 
@@ -1464,10 +1464,10 @@ static int futex_wait(u32 __user *uaddr,
 
 	/*
 	 * Now the futex is queued and we have checked the data, we
-	 * don't want to hold mmap_sem while we sleep.
+	 * don't want to hold mmap_lock while we sleep.
 	 */
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 
 	/*
 	 * There might have been scheduling since the queue_me(), as we
@@ -1538,7 +1538,7 @@ static int futex_wait(u32 __user *uaddr,
 			ret = rt_mutex_timed_lock(lock, to, 1);
 
 		if (fshared)
-			down_read(fshared);
+			rw_mutex_read_lock(fshared);
 		spin_lock(q.lock_ptr);
 
 		/*
@@ -1553,7 +1553,7 @@ static int futex_wait(u32 __user *uaddr,
 			 */
 			uaddr = q.pi_state->key.uaddr;
 
-			/* mmap_sem and hash_bucket lock are unlocked at
+			/* mmap_lock and hash_bucket lock are unlocked at
 			   return of this function */
 			ret = fixup_pi_state_owner(uaddr, fshared,
 						   &q, hb, curr);
@@ -1570,7 +1570,7 @@ static int futex_wait(u32 __user *uaddr,
 			/* Unqueue and drop the lock */
 			unqueue_me_pi(&q);
 			if (fshared)
-				up_read(fshared);
+				rw_mutex_read_unlock(fshared);
 		}
 
 		debug_rt_mutex_free_waiter(&q.waiter);
@@ -1610,7 +1610,7 @@ static int futex_wait(u32 __user *uaddr,
 
  out_release_sem:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 }
 
@@ -1620,11 +1620,11 @@ static long futex_wait_restart(struct re
 	u32 __user *uaddr = (u32 __user *)restart->arg0;
 	u32 val = (u32)restart->arg1;
 	ktime_t *abs_time = (ktime_t *)restart->arg2;
-	struct rw_semaphore *fshared = NULL;
+	struct rw_mutex *fshared = NULL;
 
 	restart->fn = do_no_restart_syscall;
 	if (restart->arg3 & ARG3_SHARED)
-		fshared = &current->mm->mmap_sem;
+		fshared = &current->mm->mmap_lock;
 	return (long)futex_wait(uaddr, fshared, val, abs_time);
 }
 
@@ -1680,7 +1680,7 @@ static void set_pi_futex_owner(struct fu
  * if there are waiters then it will block, it does PI, etc. (Due to
  * races the kernel might see a 0 value of the futex too.)
  */
-static int futex_lock_pi(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int futex_lock_pi(u32 __user *uaddr, struct rw_mutex *fshared,
 			 int detect, ktime_t *time, int trylock)
 {
 	struct hrtimer_sleeper timeout, *to = NULL;
@@ -1703,7 +1703,7 @@ static int futex_lock_pi(u32 __user *uad
 	q.pi_state = NULL;
  retry:
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1824,10 +1824,10 @@ static int futex_lock_pi(u32 __user *uad
 
 	/*
 	 * Now the futex is queued and we have checked the data, we
-	 * don't want to hold mmap_sem while we sleep.
+	 * don't want to hold mmap_lock while we sleep.
 	 */
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 
 	WARN_ON(!q.pi_state);
 	/*
@@ -1842,7 +1842,7 @@ static int futex_lock_pi(u32 __user *uad
 	}
 
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 	spin_lock(q.lock_ptr);
 
 	/*
@@ -1850,7 +1850,7 @@ static int futex_lock_pi(u32 __user *uad
 	 * did a lock-steal - fix up the PI-state in that case.
 	 */
 	if (!ret && q.pi_state->owner != curr)
-		/* mmap_sem is unlocked at return of this function */
+		/* mmap_lock is unlocked at return of this function */
 		ret = fixup_pi_state_owner(uaddr, fshared, &q, hb, curr);
 	else {
 		/*
@@ -1865,7 +1865,7 @@ static int futex_lock_pi(u32 __user *uad
 		/* Unqueue and drop the lock */
 		unqueue_me_pi(&q);
 		if (fshared)
-			up_read(fshared);
+			rw_mutex_read_unlock(fshared);
 	}
 
 	if (!detect && ret == -EDEADLK && 0)
@@ -1878,7 +1878,7 @@ static int futex_lock_pi(u32 __user *uad
 
  out_release_sem:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 	return ret;
 
  uaddr_faulted:
@@ -1886,7 +1886,7 @@ static int futex_lock_pi(u32 __user *uad
 	 * We have to r/w  *(int __user *)uaddr, but we can't modify it
 	 * non-atomically.  Therefore, if get_user below is not
 	 * enough, we need to handle the fault ourselves, while
-	 * still holding the mmap_sem.
+	 * still holding the mmap_lock.
 	 */
 	if (attempt++) {
 		ret = futex_handle_fault((unsigned long)uaddr, fshared,
@@ -1898,7 +1898,7 @@ static int futex_lock_pi(u32 __user *uad
 
 	queue_unlock(&q, hb);
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
@@ -1912,7 +1912,7 @@ static int futex_lock_pi(u32 __user *uad
  * This is the in-kernel slowpath: we look up the PI state (if any),
  * and do the rt-mutex unlock.
  */
-static int futex_unlock_pi(u32 __user *uaddr, struct rw_semaphore *fshared)
+static int futex_unlock_pi(u32 __user *uaddr, struct rw_mutex *fshared)
 {
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
@@ -1933,7 +1933,7 @@ retry:
 	 * First take all the futex related locks:
 	 */
 	if (fshared)
-		down_read(fshared);
+		rw_mutex_read_lock(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
@@ -1995,7 +1995,7 @@ out_unlock:
 	spin_unlock(&hb->lock);
 out:
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 
 	return ret;
 
@@ -2004,7 +2004,7 @@ pi_faulted:
 	 * We have to r/w  *(int __user *)uaddr, but we can't modify it
 	 * non-atomically.  Therefore, if get_user below is not
 	 * enough, we need to handle the fault ourselves, while
-	 * still holding the mmap_sem.
+	 * still holding the mmap_lock.
 	 */
 	if (attempt++) {
 		ret = futex_handle_fault((unsigned long)uaddr, fshared,
@@ -2016,7 +2016,7 @@ pi_faulted:
 
 	spin_unlock(&hb->lock);
 	if (fshared)
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
@@ -2068,7 +2068,7 @@ static int futex_fd(u32 __user *uaddr, i
 	struct futex_q *q;
 	struct file *filp;
 	int ret, err;
-	struct rw_semaphore *fshared;
+	struct rw_mutex *fshared;
 	static unsigned long printk_interval;
 
 	if (printk_timed_ratelimit(&printk_interval, 60 * 60 * 1000)) {
@@ -2110,24 +2110,24 @@ static int futex_fd(u32 __user *uaddr, i
 	}
 	q->pi_state = NULL;
 
-	fshared = &current->mm->mmap_sem;
-	down_read(fshared);
+	fshared = &current->mm->mmap_lock;
+	rw_mutex_read_lock(fshared);
 	err = get_futex_key(uaddr, fshared, &q->key);
 
 	if (unlikely(err != 0)) {
-		up_read(fshared);
+		rw_mutex_read_unlock(fshared);
 		kfree(q);
 		goto error;
 	}
 
 	/*
-	 * queue_me() must be called before releasing mmap_sem, because
+	 * queue_me() must be called before releasing mmap_lock, because
 	 * key->shared.inode needs to be referenced while holding it.
 	 */
 	filp->private_data = q;
 
 	queue_me(q, ret, filp);
-	up_read(fshared);
+	rw_mutex_read_unlock(fshared);
 
 	/* Now we map fd to filp, so userspace can access it */
 	fd_install(ret, filp);
@@ -2256,7 +2256,7 @@ retry:
 		 */
 		if (!pi) {
 			if (uval & FUTEX_WAITERS)
-				futex_wake(uaddr, &curr->mm->mmap_sem, 1);
+				futex_wake(uaddr, &curr->mm->mmap_lock, 1);
 		}
 	}
 	return 0;
@@ -2344,10 +2344,10 @@ long do_futex(u32 __user *uaddr, int op,
 {
 	int ret;
 	int cmd = op & FUTEX_CMD_MASK;
-	struct rw_semaphore *fshared = NULL;
+	struct rw_mutex *fshared = NULL;
 
 	if (!(op & FUTEX_PRIVATE_FLAG))
-		fshared = &current->mm->mmap_sem;
+		fshared = &current->mm->mmap_lock;
 
 	switch (cmd) {
 	case FUTEX_WAIT:
Index: linux-2.6/kernel/relay.c
===================================================================
--- linux-2.6.orig/kernel/relay.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/kernel/relay.c	2007-05-11 15:06:00.000000000 +0200
@@ -77,7 +77,7 @@ static struct vm_operations_struct relay
  *
  *	Returns 0 if ok, negative on error
  *
- *	Caller should already have grabbed mmap_sem.
+ *	Caller should already have grabbed mmap_lock.
  */
 int relay_mmap_buf(struct rchan_buf *buf, struct vm_area_struct *vma)
 {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/filemap.c	2007-05-11 15:06:00.000000000 +0200
@@ -67,16 +67,16 @@ generic_file_direct_IO(int rw, struct ki
  *  ->i_mutex
  *    ->i_mmap_lock		(truncate->unmap_mapping_range)
  *
- *  ->mmap_sem
+ *  ->mmap_lock
  *    ->i_mmap_lock
  *      ->page_table_lock or pte_lock	(various, mainly in memory.c)
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
- *  ->mmap_sem
+ *  ->mmap_lock
  *    ->lock_page		(access_process_vm)
  *
  *  ->i_mutex			(generic_file_buffered_write)
- *    ->mmap_sem		(fault_in_pages_readable->do_page_fault)
+ *    ->mmap_lock		(fault_in_pages_readable->do_page_fault)
  *
  *  ->i_mutex
  *    ->i_alloc_sem             (various)
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/fremap.c	2007-05-11 15:06:00.000000000 +0200
@@ -172,8 +172,8 @@ asmlinkage long sys_remap_file_pages(uns
 		return err;
 #endif
 
-	/* We need down_write() to change vma->vm_flags. */
-	down_read(&mm->mmap_sem);
+	/* We need rw_mutex_write_lock() to change vma->vm_flags. */
+	rw_mutex_read_lock(&mm->mmap_lock);
  retry:
 	vma = find_vma(mm, start);
 
@@ -193,8 +193,8 @@ asmlinkage long sys_remap_file_pages(uns
 		if (pgoff != linear_page_index(vma, start) &&
 		    !(vma->vm_flags & VM_NONLINEAR)) {
 			if (!has_write_lock) {
-				up_read(&mm->mmap_sem);
-				down_write(&mm->mmap_sem);
+				rw_mutex_read_unlock(&mm->mmap_lock);
+				rw_mutex_write_lock(&mm->mmap_lock);
 				has_write_lock = 1;
 				goto retry;
 			}
@@ -219,9 +219,9 @@ asmlinkage long sys_remap_file_pages(uns
 		 */
 	}
 	if (likely(!has_write_lock))
-		up_read(&mm->mmap_sem);
+		rw_mutex_read_unlock(&mm->mmap_lock);
 	else
-		up_write(&mm->mmap_sem);
+		rw_mutex_write_unlock(&mm->mmap_lock);
 
 	return err;
 }
Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/madvise.c	2007-05-11 15:06:15.000000000 +0200
@@ -13,7 +13,7 @@
 
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
- * take mmap_sem for writing. Others, which simply traverse vmas, need
+ * take mmap_lock for writing. Others, which simply traverse vmas, need
  * to only take it for reading.
  */
 static int madvise_need_mmap_write(int behavior)
@@ -89,7 +89,7 @@ static long madvise_behavior(struct vm_a
 
 success:
 	/*
-	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * vm_flags is protected by the mmap_lock held in write mode.
 	 */
 	vma->vm_flags = new_flags;
 
@@ -180,7 +180,7 @@ static long madvise_remove(struct vm_are
 	loff_t offset, endoff;
 	int error;
 
-	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
+	*prev = NULL;	/* tell sys_madvise we drop mmap_lock */
 
 	if (vma->vm_flags & (VM_LOCKED|VM_NONLINEAR|VM_HUGETLB))
 		return -EINVAL;
@@ -201,9 +201,9 @@ static long madvise_remove(struct vm_are
 			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 
 	/* vmtruncate_range needs to take i_mutex and i_alloc_sem */
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	error = vmtruncate_range(mapping->host, offset, endoff);
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	return error;
 }
 
@@ -289,9 +289,9 @@ asmlinkage long sys_madvise(unsigned lon
 	size_t len;
 
 	if (madvise_need_mmap_write(behavior))
-		down_write(&current->mm->mmap_sem);
+		rw_mutex_write_lock(&current->mm->mmap_lock);
 	else
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 
 	if (start & ~PAGE_MASK)
 		goto out;
@@ -349,14 +349,13 @@ asmlinkage long sys_madvise(unsigned lon
 			goto out;
 		if (prev)
 			vma = prev->vm_next;
-		else	/* madvise_remove dropped mmap_sem */
+		else	/* madvise_remove dropped mmap_lock */
 			vma = find_vma(current->mm, start);
 	}
 out:
 	if (madvise_need_mmap_write(behavior))
-		up_write(&current->mm->mmap_sem);
+		rw_mutex_write_unlock(&current->mm->mmap_lock);
 	else
-		up_read(&current->mm->mmap_sem);
-
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 	return error;
 }
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/memory.c	2007-05-11 15:06:00.000000000 +0200
@@ -1622,9 +1622,9 @@ static inline void cow_user_page(struct 
  * change only once the write actually happens. This avoids a few races,
  * and potentially makes it more efficient.
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), with pte both mapped and locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2111,9 +2111,9 @@ void swapin_readahead(swp_entry_t entry,
 }
 
 /*
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2212,9 +2212,9 @@ out_nomap:
 }
 
 /*
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2281,9 +2281,9 @@ oom:
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static int do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2426,9 +2426,9 @@ oom:
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  *
  * It is expected that the ->nopfn handler always returns the same pfn
  * for a given virtual mapping.
@@ -2474,9 +2474,9 @@ static noinline int do_no_pfn(struct mm_
  * from the encoded file_pte if possible. This enables swappable
  * nonlinear vmas.
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static int do_file_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
@@ -2516,9 +2516,9 @@ static int do_file_page(struct mm_struct
  * with external mmu caches can use to update those (ie the Sparc or
  * PowerPC hashed page tables that act as extended TLBs).
  *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
+ * We enter with non-exclusive mmap_lock (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
+ * We return with mmap_lock still held, but pte unmapped and unlocked.
  */
 static inline int handle_pte_fault(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
@@ -2782,7 +2782,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	/* ignore errors, just check how much was sucessfully transfered */
 	while (len) {
 		int bytes, ret, offset;
@@ -2813,7 +2813,7 @@ int access_process_vm(struct task_struct
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 
 	return buf - old_buf;
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mempolicy.c	2007-05-11 15:06:00.000000000 +0200
@@ -531,10 +531,10 @@ long do_get_mempolicy(int *policy, nodem
 	if (flags & ~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR))
 		return -EINVAL;
 	if (flags & MPOL_F_ADDR) {
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
-			up_read(&mm->mmap_sem);
+			rw_mutex_read_unlock(&mm->mmap_lock);
 			return -EFAULT;
 		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
@@ -564,7 +564,7 @@ long do_get_mempolicy(int *policy, nodem
 		*policy = pol->policy;
 
 	if (vma) {
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 		vma = NULL;
 	}
 
@@ -574,7 +574,7 @@ long do_get_mempolicy(int *policy, nodem
 
  out:
 	if (vma)
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 	return err;
 }
 
@@ -633,7 +633,7 @@ int do_migrate_pages(struct mm_struct *m
 	int err = 0;
 	nodemask_t tmp;
 
-  	down_read(&mm->mmap_sem);
+  	rw_mutex_read_lock(&mm->mmap_lock);
 
 	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
 	if (err)
@@ -699,7 +699,7 @@ int do_migrate_pages(struct mm_struct *m
 			break;
 	}
 out:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	if (err < 0)
 		return err;
 	return busy;
@@ -779,7 +779,7 @@ long do_mbind(unsigned long start, unsig
 	PDprintk("mbind %lx-%lx mode:%ld nodes:%lx\n",start,start+len,
 			mode,nodes_addr(nodes)[0]);
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
@@ -797,7 +797,7 @@ long do_mbind(unsigned long start, unsig
 			err = -EIO;
 	}
 
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	mpol_free(new);
 	return err;
 }
@@ -1246,7 +1246,7 @@ static struct page *alloc_page_interleav
  *
  * 	This function allocates a page from the kernel page pool and applies
  *	a NUMA policy associated with the VMA or the current process.
- *	When VMA is not NULL caller must hold down_read on the mmap_sem of the
+ *	When VMA is not NULL caller must hold down_read on the mmap_lock of the
  *	mm_struct of the VMA to prevent it from going away. Should be used for
  *	all allocations for pages that will be mapped into
  * 	user space. Returns NULL when no page can be allocated.
@@ -1690,17 +1690,17 @@ void mpol_rebind_task(struct task_struct
 /*
  * Rebind each vma in mm to new nodemask.
  *
- * Call holding a reference to mm.  Takes mm->mmap_sem during call.
+ * Call holding a reference to mm.  Takes mm->mmap_lock during call.
  */
 
 void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 	struct vm_area_struct *vma;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next)
 		mpol_rebind_policy(vma->vm_policy, new);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 }
 
 /*
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/migrate.c	2007-05-11 15:06:00.000000000 +0200
@@ -210,7 +210,7 @@ static void remove_file_migration_ptes(s
 }
 
 /*
- * Must hold mmap_sem lock on at least one of the vmas containing
+ * Must hold mmap_lock lock on at least one of the vmas containing
  * the page so that the anon_vma cannot vanish.
  */
 static void remove_anon_migration_ptes(struct page *old, struct page *new)
@@ -225,7 +225,7 @@ static void remove_anon_migration_ptes(s
 		return;
 
 	/*
-	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 * We hold the mmap_lock lock. So no need to call page_lock_anon_vma.
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
@@ -776,7 +776,7 @@ static int do_move_pages(struct mm_struc
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/*
 	 * Build a list of pages to migrate
@@ -837,7 +837,7 @@ set_status:
 	else
 		err = -ENOENT;
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return err;
 }
 
@@ -848,7 +848,7 @@ set_status:
  */
 static int do_pages_stat(struct mm_struct *mm, struct page_to_node *pm)
 {
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	for ( ; pm->node != MAX_NUMNODES; pm++) {
 		struct vm_area_struct *vma;
@@ -871,7 +871,7 @@ set_status:
 		pm->status = err;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return 0;
 }
 
Index: linux-2.6/mm/mincore.c
===================================================================
--- linux-2.6.orig/mm/mincore.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mincore.c	2007-05-11 15:06:00.000000000 +0200
@@ -209,9 +209,9 @@ asmlinkage long sys_mincore(unsigned lon
 		 * Do at most PAGE_SIZE entries per iteration, due to
 		 * the temporary buffer size.
 		 */
-		down_read(&current->mm->mmap_sem);
+		rw_mutex_read_lock(&current->mm->mmap_lock);
 		retval = do_mincore(start, tmp, min(pages, PAGE_SIZE));
-		up_read(&current->mm->mmap_sem);
+		rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 		if (retval <= 0)
 			break;
Index: linux-2.6/mm/mlock.c
===================================================================
--- linux-2.6.orig/mm/mlock.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mlock.c	2007-05-11 15:06:00.000000000 +0200
@@ -49,7 +49,7 @@ static int mlock_fixup(struct vm_area_st
 
 success:
 	/*
-	 * vm_flags is protected by the mmap_sem held in write mode.
+	 * vm_flags is protected by the mmap_lock held in write mode.
 	 * It's okay if try_to_unmap_one unmaps a page just after we
 	 * set VM_LOCKED, make_pages_present below will bring it back.
 	 */
@@ -130,7 +130,7 @@ asmlinkage long sys_mlock(unsigned long 
 	if (!can_do_mlock())
 		return -EPERM;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 
@@ -143,7 +143,7 @@ asmlinkage long sys_mlock(unsigned long 
 	/* check against resource limits */
 	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
 		error = do_mlock(start, len, 1);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return error;
 }
 
@@ -151,11 +151,11 @@ asmlinkage long sys_munlock(unsigned lon
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
 	start &= PAGE_MASK;
 	ret = do_mlock(start, len, 0);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
 
@@ -196,7 +196,7 @@ asmlinkage long sys_mlockall(int flags)
 	if (!can_do_mlock())
 		goto out;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
 	lock_limit >>= PAGE_SHIFT;
@@ -205,7 +205,7 @@ asmlinkage long sys_mlockall(int flags)
 	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
 	    capable(CAP_IPC_LOCK))
 		ret = do_mlockall(flags);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 out:
 	return ret;
 }
@@ -214,9 +214,9 @@ asmlinkage long sys_munlockall(void)
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mlockall(0);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
 
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mmap.c	2007-05-11 15:06:00.000000000 +0200
@@ -240,7 +240,7 @@ asmlinkage unsigned long sys_brk(unsigne
 	unsigned long newbrk, oldbrk;
 	struct mm_struct *mm = current->mm;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 
 	if (brk < mm->end_code)
 		goto out;
@@ -278,7 +278,7 @@ set_brk:
 	mm->brk = brk;
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return retval;
 }
 
@@ -886,7 +886,7 @@ void vm_stat_account(struct mm_struct *m
 #endif /* CONFIG_PROC_FS */
 
 /*
- * The caller must hold down_write(current->mm->mmap_sem).
+ * The caller must hold rw_mutex_write_lock(current->mm->mmap_lock).
  */
 
 unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
@@ -1151,10 +1151,10 @@ out:	
 		make_pages_present(addr, addr + len);
 	}
 	if (flags & MAP_POPULATE) {
-		up_write(&mm->mmap_sem);
+		rw_mutex_write_unlock(&mm->mmap_lock);
 		sys_remap_file_pages(addr, len, 0,
 					pgoff, flags & MAP_NONBLOCK);
-		down_write(&mm->mmap_sem);
+		rw_mutex_write_lock(&mm->mmap_lock);
 	}
 	return addr;
 
@@ -1534,7 +1534,7 @@ int expand_upwards(struct vm_area_struct
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
-	 * is required to hold the mmap_sem in read mode.  We need the
+	 * is required to hold the mmap_lock in read mode.  We need the
 	 * anon_vma lock to serialize against concurrent expand_stacks.
 	 */
 	address += 4 + PAGE_SIZE - 1;
@@ -1597,7 +1597,7 @@ int expand_stack(struct vm_area_struct *
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
-	 * is required to hold the mmap_sem in read mode.  We need the
+	 * is required to hold the mmap_lock in read mode.  We need the
 	 * anon_vma lock to serialize against concurrent expand_stacks.
 	 */
 	address &= PAGE_MASK;
@@ -1841,19 +1841,17 @@ asmlinkage long sys_munmap(unsigned long
 
 	profile_munmap(addr);
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return ret;
 }
 
 static inline void verify_mm_writelocked(struct mm_struct *mm)
 {
 #ifdef CONFIG_DEBUG_VM
-	if (unlikely(down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!rw_mutex_is_locked(&mm->mmap_lock)))
 		WARN_ON(1);
-		up_read(&mm->mmap_sem);
-	}
 #endif
 }
 
@@ -1901,7 +1899,7 @@ unsigned long do_brk(unsigned long addr,
 	}
 
 	/*
-	 * mm->mmap_sem is required to protect against another thread
+	 * mm->mmap_lock is required to protect against another thread
 	 * changing the mappings in case we sleep.
 	 */
 	verify_mm_writelocked(mm);
@@ -2130,7 +2128,7 @@ static struct vm_operations_struct speci
 };
 
 /*
- * Called with mm->mmap_sem held for writing.
+ * Called with mm->mmap_lock held for writing.
  * Insert a new vma covering the given region, with the given flags.
  * Its pages are supplied by the given array of struct page *.
  * The array can be shorter than len >> PAGE_SHIFT if it's null-terminated.
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mprotect.c	2007-05-11 15:06:00.000000000 +0200
@@ -189,7 +189,7 @@ mprotect_fixup(struct vm_area_struct *vm
 
 success:
 	/*
-	 * vm_flags and vm_page_prot are protected by the mmap_sem
+	 * vm_flags and vm_page_prot are protected by the mmap_lock
 	 * held in write mode.
 	 */
 	vma->vm_flags = newflags;
@@ -245,7 +245,7 @@ sys_mprotect(unsigned long start, size_t
 
 	vm_flags = calc_vm_prot_bits(prot);
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	vma = find_vma_prev(current->mm, start, &prev);
 	error = -ENOMEM;
@@ -309,6 +309,6 @@ sys_mprotect(unsigned long start, size_t
 		}
 	}
 out:
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return error;
 }
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/mremap.c	2007-05-11 15:06:00.000000000 +0200
@@ -91,7 +91,7 @@ static void move_ptes(struct vm_area_str
 
 	/*
 	 * We don't have to worry about the ordering of src and dst
-	 * pte locks because exclusive mmap_sem prevents deadlock.
+	 * pte locks because exclusive mmap_lock prevents deadlock.
 	 */
 	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
  	new_pte = pte_offset_map_nested(new_pmd, new_addr);
@@ -409,8 +409,8 @@ asmlinkage unsigned long sys_mremap(unsi
 {
 	unsigned long ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
Index: linux-2.6/mm/msync.c
===================================================================
--- linux-2.6.orig/mm/msync.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/msync.c	2007-05-11 15:06:00.000000000 +0200
@@ -53,7 +53,7 @@ asmlinkage long sys_msync(unsigned long 
 	 * If the interval [start,end) covers some unmapped address ranges,
 	 * just ignore them, but return -ENOMEM at the end.
 	 */
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, start);
 	for (;;) {
 		struct file *file;
@@ -80,12 +80,12 @@ asmlinkage long sys_msync(unsigned long 
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
-			up_read(&mm->mmap_sem);
+			rw_mutex_read_unlock(&mm->mmap_lock);
 			error = do_fsync(file, 0);
 			fput(file);
 			if (error || start >= end)
 				goto out;
-			down_read(&mm->mmap_sem);
+			rw_mutex_read_lock(&mm->mmap_lock);
 			vma = find_vma(mm, start);
 		} else {
 			if (start >= end) {
@@ -96,7 +96,7 @@ asmlinkage long sys_msync(unsigned long 
 		}
 	}
 out_unlock:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 out:
 	return error ? : unmapped_error;
 }
Index: linux-2.6/mm/prio_tree.c
===================================================================
--- linux-2.6.orig/mm/prio_tree.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/prio_tree.c	2007-05-11 15:06:00.000000000 +0200
@@ -50,9 +50,9 @@
  * We need some way to identify whether a vma is a tree node, head of a vm_set
  * list, or just a member of a vm_set list. We cannot use vm_flags to store
  * such information. The reason is, in the above figure, it is possible that
- * vm_flags' of R and H are covered by the different mmap_sems. When R is
- * removed under R->mmap_sem, H replaces R as a tree node. Since we do not hold
- * H->mmap_sem, we cannot use H->vm_flags for marking that H is a tree node now.
+ * vm_flags' of R and H are covered by the different mmap_locks. When R is
+ * removed under R->mmap_lock, H replaces R as a tree node. Since we do not hold
+ * H->mmap_lock, we cannot use H->vm_flags for marking that H is a tree node now.
  * That's why some trick involving shared.vm_set.parent is used for identifying
  * tree nodes and list head nodes.
  *
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/rmap.c	2007-05-11 15:06:00.000000000 +0200
@@ -22,7 +22,7 @@
  *
  * inode->i_mutex	(while writing or truncating, not reading or faulting)
  *   inode->i_alloc_sem (vmtruncate_range)
- *   mm->mmap_sem
+ *   mm->mmap_lock
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_lock
  *         anon_vma->lock
@@ -71,7 +71,7 @@ static inline void validate_anon_vma(str
 #endif
 }
 
-/* This must be called under the mmap_sem. */
+/* This must be called under the mmap_lock. */
 int anon_vma_prepare(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
@@ -313,7 +313,7 @@ static int page_referenced_one(struct pa
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
 	if (mm != current->mm && has_swap_token(mm) &&
-			rwsem_is_locked(&mm->mmap_sem))
+			rw_mutex_is_locked(&mm->mmap_lock))
 		referenced++;
 
 	(*mapcount)--;
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/swapfile.c	2007-05-11 15:06:00.000000000 +0200
@@ -616,21 +616,21 @@ static int unuse_mm(struct mm_struct *mm
 {
 	struct vm_area_struct *vma;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!rw_mutex_read_trylock(&mm->mmap_lock)) {
 		/*
 		 * Activate page so shrink_cache is unlikely to unmap its
 		 * ptes while lock is dropped, so swapoff can make progress.
 		 */
 		activate_page(page);
 		unlock_page(page);
-		down_read(&mm->mmap_sem);
+		rw_mutex_read_lock(&mm->mmap_lock);
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma && unuse_vma(vma, entry, page))
 			break;
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	/*
 	 * Currently unuse_mm cannot fail, but leave error handling
 	 * at call sites for now, since we change it from time to time.
Index: linux-2.6/include/linux/futex.h
===================================================================
--- linux-2.6.orig/include/linux/futex.h	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/include/linux/futex.h	2007-05-11 15:06:00.000000000 +0200
@@ -156,7 +156,7 @@ union futex_key {
 		int offset;
 	} both;
 };
-int get_futex_key(u32 __user *uaddr, struct rw_semaphore *shared,
+int get_futex_key(u32 __user *uaddr, struct rw_mutex *shared,
 		  union futex_key *key);
 void get_futex_key_refs(union futex_key *key);
 void drop_futex_key_refs(union futex_key *key);
Index: linux-2.6/arch/blackfin/kernel/sys_bfin.c
===================================================================
--- linux-2.6.orig/arch/blackfin/kernel/sys_bfin.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/blackfin/kernel/sys_bfin.c	2007-05-11 15:06:15.000000000 +0200
@@ -77,9 +77,9 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/powerpc/platforms/cell/spufs/fault.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/fault.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/fault.c	2007-05-11 15:06:14.000000000 +0200
@@ -51,7 +51,7 @@ static int spu_handle_mm_fault(struct mm
 		return -EFAULT;
 	}
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 	vma = find_vma(mm, ea);
 	if (!vma)
 		goto bad_area;
@@ -89,11 +89,11 @@ good_area:
 	default:
 		BUG();
 	}
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return ret;
 
 bad_area:
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	return -EFAULT;
 }
 
Index: linux-2.6/drivers/infiniband/core/umem.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/core/umem.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/infiniband/core/umem.c	2007-05-11 15:06:15.000000000 +0200
@@ -108,7 +108,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 
 	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 
 	locked     = npages + current->mm->locked_vm;
 	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >> PAGE_SHIFT;
@@ -178,7 +178,7 @@ out:
 	} else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	free_page((unsigned long) page_list);
 
 	return ret < 0 ? ERR_PTR(ret) : umem;
@@ -189,9 +189,9 @@ static void ib_umem_account(struct work_
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
-	down_write(&umem->mm->mmap_sem);
+	rw_mutex_write_lock(&umem->mm->mmap_lock);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	rw_mutex_write_unlock(&umem->mm->mmap_lock);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -215,14 +215,14 @@ void ib_umem_release(struct ib_umem *ume
 	diff = PAGE_ALIGN(umem->length + umem->offset) >> PAGE_SHIFT;
 
 	/*
-	 * We may be called with the mm's mmap_sem already held.  This
+	 * We may be called with the mm's mmap_lock already held.  This
 	 * can happen when a userspace munmap() is the call that drops
 	 * the last reference to our file and calls our release
 	 * method.  If there are memory regions to destroy, we'll end
-	 * up here and not be able to take the mmap_sem.  In that case
+	 * up here and not be able to take the mmap_lock.  In that case
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
-	if (context->closing && !down_write_trylock(&mm->mmap_sem)) {
+	if (context->closing && !down_write_trylock(&mm->mmap_lock)) {
 		INIT_WORK(&umem->work, ib_umem_account);
 		umem->mm   = mm;
 		umem->diff = diff;
@@ -230,10 +230,10 @@ void ib_umem_release(struct ib_umem *ume
 		schedule_work(&umem->work);
 		return;
 	} else
-		down_write(&mm->mmap_sem);
+		rw_mutex_write_lock(&mm->mmap_lock);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	mmput(mm);
 	kfree(umem);
 }
Index: linux-2.6/drivers/media/video/ivtv/ivtv-udma.c
===================================================================
--- linux-2.6.orig/drivers/media/video/ivtv/ivtv-udma.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/media/video/ivtv/ivtv-udma.c	2007-05-11 15:06:15.000000000 +0200
@@ -109,10 +109,10 @@ int ivtv_udma_setup(struct ivtv *itv, un
 	}
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	err = get_user_pages(current, current->mm,
 			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map, NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
Index: linux-2.6/drivers/media/video/ivtv/ivtv-yuv.c
===================================================================
--- linux-2.6.orig/drivers/media/video/ivtv/ivtv-yuv.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/drivers/media/video/ivtv/ivtv-yuv.c	2007-05-11 15:06:15.000000000 +0200
@@ -64,10 +64,10 @@ static int ivtv_yuv_prep_user_dma(struct
 	ivtv_udma_get_page_info (&uv_dma, (unsigned long)args->uv_source, 360 * uv_decode_height);
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	rw_mutex_read_lock(&current->mm->mmap_lock);
 	y_pages = get_user_pages(current, current->mm, y_dma.uaddr, y_dma.page_count, 0, 1, &dma->map[0], NULL);
 	uv_pages = get_user_pages(current, current->mm, uv_dma.uaddr, uv_dma.page_count, 0, 1, &dma->map[y_pages], NULL);
-	up_read(&current->mm->mmap_sem);
+	rw_mutex_read_unlock(&current->mm->mmap_lock);
 
 	dma->page_count = y_dma.page_count + uv_dma.page_count;
 
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c	2007-05-11 15:05:58.000000000 +0200
+++ linux-2.6/mm/nommu.c	2007-05-11 15:06:15.000000000 +0200
@@ -321,7 +321,7 @@ static void show_process_blocks(void)
 
 /*
  * add a VMA into a process's mm_struct in the appropriate place in the list
- * - should be called with mm->mmap_sem held writelocked
+ * - should be called with mm->mmap_lock held writelocked
  */
 static void add_vma_to_mm(struct mm_struct *mm, struct vm_list_struct *vml)
 {
@@ -337,7 +337,7 @@ static void add_vma_to_mm(struct mm_stru
 
 /*
  * look up the first VMA in which addr resides, NULL if none
- * - should be called with mm->mmap_sem at least held readlocked
+ * - should be called with mm->mmap_lock at least held readlocked
  */
 struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
@@ -369,7 +369,7 @@ struct vm_area_struct *find_extend_vma(s
 
 /*
  * look up the first VMA exactly that exactly matches addr
- * - should be called with mm->mmap_sem at least held readlocked
+ * - should be called with mm->mmap_lock at least held readlocked
  */
 static inline struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 						    unsigned long addr)
@@ -1075,9 +1075,9 @@ asmlinkage long sys_munmap(unsigned long
 	int ret;
 	struct mm_struct *mm = current->mm;
 
-	down_write(&mm->mmap_sem);
+	rw_mutex_write_lock(&mm->mmap_lock);
 	ret = do_munmap(mm, addr, len);
-	up_write(&mm->mmap_sem);
+	rw_mutex_write_unlock(&mm->mmap_lock);
 	return ret;
 }
 
@@ -1166,9 +1166,9 @@ asmlinkage unsigned long sys_mremap(unsi
 {
 	unsigned long ret;
 
-	down_write(&current->mm->mmap_sem);
+	rw_mutex_write_lock(&current->mm->mmap_lock);
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
-	up_write(&current->mm->mmap_sem);
+	rw_mutex_write_unlock(&current->mm->mmap_lock);
 	return ret;
 }
 
@@ -1359,7 +1359,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	rw_mutex_read_lock(&mm->mmap_lock);
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
@@ -1379,7 +1379,7 @@ int access_process_vm(struct task_struct
 		len = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	rw_mutex_read_unlock(&mm->mmap_lock);
 	mmput(mm);
 	return len;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
