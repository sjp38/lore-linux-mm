Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A642B6B025B
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:42:26 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 4so10241489pfd.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:26 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id w9si25020792pfi.224.2016.03.02.23.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:42:26 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id fl4so10163031pad.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:42:25 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 07/11] mm: hwpoison: fix race between unpoisoning and freeing migrate source page
Date: Thu,  3 Mar 2016 16:41:54 +0900
Message-Id: <1456990918-30906-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

During testing thp migration, I saw the BUG_ON triggered due to the race between
soft offline and unpoison (what I actually saw was "bad page" warning of freeing
page with PageActive set, then subsequent bug messages differ each time.)

I tried to solve similar problem a few times (see commit f4c18e6f7b5b ("mm:
check __PG_HWPOISON separately from PAGE_FLAGS_CHECK_AT_*",) but the new
workload brings out a new problem of the previous solution.

Let's say that unpoison never works well if the target page is not properly
contained,) so now I'm going in the direction of limiting unpoison function
(as commit 230ac719c500 ("mm/hwpoison: don't try to unpoison containment-failed
pages" does). This patch takes another step in the direction by ensuring that
the target page is kicked out from any pcplist. With this change, the dirty hack
of calling put_page() instead of putback_lru_page() when migration reason is
MR_MEMORY_FAILURE is not necessary any more, so it's reverted.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 10 +++++++++-
 mm/migrate.c        |  8 +-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory-failure.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory-failure.c
index 67c30eb..bfb63c6 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/memory-failure.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/memory-failure.c
@@ -1431,6 +1431,13 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
 
+	/*
+	 * Soft-offlined pages might stay in PCP list because it's freed via
+	 * putback_lru_page(), and such pages shouldn't be unpoisoned because
+	 * it could cause list corruption. So let's drain pages to avoid that.
+	 */
+	shake_page(page, 0);
+
 	nr_pages = 1 << compound_order(page);
 
 	if (!get_hwpoison_page(p)) {
@@ -1674,7 +1681,8 @@ static int __soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret = -EIO;
-		}
+		} else if (!TestSetPageHWPoison(page))
+			num_poisoned_pages_inc();
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
 			pfn, ret, page_count(page), page->flags);
diff --git v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
index bd8bfa4..31bc724 100644
--- v4.5-rc5-mmotm-2016-02-24-16-18/mm/migrate.c
+++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/mm/migrate.c
@@ -994,13 +994,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE) {
-			put_page(page);
-			if (!test_set_page_hwpoison(page))
-				num_poisoned_pages_inc();
-		} else
-			putback_lru_page(page);
+		putback_lru_page(page);
 	}
 
 	/*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
