Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99D438E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:59:40 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id t18so20335248qtj.3
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 23:59:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u24si1168646qtj.98.2019.01.20.23.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 23:59:39 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC 16/24] userfaultfd: wp: handle COW properly for uffd-wp
Date: Mon, 21 Jan 2019 15:57:14 +0800
Message-Id: <20190121075722.7945-17-peterx@redhat.com>
In-Reply-To: <20190121075722.7945-1-peterx@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, peterx@redhat.com, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

This allows uffd-wp to support write-protected pages for COW.

For example, the uffd write-protected PTE could also be write-protected
by other usages like COW or zero pages.  When that happens, we can't
simply set the write bit in the PTE since otherwise it'll change the
content of every single reference to the page.  Instead, we should do
the COW first if necessary, then handle the uffd-wp fault.

To correctly copy the page, we'll also need to carry over the
_PAGE_UFFD_WP bit if it was set in the original PTE.

For huge PMDs, we just simply split the huge PMDs where we want to
resolve an uffd-wp page fault always.  That matches what we do with
general huge PMD write protections.  In that way, we resolved the huge
PMD copy-on-write issue into PTE copy-on-write.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/memory.c   |  2 ++
 mm/mprotect.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 54 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ef823c07f635..a3de13b728f4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2290,6 +2290,8 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
+		if (pte_uffd_wp(vmf->orig_pte))
+			entry = pte_mkuffd_wp(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 000e246c163b..c37c9aa7a54e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		if (pte_present(oldpte)) {
 			pte_t ptent;
 			bool preserve_write = prot_numa && pte_write(oldpte);
+			struct page *page;
 
 			/*
 			 * Avoid trapping faults against the zero or KSM
 			 * pages. See similar comment in change_huge_pmd.
 			 */
 			if (prot_numa) {
-				struct page *page;
-
 				page = vm_normal_page(vma, addr, oldpte);
 				if (!page || PageKsm(page))
 					continue;
@@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					continue;
 			}
 
+			/*
+			 * Detect whether we'll need to COW before
+			 * resolving an uffd-wp fault.  Note that this
+			 * includes detection of the zero page (where
+			 * page==NULL)
+			 */
+			if (uffd_wp_resolve) {
+				/* If the fault is resolved already, skip */
+				if (!pte_uffd_wp(*pte))
+					continue;
+				page = vm_normal_page(vma, addr, oldpte);
+				if (!page || page_mapcount(page) > 1) {
+					struct vm_fault vmf = {
+						.vma = vma,
+						.address = addr & PAGE_MASK,
+						.page = page,
+						.orig_pte = oldpte,
+						.pmd = pmd,
+						/* pte and ptl not needed */
+					};
+					vm_fault_t ret;
+
+					if (page)
+						get_page(page);
+					arch_leave_lazy_mmu_mode();
+					pte_unmap_unlock(pte, ptl);
+					ret = wp_page_copy(&vmf);
+					/* PTE is changed, or OOM */
+					if (ret == 0)
+						/* It's done by others */
+						continue;
+					else if (WARN_ON(ret != VM_FAULT_WRITE))
+						return pages;
+					pte = pte_offset_map_lock(vma->vm_mm,
+								  pmd, addr,
+								  &ptl);
+					arch_enter_lazy_mmu_mode();
+				}
+			}
+
 			ptent = ptep_modify_prot_start(mm, addr, pte);
 			ptent = pte_modify(ptent, newprot);
 			if (preserve_write)
@@ -184,6 +223,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 	unsigned long pages = 0;
 	unsigned long nr_huge_updates = 0;
 	unsigned long mni_start = 0;
+	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
 
 	pmd = pmd_offset(pud, addr);
 	do {
@@ -201,7 +241,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		}
 
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
-			if (next - addr != HPAGE_PMD_SIZE) {
+			/*
+			 * When resolving an userfaultfd write
+			 * protection fault, it's not easy to identify
+			 * whether a THP is shared with others and
+			 * whether we'll need to do copy-on-write, so
+			 * just split it always for now to simply the
+			 * procedure.  And that's the policy too for
+			 * general THP write-protect in af9e4d5f2de2.
+			 */
+			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else {
 				int nr_ptes = change_huge_pmd(vma, pmd, addr,
-- 
2.17.1
