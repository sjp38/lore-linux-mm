Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9C2F6B0038
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 19:58:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v63so111265951pgv.0
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 16:58:37 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id i22si2690077pll.33.2017.02.25.16.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 16:58:36 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id s67so8103157pgb.1
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 16:58:36 -0800 (PST)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] writeback: use setup_deferrable_timer
Date: Sun, 26 Feb 2017 08:58:22 +0800
Message-Id: <e8e3d4280a34facbc007346f31df833cec28801e.1488070291.git.geliangtang@gmail.com>
In-Reply-To: <4f458f31907933052ee1c1a78107e1331980986f.1488070459.git.geliangtang@gmail.com>
References: <4f458f31907933052ee1c1a78107e1331980986f.1488070459.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Jens Axboe <axboe@fb.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use setup_deferrable_timer() instead of init_timer_deferrable() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/page-writeback.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 26a6081..9e7d576 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -649,9 +649,8 @@ int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 
 	spin_lock_init(&dom->lock);
 
-	init_timer_deferrable(&dom->period_timer);
-	dom->period_timer.function = writeout_period;
-	dom->period_timer.data = (unsigned long)dom;
+	setup_deferrable_timer(&dom->period_timer, writeout_period,
+			       (unsigned long)dom);
 
 	dom->dirty_limit_tstamp = jiffies;
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
