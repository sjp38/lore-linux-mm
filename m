Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C89826B005D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 16:47:54 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
Date: Wed,  5 Dec 2012 16:47:38 -0500
Message-Id: <1354744058-26373-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Memory error handling on hugepages can break a RSS counter, which emits
a message like "Bad rss-counter state mm:ffff88040abecac0 idx:1 val:-1".
This is because PageAnon returns true for hugepage (this behavior is
necessary for reverse mapping to work on hugetlbfs).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git v3.7-rc8.orig/mm/rmap.c v3.7-rc8/mm/rmap.c
index 2ee1ef0..df54ef0 100644
--- v3.7-rc8.orig/mm/rmap.c
+++ v3.7-rc8/mm/rmap.c
@@ -1235,7 +1235,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	update_hiwater_rss(mm);
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageAnon(page))
+		if (PageHuge(page))
+			;
+		else if (PageAnon(page))
 			dec_mm_counter(mm, MM_ANONPAGES);
 		else
 			dec_mm_counter(mm, MM_FILEPAGES);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
