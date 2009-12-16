Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D1B386B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:14:13 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG3EA56001322
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:14:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DFEF45DE50
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:14:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ECB045DE4F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:14:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 183321DB8042
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:14:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B25BA1DB803F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:14:09 +0900 (JST)
Date: Wed, 16 Dec 2009 12:11:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 11/11] mm accessor for x86
Message-Id: <20091216121104.886df5bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Replacing mmap_sem with mm_accessor...for x86

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/ia32/ia32_aout.c     |   32 ++++++++++++++++----------------
 arch/x86/ia32/sys_ia32.c      |    8 ++++----
 arch/x86/kernel/sys_i386_32.c |    4 ++--
 arch/x86/kernel/sys_x86_64.c  |    4 ++--
 arch/x86/kvm/mmu.c            |    4 ++--
 arch/x86/kvm/x86.c            |    8 ++++----
 arch/x86/lib/usercopy_32.c    |    8 ++++----
 arch/x86/mm/fault.c           |   14 +++++++-------
 arch/x86/mm/gup.c             |    4 ++--
 arch/x86/vdso/vdso32-setup.c  |    4 ++--
 arch/x86/vdso/vma.c           |    4 ++--
 11 files changed, 47 insertions(+), 47 deletions(-)

Index: mmotm-mm-accessor/arch/x86/ia32/ia32_aout.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/ia32/ia32_aout.c
+++ mmotm-mm-accessor/arch/x86/ia32/ia32_aout.c
@@ -121,9 +121,9 @@ static void set_brk(unsigned long start,
 	end = PAGE_ALIGN(end);
 	if (end <= start)
 		return;
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	do_brk(start, end - start);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 }
 
 #ifdef CORE_DUMP
