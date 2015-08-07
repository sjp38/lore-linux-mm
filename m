Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id DBDB56B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 06:16:54 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so76023361obd.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 03:16:54 -0700 (PDT)
Received: from BLU004-OMC1S2.hotmail.com (blu004-omc1s2.hotmail.com. [65.55.116.13])
        by mx.google.com with ESMTPS id mz4si6957583obb.107.2015.08.07.03.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Aug 2015 03:16:53 -0700 (PDT)
Message-ID: <BLU436-SMTP25940E686DCAD5372EF47D780730@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 1/2] mm/hwpoison: fix page refcount of unkown non LRU page
Date: Fri, 7 Aug 2015 18:16:41 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>, stable@vger.kernel.org

After try to drain pages from pagevec/pageset, we try to get reference
count of the page again, however, the reference count of the page is 
not reduced if the page is still not on LRU list. This patch fix it by 
adding the put_page() to drop the page reference which is from 
__get_any_page().

Cc: <stable@vger.kernel.org> # 3.9+
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com> 
---
v1 -> v2:
 * add Cc stable

 mm/memory-failure.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index c53543d..23163d0 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1535,6 +1535,8 @@ static int get_any_page(struct page *page, unsigned long pfn, int flags)
 		 */
 		ret = __get_any_page(page, pfn, 0);
 		if (!PageLRU(page)) {
+			/* Drop page reference which is from __get_any_page() */
+			put_page(page);
 			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
 				pfn, page->flags);
 			return -EIO;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
