Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BEFD46B000E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:20:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w19-v6so7890677plq.2
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:20:04 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id c2si6138972pgq.675.2018.03.23.08.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Mar 2018 08:20:03 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 2/4] mm/vmscan: remove redundant current_may_throttle() check
Date: Fri, 23 Mar 2018 18:20:27 +0300
Message-Id: <20180323152029.11084-3-aryabinin@virtuozzo.com>
In-Reply-To: <20180323152029.11084-1-aryabinin@virtuozzo.com>
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Only kswapd can have non-zero nr_immediate, and current_may_throttle() is
always true for kswapd (PF_LESS_THROTTLE bit is never set) thus it's
enough to check stat.nr_immediate only.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d74b12099bd..403f59edd53e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1807,7 +1807,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (stat.nr_immediate && current_may_throttle())
+		if (stat.nr_immediate)
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
-- 
2.16.1
