Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 607FD6B0070
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:26:32 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:26:30 -0400 (EDT)
Message-Id: <20121002.182630.2161021394486461561.davem@davemloft.net>
Subject: [PATCH 2/8] sparc64: Halve the size of PTE tables.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


The reason we want to do this is to facilitate transparent huge page
support.

Right now PMD's cover 8MB of address space, and our huge page size is
4MB.  The current transparent hugepage support is not able to handle
HPAGE_SIZE != PMD_SIZE.

So make PTE tables be sized to half of a page instead of a full page.

We can still map properly the whole supported virtual address range
which on sparc64 requires 44 bits.  Add a compile time CPP test which
ensures that this requirement is always met.

There is a minor inefficiency added by this change.  We only use half
of the page for PTE tables.  It's not trivial to use only half of the
page yet still get all of the pgtable_page_{ctor,dtor}() stuff working
properly.  It is doable, and that will come in a subsequent change.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/pgtable_64.h |   24 +++++++-----------------
 arch/sparc/include/asm/tsb.h        |    4 ++--
 2 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 51be4a1..27293a3 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -45,40 +45,30 @@
 
 #define vmemmap			((struct page *)VMEMMAP_BASE)
 
-/* XXX All of this needs to be rethought so we can take advantage
- * XXX cheetah's full 64-bit virtual address space, ie. no more hole
- * XXX in the middle like on spitfire. -DaveM
- */
-/*
- * Given a virtual address, the lowest PAGE_SHIFT bits determine offset
- * into the page; the next higher PAGE_SHIFT-3 bits determine the pte#
- * in the proper pagetable (the -3 is from the 8 byte ptes, and each page
- * table is a single page long). The next higher PMD_BITS determine pmd#
- * in the proper pmdtable (where we must have PMD_BITS <= (PAGE_SHIFT-2)
- * since the pmd entries are 4 bytes, and each pmd page is a single page
- * long). Finally, the higher few bits determine pgde#.
- */
-
 /* PMD_SHIFT determines the size of the area a second-level page
  * table can map
  */
-#define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3))
+#define PMD_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-4))
 #define PMD_SIZE	(_AC(1,UL) << PMD_SHIFT)
 #define PMD_MASK	(~(PMD_SIZE-1))
 #define PMD_BITS	(PAGE_SHIFT - 2)
 
 /* PGDIR_SHIFT determines what a third-level page table entry can map */
-#define PGDIR_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-3) + PMD_BITS)
+#define PGDIR_SHIFT	(PAGE_SHIFT + (PAGE_SHIFT-4) + PMD_BITS)
 #define PGDIR_SIZE	(_AC(1,UL) << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 #define PGDIR_BITS	(PAGE_SHIFT - 2)
 
+#if (PGDIR_SHIFT + PGDIR_BITS) != 44
+#error Page table parameters do not cover virtual address space properly.
+#endif
+
 #ifndef __ASSEMBLY__
 
 #include <linux/sched.h>
 
 /* Entries per page directory level. */
-#define PTRS_PER_PTE	(1UL << (PAGE_SHIFT-3))
+#define PTRS_PER_PTE	(1UL << (PAGE_SHIFT-4))
 #define PTRS_PER_PMD	(1UL << PMD_BITS)
 #define PTRS_PER_PGD	(1UL << PGDIR_BITS)
 
diff --git a/arch/sparc/include/asm/tsb.h b/arch/sparc/include/asm/tsb.h
index 1a8afd1..6435924 100644
--- a/arch/sparc/include/asm/tsb.h
+++ b/arch/sparc/include/asm/tsb.h
@@ -152,7 +152,7 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	lduwa		[REG1 + REG2] ASI_PHYS_USE_EC, REG1; \
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - PMD_SHIFT, REG2; \
-	srlx		REG2, 64 - PAGE_SHIFT, REG2; \
+	srlx		REG2, 64 - (PAGE_SHIFT - 1), REG2; \
 	sllx		REG1, 11, REG1; \
 	andn		REG2, 0x7, REG2; \
 	add		REG1, REG2, REG1;
@@ -177,7 +177,7 @@ extern struct tsb_phys_patch_entry __tsb_phys_patch, __tsb_phys_patch_end;
 	lduwa		[REG1 + REG2] ASI_PHYS_USE_EC, REG1; \
 	brz,pn		REG1, FAIL_LABEL; \
 	 sllx		VADDR, 64 - PMD_SHIFT, REG2; \
-	srlx		REG2, 64 - PAGE_SHIFT, REG2; \
+	srlx		REG2, 64 - (PAGE_SHIFT - 1), REG2; \
 	sllx		REG1, 11, REG1; \
 	andn		REG2, 0x7, REG2; \
 	add		REG1, REG2, REG1;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
