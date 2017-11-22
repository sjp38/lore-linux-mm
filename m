Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBBD6B02B7
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:09 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u3so17275864pgn.3
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v187si15517767pfv.227.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 53/62] irq: Remove call to idr_preload
Date: Wed, 22 Nov 2017 13:07:30 -0800
Message-Id: <20171122210739.29916-54-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Not entirely clear why the preload was there with no locking.  Maybe at
one time there was a lock, and the preload was never removed?

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 kernel/irq/timings.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/kernel/irq/timings.c b/kernel/irq/timings.c
index e0923fa4927a..e9f16527656c 100644
--- a/kernel/irq/timings.c
+++ b/kernel/irq/timings.c
@@ -356,9 +356,7 @@ int irq_timings_alloc(int irq)
 	if (!s)
 		return -ENOMEM;
 
-	idr_preload(GFP_KERNEL);
-	id = idr_alloc(&irqt_stats, s, irq, irq + 1, GFP_NOWAIT);
-	idr_preload_end();
+	id = idr_alloc(&irqt_stats, s, irq, irq + 1, GFP_KERNEL);
 
 	if (id < 0) {
 		free_percpu(s);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
