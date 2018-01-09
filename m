Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6705D6B0033
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 14:22:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g1so7949213wmd.0
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 11:22:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor2075999wrf.2.2018.01.09.11.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 11:22:47 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kmemleak: allow to coexist with fault injection
Date: Tue,  9 Jan 2018 20:22:43 +0100
Message-Id: <20180109192243.19316-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

kmemleak does one slab allocation per user allocation.
So if slab fault injection is enabled to any degree,
kmemleak instantly fails to allocate and turns itself off.
However, it's useful to use kmemleak with fault injection
to find leaks on error paths. On the other hand, checking
kmemleak itself is not so useful because (1) it's a debugging
tool and (2) it has a very regular allocation pattern
(basically a single allocation site, so it either works or not).

Turn off fault injection for kmemleak allocations.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 68648b840e8e..e83987c55a08 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -126,7 +126,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN)
+				 __GFP_NOWARN | __GFP_NOFAIL)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
