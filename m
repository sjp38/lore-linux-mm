Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E51CF6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e9so32737734pga.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:40 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l67si7209465pfc.549.2017.07.24.16.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:40 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 04/23] percpu: setup_first_chunk remove dyn_size and consolidate logic
Date: Mon, 24 Jul 2017 19:02:01 -0400
Message-ID: <20170724230220.21774-5-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

There is logic for setting variables in the static chunk init code that
could be consolidated with the dynamic chunk init code. This combines
this logic to setup for combining the allocation paths. reserved_size is
used as the conditional as a dynamic region will always exist.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 470e1a0..851aa81 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1562,8 +1562,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 {
 	static int smap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
-	size_t dyn_size = ai->dyn_size;
-	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
+	size_t size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	struct pcpu_chunk *schunk, *dchunk = NULL;
 	unsigned long *group_offsets;
 	size_t *group_sizes;
@@ -1690,14 +1689,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	bitmap_fill(schunk->populated, pcpu_unit_pages);
 	schunk->nr_populated = pcpu_unit_pages;
 
-	if (ai->reserved_size) {
-		schunk->free_size = ai->reserved_size;
-		pcpu_reserved_chunk = schunk;
-	} else {
-		schunk->free_size = dyn_size;
-		dyn_size = 0;			/* dynamic area covered */
-	}
-
+	schunk->free_size = ai->reserved_size ?: ai->dyn_size;
 	schunk->contig_hint = schunk->free_size;
 	schunk->map[0] = 1;
 	schunk->map[1] = schunk->start_offset;
@@ -1705,7 +1697,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	schunk->map_used = 2;
 
 	/* init dynamic chunk if necessary */
-	if (dyn_size) {
+	if (ai->reserved_size) {
+		pcpu_reserved_chunk = schunk;
+
 		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 		INIT_LIST_HEAD(&dchunk->list);
 		INIT_LIST_HEAD(&dchunk->map_extend_list);
@@ -1717,7 +1711,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		bitmap_fill(dchunk->populated, pcpu_unit_pages);
 		dchunk->nr_populated = pcpu_unit_pages;
 
-		dchunk->contig_hint = dchunk->free_size = dyn_size;
+		dchunk->contig_hint = dchunk->free_size = ai->dyn_size;
 		dchunk->map[0] = 1;
 		dchunk->map[1] = dchunk->start_offset;
 		dchunk->map[2] = (dchunk->start_offset + dchunk->free_size) | 1;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
