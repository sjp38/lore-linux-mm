Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB2D5F0001
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 15:46:15 -0400 (EDT)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id n3DJktpG024985
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 20:46:55 +0100
Received: from gxk28 (gxk28.prod.google.com [10.202.11.28])
	by spaceape7.eur.corp.google.com with ESMTP id n3DJkr0V005606
	for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:46:54 -0700
Received: by gxk28 with SMTP id 28so4581087gxk.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2009 12:46:53 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Apr 2009 12:46:53 -0700
Message-ID: <604427e00904131246i2edc7abdy808decc5f8b83d6d@mail.gmail.com>
Subject: [v4][PATCH 2/4]Move FAULT_FLAG_xyz into handle_mm_fault() callers
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Move FAULT_FLAG_xyz into handle_mm_fault() callers

This allows the callers to now pass down the full set of FAULT_FLAG_xyz
flags to handle_mm_fault().  All callers have been converted to the new
calling convention, there's almost certainly room for architectures to
clean up their code and then add FAULT_FLAG_RETRY when that support is added.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Ying Han <yinghan@google.com>
---

 arch/alpha/mm/fault.c                   |    3 ++-
 arch/arm/mm/fault.c                     |    3 ++-
 arch/avr32/mm/fault.c                   |    3 ++-
 arch/cris/mm/fault.c                    |    3 ++-
 arch/frv/mm/fault.c                     |    2 +-
 arch/ia64/mm/fault.c                    |    3 ++-
 arch/m32r/mm/fault.c                    |    2 +-
 arch/m68k/mm/fault.c                    |    2 +-
 arch/mips/mm/fault.c                    |    2 +-
 arch/mn10300/mm/fault.c                 |    2 +-
 arch/parisc/mm/fault.c                  |    3 ++-
 arch/powerpc/mm/fault.c                 |    3 ++-
 arch/powerpc/platforms/cell/spu_fault.c |    2 +-
 arch/s390/lib/uaccess_pt.c              |    3 ++-
 arch/s390/mm/fault.c                    |    2 +-
 arch/sh/mm/fault_32.c                   |    3 ++-
 arch/sh/mm/tlbflush_64.c                |    3 ++-
 arch/sparc/mm/fault_32.c                |    5 +++--
 arch/sparc/mm/fault_64.c                |    3 ++-
 arch/um/kernel/trap.c                   |    3 ++-
 arch/x86/mm/fault.c                     |    2 +-
 arch/xtensa/mm/fault.c                  |    3 ++-
 include/linux/mm.h                      |    4 ++--
 mm/memory.c                             |    5 +++--
 24 files changed, 42 insertions(+), 27 deletions(-)


diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 4829f96..9dfa449 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -146,7 +146,8 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	/* If for any reason at all we couldn't handle the fault,
 	   make sure we exit gracefully rather than endlessly redo
 	   the fault.  */
-	fault = handle_mm_fault(mm, vma, address, cause > 0);
+	fault = handle_mm_fault(mm, vma, address,
+			cause > 0 ? FAULT_FLAG_WRITE : 0);
 	up_read(&mm->mmap_sem);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 0455557..638335c 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -208,7 +208,8 @@ good_area:
 	 * than endlessly redo the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK, fsr & (1 << 11));
