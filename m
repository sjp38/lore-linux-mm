Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id E60AD6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 07:55:50 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so4165101pbc.1
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 04:55:50 -0700 (PDT)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id gg2si15402177pbb.253.2014.06.02.04.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 04:55:49 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so4134882pbb.31
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 04:55:49 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] swap: Delete  the "last_in_cluster < scan_base" loop in the body of scan_swap_map()
Date: Mon,  2 Jun 2014 19:54:13 +0800
Message-Id: <1401710053-8460-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shli@kernel.org
Cc: hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

>From commit ebc2a1a69111, we can find that all SWP_SOLIDSTATE "seek is cheap"(SSD case) 
has already gone to si->cluster_info scan_swap_map_try_ssd_cluster() route. So that the
"last_in_cluster < scan_base" loop in the body of scan_swap_map() has already become a 
dead code snippet, and it should have been deleted.

This patch is to delete the redundant loop as Hugh and Shaohua suggested.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/swapfile.c |   20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index beeeef8..1b44bd9 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -549,26 +549,6 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 			}
 		}
 
-		offset = si->lowest_bit;
-		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
-
-		/* Locate the first empty (unaligned) cluster */
-		for (; last_in_cluster < scan_base; offset++) {
-			if (si->swap_map[offset])
-				last_in_cluster = offset + SWAPFILE_CLUSTER;
-			else if (offset == last_in_cluster) {
-				spin_lock(&si->lock);
-				offset -= SWAPFILE_CLUSTER - 1;
-				si->cluster_next = offset;
-				si->cluster_nr = SWAPFILE_CLUSTER - 1;
-				goto checks;
-			}
-			if (unlikely(--latency_ration < 0)) {
-				cond_resched();
-				latency_ration = LATENCY_LIMIT;
-			}
-		}
-
 		offset = scan_base;
 		spin_lock(&si->lock);
 		si->cluster_nr = SWAPFILE_CLUSTER - 1;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
