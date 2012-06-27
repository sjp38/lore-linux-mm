Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 51F656B0081
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:49 -0400 (EDT)
Message-Id: <20120627212830.693232452@chello.nl>
Date: Wed, 27 Jun 2012 23:15:42 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/20] mm: Add optional TLB flush to generic RCU page-table freeing
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=nikunj_a__dadhania-flush_page-table_pages_before_freeing_them.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

From: Nikunj A. Dadhania <nikunj@linux.vnet.ibm.com>

Certain architectures (viz. x86, arm, s390) have hardware page-table
walkers (#PF). So during the RCU page-table teardown process make sure
we do a tlb flush of page-table pages on all relevant CPUs to
synchronize against hardware walkers, and then free the pages.

Moreover, the (mm_users < 2) condition does not hold good for the above
architectures, as the hardware engine is one of the user.

This patch should also make the generic RCU page-table freeing code
suitable for s390 again since it fixes the issues raised in
cd94154cc6a ("[S390] fix tlb flushing for page table pages").

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Suggested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Nikunj A. Dadhania <nikunj@linux.vnet.ibm.com>
[ Edited Kconfig bit ]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/Kconfig |   13 +++++++++++++
 mm/memory.c  |   23 +++++++++++++++++++++--
 2 files changed, 34 insertions(+), 2 deletions(-)
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -231,6 +231,19 @@ config HAVE_ARCH_MUTEX_CPU_RELAX
 config HAVE_RCU_TABLE_FREE
 	bool
 
+config HAVE_HW_PAGE_TABLE_WALKS
+	def_bool y
+	depends on HAVE_RCU_TABLE_FREE && !(SPARC64 || PPC)
+	help
+	  An arch should be excluded if it doesn't have hardware page-table
+	  walkers that can (re)populate TLB caches concurrently with us
+	  tearing down page-tables.
+
+	  Both SPARC and PPC are excluded because they have 'external'
+	  hash-table based MMUs which are cleared before we take down the
+	  linux page-table structure. Therefore we don't need to emit
+	  hardware TLB flush instructions before freeing page-table pages.
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -329,11 +329,26 @@ static void tlb_remove_table_rcu(struct 
 	free_page((unsigned long)batch);
 }
 
+#ifdef CONFIG_HAVE_HW_PAGE_TABLE_WALKS
+/*
+ * Some architectures (x86, arm, s390) can walk the page tables when
+ * the page-table tear down might be happening. So make sure we flush
+ * the TLBs before freeing the page-table pages.
+ */
+static inline void tlb_table_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu(tlb);
+}
+#else
+static inline void tlb_table_flush_mmu(struct mmu_gather *tlb) { }
+#endif /* CONFIG_HAVE_HW_PAGE_TABLE_WALKS */
+
 void tlb_table_flush(struct mmu_gather *tlb)
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
 	if (*batch) {
+		tlb_table_flush_mmu(tlb);
 		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
 		*batch = NULL;
 	}
@@ -345,18 +360,22 @@ void tlb_remove_table(struct mmu_gather 
 
 	tlb->need_flush = 1;
 
+#ifndef CONFIG_HAVE_HW_PAGE_TABLE_WALKS
 	/*
-	 * When there's less then two users of this mm there cannot be a
-	 * concurrent page-table walk.
+	 * When there's less then two users of this mm there cannot be
+	 * a concurrent page-table walk for architectures that do not
+	 * have hardware page-table walkers.
 	 */
 	if (atomic_read(&tlb->mm->mm_users) < 2) {
 		__tlb_remove_table(table);
 		return;
 	}
+#endif
 
 	if (*batch == NULL) {
 		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 		if (*batch == NULL) {
+			tlb_table_flush_mmu(tlb);
 			tlb_remove_table_one(table);
 			return;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
