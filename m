Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C82756B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:22:13 -0500 (EST)
Received: by pacej9 with SMTP id ej9so11379861pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 22:22:13 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 28si24746388pfk.134.2015.11.23.22.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 22:22:12 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so11327137pac.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 22:22:12 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] mm/vmstat: retrieve more accurate vmstat value
Date: Tue, 24 Nov 2015 15:22:03 +0900
Message-Id: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When I tested compaction in low memory condition, I found that
my benchmark is stuck in congestion_wait() at shrink_inactive_list().
This stuck last for 1 sec and after then it can escape. More investigation
shows that it is due to stale vmstat value. vmstat is updated every 1 sec
so it is stuck for 1 sec.

I guess that it is caused by updating NR_ISOLATED_XXX. In direct
reclaim/compaction, it would isolate some pages. After some processing,
they are returned to lru or freed and NR_ISOLATED_XXX is adjusted so
it should be recover to zero. But, it would be possible that some
updatings are appiled to global but some are applied only to per cpu
variable. In this case, zone_page_state() would return stale value so
it can be stuck.

This problem can be solved by adjusting zone_page_state() with this
cpu's vmstat value. It's sub-optimal because the other task in other cpu
can be stuck due to stale vmstat value but, at least, it can solve
some usecases without adding much overhead so I think that it is worth
to doing it. With this change, I can't find any stuck in my test.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/vmstat.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 62af0f8..7c84896 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -133,6 +133,9 @@ static inline unsigned long zone_page_state(struct zone *zone,
 {
 	long x = atomic_long_read(&zone->vm_stat[item]);
 #ifdef CONFIG_SMP
+	long diff = this_cpu_read(zone->pageset->vm_stat_diff[item]);
+
+	x += diff;
 	if (x < 0)
 		x = 0;
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
