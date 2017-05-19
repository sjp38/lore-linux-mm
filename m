Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D622528073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:01:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 62so64563760pft.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:22 -0700 (PDT)
Received: from mail-pg0-f48.google.com (mail-pg0-f48.google.com. [74.125.83.48])
        by mx.google.com with ESMTPS id u63si9290055pfg.238.2017.05.19.14.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 14:01:22 -0700 (PDT)
Received: by mail-pg0-f48.google.com with SMTP id q125so43126173pgq.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:22 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH 3/3] mm/slub: Put tid_to_cpu() and tid_to_event() inside #ifdef block
Date: Fri, 19 May 2017 14:00:36 -0700
Message-Id: <20170519210036.146880-4-mka@chromium.org>
In-Reply-To: <20170519210036.146880-1-mka@chromium.org>
References: <20170519210036.146880-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

The functions are only used when certain config options are set. Putting
them inside #ifdef fixes the following warnings when building with clang:

mm/slub.c:1759:28: error: unused function 'tid_to_cpu'
    [-Werror,-Wunused-function]
                           ^
mm/slub.c:1764:29: error: unused function 'tid_to_event'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 mm/slub.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 23a8eb83efff..6df95738420d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1945,15 +1945,19 @@ static inline unsigned long next_tid(unsigned long tid)
 	return tid + TID_STEP;
 }
 
+#ifdef SLUB_DEBUG_CMPXCHG
+#ifdef CONFIG_PREEMPT
 static inline unsigned int tid_to_cpu(unsigned long tid)
 {
 	return tid % TID_STEP;
 }
+#endif
 
 static inline unsigned long tid_to_event(unsigned long tid)
 {
 	return tid / TID_STEP;
 }
+#endif
 
 static inline unsigned int init_tid(int cpu)
 {
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
