Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7C16B0253
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 01:42:28 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g127so75177696ith.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 22:42:28 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id r43si1943324otb.0.2016.06.28.22.42.26
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 22:42:27 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: [PATCH] mm, vmscan: Give up balancing node for high order allocations earlier
Date: Wed, 29 Jun 2016 13:42:12 +0800
Message-ID: <00ed01d1d1c8$fcb12ff0$f6138fd0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>

To avoid excessive reclaim, we give up rebalancing for high order 
allocations right after reclaiming enough pages.

Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>
---

 mm/vmscan.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ee7e531..d080fb2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3159,8 +3159,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 	do {
 		bool raise_priority = true;
-
-		sc.nr_reclaimed = 0;
+		unsigned long reclaimed_pages = sc.nr_reclaimed;
 
 		/*
 		 * If the number of buffer_heads in the machine exceeds the
@@ -3254,7 +3253,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
-		if (raise_priority || !sc.nr_reclaimed)
+		if (raise_priority || sc.nr_reclaimed == reclaimed_pages)
 			sc.priority--;
 	} while (sc.priority >= 1);
 
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