@@ -339,9 +339,9 @@ static int load_aout_binary(struct linux
 		pos = 32;
 		map_size = ex.a_text+ex.a_data;
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_brk(text_addr & PAGE_MASK, map_size);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (error != (text_addr & PAGE_MASK)) {
 			send_sig(SIGKILL, current, 0);
@@ -380,9 +380,9 @@ static int load_aout_binary(struct linux
 		if (!bprm->file->f_op->mmap || (fd_offset & ~PAGE_MASK) != 0) {
 			loff_t pos = fd_offset;
 
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			do_brk(N_TXTADDR(ex), ex.a_text+ex.a_data);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 			bprm->file->f_op->read(bprm->file,
 					(char __user *)N_TXTADDR(ex),
 					ex.a_text+ex.a_data, &pos);
@@ -392,26 +392,26 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 				PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE |
 				MAP_EXECUTABLE | MAP_32BIT,
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
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE |
 				MAP_EXECUTABLE | MAP_32BIT,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -490,9 +490,9 @@ static int load_aout_library(struct file
 			error_time = jiffies;
 		}
 #endif
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		do_brk(start_addr, ex.a_text + ex.a_data + ex.a_bss);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		file->f_op->read(file, (char __user *)start_addr,
 			ex.a_text + ex.a_data, &pos);
@@ -504,12 +504,12 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_32BIT,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	retval = error;
 	if (error != start_addr)
 		goto out;
@@ -517,9 +517,9 @@ static int load_aout_library(struct file
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
Index: mmotm-mm-accessor/arch/x86/kernel/sys_x86_64.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/kernel/sys_x86_64.c
+++ mmotm-mm-accessor/arch/x86/kernel/sys_x86_64.c
@@ -37,9 +37,9 @@ SYSCALL_DEFINE6(mmap, unsigned long, add
 		if (!file)
 			goto out;
 	}
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	if (file)
 		fput(file);
Index: mmotm-mm-accessor/arch/x86/kernel/sys_i386_32.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/kernel/sys_i386_32.c
+++ mmotm-mm-accessor/arch/x86/kernel/sys_i386_32.c
@@ -39,9 +39,9 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	if (file)
 		fput(file);
Index: mmotm-mm-accessor/arch/x86/lib/usercopy_32.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/lib/usercopy_32.c
+++ mmotm-mm-accessor/arch/x86/lib/usercopy_32.c
@@ -745,18 +745,18 @@ unsigned long __copy_to_user_ll(void __u
 				len = n;
 
 survive:
-			down_read(&current->mm->mmap_sem);
+			mm_read_lock(current->mm);
 			retval = get_user_pages(current, current->mm,
 					(unsigned long)to, 1, 1, 0, &pg, NULL);
 
 			if (retval == -ENOMEM && is_global_init(current)) {
-				up_read(&current->mm->mmap_sem);
+				mm_read_unlock(current->mm);
 				congestion_wait(BLK_RW_ASYNC, HZ/50);
 				goto survive;
 			}
 
 			if (retval != 1) {
-				up_read(&current->mm->mmap_sem);
+				mm_read_unlock(current->mm);
 				break;
 			}
 
@@ -765,7 +765,7 @@ survive:
 			kunmap_atomic(maddr, KM_USER0);
 			set_page_dirty_lock(pg);
 			put_page(pg);
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm);
 
 			from += len;
 			to += len;
Index: mmotm-mm-accessor/arch/x86/vdso/vdso32-setup.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/vdso/vdso32-setup.c
+++ mmotm-mm-accessor/arch/x86/vdso/vdso32-setup.c
@@ -320,7 +320,7 @@ int arch_setup_additional_pages(struct l
 	if (vdso_enabled == VDSO_DISABLED)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 	/* Test compat mode once here, in case someone
 	   changes it via sysctl */
@@ -367,7 +367,7 @@ int arch_setup_additional_pages(struct l
 	if (ret)
 		current->mm->context.vdso = NULL;
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/arch/x86/vdso/vma.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/vdso/vma.c
+++ mmotm-mm-accessor/arch/x86/vdso/vma.c
@@ -108,7 +108,7 @@ int arch_setup_additional_pages(struct l
 	if (!vdso_enabled)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	addr = vdso_addr(mm->start_stack, vdso_size);
 	addr = get_unmapped_area(NULL, addr, vdso_size, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
@@ -129,7 +129,7 @@ int arch_setup_additional_pages(struct l
 	}
 
 up_fail:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return ret;
 }
 
Index: mmotm-mm-accessor/arch/x86/mm/fault.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/mm/fault.c
+++ mmotm-mm-accessor/arch/x86/mm/fault.c
@@ -759,7 +759,7 @@ __bad_area(struct pt_regs *regs, unsigne
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	__bad_area_nosemaphore(regs, error_code, address, si_code);
 }
@@ -786,7 +786,7 @@ out_of_memory(struct pt_regs *regs, unsi
 	 * We ran out of memory, call the OOM killer, and return the userspace
 	 * (which will retry the fault, or kill us if we got oom-killed):
 	 */
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	pagefault_out_of_memory();
 }
@@ -799,7 +799,7 @@ do_sigbus(struct pt_regs *regs, unsigned
 	struct mm_struct *mm = tsk->mm;
 	int code = BUS_ADRERR;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	/* Kernel mode? Handle exceptions or die: */
 	if (!(error_code & PF_USER))
@@ -965,7 +965,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	 */
 	if (kmemcheck_active(regs))
 		kmemcheck_hide(regs);
-	prefetchw(&mm->mmap_sem);
+	mm_lock_prefetch(mm);
 
 	if (unlikely(kmmio_fault(regs, address)))
 		return;
@@ -1056,13 +1056,13 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+	if (unlikely(!mm_read_trylock(mm))) {
 		if ((error_code & PF_USER) == 0 &&
 		    !search_exception_tables(regs->ip)) {
 			bad_area_nosemaphore(regs, error_code, address);
 			return;
 		}
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 	} else {
 		/*
 		 * The above down_read_trylock() might have succeeded in
@@ -1136,5 +1136,5 @@ good_area:
 
 	check_v8086_mode(regs, address, tsk);
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 }
Index: mmotm-mm-accessor/arch/x86/ia32/sys_ia32.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/ia32/sys_ia32.c
+++ mmotm-mm-accessor/arch/x86/ia32/sys_ia32.c
@@ -172,13 +172,13 @@ asmlinkage long sys32_mmap(struct mmap_a
 	}
 
 	mm = current->mm;
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags,
 			       a.offset>>PAGE_SHIFT);
 	if (file)
 		fput(file);
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	return retval;
 }
@@ -498,9 +498,9 @@ asmlinkage long sys32_mmap2(unsigned lon
 			return -EBADF;
 	}
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	if (file)
 		fput(file);
Index: mmotm-mm-accessor/arch/x86/mm/gup.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/mm/gup.c
+++ mmotm-mm-accessor/arch/x86/mm/gup.c
@@ -357,10 +357,10 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 		ret = get_user_pages(current, mm, start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
Index: mmotm-mm-accessor/arch/x86/kvm/mmu.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/kvm/mmu.c
+++ mmotm-mm-accessor/arch/x86/kvm/mmu.c
@@ -479,7 +479,7 @@ static int host_mapping_level(struct kvm
 	if (kvm_is_error_hva(addr))
 		return page_size;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	vma = find_vma(current->mm, addr);
 	if (!vma)
 		goto out;
@@ -487,7 +487,7 @@ static int host_mapping_level(struct kvm
 	page_size = vma_kernel_pagesize(vma);
 
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	for (i = PT_PAGE_TABLE_LEVEL;
 	     i < (PT_PAGE_TABLE_LEVEL + KVM_NR_PAGE_SIZES); ++i) {
Index: mmotm-mm-accessor/arch/x86/kvm/x86.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/kvm/x86.c
+++ mmotm-mm-accessor/arch/x86/kvm/x86.c
@@ -5172,13 +5172,13 @@ int kvm_arch_set_memory_region(struct kv
 		if (npages && !old.rmap) {
 			unsigned long userspace_addr;
 
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			userspace_addr = do_mmap(NULL, 0,
 						 npages * PAGE_SIZE,
 						 PROT_READ | PROT_WRITE,
 						 MAP_PRIVATE | MAP_ANONYMOUS,
 						 0);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 
 			if (IS_ERR((void *)userspace_addr))
 				return PTR_ERR((void *)userspace_addr);
@@ -5191,10 +5191,10 @@ int kvm_arch_set_memory_region(struct kv
 			if (!old.user_alloc && old.rmap) {
 				int ret;
 
-				down_write(&current->mm->mmap_sem);
+				mm_write_lock(current->mm);
 				ret = do_munmap(current->mm, old.userspace_addr,
 						old.npages * PAGE_SIZE);
-				up_write(&current->mm->mmap_sem);
+				mm_write_unlock(current->mm);
 				if (ret < 0)
 					printk(KERN_WARNING
 				       "kvm_vm_ioctl_set_memory_region: "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
