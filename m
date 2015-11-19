Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB726B0254
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:35:31 -0500 (EST)
Received: by wmec201 with SMTP id c201so137879263wme.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:35:30 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m135si15051509wmb.47.2015.11.19.14.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:35:30 -0800 (PST)
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJMVVov015319
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:35:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1y9cas2h12-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:35:28 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 9d237d488f0d11e5b9600002c99293a0-495fa230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:53 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 6/8] userfaultfd: hook userfault handler to write protection fault
Date: Thu, 19 Nov 2015 14:33:51 -0800
Message-ID: <8b39e7027b26de92477a83d8145e22eb5f3b6989.1447964595.git.shli@fb.com>
In-Reply-To: <cover.1447964595.git.shli@fb.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

There are several cases write protection fault happens. It could be a write
to zero page, swaped page or userfault write protected page. When the
fault happens, there is no way to know if userfault write protect the
page before. Here we just blindly issue a userfault notification for vma
with VM_UFFD_WP regardless if app write protects it yet. Application
should be ready to handle such wp fault.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/memory.c | 66 +++++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 49 insertions(+), 17 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index deb679c..5d16a31 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1994,10 +1994,11 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
 			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
 			struct page *page, int page_mkwrite,
-			int dirty_shared)
+			int dirty_shared, unsigned int flags)
 	__releases(ptl)
 {
 	pte_t entry;
+	bool do_uffd = false;
 	/*
 	 * Clear the pages cpupid information as the existing
 	 * information potentially belongs to a now completely
@@ -2008,10 +2009,16 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 
 	flush_cache_page(vma, address, pte_pfn(orig_pte));
 	entry = pte_mkyoung(orig_pte);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (userfaultfd_wp(vma) && page) {
+		entry = pte_mkdirty(entry);
+		do_uffd = true;
+	} else
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 	if (ptep_set_access_flags(vma, address, page_table, entry, 1))
 		update_mmu_cache(vma, address, page_table);
 	pte_unmap_unlock(page_table, ptl);
+	if (do_uffd)
+		return handle_userfault(vma, address, flags, VM_UFFD_WP);
 
 	if (dirty_shared) {
 		struct address_space *mapping;
@@ -2059,7 +2066,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
  */
 static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *page_table, pmd_t *pmd,
-			pte_t orig_pte, struct page *old_page)
+			pte_t orig_pte, struct page *old_page, unsigned int flags)
 {
 	struct page *new_page = NULL;
 	spinlock_t *ptl = NULL;
@@ -2068,6 +2075,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
+	bool do_uffd = false;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -2105,7 +2113,15 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		/*
+		 * there is no way to know if we should do writeprotect here,
+		 * force a writeprotect
+		 */
+		if (userfaultfd_wp(vma)) {
+			entry = pte_mkdirty(entry);
+			do_uffd = true;
+		} else
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -2173,6 +2189,8 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		page_cache_release(old_page);
 	}
+	if (do_uffd)
+		return handle_userfault(vma, address, flags, VM_UFFD_WP);
 	return page_copied ? VM_FAULT_WRITE : 0;
 oom_free_new:
 	page_cache_release(new_page);
@@ -2189,7 +2207,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 static int wp_pfn_shared(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
 			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
-			pmd_t *pmd)
+			pmd_t *pmd, unsigned int flags)
 {
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
 		struct vm_fault vmf = {
@@ -2215,13 +2233,13 @@ static int wp_pfn_shared(struct mm_struct *mm,
 		}
 	}
 	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
-			     NULL, 0, 0);
+			     NULL, 0, 0, flags);
 }
 
 static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 			  unsigned long address, pte_t *page_table,
 			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
-			  struct page *old_page)
+			  struct page *old_page, unsigned int flags)
 	__releases(ptl)
 {
 	int page_mkwrite = 0;
@@ -2261,7 +2279,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	return wp_page_reuse(mm, vma, address, page_table, ptl,
-			     orig_pte, old_page, page_mkwrite, 1);
+			     orig_pte, old_page, page_mkwrite, 1, flags);
 }
 
 /*
@@ -2284,7 +2302,7 @@ static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+		spinlock_t *ptl, pte_t orig_pte, unsigned int flags)
 	__releases(ptl)
 {
 	struct page *old_page;
@@ -2301,11 +2319,11 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
 			return wp_pfn_shared(mm, vma, address, page_table, ptl,
-					     orig_pte, pmd);
+					     orig_pte, pmd, flags);
 
 		pte_unmap_unlock(page_table, ptl);
 		return wp_page_copy(mm, vma, address, page_table, pmd,
-				    orig_pte, old_page);
+				    orig_pte, old_page, flags);
 	}
 
 	/*
@@ -2336,13 +2354,13 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			page_move_anon_rmap(old_page, vma, address);
 			unlock_page(old_page);
 			return wp_page_reuse(mm, vma, address, page_table, ptl,
-					     orig_pte, old_page, 0, 0);
+					     orig_pte, old_page, 0, 0, flags);
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		return wp_page_shared(mm, vma, address, page_table, pmd,
-				      ptl, orig_pte, old_page);
+				      ptl, orig_pte, old_page, flags);
 	}
 
 	/*
@@ -2352,7 +2370,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	pte_unmap_unlock(page_table, ptl);
 	return wp_page_copy(mm, vma, address, page_table, pmd,
-			    orig_pte, old_page);
+			    orig_pte, old_page, flags);
 }
 
 static void unmap_mapping_range_vma(struct vm_area_struct *vma,
@@ -2455,6 +2473,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
+	bool do_uffd = false;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2559,7 +2578,15 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		/*
+		 * there is no way to know if we should do writeprotect here,
+		 * force a writeprotect
+		 */
+		if (userfaultfd_wp(vma)) {
+			pte = pte_mkdirty(pte);
+			do_uffd = true;
+		} else
+			pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
@@ -2595,7 +2622,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl,
+					pte, flags);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
@@ -2603,6 +2631,10 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, page_table);
+	if (do_uffd) {
+		pte_unmap_unlock(page_table, ptl);
+		return handle_userfault(vma, address, flags, VM_UFFD_WP);
+	}
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 out:
@@ -3309,7 +3341,7 @@ static int handle_pte_fault(struct mm_struct *mm,
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+					pte, pmd, ptl, entry, flags);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
