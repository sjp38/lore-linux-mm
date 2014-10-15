Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id E6BCA6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 15:20:20 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so1507609vcb.6
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 12:20:20 -0700 (PDT)
Received: from mail-vc0-x24a.google.com (mail-vc0-x24a.google.com [2607:f8b0:400c:c03::24a])
        by mx.google.com with ESMTPS id tp5si18726453vcb.67.2014.10.15.12.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 12:20:20 -0700 (PDT)
Received: by mail-vc0-f202.google.com with SMTP id hy10so146432vcb.1
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 12:20:19 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2 1/2] mm: free compound page with correct order
Date: Wed, 15 Oct 2014 12:20:04 -0700
Message-Id: <1413400805-15547-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Yu Zhao <yuzhao@google.com>

Compound page should be freed by put_page() or free_pages() with
correct order. Not doing so will cause tail pages leaked.

The compound order can be obtained by compound_order() or use
HPAGE_PMD_ORDER in our case. Some people would argue the latter
is faster but I prefer the former which is more general.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 97ae17497e99 ("thp: implement refcounting for huge zero page")
Cc: stable@vger.kernel.org (v3.8+)
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 74c78aa..780d12c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -200,7 +200,7 @@ retry:
 	preempt_disable();
 	if (cmpxchg(&huge_zero_page, NULL, zero_page)) {
 		preempt_enable();
-		__free_page(zero_page);
+		__free_pages(zero_page, compound_order(zero_page));
 		goto retry;
 	}
 
@@ -232,7 +232,7 @@ static unsigned long shrink_huge_zero_page_scan(struct shrinker *shrink,
 	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
 		struct page *zero_page = xchg(&huge_zero_page, NULL);
 		BUG_ON(zero_page == NULL);
-		__free_page(zero_page);
+		__free_pages(zero_page, compound_order(zero_page));
 		return HPAGE_PMD_NR;
 	}
 
-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
