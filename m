Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 257176B0070
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:49:42 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so711210wgh.5
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:49:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex10si1640106wid.6.2014.10.02.08.49.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 08:49:40 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm, page_isolation: drain single zone pcplists
Date: Thu,  2 Oct 2014 17:48:58 +0200
Message-Id: <1412264940-15738-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
References: <1412264940-15738-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

When setting MIGRATETYPE_ISOLATE on a pageblock, pcplists are drained to have
a better chance that all pages will be successfully isolated and not left
in the per-cpu caches. Since isolation is always concerned with a single zone,
we can reduce the pcplists drain to the single zone, which is now possible.

The change should make memory isolation faster and not disturbing unrelated
pcplists anymore.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_isolation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index a57f082..3c49ef0 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -67,7 +67,7 @@ out:
 
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (!ret)
-		drain_all_pages(NULL);
+		drain_all_pages(zone);
 	return ret;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
