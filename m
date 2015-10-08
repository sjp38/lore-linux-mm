Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E97816B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 22:35:19 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so39152538pac.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 19:35:19 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id yp1si57470467pbc.152.2015.10.07.19.35.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 19:35:19 -0700 (PDT)
Message-ID: <5615D311.5030908@huawei.com>
Date: Thu, 8 Oct 2015 10:21:05 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: skip if required_kernelcore is larger than totalpages
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David
 Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If kernelcore was not specified, or the kernelcore size is zero
(required_movablecore >= totalpages), or the kernelcore size is larger
than totalpages, there is no ZONE_MOVABLE. We should fill the zone
with both kernel memory and movable memory.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index af3c9bd..6a6da0d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5674,8 +5674,11 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		required_kernelcore = max(required_kernelcore, corepages);
 	}
 
-	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
-	if (!required_kernelcore)
+	/*
+	 * If kernelcore was not specified or kernelcore size is larger
+	 * than totalpages, there is no ZONE_MOVABLE.
+	 */
+	if (!required_kernelcore || required_kernelcore >= totalpages)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
