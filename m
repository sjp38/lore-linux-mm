Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 271BD6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 17:08:19 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so4788591wib.7
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 14:08:18 -0700 (PDT)
Received: from mail-wi0-f202.google.com (mail-wi0-f202.google.com [209.85.212.202])
        by mx.google.com with ESMTPS id j1si10046848wie.44.2014.06.16.14.08.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 14:08:17 -0700 (PDT)
Received: by mail-wi0-f202.google.com with SMTP id hi2so394530wib.5
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 14:08:17 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: [PATCH] mm: page_alloc: simplify drain_zone_pages by using min()
Date: Mon, 16 Jun 2014 23:08:14 +0200
Message-Id: <1402952894-13200-1-git-send-email-mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>

Instead of open-coding getting minimal value of two, just use min macro.
That is why it is there for.  While changing the function also change
type of batch local variable to match type of per_cpu_pages::batch
(which is int).

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 mm/page_alloc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..26aa003 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1224,15 +1224,11 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 {
 	unsigned long flags;
-	int to_drain;
-	unsigned long batch;
+	int to_drain, batch;
 
 	local_irq_save(flags);
 	batch = ACCESS_ONCE(pcp->batch);
-	if (pcp->count >= batch)
-		to_drain = batch;
-	else
-		to_drain = pcp->count;
+	to_drain = min(pcp->count, batch);
 	if (to_drain > 0) {
 		free_pcppages_bulk(zone, to_drain, pcp);
 		pcp->count -= to_drain;
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
