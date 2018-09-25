Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F27AE8E00A2
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d1-v6so8926175qth.21
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:30:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l6-v6sor884645qvq.113.2018.09.25.08.30.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:30:26 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 6/8] mm: keep the page we read for the next loop
Date: Tue, 25 Sep 2018 11:30:09 -0400
Message-Id: <20180925153011.15311-7-josef@toxicpanda.com>
In-Reply-To: <20180925153011.15311-1-josef@toxicpanda.com>
References: <20180925153011.15311-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

If we drop the mmap_sem we need to redo the vma lookup and then
re-lookup the page.  This is kind of a waste since we've already done
the work, and we could even possibly evict the page, causing a refault.
Instead just hold a reference to the page and save it in our vm_fault.
The next time we go through filemap_fault we'll grab our page, verify
that it's the one we want and carry on.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 arch/alpha/mm/fault.c         |  7 +++++--
 arch/arc/mm/fault.c           |  6 +++++-
 arch/arm/mm/fault.c           |  2 ++
 arch/arm64/mm/fault.c         |  2 ++
 arch/hexagon/mm/vm_fault.c    |  6 +++++-
 arch/ia64/mm/fault.c          |  6 +++++-
 arch/m68k/mm/fault.c          |  6 +++++-
 arch/microblaze/mm/fault.c    |  6 +++++-
 arch/mips/mm/fault.c          |  6 +++++-
 arch/nds32/mm/fault.c         |  3 +++
 arch/nios2/mm/fault.c         |  6 +++++-
 arch/openrisc/mm/fault.c      |  6 +++++-
 arch/parisc/mm/fault.c        |  6 +++++-
 arch/powerpc/mm/copro_fault.c |  3 ++-
 arch/powerpc/mm/fault.c       |  3 +++
 arch/riscv/mm/fault.c         |  6 +++++-
 arch/s390/mm/fault.c          |  1 +
 arch/sh/mm/fault.c            |  8 ++++++--
 arch/sparc/mm/fault_32.c      |  8 +++++++-
 arch/sparc/mm/fault_64.c      |  6 +++++-
 arch/um/kernel/trap.c         |  6 +++++-
 arch/unicore32/mm/fault.c     |  5 ++++-
 arch/x86/mm/fault.c           |  2 ++
 arch/xtensa/mm/fault.c        |  6 +++++-
 drivers/iommu/amd_iommu_v2.c  |  1 +
 drivers/iommu/intel-svm.c     |  1 +
 include/linux/mm.h            | 14 ++++++++++++++
 mm/filemap.c                  | 31 ++++++++++++++++++++++++++++---
 mm/gup.c                      |  3 +++
 mm/hmm.c                      |  1 +
 mm/ksm.c                      |  1 +
 31 files changed, 151 insertions(+), 23 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 3c98dfef03a9..ed5929787d4a 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -152,10 +152,13 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	vm_fault_init(&vmfs, vma, flags, address);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -181,7 +184,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 			goto retry;
 		}
 	}
-
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	return;
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 7aeb81ff5070..38a6c5e94fac 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -149,8 +149,10 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	if (unlikely(fatal_signal_pending(current))) {
 		if ((fault & VM_FAULT_ERROR) && !(fault & VM_FAULT_RETRY))
 			up_read(&mm->mmap_sem);
-		if (user_mode(regs))
+		if (user_mode(regs)) {
+			vm_fault_cleanup(&vmf);
 			return;
+		}
 	}
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
@@ -176,10 +178,12 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 		}
 
 		/* Fault Handled Gracefully */
+		vm_fault_cleanup(&vmf);
 		up_read(&mm->mmap_sem);
 		return;
 	}
 
+	vm_fault_cleanup(&vmf);
 	if (fault & VM_FAULT_OOM)
 		goto out_of_memory;
 	else if (fault & VM_FAULT_SIGSEGV)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 885a24385a0a..f08946e78bd9 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -325,6 +325,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		if (!user_mode(regs))
 			goto no_context;
 		return 0;
