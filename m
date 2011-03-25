Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 011478D0047
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 04:44:47 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2P8iNFZ001592
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:23 -0700
Received: from iyi12 (iyi12.prod.google.com [10.241.51.12])
	by kpbe20.cbf.corp.google.com with ESMTP id p2P8iLjg005663
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:21 -0700
Received: by iyi12 with SMTP id 12so1084474iyi.23
        for <linux-mm@kvack.org>; Fri, 25 Mar 2011 01:44:21 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/5] kstaled: page_referenced_kstaled() and supporting infrastructure.
Date: Fri, 25 Mar 2011 01:43:52 -0700
Message-Id: <1301042635-11180-3-git-send-email-walken@google.com>
In-Reply-To: <1301042635-11180-1-git-send-email-walken@google.com>
References: <1301042635-11180-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Add a new page_referenced_kstaled() interface. The desired behavior
is that page_referenced() returns page references since the last
page_referenced() call, and page_referenced_kstaled() returns page
references since the last page_referenced_kstaled() call, but they
are both independent of each other and do not influence each other.

The following events are counted as kstaled page references:
- CPU data access to the page (as noticed through pte_young());
- mark_page_accessed() calls;
- page being freed / reallocated.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/page-flags.h |   25 +++++++++++++++++
 include/linux/rmap.h       |   64 +++++++++++++++++++++++++++++++++++++++-----
 mm/memory.c                |   14 +++++++++
 mm/rmap.c                  |   60 ++++++++++++++++++++++++++++------------
 mm/swap.c                  |    1 +
 5 files changed, 139 insertions(+), 25 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0db8037..6033b7c 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -51,6 +51,13 @@
  * PG_hwpoison indicates that a page got corrupted in hardware and contains
  * data with incorrect ECC bits that triggered a machine check. Accessing is
  * not safe since it may cause another machine check. Don't touch!
+ *
+ * PG_young indicates that kstaled cleared the young bit on some PTEs pointing
+ * to that page. In order to avoid interacting with the LRU algorithm, we want
+ * the next page_referenced() call to still consider the page young.
+ *
+ * PG_idle indicates that the page has not been referenced since the last time
+ * kstaled scanned it.
  */
 
 /*
@@ -107,6 +114,8 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+	PG_young,		/* kstaled cleared pte_young */
+	PG_idle,		/* idle since start of kstaled interval */
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -278,6 +287,22 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+PAGEFLAG(Young, young)
+
+PAGEFLAG(Idle, idle)
+
+static inline void set_page_young(struct page *page)
+{
+	if (!PageYoung(page))
+		SetPageYoung(page);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	if (PageIdle(page))
+		ClearPageIdle(page);
+}
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 61f51af..d6aab09 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -77,6 +77,8 @@ struct pr_info {
 	unsigned long vm_flags;
 	unsigned int pr_flags;
 #define PR_REFERENCED  1
+#define PR_DIRTY       2
+#define PR_FOR_KSTALED 4
 };
 
 #ifdef CONFIG_MMU
@@ -190,8 +192,8 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-void page_referenced(struct page *, int is_locked,
-		     struct mem_cgroup *cnt, struct pr_info *info);
+void __page_referenced(struct page *, int is_locked,
+		       struct mem_cgroup *cnt, struct pr_info *info);
 void page_referenced_one(struct page *, struct vm_area_struct *,
 			 unsigned long address, unsigned int *mapcount,
 			 struct pr_info *info);
@@ -282,12 +284,10 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-static inline void page_referenced(struct page *page, int is_locked,
-				   struct mem_cgroup *cnt,
-				   struct pr_info *info)
+static inline void __page_referenced(struct page *page, int is_locked,
+				     struct mem_cgroup *cnt,
+				     struct pr_info *info)
 {
-	info->vm_flags = 0;
-	info->pr_flags = 0;
 }
 
 #define try_to_unmap(page, refs) SWAP_FAIL
@@ -300,6 +300,56 @@ static inline int page_mkclean(struct page *page)
 
 #endif	/* CONFIG_MMU */
 
+/**
+ * page_referenced - test if the page was referenced
+ * @page: the page to test
+ * @is_locked: caller holds lock on the page
+ * @mem_cont: target memory controller
+ * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ *
+ * Quick test_and_clear_referenced for all mappings to a page,
+ * returns the number of ptes which referenced the page.
+ */
+static inline void page_referenced(struct page *page,
+				   int is_locked,
+				   struct mem_cgroup *mem_cont,
+				   struct pr_info *info)
+{
+	info->vm_flags = 0;
+	info->pr_flags = 0;
+
+	/*
+	 * Always clear PageYoung at the start of a scanning interval. It will
+	 * get get set if kstaled clears a young bit in a pte reference,
+	 * so that vmscan will still see the page as referenced.
+	 */
+	if (PageYoung(page)) {
+		ClearPageYoung(page);
+		info->pr_flags |= PR_REFERENCED;
+	}
+
+	__page_referenced(page, is_locked, mem_cont, info);
+}
+
+static inline void page_referenced_kstaled(struct page *page, bool is_locked,
+					   struct pr_info *info)
+{
+	info->vm_flags = 0;
+	info->pr_flags = PR_FOR_KSTALED;
+
+	/*
+	 * Always set PageIdle at the start of a scanning interval. It will
+	 * get cleared if a young page reference is encountered; otherwise
+	 * the page will be counted as idle at the next kstaled scan cycle.
+	 */
+	if (!PageIdle(page)) {
+		SetPageIdle(page);
+		info->pr_flags |= PR_REFERENCED;
+	}
+
+	__page_referenced(page, is_locked, NULL, info);
+}
+
 /*
  * Return values of try_to_unmap
  */
