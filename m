Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6637C6B2487
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:21:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b16so2478927qtc.22
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:21:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r41si2677380qtj.56.2018.11.20.22.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 22:21:38 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC v3 2/4] mm: userfault: return VM_FAULT_RETRY on signals
Date: Wed, 21 Nov 2018 14:21:01 +0800
Message-Id: <20181121062103.18835-3-peterx@redhat.com>
In-Reply-To: <20181121062103.18835-1-peterx@redhat.com>
References: <20181121062103.18835-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>

There was a special path in handle_userfault() in the past that we'll
return a VM_FAULT_NOPAGE when we detected non-fatal signals when waiting
for userfault handling.  We did that by reacquiring the mmap_sem before
returning.  However that brings a risk in that the vmas might have
changed when we retake the mmap_sem and even we could be holding an
invalid vma structure.  The problem was reported by syzbot.

This patch removes the special path and we'll return a VM_FAULT_RETRY
with the common path even if we have got such signals.  Then for all the
architectures that is passing in VM_FAULT_ALLOW_RETRY into
handle_mm_fault(), we check not only for SIGKILL but for all the rest of
userspace pending signals right after we returned from
handle_mm_fault().

The idea comes from the upstream discussion between Linus and Andrea:

  https://lkml.org/lkml/2017/10/30/560

(This patch contains a potential fix for a double-free of mmap_sem on
 ARC architecture; please see https://lkml.org/lkml/2018/11/1/723 for
 more information)

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c      |  2 +-
 arch/arc/mm/fault.c        | 11 +++++++----
 arch/arm/mm/fault.c        | 14 ++++++++++----
 arch/arm64/mm/fault.c      |  6 +++---
 arch/hexagon/mm/vm_fault.c |  2 +-
 arch/ia64/mm/fault.c       |  2 +-
 arch/m68k/mm/fault.c       |  2 +-
 arch/microblaze/mm/fault.c |  2 +-
 arch/mips/mm/fault.c       |  2 +-
 arch/nds32/mm/fault.c      |  6 +++---
 arch/nios2/mm/fault.c      |  2 +-
 arch/openrisc/mm/fault.c   |  2 +-
 arch/parisc/mm/fault.c     |  2 +-
 arch/powerpc/mm/fault.c    |  4 +++-
 arch/riscv/mm/fault.c      |  4 ++--
 arch/s390/mm/fault.c       |  9 ++++++---
 arch/sh/mm/fault.c         |  4 ++++
 arch/sparc/mm/fault_32.c   |  3 +++
 arch/sparc/mm/fault_64.c   |  3 +++
 arch/um/kernel/trap.c      |  5 ++++-
 arch/unicore32/mm/fault.c  |  4 ++--
 arch/x86/mm/fault.c        | 12 +++++++++++-
 arch/xtensa/mm/fault.c     |  3 +++
 fs/userfaultfd.c           | 24 ------------------------
 24 files changed, 73 insertions(+), 57 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index d73dc473fbb9..46e5e420ad2a 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -150,7 +150,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	   the fault.  */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index c9da6102eb4f..52b6b71b74e2 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -142,11 +142,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	fault = handle_mm_fault(vma, address, flags);
 
 	/* If Pagefault was interrupted by SIGKILL, exit page fault "early" */
-	if (unlikely(fatal_signal_pending(current))) {
-		if ((fault & VM_FAULT_ERROR) && !(fault & VM_FAULT_RETRY))
+	if (unlikely(fatal_signal_pending(current) && user_mode(regs))) {
+		/*
+		 * VM_FAULT_RETRY means we have released the mmap_sem,
+		 * otherwise we need to drop it before leaving
+		 */
+		if (!(fault & VM_FAULT_RETRY))
 			up_read(&mm->mmap_sem);
-		if (user_mode(regs))
-			return;
+		return;
 	}
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index f4ea4c62c613..743077d19669 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -308,14 +308,20 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (fault & VM_FAULT_RETRY) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
-		return 0;
+		else if (signal_pending(current))
+			/*
+			 * It's either a common signal, or a fatal
+			 * signal but for the userspace, we return
+			 * immediately.
+			 */
+			return 0;
 	}
 
 	/*
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 7d9571f4ae3d..744d6451ea83 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -499,13 +499,13 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 
 	if (fault & VM_FAULT_RETRY) {
 		/*
-		 * If we need to retry but a fatal signal is pending,
+		 * If we need to retry but a signal is pending,
 		 * handle the signal first. We do not need to release
 		 * the mmap_sem because it would already be released
 		 * in __lock_page_or_retry in mm/filemap.c.
 		 */
