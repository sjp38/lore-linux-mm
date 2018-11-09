Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9C96B069A
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:39 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id l2-v6so609587pgp.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16-v6sor6947988pgh.17.2018.11.08.22.47.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:38 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 04/11] mm: madvise: call soft_offline_page() without MF_COUNT_INCREASED
Date: Fri,  9 Nov 2018 15:47:08 +0900
Message-Id: <1541746035-13408-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Currently madvise_inject_error() pins the target page when calling
memory error handler, but it's not good because the refcount is just
an artifact of error injector and mock nothing about hw error itself.
IOW, pinning the error page is part of error handler's task, so
let's stop doing it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/madvise.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/madvise.c v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
index 6cb1ca9..9fa0225 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/madvise.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
@@ -637,6 +637,16 @@ static int madvise_inject_error(int behavior,
 		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
+		/*
+		 * The get_user_pages_fast() is just to get the pfn of the
+		 * given address, and the refcount has nothing to do with
+		 * what we try to test, so it should be released immediately.
+		 * This is racy but it's intended because the real hardware
+		 * errors could happen at any moment and memory error handlers
+		 * must properly handle the race.
+		 */
+		put_page(page);
+
 		pfn = page_to_pfn(page);
 
 		/*
@@ -646,16 +656,11 @@ static int madvise_inject_error(int behavior,
 		 */
 		order = compound_order(compound_head(page));
 
-		if (PageHWPoison(page)) {
-			put_page(page);
-			continue;
-		}
-
 		if (behavior == MADV_SOFT_OFFLINE) {
 			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
 					pfn, start);
 
-			ret = soft_offline_page(page, MF_COUNT_INCREASED);
+			ret = soft_offline_page(page, 0);
 			if (ret)
 				return ret;
 			continue;
@@ -663,14 +668,6 @@ static int madvise_inject_error(int behavior,
 
 		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
 				pfn, start);
-
-		/*
-		 * Drop the page reference taken by get_user_pages_fast(). In
-		 * the absence of MF_COUNT_INCREASED the memory_failure()
-		 * routine is responsible for pinning the page to prevent it
-		 * from being released back to the page allocator.
-		 */
-		put_page(page);
 		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
-- 
2.7.0
