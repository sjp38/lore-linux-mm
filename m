Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E23D26B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:34:34 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fa1so2722755pad.10
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:34:34 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id g6si8394626pbd.54.2013.12.16.01.34.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 01:34:33 -0800 (PST)
Message-ID: <52AEC8FD.6050200@huawei.com>
Date: Mon, 16 Dec 2013 17:33:49 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hugetlb: check for pte NULL pointer in __page_check_address()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kirill.shutemov@linux.intel.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

In __page_check_address(), if address's pud is not present,
huge_pte_offset() will return NULL, we should check the return value.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/rmap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 55c8b8d..068522d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -600,7 +600,11 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 	spinlock_t *ptl;
 
 	if (unlikely(PageHuge(page))) {
+		/* when pud is not present, pte will be NULL */
 		pte = huge_pte_offset(mm, address);
+		if (!pte)
+			return NULL;
+
 		ptl = huge_pte_lockptr(page_hstate(page), mm, pte);
 		goto check;
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