-		if (fatal_signal_pending(current)) {
-			if (!user_mode(regs))
+		if (signal_pending(current)) {
+			if (fatal_signal_pending(current) && !user_mode(regs))
 				goto no_context;
 			return 0;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index eb263e61daf4..be10b441d9cc 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -104,7 +104,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	/* The most common case -- we are done. */
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 5baeb022f474..62c2d39d2bed 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -163,7 +163,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 9b6163c05a75..d9808a807ab8 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -138,7 +138,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	fault = handle_mm_fault(vma, address, flags);
 	pr_debug("handle_mm_fault returns %x\n", fault);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 202ad6a494f5..4fd2dbd0c5ca 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -217,7 +217,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 73d8a0f0b810..92374fd091d2 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -154,7 +154,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index b740534b152c..72461745d3e1 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -207,12 +207,12 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (fault & VM_FAULT_RETRY && signal_pending(current)) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
 		return;
 	}
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 24fd84cf6006..5939434a31ae 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -134,7 +134,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index dc4dbafc1d83..873ecb5d82d7 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -165,7 +165,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index c8e8b7c05558..29422eec329d 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -303,7 +303,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 1697e903bbf2..8bc0d091f13c 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -575,8 +575,10 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 			 */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
-			if (!fatal_signal_pending(current))
+			if (!signal_pending(current))
 				goto retry;
+			else if (!fatal_signal_pending(current) && is_user)
+				return 0;
 		}
 
 		/*
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 88401d5125bc..4fc8d746bec3 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -123,11 +123,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(tsk))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 2b8f32f56e0c..19b4fb2fafab 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -500,9 +500,12 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 	 * the fault.
 	 */
 	fault = handle_mm_fault(vma, address, flags);
-	/* No reason to continue if interrupted by SIGKILL. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		fault = VM_FAULT_SIGNAL;
+	/* Do not continue if interrupted by signals. */
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+		if (fatal_signal_pending(current))
+			fault = VM_FAULT_SIGNAL;
+		else
+			fault = 0;
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_up;
 		goto out;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6defd2c6d9b1..baf5d73df40c 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -506,6 +506,10 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 			 * have already released it in __lock_page_or_retry
 			 * in mm/filemap.c.
 			 */
+
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index b0440b0edd97..a2c83104fe35 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -269,6 +269,9 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 8f8a604c1300..cad71ec5c7b3 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -467,6 +467,9 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 0e8b6158f224..09baf37b65b9 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -76,8 +76,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 
 		fault = handle_mm_fault(vma, address, flags);
 
-		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		if (fault & VM_FAULT_RETRY && signal_pending(current)) {
+			if (is_user && !fatal_signal_pending(current))
+				err = 0;
 			goto out_nosemaphore;
+		}
 
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index b9a3a50644c1..3611f19234a1 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -248,11 +248,11 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_pf(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_RETRY)) {
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 71d4b9d4d43f..b94ef0c2b98c 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1433,8 +1433,18 @@ void do_user_addr_fault(struct pt_regs *regs,
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
-			if (!fatal_signal_pending(tsk))
+			if (!signal_pending(tsk))
 				goto retry;
+			else if (!fatal_signal_pending(tsk))
+				/*
+				 * There is a signal for the task but
+				 * it's not fatal, let's return
+				 * directly to the userspace.  This
+				 * gives chance for signals like
+				 * SIGSTOP/SIGCONT to be handled
+				 * faster, e.g., with GDB.
+				 */
+				return;
 		}
 
 		/* User mode? Just return to handle the fatal exception */
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 2ab0e0dcd166..792dad5e2f12 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -136,6 +136,9 @@ void do_page_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 356d2b8568c1..249c9211b2ed 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -515,30 +515,6 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
 	__set_current_state(TASK_RUNNING);
 
-	if (return_to_userland) {
-		if (signal_pending(current) &&
-		    !fatal_signal_pending(current)) {
-			/*
-			 * If we got a SIGSTOP or SIGCONT and this is
-			 * a normal userland page fault, just let
-			 * userland return so the signal will be
-			 * handled and gdb debugging works.  The page
-			 * fault code immediately after we return from
-			 * this function is going to release the
-			 * mmap_sem and it's not depending on it
-			 * (unlike gup would if we were not to return
-			 * VM_FAULT_RETRY).
-			 *
-			 * If a fatal signal is pending we still take
-			 * the streamlined VM_FAULT_RETRY failure path
-			 * and there's no need to retake the mmap_sem
-			 * in such case.
-			 */
-			down_read(&mm->mmap_sem);
-			ret = VM_FAULT_NOPAGE;
-		}
-	}
-
 	/*
 	 * Here we race with the list_del; list_add in
 	 * userfaultfd_ctx_read(), however because we don't ever run
-- 
2.17.1
