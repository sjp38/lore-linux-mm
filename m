Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF756B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:47:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m30so20757838pgn.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:47:41 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.125])
        by mx.google.com with ESMTPS id 60si1418902ple.818.2017.09.26.01.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:47:40 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 2/2] Change limit of HighAtomic from 1% to 10%
Date: Tue, 26 Sep 2017 16:46:44 +0800
Message-ID: <1506415604-4310-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

After "Try to use HighAtomic if try to alloc umovable page that order
is not 0".  The result is still not very well because the the limit of
HighAtomic make kernel cannot reserve more pageblock to HighAtomic.

The patch change max_managed from 1% to 10% make HighAtomic can get more
pageblocks.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b54e94a..9322458 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2101,7 +2101,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 	 * Limit the number reserved to 1 pageblock or roughly 1% of a zone.
 	 * Check is race-prone but harmless.
 	 */
-	max_managed = (zone->managed_pages / 100) + pageblock_nr_pages;
+	max_managed = (zone->managed_pages / 10) + pageblock_nr_pages;
 	if (zone->nr_reserved_highatomic >= max_managed)
 		return;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
