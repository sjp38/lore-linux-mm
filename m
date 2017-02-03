Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4A86B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 13:10:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so5411900wmu.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 10:10:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si33261227wrj.85.2017.02.03.10.10.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 10:10:27 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
Date: Fri,  3 Feb 2017 19:10:08 +0100
Message-Id: <20170203181008.24898-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>

SLAB as part of its bootstrap pre-creates one kmalloc cache that can fit the
kmem_cache_node management structure, and puts it into the generic kmalloc
cache array (e.g. for 128b objects). The name of this cache is "kmalloc-node",
which is confusing for readers of /proc/slabinfo as the cache is used for
generic allocations (and not just the kmem_cache_node struct) and it appears as
the kmalloc-128 cache is missing.

An easy solution is to use the kmalloc-<size> name when pre-creating the cache,
which we can get from the kmalloc_info array.

Example /proc/slabinfo before the patch:

...
kmalloc-256         1647   1984    256   16    1 : tunables  120   60    8 : slabdata    124    124    828
kmalloc-192         1974   1974    192   21    1 : tunables  120   60    8 : slabdata     94     94    133
kmalloc-96          1332   1344    128   32    1 : tunables  120   60    8 : slabdata     42     42    219
kmalloc-64          2505   5952     64   64    1 : tunables  120   60    8 : slabdata     93     93    715
kmalloc-32          4278   4464     32  124    1 : tunables  120   60    8 : slabdata     36     36    346
kmalloc-node        1352   1376    128   32    1 : tunables  120   60    8 : slabdata     43     43     53
kmem_cache           132    147    192   21    1 : tunables  120   60    8 : slabdata      7      7      0

After the patch:

...
kmalloc-256         1672   2160    256   16    1 : tunables  120   60    8 : slabdata    135    135    807
kmalloc-192         1992   2016    192   21    1 : tunables  120   60    8 : slabdata     96     96    203
kmalloc-96          1159   1184    128   32    1 : tunables  120   60    8 : slabdata     37     37    116
kmalloc-64          2561   4864     64   64    1 : tunables  120   60    8 : slabdata     76     76    785
kmalloc-32          4253   4340     32  124    1 : tunables  120   60    8 : slabdata     35     35    270
kmalloc-128         1256   1280    128   32    1 : tunables  120   60    8 : slabdata     40     40     39
kmem_cache           125    147    192   21    1 : tunables  120   60    8 : slabdata      7      7      0

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab.c        | 3 ++-
 mm/slab.h        | 1 +
 mm/slab_common.c | 5 +++++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index a95fd4fed0a8..ede31b59bb9f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1293,7 +1293,8 @@ void __init kmem_cache_init(void)
 	 * Initialize the caches that provide memory for the  kmem_cache_node
 	 * structures first.  Without this, further allocations will bug.
 	 */
-	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache("kmalloc-node",
+	kmalloc_caches[INDEX_NODE] = create_kmalloc_cache(
+				get_kmalloc_cache_name(INDEX_NODE),
 				kmalloc_size(INDEX_NODE), ARCH_KMALLOC_FLAGS);
 	slab_state = PARTIAL_NODE;
 	setup_kmalloc_cache_index_table();
diff --git a/mm/slab.h b/mm/slab.h
index de6579dc362c..5708c548c6f7 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -78,6 +78,7 @@ unsigned long calculate_alignment(unsigned long flags,
 /* Kmalloc array related functions */
 void setup_kmalloc_cache_index_table(void);
 void create_kmalloc_caches(unsigned long);
+const char *get_kmalloc_cache_name(int index);
 
 /* Find the kmalloc slab corresponding for a certain size */
 struct kmem_cache *kmalloc_slab(size_t, gfp_t);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1dfc209431f2..36a8547de699 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -937,6 +937,11 @@ static struct {
 	{"kmalloc-67108864", 67108864}
 };
 
+const char *get_kmalloc_cache_name(int index)
+{
+	return kmalloc_info[index].name;
+}
+
 /*
  * Patch up the size_index table if we have strange large alignment
  * requirements for the kmalloc array. This is only the case for
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
