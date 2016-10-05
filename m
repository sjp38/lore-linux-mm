Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2A156B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 09:31:15 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id u124so50410622ywg.2
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 06:31:15 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id x127si12873240ywe.254.2016.10.05.06.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Oct 2016 06:30:41 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH v3 2/2] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <db08c942-ff7b-d008-27de-57b9348f1904@zoho.com>
Date: Wed, 5 Oct 2016 21:30:24 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

in order to ensure the percpu group areas within a chunk aren't
distributed too sparsely, pcpu_embed_first_chunk() goes to error handling
path when a chunk spans over 3/4 VMALLOC area, however, during the error
handling, it forget to free the memory allocated for all percpu groups by
going to label @out_free other than @out_free_areas.

it will cause memory leakage issue if the rare scene really happens, in
order to fix the issue, we check chunk spanned area immediately after
completing memory allocation for all percpu groups, we go to label
@out_free_areas to free the memory then return if the checking is failed.

in order to verify the approach, we dump all memory allocated then
enforce the jump then dump all memory freed, the result is okay after
checking whether we free all memory we allocate in this function.

BTW, The approach is chosen after thinking over the below scenes
 - we don't go to label @out_free directly to fix this issue since we
   maybe free several allocated memory blocks twice
 - the aim of jumping after pcpu_setup_first_chunk() is bypassing free
   usable memory other than handling error, moreover, the function does
   not return error code in any case, it either panics due to BUG_ON()
   or return 0.

Signed-off-by: zijun_hu <zijun_hu@htc.com>
Tested-by: zijun_hu <zijun_hu@htc.com>
---
 Changes in v3:
  - commit message is updated
  - more descriptive local variant name highest_group is used

 Changes in v2:
  - more detailed commit message is provided as discussed
    with tj@kernel.org

 mm/percpu.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index e2737e56b017..255714302394 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1963,7 +1963,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	struct pcpu_alloc_info *ai;
 	size_t size_sum, areas_size;
 	unsigned long max_distance;
-	int group, i, rc;
+	int group, i, highest_group, rc;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
 				   cpu_distance_fn);
@@ -1979,7 +1979,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		goto out_free;
 	}
 
-	/* allocate, copy and determine base address */
+	/* allocate, copy and determine base address & max_distance */
+	highest_group = 0;
 	for (group = 0; group < ai->nr_groups; group++) {
 		struct pcpu_group_info *gi = &ai->groups[group];
 		unsigned int cpu = NR_CPUS;
@@ -2000,6 +2001,21 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		areas[group] = ptr;
 
 		base = min(ptr, base);
+		if (ptr > areas[highest_group])
+			highest_group = group;
+	}
+	max_distance = areas[highest_group] - base;
+	max_distance += ai->unit_size * ai->groups[highest_group].nr_units;
+
+	/* warn if maximum distance is further than 75% of vmalloc space */
+	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
+		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
+				max_distance, VMALLOC_TOTAL);
+#ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
+		/* and fail if we have fallback */
+		rc = -EINVAL;
+		goto out_free_areas;
+#endif
 	}
 
 	/*
@@ -2024,24 +2040,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	}
 
 	/* base address is now known, determine group base offsets */
-	i = 0;
 	for (group = 0; group < ai->nr_groups; group++) {
 		ai->groups[group].base_offset = areas[group] - base;
-		if (areas[group] > areas[i])
-			i = group;
-	}
-	max_distance = ai->groups[i].base_offset +
-		ai->unit_size * ai->groups[i].nr_units;
-
-	/* warn if maximum distance is further than 75% of vmalloc space */
-	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
-		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
-			max_distance, VMALLOC_TOTAL);
-#ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
-		/* and fail if we have fallback */
-		rc = -EINVAL;
-		goto out_free;
-#endif
 	}
 
 	pr_info("Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
