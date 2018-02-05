Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB54D6B029E
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:39 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q5so7783783pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si4855082pgt.217.2018.02.04.17.28.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 36/64] arch/mips: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:26 +0100
Message-Id: <20180205012754.23615-37-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This becomes quite straightforward with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 arch/mips/kernel/traps.c |  5 +++--
 arch/mips/kernel/vdso.c  |  4 ++--
 arch/mips/mm/c-octeon.c  |  5 +++--
 arch/mips/mm/c-r4k.c     |  5 +++--
 arch/mips/mm/fault.c     | 10 +++++-----
 5 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 0ae4a731cc12..a7d1d2417844 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -746,6 +746,7 @@ int process_fpemu_return(int sig, void __user *fault_addr, unsigned long fcr31)
 {
 	struct siginfo si;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	clear_siginfo(&si);
 	switch (sig) {
@@ -766,13 +767,13 @@ int process_fpemu_return(int sig, void __user *fault_addr, unsigned long fcr31)
 	case SIGSEGV:
 		si.si_addr = fault_addr;
 		si.si_signo = sig;
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 		vma = find_vma(current->mm, (unsigned long)fault_addr);
 		if (vma && (vma->vm_start <= (unsigned long)fault_addr))
 			si.si_code = SEGV_ACCERR;
 		else
 			si.si_code = SEGV_MAPERR;
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 		force_sig_info(sig, &si, current);
 		return 1;
 
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 56b7c29991db..beaf63864e70 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -104,7 +104,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	if (down_write_killable(&mm->mmap_sem))
+	if (mm_write_lock_killable(mm, &mmrange))
 		return -EINTR;
 
 	/* Map delay slot emulation page */
@@ -177,6 +177,6 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	ret = 0;
 
 out:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
diff --git a/arch/mips/mm/c-octeon.c b/arch/mips/mm/c-octeon.c
index 0e45b061e514..e4f6db4a8755 100644
--- a/arch/mips/mm/c-octeon.c
+++ b/arch/mips/mm/c-octeon.c
@@ -136,11 +136,12 @@ static void octeon_flush_icache_range(unsigned long start, unsigned long end)
 static void octeon_flush_cache_sigtramp(unsigned long addr)
 {
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, addr);
 	octeon_flush_icache_all_cores(vma);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 }
 
 
diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index 6f534b209971..7f9c9c91dbc1 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -999,8 +999,9 @@ static void r4k_flush_cache_sigtramp(unsigned long addr)
 {
 	struct flush_cache_sigtramp_args args;
 	int npages;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 
 	npages = get_user_pages_fast(addr, 1, 0, &args.page);
 	if (npages < 1)
@@ -1013,7 +1014,7 @@ static void r4k_flush_cache_sigtramp(unsigned long addr)
 
 	put_page(args.page);
 out:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 }
 
 static void r4k_flush_icache_all(void)
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 1433edd01d09..510abb6b433a 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -98,7 +98,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	if (user_mode(regs))
 		flags |= FAULT_FLAG_USER;
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -192,7 +192,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 /*
@@ -200,7 +200,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -256,14 +256,14 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 * We ran out of memory, call the OOM killer, and return the userspace
 	 * (which will retry the fault, or kill us if we got oom-killed).
 	 */
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!user_mode(regs))
 		goto no_context;
 	pagefault_out_of_memory();
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!user_mode(regs))
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
