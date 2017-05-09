Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0CC76B0388
	for <linux-mm@kvack.org>; Tue,  9 May 2017 07:25:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m128so11419632ita.15
        for <linux-mm@kvack.org>; Tue, 09 May 2017 04:25:21 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id b135si6828740iob.220.2017.05.09.04.25.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 04:25:20 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm: fix the memory leak after collapsing the huge page fails
Date: Tue, 9 May 2017 18:55:05 +0800
Message-ID: <1494327305-835-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Current, when we prepare a huge page to collapse, due to some
reasons, it can fail to collapse. At the moment, we should
release the preallocate huge page.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/khugepaged.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7cb9c88..586b1f1 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1082,6 +1082,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	up_write(&mm->mmap_sem);
 out_nolock:
 	trace_mm_collapse_huge_page(mm, isolated, result);
+	if (page != NULL && result != SCAN_SUCCEED)
+		put_page(new_page);
 	return;
 out:
 	mem_cgroup_cancel_charge(new_page, memcg, true);
@@ -1555,6 +1557,8 @@ static void collapse_shmem(struct mm_struct *mm,
 	}
 out:
 	VM_BUG_ON(!list_empty(&pagelist));
+	if (page != NULL && result != SCAN_SUCCEED)
+		put_page(new_page);
 	/* TODO: tracepoints */
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
