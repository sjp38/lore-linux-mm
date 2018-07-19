Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80B666B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 12:04:59 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c27-v6so6961329qkj.3
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:04:59 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30102.outbound.protection.outlook.com. [40.107.3.102])
        by mx.google.com with ESMTPS id 22-v6si6363801qtt.370.2018.07.19.09.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Jul 2018 09:04:58 -0700 (PDT)
Subject: [PATCH] mm: Cleanup in do_shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 19 Jul 2018 19:04:51 +0300
Message-ID: <153201627722.12295.11034132843390627757.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, mhocko@suse.com, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Group long variables together to minimize number of occupied lines
and place all definitions in back Christmas tree order. Also,
simplify expression around batch_size: use all power of C language!

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9918bfc1d2f9..636657213b9b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -445,16 +445,11 @@ EXPORT_SYMBOL(unregister_shrinker);
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker, int priority)
 {
-	unsigned long freed = 0;
+	long total_scan, freeable, nr, new_nr, next_deferred, scanned = 0;
+	long batch_size = shrinker->batch ? : SHRINK_BATCH;
 	unsigned long long delta;
-	long total_scan;
-	long freeable;
-	long nr;
-	long new_nr;
 	int nid = shrinkctl->nid;
-	long batch_size = shrinker->batch ? shrinker->batch
-					  : SHRINK_BATCH;
-	long scanned = 0, next_deferred;
+	unsigned long freed = 0;
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0 || freeable == SHRINK_EMPTY)
