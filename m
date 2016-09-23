Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D45F28024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 19:20:59 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so227403043pab.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 16:20:59 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id 27si10030765pfn.124.2016.09.23.16.20.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 16:20:58 -0700 (PDT)
Subject: Re: [RESEND PATCH 1/1] mm/percpu.c: correct max_distance calculation
 for pcpu_embed_first_chunk()
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <0310bf92-c8da-459f-58e3-40b8bfbb7223@zoho.com>
Date: Sat, 24 Sep 2016 07:20:49 +0800
MIME-Version: 1.0
In-Reply-To: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: zijun_hu@htc.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

it is error to represent the max range max_distance spanned by all the
group areas as the offset of the highest group area plus unit size in
pcpu_embed_first_chunk(), it should equal to the offset plus the size
of the highest group area

in order to fix this issue,let us find the highest group area who has the
biggest base address among all the ones, then max_distance is formed by
add it's offset and size value

the type of variant max_distance is changed from size_t to unsigned long
to prevent potential overflow

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 more detailed commit messages is provided against the previous one as
 advised by tj@kernel.org

 mm/percpu.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index fcaaac977954..ee0d1c93f070 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1963,7 +1963,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	void *base = (void *)ULONG_MAX;
 	void **areas = NULL;
 	struct pcpu_alloc_info *ai;
-	size_t size_sum, areas_size, max_distance;
+	size_t size_sum, areas_size;
+	unsigned long max_distance;
 	int group, i, rc;
 
 	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
@@ -2025,17 +2026,18 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
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
+		(unsigned long)ai->unit_size * ai->groups[i].nr_units;
 
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
