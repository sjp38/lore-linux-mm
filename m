Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 045AB6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 00:05:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b62so55799791pfa.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 21:05:14 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id lv5si13536546pab.152.2016.07.21.21.04.50
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 21:05:14 -0700 (PDT)
From: Zhou Chengming <zhouchengming1@huawei.com>
Subject: [PATCH] update sc->nr_reclaimed after each shrink_slab
Date: Fri, 22 Jul 2016 11:43:30 +0800
Message-ID: <1469159010-5636-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, riel@redhat.com, mhocko@suse.com, guohanjun@huawei.com, zhouchengming1@huawei.com

In !global_reclaim(sc) case, we should update sc->nr_reclaimed after each
shrink_slab in the loop. Because we need the correct sc->nr_reclaimed
value to see if we can break out.

Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
---
 mm/vmscan.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4a2f45..47133c3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2405,6 +2405,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
+			if (!global_reclaim(sc) && reclaim_state) {
+				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+				reclaim_state->reclaimed_slab = 0;
+			}
+
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
 				   sc->nr_scanned - scanned,
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
