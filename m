Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 033996B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 04:33:49 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so267569133pdb.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 01:33:48 -0700 (PDT)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com. [209.85.192.178])
        by mx.google.com with ESMTPS id br5si6657206pdb.256.2015.04.22.01.33.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 01:33:48 -0700 (PDT)
Received: by pdbqd1 with SMTP id qd1so268094903pdb.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 01:33:47 -0700 (PDT)
From: Gavin Guo <gavin.guo@canonical.com>
Subject: [PATCH v2] mm/slab_common: Support the slub_debug boot option on specific object size
Date: Wed, 22 Apr 2015 16:33:38 +0800
Message-Id: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slub_debug=PU,kmalloc-xx cannot work because in the
create_kmalloc_caches() the s->name is created after the
create_kmalloc_cache() is called. The name is NULL in the
create_kmalloc_cache() so the kmem_cache_flags() would not set the
slub_debug flags to the s->flags. The fix here set up a kmalloc_names
string array for the initialization purpose and delete the dynamic
name creation of kmalloc_caches.

v1->v2
 - Adopted suggestion from Christoph to delete the dynamic name creation
   for kmalloc_caches.

Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
 mm/slab_common.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb34..61fbc4e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -793,6 +793,26 @@ void __init create_kmalloc_caches(unsigned long flags)
 	int i;
 
 	/*
+	 * The kmalloc_names is for temporary usage to make
+	 * slub_debug=,kmalloc-xx option work in the boot time. The
+	 * kmalloc_index() support to 2^26=64MB. So, the final entry of the
+	 * table is kmalloc-67108864.
+	 */
+	static const char *kmalloc_names[] = {
+		"0",			"kmalloc-96",		"kmalloc-192",
+		"kmalloc-8",		"kmalloc-16",		"kmalloc-32",
+		"kmalloc-64",		"kmalloc-128",		"kmalloc-256",
+		"kmalloc-512",		"kmalloc-1024",		"kmalloc-2048",
+		"kmalloc-4196",		"kmalloc-8192",		"kmalloc-16384",
+		"kmalloc-32768",	"kmalloc-65536",
+		"kmalloc-131072",	"kmalloc-262144",
+		"kmalloc-524288",	"kmalloc-1048576",
+		"kmalloc-2097152",	"kmalloc-4194304",
+		"kmalloc-8388608",	"kmalloc-16777216",
+		"kmalloc-33554432",	"kmalloc-67108864"
+	};
+
+	/*
 	 * Patch up the size_index table if we have strange large alignment
 	 * requirements for the kmalloc array. This is only the case for
 	 * MIPS it seems. The standard arches will not generate any code here.
@@ -835,7 +855,8 @@ void __init create_kmalloc_caches(unsigned long flags)
 	}
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i]) {
-			kmalloc_caches[i] = create_kmalloc_cache(NULL,
+			kmalloc_caches[i] = create_kmalloc_cache(
+							kmalloc_names[i],
 							1 << i, flags);
 		}
 
@@ -845,27 +866,17 @@ void __init create_kmalloc_caches(unsigned long flags)
 		 * earlier power of two caches
 		 */
 		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1] && i == 6)
-			kmalloc_caches[1] = create_kmalloc_cache(NULL, 96, flags);
+			kmalloc_caches[1] = create_kmalloc_cache(
+						kmalloc_names[1], 96, flags);
 
 		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2] && i == 7)
-			kmalloc_caches[2] = create_kmalloc_cache(NULL, 192, flags);
+			kmalloc_caches[2] = create_kmalloc_cache(
+						 kmalloc_names[2], 192, flags);
 	}
 
 	/* Kmalloc array is now usable */
 	slab_state = UP;
 
-	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
-		struct kmem_cache *s = kmalloc_caches[i];
-		char *n;
-
-		if (s) {
-			n = kasprintf(GFP_NOWAIT, "kmalloc-%d", kmalloc_size(i));
-
-			BUG_ON(!n);
-			s->name = n;
-		}
-	}
-
 #ifdef CONFIG_ZONE_DMA
 	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
 		struct kmem_cache *s = kmalloc_caches[i];
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
