Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3396B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 04:57:46 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t31so52185123ioi.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 01:57:46 -0800 (PST)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:67c:670:201:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id w4si2379096wmg.1.2016.12.02.01.57.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 01:57:45 -0800 (PST)
From: Lucas Stach <l.stach@pengutronix.de>
Subject: [PATCH] mm: alloc_contig: demote PFN busy message to debug level
Date: Fri,  2 Dec 2016 10:57:42 +0100
Message-Id: <20161202095742.32449-1-l.stach@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kernel@pengutronix.de, patchwork-lst@pengutronix.de

There are a lot of reasons why a PFN might be busy and unable to be isolated
some of which can't really be avoided. This message is spamming the logs when
a lot of CMA allocations are happening, causing isolation to happen quite
frequently.

Demote the message to log level, as CMA will just retry the allocation, so
there is no need to have this message in the logs. If someone is interested
in the failing case, there is a tracepoint to track those failures properly.

Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b3bf6767d54..b2cfb4074f90 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7398,7 +7398,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
+		pr_debug("%s: [%lx, %lx) PFNs busy\n",
 			__func__, outer_start, end);
 		ret = -EBUSY;
 		goto done;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
