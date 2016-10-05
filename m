Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6416E6B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 09:20:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v138so2147716qka.2
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 06:20:11 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id y2si17218781qtb.15.2016.10.05.06.19.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Oct 2016 06:19:21 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH v2 1/2] mm/percpu.c: correct max_distance calculation for
 pcpu_embed_first_chunk()
Message-ID: <5cfc6d8b-cb24-7c43-a2c5-7b6eaac6e7a3@zoho.com>
Date: Wed, 5 Oct 2016 21:19:11 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

pcpu_embed_first_chunk() calculates the range a percpu chunk spans into
@max_distance and uses it to ensure that a chunk is not too big compared
to the total vmalloc area. However, during calculation, it used incorrect
top address by adding a unit size to the highest group's base address.

This can make the calculated max_distance slightly smaller than the actual
distance although given the scale of values involved the error is very
unlikely to have an actual impact.

Fix this issue by adding the group's size instead of a unit size.

BTW, The type of variable max_distance is changed from size_t to unsigned
long too based on below consideration:
 - type unsigned long usually have same width with IP core registers and
   can be applied at here very well
 - make @max_distance type consistent with the operand calculated against
   it such as @ai->groups[i].base_offset and macro VMALLOC_TOTAL
 - type unsigned long is more universal then size_t, size_t is type defined
   to unsigned int or unsigned long among various ARCHs usually

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 Changes in v2:
  - commit messages offered by Tejun are applied
  - redundant type cast is removed

 mm/percpu.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 9903830aaebb..e2737e56b017 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1961,7 +1961,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	void *base = (void *)ULONG_MAX;
 	void **areas = NULL;
 	struct pcpu_alloc_info *ai;
-	size_t size_sum, areas_size, max_distance;
+	size_t size_sum, areas_size;
+	unsigned long max_distance;
 	int group, i, rc;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
@@ -2023,17 +2024,18 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	}
 
 	/* base address is now known, determine group base offsets */
-	max_distance = 0;
+	i = 0;
 	for (group = 0; group < ai->nr_groups; group++) {
 		ai->groups[group].base_offset = areas[group] - base;
-		max_distance = max_t(size_t, max_distance,
-				     ai->groups[group].base_offset);
+		if (areas[group] > areas[i])
+			i = group;
 	}
-	max_distance += ai->unit_size;
+	max_distance = ai->groups[i].base_offset +
+		ai->unit_size * ai->groups[i].nr_units;
 
 	/* warn if maximum distance is further than 75% of vmalloc space */
 	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
-		pr_warn("max_distance=0x%zx too large for vmalloc space 0x%lx\n",
+		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
 			max_distance, VMALLOC_TOTAL);
 #ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
 		/* and fail if we have fallback */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
