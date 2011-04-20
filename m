Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6171C8D0047
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 05:11:21 -0400 (EDT)
Subject: Re: [PATCH 01/20] mm: mmu_gather rework
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1303289248.8345.62.camel@twins>
References: <20110401121258.211963744@chello.nl>
	 <20110401121725.360704327@chello.nl>
	 <20110419130606.fb7139b2.akpm@linux-foundation.org>
	 <1303289248.8345.62.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 20 Apr 2011 11:10:28 +0200
Message-ID: <1303290628.8345.64.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Wed, 2011-04-20 at 10:47 +0200, Peter Zijlstra wrote:
>=20
> But I guess I can have asm-generic/tlb.h define HAVE_GENERIC_MMU_GATHER
> and make the compilation in mm/memory.c conditional on that (or generate
> lots of Kconfig churn).=20

Something like so:

---
Subject: mm: Uninline large generic tlb.h functions
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed Apr 20 11:04:42 CEST 2011

Some of these functions have grown beyond inline sanity, move them
out-of-line.

Requested-by: Andrew Morton <akpm@linux-foundation.org>
Requested-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/asm-generic/tlb.h |  135 ++++-------------------------------------=
-----
 mm/memory.c               |  124 +++++++++++++++++++++++++++++++++++++++++=
-
 2 files changed, 135 insertions(+), 124 deletions(-)

Index: linux-2.6/include/asm-generic/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -96,134 +96,25 @@ struct mmu_gather {
 	struct page		*__pages[MMU_GATHER_BUNDLE];
 };
=20
-/*
- * For UP we don't need to worry about TLB flush
- * and page free order so much..
- */
-#ifdef CONFIG_SMP
-  #define tlb_fast_mode(tlb) (tlb->fast_mode)
-#else
-  #define tlb_fast_mode(tlb) 1
-#endif
+#define HAVE_GENERIC_MMU_GATHER
=20
-static inline int tlb_next_batch(struct mmu_gather *tlb)
+static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
-	struct mmu_gather_batch *batch;
-
-	batch =3D tlb->active;
-	if (batch->next) {
-		tlb->active =3D batch->next;
-		return 1;
-	}
-
-	batch =3D (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-	if (!batch)
-		return 0;
-
-	batch->next =3D NULL;
-	batch->nr   =3D 0;
-	batch->max  =3D MAX_GATHER_BATCH;
-
-	tlb->active->next =3D batch;
-	tlb->active =3D batch;
-
+#ifdef CONFIG_SMP
+	return tlb->fast_mode;
+#else
+	/*
+	 * For UP we don't need to worry about TLB flush
+	 * and page free order so much..
+	 */
 	return 1;
-}
-
-/* tlb_gather_mmu
- *	Called to initialize an (on-stack) mmu_gather structure for page-table
- *	tear-down from @mm. The @fullmm argument is used when @mm is without
- *	users and we're going to destroy the full address space (exit/execve).
- */
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm)
-{
-	tlb->mm =3D mm;
-
-	tlb->fullmm     =3D fullmm;
-	tlb->need_flush =3D 0;
-	tlb->fast_mode  =3D (num_possible_cpus() =3D=3D 1);
-	tlb->local.next =3D NULL;
-	tlb->local.nr   =3D 0;
-	tlb->local.max  =3D ARRAY_SIZE(tlb->__pages);
-	tlb->active     =3D &tlb->local;
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch =3D NULL;
 #endif
 }
=20
-static inline void
-tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	struct mmu_gather_batch *batch;
-
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush =3D 0;
-	tlb_flush(tlb);
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-
-	if (tlb_fast_mode(tlb))
-		return;
-
-	for (batch =3D &tlb->local; batch; batch =3D batch->next) {
-		free_pages_and_swap_cache(batch->pages, batch->nr);
-		batch->nr =3D 0;
-	}
-	tlb->active =3D &tlb->local;
-}
-
-/* tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long =
end)
-{
-	struct mmu_gather_batch *batch, *next;
-
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	for (batch =3D tlb->local.next; batch; batch =3D next) {
-		next =3D batch->next;
-		free_pages((unsigned long)batch, 0);
-	}
-	tlb->local.next =3D NULL;
-}
-
-/* __tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), whi=
le
- *	handling the additional races in SMP caused by other CPUs caching valid
- *	mappings in their TLBs. Returns the number of free page slots left.
- *	When out of page slots we must call tlb_flush_mmu().
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *p=
age)
-{
-	struct mmu_gather_batch *batch;
-
-	tlb->need_flush =3D 1;
-
-	if (tlb_fast_mode(tlb)) {
-		free_page_and_swap_cache(page);
-		return 1; /* avoid calling tlb_flush_mmu() */
-	}
-
-	batch =3D tlb->active;
-	batch->pages[batch->nr++] =3D page;
-	VM_BUG_ON(batch->nr > batch->max);
-	if (batch->nr =3D=3D batch->max) {
-		if (!tlb_next_batch(tlb))
-			return 0;
-	}
-
-	return batch->max - batch->nr;
-}
+void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool ful=
lmm);
+void tlb_flush_mmu(struct mmu_gather *tlb);
+void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned =
long end);
+int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
=20
 /* tlb_remove_page
  *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
Index: linux-2.6/mm/memory.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -182,7 +182,7 @@ void sync_mm_rss(struct task_struct *tas
 {
 	__sync_task_rss_stat(task, mm);
 }
-#else
+#else /* SPLIT_RSS_COUNTING */
=20
 #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
 #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
