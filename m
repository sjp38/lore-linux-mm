Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id AE7326B0032
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 15:21:07 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:20:47 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377199247-2kdx6aoc-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] hwpoison: always unset MIGRATE_ISOLATE before returning from
 soft_offline_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Soft offline code expects that MIGRATE_ISOLATE is set on the target page
only during soft offlining work. But currenly it doesn't work as expected
when get_any_page() fails and returns negative value. In the result, end
users can have unexpectedly isolated pages. This patch just fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index af6f61c..1cb3b7d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1550,7 +1550,7 @@ int soft_offline_page(struct page *page, int flags)
 
 	ret = get_any_page(page, pfn, flags);
 	if (ret < 0)
-		return ret;
+		goto unset;
 	if (ret) { /* for in-use pages */
 		if (PageHuge(page))
 			ret = soft_offline_huge_page(page, flags);
@@ -1567,6 +1567,7 @@ int soft_offline_page(struct page *page, int flags)
 			atomic_long_inc(&num_poisoned_pages);
 		}
 	}
+unset:
 	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
