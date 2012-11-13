Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id B64FC6B009F
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:42:20 -0500 (EST)
Date: Tue, 13 Nov 2012 15:42:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/31] Foundation for automatic NUMA balancing V2
Message-ID: <20121113154215.GD8218@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
 <20121113151416.GA20044@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113151416.GA20044@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 04:14:16PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > (Since I wrote this changelog there has been another release 
> > of schednuma. I had delayed releasing this series long enough 
> > and decided not to delay further. Of course, I plan to dig 
> > into that new revision and see what has changed.)
> 
> Thanks, I've picked up a number of cleanups from your series and 
> propagated them into tip:numa/core tree.
> 

Cool.

> FYI, in addition to the specific patches to which I replied to 
> earier today, I've also propagated all your:
> 
>    CONFIG_SCHED_NUMA -> CONFIG_BALANCE_NUMA
> 
> renames thoughout the patches - I fundamentally agree that 
> CONFIG_BALANCE_NUMA is a better, more generic name.
> 
> My structural criticism of the architecture specific bits of 
> your patch-queue still applies to this version as well. That 
> change inflicted much of the changes that you had to do to 
> Peter's patches. It blew up the size of your tree and forks the 
> code into per architecture variants for no good reason.
> 

Should be fairly easy to do what you described -- move to generic and
make weak functions. PAGE_NUMA still has to be defined per architecture
because they'll need to update their pte_present, pmd_present and pmd_bad to
match but I do not necessarily consider this to be a bad thing. Initially,
enabling automatic NUMA support be a careful choice until we can be 100%
sure that PROT_NONE is equivalent in all cases.  Prototype is below that
moves definitions to mm/pgtable-generic.c

There is still the task of converting change_prot_numa() to reuse
change_protection if PAGE_NUMA == PROT_NONE but that should be
straight-forward.

> Had you not done that and had you kept the code generic you'd 
> essentially end up close to where tip:numa/core is today.
> 
> So if we can clear that core issue up we'll have quite a bit of 
> agreement.
> 
> I'd also like to add another, structural side note: you mixed 
> new vm-stats bits into the whole queue, needlessly blowing up 
> the size and the mm/ specific portions of the tree. I'd suggest 
> to post and keep those bits separately, preferably on top of 
> what we have already once it has settled down. I'm keeping the 
> 'perf bench numa' bits separate as well.

The stats part are fairly late in the queue. I noticed they break build
for !CONFIG_BALANCE_NUMA but it was trivially resolved. I feel they are
important due to the history showing the cost of all the balancing
implementations to be fairly high. One can use profiles to see where
some of the cost is but I also find the vmstats helpful in figuring out
how much work it's doing. They can be dropped again if they are not
considered generally useful.

> 
> Anyway, I've applied all applicable cleanups from you and picked 
> up Peter's latest code with the modifications I've indicated in 
> that thread, to the latest tip:numa/core tree, which I'll send 
> out for review in the next hour or so.
> 

Ok.

> This version is supposed to address all review feedback received 
> so far: it refines the MM specific split-up of the patches, 
> fixes regressions - see the changelogs for more details.
> 
> I'll (re-)send the full series of the latest patches and any 
> additional feedback will be welcome.
> 

Thanks

---8<---
mm: numa: Make pte_numa() and pmd_numa() a generic implementation

It was pointed out by Ingo Molnar that the per-architecture definition of
the NUMA PTE helper functions means that each supporting architecture
will have to cut and paste it which is unfortunate. He suggested instead
that the helpers should be weak functions that can be overridden by the
architecture.

This patch moves the helpers to mm/pgtable-generic.c and makes them weak
functions. Architectures wishing to use this will still be required to
define _PAGE_NUMA and potentially update their p[te|md]_present and
pmd_bad helpers if they choose to make PAGE_NUMA similar to PROT_NONE.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/x86/include/asm/pgtable.h |   56 +---------------------------------------
 include/asm-generic/pgtable.h  |   17 +++++-------
 mm/pgtable-generic.c           |   53 +++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 66 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index e075d57..4a4c11c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -425,61 +425,6 @@ static inline int pmd_present(pmd_t pmd)
 				 _PAGE_NUMA);
 }
 
