Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 36FB76B0036
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 03:54:02 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so10689647wes.11
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 00:54:01 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id bg2si4909704wjb.157.2013.12.05.00.53.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 00:54:01 -0800 (PST)
Message-ID: <52A03EE4.6030609@huawei.com>
Date: Thu, 5 Dec 2013 16:52:52 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: do_mincore() cleanup
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi <qiuxishi@huawei.com>

Two cleanups:
1. remove redundant codes for hugetlb pages.
2. end = pmd_addr_end(addr, end) restricts [addr, end) within PMD_SIZE,
   this may increase do_mincore() calls, remove it.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/mincore.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index da2be56..1016233 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -225,13 +225,6 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
 
-	if (is_vm_hugetlb_page(vma)) {
-		mincore_hugetlb_page_range(vma, addr, end, vec);
-		return (end - addr) >> PAGE_SHIFT;
-	}
-
-	end = pmd_addr_end(addr, end);
-
 	if (is_vm_hugetlb_page(vma))
 		mincore_hugetlb_page_range(vma, addr, end, vec);
 	else
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
