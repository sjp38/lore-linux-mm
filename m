Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC796B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 14:04:39 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so74399471wic.1
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 11:04:39 -0700 (PDT)
Received: from mail-wi0-x244.google.com (mail-wi0-x244.google.com. [2a00:1450:400c:c05::244])
        by mx.google.com with ESMTPS id pe9si17321613wic.10.2015.09.27.11.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 11:04:38 -0700 (PDT)
Received: by wicxq10 with SMTP id xq10so13082240wic.2
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 11:04:38 -0700 (PDT)
Date: Sun, 27 Sep 2015 21:04:16 +0000
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH 1/2] mm: change free_cma and free_pages declarations to
 unsigned
Message-ID: <20150927210416.GA20144@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, rientjes@google.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Their stored values come from zone_page_state() which returns
an unsigned long. To improve code correctness we should avoid
mixing signed and unsigned integers.

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b..f55e3a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2242,7 +2242,7 @@ static bool __zone_watermark_ok(struct zone *z, unsigned int order,
 	/* free_pages may go negative - that's OK */
 	long min = mark;
 	int o;
-	long free_cma = 0;
+	unsigned long free_cma = 0;
 
 	free_pages -= (1 << order) - 1;
 	if (alloc_flags & ALLOC_HIGH)
@@ -2280,7 +2280,7 @@ bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
 			unsigned long mark, int classzone_idx, int alloc_flags)
 {
-	long free_pages = zone_page_state(z, NR_FREE_PAGES);
+	unsigned long free_pages = zone_page_state(z, NR_FREE_PAGES);
 
 	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
 		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
