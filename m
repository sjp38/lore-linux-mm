Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9713D6B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:15:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so253641608pfa.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 12:15:55 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id i128si5424749pfb.16.2016.07.01.12.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 12:15:54 -0700 (PDT)
From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] dma-debug: Track bucket lock state for static checkers
Date: Fri,  1 Jul 2016 12:15:52 -0700
Message-Id: <20160701191552.24295-1-sboyd@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

get_hash_bucket() and put_hash_bucket() acquire and release the
same spinlock, but this confuses static checkers such as sparse

lib/dma-debug.c:254:27: warning: context imbalance in 'get_hash_bucket' - wrong count at exit
lib/dma-debug.c:268:13: warning: context imbalance in 'put_hash_bucket' - unexpected unlock

Add the appropriate acquire and release statements so that
checkers can properly track the lock state.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 lib/dma-debug.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 51a76af25c66..fcfa1939ac41 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -253,6 +253,7 @@ static int hash_fn(struct dma_debug_entry *entry)
  */
 static struct hash_bucket *get_hash_bucket(struct dma_debug_entry *entry,
 					   unsigned long *flags)
+	__acquires(&dma_entry_hash[idx].lock)
 {
 	int idx = hash_fn(entry);
 	unsigned long __flags;
@@ -267,6 +268,7 @@ static struct hash_bucket *get_hash_bucket(struct dma_debug_entry *entry,
  */
 static void put_hash_bucket(struct hash_bucket *bucket,
 			    unsigned long *flags)
+	__releases(&bucket->lock)
 {
 	unsigned long __flags = *flags;
 
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
