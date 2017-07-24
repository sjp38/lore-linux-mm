Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 264966B0313
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g28so26304750wrg.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:47 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u7si13769935wrb.292.2017.07.24.16.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:46 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 07/23] percpu: setup_first_chunk rename schunk/dchunk to chunk
Date: Mon, 24 Jul 2017 19:02:04 -0400
Message-ID: <20170724230220.21774-8-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

There is no need to have the static chunk and dynamic chunk be named
separately as the allocations are sequential. This preemptively solves
the misnomer problem with the base_addrs being moved up in the following
patch. It also removes a ternary operation deciding the first chunk.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 1d2c980..e08ed61 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1602,7 +1602,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
-	struct pcpu_chunk *schunk, *dchunk = NULL;
+	struct pcpu_chunk *chunk;
 	unsigned long *group_offsets;
 	size_t *group_sizes;
 	unsigned long *unit_off;
@@ -1720,22 +1720,22 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 */
 	start_offset = ai->static_size;
 	map_size = ai->reserved_size ?: ai->dyn_size;
-	schunk = pcpu_alloc_first_chunk(base_addr, start_offset, map_size,
-					smap, ARRAY_SIZE(smap));
+	chunk = pcpu_alloc_first_chunk(base_addr, start_offset, map_size, smap,
+				       ARRAY_SIZE(smap));
 
 	/* init dynamic chunk if necessary */
 	if (ai->reserved_size) {
-		pcpu_reserved_chunk = schunk;
+		pcpu_reserved_chunk = chunk;
 
 		start_offset = ai->static_size + ai->reserved_size;
 		map_size = ai->dyn_size;
-		dchunk = pcpu_alloc_first_chunk(base_addr, start_offset,
-						map_size, dmap,
-						ARRAY_SIZE(dmap));
+		chunk = pcpu_alloc_first_chunk(base_addr, start_offset,
+					       map_size, dmap,
+					       ARRAY_SIZE(dmap));
 	}
 
 	/* link the first chunk in */
-	pcpu_first_chunk = dchunk ?: schunk;
+	pcpu_first_chunk = chunk;
 	i = (pcpu_first_chunk->start_offset) ? 1 : 0;
 	pcpu_nr_empty_pop_pages +=
 		pcpu_count_occupied_pages(pcpu_first_chunk, i);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
