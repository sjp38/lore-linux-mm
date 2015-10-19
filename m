Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id AECA76B027F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 14:13:09 -0400 (EDT)
Received: by lbbes7 with SMTP id es7so61068671lbb.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 11:13:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u4si42764254wjq.30.2015.10.19.11.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 11:13:07 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX increase
Date: Mon, 19 Oct 2015 14:13:01 -0400
Message-Id: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
the scan window for vmpressure detection from 2MB to 16MB. Revert.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmpressure.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index c5afd57..74f206b 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -38,7 +38,7 @@
  * TODO: Make the window size depend on machine size, as we do for vmstat
  * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
  */
-static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
+static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX;
 
 /*
  * These thresholds are used when we account memory pressure through
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
