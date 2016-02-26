Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 60C98828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:14 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id c10so47850849pfc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:14 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id tc5si949598pab.176.2016.02.25.22.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:13 -0800 (PST)
Received: by mail-pa0-x229.google.com with SMTP id ho8so46725496pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:13 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 12/17] mm/slab: do not change cache size if debug pagealloc isn't possible
Date: Fri, 26 Feb 2016 15:01:19 +0900
Message-Id: <1456466484-3442-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can fail to setup off slab in some conditions.  Even in this case,
debug pagealloc increases cache size to PAGE_SIZE in advance and it is
waste because debug pagealloc cannot work for it when it isn't the off
slab.  To improve this situation, this patch checks first that this cache
with increased size is suitable for off slab.  It actually increases cache
size when it is suitable for off-slab, so possible waste is removed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9b56685..21aad9d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2206,10 +2206,17 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 */
 	if (debug_pagealloc_enabled() && (flags & SLAB_POISON) &&
 		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
-		size >= 256 && cachep->object_size > cache_line_size() &&
-		size < PAGE_SIZE) {
-		cachep->obj_offset += PAGE_SIZE - size;
-		size = PAGE_SIZE;
+		size >= 256 && cachep->object_size > cache_line_size()) {
+		if (size < PAGE_SIZE || size % PAGE_SIZE == 0) {
+			size_t tmp_size = ALIGN(size, PAGE_SIZE);
+
+			if (set_off_slab_cache(cachep, tmp_size, flags)) {
+				flags |= CFLGS_OFF_SLAB;
+				cachep->obj_offset += tmp_size - size;
+				size = tmp_size;
+				goto done;
+			}
+		}
 	}
 #endif
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
