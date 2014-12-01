Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 63B016B0072
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:05:21 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so26398116wiv.2
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:05:20 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id ev3si30078215wic.87.2014.12.01.04.05.20
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 04:05:20 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH 5/5] mm: Move the MMU-notifier code from wp_page_unlock to wp_page_copy
Date: Mon,  1 Dec 2014 14:04:45 +0200
Message-Id: <1417435485-24629-6-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com

The MMU-notifier code is needed only in case we copied a page. In the
original code, as the tail call was explicit, we had to handle it as a
special case there. However, now that the unlock flow is a separate
function, this is not the case. We explicitly call
mmu_notifier_invalidate_range_end in wp_page_copy, after finishing all
of the unlock logic. This also makes it much easier to see the pairing
of mmu_notifier_invalidate_range_start and
mmu_notifier_invalidate_range_end in the same function.

Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 mm/memory.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 8023cf3..68fab34 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2100,13 +2100,10 @@ static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
  */
 static int wp_page_unlock(struct mm_struct *mm, struct vm_area_struct *vma,
 			  pte_t *page_table, spinlock_t *ptl,
-			  unsigned long mmun_start, unsigned long mmun_end,
 			  struct page *old_page, int page_copied)
 	__releases(ptl)
 {
 	pte_unmap_unlock(page_table, ptl);
-	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
@@ -2143,6 +2140,7 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *new_page = NULL;
 	pte_t entry;
 	int page_copied = 0;
+	int ret = 0;
 	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
@@ -2238,8 +2236,9 @@ static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new_page)
 		page_cache_release(new_page);
 
-	return wp_page_unlock(mm, vma, page_table, ptl, mmun_start,
-			      mmun_end, old_page, page_copied);
+	ret = wp_page_unlock(mm, vma, page_table, ptl, old_page, page_copied);
+	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+	return ret;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
@@ -2283,7 +2282,6 @@ static int wp_page_shared_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (!pte_same(*page_table, orig_pte)) {
 			unlock_page(old_page);
 			return wp_page_unlock(mm, vma, page_table, ptl,
-					      0, 0,
 					      old_page, 0);
 		}
 
@@ -2352,7 +2350,6 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			if (!pte_same(*page_table, orig_pte)) {
 				unlock_page(old_page);
 				return wp_page_unlock(mm, vma, page_table, ptl,
-						      0, 0,
 						      old_page, 0);
 			}
 			page_cache_release(old_page);
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
