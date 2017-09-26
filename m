Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 287C56B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:47:41 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 11so20753149pge.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:47:41 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.125])
        by mx.google.com with ESMTPS id 60si1418902ple.818.2017.09.26.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:47:40 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 1/2] Try to use HighAtomic if try to alloc umovable page that order is not 0
Date: Tue, 26 Sep 2017 16:46:43 +0800
Message-ID: <1506415604-4310-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

The page add a new condition to let gfp_to_alloc_flags return
alloc_flags with ALLOC_HARDER if the order is not 0 and migratetype is
MIGRATE_UNMOVABLE.

Then alloc umovable page that order is not 0 will try to use HighAtomic.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c841af8..b54e94a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3642,7 +3642,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 }
 
 static inline unsigned int
-gfp_to_alloc_flags(gfp_t gfp_mask)
+gfp_to_alloc_flags(gfp_t gfp_mask, int order, int migratetype)
 {
 	unsigned int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
 
@@ -3671,6 +3671,8 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 		alloc_flags &= ~ALLOC_CPUSET;
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
+	else if (order > 0 && migratetype == MIGRATE_UNMOVABLE)
+		alloc_flags |= ALLOC_HARDER;
 
 #ifdef CONFIG_CMA
 	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -3903,7 +3905,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	 * kswapd needs to be woken up, and to avoid the cost of setting up
 	 * alloc_flags precisely. So we do that now.
 	 */
-	alloc_flags = gfp_to_alloc_flags(gfp_mask);
+	alloc_flags = gfp_to_alloc_flags(gfp_mask, order, ac->migratetype);
 
 	/*
 	 * We need to recalculate the starting point for the zonelist iterator
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
