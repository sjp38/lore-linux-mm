Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13D5B6B002B
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:07 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 3so7801139pla.1
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n11-v6si6052913plp.449.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 31/64] arch/sparc: use mm locking wrappers
Date: Mon,  5 Feb 2018 02:27:21 +0100
Message-Id: <20180205012754.23615-32-dbueso@wotan.suse.de>
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
 arch/sparc/mm/fault_32.c | 18 +++++++++---------
 arch/sparc/mm/fault_64.c | 12 ++++++------
 arch/sparc/vdso/vma.c    |  5 +++--
 3 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index ebb2406dbe7c..1f63a37b6f81 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -204,7 +204,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
 retry:
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	if (!from_user && address >= PAGE_OFFSET)
 		goto bad_area;
@@ -281,7 +281,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 		}
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 
 	/*
@@ -289,7 +289,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	 * Fix it, but check if it's kernel or user first..
 	 */
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -338,7 +338,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (from_user) {
 		pagefault_out_of_memory();
 		return;
@@ -346,7 +346,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	do_fault_siginfo(BUS_ADRERR, SIGBUS, regs, text_fault);
 	if (!from_user)
 		goto no_context;
@@ -394,7 +394,7 @@ static void force_user_fault(unsigned long address, int write)
 
 	code = SEGV_MAPERR;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -419,15 +419,15 @@ static void force_user_fault(unsigned long address, int write)
 	case VM_FAULT_OOM:
 		goto do_sigbus;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return;
 bad_area:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	__do_fault_siginfo(code, SIGSEGV, tsk->thread.kregs, address);
 	return;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	__do_fault_siginfo(BUS_ADRERR, SIGBUS, tsk->thread.kregs, address);
 }
 
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index e0a3c36b0fa1..d674c2d6b51a 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -335,7 +335,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
+	if (!mm_read_trylock(mm, &mmrange)) {
 		if ((regs->tstate & TSTATE_PRIV) &&
 		    !search_exception_tables(regs->tpc)) {
 			insn = get_fault_insn(regs, insn);
@@ -343,7 +343,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 		}
 
 retry:
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 	}
 
 	if (fault_code & FAULT_CODE_BAD_RA)
@@ -476,7 +476,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			goto retry;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	mm_rss = get_mm_rss(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE)
@@ -507,7 +507,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	 */
 bad_area:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 handle_kernel_fault:
 	do_kernel_fault(regs, si_code, fault_code, insn, address);
@@ -519,7 +519,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
  */
 out_of_memory:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	if (!(regs->tstate & TSTATE_PRIV)) {
 		pagefault_out_of_memory();
 		goto exit_exception;
@@ -532,7 +532,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 
 do_sigbus:
 	insn = get_fault_insn(regs, insn);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	/*
 	 * Send a sigbus, regardless of whether we were in kernel
diff --git a/arch/sparc/vdso/vma.c b/arch/sparc/vdso/vma.c
index f51595f861b8..35b888bc2f54 100644
--- a/arch/sparc/vdso/vma.c
+++ b/arch/sparc/vdso/vma.c
@@ -178,8 +178,9 @@ static int map_vdso(const struct vdso_image *image,
 	struct vm_area_struct *vma;
 	unsigned long text_start, addr = 0;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 
 	/*
 	 * First, get an unmapped region: then randomize it, and make sure that
@@ -235,7 +236,7 @@ static int map_vdso(const struct vdso_image *image,
 	if (ret)
 		current->mm->context.vdso = NULL;
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return ret;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
