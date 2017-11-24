Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 168EA6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 19:05:04 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t77so7443548pfe.10
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 16:05:04 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l30si17023873plg.363.2017.11.23.16.05.01
        for <linux-mm@kvack.org>;
        Thu, 23 Nov 2017 16:05:02 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: Do not stall register_shrinker
Date: Fri, 24 Nov 2017 09:04:59 +0900
Message-Id: <1511481899-20335-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Shakeel Butt reported, he have observed in production system that
the job loader gets stuck for 10s of seconds while doing mount
operation. It turns out that it was stuck in register_shrinker()
and some unrelated job was under memory pressure and spending time
in shrink_slab(). Machines have a lot of shrinkers registered and
jobs under memory pressure has to traverse all of those memcg-aware
shrinkers and do affect unrelated jobs which want to register their
own shrinkers.

To solve the issue, this patch simply bails out slab shrinking
once it found someone want to register shrinker in parallel.
A downside is it could cause unfair shrinking between shrinkers.
However, it should be rare and we can add compilcated logic once
we found it's not enough.

Link: http://lkml.kernel.org/r/20171115005602.GB23810@bbox
Cc: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-and-tested-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6a5a72baccd5..6698001787bd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -486,6 +486,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			sc.nid = 0;
 
 		freed += do_shrink_slab(&sc, shrinker, priority);
+		/*
+		 * bail out if someone want to register a new shrinker to
+		 * prevent long time stall by parallel ongoing shrinking.
+		 */
+		if (rwsem_is_contended(&shrinker_rwsem)) {
+			freed = freed ? : 1;
+			break;
+		}
 	}
 
 	up_read(&shrinker_rwsem);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