@@ -356,6 +357,7 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 31e86a74cbe0..6f3e908a3820 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -506,6 +506,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 		 * in __lock_page_or_retry in mm/filemap.c.
 		 */
 		if (fatal_signal_pending(current)) {
+			vm_fault_cleanup(&vmf);
 			if (!user_mode(regs))
 				goto no_context;
 			return 0;
@@ -521,6 +522,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 			goto retry;
 		}
 	}
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 1ee1042bb2b5..d68aa9691184 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -106,8 +106,10 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	/* The most common case -- we are done. */
 	if (likely(!(fault & VM_FAULT_ERROR))) {
@@ -123,10 +125,12 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 			}
 		}
 
+		vm_fault_cleanup(&vmf);
 		up_read(&mm->mmap_sem);
 		return;
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	/* Handle copyin/out exception cases */
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 827b898adb5e..68b689bb619f 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -165,8 +165,10 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
@@ -174,6 +176,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		 * to us that made us unable to handle the page fault
 		 * gracefully.
 		 */
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM) {
 			goto out_of_memory;
 		} else if (fault & VM_FAULT_SIGSEGV) {
@@ -203,6 +206,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index e42eddc9c7ca..7e8be4665ef9 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -139,10 +139,13 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	fault = handle_mm_fault(&vmf);
 	pr_debug("handle_mm_fault returns %x\n", fault);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return 0;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -178,6 +181,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return 0;
 
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index ade980266f65..bb320be95142 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -219,10 +219,13 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -251,6 +254,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index bf212bb70f24..8f1cfe564987 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -156,11 +156,14 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -193,6 +196,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 27ac4caa5102..7cb4d9f73c1a 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -213,12 +213,14 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		if (!user_mode(regs))
 			goto no_context;
 		return;
 	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGBUS)
@@ -249,6 +251,7 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 693472f05065..774035116392 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -136,10 +136,13 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -175,6 +178,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 70eef1d9f7ed..9186af1b9cdc 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -166,10 +166,13 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -198,6 +201,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 83c89cada3c0..7ad74571407e 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -304,8 +304,10 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
@@ -313,6 +315,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 		 * other thing happened to us that made us unable to
 		 * handle the page fault gracefully.
 		 */
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -339,6 +342,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 			goto retry;
 		}
 	}
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 02dd21a54479..07ec389ac6c6 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -81,6 +81,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	vm_fault_init(&vmf, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
 	*flt = handle_mm_fault(&vmf);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
 			goto out_unlock;
@@ -95,7 +96,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 		current->maj_flt++;
 	else
 		current->min_flt++;
-
+	vm_fault_cleanup(&vmf);
 out_unlock:
 	up_read(&mm->mmap_sem);
 	return ret;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index cc00bba104fb..1940471c6a6f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -552,6 +552,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 
 		int pkey = vma_pkey(vma);
 
+		vm_fault_cleanup(&vmf);
 		up_read(&mm->mmap_sem);
 		return bad_key_fault_exception(regs, address, pkey);
 	}
@@ -580,9 +581,11 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 		 * User mode? Just return to handle the fatal exception otherwise
 		 * return to bad_page_fault
 		 */
+		vm_fault_cleanup(&vmf);
 		return is_user ? 0 : SIGBUS;
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&current->mm->mmap_sem);
 
 	if (unlikely(fault & VM_FAULT_ERROR))
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index aa3db34c9eb8..64c8de82a40b 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -129,10 +129,13 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGBUS)
@@ -172,6 +175,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 14cfd6de43ed..a91849a7e338 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -561,6 +561,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 out_up:
 	up_read(&mm->mmap_sem);
 out:
