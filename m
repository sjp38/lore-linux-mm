Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7546B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:41:40 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ml10so1786562pab.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 10:41:40 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id v78si3913140pfk.64.2016.10.26.10.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 10:41:38 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id s8so614319pfj.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 10:41:38 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB & OBJFREELIST_SLAB
Date: Wed, 26 Oct 2016 10:41:28 -0700
Message-Id: <1477503688-69191-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, Thomas Garnier <thgarnie@google.com>

While testing OBJFREELIST_SLAB integration with pagealloc, we found a
bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
CFLGS_OBJFREELIST_SLAB.

The original kmem_cache is created early making OFF_SLAB not possible.
When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
is enabled it will try to enable it first under certain conditions.
Given kmem_cache(sys) reuses the original flag, you can have both flags
at the same time resulting in allocation failures and odd behaviors.

The proposed fix removes these flags by default at the entrance of
__kmem_cache_create. This way the function will define which way the
freelist should be handled at this stage for the new cache.

Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
Signed-off-by: Thomas Garnier <thgarnie@google.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
Based on next-20161025
---
 mm/slab.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 3c83c29..efe280a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2027,6 +2027,14 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	int err;
 	size_t size = cachep->size;
 
+	/*
+	 * memcg re-creates caches with the flags of the originals. Remove
+	 * the freelist related flags to ensure they are re-defined at this
+	 * stage. Prevent having both flags on edge cases like with pagealloc
+	 * if the original cache was created too early to be OFF_SLAB.
+	 */
+	flags &= ~(CFLGS_OBJFREELIST_SLAB|CFLGS_OFF_SLAB);
+
 #if DEBUG
 #if FORCED_DEBUG
 	/*
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
