Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97F046B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:31:34 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so1121095551pgc.1
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 18:31:34 -0800 (PST)
Received: from anholt.net (anholt.net. [50.246.234.109])
        by mx.google.com with ESMTP id g10si22946128plm.311.2016.12.28.18.31.33
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 18:31:33 -0800 (PST)
From: Eric Anholt <eric@anholt.net>
Subject: [PATCH] mm: Drop "PFNs busy" printk in an expected path.
Date: Wed, 28 Dec 2016 18:31:31 -0800
Message-Id: <20161229023131.506-1-eric@anholt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Eric Anholt <eric@anholt.net>, linux-stable <stable@vger.kernel.org>

For CMA allocations, we expect to occasionally hit this error path, at
which point CMA will retry.  Given that, we shouldn't be spamming
dmesg about it.

The Raspberry Pi graphics driver does frequent CMA allocations, and
during regression testing this printk was sometimes occurring 100s of
times per second.

Signed-off-by: Eric Anholt <eric@anholt.net>
Cc: linux-stable <stable@vger.kernel.org>
---
 mm/page_alloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..bea7204c14a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7289,8 +7289,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
-			__func__, outer_start, end);
 		ret = -EBUSY;
 		goto done;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
