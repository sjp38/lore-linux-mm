Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A53C6B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so81805912pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:33 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y17si6610383pgi.179.2017.03.01.22.39.31
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:32 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 10/11] mm: make rmap_one boolean function
Date: Thu,  2 Mar 2017 15:39:24 +0900
Message-Id: <1488436765-32350-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

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
index 68f8820..f764afb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1975,7 +1975,7 @@ void rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 			if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 				continue;
 
-			if (SWAP_AGAIN != rwc->rmap_one(page, vma,
+			if (!rwc->rmap_one(page, vma,
 					rmap_item->address, rwc->arg)) {
 				anon_vma_unlock_read(anon_vma);
 				return;
diff --git a/mm/migrate.c b/mm/migrate.c
index cda4c27..22daaea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -193,7 +193,7 @@ void putback_movable_pages(struct list_head *l)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
+static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 				 unsigned long addr, void *old)
 {
 	struct page_vma_mapped_walk pvmw = {
@@ -249,7 +249,7 @@ static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
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
index 08e4f81..60adedb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -717,7 +717,7 @@ struct page_referenced_arg {
 /*
  * arg: page_referenced_arg will be passed
  */
-static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
+static bool page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, void *arg)
 {
 	struct page_referenced_arg *pra = arg;
@@ -734,7 +734,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (vma->vm_flags & VM_LOCKED) {
 			page_vma_mapped_walk_done(&pvmw);
 			pra->vm_flags |= VM_LOCKED;
-			return SWAP_FAIL; /* To break the loop */
+			return false; /* To break the loop */
 		}
 
 		if (pvmw.pte) {
@@ -774,9 +774,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	if (!pra->mapcount)
-		return SWAP_SUCCESS; /* To break the loop */
+		return false; /* To break the loop */
 
-	return SWAP_AGAIN;
+	return true;
 }
 
 static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
@@ -847,7 +847,7 @@ int page_referenced(struct page *page,
 	return pra.referenced;
 }
 
-static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
+static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
 	struct page_vma_mapped_walk pvmw = {
@@ -900,7 +900,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		}
 	}
 
-	return SWAP_AGAIN;
+	return true;
 }
 
 static bool invalid_mkclean_vma(struct vm_area_struct *vma, void *arg)
@@ -1283,7 +1283,7 @@ void page_remove_rmap(struct page *page, bool compound)
 /*
  * @arg: enum ttu_flags will be passed to this argument
  */
-static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
+static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		     unsigned long address, void *arg)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -1294,12 +1294,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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
@@ -1328,7 +1328,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 					 */
 					mlock_vma_page(page);
 				}
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1339,7 +1339,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (!(flags & TTU_IGNORE_ACCESS)) {
 			if (ptep_clear_flush_young_notify(vma, address,
 						pvmw.pte)) {
-				ret = SWAP_FAIL;
+				ret = false;
 				page_vma_mapped_walk_done(&pvmw);
 				break;
 			}
@@ -1425,14 +1425,14 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				/* dirty MADV_FREE page */
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
@@ -1624,7 +1624,7 @@ static void rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
 		if (rwc->invalid_vma && rwc->invalid_vma(vma, rwc->arg))
 			continue;
 
-		if (SWAP_AGAIN != rwc->rmap_one(page, vma, address, rwc->arg))
+		if (!rwc->rmap_one(page, vma, address, rwc->arg))
 			break;
 		if (rwc->done && rwc->done(page))
 			break;
@@ -1678,7 +1678,7 @@ static void rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
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
