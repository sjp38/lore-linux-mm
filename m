Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B35616B0694
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:32 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g24-v6so752790pfi.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s17-v6sor7675424plp.3.2018.11.08.22.47.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:31 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 01/11] mm: hwpoison: cleanup unused PageHuge() check
Date: Fri,  9 Nov 2018 15:47:05 +0900
Message-Id: <1541746035-13408-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

memory_failure() forks to memory_failure_hugetlb() for hugetlb pages,
so a PageHuge() check after the fork should not be necessary.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
index 0cd3de3..9f09bf3 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/memory-failure.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/memory-failure.c
@@ -1357,10 +1357,7 @@ int memory_failure(unsigned long pfn, int flags)
 	 * page_remove_rmap() in try_to_unmap_one(). So to determine page status
 	 * correctly, we save a copy of the page flags at this time.
 	 */
-	if (PageHuge(p))
-		page_flags = hpage->flags;
-	else
-		page_flags = p->flags;
+	page_flags = p->flags;
 
 	/*
 	 * unpoison always clear PG_hwpoison inside page lock
-- 
2.7.0
