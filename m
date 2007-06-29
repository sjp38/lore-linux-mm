Subject: "Noreclaim - client patch 3/3 - treat pages w/ excessively
	references anon_vma as nonreclaimable"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070629141254.GA23310@v2.random>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	 <466C36AE.3000101@redhat.com> <20070610181700.GC7443@v2.random>
	 <46814829.8090808@redhat.com>
	 <20070626105541.cd82c940.akpm@linux-foundation.org>
	 <468439E8.4040606@redhat.com> <1183124309.5037.31.camel@localhost>
	 <20070629141254.GA23310@v2.random>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 18:49:14 -0400
Message-Id: <1183157354.7012.37.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

Here's the last one for now.  I have a couple more in this series
that handle the swap-backed w/ no swap space avail, but that's a 
different topic, right?

----

Patch m/n against 2.6.21-rc5 - track anon_vma "related vmas" == list length

When a single parent forks a large number [thousands, 10s of thousands]
of children, the anon_vma list of related vmas becomes very long.  In
reclaim, this list must be traversed twice--once in page_referenced_anon()
and once in try_to_unmap_anon()--under a spin lock to reclaim the page.
Multiple cpus can end up spinning behind the same anon_vma spinlock and
traversing the lists.  This patch, part of the "noreclaim" series, treats
anon pages with list lengths longer than a tunable threshold as non-
reclaimable.

1) add mm Kconfig option NORECLAIM_ANON_VMA, dependent on NORECLAIM.
   32-bit systems may not want/need this features.

2) add a counter of related vmas to the anon_vma structure.  This won't
   increase the size of the structure on 64-bit systems, as it will fit
   in a padding slot.  

3) In [__]anon_vma_[un]link(), track number of related vmas.  The
   count is only incremented/decremented while the anon_vma lock
   is held, so regular, non-atomic, increment/decrement is used.

4) in page_reclaimable(), check anon_vma count in vma's anon_vma, if
   vma supplied, or in page's anon_vma.  In fault path, new anon pages are
   placed on the LRU before adding the anon rmap, so we need to check
   the vma's anon_vma.  Fortunately, the vma is available at that point.
   In vmscan, we can just check the page's anon_vma for any anon pages
   that made it onto the [in]active list before the anon_vma list length
   became "excessive".

5) make the threshold tunable via /proc/sys/vm/anon_vma_reclaim_limit.
   Default value of 64 is totally arbitrary, but should be high enough
   that most applications won't hit it.

6) In the fault paths that install new anonymous pages, check whether
   the page is reclaimable or not [#4 above].  If it is, just add it
   to the active lru list [via the pagevec cache], else add it to the
   noreclaim list.  

Notes:

1) a separate patch makes the anon_vma lock a reader/writer lock.
This allows some parallelism--different cpus can work on different 
pages that reference the same anon_vma--but this does not address the
problem of long lists and potentially many pte's to unmap.

2) I moved the call to page_add_new_anon_rmap() to before the test
for page_reclaimable() and thus before the calls to
lru_cache_add_{active|noreclaim}(), so that page_reclaimable()
could recognize the page as anon, thus obviating, I think, the vma
arg to page_reclaimable().  TBD I think this reordering is OK,
but the previous order may have existed to close some obscure
race?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/rmap.h   |   57 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/swap.h   |    3 ++
 include/linux/sysctl.h |    1 
 kernel/sysctl.c        |   12 ++++++++++
 mm/Kconfig             |   11 +++++++++
 mm/memory.c            |   20 +++++++++++++----
 mm/rmap.c              |    9 ++++++-
 mm/vmscan.c            |   22 +++++++++++++++++-
 8 files changed, 127 insertions(+), 8 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-03-28 16:33:18.000000000 -0400
+++ Linux/mm/Kconfig	2007-03-28 16:34:00.000000000 -0400
@@ -171,3 +171,14 @@ config NORECLAIM
 	  may be non-reclaimable because:  they are locked into memory, they
 	  are anonymous pages for which no swap space exists, or they are anon
 	  pages that are expensive to unmap [long anon_vma "related vma" list.]
