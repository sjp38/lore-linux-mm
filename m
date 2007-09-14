From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:55:06 -0400
Message-Id: <20070914205506.6536.5170.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 10/14] Reclaim Scalability:  track anon_vma "related vmas"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 10/14 Reclaim Scalability:  track anon_vma "related vmas"

Against:  2.6.23-rc4-mm1

When a single parent forks a large number [thousands, 10s of thousands]
of children, the anon_vma list of related vmas becomes very long.  In
reclaim, this list must be traversed twice--once in page_referenced_anon()
and once in try_to_unmap_anon()--under a spin lock to reclaim the page.
Multiple cpus can end up spinning behind the same anon_vma spinlock and
traversing the lists.  This patch, part of the "noreclaim" series, treats
anon pages with list lengths longer than a tunable threshold as non-
reclaimable.

1) add mm Kconfig option NORECLAIM_ANON_VMA, dependent on NORECLAIM.

2) add a counter of related vmas to the anon_vma structure.  This won't
   increase the size of the structure on 64-bit systems, as it will fit
   in a padding slot.  
   TODO:  do we need a ref count > 4 billion?

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

Notes:

1) a separate patch makes the anon_vma lock a reader/writer lock.
   This allows some parallelism--different cpus can work on different 
   pages that reference the same anon_vma--but this does not address the
   problem of long lists and potentially many pte's to unmap.

2) TODO:  do same for file rmap in address_space with excessive number
   of mapping vmas?

3) Treating what are theortically reclaimable pages as nonreclaimable
   [in practice they ARE nonreclaimable] will result in oom-kill of some
   tasks rather than system hang/livelock.  We can debate which is
   preferrable.  However, with these patches, Andrea Arcangeli's oom-kill
   cleanups may become more important.

4) an alternate approach:  rather than treat these pages as nonreclaimable,
   we could track the anon_vma references and in fork() [dup_mmap()], when
   the count reaches some limit, give the anon_vma to the child and its
   siblings and their descendants, and allocate a new one for the parent.
   This requires breaking COW sharing of all anon pages [only the parent
   has complete enough state to do this at this point], as tasks can't
   share pages using different anon_vmas.  This will increase memory
   pressure and hasten the onset of reclaim.  I was working on this 
   alternate approach, but shelved it to try the noreclaim list approach.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/rmap.h |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/swap.h |    3 ++
 kernel/sysctl.c      |   12 ++++++++++
 mm/Kconfig           |   11 +++++++++
 mm/rmap.c            |   12 ++++++++--
 mm/vmscan.c          |   23 +++++++++++++++++--
 6 files changed, 117 insertions(+), 5 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-09-14 10:22:02.000000000 -0400
+++ Linux/mm/Kconfig	2007-09-14 10:23:52.000000000 -0400
@@ -204,3 +204,14 @@ config NORECLAIM
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
--- Linux.orig/include/linux/rmap.h	2007-09-14 10:22:02.000000000 -0400
+++ Linux/include/linux/rmap.h	2007-09-14 10:23:52.000000000 -0400
@@ -11,6 +11,20 @@
 #include <linux/memcontrol.h>
 
 /*
+ * Optionally, limit the growth of the anon_vma list of "related" vmas
+ * to ANON_VMA_LIST_LIMIT.  Add a count member
+ * to the anon_vma structure where we'd have padding on a 64-bit
+ * system w/o lock debugging.
+ */
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+#define DEFAULT_ANON_VMA_RECLAIM_LIMIT 64
+#define TRACK_ANON_VMA_COUNT 1
+#else
+#define DEFAULT_ANON_VMA_RECLAIM_LIMIT 0
+#define TRACK_ANON_VMA_COUNT 0
+#endif
+
+/*
  * The anon_vma heads a list of private "related" vmas, to scan if
  * an anonymous page pointing to this anon_vma needs to be unmapped:
  * the vmas on the list will be related by forking, or by splitting.
@@ -26,6 +40,9 @@
  */
 struct anon_vma {
 	rwlock_t rwlock;	/* Serialize access to vma list */
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+	int count;	/* number of "related" vmas */
+#endif
 	struct list_head head;	/* List of private "related" vmas */
 };
 
