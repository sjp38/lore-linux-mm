Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44BF06B069C
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:42 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id w7-v6so634483pgi.3
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1-v6sor7829870plr.70.2018.11.08.22.47.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:40 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 05/11] mm: hwpoison-inject: don't pin for hwpoison_filter()
Date: Fri,  9 Nov 2018 15:47:09 +0900
Message-Id: <1541746035-13408-6-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Another memory error injection interface debugfs:hwpoison/corrupt-pfn
also takes bogus refcount for hwpoison_filter(). It's justified
because this does a coarse filter, expecting that memory_failure()
redoes the check for sure.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hwpoison-inject.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/hwpoison-inject.c v4.19-mmotm-2018-10-30-16-08_patched/mm/hwpoison-inject.c
index b6ac706..766062c 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/hwpoison-inject.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/hwpoison-inject.c
@@ -25,11 +25,6 @@ static int hwpoison_inject(void *data, u64 val)
 
 	p = pfn_to_page(pfn);
 	hpage = compound_head(p);
-	/*
-	 * This implies unable to support free buddy pages.
-	 */
-	if (!get_hwpoison_page(p))
-		return 0;
 
 	if (!hwpoison_filter_enable)
 		goto inject;
@@ -39,23 +34,20 @@ static int hwpoison_inject(void *data, u64 val)
 	 * This implies unable to support non-LRU pages.
 	 */
 	if (!PageLRU(hpage) && !PageHuge(p))
-		goto put_out;
+		return 0;
 
 	/*
-	 * do a racy check with elevated page count, to make sure PG_hwpoison
-	 * will only be set for the targeted owner (or on a free page).
+	 * do a racy check to make sure PG_hwpoison will only be set for
+	 * the targeted owner (or on a free page).
 	 * memory_failure() will redo the check reliably inside page lock.
 	 */
 	err = hwpoison_filter(hpage);
 	if (err)
-		goto put_out;
+		return 0;
 
 inject:
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
-	return memory_failure(pfn, MF_COUNT_INCREASED);
-put_out:
-	put_hwpoison_page(p);
-	return 0;
+	return memory_failure(pfn, 0);
 }
 
 static int hwpoison_unpoison(void *data, u64 val)
-- 
2.7.0