+
+config NORECLAIM_ANON_VMA
+	bool "Exclude pages with excessively long anon_vma lists"
+	depends on NORECLAIM
+	help
+	  Treats anonymous pages with excessively long anon_vma lists as
+	  non-reclaimable.  Long anon_vma lists results from fork()ing
+	  many [hundreds, thousands] of children from a single parent.  The
+	  anonymous pages in such tasks are very expensive [sometimes almost
+	  impossible] to reclaim.  Treating them as non-reclaimable avoids
+	  the overhead of attempting to reclaim them.
Index: Linux/include/linux/rmap.h
===================================================================
--- Linux.orig/include/linux/rmap.h	2007-03-28 16:33:18.000000000 -0400
+++ Linux/include/linux/rmap.h	2007-03-28 16:33:29.000000000 -0400
@@ -10,6 +10,18 @@
 #include <linux/spinlock.h>
 
 /*
+ * Optionally, limit the growth of the anon_vma list of "related" vmas
+ * to ANON_VMA_LIST_LIMIT.  Add a count member
+ * to the anon_vma structure where we'd have padding on a 64-bit
+ * system w/o lock debugging.
+ */
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+#define DEFAULT_ANON_VMA_RECLAIM_LIMIT 64
+#else
+#define DEFAULT_ANON_VMA_RECLAIM_LIMIT 0
+#endif
+
+/*
  * The anon_vma heads a list of private "related" vmas, to scan if
  * an anonymous page pointing to this anon_vma needs to be unmapped:
  * the vmas on the list will be related by forking, or by splitting.
@@ -25,6 +37,9 @@
  */
 struct anon_vma {
 	rwlock_t rwlock;	/* Serialize access to vma list */
+#if CONFIG_NORECLAIM_ANON_VMA
+	int count;	/* number of "related" vmas */
+#endif
 	struct list_head head;	/* List of private "related" vmas */
 };
 
@@ -34,11 +49,18 @@ extern struct kmem_cache *anon_vma_cache
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
-	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	struct anon_vma *anon_vma;
+
+	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	if (DEFAULT_ANON_VMA_RECLAIM_LIMIT && anon_vma)
+		anon_vma->count = 0;
+	return anon_vma;
 }
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
+	if (DEFAULT_ANON_VMA_RECLAIM_LIMIT)
+		VM_BUG_ON(anon_vma->count);
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
@@ -59,6 +81,39 @@ static inline void anon_vma_unlock(struc
 		write_unlock(&anon_vma->rwlock);
 }
 
+#if CONFIG_NORECLAIM_ANON_VMA
+
+/*
+ * Track number of "related" vmas on anon_vma list.
+ * Only called with anon_vma lock held.
+ * Note:  we track related vmas on fork() and splits, but
+ * only enforce the limit on fork().
+ */
+static inline void add_related_vma(struct anon_vma *anon_vma)
+{
+	++anon_vma->count;
+}
+
+static inline void remove_related_vma(struct anon_vma *anon_vma)
+{
+	--anon_vma->count;
+	VM_BUG_ON(anon_vma->count < 0);
+}
+
+static inline struct anon_vma *page_anon_vma(struct page *page)
+{
+	VM_BUG_ON(!PageAnon(page));
+	return (struct anon_vma *)((unsigned long)page->mapping &
+						~PAGE_MAPPING_ANON);
+}
+
+#else
+
+#define add_related_vma(A)
+#define remove_related_vma(A)
+
+#endif
+
 /*
  * anon_vma helper functions.
  */
