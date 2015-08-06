Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id BD8C66B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 04:11:03 -0400 (EDT)
Received: by oip136 with SMTP id 136so33504544oip.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 01:11:03 -0700 (PDT)
Received: from BLU004-OMC1S26.hotmail.com (blu004-omc1s26.hotmail.com. [65.55.116.37])
        by mx.google.com with ESMTPS id o184si4140975oia.77.2015.08.06.01.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Aug 2015 01:11:03 -0700 (PDT)
Message-ID: <BLU436-SMTP128848C012F916D3DFC86B80740@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH] mm/hwpoison: fix page refcount of unkown non LRU page
Date: Thu, 6 Aug 2015 16:09:37 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <wanpeng.li@hotmail.com>

After try to drain pages from pagevec/pageset, we try to get reference
count of the page again, however, the reference count of the page is 
not reduced if the page is still not on LRU list. This patch fix it by 
adding the put_page() to drop the page reference which is from 
__get_any_page().

Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com> 
---
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
