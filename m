Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9989A6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 05:38:43 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so35724084pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 02:38:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id fl1si372667pad.11.2015.09.30.02.38.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Sep 2015 02:38:43 -0700 (PDT)
Message-ID: <560BAC76.6050002@huawei.com>
Date: Wed, 30 Sep 2015 17:33:42 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix overflow in find_zone_movable_pfns_for_nodes()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Yasuaki
 Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If user set "movablecore=xx" to a large number, corepages will overflow,
this patch fix the problem.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b..af3c9bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5668,6 +5668,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		 */
 		required_movablecore =
 			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
+		required_movablecore = min(totalpages, required_movablecore);
 		corepages = totalpages - required_movablecore;
 
 		required_kernelcore = max(required_kernelcore, corepages);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
