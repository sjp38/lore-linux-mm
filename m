Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF176B01D0
	for <linux-mm@kvack.org>; Thu, 27 May 2010 20:32:52 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 8/8] HWPOISON, hugetlb: support hwpoison injection for hugepage
Date: Fri, 28 May 2010 09:29:22 +0900
Message-Id: <1275006562-18946-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch enables hwpoison injection through debug/hwpoison interfaces,
with which we can test memory error handling for free or reserved
hugepages (which cannot be tested by madvise() injector).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/hwpoison-inject.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git v2.6.34/mm/hwpoison-inject.c v2.6.34/mm/hwpoison-inject.c
index 10ea719..0948f10 100644
--- v2.6.34/mm/hwpoison-inject.c
+++ v2.6.34/mm/hwpoison-inject.c
@@ -5,6 +5,7 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/pagemap.h>
+#include <linux/hugetlb.h>
 #include "internal.h"
 
 static struct dentry *hwpoison_dir;
@@ -13,6 +14,7 @@ static int hwpoison_inject(void *data, u64 val)
 {
 	unsigned long pfn = val;
 	struct page *p;
+	struct page *hpage;
 	int err;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -24,18 +26,19 @@ static int hwpoison_inject(void *data, u64 val)
 		return -ENXIO;
 
 	p = pfn_to_page(pfn);
+	hpage = compound_head(p);
 	/*
 	 * This implies unable to support free buddy pages.
 	 */
-	if (!get_page_unless_zero(p))
+	if (!get_page_unless_zero(hpage))
 		return 0;
 
-	if (!PageLRU(p))
+	if (!PageLRU(p) && !PageHuge(p))
 		shake_page(p, 0);
 	/*
 	 * This implies unable to support non-LRU pages.
 	 */
-	if (!PageLRU(p))
+	if (!PageLRU(p) && !PageHuge(p))
 		return 0;
 
 	/*
@@ -44,9 +47,9 @@ static int hwpoison_inject(void *data, u64 val)
 	 * We temporarily take page lock for try_get_mem_cgroup_from_page().
 	 * __memory_failure() will redo the check reliably inside page lock.
 	 */
-	lock_page(p);
-	err = hwpoison_filter(p);
-	unlock_page(p);
+	lock_page(hpage);
+	err = hwpoison_filter(hpage);
+	unlock_page(hpage);
 	if (err)
 		return 0;
 
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
