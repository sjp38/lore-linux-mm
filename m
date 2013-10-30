Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C3F766B003C
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:46:05 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so1563045pab.24
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:46:05 -0700 (PDT)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id dl5si25794pbd.206.2013.10.30.14.46.04
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:46:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 08/11] madvise: redefine callback functions for page table walker
Date: Wed, 30 Oct 2013 17:44:56 -0400
Message-Id: <1383169499-25144-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

swapin_walk_pmd_entry() is defined as pmd_entry(), but it has no code
about pmd handling (except pmd_none_or_trans_huge_or_clear_bad, but the
same check are now done in core page table walk code).
So let's move this function on pte_entry() as swapin_walk_pte_entry().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/madvise.c | 43 +++++++++++++------------------------------
 1 file changed, 13 insertions(+), 30 deletions(-)

diff --git v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/madvise.c v3.12-rc7-mmots-2013-10-29-16-24/mm/madvise.c
index 6970248..722fe1d 100644
--- v3.12-rc7-mmots-2013-10-29-16-24.orig/mm/madvise.c
+++ v3.12-rc7-mmots-2013-10-29-16-24/mm/madvise.c
@@ -109,38 +109,22 @@ static int madvise_vma_anon_name(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_SWAP
-static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
+static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
 	unsigned long end, struct mm_walk *walk)
 {
-	pte_t *orig_pte;
-	struct vm_area_struct *vma = walk->private;
-	unsigned long index;
+	swp_entry_t entry;
+	struct page *page;
+	struct vm_area_struct *vma = walk->vma;
 
-	if (pmd_none_or_trans_huge_or_clear_bad(pmd))
+	if (pte_present(*pte) || pte_none(*pte) || pte_file(*pte))
 		return 0;
-
-	for (index = start; index != end; index += PAGE_SIZE) {
-		pte_t pte;
-		swp_entry_t entry;
-		struct page *page;
-		spinlock_t *ptl;
-
-		orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, start, &ptl);
-		pte = *(orig_pte + ((index - start) / PAGE_SIZE));
-		pte_unmap_unlock(orig_pte, ptl);
-
-		if (pte_present(pte) || pte_none(pte) || pte_file(pte))
-			continue;
-		entry = pte_to_swp_entry(pte);
-		if (unlikely(non_swap_entry(entry)))
-			continue;
-
-		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
-								vma, index);
-		if (page)
-			page_cache_release(page);
-	}
-
+	entry = pte_to_swp_entry(*pte);
+	if (unlikely(non_swap_entry(entry)))
+		return 0;
+	page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
+				     vma, start);
+	if (page)
+		page_cache_release(page);
 	return 0;
 }
 
@@ -149,8 +133,7 @@ static void force_swapin_readahead(struct vm_area_struct *vma,
 {
 	struct mm_walk walk = {
 		.mm = vma->vm_mm,
-		.pmd_entry = swapin_walk_pmd_entry,
-		.private = vma,
+		.pte_entry = swapin_walk_pte_entry,
 	};
 
 	walk_page_range(start, end, &walk);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
