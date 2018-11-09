Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0B06B06A8
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:53 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s141-v6so607129pgs.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z10-v6sor7712035pln.16.2018.11.08.22.47.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:52 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH v1 10/11] mm: clear PageHWPoison in memory hotremove
Date: Fri,  9 Nov 2018 15:47:14 +0900
Message-Id: <1541746035-13408-11-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

One hopeful usecase of memory hotplug is to replace half-broken DIMMs
with new ones, so it makes sense to clear hwpoison info at the time of
memory hotremove.

I hope that this patch covers the topic discussed in
https://lkml.org/lkml/2018/1/17/1228

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
index 970d6ff..27826b3 100644
--- v4.19-mmotm-2018-10-30-16-08/mm/page_alloc.c
+++ v4.19-mmotm-2018-10-30-16-08_patched/mm/page_alloc.c
@@ -8139,8 +8139,9 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
 		 */
-		if (unlikely(!PageBuddy(page) && PageHWPoison(page))) {
+		if (unlikely(!PageBuddy(page) && TestClearPageHWPoison(page))) {
 			pfn++;
+			num_poisoned_pages_dec();
 			SetPageReserved(page);
 			continue;
 		}
-- 
2.7.0
