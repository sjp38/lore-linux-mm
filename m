Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89BAB6B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h29so142239037pfd.2
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:43 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 4si7225290pfk.101.2017.07.24.16.02.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:42 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 06/23] percpu: end chunk area maps page aligned for the populated bitmap
Date: Mon, 24 Jul 2017 19:02:03 -0400
Message-ID: <20170724230220.21774-7-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The area map allocator manages the first chunk area by hiding all but
the region it is responsible for serving in the area map. To align this
with the populated page bitmap, end_offset is introduced to keep track
of the delta to end page aligned. The area map is appended with the
page aligned end when necessary to be in line with how the bitmap
allocator requires the ending to be aligned with the LCM of PAGE_SIZE
and the size of each bitmap block. percpu_stats is updated to ignore
this region when present.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h | 3 +++
 mm/percpu-stats.c    | 5 +++--
 mm/percpu.c          | 9 +++++++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index c876b5b..f02f31c 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -26,6 +26,9 @@ struct pcpu_chunk {
 	int			start_offset;	/* the overlap with the previous
 						   region to have a page aligned
 						   base_addr */
+	int			end_offset;	/* additional area required to
+						   have the region end page
+						   aligned */
 	int			nr_populated;	/* # of populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 32f3550..ffbdb96 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -51,7 +51,7 @@ static int find_max_map_used(void)
 static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 			    int *buffer)
 {
-	int i, s_index, last_alloc, alloc_sign, as_len;
+	int i, s_index, e_index, last_alloc, alloc_sign, as_len;
 	int *alloc_sizes, *p;
 	/* statistics */
 	int sum_frag = 0, max_frag = 0;
@@ -59,10 +59,11 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 
 	alloc_sizes = buffer;
 	s_index = (chunk->start_offset) ? 1 : 0;
+	e_index = chunk->map_used - ((chunk->end_offset) ? 1 : 0);
 
 	/* find last allocation */
 	last_alloc = -1;
-	for (i = chunk->map_used - 1; i >= s_index; i--) {
+	for (i = e_index - 1; i >= s_index; i--) {
 		if (chunk->map[i] & 1) {
 			last_alloc = i;
 			break;
diff --git a/mm/percpu.c b/mm/percpu.c
index 2e785a7..1d2c980 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -715,12 +715,16 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(void *base_addr,
 							 int init_map_size)
 {
 	struct pcpu_chunk *chunk;
+	int region_size;
+
+	region_size = PFN_ALIGN(start_offset + map_size);
 
 	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
 	chunk->base_addr = base_addr;
 	chunk->start_offset = start_offset;
+	chunk->end_offset = region_size - chunk->start_offset - map_size;
 	chunk->map = map;
 	chunk->map_alloc = init_map_size;
 
@@ -735,6 +739,11 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(void *base_addr,
 	chunk->map[2] = (chunk->start_offset + chunk->free_size) | 1;
 	chunk->map_used = 2;
 
+	if (chunk->end_offset) {
+		/* hide the end of the bitmap */
+		chunk->map[++chunk->map_used] = region_size | 1;
+	}
+
 	return chunk;
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
