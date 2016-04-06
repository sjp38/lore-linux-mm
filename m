Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 139AE6B0262
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:29 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id c20so42397790pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qn9si7245269pab.159.2016.04.06.15.51.26
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 02/30] mm: do not pass mm_struct into handle_mm_fault
Date: Thu,  7 Apr 2016 01:50:52 +0300
Message-Id: <1459983080-106718-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
 drivers/iommu/amd_iommu_v2.c  |  3 +--
 drivers/iommu/intel-svm.c     |  2 +-
 include/linux/mm.h            |  9 ++++-----
 mm/gup.c                      |  5 ++---
 mm/ksm.c                      |  5 ++---
 mm/memory.c                   | 13 +++++++------
 36 files changed, 48 insertions(+), 51 deletions(-)

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
index ad5841856007..3a2e678b8d30 100644
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
index 95df28bc875f..4dbb076b9e1f 100644
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
index 26fac9c671c9..f27c74cbed6e 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -238,7 +238,7 @@ good_area:
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
index cce577feab1e..a9524531320e 100644
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
index b6c559cbd64d..4714061d6cd3 100644
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
index 26734214818c..beba986589e5 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -434,7 +434,7 @@ good_area:
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
index 2ec3d3adcefc..6c7f70bcaae3 100644
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
index 5ce1ed02f7e8..2915b5b7bd7e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1348,7 +1348,7 @@ good_area:
 	 * the fault.  Since we never set FAULT_FLAG_RETRY_NOWAIT, if
 	 * we get VM_FAULT_RETRY back, the mmap_sem has been unlocked.
 	 */
-	fault = handle_mm_fault(mm, vma, address, flags);
+	fault = handle_mm_fault(vma, address, flags);
 	major |= fault & VM_FAULT_MAJOR;
 
 	/*
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 7f4a1fdb1502..2725e08ef353 100644
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
index 56999d2fac07..fbdaf81ae925 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -538,8 +538,7 @@ static void do_fault(struct work_struct *work)
 	if (access_error(vma, fault))
 		goto out;
 
-	ret = handle_mm_fault(mm, vma, address, flags);
-
+	ret = handle_mm_fault(vma, address, flags);
 out:
 	up_read(&mm->mmap_sem);
 
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index d9939fa9b588..8ebb3530afa7 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -583,7 +583,7 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		if (access_error(vma, req))
 			goto invalid;
 
-		ret = handle_mm_fault(svm->mm, vma, address,
+		ret = handle_mm_fault(vma, address,
 				      req->wr_req ? FAULT_FLAG_WRITE : 0);
 		if (ret & VM_FAULT_ERROR)
 			goto invalid;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffcff53e3b2b..8fc68ed3c862 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1214,15 +1214,14 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, unsigned int flags);
+extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+		unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
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
index fb87aea9edc8..39f751e1cb33 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -351,7 +351,6 @@ unmap:
 static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	unsigned int fault_flags = 0;
 	int ret;
 
@@ -376,7 +375,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
 			return -ENOMEM;
@@ -691,7 +690,7 @@ retry:
 	if (!vma_permits_fault(vma, fault_flags))
 		return -EFAULT;
 
-	ret = handle_mm_fault(mm, vma, address, fault_flags);
+	ret = handle_mm_fault(vma, address, fault_flags);
 	major |= ret & VM_FAULT_MAJOR;
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
diff --git a/mm/ksm.c b/mm/ksm.c
index b99e828172f6..c967d1b8df97 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -376,9 +376,8 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
-			ret = handle_mm_fault(vma->vm_mm, vma, addr,
-							FAULT_FLAG_WRITE |
-							FAULT_FLAG_REMOTE);
+			ret = handle_mm_fault(vma, addr,
+					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index a718786983c2..195262f40e32 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3370,9 +3370,10 @@ unlock:
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
@@ -3459,15 +3460,15 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -3479,7 +3480,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
-	ret = __handle_mm_fault(mm, vma, address, flags);
+	ret = __handle_mm_fault(vma, address, flags);
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
