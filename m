Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14CB06B03E5
	for <linux-mm@kvack.org>; Tue,  9 May 2017 04:18:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e8so81785362pfl.4
        for <linux-mm@kvack.org>; Tue, 09 May 2017 01:18:46 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id z2si12363059pgc.277.2017.05.09.01.18.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 01:18:45 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: fix the memory leak after collapsing the huge page fails
Date: Tue, 9 May 2017 16:12:37 +0800
Message-ID: <1494317557-49680-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, hannes@cmpxchg.org, vbabka@suse.cz, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Current, when we prepare a huge page to collapse, due to some
reasons, it can fail to collapse. At the moment, we should
release the preallocate huge page.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/khugepaged.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7cb9c88..3f5749e 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1080,6 +1080,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	result = SCAN_SUCCEED;
 out_up_write:
 	up_write(&mm->mmap_sem);
+	put_page(new_page);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
