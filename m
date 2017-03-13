Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52AD26B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 04:08:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l66so287723073pfl.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:08:00 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id c63si10816195pfb.128.2017.03.13.01.07.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 01:07:59 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
Date: Mon, 13 Mar 2017 16:02:54 +0800
Message-ID: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: vbabka@suse.cz, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
the IRQ context. but drain_pages_zone fails to clear away the irq. because
preempt_disable have take effect. so it safely remove the code.

Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05c3956..7b16095 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2294,11 +2294,9 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
  */
 static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 {
-	unsigned long flags;
 	struct per_cpu_pageset *pset;
 	struct per_cpu_pages *pcp;
 
-	local_irq_save(flags);
 	pset = per_cpu_ptr(zone->pageset, cpu);
 
 	pcp = &pset->pcp;
@@ -2306,7 +2304,6 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 		free_pcppages_bulk(zone, pcp->count, pcp);
 		pcp->count = 0;
 	}
-	local_irq_restore(flags);
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
