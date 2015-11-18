Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE8C6B0260
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:26:15 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so59459520pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:26:14 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id cv1si7500794pbb.202.2015.11.18.15.26.13
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:26:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/9] mm: do not pass mm_struct into handle_mm_fault
Date: Thu, 19 Nov 2015 01:25:28 +0200
Message-Id: <1447889136-6928-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We always have vma->vm_mm around.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/alpha/mm/fault.c         |  2 +-
 arch/arc/mm/fault.c           |  2 +-
 arch/arm/mm/fault.c           |  2 +-
 arch/arm64/mm/fault.c         |  2 +-
 arch/avr32/mm/fault.c         |  2 +-
 arch/cris/mm/fault.c          |  2 +-
 arch/frv/mm/fault.c           |  2 +-
 arch/hexagon/mm/vm_fault.c    |  2 +-
 arch/ia64/mm/fault.c          |  2 +-
 arch/m32r/mm/fault.c          |  2 +-
 arch/m68k/mm/fault.c          |  2 +-
 arch/metag/mm/fault.c         |  2 +-
 arch/microblaze/mm/fault.c    |  2 +-
 arch/mips/mm/fault.c          |  2 +-
 arch/mn10300/mm/fault.c       |  2 +-
 arch/nios2/mm/fault.c         |  2 +-
 arch/openrisc/mm/fault.c      |  2 +-
 arch/parisc/mm/fault.c        |  2 +-
 arch/powerpc/mm/copro_fault.c |  2 +-
 arch/powerpc/mm/fault.c       |  2 +-
 arch/s390/mm/fault.c          |  2 +-
 arch/score/mm/fault.c         |  2 +-
 arch/sh/mm/fault.c            |  2 +-
 arch/sparc/mm/fault_32.c      |  4 ++--
 arch/sparc/mm/fault_64.c      |  2 +-
 arch/tile/mm/fault.c          |  2 +-
 arch/um/kernel/trap.c         |  2 +-
 arch/unicore32/mm/fault.c     |  2 +-
 arch/x86/mm/fault.c           |  2 +-
 arch/xtensa/mm/fault.c        |  2 +-
 drivers/iommu/amd_iommu_v2.c  |  2 +-
 include/linux/mm.h            |  9 ++++-----
 mm/gup.c                      |  5 ++---
 mm/ksm.c                      |  3 +--
 mm/memory.c                   | 13 +++++++------
 35 files changed, 46 insertions(+), 48 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 4a905bd667e2..83e9eee57a55 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -147,7 +147,7 @@ retry:
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index af63f4a13e60..e94e5aa33985 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -137,7 +137,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	/* If Pagefault was interrupted by SIGKILL, exit page fault "early" */
 	if (unlikely(fatal_signal_pending(current))) {
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index daafcf121ce0..7cd0d5b2ef50 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -243,7 +243,7 @@ good_area:
 		goto out;
 	}
 
-	return handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
+	return handle_mm_fault(vma, addr & PAGE_MASK, flags);
 
 check_stack:
 	/* Don't allow expansion below FIRST_USER_ADDRESS */
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 19211c4a8911..987e9956fb98 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -183,7 +183,7 @@ good_area:
 		goto out;
 	}
 
-	return handle_mm_fault(mm, vma, addr & PAGE_MASK, mm_flags);
+	return handle_mm_fault(vma, addr & PAGE_MASK, mm_flags);
 
 check_stack:
 	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index c03533937a9f..a4b7edac8f10 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -134,7 +134,7 @@ good_area:
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index 3066d40a6db1..112ef26c7f2e 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -168,7 +168,7 @@ retry:
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index 61d99767fe16..614a46c413d2 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -164,7 +164,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr0, unsigned long ear
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, flags);
+	fault = handle_mm_fault(vma, ear0, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 8704c9320032..bd7c251e2bce 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -101,7 +101,7 @@ good_area:
 		break;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 70b40d1205a6..fa6ad95e992e 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -159,7 +159,7 @@ retry:
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 8f9875b7933d..a3785d3644c2 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -196,7 +196,7 @@ good_area:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, flags);
+	fault = handle_mm_fault(vma, addr, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 6a94cdd0c830..bd66a0b20c6b 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -136,7 +136,7 @@ good_area:
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	pr_debug("handle_mm_fault returns %d\n", fault);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
diff --git a/arch/metag/mm/fault.c b/arch/metag/mm/fault.c
index f57edca63609..372783a67dda 100644
--- a/arch/metag/mm/fault.c
+++ b/arch/metag/mm/fault.c
@@ -133,7 +133,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return 0;
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 177dfc003643..abb678ccde6f 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -216,7 +216,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 4b88fa031891..9560ad731120 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -153,7 +153,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 4a1d181ed32f..f23781d6bbb3 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -254,7 +254,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index b51878b0c6b8..affc4eb3f89e 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -131,7 +131,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 230ac20ae794..e94cd225e816 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -163,7 +163,7 @@ good_area:
 	 * the fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index a762864ec92e..87436cd7ea1a 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -243,7 +243,7 @@ good_area:
 	 * fault.
 	 */
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 6527882ce05e..bb0354222b11 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -75,7 +75,7 @@ int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
 	}
 
 	ret = 0;
