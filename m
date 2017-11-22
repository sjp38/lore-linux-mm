Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65E036B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d6so15506773pfb.3
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t25si13940801pgv.644.2017.11.22.13.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 04/62] idr test suite: Fix ida_test_random()
Date: Wed, 22 Nov 2017 13:06:41 -0800
Message-Id: <20171122210739.29916-5-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The test was checking the wrong errno; ida_get_new_above() returns
EAGAIN, not ENOMEM on memory allocation failure.  Double the number of
threads to increase the chance that we actually exercise this path
during the test suite (it was a bit sporadic before).

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/idr-test.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/radix-tree/idr-test.c b/tools/testing/radix-tree/idr-test.c
index 30cd0b296f1a..193450b29bf0 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr-test.c
@@ -380,7 +380,7 @@ void ida_check_random(void)
 			do {
 				ida_pre_get(&ida, GFP_KERNEL);
 				err = ida_get_new_above(&ida, bit, &id);
-			} while (err == -ENOMEM);
+			} while (err == -EAGAIN);
 			assert(!err);
 			assert(id == bit);
 		}
@@ -489,7 +489,7 @@ static void *ida_random_fn(void *arg)
 
 void ida_thread_tests(void)
 {
-	pthread_t threads[10];
+	pthread_t threads[20];
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(threads); i++)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
