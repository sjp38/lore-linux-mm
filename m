Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9CC6B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 14:23:35 -0500 (EST)
Received: by lfs39 with SMTP id 39so115233730lfs.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 11:23:34 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id r187si9310836lfr.241.2015.12.04.11.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 11:23:33 -0800 (PST)
Received: by lfs39 with SMTP id 39so115233392lfs.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 11:23:32 -0800 (PST)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: introduce for_each_memblock_type()
Date: Sat,  5 Dec 2015 01:20:56 +0600
Message-Id: <1449256856-8408-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

We already have the for_each_memblock() macrom in the <linux/memblock.h>
which provides ability to iterate over memblock regions of a known type.
The for_each_memblock() macro does allow us to pass the pointer to the
struct memblock_type, instead we need to pass name of the type.

This patch introduces new macro - for_each_memblock_type() which allows
us iterate over memblock regions with the given type when the type is
unknown.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 include/linux/memblock.h |  5 +++++
 mm/memblock.c            | 32 ++++++++++++++++----------------
 2 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 24daf8f..b7bb796 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -391,6 +391,11 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	     region < (memblock.memblock_type.regions + memblock.memblock_type.cnt);	\
 	     region++)
 
+#define for_each_memblock_type(memblock_type, rgn)			\
+	idx = 0;							\
+	rgn = &memblock_type->regions[idx];				\
+	for (idx = 0; idx < memblock_type->cnt;				\
+	     idx++,rgn = &memblock_type->regions[idx])
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 #define __init_memblock __meminit
diff --git a/mm/memblock.c b/mm/memblock.c
index d300f13..bf8b8ac 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -528,7 +528,8 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
 	bool insert = false;
 	phys_addr_t obase = base;
 	phys_addr_t end = base + memblock_cap_size(base, &size);
-	int i, nr_new;
+	int idx, nr_new;
+	struct memblock_region *rgn;
 
 	if (!size)
 		return 0;
@@ -552,8 +553,7 @@ repeat:
 	base = obase;
 	nr_new = 0;
 
-	for (i = 0; i < type->cnt; i++) {
-		struct memblock_region *rgn = &type->regions[i];
+	for_each_memblock_type(type, rgn) {
 		phys_addr_t rbase = rgn->base;
 		phys_addr_t rend = rbase + rgn->size;
 
@@ -572,7 +572,7 @@ repeat:
 			WARN_ON(flags != rgn->flags);
 			nr_new++;
 			if (insert)
-				memblock_insert_region(type, i++, base,
+				memblock_insert_region(type, idx++, base,
 						       rbase - base, nid,
 						       flags);
 		}
@@ -584,7 +584,7 @@ repeat:
 	if (base < end) {
 		nr_new++;
 		if (insert)
-			memblock_insert_region(type, i, base, end - base,
+			memblock_insert_region(type, idx, base, end - base,
 					       nid, flags);
 	}
 
@@ -651,7 +651,8 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 					int *start_rgn, int *end_rgn)
 {
 	phys_addr_t end = base + memblock_cap_size(base, &size);
-	int i;
+	int idx;
+	struct memblock_region *rgn;
 
 	*start_rgn = *end_rgn = 0;
 
@@ -663,8 +664,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 		if (memblock_double_array(type, base, size) < 0)
 			return -ENOMEM;
 
-	for (i = 0; i < type->cnt; i++) {
-		struct memblock_region *rgn = &type->regions[i];
+	for_each_memblock_type(type, rgn) {
 		phys_addr_t rbase = rgn->base;
 		phys_addr_t rend = rbase + rgn->size;
 
@@ -681,7 +681,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->base = base;
 			rgn->size -= base - rbase;
 			type->total_size -= base - rbase;
-			memblock_insert_region(type, i, rbase, base - rbase,
+			memblock_insert_region(type, idx, rbase, base - rbase,
 					       memblock_get_region_node(rgn),
 					       rgn->flags);
 		} else if (rend > end) {
@@ -692,14 +692,14 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 			rgn->base = end;
 			rgn->size -= end - rbase;
 			type->total_size -= end - rbase;
-			memblock_insert_region(type, i--, rbase, end - rbase,
+			memblock_insert_region(type, idx--, rbase, end - rbase,
 					       memblock_get_region_node(rgn),
 					       rgn->flags);
 		} else {
 			/* @rgn is fully contained, record it */
 			if (!*end_rgn)
-				*start_rgn = i;
-			*end_rgn = i + 1;
+				*start_rgn = idx;
+			*end_rgn = idx + 1;
 		}
 	}
 
@@ -1613,12 +1613,12 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 {
 	unsigned long long base, size;
 	unsigned long flags;
-	int i;
+	int idx;
+	struct memblock_region *rgn;
 
 	pr_info(" %s.cnt  = 0x%lx\n", name, type->cnt);
 
-	for (i = 0; i < type->cnt; i++) {
-		struct memblock_region *rgn = &type->regions[i];
+	for_each_memblock_type(type, rgn) {
 		char nid_buf[32] = "";
 
 		base = rgn->base;
@@ -1630,7 +1630,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type, char *name
 				 memblock_get_region_node(rgn));
 #endif
 		pr_info(" %s[%#x]\t[%#016llx-%#016llx], %#llx bytes%s flags: %#lx\n",
-			name, i, base, base + size - 1, size, nid_buf, flags);
+			name, idx, base, base + size - 1, size, nid_buf, flags);
 	}
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
