Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6D29A6B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 04:17:35 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so1641895pdb.11
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 01:17:35 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id cd8si11613413pdb.107.2015.01.18.01.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 01:17:34 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id fp1so9437460pdb.2
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 01:17:33 -0800 (PST)
From: Hui Zhu <teawater@gmail.com>
Subject: [PATCH] mm/page_alloc: Fix race conditions on getting migratetype in buffered_rmqueue
Date: Sun, 18 Jan 2015 17:17:14 +0800
Message-Id: <1421572634-3399-1-git-send-email-teawater@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, rientjes@google.com, iamjoonsoo.kim@lge.com, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

From: Hui Zhu <zhuhui@xiaomi.com>

To test the patch [1], I use KGTP and a script [2] to show NR_FREE_CMA_PAGES
and gross of cma_nr_free.  The values are always not same.
I check the code of pages alloc and free and found that race conditions
on getting migratetype in buffered_rmqueue.
Then I add move the code of getting migratetype inside the zone->lock
protection part.

Because this issue will affect system even if the Linux kernel does't
have [1].  So I post this patch separately.

This patchset is based on fc7f0dd381720ea5ee5818645f7d0e9dece41cb0.

[1] https://lkml.org/lkml/2015/1/18/28
[2] https://github.com/teawater/kgtp/blob/dev/add-ons/cma_free.py

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/page_alloc.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..f3d6922 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1694,11 +1694,12 @@ again:
 		}
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
+		if (page)
+			migratetype = get_pageblock_migratetype(page);
+		else
+			goto failed_unlock;
 		spin_unlock(&zone->lock);
-		if (!page)
-			goto failed;
-		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_freepage_migratetype(page));
+		__mod_zone_freepage_state(zone, -(1 << order), migratetype);
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
@@ -1715,6 +1716,8 @@ again:
 		goto again;
 	return page;
 
+failed_unlock:
+	spin_unlock(&zone->lock);
 failed:
 	local_irq_restore(flags);
 	return NULL;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