@@ -191,7 +191,127 @@ static void check_sync_rss_stat(struct t
 {
 }
=20
+#endif /* SPLIT_RSS_COUNTING */
+
+#ifdef HAVE_GENERIC_MMU_GATHER
+
+static int tlb_next_batch(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+	batch =3D tlb->active;
+	if (batch->next) {
+		tlb->active =3D batch->next;
+		return 1;
+	}
+
+	batch =3D (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	if (!batch)
+		return 0;
+
+	batch->next =3D NULL;
+	batch->nr   =3D 0;
+	batch->max  =3D MAX_GATHER_BATCH;
+
+	tlb->active->next =3D batch;
+	tlb->active =3D batch;
+
+	return 1;
+}
+
+/* tlb_gather_mmu
+ *	Called to initialize an (on-stack) mmu_gather structure for page-table
+ *	tear-down from @mm. The @fullmm argument is used when @mm is without
+ *	users and we're going to destroy the full address space (exit/execve).
+ */
+void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool ful=
lmm)
+{
+	tlb->mm =3D mm;
+
+	tlb->fullmm     =3D fullmm;
+	tlb->need_flush =3D 0;
+	tlb->fast_mode  =3D (num_possible_cpus() =3D=3D 1);
+	tlb->local.next =3D NULL;
+	tlb->local.nr   =3D 0;
+	tlb->local.max  =3D ARRAY_SIZE(tlb->__pages);
+	tlb->active     =3D &tlb->local;
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch =3D NULL;
 #endif
+}
+
+void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+	if (!tlb->need_flush)
+		return;
+	tlb->need_flush =3D 0;
+	tlb_flush(tlb);
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
+
+	if (tlb_fast_mode(tlb))
+		return;
+
+	for (batch =3D &tlb->local; batch; batch =3D batch->next) {
+		free_pages_and_swap_cache(batch->pages, batch->nr);
+		batch->nr =3D 0;
+	}
+	tlb->active =3D &tlb->local;
+}
+
+/* tlb_finish_mmu
+ *	Called at the end of the shootdown operation to free up any resources
+ *	that were required.
+ */
+void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned =
long end)
+{
+	struct mmu_gather_batch *batch, *next;
+
+	tlb_flush_mmu(tlb);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+
+	for (batch =3D tlb->local.next; batch; batch =3D next) {
+		next =3D batch->next;
+		free_pages((unsigned long)batch, 0);
+	}
+	tlb->local.next =3D NULL;
+}
+
+/* __tlb_remove_page
+ *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), whi=
le
+ *	handling the additional races in SMP caused by other CPUs caching valid
+ *	mappings in their TLBs. Returns the number of free page slots left.
+ *	When out of page slots we must call tlb_flush_mmu().
+ */
+int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	struct mmu_gather_batch *batch;
+
+	tlb->need_flush =3D 1;
+
+	if (tlb_fast_mode(tlb)) {
+		free_page_and_swap_cache(page);
+		return 1; /* avoid calling tlb_flush_mmu() */
+	}
+
+	batch =3D tlb->active;
+	batch->pages[batch->nr++] =3D page;
+	if (batch->nr =3D=3D batch->max) {
+		if (!tlb_next_batch(tlb))
+			return 0;
+	}
+	VM_BUG_ON(batch->nr > batch->max);
+
+	return batch->max - batch->nr;
+}
+
+#endif /* HAVE_GENERIC_MMU_GATHER */
=20
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
=20
@@ -268,7 +388,7 @@ void tlb_remove_table(struct mmu_gather=20
 		tlb_table_flush(tlb);
 }
=20
-#endif
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
=20
 /*
  * If a p?d_bad entry is found while walking page tables, report

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
