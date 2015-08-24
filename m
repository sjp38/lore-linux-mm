Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 51E8382F5F
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 22:20:31 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so11685476pac.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:31 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id j3si24975733pdl.212.2015.08.23.19.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 19:20:30 -0700 (PDT)
Received: by pacti10 with SMTP id ti10so11685280pac.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 19:20:30 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 8/9] mm/compaction: don't use higher order freepage than compaction aims at
Date: Mon, 24 Aug 2015 11:19:32 +0900
Message-Id: <1440382773-16070-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Purpose of compaction is to make high order page. To achive this purpose,
it is the best strategy that compaction migrates contiguous used pages
to fragmented unused freepages. Currently, freepage scanner don't
distinguish whether freepage is fragmented or not and blindly use
any freepage for migration target regardless of freepage's order.

Using higher order freepage than compaction aims at is not good because
what we do here is breaking high order freepage at somewhere and migrating
used pages from elsewhere to this broken high order freepages in order to
make new high order freepage. That is just position change of high order
freepage.

This is useless effort and doesn't help to make more high order freepages
because we can't be sure that migrating used pages makes high order
freepage. So, this patch makes freepage scanner only uses the ordered
freepage lower than compaction order.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index ca4d6d1..e61ee77 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -455,6 +455,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
+	unsigned long freepage_order;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -482,6 +483,20 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 		if (!PageBuddy(page))
 			goto isolate_fail;
 
+		if (!strict && cc->order != -1) {
+			freepage_order = page_order_unsafe(page);
+
+			if (freepage_order > 0 && freepage_order < MAX_ORDER) {
+				/*
+				 * Do not use high order freepage for migration
+				 * taret. It would not be beneficial for
+				 * compaction success rate.
+				 */
+				if (freepage_order >= cc->order)
+					goto isolate_fail;
+			}
+		}
+
 		/*
 		 * If we already hold the lock, we can skip some rechecking.
 		 * Note that if we hold the lock now, checked_pageblock was
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
