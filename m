Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B216F6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:26:11 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so18212618pac.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:26:11 -0700 (PDT)
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com. [209.85.192.181])
        by mx.google.com with ESMTPS id cs1si12434868pbb.255.2015.04.23.06.26.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 06:26:10 -0700 (PDT)
Received: by pdbqd1 with SMTP id qd1so18480560pdb.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:26:10 -0700 (PDT)
From: Gavin Guo <gavin.guo@canonical.com>
Subject: [PATCH v3] mm/slab_common: Support the slub_debug boot option on specific object size
Date: Thu, 23 Apr 2015 21:26:00 +0800
Message-Id: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@rasmusvillemoes.dk

The slub_debug=PU,kmalloc-xx cannot work because in the
create_kmalloc_caches() the s->name is created after the
create_kmalloc_cache() is called. The name is NULL in the
create_kmalloc_cache() so the kmem_cache_flags() would not set the
slub_debug flags to the s->flags. The fix here set up a kmalloc_names
string array for the initialization purpose and delete the dynamic
name creation of kmalloc_caches.

v2->v3
 - Adopted suggestion from Andrew Morton to delete the kmalloc-96/192 case
   and merge the code to single initialization loop.
 - Redefine the kmalloc_names.
 - Add the KMALLOC_LOOP_LOW as the for loop start index to initialize the
   kmalloc_caches object.

v1->v2
 - Adopted suggestion from Christoph to delete the dynamic name creation
   for kmalloc_caches.

Signed-off-by: Gavin Guo <gavin.guo@canonical.com>
---
 include/linux/slab.h | 22 +++++++++++++++++++
 mm/slab_common.c     | 62 +++++++++++++++++++++++++++++++++-------------------
 2 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ffd24c8..96f0ea5 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -153,8 +153,30 @@ size_t ksize(const void *);
 #define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
 #define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
 #define KMALLOC_SHIFT_LOW ilog2(ARCH_DMA_MINALIGN)
+/*
+ * The KMALLOC_LOOP_LOW is the definition for the for loop index start number
+ * to create the kmalloc_caches object in create_kmalloc_caches(). The first
+ * and the second are 96 and 192. You can see that in the kmalloc_index(), if
+ * the KMALLOC_MIN_SIZE <= 32, then return 1 (96). If KMALLOC_MIN_SIZE <= 64,
+ * then return 2 (192). If the KMALLOC_MIN_SIZE is bigger than 64, we don't
+ * need to initialize 96 and 192. Go directly to start the KMALLOC_SHIFT_LOW.
+ */
+#if KMALLOC_MIN_SIZE <= 32
+#define KMALLOC_LOOP_LOW 1
+#elif KMALLOC_MIN_SIZE <= 64
+#define KMALLOC_LOOP_LOW 2
+#else
+#define KMALLOC_LOOP_LOW KMALLOC_SHIFT_LOW
+#endif
+
 #else
 #define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
+/*
+ * The KMALLOC_MIN_SIZE of slub/slab/slob is 2^3/2^5/2^3. So, even slab is used.
+ * The KMALLOC_MIN_SIZE <= 32. The kmalloc-96 and kmalloc-192 should also be
+ * initialized.
+ */
+#define KMALLOC_LOOP_LOW 1
 #endif
 
 /*
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 999bb34..05c6439 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -784,6 +784,31 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 }
 
 /*
+ * The kmalloc_names is to make slub_debug=,kmalloc-xx option work in the boot
+ * time. The kmalloc_index() support to 2^26=64MB. So, the final entry of the
+ * table is kmalloc-67108864.
+ */
+static struct {
+	const char *name;
+	unsigned long size;
+} const kmalloc_names[] __initconst = {
+	{NULL,                      0},		{"kmalloc-96",             96},
+	{"kmalloc-192",           192},		{"kmalloc-8",               8},
+	{"kmalloc-16",             16},		{"kmalloc-32",             32},
+	{"kmalloc-64",             64},		{"kmalloc-128",           128},
+	{"kmalloc-256",           256},		{"kmalloc-512",           512},
+	{"kmalloc-1024",         1024},		{"kmalloc-2048",         2048},
+	{"kmalloc-4096",         4096},		{"kmalloc-8192",         8192},
+	{"kmalloc-16384",       16384},		{"kmalloc-32768",       32768},
+	{"kmalloc-65536",       65536},		{"kmalloc-131072",     131072},
+	{"kmalloc-262144",     262144},		{"kmalloc-524288",     524288},
+	{"kmalloc-1048576",   1048576},		{"kmalloc-2097152",   2097152},
+	{"kmalloc-4194304",   4194304},		{"kmalloc-8388608",   8388608},
+	{"kmalloc-16777216", 16777216},		{"kmalloc-33554432", 33554432},
+	{"kmalloc-67108864", 67108864}
+};
+
+/*
  * Create the kmalloc array. Some of the regular kmalloc arrays
  * may already have been created because they were needed to
  * enable allocations for slab creation.
@@ -833,39 +858,30 @@ void __init create_kmalloc_caches(unsigned long flags)
 		for (i = 128 + 8; i <= 192; i += 8)
 			size_index[size_index_elem(i)] = 8;
 	}
-	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+	for (i = KMALLOC_LOOP_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i]) {
-			kmalloc_caches[i] = create_kmalloc_cache(NULL,
-							1 << i, flags);
+			kmalloc_caches[i] = create_kmalloc_cache(
+						kmalloc_names[i].name,
+						kmalloc_names[i].size,
+						flags);
 		}
 
 		/*
-		 * Caches that are not of the two-to-the-power-of size.
-		 * These have to be created immediately after the
-		 * earlier power of two caches
+		 * "i == 2" is the "kmalloc-192" case which is the last special
+		 * case for initialization and it's the point to jump to
+		 * allocate the minimize size of the object. In slab allocator,
+		 * the KMALLOC_SHIFT_LOW = 5. So, it needs to skip 2^3 and 2^4
+		 * and go straight to allocate 2^5. If the ARCH_DMA_MINALIGN is
+		 * defined, it may be larger than 2^5 and here is also the
+		 * trick to skip the empty gap.
 		 */
-		if (KMALLOC_MIN_SIZE <= 32 && !kmalloc_caches[1] && i == 6)
-			kmalloc_caches[1] = create_kmalloc_cache(NULL, 96, flags);
-
-		if (KMALLOC_MIN_SIZE <= 64 && !kmalloc_caches[2] && i == 7)
-			kmalloc_caches[2] = create_kmalloc_cache(NULL, 192, flags);
+		if (i == 2)
+			i = (KMALLOC_SHIFT_LOW - 1);
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
