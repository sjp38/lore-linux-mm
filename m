Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE4C828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:32 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id fl4so45446956pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:32 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id u66si17594752pfa.106.2016.02.25.22.02.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:31 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id q63so46303523pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:31 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 17/17] mm/slab: avoid returning values by reference
Date: Fri, 26 Feb 2016 15:01:24 +0900
Message-Id: <1456466484-3442-18-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Returing values by reference is bad practice. Instead, just use
function return value.

Suggested-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 85e394f..4f4e647 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -460,9 +460,10 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 /*
  * Calculate the number of objects and left-over bytes for a given buffer size.
  */
-static void cache_estimate(unsigned long gfporder, size_t buffer_size,
-		unsigned long flags, size_t *left_over, unsigned int *num)
+static unsigned int cache_estimate(unsigned long gfporder, size_t buffer_size,
+		unsigned long flags, size_t *left_over)
 {
+	unsigned int num;
 	size_t slab_size = PAGE_SIZE << gfporder;
 
 	/*
@@ -483,13 +484,15 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * correct alignment when allocated.
 	 */
 	if (flags & (CFLGS_OBJFREELIST_SLAB | CFLGS_OFF_SLAB)) {
-		*num = slab_size / buffer_size;
+		num = slab_size / buffer_size;
 		*left_over = slab_size % buffer_size;
 	} else {
-		*num = slab_size / (buffer_size + sizeof(freelist_idx_t));
+		num = slab_size / (buffer_size + sizeof(freelist_idx_t));
 		*left_over = slab_size %
 			(buffer_size + sizeof(freelist_idx_t));
 	}
+
+	return num;
 }
 
 #if DEBUG
@@ -1893,7 +1896,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 		unsigned int num;
 		size_t remainder;
 
-		cache_estimate(gfporder, size, flags, &remainder, &num);
+		num = cache_estimate(gfporder, size, flags, &remainder);
 		if (!num)
 			continue;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
