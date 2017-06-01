Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1AEB6B0292
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id s131so31841747itd.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:08 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id m7si1220178ite.18.2017.06.01.01.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:08 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id d68so4475626ita.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:07 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 1/9] mm: hugetlb: prevent reuse of hwpoisoned free hugepages
Date: Thu,  1 Jun 2017 17:16:51 +0900
Message-Id: <1496305019-5493-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

We no longer use MIGRATE_ISOLATE to prevent reuse of hwpoison hugepages
as we did before. So current dequeue_huge_page_node() doesn't work as
intended because it still uses is_migrate_isolate_page() for this check.
This patch fixes it with PageHWPoison flag.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c        | 3 +--
 mm/memory-failure.c | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git v4.12-rc3/mm/hugetlb.c v4.12-rc3_patched/mm/hugetlb.c
index e582887..6d6c659 100644
--- v4.12-rc3/mm/hugetlb.c
+++ v4.12-rc3_patched/mm/hugetlb.c
@@ -22,7 +22,6 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
-#include <linux/page-isolation.h>
 #include <linux/jhash.h>
 
 #include <asm/page.h>
@@ -872,7 +871,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 	struct page *page;
 
 	list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
-		if (!is_migrate_isolate_page(page))
+		if (!PageHWPoison(page))
 			break;
 	/*
 	 * if 'non-isolated free hugepage' not found on the list,
diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index 2527dfed..6c1a7c9 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -49,7 +49,6 @@
 #include <linux/swap.h>
 #include <linux/backing-dev.h>
 #include <linux/migrate.h>
-#include <linux/page-isolation.h>
 #include <linux/suspend.h>
 #include <linux/slab.h>
 #include <linux/swapops.h>
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
