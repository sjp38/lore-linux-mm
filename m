Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 579356B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 07:50:47 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so11197145igb.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 04:50:47 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id r37si9117399ioe.69.2015.12.03.04.50.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 04:50:46 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: account pglazyfreed exactly
Date: Thu,  3 Dec 2015 21:51:04 +0900
Message-Id: <1449147064-1345-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Minchan Kim <minchan@kernel.org>

If anon pages are zapped by unmapping between page_mapped check
and try_to_unmap in shrink_page_list, they could be !PG_dirty
although thre are not MADV_FREEed pages so that VM accoutns it
as pglazyfreed wrongly.

To fix, this patch counts the number of lazyfree ptes in
try_to_unmap_one and try_to_unmap returns SWAP_LZFREE only if
the count is not zero, page is !PG_dirty and SWAP_SUCCESS.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/rmap.h |  1 +
 mm/rmap.c            | 29 +++++++++++++++++++++++++----
 mm/vmscan.c          |  8 ++++++--
 3 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 04d2aec64e57..bdf597c4f0be 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -312,5 +312,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
+#define SWAP_LZFREE	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/rmap.c b/mm/rmap.c
index 321b633ee559..ffae0571c0ef 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1405,6 +1405,11 @@ void page_remove_rmap(struct page *page, bool compound)
 	 */
 }
 
+struct rmap_private {
+	enum ttu_flags flags;
+	int lazyfreed;
+};
+
 /*
  * @arg: enum ttu_flags will be passed to this argument
  */
@@ -1416,7 +1421,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	pte_t pteval;
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
-	enum ttu_flags flags = (enum ttu_flags)arg;
+	struct rmap_private *rp = arg;
+	enum ttu_flags flags = rp->flags;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1512,6 +1518,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		if (!PageDirty(page) && (flags & TTU_LZFREE)) {
 			/* It's a freeable page by MADV_FREE */
 			dec_mm_counter(mm, MM_ANONPAGES);
+			rp->lazyfreed++;
 			goto discard;
 		}
 
@@ -1588,9 +1595,14 @@ static int page_not_mapped(struct page *page)
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
 	int ret;
+	struct rmap_private rp = {
+		.flags = flags,
+		.lazyfreed = 0,
+	};
+
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)flags,
+		.arg = (void *)&rp,
 		.done = page_not_mapped,
 		.anon_lock = page_lock_anon_vma_read,
 	};
@@ -1610,8 +1622,11 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 
 	ret = rmap_walk(page, &rwc);
 
-	if (ret != SWAP_MLOCK && !page_mapped(page))
+	if (ret != SWAP_MLOCK && !page_mapped(page)) {
 		ret = SWAP_SUCCESS;
+		if (rp.lazyfreed && !PageDirty(page))
+			ret = SWAP_LZFREE;
+	}
 	return ret;
 }
 
@@ -1633,9 +1648,15 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 int try_to_munlock(struct page *page)
 {
 	int ret;
+
+	struct rmap_private rp = {
+		.flags = TTU_MUNLOCK,
+		.lazyfreed = 0,
+	};
+
 	struct rmap_walk_control rwc = {
 		.rmap_one = try_to_unmap_one,
-		.arg = (void *)TTU_MUNLOCK,
+		.arg = (void *)&rp,
 		.done = page_not_mapped,
 		.anon_lock = page_lock_anon_vma_read,
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c2f69445190c..97788c9ce58c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -909,6 +909,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
 		bool lazyfree = false;
+		int ret = SWAP_SUCCESS;
 
 		cond_resched();
 
@@ -1064,7 +1065,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, lazyfree ?
+			switch (ret = try_to_unmap(page, lazyfree ?
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
@@ -1073,6 +1074,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
+			case SWAP_LZFREE:
+				goto lazyfree;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1179,6 +1182,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
+lazyfree:
 		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 
@@ -1191,7 +1195,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		__ClearPageLocked(page);
 free_it:
-		if (lazyfree && !PageDirty(page))
+		if (ret == SWAP_LZFREE)
 			count_vm_event(PGLAZYFREED);
 
 		nr_reclaimed++;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
