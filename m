Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CC1AC6B0038
	for <linux-mm@kvack.org>; Fri,  9 May 2014 23:14:40 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so4382033pdi.35
        for <linux-mm@kvack.org>; Fri, 09 May 2014 20:14:40 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id yi3si3165318pbb.183.2014.05.09.20.14.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 May 2014 20:14:40 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so5212566pab.0
        for <linux-mm@kvack.org>; Fri, 09 May 2014 20:14:39 -0700 (PDT)
Message-ID: <1399691674.29028.1.camel@cyc>
Subject: [PATCH] HWPOSION, hugetlb: lock_page/unlock_page does not match for
 handling a free hugepage
From: Chen Yucong <slaoub@gmail.com>
Date: Sat, 10 May 2014 11:14:34 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>

For handling a free hugepage in memory failure, the race will happen if
another thread hwpoisoned this hugepage concurrently. So we need to
check PageHWPoison instead of !PageHWPoison.

If hwpoison_filter(p) returns true or a race happens, then we need to
unlock_page(hpage).

Signed-off-by: Chen Yucong <slaoub@gmail.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
mm/memory-failure.c |   15 ++++++++-------
1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 35ef28a..dbf8922 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1081,15 +1081,16 @@ int memory_failure(unsigned long pfn, int
trapno, int flags)
 			return 0;
 		} else if (PageHuge(hpage)) {
 			/*
-			 * Check "just unpoisoned", "filter hit", and
-			 * "race with other subpage."
+			 * Check "filter hit" and "race with other subpage."
 			 */
 			lock_page(hpage);
-			if (!PageHWPoison(hpage)
-			    || (hwpoison_filter(p) && TestClearPageHWPoison(p))
-			    || (p != hpage && TestSetPageHWPoison(hpage))) {
-				atomic_long_sub(nr_pages, &num_poisoned_pages);
-				return 0;
+			if (PageHWPoison(hpage)) {
+				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
+				    || (p != hpage && TestSetPageHWPoison(hpage))) {
+					atomic_long_sub(nr_pages, &num_poisoned_pages);
+					unlock_page(hpage);
+					return 0;
+				}
 			}
 			set_page_hwpoison_huge_page(hpage);
 			res = dequeue_hwpoisoned_huge_page(hpage);
-- 
1.7.10.4






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
