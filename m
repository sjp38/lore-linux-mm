Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BAFE16B02C5
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:33:03 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/9] HWPOISON, hugetlb: move PG_HWPoison bit check
Date: Tue, 10 Aug 2010 18:27:36 +0900
Message-Id: <1281432464-14833-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In order to handle metadatum correctly, we should check whether the hugepage
we are going to access is HWPOISONed *before* incrementing mapcount,
adding the hugepage into pagecache or constructing anon_vma.
This patch also adds retry code when there is a race between
alloc_huge_page() and memory failure.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/hugetlb.c |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git linux-mce-hwpoison/mm/hugetlb.c linux-mce-hwpoison/mm/hugetlb.c
index a26c24a..5c77a73 100644
--- linux-mce-hwpoison/mm/hugetlb.c
+++ linux-mce-hwpoison/mm/hugetlb.c
@@ -2490,8 +2490,15 @@ retry:
 			int err;
 			struct inode *inode = mapping->host;
 
-			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
+			lock_page(page);
+			if (unlikely(PageHWPoison(page))) {
+				unlock_page(page);
+				goto retry;
+			}
+			err = add_to_page_cache_locked(page, mapping,
+						       idx, GFP_KERNEL);
 			if (err) {
+				unlock_page(page);
 				put_page(page);
 				if (err == -EEXIST)
 					goto retry;
@@ -2504,6 +2511,10 @@ retry:
 			page_dup_rmap(page);
 		} else {
 			lock_page(page);
+			if (unlikely(PageHWPoison(page))) {
+				unlock_page(page);
+				goto retry;
+			}
 			if (unlikely(anon_vma_prepare(vma))) {
 				ret = VM_FAULT_OOM;
 				goto backout_unlocked;
@@ -2511,22 +2522,19 @@ retry:
 			hugepage_add_new_anon_rmap(page, vma, address);
 		}
 	} else {
+		/*
+		 * If memory error occurs between mmap() and fault, some process
+		 * don't have hwpoisoned swap entry for errored virtual address.
+		 * So we need to block hugepage fault by PG_hwpoison bit check.
+		 */
+		if (unlikely(PageHWPoison(page))) {
+			ret = VM_FAULT_HWPOISON;
+			goto backout_unlocked;
+		}
 		page_dup_rmap(page);
 	}
 
 	/*
-	 * Since memory error handler replaces pte into hwpoison swap entry
-	 * at the time of error handling, a process which reserved but not have
-	 * the mapping to the error hugepage does not have hwpoison swap entry.
-	 * So we need to block accesses from such a process by checking
-	 * PG_hwpoison bit here.
-	 */
-	if (unlikely(PageHWPoison(page))) {
-		ret = VM_FAULT_HWPOISON;
-		goto backout_unlocked;
-	}
-
-	/*
 	 * If we are going to COW a private mapping later, we examine the
 	 * pending reservations for this page now. This will ensure that
 	 * any allocations necessary to record that reservation occur outside
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
