Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA5436B01F1
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 19:56:48 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/8] hugetlb: fix metadata corruption in hugetlb_fault()
Date: Wed, 25 Aug 2010 08:55:20 +0900
Message-Id: <1282694127-14609-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

In order to avoid metadata corruption when memory failure occurs between
alloc_huge_page() and lock_page().
The corruption occurs because page fault can fail with metadata changes
remained (such as refcount, mapcount, etc.)
Since the PageHWPoison() check is for avoiding hwpoisoned page remained
in pagecache mapping to the process, it should be done in "found in pagecache"
branch, not in the common path.
This patch moves the check to "found in pagecache" branch and fix the problem.

ChangeLog since v2:
- remove retry check in "new allocation" path.
- make description more detailed
- change patch name from "HWPOISON, hugetlb: move PG_HWPoison bit check"

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
---
 mm/hugetlb.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git v2.6.36-rc2/mm/hugetlb.c v2.6.36-rc2/mm/hugetlb.c
index cc5be78..6871b41 100644
--- v2.6.36-rc2/mm/hugetlb.c
+++ v2.6.36-rc2/mm/hugetlb.c
@@ -2518,22 +2518,19 @@ retry:
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