+	vm_fault_cleanup(&vmf);
 	return fault;
 }
 
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 31202706125c..ee0ad499ed53 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -485,9 +485,12 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR)))
-		if (mm_fault_error(regs, error_code, address, fault))
+	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR))) {
+		if (mm_fault_error(regs, error_code, address, fault)) {
+			vm_fault_cleanup(&vmf);
 			return;
+		}
+	}
 
 	if (flags & FAULT_FLAG_ALLOW_RETRY) {
 		if (fault & VM_FAULT_MAJOR) {
@@ -512,5 +515,6 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 }
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index a9dd62393934..0623154163c5 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -239,10 +239,13 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -275,6 +278,7 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 
@@ -412,8 +416,10 @@ static void force_user_fault(unsigned long address, int write)
 	switch (handle_mm_fault(&vmf)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
+		vm_fault_cleanup(&vmf);
 		goto do_sigbus;
 	}
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	return;
 bad_area:
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 381ab905eb2c..45107ddb8478 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -437,10 +437,13 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		goto exit_exception;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -472,6 +475,7 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			goto retry;
 		}
 	}
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	mm_rss = get_mm_rss(mm);
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index c6d9e176c5c5..419f4d54bf10 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -78,10 +78,13 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 		vm_fault_init(&vmf, vma, address, flags);
 		fault = handle_mm_fault(&vmf);
 
-		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+			vm_fault_cleanup(&vmf);
 			goto out_nosemaphore;
+		}
 
 		if (unlikely(fault & VM_FAULT_ERROR)) {
+			vm_fault_cleanup(&vmf);
 			if (fault & VM_FAULT_OOM) {
 				goto out_of_memory;
 			} else if (fault & VM_FAULT_SIGSEGV) {
@@ -109,6 +112,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 		pud = pud_offset(pgd, address);
 		pmd = pmd_offset(pud, address);
 		pte = pte_offset_kernel(pmd, address);
+		vm_fault_cleanup(&vmf);
 	} while (!pte_present(*pte));
 	err = 0;
 	/*
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 68c2b0a65348..0c94b8d5187d 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -262,8 +262,10 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return 0;
+	}
 
 	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_RETRY)) {
 		if (fault & VM_FAULT_MAJOR)
@@ -278,6 +280,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 
 	/*
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9919a25b15e6..a8ea7b609697 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1410,6 +1410,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
+		vm_fault_cleanup(&vmf);
 
 		/* User mode? Just return to handle the fatal exception */
 		if (flags & FAULT_FLAG_USER)
@@ -1420,6 +1421,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 		return;
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, &pkey, fault);
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index f1b0f4f858ff..a577b73f9ca4 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -112,10 +112,13 @@ void do_page_fault(struct pt_regs *regs)
 	vm_fault_init(&vmf, vma, address, flags);
 	fault = handle_mm_fault(&vmf);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
+		vm_fault_cleanup(&vmf);
 		return;
+	}
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
+		vm_fault_cleanup(&vmf);
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
 		else if (fault & VM_FAULT_SIGSEGV)
@@ -142,6 +145,7 @@ void do_page_fault(struct pt_regs *regs)
 		}
 	}
 
+	vm_fault_cleanup(&vmf);
 	up_read(&mm->mmap_sem);
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
 	if (flags & VM_FAULT_MAJOR)
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 129e0ef68827..fc20bbe1c0dc 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -535,6 +535,7 @@ static void do_fault(struct work_struct *work)
 
 	vm_fault_init(&vmf, vma, address, flags);
 	ret = handle_mm_fault(&vmf);
+	vm_fault_cleanup(&vmf);
 out:
 	up_read(&mm->mmap_sem);
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index 03aa02723242..614f6aab9615 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -640,6 +640,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		vm_fault_init(&vmf, vma, address,
 			      req->wr_req ? FAULT_FLAG_WRITE : 0);
 		ret = handle_mm_fault(&vmf);
