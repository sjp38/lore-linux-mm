Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09EE2280956
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 20:36:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j5so275756848pfb.3
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 17:36:02 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d9si9853163pge.193.2017.03.12.17.36.00
        for <linux-mm@kvack.org>;
        Sun, 12 Mar 2017 17:36:01 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 09/10] mm: make rmap_one boolean function
Date: Mon, 13 Mar 2017 09:35:52 +0900
Message-ID: <1489365353-28205-10-git-send-email-minchan@kernel.org>
In-Reply-To: <1489365353-28205-1-git-send-email-minchan@kernel.org>
References: <1489365353-28205-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>

rmap_one's return value controls whether rmap_work should contine to
scan other ptes or not so it's target for changing to boolean.
Return true if the scan should be continued. Otherwise, return false
to stop the scanning.

This patch makes rmap_one's return value to boolean.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  2 +-
 mm/ksm.c             |  2 +-
 mm/migrate.c         |  4 ++--
 mm/page_idle.c       |  4 ++--
 mm/rmap.c            | 30 +++++++++++++++---------------
 5 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1d7d457c..59d7dd7 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -257,7 +257,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
  */
 struct rmap_walk_control {
 	void *arg;
-	int (*rmap_one)(struct page *page, struct vm_area_struct *vma,
+	bool (*rmap_one)(struct page *page, struct vm_area_struct *vma,
 					unsigned long addr, void *arg);
 	int (*done)(struct page *page);
 	struct anon_vma *(*anon_lock)(struct page *page);
diff --git a/mm/ksm.c b/mm/ksm.c
index 6edffb9..d9fc0e4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1977,7 +1977,7 @@ void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 			if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 				continue;
 
-			if (SWAP_AGAIN != rwc->rmap_one(page, vma,
+			if (!rwc->rmap_one(page, vma,
 					rmap_item->address, rwc->arg)) {
 				anon_vma_unlock_read(anon_vma);
 				return;
diff --git a/mm/migrate.c b/mm/migrate.c
index e0cb4b7..8e9f1e8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -194,7 +194,7 @@ void putback_movable_pages(struct list_head *l)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
+static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				 unsigned long addr, void *old)
 {
 	struct page_vma_mapped_walk pvmw = {
@@ -250,7 +250,7 @@ static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		update_mmu_cache(vma, pvmw.address, pvmw.pte);
 	}
 
-	return SWAP_AGAIN;
+	return true;
 }
 
 /*
diff --git a/mm/page_idle.c b/mm/page_idle.c
index b0ee56c..1b0f48c 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -50,7 +50,7 @@ static struct page *page_idle_get_page(unsigned long pfn)
 	return page;
 }
 
-static int page_idle_clear_pte_refs_one(struct page *page,
+static bool page_idle_clear_pte_refs_one(struct page *page,
 					struct vm_area_struct *vma,
 					unsigned long addr, void *arg)
 {
@@ -84,7 +84,7 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 		 */
 		set_page_young(page);
 	}
-	return SWAP_AGAIN;
+	return true;
 }
 
 static void page_idle_clear_pte_refs(struct page *page)
diff --git a/mm/rmap.c b/mm/rmap.c
index fbffc5a..2422758 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -719,7 +719,7 @@ struct page_referenced_arg {
 /*
  * arg: page_referenced_arg will be passed
  */
-static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
+static bool page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, void *arg)
 {
 	struct page_referenced_arg *pra = arg;
@@ -736,7 +736,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (vma->vm_flags & VM_LOCKED) {
 			page_vma_mapped_walk_done(&pvmw);
 			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
+			return false; /* To break the loop */
 		}
 
 		if (pvmw.pte) {
@@ -776,9 +776,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	if (!pra->mapcount)
-		return SWAP_SUCCESS; /* To break the loop */
+		return false; /* To break the loop */
 
-	return SWAP_AGAIN;
+	return true;
 }
 
 static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
@@ -849,7 +849,7 @@ int page_referenced(struct page *page,
 	return pra.referenced;
 }
 
-static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
+static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
 	struct page_vma_mapped_walk pvmw = {
@@ -902,7 +902,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		}
 	}
 
-	return SWAP_AGAIN;
+	return true;
 }
 
 static bool invalid_mkclean_vma(struct vm_area_struct *vma, void *arg)
@@ -1285,7 +1285,7 @@ void page_remove_rmap(struct page *page, bool compound)
 /*
  * @arg: enum ttu_flags will be passed to this argument
  */
-static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
+static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -1296,12 +1296,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	};
 	pte_t pteval;
 	struct page *subpage;
-	int ret = SWAP_AGAIN;
+	bool ret = true;
 	enum ttu_flags flags = (enum ttu_flags)arg;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
-		return SWAP_AGAIN;
+		return true;
 
 	if (flags & TTU_SPLIT_HUGE_PMD) {
 		split_huge_pmd_address(vma, address,
@@ -1324,7 +1324,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 					 */
 					mlock_vma_page(page);
 				}
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1342,7 +1342,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (!(flags & TTU_IGNORE_ACCESS)) {
 			if (ptep_clear_flush_young_notify(vma, address,
 						pvmw.pte)) {
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1432,14 +1432,14 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				 */
 				set_pte_at(mm, address, pvmw.pte, pteval);
 				SetPageSwapBacked(page);
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
 
 			if (swap_duplicate(entry) < 0) {
 				set_pte_at(mm, address, pvmw.pte, pteval);
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1632,7 +1632,7 @@ static void rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
+		if (!rwc->rmap_one(page, vma, address, rwc->arg))
 			break;
 		if (rwc->done && rwc->done(page))
 			break;
@@ -1686,7 +1686,7 @@ static void rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
+		if (!rwc->rmap_one(page, vma, address, rwc->arg))
 			goto done;
 		if (rwc->done && rwc->done(page))
 			goto done;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
