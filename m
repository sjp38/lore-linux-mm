Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8C76B0268
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:47:45 -0500 (EST)
Received: by lfdl133 with SMTP id l133so18889796lfd.2
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:47:44 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l86si10033298lfi.120.2015.11.24.04.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 04:47:43 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] vmscan: fix slab vs lru balance
Date: Tue, 24 Nov 2015 15:47:21 +0300
Message-ID: <1448369241-26593-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The comment to shrink_slab states that the portion of kmem objects
scanned by it equals the portion of lru pages scanned by shrink_zone
over shrinker->seeks.

shrinker->seeks is supposed to be equal to the number of disk seeks
required to recreated an object. It is usually set to DEFAULT_SEEKS (2),
which is quite logical, because most kmem objects (e.g. dentry or inode)
require random IO to reread (seek to read and seek back).

That said, one would expect that dcache is scanned two times less
intensively than page cache, which sounds sane as dentries are generally
more costly to recreate.

However, the formula for distributing memory pressure between slab and
lru actually looks as follows (see do_shrink_slab):

                              lru_scanned
objs_to_scan = objs_total * --------------- * 4 / shrinker->seeks
                            lru_reclaimable

That is dcache, as well as most of other slab caches, is scanned two
times more aggressively than page cache.

Fix this by dropping '4' from the equation above.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 97ba9e1cde09..9d553b07bb86 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -290,7 +290,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
 	total_scan = nr;
-	delta = (4 * nr_scanned) / shrinker->seeks;
+	delta = nr_scanned / shrinker->seeks;
 	delta *= freeable;
 	do_div(delta, nr_eligible + 1);
 	total_scan += delta;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
