Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C40D6B025F
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 03:10:08 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so4464316pfj.4
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 00:10:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o1si2236324pld.566.2017.09.19.00.10.06
        for <linux-mm@kvack.org>;
        Tue, 19 Sep 2017 00:10:06 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/4] mm:swap: skip swapcache for swapin of synchronous device
Date: Tue, 19 Sep 2017 16:10:01 +0900
Message-Id: <1505805001-30187-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1505805001-30187-1-git-send-email-minchan@kernel.org>
References: <1505805001-30187-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team <kernel-team@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>

With fast swap storage, platform want to use swap more aggressively
and swap-in is crucial to application latency.

The rw_page based synchronous devices like zram, pmem and btt are such
fast storage. When I profile swapin performance with zram lz4 decompress
test, S/W overhead is more than 70%. Maybe, it would be bigger in nvdimm.

This patch aims for reducing swap-in latency via skipping swapcache
if swap device is synchronous device like rw_page based device.
It enhances 45% my swapin test(5G sequential swapin, no readahead,
from 2.41sec to 1.64sec).

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 11 +++++++++++
 mm/memory.c          | 52 ++++++++++++++++++++++++++++++++++++----------------
 mm/page_io.c         |  6 +++---
 mm/swapfile.c        | 11 +++++++----
 4 files changed, 57 insertions(+), 23 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index fbb33919d1c6..cd2f66fdfc2d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -461,6 +461,7 @@ extern int page_swapcount(struct page *);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
+extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
 extern bool reuse_swap_page(struct page *, int *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
@@ -469,6 +470,16 @@ extern void exit_swap_address_space(unsigned int type);
 
 #else /* CONFIG_SWAP */
 
+static inline int swap_readpage(struct page *page, bool do_poll)
+{
+	return 0;
+}
+
+static inline struct swap_info_struct *swp_swap_info(swp_entry_t entry)
+{
+	return NULL;
+}
+
 #define swap_address_space(entry)		(NULL)
 #define get_nr_swap_pages()			0L
 #define total_swap_pages			0L
diff --git a/mm/memory.c b/mm/memory.c
index ec4e15494901..163ab2062385 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2842,7 +2842,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
 int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *page = NULL, *swapcache;
+	struct page *page = NULL, *swapcache = NULL;
 	struct mem_cgroup *memcg;
 	struct vma_swap_readahead swap_ra;
 	swp_entry_t entry;
@@ -2881,17 +2881,35 @@ int do_swap_page(struct vm_fault *vmf)
 		}
 		goto out;
 	}
+
+
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	if (!page)
 		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
 					 vmf->address);
 	if (!page) {
-		if (vma_readahead)
-			page = do_swap_page_readahead(entry,
-				GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
-		else
-			page = swapin_readahead(entry,
-				GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+		struct swap_info_struct *si = swp_swap_info(entry);
+
+		if (!(si->flags & SWP_SYNCHRONOUS_IO)) {
+			if (vma_readahead)
+				page = do_swap_page_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
+			else
+				page = swapin_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			swapcache = page;
+		} else {
+			/* skip swapcache */
+			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			if (page) {
+				__SetPageLocked(page);
+				__SetPageSwapBacked(page);
+				set_page_private(page, entry.val);
+				lru_cache_add_anon(page);
+				swap_readpage(page, true);
+			}
+		}
+
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
@@ -2920,7 +2938,6 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out_release;
 	}
 
-	swapcache = page;
 	locked = lock_page_or_retry(page, vma->vm_mm, vmf->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2935,7 +2952,8 @@ int do_swap_page(struct vm_fault *vmf)
 	 * test below, are not enough to exclude that.  Even if it is still
 	 * swapcache, we need to check that the page's swap has not changed.
 	 */
-	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
+	if (unlikely((!PageSwapCache(page) ||
+			page_private(page) != entry.val)) && swapcache)
 		goto out_page;
 
 	page = ksm_might_need_to_copy(page, vma, vmf->address);
@@ -2988,14 +3006,16 @@ int do_swap_page(struct vm_fault *vmf)
 		pte = pte_mksoft_dirty(pte);
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	vmf->orig_pte = pte;
-	if (page == swapcache) {
-		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
-		mem_cgroup_commit_charge(page, memcg, true, false);
-		activate_page(page);
-	} else { /* ksm created a completely new copy */
+
+	/* ksm created a completely new copy */
+	if (unlikely(page != swapcache && swapcache)) {
 		page_add_new_anon_rmap(page, vma, vmf->address, false);
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
+	} else {
+		do_page_add_anon_rmap(page, vma, vmf->address, exclusive);
+		mem_cgroup_commit_charge(page, memcg, true, false);
+		activate_page(page);
 	}
 
 	swap_free(entry);
@@ -3003,7 +3023,7 @@ int do_swap_page(struct vm_fault *vmf)
 	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
-	if (page != swapcache) {
+	if (page != swapcache && swapcache) {
 		/*
 		 * Hold the lock to avoid the swap entry to be reused
 		 * until we take the PT lock for the pte_same() check
@@ -3036,7 +3056,7 @@ int do_swap_page(struct vm_fault *vmf)
 	unlock_page(page);
 out_release:
 	put_page(page);
-	if (page != swapcache) {
+	if (page != swapcache && swapcache) {
 		unlock_page(swapcache);
 		put_page(swapcache);
 	}
diff --git a/mm/page_io.c b/mm/page_io.c
index 21502d341a67..d4a98e1f6608 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -346,7 +346,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	return ret;
 }
 
-int swap_readpage(struct page *page, bool do_poll)
+int swap_readpage(struct page *page, bool synchronous)
 {
 	struct bio *bio;
 	int ret = 0;
@@ -354,7 +354,7 @@ int swap_readpage(struct page *page, bool do_poll)
 	blk_qc_t qc;
 	struct gendisk *disk;
 
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+	VM_BUG_ON_PAGE(!PageSwapCache(page) && !synchronous, page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageUptodate(page), page);
 	if (frontswap_load(page) == 0) {
@@ -402,7 +402,7 @@ int swap_readpage(struct page *page, bool do_poll)
 	count_vm_event(PSWPIN);
 	bio_get(bio);
 	qc = submit_bio(bio);
-	while (do_poll) {
+	while (synchronous) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		if (!READ_ONCE(bio->bi_private))
 			break;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 1305591cde4d..64a3d85226ba 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3454,10 +3454,15 @@ int swapcache_prepare(swp_entry_t entry)
 	return __swap_duplicate(entry, SWAP_HAS_CACHE);
 }
 
+struct swap_info_struct *swp_swap_info(swp_entry_t entry)
+{
+	return swap_info[swp_type(entry)];
+}
+
 struct swap_info_struct *page_swap_info(struct page *page)
 {
-	swp_entry_t swap = { .val = page_private(page) };
-	return swap_info[swp_type(swap)];
+	swp_entry_t entry = { .val = page_private(page) };
+	return swp_swap_info(entry);
 }
 
 /*
@@ -3465,7 +3470,6 @@ struct swap_info_struct *page_swap_info(struct page *page)
  */
 struct address_space *__page_file_mapping(struct page *page)
 {
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	return page_swap_info(page)->swap_file->f_mapping;
 }
 EXPORT_SYMBOL_GPL(__page_file_mapping);
@@ -3473,7 +3477,6 @@ EXPORT_SYMBOL_GPL(__page_file_mapping);
 pgoff_t __page_file_index(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
-	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	return swp_offset(swap);
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