+		vm_fault_cleanup(&vmf);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e271c60af01a..724514be03b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -360,6 +360,12 @@ struct vm_fault {
 					 * is set (which is also implied by
 					 * VM_FAULT_ERROR).
 					 */
+	struct page *cached_page;	/* ->fault handlers that return
+					 * VM_FAULT_RETRY can store their
+					 * previous page here to be reused the
+					 * next time we loop through the fault
+					 * handler for faster lookup.
+					 */
 	/* These three entries are valid only while holding ptl lock */
 	pte_t *pte;			/* Pointer to pte entry matching
 					 * the 'address'. NULL if the page
@@ -953,6 +959,14 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
+static inline void vm_fault_cleanup(struct vm_fault *vmf)
+{
+	if (vmf->cached_page) {
+		put_page(vmf->cached_page);
+		vmf->cached_page = NULL;
+	}
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/mm/filemap.c b/mm/filemap.c
index 65395ee132a0..49b35293fa95 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2530,13 +2530,38 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	pgoff_t offset = vmf->pgoff;
 	int flags = vmf->flags;
 	pgoff_t max_off;
-	struct page *page;
+	struct page *page = NULL;
+	struct page *cached_page = vmf->cached_page;
 	vm_fault_t ret = 0;
 
 	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (unlikely(offset >= max_off))
 		return VM_FAULT_SIGBUS;
 
+	/*
+	 * We may have read in the page already and have a page from an earlier
+	 * loop.  If so we need to see if this page is still valid, and if not
+	 * do the whole dance over again.
+	 */
+	if (cached_page) {
+		if (flags & FAULT_FLAG_KILLABLE) {
+			error = lock_page_killable(cached_page);
+			if (error) {
+				up_read(&mm->mmap_sem);
+				goto out_retry;
+			}
+		} else
+			lock_page(cached_page);
+		vmf->cached_page = NULL;
+		if (cached_page->mapping == mapping &&
+		    cached_page->index == offset) {
+			page = cached_page;
+			goto have_cached_page;
+		}
+		unlock_page(cached_page);
+		put_page(cached_page);
+	}
+
 	/*
 	 * Do we have something in the page cache already?
 	 */
@@ -2587,8 +2612,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
+have_cached_page:
 	VM_BUG_ON_PAGE(page->index != offset, page);
-
 	/*
 	 * We have a locked page in the page cache, now we need to check
 	 * that it's up-to-date. If not, it is going to be due to an error.
@@ -2677,7 +2702,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 	if (fpin)
 		fput(fpin);
 	if (page)
-		put_page(page);
+		vmf->cached_page = page;
 	return ret | VM_FAULT_RETRY;
 }
 EXPORT_SYMBOL(filemap_fault);
diff --git a/mm/gup.c b/mm/gup.c
index c12d1e98614b..75f55f4f044c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -518,6 +518,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 
 	vm_fault_init(&vmf, vma, address, fault_flags);
 	ret = handle_mm_fault(&vmf);
+	vm_fault_cleanup(&vmf);
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, *flags);
 
@@ -840,6 +841,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, 0);
 
+		vm_fault_cleanup(&vmf);
 		if (err)
 			return err;
 		BUG();
@@ -854,6 +856,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			goto retry;
 		}
 	}
+	vm_fault_cleanup(&vmf);
 
 	if (tsk) {
 		if (major)
diff --git a/mm/hmm.c b/mm/hmm.c
index 695ef184a7d0..b803746745a5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -309,6 +309,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
 	vm_fault_init(&vmf, vma, addr, flags);
 	ret = handle_mm_fault(&vmf);
+	vm_fault_cleanup(&vmf);
 	if (ret & VM_FAULT_RETRY)
 		return -EBUSY;
 	if (ret & VM_FAULT_ERROR) {
diff --git a/mm/ksm.c b/mm/ksm.c
index 4b6d90357ee2..8404e230fdab 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -483,6 +483,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 			vm_fault_init(&vmf, vma, addr,
 				      FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
 			ret = handle_mm_fault(&vmf);
+			vm_fault_cleanup(&vmf);
 		} else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
-- 
2.14.3
