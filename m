Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29DD06B0288
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:31 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q5so7783361pll.17
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si4874128pgn.253.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 18/64] mm/ksm: teach about range locking
Date: Mon,  5 Feb 2018 02:27:08 +0100
Message-Id: <20180205012754.23615-19-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Conversion is straightforward as most calls use mmap_sem
within the same function context. No changes in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/ksm.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 66c350cd9799..c7d62c367ffc 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -526,11 +526,11 @@ static void break_cow(struct rmap_item *rmap_item)
 	 */
 	put_anon_vma(rmap_item->anon_vma);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, addr);
 	if (vma)
 		break_ksm(vma, addr, &mmrange);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 }
 
 static struct page *get_mergeable_page(struct rmap_item *rmap_item)
@@ -539,8 +539,9 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
 	struct page *page;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, addr);
 	if (!vma)
 		goto out;
@@ -556,7 +557,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 out:
 		page = NULL;
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return page;
 }
 
@@ -936,7 +937,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	for (mm_slot = ksm_scan.mm_slot;
 			mm_slot != &ksm_mm_head; mm_slot = ksm_scan.mm_slot) {
 		mm = mm_slot->mm;
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		for (vma = mm->mmap; vma; vma = vma->vm_next) {
 			if (ksm_test_exit(mm))
 				break;
@@ -949,7 +950,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		}
 
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -972,7 +973,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 	return 0;
 
 error:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = &ksm_mm_head;
 	spin_unlock(&ksm_mmlist_lock);
@@ -1251,8 +1252,9 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	struct mm_struct *mm = rmap_item->mm;
 	struct vm_area_struct *vma;
 	int err = -EFAULT;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	vma = find_mergeable_vma(mm, rmap_item->address);
 	if (!vma)
 		goto out;
@@ -1268,7 +1270,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
 	rmap_item->anon_vma = vma->anon_vma;
 	get_anon_vma(vma->anon_vma);
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return err;
 }
 
@@ -2071,12 +2073,13 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	 */
 	if (ksm_use_zero_pages && (checksum == zero_checksum)) {
 		struct vm_area_struct *vma;
+		DEFINE_RANGE_LOCK_FULL(mmrange);
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		vma = find_mergeable_vma(mm, rmap_item->address);
 		err = try_to_merge_one_page(vma, page,
 					    ZERO_PAGE(rmap_item->address));
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/*
 		 * In case of failure, the page was not really empty, so we
 		 * need to continue. Otherwise we're done.
@@ -2154,6 +2157,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
 	int nid;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -2210,7 +2214,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	}
 
 	mm = slot->mm;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	if (ksm_test_exit(mm))
 		vma = NULL;
 	else
@@ -2244,7 +2248,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 					ksm_scan.address += PAGE_SIZE;
 				} else
 					put_page(*page);
-				up_read(&mm->mmap_sem);
+				mm_read_unlock(mm, &mmrange);
 				return rmap_item;
 			}
 			put_page(*page);
@@ -2282,10 +2286,10 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		mmdrop(mm);
 	} else {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/*
 		 * up_read(&mm->mmap_sem) first because after
 		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
@@ -2474,8 +2478,10 @@ void __ksm_exit(struct mm_struct *mm)
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
 		mmdrop(mm);
 	} else if (mm_slot) {
-		down_write(&mm->mmap_sem);
-		up_write(&mm->mmap_sem);
+		DEFINE_RANGE_LOCK_FULL(mmrange);
+
+		mm_write_lock(mm, &mmrange);
+		mm_write_unlock(mm, &mmrange);
 	}
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
