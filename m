Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0936B2489
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:21:46 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so2481563qtj.21
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:21:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f70si2053473qke.10.2018.11.20.22.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 22:21:45 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC v3 3/4] mm: allow VM_FAULT_RETRY for multiple times
Date: Wed, 21 Nov 2018 14:21:02 +0800
Message-Id: <20181121062103.18835-4-peterx@redhat.com>
In-Reply-To: <20181121062103.18835-1-peterx@redhat.com>
References: <20181121062103.18835-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>

The idea comes from a discussion between Linus and Andrea [1].

Before this patch we only allow a page fault to retry once.  We achieved
this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
handle_mm_fault() the second time.  This was majorly used to avoid
unexpected starvation of the system by looping over forever to handle
the page fault on a single page.  However that should hardly happen, and
after all for each code path to return a VM_FAULT_RETRY we'll first wait
for a condition (during which time we should possibly yield the cpu) to
happen before VM_FAULT_RETRY is really returned.

This patch removes the restriction by keeping the FAULT_FLAG_ALLOW_RETRY
flag when we receive VM_FAULT_RETRY.  It means that the page fault
handler now can retry the page fault for multiple times if necessary
without the need to generate another page fault event. Meanwhile we
still keep the FAULT_FLAG_TRIED flag so page fault handler can still
identify whether a page fault is the first attempt or not.

GUP code is not touched yet and will be covered in follow up patch.

This will be a nice enhancement for current code at the same time a
supporting material for the future userfaultfd-writeprotect work since
in that work there will always be an explicit userfault writeprotect
retry for protected pages, and if that cannot resolve the page
fault (e.g., when userfaultfd-writeprotect is used in conjunction with
shared memory) then we'll possibly need a 3rd retry of the page fault.
It might also benefit other potential users who will have similar
requirement like userfault write-protection.

Please read the thread below for more information.

[1] https://lkml.org/lkml/2017/11/2/833

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c      | 2 +-
 arch/arc/mm/fault.c        | 1 -
 arch/arm/mm/fault.c        | 3 ---
 arch/arm64/mm/fault.c      | 5 -----
 arch/hexagon/mm/vm_fault.c | 1 -
 arch/ia64/mm/fault.c       | 1 -
 arch/m68k/mm/fault.c       | 3 ---
 arch/microblaze/mm/fault.c | 1 -
 arch/mips/mm/fault.c       | 1 -
 arch/nds32/mm/fault.c      | 1 -
 arch/nios2/mm/fault.c      | 3 ---
 arch/openrisc/mm/fault.c   | 1 -
 arch/parisc/mm/fault.c     | 2 --
 arch/powerpc/mm/fault.c    | 5 -----
 arch/riscv/mm/fault.c      | 5 -----
 arch/s390/mm/fault.c       | 5 +----
 arch/sh/mm/fault.c         | 1 -
 arch/sparc/mm/fault_32.c   | 1 -
 arch/sparc/mm/fault_64.c   | 1 -
 arch/um/kernel/trap.c      | 1 -
 arch/unicore32/mm/fault.c  | 6 +-----
 arch/x86/mm/fault.c        | 1 -
 arch/xtensa/mm/fault.c     | 1 -
 23 files changed, 3 insertions(+), 49 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 46e5e420ad2a..deae82bb83c1 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -169,7 +169,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 52b6b71b74e2..a8b02db45324 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -168,7 +168,6 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 			}
 
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 				goto retry;
 			}
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 743077d19669..377781d8491a 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -342,9 +342,6 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 					regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 744d6451ea83..8a26e03fc2bf 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -510,12 +510,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 			return 0;
 		}
 
-		/*
-		 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk of
-		 * starvation.
-		 */
 		if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
-			mm_flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			mm_flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index be10b441d9cc..576751597e77 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -115,7 +115,6 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 				goto retry;
 			}
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 62c2d39d2bed..9de95d39935e 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -189,7 +189,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index d9808a807ab8..b1b2109e4ab4 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -162,9 +162,6 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 4fd2dbd0c5ca..05a4847ac0bf 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -236,7 +236,6 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 92374fd091d2..9953b5b571df 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -178,7 +178,6 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 			tsk->min_flt++;
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 72461745d3e1..f0b775cb5cdf 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -237,7 +237,6 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 5939434a31ae..9dd1c51acc22 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -158,9 +158,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 873ecb5d82d7..ff92c5674781 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -185,7 +185,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 29422eec329d..7d3e96a9a7ab 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -327,8 +327,6 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
-
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 8bc0d091f13c..8bdc7e75d2e5 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -569,11 +569,6 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (unlikely(fault & VM_FAULT_RETRY)) {
 		/* We retry only once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			if (!signal_pending(current))
 				goto retry;
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 4fc8d746bec3..aad2c0557d2f 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -154,11 +154,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 				      1, regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &= ~(FAULT_FLAG_ALLOW_RETRY);
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 19b4fb2fafab..819f87169ee1 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -537,10 +537,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 				fault = VM_FAULT_PFAULT;
 				goto out_up;
 			}
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~(FAULT_FLAG_ALLOW_RETRY |
-				   FAULT_FLAG_RETRY_NOWAIT);
+			flags &= ~FAULT_FLAG_RETRY_NOWAIT;
 			flags |= FAULT_FLAG_TRIED;
 			down_read(&mm->mmap_sem);
 			goto retry;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index baf5d73df40c..cd710e2d7c57 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -498,7 +498,6 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 				      regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index a2c83104fe35..6735cd1c09b9 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -261,7 +261,6 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index cad71ec5c7b3..28d5b4d012c6 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -459,7 +459,6 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 09baf37b65b9..c63fc292aea0 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -99,7 +99,6 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 
 				goto retry;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 3611f19234a1..fdf577956f5f 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -260,12 +260,8 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 			tsk->maj_flt++;
 		else
 			tsk->min_flt++;
-		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+		if (fault & VM_FAULT_RETRY)
 			goto retry;
-		}
 	}
 
 	up_read(&mm->mmap_sem);
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index b94ef0c2b98c..645b1365a72d 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1431,7 +1431,6 @@ void do_user_addr_fault(struct pt_regs *regs,
 	if (unlikely(fault & VM_FAULT_RETRY)) {
 		/* Retry at most once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			if (!signal_pending(tsk))
 				goto retry;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 792dad5e2f12..7cd55f2d66c9 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -128,7 +128,6 @@ void do_page_fault(struct pt_regs *regs)
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
-- 
2.17.1
