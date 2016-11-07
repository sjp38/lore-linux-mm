Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 454816B0266
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:32:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so36048422pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:35 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id c73si33408116pfj.76.2016.11.07.15.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:34 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y68so17348423pfb.1
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:34 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 09/12] mm: hwpoison: soft offline supports thp migration
Date: Tue,  8 Nov 2016 08:31:54 +0900
Message-Id: <1478561517-4317-10-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patch enables thp migration for soft offline.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
index 19e796d..6cc8157 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
@@ -1485,7 +1485,17 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 	if (PageHuge(p))
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 						   nid);
-	else
+	else if (thp_migration_supported() && PageTransHuge(p)) {
+		struct page *thp;
+
+		thp = alloc_pages_node(nid,
+			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+			HPAGE_PMD_ORDER);
+		if (!thp)
+			return NULL;
+		prep_transhuge_page(thp);
+		return thp;
+	} else
 		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
 
@@ -1687,28 +1697,11 @@ static int __soft_offline_page(struct page *page, int flags)
 static int soft_offline_in_use_page(struct page *page, int flags)
 {
 	int ret;
-	struct page *hpage = compound_head(page);
-
-	if (!PageHuge(page) && PageTransHuge(hpage)) {
-		lock_page(hpage);
-		if (!PageAnon(hpage) || unlikely(split_huge_page(hpage))) {
-			unlock_page(hpage);
-			if (!PageAnon(hpage))
-				pr_info("soft offline: %#lx: non anonymous thp\n", page_to_pfn(page));
-			else
-				pr_info("soft offline: %#lx: thp split failed\n", page_to_pfn(page));
-			put_hwpoison_page(hpage);
-			return -EBUSY;
-		}
-		unlock_page(hpage);
-		get_hwpoison_page(page);
-		put_hwpoison_page(hpage);
-	}
 
 	if (PageHuge(page))
 		ret = soft_offline_huge_page(page, flags);
 	else
-		ret = __soft_offline_page(page, flags);
+		ret = __soft_offline_page(compound_head(page), flags);
 
 	return ret;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