-#ifdef CONFIG_BALANCE_NUMA
-/*
- * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
- * same bit too). It's set only when _PAGE_PRESET is not set and it's
- * never set if _PAGE_PRESENT is set.
- *
- * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
- * fault triggers on those regions if pte/pmd_numa returns true
- * (because _PAGE_PRESENT is not set).
- */
-static inline int pte_numa(pte_t pte)
-{
-	return (pte_flags(pte) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-
-static inline int pmd_numa(pmd_t pmd)
-{
-	return (pmd_flags(pmd) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-#endif
-
-/*
- * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
- * because they're called by the NUMA hinting minor page fault. If we
- * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
- * would be forced to set it later while filling the TLB after we
- * return to userland. That would trigger a second write to memory
- * that we optimize away by setting _PAGE_ACCESSED here.
- */
-static inline pte_t pte_mknonnuma(pte_t pte)
-{
-	pte = pte_clear_flags(pte, _PAGE_NUMA);
-	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
-}
-
-static inline pmd_t pmd_mknonnuma(pmd_t pmd)
-{
-	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
-	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
-}
-
-static inline pte_t pte_mknuma(pte_t pte)
-{
-	pte = pte_set_flags(pte, _PAGE_NUMA);
-	return pte_clear_flags(pte, _PAGE_PRESENT);
-}
-
-static inline pmd_t pmd_mknuma(pmd_t pmd)
-{
-	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
-	return pmd_clear_flags(pmd, _PAGE_PRESENT);
-}
-
 static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
@@ -534,6 +479,7 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
 	return (pte_t *)pmd_page_vaddr(*pmd) + pte_index(address);
 }
 
+extern int pmd_numa(pmd_t pmd);
 static inline int pmd_bad(pmd_t pmd)
 {
 #ifdef CONFIG_BALANCE_NUMA
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 896667e..da3e761 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -554,17 +554,12 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
 #endif
 }
 
-#ifndef CONFIG_BALANCE_NUMA
-static inline int pte_numa(pte_t pte)
-{
-	return 0;
-}
-
-static inline int pmd_numa(pmd_t pmd)
-{
-	return 0;
-}
-#endif /* CONFIG_BALANCE_NUMA */
+extern int pte_numa(pte_t pte);
+extern int pmd_numa(pmd_t pmd);
+extern pte_t pte_mknonnuma(pte_t pte);
+extern pmd_t pmd_mknonnuma(pmd_t pmd);
+extern pte_t pte_mknuma(pte_t pte);
+extern pmd_t pmd_mknuma(pmd_t pmd);
 
 #endif /* CONFIG_MMU */
 
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index e642627..6b6507f 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -170,3 +170,56 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+
+/*
+ * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
+ * same bit too). It's set only when _PAGE_PRESET is not set and it's
+ * never set if _PAGE_PRESENT is set.
+ *
+ * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
+ * fault triggers on those regions if pte/pmd_numa returns true
+ * (because _PAGE_PRESENT is not set).
+ */
+__weak int pte_numa(pte_t pte)
+{
+	return (pte_flags(pte) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+
+__weak int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+
+/*
+ * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
+ * because they're called by the NUMA hinting minor page fault. If we
+ * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
+ * would be forced to set it later while filling the TLB after we
+ * return to userland. That would trigger a second write to memory
+ * that we optimize away by setting _PAGE_ACCESSED here.
+ */
+__weak pte_t pte_mknonnuma(pte_t pte)
+{
+	pte = pte_clear_flags(pte, _PAGE_NUMA);
+	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+__weak pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
+	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
+}
+
+__weak pte_t pte_mknuma(pte_t pte)
+{
+	pte = pte_set_flags(pte, _PAGE_NUMA);
+	return pte_clear_flags(pte, _PAGE_PRESENT);
+}
+
+__weak pmd_t pmd_mknuma(pmd_t pmd)
+{
+	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
+	return pmd_clear_flags(pmd, _PAGE_PRESENT);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
