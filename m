Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id A59426B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 06:24:56 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id x3so58446730obt.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:24:56 -0700 (PDT)
Received: from szxga05-in.huawei.com ([119.145.14.199])
        by mx.google.com with ESMTPS id za5si1017658obb.90.2016.03.30.03.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 03:24:21 -0700 (PDT)
From: He Kuang <hekuang@huawei.com>
Subject: [PATCH] Revert "mm/page_alloc: protect pcp->batch accesses with ACCESS_ONCE"
Date: Wed, 30 Mar 2016 10:22:07 +0000
Message-ID: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, cody@linux.vnet.ibm.com
Cc: gilad@benyossef.com, kosaki.motohiro@gmail.com, mgorman@suse.de, penberg@kernel.org, lizefan@huawei.com, wangnan0@huawei.com, hekuang@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This reverts commit 998d39cb236fe464af86a3492a24d2f67ee1efc2.

When local irq is disabled, a percpu variable does not change, so we can
remove the access macros and let the compiler optimize the code safely.

Signed-off-by: He Kuang <hekuang@huawei.com>
---
 mm/page_alloc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d..4575b82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2015,11 +2015,10 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 {
 	unsigned long flags;
-	int to_drain, batch;
+	int to_drain;
 
 	local_irq_save(flags);
-	batch = READ_ONCE(pcp->batch);
-	to_drain = min(pcp->count, batch);
+	to_drain = min(pcp->count, pcp->batch);
 	if (to_drain > 0) {
 		free_pcppages_bulk(zone, to_drain, pcp);
 		pcp->count -= to_drain;
@@ -2217,9 +2216,8 @@ void free_hot_cold_page(struct page *page, bool cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
-		unsigned long batch = READ_ONCE(pcp->batch);
-		free_pcppages_bulk(zone, batch, pcp);
-		pcp->count -= batch;
+		free_pcppages_bulk(zone, pcp->batch, pcp);
+		pcp->count -= pcp->batch;
 	}
 
 out:
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
