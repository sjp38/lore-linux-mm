Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E221D6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:05:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so392986157pfb.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:05:26 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 186si26138717pfy.175.2016.06.27.04.05.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Jun 2016 04:05:24 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH] mm, vmscan: set shrinker to the left page count
Date: Mon, 27 Jun 2016 19:02:15 +0800
Message-ID: <1467025335-6748-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: puck.chen@hisilicon.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, labbott@redhat.com
Cc: suzhuangluan@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com, dan.zhao@hisilicon.com, saberlily.xia@hisilicon.com, xuyiping@hisilicon.com

In my platform, there can be cache a lot of memory in
ion page pool. When shrink memory the nr_to_scan to ion
is always to little.
to_scan: 395  ion_pool_cached: 27305

Currently, the shrinker nr_deferred is set to total_scan.
But it's not the real left of the shrinker. Change it to
the freeable - freed.

Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c4a2f45..1ce3fc4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -357,8 +357,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * manner that handles concurrent updates. If we exhausted the
 	 * scan, there is no need to do an update.
 	 */
-	if (total_scan > 0)
-		new_nr = atomic_long_add_return(total_scan,
+	if (freeable - freed > 0)
+		new_nr = atomic_long_add_return(freeable - freed,
 						&shrinker->nr_deferred[nid]);
 	else
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
