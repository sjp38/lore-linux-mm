Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ACA906B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:42:05 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI0fxje017024
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Dec 2009 09:41:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17CCC2AEAA1
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:41:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E79CA45DE4D
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:41:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B05E41DB803F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:41:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A2871DB803B
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:41:58 +0900 (JST)
Date: Fri, 18 Dec 2009 09:38:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC 0/4] speculative page fault (Was Re: [mm][RFC][PATCH 0/11] mm
 accessor updates.
Message-Id: <20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216101107.GA15031@basil.fritz.box>
	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216102806.GC15031@basil.fritz.box>
	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__18_Dec_2009_09_38_49_+0900_blCCLMOtWox4vccc"
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Fri__18_Dec_2009_09_38_49_+0900_blCCLMOtWox4vccc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 16 Dec 2009 19:33:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > After we see the further works, let us discuss this patch's value.
> > 
> Ok, I'll show new version of speculative page fault.
> 

Here is a one-day patch for speculative page fault. Maybe someone can do
better than me.
  - For what direction someone fixes mmap_sem, this result seems to be a good
    for motivation.
  - Because lockless vma lookup can be a big patch, I avoid that and just uses
    caching. Then, this just helps page fault.
    In that sense, this patch is imcomplete and not very good.

Test program and unified diff is attached. After reading all e-mails,
I'd like to wait for another idea pops up. 

This test program is the best case for this patch and doesn't reflects any
real-world application behavior.

tested on x86-64, 8core, 2socket machine.

cache-miss/page fault are 32.67, 11.4, 10.6

[Before patch (2.5.32-mmotm-Dec8)
[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8':

       15774882  page-faults
      515407936  cache-misses

   60.011299493  seconds time elapsed

[After speculative page fault]
[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8':

       39800221  page-faults
      454331251  cache-misses

   60.002859027  seconds time elapsed

[After speculative page fault + per-thread mm_counter (already posted)]
[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8':

       41025269  page-faults
      436365676  cache-misses

   60.007787788  seconds time elapsed


Bye.
-Kame

--Multipart=_Fri__18_Dec_2009_09_38_49_+0900_blCCLMOtWox4vccc
Content-Type: text/plain;
 name="snap.diff"
Content-Disposition: attachment;
 filename="snap.diff"
Content-Transfer-Encoding: 7bit

Index: mmotm-mm-accessor/Documentation/filesystems/proc.txt
===================================================================
--- mmotm-mm-accessor.orig/Documentation/filesystems/proc.txt
+++ mmotm-mm-accessor/Documentation/filesystems/proc.txt
@@ -189,6 +189,12 @@ memory usage. Its seven fields are expla
 contains details information about the process itself.  Its fields are
 explained in Table 1-4.
 
+(for SMP CONFIG users)
+For making accounting scalable, RSS related information are handled in
+asynchronous manner and the vaule may not be very precise. To see a precise
+snapshot of a moment, you can see /proc/<pid>/smaps file and scan page table.
+It's slow but very precise.
+
 Table 1-2: Contents of the statm files (as of 2.6.30-rc7)
 ..............................................................................
  Field                       Content
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
Index: mmotm-mm-accessor/arch/x86/mm/fault.c
===================================================================
--- mmotm-mm-accessor.orig/arch/x86/mm/fault.c
+++ mmotm-mm-accessor/arch/x86/mm/fault.c
@@ -11,6 +11,7 @@
 #include <linux/kprobes.h>		/* __kprobes, ...		*/
 #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
 #include <linux/perf_event.h>		/* perf_sw_event		*/
+#include <linux/hugetlb.h>		/* is_vm_hugetlb...*/
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -759,7 +760,7 @@ __bad_area(struct pt_regs *regs, unsigne
 	 * Something tried to access memory that isn't in our memory map..
 	 * Fix it, but check if it's kernel or user first..
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	__bad_area_nosemaphore(regs, error_code, address, si_code);
 }
@@ -786,7 +787,7 @@ out_of_memory(struct pt_regs *regs, unsi
 	 * We ran out of memory, call the OOM killer, and return the userspace
 	 * (which will retry the fault, or kill us if we got oom-killed):
 	 */
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	pagefault_out_of_memory();
 }
@@ -799,7 +800,7 @@ do_sigbus(struct pt_regs *regs, unsigned
 	struct mm_struct *mm = tsk->mm;
 	int code = BUS_ADRERR;
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	/* Kernel mode? Handle exceptions or die: */
 	if (!(error_code & PF_USER))
@@ -952,6 +953,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	struct mm_struct *mm;
 	int write;
 	int fault;
+	int speculative;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -965,7 +967,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	 */
 	if (kmemcheck_active(regs))
 		kmemcheck_hide(regs);
-	prefetchw(&mm->mmap_sem);
+	mm_lock_prefetch(mm);
 
 	if (unlikely(kmmio_fault(regs, address)))
 		return;
@@ -1040,6 +1042,17 @@ do_page_fault(struct pt_regs *regs, unsi
 		return;
 	}
 
+	if ((error_code & PF_USER) && mm_version_check(mm)) {
+		vma = lookup_vma_cache(mm, address);
+		if (vma && mm_version_check(mm) &&
+		   (vma->vm_start <= address) && (address < vma->vm_end)) {
+			speculative = 1;
+			goto found_vma;
+		}
+		if (vma)
+			vma_release(vma);
+	}
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1056,13 +1069,15 @@ do_page_fault(struct pt_regs *regs, unsi
 	 * validate the source. If this is invalid we can skip the address
 	 * space check, thus avoiding the deadlock:
 	 */
-	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+retry_with_lock:
+	speculative = 0;
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
@@ -1073,6 +1088,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	}
 
 	vma = find_vma(mm, address);
+found_vma:
 	if (unlikely(!vma)) {
 		bad_area(regs, error_code, address);
 		return;
@@ -1119,6 +1135,7 @@ good_area:
 	 */
 	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 
+
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, fault);
 		return;
@@ -1128,13 +1145,18 @@ good_area:
 		tsk->maj_flt++;
 		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
 				     regs, address);
-	} else {
+	} else if (!speculative || mm_version_check(mm)) {
 		tsk->min_flt++;
 		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
 				     regs, address);
+	} else {
+		vma_release(vma);
+		goto retry_with_lock;
 	}
 
 	check_v8086_mode(regs, address, tsk);
-
-	up_read(&mm->mmap_sem);
+	if (!speculative)
+		mm_read_unlock(mm);
+	else
+		vma_release(vma);
 }
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
Index: mmotm-mm-accessor/drivers/gpu/drm/i915/i915_gem.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i915/i915_gem.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i915/i915_gem.c
@@ -398,10 +398,10 @@ i915_gem_shmem_pread_slow(struct drm_dev
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 1, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -698,10 +698,10 @@ i915_gem_gtt_pwrite_slow(struct drm_devi
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto out_unpin_pages;
@@ -873,10 +873,10 @@ i915_gem_shmem_pwrite_slow(struct drm_de
 	if (user_pages == NULL)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	pinned_pages = get_user_pages(current, mm, (uintptr_t)args->data_ptr,
 				      num_pages, 0, 0, user_pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	if (pinned_pages < num_pages) {
 		ret = -EFAULT;
 		goto fail_put_user_pages;
@@ -1149,11 +1149,11 @@ i915_gem_mmap_ioctl(struct drm_device *d
 
 	offset = args->offset;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	addr = do_mmap(obj->filp, 0, args->size,
 		       PROT_READ | PROT_WRITE, MAP_SHARED,
 		       args->offset);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	mutex_lock(&dev->struct_mutex);
 	drm_gem_object_unreference(obj);
 	mutex_unlock(&dev->struct_mutex);
Index: mmotm-mm-accessor/drivers/gpu/drm/ttm/ttm_tt.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/ttm/ttm_tt.c
+++ mmotm-mm-accessor/drivers/gpu/drm/ttm/ttm_tt.c
@@ -359,10 +359,10 @@ int ttm_tt_set_user(struct ttm_tt *ttm,
 	if (unlikely(ret != 0))
 		return ret;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	ret = get_user_pages(tsk, mm, start, num_pages,
 			     write, 0, ttm->pages, NULL);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 
 	if (ret != num_pages && write) {
 		ttm_tt_free_user_pages(ttm);
Index: mmotm-mm-accessor/drivers/infiniband/core/umem.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/core/umem.c
+++ mmotm-mm-accessor/drivers/infiniband/core/umem.c
@@ -133,7 +133,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 
 	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	locked     = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -207,7 +207,7 @@ out:
 	} else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -220,9 +220,9 @@ static void ib_umem_account(struct work_
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -256,7 +256,7 @@ void ib_umem_release(struct ib_umem *ume
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -265,10 +265,10 @@ void ib_umem_release(struct ib_umem *ume
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	mmput(mm);
 	kfree(umem);
 }
Index: mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_pages.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -162,24 +162,24 @@ int ipath_get_user_pages(unsigned long s
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	ret = __get_user_pages(start_page, num_pages, p, NULL);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return ret;
 }
 
 void ipath_release_user_pages(struct page **p, size_t num_pages)
 {
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	__ipath_release_user_pages(p, num_pages, 1);
 
 	current->mm->locked_vm -= num_pages;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 }
 
 struct ipath_user_pages_work {
@@ -193,9 +193,9 @@ static void user_pages_account(struct wo
 	struct ipath_user_pages_work *work =
 		container_of(_work, struct ipath_user_pages_work, work);
 
-	down_write(&work->mm->mmap_sem);
+	mm_write_lock(work->mm);
 	work->mm->locked_vm -= work->num_pages;
-	up_write(&work->mm->mmap_sem);
+	mm_write_unlock(work->mm);
 	mmput(work->mm);
 	kfree(work);
 }
Index: mmotm-mm-accessor/drivers/media/video/davinci/vpif_capture.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/davinci/vpif_capture.c
+++ mmotm-mm-accessor/drivers/media/video/davinci/vpif_capture.c
@@ -122,11 +122,11 @@ static inline u32 vpif_uservirt_to_phys(
 		int res, nr_pages = 1;
 			struct page *pages;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 
 		res = get_user_pages(current, current->mm,
 				     virtp, nr_pages, 1, 0, &pages, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (res == nr_pages)
 			physp = __pa(page_address(&pages[0]) +
Index: mmotm-mm-accessor/drivers/media/video/davinci/vpif_display.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/davinci/vpif_display.c
+++ mmotm-mm-accessor/drivers/media/video/davinci/vpif_display.c
@@ -116,11 +116,12 @@ static u32 vpif_uservirt_to_phys(u32 vir
 		/* otherwise, use get_user_pages() for general userland pages */
 		int res, nr_pages = 1;
 		struct page *pages;
-		down_read(&current->mm->mmap_sem);
+
+		mm_read_lock(current->mm);
 
 		res = get_user_pages(current, current->mm,
 				     virtp, nr_pages, 1, 0, &pages, NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (res == nr_pages) {
 			physp = __pa(page_address(&pages[0]) +
Index: mmotm-mm-accessor/drivers/media/video/videobuf-core.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-core.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-core.c
@@ -485,7 +485,7 @@ int videobuf_qbuf(struct videobuf_queue 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 
 	mutex_lock(&q->vb_lock);
 	retval = -EBUSY;
@@ -575,7 +575,7 @@ int videobuf_qbuf(struct videobuf_queue 
 	mutex_unlock(&q->vb_lock);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 	return retval;
 }
Index: mmotm-mm-accessor/drivers/media/video/videobuf-dma-contig.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-dma-contig.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-dma-contig.c
@@ -147,7 +147,7 @@ static int videobuf_dma_contig_user_get(
 	mem->is_userptr = 0;
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -182,7 +182,7 @@ static int videobuf_dma_contig_user_get(
 		mem->is_userptr = 1;
 
  out_up:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/drivers/media/video/videobuf-dma-sg.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/videobuf-dma-sg.c
+++ mmotm-mm-accessor/drivers/media/video/videobuf-dma-sg.c
@@ -179,9 +179,9 @@ int videobuf_dma_init_user(struct videob
 			   unsigned long data, unsigned long size)
 {
 	int ret;
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/drivers/misc/sgi-gru/grufault.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/misc/sgi-gru/grufault.c
+++ mmotm-mm-accessor/drivers/misc/sgi-gru/grufault.c
@@ -81,14 +81,14 @@ static struct gru_thread_state *gru_find
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = NULL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	vma = gru_find_vma(vaddr);
 	if (vma)
 		gts = gru_find_thread_state(vma, TSID(vaddr, vma));
 	if (gts)
 		mutex_lock(&gts->ts_ctxlock);
 	else
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	return gts;
 }
 
@@ -98,7 +98,7 @@ static struct gru_thread_state *gru_allo
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = ERR_PTR(-EINVAL);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	vma = gru_find_vma(vaddr);
 	if (!vma)
 		goto err;
@@ -107,11 +107,11 @@ static struct gru_thread_state *gru_allo
 	if (IS_ERR(gts))
 		goto err;
 	mutex_lock(&gts->ts_ctxlock);
-	downgrade_write(&mm->mmap_sem);
+	mm_write_to_read_lock(mm);
 	return gts;
 
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return gts;
 }
 
@@ -121,7 +121,7 @@ err:
 static void gru_unlock_gts(struct gru_thread_state *gts)
 {
 	mutex_unlock(&gts->ts_ctxlock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 }
 
 /*
@@ -583,9 +583,9 @@ static irqreturn_t gru_intr(int chiplet,
 		 */
 		gts->ustats.fmm_tlbmiss++;
 		if (!gts->ts_force_cch_reload &&
-					down_read_trylock(&gts->ts_mm->mmap_sem)) {
+					mm_read_trylock(gts->ts_mm)) {
 			gru_try_dropin(gru, gts, tfh, NULL);
-			up_read(&gts->ts_mm->mmap_sem);
+			mm_read_unlock(gts->ts_mm);
 		} else {
 			tfh_user_polling_mode(tfh);
 			STAT(intr_mm_lock_failed);
Index: mmotm-mm-accessor/drivers/misc/sgi-gru/grufile.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/misc/sgi-gru/grufile.c
+++ mmotm-mm-accessor/drivers/misc/sgi-gru/grufile.c
@@ -144,7 +144,7 @@ static int gru_create_new_context(unsign
 	if (!(req.options & GRU_OPT_MISS_MASK))
 		req.options |= GRU_OPT_MISS_FMM_INTR;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	vma = gru_find_vma(req.gseg);
 	if (vma) {
 		vdata = vma->vm_private_data;
@@ -155,7 +155,7 @@ static int gru_create_new_context(unsign
 		vdata->vd_tlb_preload_count = req.tlb_preload_count;
 		ret = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return ret;
 }
Index: mmotm-mm-accessor/drivers/scsi/st.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/scsi/st.c
+++ mmotm-mm-accessor/drivers/scsi/st.c
@@ -4553,7 +4553,7 @@ static int sgl_map_user_pages(struct st_
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages(
 		current,
@@ -4564,7 +4564,7 @@ static int sgl_map_user_pages(struct st_
 		0, /* don't force */
 		pages,
 		NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
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
@@ -702,6 +702,7 @@ static int exec_mmap(struct mm_struct *m
 	/* Notify parent that we're no longer interested in the old VM */
 	tsk = current;
 	old_mm = current->mm;
+	sync_mm_rss(tsk, old_mm);
 	mm_release(tsk, old_mm);
 
 	if (old_mm) {
@@ -711,9 +712,9 @@ static int exec_mmap(struct mm_struct *m
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
@@ -725,7 +726,7 @@ static int exec_mmap(struct mm_struct *m
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
-		up_read(&old_mm->mmap_sem);
+		mm_read_unlock(old_mm);
 		BUG_ON(active_mm != old_mm);
 		mm_update_next_owner(old_mm);
 		mmput(old_mm);
@@ -1642,7 +1643,7 @@ static int coredump_wait(int exit_code, 
 	core_state->dumper.task = tsk;
 	core_state->dumper.next = NULL;
 	core_waiters = zap_threads(tsk, mm, core_state, exit_code);
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 
 	if (unlikely(core_waiters < 0))
 		goto fail;
@@ -1790,12 +1791,12 @@ void do_coredump(long signr, int exit_co
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
 
Index: mmotm-mm-accessor/fs/proc/task_mmu.c
===================================================================
--- mmotm-mm-accessor.orig/fs/proc/task_mmu.c
+++ mmotm-mm-accessor/fs/proc/task_mmu.c
@@ -65,11 +65,11 @@ unsigned long task_vsize(struct mm_struc
 int task_statm(struct mm_struct *mm, int *shared, int *text,
 	       int *data, int *resident)
 {
-	*shared = get_mm_counter(mm, file_rss);
+	*shared = get_mm_counter(mm, MM_FILEPAGES);
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, anon_rss);
+	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
 	return mm->total_vm;
 }
 
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
Index: mmotm-mm-accessor/include/linux/mm.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm.h
+++ mmotm-mm-accessor/include/linux/mm.h
@@ -763,6 +763,26 @@ unsigned long unmap_vmas(struct mmu_gath
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
+struct vm_area_struct *lookup_vma_cache(struct mm_struct *mm,
+		unsigned long address);
+void invalidate_vma_cache(struct mm_struct *mm,
+		struct vm_area_struct *vma);
+void wait_vmas_cache_range(struct vm_area_struct *vma, unsigned long end);
+
+static inline void vma_hold(struct vm_area_struct *vma)
+{
+	atomic_inc(&vma->cache_access);
+}
+
+void __vma_release(struct vm_area_struct *vma);
+static inline void vma_release(struct vm_area_struct *vma)
+{
+	if (atomic_dec_and_test(&vma->cache_access)) {
+		if (waitqueue_active(&vma->cache_wait))
+			__vma_release(vma);
+	}
+}
+
 /**
  * mm_walk - callbacks for walk_page_range
  * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
@@ -868,6 +888,108 @@ extern int mprotect_fixup(struct vm_area
  */
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages);
+/*
+ * per-process(per-mm_struct) statistics.
+ */
+#if defined(SPLIT_RSS_COUNTING)
+/*
+ * The mm counters are not protected by its page_table_lock,
+ * so must be incremented atomically.
+ */
+static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_set(&mm->rss_stat.count[member], value);
+}
+
+unsigned long get_mm_counter(struct mm_struct *mm, int member);
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	atomic_long_add(value, &mm->rss_stat.count[member]);
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_inc(&mm->rss_stat.count[member]);
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	atomic_long_dec(&mm->rss_stat.count[member]);
+}
+
+#else  /* !USE_SPLIT_PTLOCKS */
+/*
+ * The mm counters are protected by its page_table_lock,
+ * so can be incremented directly.
+ */
+static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->rss_stat.count[member] = value;
+}
+
+static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	return mm->rss_stat.count[member];
+}
+
+static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
+{
+	mm->rss_stat.count[member] += value;
+}
+
+static inline void inc_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->rss_stat.count[member]++;
+}
+
+static inline void dec_mm_counter(struct mm_struct *mm, int member)
+{
+	mm->rss_stat.count[member]--;
+}
+
+#endif /* !USE_SPLIT_PTLOCKS */
+
+static inline unsigned long get_mm_rss(struct mm_struct *mm)
+{
+	return get_mm_counter(mm, MM_FILEPAGES) +
+		get_mm_counter(mm, MM_ANONPAGES);
+}
+
+static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
+{
+	return max(mm->hiwater_rss, get_mm_rss(mm));
+}
+
+static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
+{
+	return max(mm->hiwater_vm, mm->total_vm);
+}
+
+static inline void update_hiwater_rss(struct mm_struct *mm)
+{
+	unsigned long _rss = get_mm_rss(mm);
+
+	if ((mm)->hiwater_rss < _rss)
+		(mm)->hiwater_rss = _rss;
+}
+
+static inline void update_hiwater_vm(struct mm_struct *mm)
+{
+	if (mm->hiwater_vm < mm->total_vm)
+		mm->hiwater_vm = mm->total_vm;
+}
+
+static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
+					 struct mm_struct *mm)
+{
+	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
+
+	if (*maxrss < hiwater_rss)
+		*maxrss = hiwater_rss;
+}
+
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm);
 
 /*
  * A callback you can register to apply pressure to ageable caches.
Index: mmotm-mm-accessor/include/linux/sched.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/sched.h
+++ mmotm-mm-accessor/include/linux/sched.h
@@ -385,60 +385,6 @@ arch_get_unmapped_area_topdown(struct fi
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
-#if USE_SPLIT_PTLOCKS
-/*
- * The mm counters are not protected by its page_table_lock,
- * so must be incremented atomically.
- */
-#define set_mm_counter(mm, member, value) atomic_long_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic_long_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic_long_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic_long_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic_long_dec(&(mm)->_##member)
-
-#else  /* !USE_SPLIT_PTLOCKS */
-/*
- * The mm counters are protected by its page_table_lock,
- * so can be incremented directly.
- */
-#define set_mm_counter(mm, member, value) (mm)->_##member = (value)
-#define get_mm_counter(mm, member) ((mm)->_##member)
-#define add_mm_counter(mm, member, value) (mm)->_##member += (value)
-#define inc_mm_counter(mm, member) (mm)->_##member++
-#define dec_mm_counter(mm, member) (mm)->_##member--
-
-#endif /* !USE_SPLIT_PTLOCKS */
-
-#define get_mm_rss(mm)					\
-	(get_mm_counter(mm, file_rss) + get_mm_counter(mm, anon_rss))
-#define update_hiwater_rss(mm)	do {			\
-	unsigned long _rss = get_mm_rss(mm);		\
-	if ((mm)->hiwater_rss < _rss)			\
-		(mm)->hiwater_rss = _rss;		\
-} while (0)
-#define update_hiwater_vm(mm)	do {			\
-	if ((mm)->hiwater_vm < (mm)->total_vm)		\
-		(mm)->hiwater_vm = (mm)->total_vm;	\
-} while (0)
-
-static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
-{
-	return max(mm->hiwater_rss, get_mm_rss(mm));
-}
-
-static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
-					 struct mm_struct *mm)
-{
-	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);
-
-	if (*maxrss < hiwater_rss)
-		*maxrss = hiwater_rss;
-}
-
-static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
-{
-	return max(mm->hiwater_vm, mm->total_vm);
-}
 
 extern void set_dumpable(struct mm_struct *mm, int value);
 extern int get_dumpable(struct mm_struct *mm);
@@ -1276,7 +1222,10 @@ struct task_struct {
 	struct plist_node pushable_tasks;
 
 	struct mm_struct *mm, *active_mm;
-
+	int mm_version;
+#if defined(SPLIT_RSS_COUNTING)
+	struct task_rss_stat rss_stat;
+#endif
 /* task state */
 	int exit_state;
 	int exit_code, exit_signal;
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
@@ -944,7 +944,8 @@ NORET_TYPE void do_exit(long code)
 				preempt_count());
 
 	acct_update_integrals(tsk);
-
+	/* sync mm's RSS info before statistics gathering */
+	sync_mm_rss(tsk, tsk->mm);
 	group_dead = atomic_dec_and_test(&tsk->signal->live);
 	if (group_dead) {
 		hrtimer_cancel(&tsk->signal->real_timer);
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
@@ -448,14 +448,13 @@ static struct mm_struct * mm_init(struct
 {
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
-	init_rwsem(&mm->mmap_sem);
+	mm_lock_init(mm);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->flags = (current->mm) ?
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
 	mm->nr_ptes = 0;
-	set_mm_counter(mm, file_rss, 0);
-	set_mm_counter(mm, anon_rss, 0);
+	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
Index: mmotm-mm-accessor/mm/Makefile
===================================================================
--- mmotm-mm-accessor.orig/mm/Makefile
+++ mmotm-mm-accessor/mm/Makefile
@@ -8,7 +8,7 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o 
 			   vmalloc.o pagewalk.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
-			   maccess.o page_alloc.o page-writeback.o \
+			   maccess.o page_alloc.o page-writeback.o mm_accessor.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
 			   page_isolation.o mm_init.o mmu_context.o \
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
 
Index: mmotm-mm-accessor/mm/memory.c
===================================================================
--- mmotm-mm-accessor.orig/mm/memory.c
+++ mmotm-mm-accessor/mm/memory.c
@@ -121,6 +121,87 @@ static int __init init_zero_pfn(void)
 }
 core_initcall(init_zero_pfn);
 
+static bool test_valid_pte(struct mm_struct *mm, pte_t pte, pte_t orig)
+{
+	if (likely(mm_version_check(mm) && pte_same(pte, orig)))
+		return true;
+	return false;
+}
+
+
+#if defined(SPLIT_RSS_COUNTING)
+
+void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < NR_MM_COUNTERS; i++) {
+		if (task->rss_stat.count[i]) {
+			add_mm_counter(mm, i, task->rss_stat.count[i]);
+			task->rss_stat.count[i] = 0;
+		}
+	}
+	task->rss_stat.events = 0;
+}
+
+static void add_mm_counter_fast(struct mm_struct *mm, int member, int val)
+{
+	struct task_struct *task = current;
+
+	if (likely(task->mm == mm))
+		task->rss_stat.count[member] += val;
+	else
+		add_mm_counter(mm, member, val);
+}
+#define inc_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,1)
+#define dec_mm_counter_fast(mm, member) add_mm_counter_fast(mm, member,-1)
+
+/* sync counter once per 64 page faults */
+#define TASK_RSS_EVENTS_THRESH	(64)
+static void check_sync_rss_stat(struct task_struct *task)
+{
+	if (unlikely(task != current))
+		return;
+	if (unlikely(task->rss_stat.events++ > TASK_RSS_EVENTS_THRESH))
+		__sync_task_rss_stat(task, task->mm);
+}
+
+unsigned long get_mm_counter(struct mm_struct *mm, int member)
+{
+	long val = 0;
+
+	/*
+	 * Don't use task->mm here...for avoiding to use task_get_mm()..
+ 	 * The caller must guarantee task->mm is not invalid.
+ 	 */
+	val = atomic_long_read(&mm->rss_stat.count[member]);
+	/*
+	 * counter is updated in asynchronous manner and may go to minus.
+	 * But it's never be expected number for users.
+	 */
+	if (val < 0)
+		return 0;
+	return (unsigned long)val;
+}
+
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+{
+	__sync_task_rss_stat(task, mm);
+}
+#else
+
+#define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
+#define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
+
+static void check_sync_rss_stat(struct task_struct *task)
+{
+}
+
+void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
+{
+}
+#endif
+
 /*
  * If a p?d_bad entry is found while walking page tables, report
  * the error, before resetting entry to p?d_none.  Usually (but
@@ -145,6 +226,14 @@ void pmd_clear_bad(pmd_t *pmd)
 	pmd_clear(pmd);
 }
 
+static void update_vma_cache(pmd_t *pmd, struct vm_area_struct *vma)
+{
+	struct page *page;
+	/* ptelock is held */
+	page = pmd_page(*pmd);
+	page->cache = vma;
+}
+
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
@@ -376,12 +465,20 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+static inline void init_rss_vec(int *rss)
 {
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
+	memset(rss, 0, sizeof(int) * NR_MM_COUNTERS);
+}
+
+static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
+{
+	int i;
+
+	if (current->mm == mm)
+		sync_mm_rss(current, mm);
+	for (i = 0; i < NR_MM_COUNTERS; i++)
+		if (rss[i])
+			add_mm_counter(mm, i, rss[i]);
 }
 
 /*
@@ -632,7 +729,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		rss[PageAnon(page)]++;
+		if (PageAnon(page))
+			rss[MM_ANONPAGES]++;
+		else
+			rss[MM_FILEPAGES]++;
 	}
 
 out_set_pte:
@@ -648,11 +748,12 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];
+	int rss[NR_MM_COUNTERS];
 	swp_entry_t entry = (swp_entry_t){0};
 
 again:
-	rss[1] = rss[0] = 0;
+	init_rss_vec(rss);
+
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -688,7 +789,7 @@ again:
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(orig_src_pte);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
+	add_mm_rss_vec(dst_mm, rss);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -816,8 +917,9 @@ static unsigned long zap_pte_range(struc
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
+	int rss[NR_MM_COUNTERS];
+
+	init_rss_vec(rss);
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -863,14 +965,14 @@ static unsigned long zap_pte_range(struc
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
 			if (PageAnon(page))
-				anon_rss--;
+				rss[MM_ANONPAGES]--;
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
-				file_rss--;
+				rss[MM_FILEPAGES]--;
 			}
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
@@ -893,7 +995,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss);
+	add_mm_rss_vec(mm, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -1527,7 +1629,7 @@ static int insert_page(struct vm_area_st
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, file_rss);
+	inc_mm_counter_fast(mm, MM_FILEPAGES);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2036,7 +2138,7 @@ static int do_wp_page(struct mm_struct *
 			lock_page(old_page);
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			if (!test_valid_pte(mm, *page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
 				goto unlock;
@@ -2097,7 +2199,7 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+			if (!test_valid_pte(mm, *page_table, orig_pte)) {
 				unlock_page(old_page);
 				page_cache_release(old_page);
 				goto unlock;
@@ -2118,6 +2220,7 @@ reuse:
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		update_vma_cache(pmd, vma);
 		goto unlock;
 	}
 
@@ -2160,14 +2263,14 @@ gotten:
 	 * Re-check the pte - we dropped the lock
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (test_valid_pte(mm, *page_table, orig_pte)) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter(mm, file_rss);
-				inc_mm_counter(mm, anon_rss);
+				dec_mm_counter_fast(mm, MM_FILEPAGES);
+				inc_mm_counter_fast(mm, MM_ANONPAGES);
 			}
 		} else
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2186,6 +2289,7 @@ gotten:
 		 */
 		set_pte_at_notify(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 		if (old_page) {
 			/*
 			 * Only after switching the pte to the new page may
@@ -2545,7 +2649,7 @@ static int do_swap_page(struct mm_struct
 			 * while we released the pte lock.
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-			if (likely(pte_same(*page_table, orig_pte)))
+			if (pte_same(*page_table, orig_pte))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto unlock;
@@ -2578,7 +2682,7 @@ static int do_swap_page(struct mm_struct
 	 * Back out if somebody else already faulted in this pte.
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (unlikely(!test_valid_pte(mm, *page_table, orig_pte)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2600,7 +2704,7 @@ static int do_swap_page(struct mm_struct
 	 * discarded at swap_free().
 	 */
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2626,6 +2730,7 @@ static int do_swap_page(struct mm_struct
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
+	update_vma_cache(pmd, vma);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -2684,13 +2789,14 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 
-	inc_mm_counter(mm, anon_rss);
+	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, entry);
+	update_vma_cache(pmd, vma);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
@@ -2832,16 +2938,16 @@ static int __do_fault(struct mm_struct *
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (likely(test_valid_pte(mm, *page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
-			inc_mm_counter(mm, anon_rss);
+			inc_mm_counter_fast(mm, MM_ANONPAGES);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
-			inc_mm_counter(mm, file_rss);
+			inc_mm_counter_fast(mm, MM_FILEPAGES);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
@@ -2852,6 +2958,7 @@ static int __do_fault(struct mm_struct *
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 	} else {
 		if (charged)
 			mem_cgroup_uncharge_page(page);
@@ -2978,7 +3085,7 @@ static inline int handle_pte_fault(struc
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
-	if (unlikely(!pte_same(*pte, entry)))
+	if (unlikely(!test_valid_pte(mm, *pte, entry)))
 		goto unlock;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
@@ -2989,6 +3096,7 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {
 		update_mmu_cache(vma, address, entry);
+		update_vma_cache(pmd, vma);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
@@ -3019,6 +3127,9 @@ int handle_mm_fault(struct mm_struct *mm
 
 	count_vm_event(PGFAULT);
 
+	/* do counter updates before entering really critical section. */
+	check_sync_rss_stat(current);
+
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
@@ -3284,7 +3395,7 @@ int access_process_vm(struct task_struct
 	if (!mm)
 		return 0;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
@@ -3331,7 +3442,7 @@ int access_process_vm(struct task_struct
 		buf += bytes;
 		addr += bytes;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 
 	return buf - old_buf;
@@ -3352,7 +3463,7 @@ void print_vma_addr(char *prefix, unsign
 	if (preempt_count())
 		return;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	vma = find_vma(mm, ip);
 	if (vma && vma->vm_file) {
 		struct file *f = vma->vm_file;
@@ -3372,7 +3483,7 @@ void print_vma_addr(char *prefix, unsign
 			free_page((unsigned long)buf);
 		}
 	}
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(mm);
 }
 
 #ifdef CONFIG_PROVE_LOCKING
@@ -3394,7 +3505,7 @@ void might_fault(void)
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
@@ -187,6 +187,94 @@ error:
 	return -ENOMEM;
 }
 
+struct vm_area_struct *
+lookup_vma_cache(struct mm_struct *mm, unsigned long address)
+{
+	struct page *page;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	struct vm_area_struct *ret = NULL;
+
+	if (!mm)
+		return NULL;
+
+	preempt_disable();
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+	pmd = pmd_offset(pud, address);
+	if (!pmd_present(*pmd))
+		goto out;
+	page = pmd_page(*pmd);
+	if (PageReserved(page))
+		goto out;
+	ret = (struct vm_area_struct *)page->cache;
+	if (ret)
+		vma_hold(ret);
+out:
+	preempt_enable();
+	return ret;
+}
+
+void invalidate_vma_cache_range(struct mm_struct *mm,
+	unsigned long start, unsigned long end)
+{
+	struct page *page;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	unsigned long address = start;
+	spinlock_t *lock;
+
+	if (!mm)
+		return;
+
+	while (address < end) {
+		pgd = pgd_offset(mm, address);
+		if (!pgd_present(*pgd)) {
+			address = pgd_addr_end(address, end);
+			continue;
+		}
+		pud = pud_offset(pgd, address);
+		if (!pud_present(*pud)) {
+			address = pud_addr_end(address, end);
+			continue;
+		}
+		pmd = pmd_offset(pud, address);
+		if (pmd_present(*pmd)) {
+			page = pmd_page(*pmd);
+			/*
+ 			 * this spinlock guarantee no race with speculative
+			 * page fault, finally.
+			 */
+			lock = pte_lockptr(mm, pmd);
+			spin_lock(lock);
+			page->cache = NULL;
+			spin_unlock(lock);
+		}
+		address = pmd_addr_end(address, end);
+	}
+}
+
+/* called under mm_write_lock() */
+void wait_vmas_cache_access(struct vm_area_struct *vma, unsigned long end)
+{
+	while (vma && (vma->vm_start < end)) {
+		wait_event_interruptible(vma->cache_wait,
+				atomic_read(&vma->cache_access) == 0);
+		vma = vma->vm_next;
+	}
+}
+
+void __vma_release(struct vm_area_struct *vma)
+{
+	wake_up(&vma->cache_wait);
+}
+
 /*
  * Requires inode->i_mapping->i_mmap_lock
  */
@@ -249,7 +337,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	struct mm_struct *mm = current->mm;
 	unsigned long min_brk;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 
 #ifdef CONFIG_COMPAT_BRK
 	min_brk = mm->end_code;
@@ -293,7 +381,7 @@ set_brk:
 	mm->brk = brk;
 out:
 	retval = mm->brk;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return retval;
 }
 
@@ -406,6 +494,8 @@ void __vma_link_rb(struct mm_struct *mm,
 {
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+	atomic_set(&vma->cache_access, 0);
+	init_waitqueue_head(&vma->cache_wait);
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -774,7 +864,8 @@ struct vm_area_struct *vma_merge(struct 
 	area = next;
 	if (next && next->vm_end == end)		/* cases 6, 7, 8 */
 		next = next->vm_next;
-
+	invalidate_vma_cache_range(mm, addr, end);
+	wait_vmas_cache_access(next, end);
 	/*
 	 * Can it merge with the predecessor?
 	 */
@@ -1162,7 +1253,6 @@ munmap_back:
 			return -ENOMEM;
 		vm_flags |= VM_ACCOUNT;
 	}
-
 	/*
 	 * Can we just expand an old mapping?
 	 */
@@ -1930,7 +2020,9 @@ int do_munmap(struct mm_struct *mm, unsi
 	end = start + len;
 	if (vma->vm_start >= end)
 		return 0;
-
+	/* Before going further, clear vma cache */
+	invalidate_vma_cache_range(mm, start, end);
+	wait_vmas_cache_access(vma, end);
 	/*
 	 * If we need to split any vma, do it now to save pain later.
 	 *
@@ -1940,7 +2032,6 @@ int do_munmap(struct mm_struct *mm, unsi
 	 */
 	if (start > vma->vm_start) {
 		int error;
-
 		/*
 		 * Make sure that map_count on return from munmap() will
 		 * not exceed its limit; but let map_count go just above
@@ -1999,18 +2090,18 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
 
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
@@ -2050,6 +2141,7 @@ unsigned long do_brk(unsigned long addr,
 	if (error)
 		return error;
 
+
 	/*
 	 * mlock MCL_FUTURE?
 	 */
@@ -2069,6 +2161,7 @@ unsigned long do_brk(unsigned long addr,
 	 */
 	verify_mm_writelocked(mm);
 
+	invalidate_vma_cache_range(mm, addr,addr+len);
 	/*
 	 * Clear old maps.  this also does some error checking for us
 	 */
@@ -2245,6 +2338,7 @@ struct vm_area_struct *copy_vma(struct v
 				kmem_cache_free(vm_area_cachep, new_vma);
 				return NULL;
 			}
+			atomic_set(&new_vma->cache_access, 0);
 			vma_set_policy(new_vma, pol);
 			new_vma->vm_start = addr;
 			new_vma->vm_end = addr + len;
@@ -2368,7 +2462,7 @@ static void vm_lock_anon_vma(struct mm_s
 		 * The LSB of head.next can't change from under us
 		 * because we hold the mm_all_locks_mutex.
 		 */
-		spin_lock_nest_lock(&anon_vma->lock, &mm->mmap_sem);
+		mm_nest_spin_lock(&anon_vma->lock, mm);
 		/*
 		 * We can safely modify head.next after taking the
 		 * anon_vma->lock. If some other vma in this mm shares
@@ -2398,7 +2492,7 @@ static void vm_lock_mapping(struct mm_st
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
 			BUG();
-		spin_lock_nest_lock(&mapping->i_mmap_lock, &mm->mmap_sem);
+		mm_nest_spin_lock(&mapping->i_mmap_lock, mm);
 	}
 }
 
@@ -2439,7 +2533,7 @@ int mm_take_all_locks(struct mm_struct *
 	struct vm_area_struct *vma;
 	int ret = -EINTR;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -2510,7 +2604,7 @@ void mm_drop_all_locks(struct mm_struct 
 {
 	struct vm_area_struct *vma;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
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
Index: mmotm-mm-accessor/mm/oom_kill.c
===================================================================
--- mmotm-mm-accessor.orig/mm/oom_kill.c
+++ mmotm-mm-accessor/mm/oom_kill.c
@@ -401,8 +401,8 @@ static void __oom_kill_task(struct task_
 		       "vsz:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		       task_pid_nr(p), p->comm,
 		       K(p->mm->total_vm),
-		       K(get_mm_counter(p->mm, anon_rss)),
-		       K(get_mm_counter(p->mm, file_rss)));
+		       K(get_mm_counter(p->mm, MM_ANONPAGES)),
+		       K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
 	/*
Index: mmotm-mm-accessor/mm/page_alloc.c
===================================================================
--- mmotm-mm-accessor.orig/mm/page_alloc.c
+++ mmotm-mm-accessor/mm/page_alloc.c
@@ -698,6 +698,7 @@ static int prep_new_page(struct page *pa
 
 	set_page_private(page, 0);
 	set_page_refcounted(page);
+	page->cache = NULL;
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
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
@@ -815,9 +814,9 @@ int try_to_unmap_one(struct page *page, 
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
 		if (PageAnon(page))
-			dec_mm_counter(mm, anon_rss);
+			dec_mm_counter(mm, MM_ANONPAGES);
 		else
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		set_pte_at(mm, address, pte,
 				swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (PageAnon(page)) {
@@ -839,7 +838,7 @@ int try_to_unmap_one(struct page *page, 
 					list_add(&mm->mmlist, &init_mm.mmlist);
 				spin_unlock(&mmlist_lock);
 			}
-			dec_mm_counter(mm, anon_rss);
+			dec_mm_counter(mm, MM_ANONPAGES);
 		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -857,7 +856,7 @@ int try_to_unmap_one(struct page *page, 
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-		dec_mm_counter(mm, file_rss);
+		dec_mm_counter(mm, MM_FILEPAGES);
 
 	page_remove_rmap(page);
 	page_cache_release(page);
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
@@ -996,12 +995,12 @@ static int try_to_unmap_cluster(unsigned
 
 		page_remove_rmap(page);
 		page_cache_release(page);
-		dec_mm_counter(mm, file_rss);
+		dec_mm_counter(mm, MM_FILEPAGES);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
 	if (locked_vma)
-		up_read(&vma->vm_mm->mmap_sem);
+		mm_read_unlock(vma->vm_mm);
 	return ret;
 }
 
Index: mmotm-mm-accessor/mm/swapfile.c
===================================================================
--- mmotm-mm-accessor.orig/mm/swapfile.c
+++ mmotm-mm-accessor/mm/swapfile.c
@@ -840,7 +840,7 @@ static int unuse_pte(struct vm_area_stru
 		goto out;
 	}
 
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
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
 
Index: mmotm-mm-accessor/security/tomoyo/common.c
===================================================================
--- mmotm-mm-accessor.orig/security/tomoyo/common.c
+++ mmotm-mm-accessor/security/tomoyo/common.c
@@ -759,14 +759,14 @@ static const char *tomoyo_get_exe(void)
 
 	if (!mm)
 		return NULL;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
 			cp = tomoyo_realpath_from_path(&vma->vm_file->f_path);
 			break;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return cp;
 }
 
Index: mmotm-mm-accessor/virt/kvm/kvm_main.c
===================================================================
--- mmotm-mm-accessor.orig/virt/kvm/kvm_main.c
+++ mmotm-mm-accessor/virt/kvm/kvm_main.c
@@ -843,18 +843,18 @@ pfn_t gfn_to_pfn(struct kvm *kvm, gfn_t 
 	if (unlikely(npages != 1)) {
 		struct vm_area_struct *vma;
 
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		vma = find_vma(current->mm, addr);
 
 		if (vma == NULL || addr < vma->vm_start ||
 		    !(vma->vm_flags & VM_PFNMAP)) {
-			up_read(&current->mm->mmap_sem);
+			mm_read_unlock(current->mm);
 			get_page(bad_page);
 			return page_to_pfn(bad_page);
 		}
 
 		pfn = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 		BUG_ON(!kvm_is_mmio_pfn(pfn));
 	} else
 		pfn = page_to_pfn(page[0]);
Index: mmotm-mm-accessor/include/linux/mm_accessor.h
===================================================================
--- /dev/null
+++ mmotm-mm-accessor/include/linux/mm_accessor.h
@@ -0,0 +1,36 @@
+#ifndef __LINUX_MM_ACCESSOR_H
+#define __LINUX_MM_ACCESSOR_H
+
+void mm_read_lock(struct mm_struct *mm);
+
+int mm_read_trylock(struct mm_struct *mm);
+
+void mm_read_unlock(struct mm_struct *mm);
+
+void mm_write_lock(struct mm_struct *mm);
+
+void mm_write_unlock(struct mm_struct *mm);
+
+int mm_write_trylock(struct mm_struct *mm);
+
+int mm_is_locked(struct mm_struct *mm);
+
+void mm_write_to_read_lock(struct mm_struct *mm);
+
+void mm_write_lock_nested(struct mm_struct *mm, int x);
+
+void mm_lock_init(struct mm_struct *mm);
+
+void mm_lock_prefetch(struct mm_struct *mm);
+
+void mm_nest_spin_lock(spinlock_t *s, struct mm_struct *mm);
+
+void mm_read_might_lock(struct mm_struct *mm);
+
+int mm_version_check(struct mm_struct *mm);
+
+struct vm_area_struct *get_cached_vma(struct mm_struct *mm);
+void set_cached_vma(struct vm_area_struct *vma);
+void clear_cached_vma(struct task_struct *task);
+
+#endif
Index: mmotm-mm-accessor/include/linux/mm_types.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm_types.h
+++ mmotm-mm-accessor/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/wait.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -24,12 +25,6 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
-#if USE_SPLIT_PTLOCKS
-typedef atomic_long_t mm_counter_t;
-#else  /* !USE_SPLIT_PTLOCKS */
-typedef unsigned long mm_counter_t;
-#endif /* !USE_SPLIT_PTLOCKS */
-
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -77,6 +72,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		void *cache;
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
@@ -180,6 +176,9 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
+	atomic_t cache_access;
+	wait_queue_head_t cache_wait;
+
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
 #endif
@@ -199,6 +198,28 @@ struct core_state {
 	struct completion startup;
 };
 
+enum {
+	MM_FILEPAGES,
+	MM_ANONPAGES,
+	NR_MM_COUNTERS
+};
+
+#if USE_SPLIT_PTLOCKS
+#define SPLIT_RSS_COUNTING
+struct mm_rss_stat {
+	atomic_long_t count[NR_MM_COUNTERS];
+};
+/* per-thread cached information, */
+struct task_rss_stat {
+	int events;	/* for synchronization threshold */
+	int count[NR_MM_COUNTERS];
+};
+#else  /* !USE_SPLIT_PTLOCKS */
+struct mm_rss_stat {
+	unsigned long count[NR_MM_COUNTERS];
+};
+#endif /* !USE_SPLIT_PTLOCKS */
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -216,6 +237,7 @@ struct mm_struct {
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
 	struct rw_semaphore mmap_sem;
+	int version;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
@@ -223,11 +245,6 @@ struct mm_struct {
 						 * by mmlist_lock
 						 */
 
-	/* Special counters, in some configurations protected by the
-	 * page_table_lock, in other configurations by being atomic.
-	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
@@ -240,6 +257,12 @@ struct mm_struct {
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
+	/*
+	 * Special counters, in some configurations protected by the
+	 * page_table_lock, in other configurations by being atomic.
+	 */
+	struct mm_rss_stat rss_stat;
+
 	struct linux_binfmt *binfmt;
 
 	cpumask_t cpu_vm_mask;
@@ -292,4 +315,7 @@ struct mm_struct {
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
 #define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
 
+/* Functions for accessing mm_struct */
+#include <linux/mm_accessor.h>
+
 #endif /* _LINUX_MM_TYPES_H */
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
@@ -40,7 +40,7 @@ static void zap_pte(struct mm_struct *mm
 			page_remove_rmap(page);
 			page_cache_release(page);
 			update_hiwater_rss(mm);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 		}
 	} else {
 		if (!pte_file(pte))
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
 
Index: mmotm-mm-accessor/drivers/gpu/drm/drm_bufs.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/drm_bufs.c
+++ mmotm-mm-accessor/drivers/gpu/drm/drm_bufs.c
@@ -1574,18 +1574,18 @@ int drm_mapbufs(struct drm_device *dev, 
 				retcode = -EINVAL;
 				goto done;
 			}
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, map->size,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED,
 					  token);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 		} else {
-			down_write(&current->mm->mmap_sem);
+			mm_write_lock(current->mm);
 			virtual = do_mmap(file_priv->filp, 0, dma->byte_count,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, 0);
-			up_write(&current->mm->mmap_sem);
+			mm_write_unlock(current->mm);
 		}
 		if (virtual > -1024UL) {
 			/* Real error */
Index: mmotm-mm-accessor/drivers/gpu/drm/i810/i810_dma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i810/i810_dma.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i810/i810_dma.c
@@ -131,7 +131,7 @@ static int i810_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i810_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -146,7 +146,7 @@ static int i810_map_buffer(struct drm_bu
 		retcode = PTR_ERR(buf_priv->virtual);
 		buf_priv->virtual = NULL;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return retcode;
 }
@@ -159,11 +159,11 @@ static int i810_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	buf_priv->currently_mapped = I810_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-mm-accessor/drivers/gpu/drm/i830/i830_dma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/i830/i830_dma.c
+++ mmotm-mm-accessor/drivers/gpu/drm/i830/i830_dma.c
@@ -134,7 +134,7 @@ static int i830_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i830_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -150,7 +150,7 @@ static int i830_map_buffer(struct drm_bu
 	} else {
 		buf_priv->virtual = (void __user *)virtual;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return retcode;
 }
@@ -163,11 +163,11 @@ static int i830_unmap_buffer(struct drm_
 	if (buf_priv->currently_mapped != I830_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	retcode = do_munmap(current->mm,
 			    (unsigned long)buf_priv->virtual,
 			    (size_t) buf->total);
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	buf_priv->currently_mapped = I830_BUF_UNMAPPED;
 	buf_priv->virtual = NULL;
Index: mmotm-mm-accessor/drivers/gpu/drm/via/via_dmablit.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/gpu/drm/via/via_dmablit.c
+++ mmotm-mm-accessor/drivers/gpu/drm/via/via_dmablit.c
@@ -237,14 +237,14 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == (vsg->pages = vmalloc(sizeof(struct page *) * vsg->num_pages)))
 		return -ENOMEM;
 	memset(vsg->pages, 0, sizeof(struct page *) * vsg->num_pages);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = get_user_pages(current, current->mm,
 			     (unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
 
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 	if (ret != vsg->num_pages) {
 		if (ret < 0)
 			return ret;
Index: mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_sdma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/hw/ipath/ipath_user_sdma.c
+++ mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_sdma.c
@@ -811,9 +811,9 @@ int ipath_user_sdma_writev(struct ipath_
 	while (dim) {
 		const int mxp = 8;
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		ret = ipath_user_sdma_queue_pkts(dd, pq, &list, iov, dim, mxp);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (ret <= 0)
 			goto done_unlock;
Index: mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-udma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/ivtv/ivtv-udma.c
+++ mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-udma.c
@@ -124,10 +124,10 @@ int ivtv_udma_setup(struct ivtv *itv, un
 	}
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	err = get_user_pages(current, current->mm,
 			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
Index: mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-yuv.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/media/video/ivtv/ivtv-yuv.c
+++ mmotm-mm-accessor/drivers/media/video/ivtv/ivtv-yuv.c
@@ -75,10 +75,10 @@ static int ivtv_yuv_prep_user_dma(struct
 	ivtv_udma_get_page_info (&uv_dma, (unsigned long)args->uv_source, 360 * uv_decode_height);
 
 	/* Get user pages for DMA Xfer */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	y_pages = get_user_pages(current, current->mm, y_dma.uaddr, y_dma.page_count, 0, 1, &dma->map[0], NULL);
 	uv_pages = get_user_pages(current, current->mm, uv_dma.uaddr, uv_dma.page_count, 0, 1, &dma->map[y_pages], NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	dma->page_count = y_dma.page_count + uv_dma.page_count;
 
Index: mmotm-mm-accessor/drivers/dma/iovlock.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/dma/iovlock.c
+++ mmotm-mm-accessor/drivers/dma/iovlock.c
@@ -94,7 +94,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		ret = get_user_pages(
 			current,
 			current->mm,
@@ -104,7 +104,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 			0,	/* force */
 			page_list->pages,
 			NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (ret != page_list->nr_pages)
 			goto unpin;
Index: mmotm-mm-accessor/drivers/oprofile/buffer_sync.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/oprofile/buffer_sync.c
+++ mmotm-mm-accessor/drivers/oprofile/buffer_sync.c
@@ -87,11 +87,11 @@ munmap_notify(struct notifier_block *sel
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -99,7 +99,7 @@ munmap_notify(struct notifier_block *sel
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return 0;
 }
 
@@ -410,7 +410,7 @@ static void release_mm(struct mm_struct 
 {
 	if (!mm)
 		return;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 }
 
@@ -419,7 +419,7 @@ static struct mm_struct *take_tasks_mm(s
 {
 	struct mm_struct *mm = get_task_mm(task);
 	if (mm)
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 	return mm;
 }
 
Index: mmotm-mm-accessor/drivers/video/pvr2fb.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/video/pvr2fb.c
+++ mmotm-mm-accessor/drivers/video/pvr2fb.c
@@ -686,10 +686,10 @@ static ssize_t pvr2fb_write(struct fb_in
 	if (!pages)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = get_user_pages(current, current->mm, (unsigned long)buf,
 			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;
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
Index: mmotm-mm-accessor/mm/mm_accessor.c
===================================================================
--- /dev/null
+++ mmotm-mm-accessor/mm/mm_accessor.c
@@ -0,0 +1,103 @@
+#include <linux/sched.h>
+#include <linux/module.h>
+
+void mm_read_lock(struct mm_struct *mm)
+{
+	down_read(&mm->mmap_sem);
+	if (current->mm == mm && current->mm_version != mm->version)
+		current->mm_version = mm->version;
+}
+EXPORT_SYMBOL(mm_read_lock);
+
+int mm_read_trylock(struct mm_struct *mm)
+{
+	int ret = down_read_trylock(&mm->mmap_sem);
+	if (ret && current->mm == mm && current->mm_version != mm->version)
+		current->mm_version = mm->version;
+	return ret;
+}
+EXPORT_SYMBOL(mm_read_trylock);
+
+void mm_read_unlock(struct mm_struct *mm)
+{
+	up_read(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_read_unlock);
+
+void mm_write_lock(struct mm_struct *mm)
+{
+	down_write(&mm->mmap_sem);
+	mm->version++;
+}
+EXPORT_SYMBOL(mm_write_lock);
+
+void mm_write_unlock(struct mm_struct *mm)
+{
+	mm->version++;
+	up_write(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_write_unlock);
+
+int mm_write_trylock(struct mm_struct *mm)
+{
+	int ret = down_write_trylock(&mm->mmap_sem);
+
+	if (ret)
+		mm->version++;
+	return ret;
+}
+EXPORT_SYMBOL(mm_write_trylock);
+
+int mm_is_locked(struct mm_struct *mm)
+{
+	return rwsem_is_locked(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_is_locked);
+
+void mm_write_to_read_lock(struct mm_struct *mm)
+{
+	mm->version++;
+	downgrade_write(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_write_to_read_lock);
+
+void mm_write_lock_nested(struct mm_struct *mm, int x)
+{
+	down_write_nested(&mm->mmap_sem, x);
+}
+EXPORT_SYMBOL(mm_write_lock_nested);
+
+void mm_lock_init(struct mm_struct *mm)
+{
+	init_rwsem(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_lock_init);
+
+void mm_lock_prefetch(struct mm_struct *mm)
+{
+	prefetchw(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_lock_prefetch);
+
+void mm_nest_spin_lock(spinlock_t *s, struct mm_struct *mm)
+{
+	spin_lock_nest_lock(s, &mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_nest_spin_lock);
+
+void mm_read_might_lock(struct mm_struct *mm)
+{
+	might_lock_read(&mm->mmap_sem);
+}
+EXPORT_SYMBOL(mm_read_might_lock);
+
+/*
+ * Called when mm is accessed without read-lock or for chekcing
+ * per-thread cached value is stale or not.
+ */
+int mm_version_check(struct mm_struct *mm)
+{
+	if ((current->mm == mm) && (current->mm_version != mm->version))
+		return 0;
+	return 1;
+}
Index: mmotm-mm-accessor/kernel/tsacct.c
===================================================================
--- mmotm-mm-accessor.orig/kernel/tsacct.c
+++ mmotm-mm-accessor/kernel/tsacct.c
@@ -21,6 +21,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/acct.h>
 #include <linux/jiffies.h>
+#include <linux/mm.h>
 
 /*
  * fill in basic accounting fields
Index: mmotm-mm-accessor/mm/filemap_xip.c
===================================================================
--- mmotm-mm-accessor.orig/mm/filemap_xip.c
+++ mmotm-mm-accessor/mm/filemap_xip.c
@@ -194,7 +194,7 @@ retry:
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
-			dec_mm_counter(mm, file_rss);
+			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);

--Multipart=_Fri__18_Dec_2009_09_38_49_+0900_blCCLMOtWox4vccc
Content-Type: text/x-csrc;
 name="multi-fault-all-split.c"
Content-Disposition: attachment;
 filename="multi-fault-all-split.c"
Content-Transfer-Encoding: 7bit

/*
 * multi-fault.c :: causes 60secs of parallel page fault in multi-thread.
 * % gcc -O2 -o multi-fault multi-fault.c -lpthread
 * % multi-fault # of cpus.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define NR_THREADS	8
pthread_t threads[NR_THREADS];
/*
 * For avoiding contention in page table lock, FAULT area is
 * sparse. If FAULT_LENGTH is too large for your cpus, decrease it.
 */
#define MMAP_LENGTH	(8 * 1024 * 1024)
#define FAULT_LENGTH	(2 * 1024 * 1024)
void *mmap_area[NR_THREADS];
#define PAGE_SIZE	4096

pthread_barrier_t barrier;
int name[NR_THREADS];

void segv_handler(int sig)
{
	sleep(100);
}
void *worker(void *data)
{
	cpu_set_t set;
	int cpu;

	cpu = *(int *)data;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	while (1) {
		char *c;
		char *start = mmap_area[cpu];
		char *end = mmap_area[cpu] + FAULT_LENGTH;
		pthread_barrier_wait(&barrier);
		//printf("fault into %p-%p\n",start, end);

		for (c = start; c < end; c += PAGE_SIZE)
			*c = 0;
		pthread_barrier_wait(&barrier);

		madvise(start, FAULT_LENGTH, MADV_DONTNEED);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int i, ret;
	unsigned int num;

	if (argc < 2)
		return 0;

	num = atoi(argv[1]);	
	pthread_barrier_init(&barrier, NULL, num);

	for (i = 0; i < num; i++) {
		mmap_area[i] = mmap(NULL, MMAP_LENGTH * num,
				PROT_WRITE|PROT_READ,
				MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
		/* memory hole */
		mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
	}

	for (i = 0; i < num; ++i) {
		name[i] = i;
		ret = pthread_create(&threads[i], NULL, worker, &name[i]);
		if (ret < 0) {
			perror("pthread create");
			return 0;
		}
	}
	sleep(60);
	return 0;
}

--Multipart=_Fri__18_Dec_2009_09_38_49_+0900_blCCLMOtWox4vccc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
