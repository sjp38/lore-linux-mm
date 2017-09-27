Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE536B025F
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 04:20:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f4so13616022wmh.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 01:20:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si8602982wrp.443.2017.09.27.01.20.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 01:20:58 -0700 (PDT)
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH 1/6] mm: add kmalloc_array_node and kcalloc_node
Date: Wed, 27 Sep 2017 10:20:33 +0200
Message-Id: <20170927082038.3782-2-jthumshirn@suse.de>
In-Reply-To: <20170927082038.3782-1-jthumshirn@suse.de>
References: <20170927082038.3782-1-jthumshirn@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Damien Le Moal <damien.lemoal@wdc.com>, Christoph Hellwig <hch@lst.de>, Johannes Thumshirn <jthumshirn@suse.de>

We have kmalloc_array() and kcalloc() wrappers on top of kmalloc() which
ensure us overflow free multiplication for the size of a memory
allocation but these implementations are not NUMA-aware.

Likewise we have kmalloc_node() which is a NUMA-aware version of
kmalloc() but the implementation is not aware of any possible overflows in
eventual size calculations.

Introduce a combination of the two above cases to have a NUMA-node aware
version of kmalloc_array() and kcalloc().

Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
---
 include/linux/slab.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 41473df6dfb0..aaf4723e41b3 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -635,6 +635,22 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, _RET_IP_)
 
+static inline void *kmalloc_array_node(size_t n, size_t size, gfp_t flags,
+				       int node)
+{
+	if (size != 0 && n > SIZE_MAX / size)
+		return NULL;
+	if (__builtin_constant_p(n) && __builtin_constant_p(size))
+		return kmalloc_node(n * size, flags, node);
+	return __kmalloc_node(n * size, flags, node);
+}
+
+static inline void *kcalloc_node(size_t n, size_t size, gfp_t flags, int node)
+{
+	return kmalloc_array_node(n, size, flags | __GFP_ZERO, node);
+}
+
+
 #ifdef CONFIG_NUMA
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
 #define kmalloc_node_track_caller(size, flags, node) \
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
