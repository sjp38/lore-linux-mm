Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 733EE6B02D5
	for <linux-mm@kvack.org>; Wed, 16 May 2018 16:20:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l128-v6so791916pga.22
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:20:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1-v6sor2415484plb.62.2018.05.16.13.20.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 13:20:44 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: save two stranding bit in gfp_mask
Date: Wed, 16 May 2018 13:20:23 -0700
Message-Id: <20180516202023.167627-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

___GFP_COLD and ___GFP_OTHER_NODE were removed but their bits were
stranded. Slide existing gfp masks to make those two bits available.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/gfp.h | 42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1a4582b44d32..8edf72d32411 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -16,31 +16,31 @@ struct vm_area_struct;
  */
 
 /* Plain integer GFP bitmasks. Do not use this directly. */
-#define ___GFP_DMA		0x01u
-#define ___GFP_HIGHMEM		0x02u
-#define ___GFP_DMA32		0x04u
-#define ___GFP_MOVABLE		0x08u
+#define ___GFP_DMA		0x1u
+#define ___GFP_HIGHMEM		0x2u
+#define ___GFP_DMA32		0x4u
+#define ___GFP_MOVABLE		0x8u
 #define ___GFP_RECLAIMABLE	0x10u
 #define ___GFP_HIGH		0x20u
 #define ___GFP_IO		0x40u
 #define ___GFP_FS		0x80u
-#define ___GFP_NOWARN		0x200u
-#define ___GFP_RETRY_MAYFAIL	0x400u
-#define ___GFP_NOFAIL		0x800u
-#define ___GFP_NORETRY		0x1000u
-#define ___GFP_MEMALLOC		0x2000u
-#define ___GFP_COMP		0x4000u
-#define ___GFP_ZERO		0x8000u
-#define ___GFP_NOMEMALLOC	0x10000u
-#define ___GFP_HARDWALL		0x20000u
-#define ___GFP_THISNODE		0x40000u
-#define ___GFP_ATOMIC		0x80000u
-#define ___GFP_ACCOUNT		0x100000u
-#define ___GFP_DIRECT_RECLAIM	0x400000u
-#define ___GFP_WRITE		0x800000u
-#define ___GFP_KSWAPD_RECLAIM	0x1000000u
+#define ___GFP_NOWARN		0x100u
+#define ___GFP_RETRY_MAYFAIL	0x200u
+#define ___GFP_NOFAIL		0x400u
+#define ___GFP_NORETRY		0x800u
+#define ___GFP_MEMALLOC		0x1000u
+#define ___GFP_COMP		0x2000u
+#define ___GFP_ZERO		0x4000u
+#define ___GFP_NOMEMALLOC	0x8000u
+#define ___GFP_HARDWALL		0x10000u
+#define ___GFP_THISNODE		0x20000u
+#define ___GFP_ATOMIC		0x40000u
+#define ___GFP_ACCOUNT		0x80000u
+#define ___GFP_DIRECT_RECLAIM	0x100000u
+#define ___GFP_WRITE		0x200000u
+#define ___GFP_KSWAPD_RECLAIM	0x400000u
 #ifdef CONFIG_LOCKDEP
-#define ___GFP_NOLOCKDEP	0x2000000u
+#define ___GFP_NOLOCKDEP	0x800000u
 #else
 #define ___GFP_NOLOCKDEP	0
 #endif
@@ -205,7 +205,7 @@ struct vm_area_struct;
 #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
 
 /* Room for N __GFP_FOO bits */
-#define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
+#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /*
-- 
2.17.0.441.gb46fe60e1d-goog
