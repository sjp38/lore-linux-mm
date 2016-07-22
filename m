Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 936CC828E1
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:20:12 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so72035535lfi.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:20:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 127si6916231wmt.49.2016.07.22.05.19.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 05/15] mm: Factor out functionality to finish page faults
Date: Fri, 22 Jul 2016 14:19:31 +0200
Message-Id: <1469189981-19000-6-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Introduce function finish_fault() which handles locking of page tables
and insertion of PTE after page for the page fault is prepared. This
will be somewhat easier to use from page fault handlers than current
do_set_pte() which is unnecessarily low-level for most uses.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 67 ++++++++++++++++++++++++++++++++++++++----------------
 2 files changed, 48 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2442f972bdc8..21226cc2b1cd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -606,6 +606,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 		struct page *page, pte_t *pte, bool write, bool anon);
+int finish_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index aef88d634072..b785f823caa4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2890,6 +2890,49 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+/**
+ * finish_fault - finish page fault once we have prepared the page to fault
+ *
+ * @vma: virtual memory area
+ * @vmf: structure describing the fault
+ *
+ * This function handles all that is needed to finish a page fault once the
+ * page to fault in is prepared. It handles locking of PTEs, inserts PTE for
+ * given page, adds reverse page mapping, handles memcg charges and LRU
+ * addition. The function returns 0 on success, error in case page could not
+ * be inserted into page tables.
+ *
+ * The function expects the page to be locked.
+ */
+int finish_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	struct page *page = vmf->page;
+	bool anon = false;
+	spinlock_t *ptl;
+	pte_t *pte;
+
+	if (vmf->cow_page) {
+		page = vmf->cow_page;
+		anon = true;
+	}
+
+	pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, address, &ptl);
+	if (unlikely(!pte_same(*pte, vmf->orig_pte))) {
+		pte_unmap_unlock(pte, ptl);
+		return -EBUSY;
+	}
+	do_set_pte(vma, address, page, pte, vmf->flags & FAULT_FLAG_WRITE,
+		   anon);
+	if (anon) {
+		mem_cgroup_commit_charge(page, vmf->memcg, false, false);
+		lru_cache_add_active_or_unevictable(page, vma);
+	}
+	pte_unmap_unlock(pte, ptl);
+
+	return 0;
+}
+
 static unsigned long fault_around_bytes __read_mostly =
 	rounddown_pow_of_two(65536);
 
@@ -3022,15 +3065,13 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	pte = pte_offset_map_lock(mm, vmf->pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, vmf->orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (unlikely(finish_fault(vma, vmf) < 0)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
 		return ret;
 	}
-	do_set_pte(vma, address, vmf->page, pte, false, false);
 	unlock_page(vmf->page);
+	return ret;
 unlock_out:
 	pte_unmap_unlock(pte, ptl);
 	return ret;
@@ -3041,8 +3082,6 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *new_page;
 	struct mem_cgroup *memcg;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int ret;
 	unsigned long address = (unsigned long)vmf->virtual_address;
 
@@ -3070,9 +3109,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		copy_user_highpage(new_page, vmf->page, address, vma);
 	__SetPageUptodate(new_page);
 
-	pte = pte_offset_map_lock(mm, vmf->pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, vmf->orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (unlikely(finish_fault(vma, vmf) < 0)) {
 		if (!(ret & VM_FAULT_DAX_LOCKED)) {
 			unlock_page(vmf->page);
 			put_page(vmf->page);
@@ -3082,10 +3119,6 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
-	mem_cgroup_commit_charge(new_page, memcg, false, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
-	pte_unmap_unlock(pte, ptl);
 	if (!(ret & VM_FAULT_DAX_LOCKED)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
@@ -3104,8 +3137,6 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct address_space *mapping;
 	unsigned long address = (unsigned long)vmf->virtual_address;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int dirtied = 0;
 	int ret, tmp;
 
@@ -3128,15 +3159,11 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
-	pte = pte_offset_map_lock(mm, vmf->pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, vmf->orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (unlikely(finish_fault(vma, vmf) < 0)) {
 		unlock_page(vmf->page);
 		put_page(vmf->page);
 		return ret;
 	}
-	do_set_pte(vma, address, vmf->page, pte, true, false);
-	pte_unmap_unlock(pte, ptl);
 
 	if (set_page_dirty(vmf->page))
 		dirtied = 1;
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
