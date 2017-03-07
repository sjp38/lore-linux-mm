Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 723916B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 05:47:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id l66so122895192pfl.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 02:47:04 -0800 (PST)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id p5si22118559pgn.354.2017.03.07.02.47.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 02:47:03 -0800 (PST)
Message-ID: <58BE8F07.8020109@huawei.com>
Date: Tue, 7 Mar 2017 18:44:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 2/2] mm: unreserve highatomic pageblock if direct reclaim
 failed
References: <58BE8C91.20600@huawei.com>
In-Reply-To: <58BE8C91.20600@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If direct reclaim failed, unreserve highatomic pageblock
immediately is better than unreserve in should_reclaim_retry().
We may get page in next try rather than reclaim-compact-reclaim-compact...

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2331840..2bd19d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3421,7 +3421,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	bool drained = false;
 
 	*did_some_progress = __perform_reclaim(gfp_mask, order, ac);
-	if (unlikely(!(*did_some_progress)))
+	if (unlikely(!(*did_some_progress)
+	    && !unreserve_highatomic_pageblock(ac, false)))
 		return NULL;
 
 retry:
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