+	fault = handle_mm_fault(mm, vma, addr & PAGE_MASK,
+			(fsr & (1 << 11)) ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/avr32/mm/fault.c b/arch/avr32/mm/fault.c
index ce4e429..a53553e 100644
--- a/arch/avr32/mm/fault.c
+++ b/arch/avr32/mm/fault.c
@@ -133,7 +133,8 @@ good_area:
 	 * fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	fault = handle_mm_fault(mm, vma, address,
+			writeaccess ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/cris/mm/fault.c b/arch/cris/mm/fault.c
index c4c76db..59b01c7 100644
--- a/arch/cris/mm/fault.c
+++ b/arch/cris/mm/fault.c
@@ -163,7 +163,8 @@ do_page_fault(unsigned long address, struct pt_regs *regs,
 	 * the fault.
 	 */

-	fault = handle_mm_fault(mm, vma, address, writeaccess & 1);
+	fault = handle_mm_fault(mm, vma, address,
+			(writeaccess & 1) ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/frv/mm/fault.c b/arch/frv/mm/fault.c
index 05093d4..30f5d10 100644
--- a/arch/frv/mm/fault.c
+++ b/arch/frv/mm/fault.c
@@ -163,7 +163,7 @@ asmlinkage void do_page_fault(int datammu, unsigned long esr
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, ear0, write);
+	fault = handle_mm_fault(mm, vma, ear0, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 23088be..5add87f 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -154,7 +154,8 @@ ia64_do_page_fault (unsigned long address, unsigned long isr
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, (mask & VM_WRITE) != 0);
+	fault = handle_mm_fault(mm, vma, address,
+			(mask & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We ran out of memory, or some other thing happened
diff --git a/arch/m32r/mm/fault.c b/arch/m32r/mm/fault.c
index 4a71df4..7274b47 100644
--- a/arch/m32r/mm/fault.c
+++ b/arch/m32r/mm/fault.c
@@ -196,7 +196,7 @@ survive:
 	 */
 	addr = (address & PAGE_MASK);
 	set_thread_fault_code(error_code);
-	fault = handle_mm_fault(mm, vma, addr, write);
+	fault = handle_mm_fault(mm, vma, addr, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index f493f03..d0e35cf 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -155,7 +155,7 @@ good_area:
 	 */

  survive:
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 #ifdef DEBUG
 	printk("handle_mm_fault returns %d\n",fault);
 #endif
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 55767ad..6751ce9 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -102,7 +102,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/mn10300/mm/fault.c b/arch/mn10300/mm/fault.c
index 33cf250..a62e1e1 100644
--- a/arch/mn10300/mm/fault.c
+++ b/arch/mn10300/mm/fault.c
@@ -258,7 +258,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 92c7fa4..987bbfe 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -202,7 +202,8 @@ good_area:
 	 * fault.
 	 */

-	fault = handle_mm_fault(mm, vma, address, (acc_type & VM_WRITE) != 0);
+	fault = handle_mm_fault(mm, vma, address,
+			(acc_type & VM_WRITE) ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		/*
 		 * We hit a shared mapping outside of the file, or some
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 91c7b86..96a4aaf 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -311,7 +311,8 @@ good_area:
 	 * the fault.
 	 */
  survive:
-	ret = handle_mm_fault(mm, vma, address, is_write);
+	ret = handle_mm_fault(mm, vma, address,
+			is_write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(ret & VM_FAULT_ERROR)) {
 		if (ret & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/powerpc/platforms/cell/spu_fault.c b/arch/powerpc/platforms/ce
index c8b1cd4..3b934a0 100644
--- a/arch/powerpc/platforms/cell/spu_fault.c
+++ b/arch/powerpc/platforms/cell/spu_fault.c
@@ -73,7 +73,7 @@ good_area:
 			goto bad_area;
 	}
 	ret = 0;
-	*flt = handle_mm_fault(mm, vma, ea, is_write);
+	*flt = handle_mm_fault(mm, vma, ea, is_write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(*flt & VM_FAULT_ERROR)) {
 		if (*flt & VM_FAULT_OOM) {
 			ret = -ENOMEM;
diff --git a/arch/s390/lib/uaccess_pt.c b/arch/s390/lib/uaccess_pt.c
index d66215b..4ee9d99 100644
--- a/arch/s390/lib/uaccess_pt.c
+++ b/arch/s390/lib/uaccess_pt.c
@@ -66,7 +66,8 @@ static int __handle_fault(struct mm_struct *mm, unsigned long
 	}

 survive:
-	fault = handle_mm_fault(mm, vma, address, write_access);
+	fault = handle_mm_fault(mm, vma, address,
+			write_access ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 4d53720..f08f3c3 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -375,7 +375,7 @@ survive:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM) {
 			if (do_out_of_memory(regs, error_code, address))
diff --git a/arch/sh/mm/fault_32.c b/arch/sh/mm/fault_32.c
index 31a33eb..78d2f8c 100644
--- a/arch/sh/mm/fault_32.c
+++ b/arch/sh/mm/fault_32.c
@@ -133,7 +133,8 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	fault = handle_mm_fault(mm, vma, address,
+			writeaccess ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index 7876997..5ee5d95 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -187,7 +187,8 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address, writeaccess);
+	fault = handle_mm_fault(mm, vma, address,
+			writeaccess ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 12e447f..69ca75e 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -241,7 +241,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
@@ -484,7 +484,8 @@ good_area:
 		if(!(vma->vm_flags & (VM_READ | VM_EXEC)))
 			goto bad_area;
 	}
-	switch (handle_mm_fault(mm, vma, address, write)) {
+	switch (handle_mm_fault(mm, vma, address,
+				write ? FAULT_FLAG_WRITE : 0)) {
 	case VM_FAULT_SIGBUS:
 	case VM_FAULT_OOM:
 		goto do_sigbus;
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 4ab8993..539e829 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -398,7 +398,8 @@ good_area:
 			goto bad_area;
 	}

-	fault = handle_mm_fault(mm, vma, address, (fault_code & FAULT_CODE_WRITE));
+	fault = handle_mm_fault(mm, vma, address,
+			(fault_code & FAULT_CODE_WRITE) ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 7384d8a..87d7a5e 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -65,7 +65,8 @@ good_area:
 	do {
 		int fault;

-		fault = handle_mm_fault(mm, vma, address, is_write);
+		fault = handle_mm_fault(mm, vma, address,
+				is_write ? FAULT_FLAG_WRITE : 0);
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
 				goto out_of_memory;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index c76ef1d..63c1427 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -740,7 +740,7 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault.
 	 */
-	fault = handle_mm_fault(mm, vma, address, write);
+	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index bdd860d..abea2d7 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -106,7 +106,8 @@ good_area:
 	 * the fault.
 	 */
 survive:
-	fault = handle_mm_fault(mm, vma, address, is_write);
+	fault = handle_mm_fault(mm, vma, address,
+			is_write ? FAULT_FLAG_WRITE : 0);
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		if (fault & VM_FAULT_OOM)
 			goto out_of_memory;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065cdf8..9d22a5e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -808,11 +808,11 @@ extern int vmtruncate_range(struct inode * inode, loff_t o

 #ifdef CONFIG_MMU
 extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access);
+			unsigned long address, unsigned int flags);
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
-			int write_access)
+			unsigned init flags)
 {
 	/* should never happen if there's no MMU */
 	BUG();
diff --git a/mm/memory.c b/mm/memory.c
index bfecdfb..98fcc63 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1305,6 +1305,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_st
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
+
+				/* FOLL_WRITE matches FAULT_FLAG_WRITE */
 				ret = handle_mm_fault(mm, vma, start,
 						foll_flags & FOLL_WRITE);
 				if (ret & VM_FAULT_ERROR) {
@@ -2842,13 +2844,12 @@ unlock:
  * By the time we get here, we already hold the mm semaphore
  */
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, int write_access)
+		unsigned long address, unsigned int flags)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
-	unsigned int flags = write_access ? FAULT_FLAG_WRITE : 0;

 	__set_current_state(TASK_RUNNING);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