Index: Linux/mm/rmap.c
===================================================================
--- Linux.orig/mm/rmap.c	2007-03-28 16:33:18.000000000 -0400
+++ Linux/mm/rmap.c	2007-03-28 16:33:29.000000000 -0400
@@ -99,6 +99,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			add_related_vma(anon_vma);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -113,8 +114,11 @@ int anon_vma_prepare(struct vm_area_stru
 
 void __anon_vma_merge(struct vm_area_struct *vma, struct vm_area_struct *next)
 {
-	BUG_ON(vma->anon_vma != next->anon_vma);
+	struct anon_vma *anon_vma = vma->anon_vma;
+
+	BUG_ON(anon_vma != next->anon_vma);
 	list_del(&next->anon_vma_node);
+	remove_related_vma(anon_vma);
 }
 
 void __anon_vma_link(struct vm_area_struct *vma)
@@ -123,6 +127,7 @@ void __anon_vma_link(struct vm_area_stru
 
 	if (anon_vma) {
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		add_related_vma(anon_vma);
 		validate_anon_vma(vma);
 	}
 }
@@ -134,6 +139,7 @@ void anon_vma_link(struct vm_area_struct
 	if (anon_vma) {
 		write_lock(&anon_vma->rwlock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		add_related_vma(anon_vma);
 		validate_anon_vma(vma);
 		write_unlock(&anon_vma->rwlock);
 	}
@@ -150,6 +156,7 @@ void anon_vma_unlink(struct vm_area_stru
 	write_lock(&anon_vma->rwlock);
 	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
+	remove_related_vma(anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
Index: Linux/include/linux/swap.h
===================================================================
--- Linux.orig/include/linux/swap.h	2007-03-28 16:33:18.000000000 -0400
+++ Linux/include/linux/swap.h	2007-03-28 16:33:29.000000000 -0400
@@ -214,6 +214,9 @@ static inline int zone_reclaim(struct zo
 
 #ifdef CONFIG_NORECLAIM
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+extern int anon_vma_reclaim_limit;
+#endif
 #else
 #define page_reclaimable(P, V) 1
 #endif
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-03-28 16:33:18.000000000 -0400
+++ Linux/mm/vmscan.c	2007-03-28 16:34:00.000000000 -0400
@@ -1812,6 +1812,10 @@ int zone_reclaim(struct zone *zone, gfp_
 #endif
 
 #ifdef CONFIG_NORECLAIM
+
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+int anon_vma_reclaim_limit = DEFAULT_ANON_VMA_RECLAIM_LIMIT;
+#endif
 /*
  * page_reclaimable(struct page *page, struct vm_area_struct *vma)
  * Test whether page is reclaimable--i.e., should be placed on active/inactive
@@ -1822,7 +1826,8 @@ int zone_reclaim(struct zone *zone, gfp_
  *               If !NULL, called from fault path.
  *
  * Reasons page might not be reclaimable:
- * TODO - later patches
+ * 1) anon_vma [if any] has too many related vmas
+ * [more TBD.  e.g., anon page and no swap available, page mlocked, ...]
  *
  * TODO:  specify locking assumptions
  */
@@ -1832,7 +1837,20 @@ int page_reclaimable(struct page *page, 
 
 	VM_BUG_ON(PageNoreclaim(page));
 
-	/* TODO:  test page [!]reclaimable conditions */
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+	if (PageAnon(page)) {
+		struct anon_vma *anon_vma;
+
+		/*
+		 * anon page with too many related vmas?
+		 */
+		anon_vma = page_anon_vma(page);
+		VM_BUG_ON(!anon_vma);
+		if (anon_vma_reclaim_limit &&
+			anon_vma->count > anon_vma_reclaim_limit)
+			reclaimable = 0;
+	}
+#endif
 
 	return reclaimable;
 }
Index: Linux/include/linux/sysctl.h
===================================================================
--- Linux.orig/include/linux/sysctl.h	2007-03-28 16:33:18.000000000 -0400
+++ Linux/include/linux/sysctl.h	2007-03-28 16:33:29.000000000 -0400
@@ -207,6 +207,7 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_ANON_VMA_RECLAIM_LIMIT=36, /* max "related vmas" for reclaim  */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,
Index: Linux/kernel/sysctl.c
===================================================================
--- Linux.orig/kernel/sysctl.c	2007-03-28 16:33:18.000000000 -0400
+++ Linux/kernel/sysctl.c	2007-03-28 16:33:29.000000000 -0400
@@ -859,6 +859,18 @@ static ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 #endif
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+	{
+		.ctl_name	= VM_ANON_VMA_RECLAIM_LIMIT,
+		.procname	= "anon_vma_reclaim_limit",
+		.data		= &anon_vma_reclaim_limit,
+		.maxlen		= sizeof(anon_vma_reclaim_limit),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 
Index: Linux/mm/memory.c
===================================================================
--- Linux.orig/mm/memory.c	2007-03-28 16:33:18.000000000 -0400
+++ Linux/mm/memory.c	2007-03-28 16:33:29.000000000 -0400
@@ -1650,8 +1650,11 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
+		if (page_reclaimable(new_page, vma))
+			lru_cache_add_active(new_page);
+		else
+			lru_cache_add_noreclaim(new_page);
 
 		/* Free the old page.. */
 		new_page = old_page;
@@ -2149,8 +2152,11 @@ int install_new_anon_page(struct vm_area
 	inc_mm_counter(mm, anon_rss);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
-	lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
+	if (page_reclaimable(page, vma))
+		lru_cache_add_active(page);
+	else
+		lru_cache_add_noreclaim(page);
 	pte_unmap_unlock(pte, ptl);
 
 	/* no need for flush_tlb */
@@ -2187,8 +2193,11 @@ static int do_anonymous_page(struct mm_s
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, anon_rss);
-		lru_cache_add_active(page);
 		page_add_new_anon_rmap(page, vma, address);
+		if (page_reclaimable(page, vma))
+			lru_cache_add_active(page);
+		else
+			lru_cache_add_noreclaim(page);
 	} else {
 		/* Map the ZERO_PAGE - vm_page_prot is readonly */
 		page = ZERO_PAGE(address);
@@ -2334,8 +2343,11 @@ retry:
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
-			lru_cache_add_active(new_page);
 			page_add_new_anon_rmap(new_page, vma, address);
+			if (page_reclaimable(new_page, vma))
+				lru_cache_add_active(new_page);
+			else
+				lru_cache_add_noreclaim(new_page);
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
