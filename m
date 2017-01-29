Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8DA56B0282
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:39:12 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so294434538pfg.4
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:39:12 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l127si6570940pga.348.2017.01.29.09.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 09:39:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 09/12] mm, uprobes: convert __replace_page() to use page_vma_mapped_walk()
Date: Sun, 29 Jan 2017 20:38:55 +0300
Message-Id: <20170129173858.45174-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
References: <20170129173858.45174-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For consistency, it worth converting all page_check_address() to
page_vma_mapped_walk(), so we could drop the former.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 kernel/events/uprobes.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1e65c79e52a6..18c6b23edd3c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -153,14 +153,19 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 				struct page *old_page, struct page *new_page)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pte_t *ptep;
+	struct page_vma_mapped_walk pvmw = {
+		.page = old_page,
+		.vma = vma,
+		.address = addr,
+	};
 	int err;
 	/* For mmu_notifiers */
 	const unsigned long mmun_start = addr;
 	const unsigned long mmun_end   = addr + PAGE_SIZE;
 	struct mem_cgroup *memcg;
 
+	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
+
 	err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL, &memcg,
 			false);
 	if (err)
@@ -171,11 +176,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	err = -EAGAIN;
-	ptep = page_check_address(old_page, mm, addr, &ptl, 0);
-	if (!ptep) {
+	if (!page_vma_mapped_walk(&pvmw)) {
 		mem_cgroup_cancel_charge(new_page, memcg, false);
 		goto unlock;
 	}
+	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
 
 	get_page(new_page);
 	page_add_new_anon_rmap(new_page, vma, addr, false);
@@ -187,14 +192,15 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 		inc_mm_counter(mm, MM_ANONPAGES);
 	}
 
-	flush_cache_page(vma, addr, pte_pfn(*ptep));
-	ptep_clear_flush_notify(vma, addr, ptep);
-	set_pte_at_notify(mm, addr, ptep, mk_pte(new_page, vma->vm_page_prot));
+	flush_cache_page(vma, addr, pte_pfn(*pvmw.pte));
+	ptep_clear_flush_notify(vma, addr, pvmw.pte);
+	set_pte_at_notify(mm, addr, pvmw.pte,
+			mk_pte(new_page, vma->vm_page_prot));
 
 	page_remove_rmap(old_page, false);
 	if (!page_mapped(old_page))
 		try_to_free_swap(old_page);
-	pte_unmap_unlock(ptep, ptl);
+	page_vma_mapped_walk_done(&pvmw);
 
 	if (vma->vm_flags & VM_LOCKED)
 		munlock_vma_page(old_page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