-	*flt = handle_mm_fault(mm, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
+	*flt = handle_mm_fault(vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index a67c6d781c52..a4db22f65021 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -429,7 +429,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
 		if (fault & VM_FAULT_SIGSEGV)
 			goto bad_area;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index ec1a30d0d11a..9579c92e35b9 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -455,7 +455,7 @@ retry:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	/* No reason to continue if interrupted by SIGKILL. */
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
 		fault = VM_FAULT_SIGNAL;
diff --git a/arch/score/mm/fault.c b/arch/score/mm/fault.c
index 37a6c2e0e969..995b71e4db4b 100644
--- a/arch/score/mm/fault.c
+++ b/arch/score/mm/fault.c
@@ -111,7 +111,7 @@ good_area:
 	* make sure we exit gracefully rather than endlessly redo
 	* the fault.
 	*/
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 79d8276377d1..9bf876780cef 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -487,7 +487,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if (unlikely(fault & (VM_FAULT_RETRY | VM_FAULT_ERROR)))
 		if (mm_fault_error(regs, error_code, address, fault))
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index c399e7b3b035..3d2d6686d8e9 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -241,7 +241,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
@@ -411,7 +411,7 @@ good_area:
 		if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
-	switch (handle_mm_fault(mm, vma, address, flags)) {
+	switch (handle_mm_fault(vma, address, flags)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index cb841a33da59..6c43b924a7a2 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -436,7 +436,7 @@ good_area:
 			goto bad_area;
 	}
 
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		goto exit_exception;
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 13eac59bf16a..4be04f649396 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -435,7 +435,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return 0;
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 98783dd0fa2e..ad8f206ab5e8 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -73,7 +73,7 @@ good_area:
 	do {
 		int fault;
 
-		fault = handle_mm_fault(mm, vma, address, flags);
+		fault = handle_mm_fault(vma, address, flags);
 
 		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 			goto out_nosemaphore;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index afccef5529cc..43c84cb70fc7 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -194,7 +194,7 @@ good_area:
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, flags);
+	fault = handle_mm_fault(vma, addr & PAGE_MASK, flags);
 	return fault;
 
 check_stack:
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index eef44d9a3f77..d01fd75adfcb 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1235,7 +1235,7 @@ good_area:
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index c9784c1b18d8..551bba2c9ed8 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -110,7 +110,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 
 	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
 		return;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index d21d4edf7236..64c997a59e84 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -523,7 +523,7 @@ static void do_fault(struct work_struct *work)
 		goto out;
 	}
 
-	ret = handle_mm_fault(mm, vma, address, write);
+	ret = handle_mm_fault(vma, address, write);
 	if (ret & VM_FAULT_ERROR) {
 		/* failed to service fault */
 		up_read(&mm->mmap_sem);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6fccda2280e4..065ee44366ea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1232,14 +1232,13 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags);
 #else
-static inline int handle_mm_fault(struct mm_struct *mm,
-			struct vm_area_struct *vma, unsigned long address,
-			unsigned int flags)
+static inline int handle_mm_fault(struct vm_area_struct *vma,
+		unsigned long address, unsigned int flags)
 {
 	/* should never happen if there's no MMU */
 	BUG();
diff --git a/mm/gup.c b/mm/gup.c
index e95b0cb6ed81..06499f8ecd49 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -323,7 +323,6 @@ unmap:
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned int fault_flags = 0;
 	int ret;
 
@@ -346,7 +345,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
 			return -ENOMEM;
@@ -627,7 +626,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!(vm_flags & vma->vm_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
 			return -ENOMEM;
diff --git a/mm/ksm.c b/mm/ksm.c
index 30cb0f753e19..6221f5b65736 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -371,8 +371,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
-			ret = handle_mm_fault(vma->vm_mm, vma, addr,
-							FAULT_FLAG_WRITE);
+			ret = handle_mm_fault(vma, addr, FAULT_FLAG_WRITE);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index b11c0bcf7058..1ffc61505f43 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3339,9 +3339,10 @@ unlock:
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			     unsigned long address, unsigned int flags)
+static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -3414,15 +3415,15 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		    unsigned long address, unsigned int flags)
+int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags)
 {
 	int ret;
 
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
-	mem_cgroup_count_vm_event(mm, PGFAULT);
+	mem_cgroup_count_vm_event(vma->vm_mm, PGFAULT);
 
 	/* do counter updates before entering really critical section. */
 	check_sync_rss_stat(current);
@@ -3434,7 +3435,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
-	ret = __handle_mm_fault(mm, vma, address, flags);
+	ret = __handle_mm_fault(vma, address, flags);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
