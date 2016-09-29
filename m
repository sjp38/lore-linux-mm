Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE4A86B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 11:54:47 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f187so111673339qkd.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:54:47 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id q125si369599qkd.4.2016.09.29.08.54.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 08:54:47 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <c667e4f6-0446-ffd6-d05d-d87e97041a67@zoho.com>
Date: Thu, 29 Sep 2016 23:54:26 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zijun_hu <zijun_hu@htc.com>

it will cause memory leakage for pcpu_embed_first_chunk() to go to
label @out_free if the chunk spans over 3/4 VMALLOC area. all memory
are allocated and recorded into array @areas for each CPU group, but
the memory allocated aren't be freed before returning after going to
label @out_free

in order to fix this bug, we check chunk spanned area immediately
after completing memory allocation for all CPU group, we go to label
@out_free_areas other than @out_free to free all memory allocated if
the checking is failed.

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 Hi Andrew,
 this patch is based on mmotm/linux-next branch so can be
 applied directly

 mm/percpu.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 41d9d0b35801..7a5dae185ce1 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1963,7 +1963,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	struct pcpu_alloc_info *ai;
 	size_t size_sum, areas_size;
 	unsigned long max_distance;
-	int group, i, rc;
+	int group, i, j, rc;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
 				   cpu_distance_fn);
@@ -1979,7 +1979,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		goto out_free;
 	}
 
-	/* allocate, copy and determine base address */
+	/* allocate, copy and determine base address & max_distance */
+	j = 0;
 	for (group = 0; group < ai->nr_groups; group++) {
 		struct pcpu_group_info *gi = &ai->groups[group];
 		unsigned int cpu = NR_CPUS;
@@ -2000,6 +2001,21 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 		areas[group] = ptr;
 
 		base = min(ptr, base);
+		if (ptr > areas[j])
+			j = group;
+	}
+	max_distance = areas[j] - base;
+	max_distance += ai->unit_size * ai->groups[j].nr_units;
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
-		(unsigned long)ai->unit_size * ai->groups[i].nr_units;
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