diff --git a/mm/memory.c b/mm/memory.c
index 5823698..d331e85 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -966,6 +966,20 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
+				/*
+				 * Using pte_young() here means kstaled
+				 * interferes with the LRU algorithm. We can't
+				 * just use PageYoung() to handle the case
+				 * where kstaled transfered the young bit from
+				 * pte to page, because mark_page_accessed()
+				 * is not idempotent: if the same page was
+				 * referenced by several unmapped ptes we don't
+				 * want to call mark_page_accessed() for every
+				 * such mapping.
+				 * We did not have this problem in 300 kernels
+				 * because they were using SetPageReferenced()
+				 * here instead.
+				 */
 				if (pte_young(ptent) &&
 				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index ee2c413..c632bbb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -520,8 +520,17 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		}
 
 		/* go ahead even if the pmd is pmd_trans_splitting() */
-		if (pmdp_clear_flush_young_notify(vma, address, pmd))
-			referenced = true;
+		if (!(info->pr_flags & PR_FOR_KSTALED)) {
+			if (pmdp_clear_flush_young_notify(vma, address, pmd)) {
+				referenced = true;
+				clear_page_idle(page);
+			}
+		} else {
+			if (pmdp_test_and_clear_young(vma, address, pmd)) {
+				referenced = true;
+				set_page_young(page);
+			}
+		}
 		spin_unlock(&mm->page_table_lock);
 	} else {
 		pte_t *pte;
@@ -535,6 +544,9 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (!pte)
 			return;
 
+		if (pte_dirty(*pte))
+			info->pr_flags |= PR_DIRTY;
+
 		if (vma->vm_flags & VM_LOCKED) {
 			pte_unmap_unlock(pte, ptl);
 			*mapcount = 0;	/* break early from loop */
@@ -542,23 +554,38 @@ void page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			return;
 		}
 
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		if (!(info->pr_flags & PR_FOR_KSTALED)) {
+			if (ptep_clear_flush_young_notify(vma, address, pte)) {
+				/*
+				 * Don't treat a reference through a
+				 * sequentially read mapping as such.
+				 * If the page has been used in another
+				 * mapping, we will catch it; if this other
+				 * mapping is already gone, the unmap path
+				 * will have set PG_referenced or activated
+				 * the page.
+				 */
+				if (likely(!VM_SequentialReadHint(vma)))
+					referenced = true;
+				clear_page_idle(page);
+			}
+		} else {
 			/*
-			 * Don't treat a reference through a sequentially read
-			 * mapping as such.  If the page has been used in
-			 * another mapping, we will catch it; if this other
-			 * mapping is already gone, the unmap path will have
-			 * set PG_referenced or activated the page.
+			 * Within page_referenced_kstaled():
+			 * skip TLB shootdown & VM_SequentialReadHint heuristic
 			 */
-			if (likely(!VM_SequentialReadHint(vma)))
+			if (ptep_test_and_clear_young(vma, address, pte)) {
 				referenced = true;
+				set_page_young(page);
+			}
 		}
 		pte_unmap_unlock(pte, ptl);
 	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
+	if (!(info->pr_flags & PR_FOR_KSTALED) &&
+			mm != current->mm && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced = true;
 
@@ -670,7 +697,7 @@ static void page_referenced_file(struct page *page,
 }
 
 /**
- * page_referenced - test if the page was referenced
+ * __page_referenced - test if the page was referenced
  * @page: the page to test
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
@@ -680,16 +707,13 @@ static void page_referenced_file(struct page *page,
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-void page_referenced(struct page *page,
-		     int is_locked,
-		     struct mem_cgroup *mem_cont,
-		     struct pr_info *info)
+void __page_referenced(struct page *page,
+		       int is_locked,
+		       struct mem_cgroup *mem_cont,
+		       struct pr_info *info)
 {
 	int we_locked = 0;
 
-	info->vm_flags = 0;
-	info->pr_flags = 0;
-
 	if (page_mapped(page) && page_rmapping(page)) {
 		if (!is_locked && (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
diff --git a/mm/swap.c b/mm/swap.c
index c02f936..4829e53 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -291,6 +291,7 @@ void mark_page_accessed(struct page *page)
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
+	clear_page_idle(page);
 }
 
 EXPORT_SYMBOL(mark_page_accessed);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
