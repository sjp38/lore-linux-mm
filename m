Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9516B0005
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 23:18:00 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i22-v6so8519365pfj.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 20:18:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17-v6sor23003789pfi.2.2018.11.12.20.17.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 20:17:58 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim() when CONFIG_NUMA is n
Date: Tue, 13 Nov 2018 12:17:50 +0800
Message-Id: <20181113041750.20784-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
fail zone_reclaim() as full") changed the return value of node_reclaim().
The original return value 0 means NODE_RECLAIM_SOME after this commit.

While the return value of node_reclaim() when CONFIG_NUMA is n is not
changed. This will leads to call zone_watermark_ok() again.

This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
it is not proper to include "mm/internal.h", just hard coded it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---

This doesn't effect the system functionally. I am not sure we need to cc to
stable tree?

---
 include/linux/swap.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d8a07a4f171d..2bd993280470 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -364,7 +364,7 @@ extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
 static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
 				unsigned int order)
 {
-	return 0;
+	return -2;	/* NODE_RECLAIM_NOSCAN */
 }
 #endif
 
-- 
2.15.1
