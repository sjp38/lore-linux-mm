Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB136B003C
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:22 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so6728148pbb.17
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:21 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yt9si16577925pab.91.2014.02.10.12.41.20
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/8] mm: consolidate code to setup pte
Date: Mon, 10 Feb 2014 22:41:06 +0200
Message-Id: <1392064866-11840-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch extract consolidate code to setup pte from do_read_fault(),
do_cow_fault() and do_shared_fault().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 66 ++++++++++++++++++++++++++++---------------------------------
 1 file changed, 30 insertions(+), 36 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index c36a21b912e1..68c3dc141059 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3317,13 +3317,37 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
 	return ret;
 }
 
+static void do_set_pte(struct vm_area_struct *vma, unsigned long address,
+		struct page *page, pte_t *pte, bool write, bool anon)
+{
+	pte_t entry;
+
+	flush_icache_page(vma, page);
+	entry = mk_pte(page, vma->vm_page_prot);
+	if (write)
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
+		pte_mksoft_dirty(entry);
+	if (anon) {
+		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
+		page_add_new_anon_rmap(page, vma, address);
+	} else {
+		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
+		page_add_file_rmap(page);
+	}
+	set_pte_at(vma->vm_mm, address, pte, entry);
+
+	/* no need to invalidate: a not-present page won't be cached */
+	update_mmu_cache(vma, address, pte);
+}
+
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	struct page *fault_page;
 	spinlock_t *ptl;
-	pte_t entry, *pte;
+	pte_t *pte;
 	int ret;
 
 	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
@@ -3337,20 +3361,9 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(fault_page);
 		return ret;
 	}
-
-	flush_icache_page(vma, fault_page);
-	entry = mk_pte(fault_page, vma->vm_page_prot);
-	if (pte_file(orig_pte) && pte_file_soft_dirty(orig_pte))
-		pte_mksoft_dirty(entry);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
-	page_add_file_rmap(fault_page);
-	set_pte_at(mm, address, pte, entry);
-
-	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, address, pte);
+	do_set_pte(vma, address, fault_page, pte, false, false);
 	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
-
 	return ret;
 }
 
@@ -3360,7 +3373,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *fault_page, *new_page;
 	spinlock_t *ptl;
-	pte_t entry, *pte;
+	pte_t *pte;
 	int ret;
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -3389,17 +3402,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(fault_page);
 		goto uncharge_out;
 	}
-
-	flush_icache_page(vma, new_page);
-	entry = mk_pte(new_page, vma->vm_page_prot);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(new_page, vma, address);
-	set_pte_at(mm, address, pte, entry);
-
-	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, address, pte);
-
+	do_set_pte(vma, address, new_page, pte, true, true);
 	pte_unmap_unlock(pte, ptl);
 	unlock_page(fault_page);
 	page_cache_release(fault_page);
@@ -3416,7 +3419,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *fault_page;
 	spinlock_t *ptl;
-	pte_t entry, *pte;
+	pte_t *pte;
 	int dirtied = 0;
 	int ret, tmp;
 
@@ -3445,16 +3448,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(fault_page);
 		return ret;
 	}
-
-	flush_icache_page(vma, fault_page);
-	entry = mk_pte(fault_page, vma->vm_page_prot);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	inc_mm_counter_fast(mm, MM_FILEPAGES);
-	page_add_file_rmap(fault_page);
-	set_pte_at(mm, address, pte, entry);
-
-	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, address, pte);
+	do_set_pte(vma, address, fault_page, pte, true, false);
 	pte_unmap_unlock(pte, ptl);
 
 	if (set_page_dirty(fault_page))
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
