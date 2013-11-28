Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2CE6B0037
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 02:46:44 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so11527274pdj.18
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 23:46:44 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id ot3si25785247pac.166.2013.11.27.23.46.41
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 23:46:42 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/9] mm/rmap: recompute pgoff for huge page
Date: Thu, 28 Nov 2013 16:48:38 +0900
Message-Id: <1385624926-28883-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We have to recompute pgoff if the given page is huge, since result based
on HPAGE_SIZE is not approapriate for scanning the vma interval tree, as
shown by commit 36e4f20af833 ("hugetlb: do not use vma_hugecache_offset()
for vma_prio_tree_foreach") and commit 369a713e ("rmap: recompute pgoff
for unmapping huge page").

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/rmap.c b/mm/rmap.c
index 55c8b8d..1214703 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1714,6 +1714,10 @@ static int rmap_walk_file(struct page *page, int (*rmap_one)(struct page *,
 
 	if (!mapping)
 		return ret;
+
+	if (PageHuge(page))
+		pgoff = page->index << compound_order(page);
+
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
