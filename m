Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B62BF6B008C
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 10:33:50 -0500 (EST)
Received: by mail-iy0-f169.google.com with SMTP id 17so4366711iyj.14
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 07:33:47 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/7] tlbfs: Change remove_from_page_cache
Date: Thu, 23 Dec 2010 00:32:45 +0900
Message-Id: <8fb992356ab4f24f0bcb47b8a59b298508e48745.1293031046.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293031046.git.minchan.kim@gmail.com>
References: <cover.1293031046.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1293031046.git.minchan.kim@gmail.com>
References: <cover.1293031046.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This patch series changes remove_from_page_cache's page ref counting
rule. Page cache ref count is decreased in delete_from_page_cache.
So we don't need decreasing page reference by caller.

Cc: William Irwin <wli@holomorphy.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/hugetlbfs/inode.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9885082..b9eeb1c 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -332,8 +332,7 @@ static void truncate_huge_page(struct page *page)
 {
 	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
 	ClearPageUptodate(page);
-	remove_from_page_cache(page);
-	put_page(page);
+	delete_from_page_cache(page);
 }
 
 static void truncate_hugepages(struct inode *inode, loff_t lstart)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
