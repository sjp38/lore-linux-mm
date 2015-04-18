Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9F13B6B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 05:25:00 -0400 (EDT)
Received: by pdea3 with SMTP id a3so152926913pde.3
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 02:25:00 -0700 (PDT)
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com. [209.85.192.174])
        by mx.google.com with ESMTPS id rs11si20029643pab.141.2015.04.18.02.24.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Apr 2015 02:24:59 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so152913557pdb.0
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 02:24:59 -0700 (PDT)
From: Gavin Guo <gavin.guo@canonical.com>
Subject: [PATCH] mm/slab_common: Support the slub_debug boot option on specific object size
Date: Sat, 18 Apr 2015 17:24:51 +0800
Message-Id: <1429349091-11785-1-git-send-email-gavin.guo@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The slub_debug=PU,kmalloc-xx cannot work because in the
create_kmalloc_caches() the s->name is created after the
create_kmalloc_cache() is called. The name is NULL in the
create_kmalloc_cache() so the kmem_cache_flags() would not set the
slub_debug flags to the s->flags. The fix here set up a temporary
kmalloc_names string array for the initialization purpose. After the
kmalloc_caches are already it can be used to create s->name in the
kasprintf.

Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
 mm/slab_common.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb34..c7d7d54 100644
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
+	static char __initdata kmalloc_names[][17] = {
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
 
@@ -845,10 +866,12 @@ void __init create_kmalloc_caches(unsigned long flags)
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
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
