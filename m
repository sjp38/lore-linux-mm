Message-Id: <20061019102309.179968000@chello.nl>
References: <20061019101722.805147000@chello.nl>
Date: Thu, 19 Oct 2006 12:17:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/4] mm: arch do_page_fault() vs in_atomic()
Content-Disposition: inline; filename=inatomic_do_page_fault.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

In light of the recent pagefault and filemap_copy_from_user work I've
gone through all the arch pagefault handlers to make sure the 
inc_preempt_count() 'feature' works as expected.

Several sections of code (including the new filemap_copy_from_user) rely
on the fact that faults do not take locks under increased preempt count.

arch/x86_64 - good
arch/powerpc - good
arch/cris - fixed
arch/i386 - good
arch/parisc - fixed
arch/sh - good
arch/sparc - good
arch/s390 - good
arch/m68k - fixed
arch/ppc - good
arch/alpha - fixed
arch/mips - good
arch/sparc64 - good
arch/ia64 - good
arch/arm - fixed
arch/um - NA
arch/avr32 - good
arch/h8300 - NA
arch/m32r - good
arch/v850 - good
arch/frv - fixed
arch/m68knommu - NA
arch/arm26 - fixed
arch/sh64 - fixed
arch/xtensa - good

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/mm/fault.c  |    2 +-
 arch/arm/mm/fault.c    |    2 +-
 arch/arm26/mm/fault.c  |    2 +-
 arch/cris/mm/fault.c   |    2 +-
 arch/frv/mm/fault.c    |    2 +-
 arch/m68k/mm/fault.c   |    2 +-
 arch/parisc/mm/fault.c |    2 +-
 arch/sh64/mm/fault.c   |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

Index: linux-2.6/arch/alpha/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/alpha/mm/fault.c
+++ linux-2.6/arch/alpha/mm/fault.c
@@ -108,7 +108,7 @@ do_page_fault(unsigned long address, uns
 
 	/* If we're in an interrupt context, or have no user context,
 	   we must not take the fault.  */
-	if (!mm || in_interrupt())
+	if (!mm || in_atomic())
 		goto no_context;
 
 #ifdef CONFIG_ALPHA_LARGE_VMALLOC
Index: linux-2.6/arch/arm/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/fault.c
+++ linux-2.6/arch/arm/mm/fault.c
@@ -230,7 +230,7 @@ do_page_fault(unsigned long addr, unsign
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	/*
Index: linux-2.6/arch/arm26/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/arm26/mm/fault.c
+++ linux-2.6/arch/arm26/mm/fault.c
@@ -215,7 +215,7 @@ int do_page_fault(unsigned long addr, un
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/cris/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/cris/mm/fault.c
+++ linux-2.6/arch/cris/mm/fault.c
@@ -232,7 +232,7 @@ do_page_fault(unsigned long address, str
 	 * context, we must not take the fault..
 	 */
 
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/frv/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/fault.c
+++ linux-2.6/arch/frv/mm/fault.c
@@ -78,7 +78,7 @@ asmlinkage void do_page_fault(int datamm
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/m68k/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/m68k/mm/fault.c
+++ linux-2.6/arch/m68k/mm/fault.c
@@ -99,7 +99,7 @@ int do_page_fault(struct pt_regs *regs, 
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/parisc/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/parisc/mm/fault.c
+++ linux-2.6/arch/parisc/mm/fault.c
@@ -152,7 +152,7 @@ void do_page_fault(struct pt_regs *regs,
 	const struct exception_table_entry *fix;
 	unsigned long acc_type;
 
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	down_read(&mm->mmap_sem);
Index: linux-2.6/arch/sh64/mm/fault.c
===================================================================
--- linux-2.6.orig/arch/sh64/mm/fault.c
+++ linux-2.6/arch/sh64/mm/fault.c
@@ -154,7 +154,7 @@ asmlinkage void do_page_fault(struct pt_
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 	/* TLB misses upon some cache flushes get done under cli() */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