@@ -35,11 +52,20 @@ extern struct kmem_cache *anon_vma_cache
 
 static inline struct anon_vma *anon_vma_alloc(void)
 {
-	return kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	struct anon_vma *anon_vma;
+
+	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+	if (anon_vma)
+		anon_vma->count = 0;
+#endif
+	return anon_vma;
 }
 
 static inline void anon_vma_free(struct anon_vma *anon_vma)
 {
+	if (TRACK_ANON_VMA_COUNT)
+		VM_BUG_ON(anon_vma->count);
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
@@ -60,6 +86,39 @@ static inline void anon_vma_unlock(struc
 		write_unlock(&anon_vma->rwlock);
 }
 
+#ifdef CONFIG_NORECLAIM_ANON_VMA
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
--- Linux.orig/mm/rmap.c	2007-09-14 10:22:02.000000000 -0400
+++ Linux/mm/rmap.c	2007-09-14 10:23:52.000000000 -0400
@@ -82,6 +82,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (likely(!vma->anon_vma)) {
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			add_related_vma(anon_vma);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
@@ -96,16 +97,21 @@ int anon_vma_prepare(struct vm_area_stru
 
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
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
-	if (anon_vma)
+	if (anon_vma) {
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		add_related_vma(anon_vma);
+	}
 }
 
 void anon_vma_link(struct vm_area_struct *vma)
@@ -115,6 +121,7 @@ void anon_vma_link(struct vm_area_struct
 	if (anon_vma) {
 		write_lock(&anon_vma->rwlock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+		add_related_vma(anon_vma);
 		write_unlock(&anon_vma->rwlock);
 	}
 }
@@ -129,6 +136,7 @@ void anon_vma_unlink(struct vm_area_stru
 
 	write_lock(&anon_vma->rwlock);
 	list_del(&vma->anon_vma_node);
+	remove_related_vma(anon_vma);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
Index: Linux/include/linux/swap.h
===================================================================
--- Linux.orig/include/linux/swap.h	2007-09-14 10:22:02.000000000 -0400
+++ Linux/include/linux/swap.h	2007-09-14 10:23:52.000000000 -0400
@@ -227,6 +227,9 @@ static inline int zone_reclaim(struct zo
 #ifdef CONFIG_NORECLAIM
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
 extern void putback_all_noreclaim_pages(void);
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+extern int anon_vma_reclaim_limit;
+#endif
 #else
 static inline int page_reclaimable(struct page *page,
 						struct vm_area_struct *vma)
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:23:50.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:23:52.000000000 -0400
@@ -2154,6 +2154,10 @@ int zone_reclaim(struct zone *zone, gfp_
 #endif
 
 #ifdef CONFIG_NORECLAIM
+
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+int anon_vma_reclaim_limit = DEFAULT_ANON_VMA_RECLAIM_LIMIT;
+#endif
 /*
  * page_reclaimable(struct page *page, struct vm_area_struct *vma)
  * Test whether page is reclaimable--i.e., should be placed on active/inactive
@@ -2164,8 +2168,9 @@ int zone_reclaim(struct zone *zone, gfp_
  *               If !NULL, called from fault path.
  *
  * Reasons page might not be reclaimable:
- * + page's mapping marked non-reclaimable
- * TODO - later patches
+ * 1) page's mapping marked non-reclaimable
+ * 2) anon_vma [if any] has too many related vmas
+ * [more TBD.  e.g., anon page and no swap available, page mlocked, ...]
  *
  * TODO:  specify locking assumptions
  */
@@ -2177,6 +2182,20 @@ int page_reclaimable(struct page *page, 
 	if (mapping_non_reclaimable(page_mapping(page)))
 		return 0;
 
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
+			return 0;
+	}
+#endif
 	/* TODO:  test page [!]reclaimable conditions */
 
 	return 1;
Index: Linux/kernel/sysctl.c
===================================================================
--- Linux.orig/kernel/sysctl.c	2007-09-14 10:22:02.000000000 -0400
+++ Linux/kernel/sysctl.c	2007-09-14 10:23:52.000000000 -0400
@@ -1060,6 +1060,18 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 #endif
+#ifdef CONFIG_NORECLAIM_ANON_VMA
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "anon_vma_reclaim_limit",
+		.data		= &anon_vma_reclaim_limit,
+		.maxlen		= sizeof(anon_vma_reclaim_limit),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+	},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
