Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D95096B03A1
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 184so12096905wmo.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e35si12629163wre.324.2017.07.24.16.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:50 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 11/23] percpu: introduce nr_empty_pop_pages to help empty page accounting
Date: Mon, 24 Jul 2017 19:02:08 -0400
Message-ID: <20170724230220.21774-12-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

pcpu_nr_empty_pop_pages is used to ensure there are a handful of free
pages around to serve atomic allocations. A new field, nr_empty_pop_pages,
is added to the pcpu_chunk struct to keep track of the number of empty
pages. This field is needed as the number of empty populated pages is
globally tracked and deltas are used to update in the bitmap allocator.
Pages that contain a hidden area are not considered to be empty. This
new field is exposed in percpu_stats.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |  1 +
 mm/percpu-stats.c    |  1 +
 mm/percpu.c          | 11 ++++++++---
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 34cb979..c4c8fc4 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -32,6 +32,7 @@ struct pcpu_chunk {
 
 	int			nr_pages;	/* # of pages served by this chunk */
 	int			nr_populated;	/* # of populated pages */
+	int                     nr_empty_pop_pages; /* # of empty populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
 
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index ffbdb96..e146b58 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -100,6 +100,7 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
+	P("empty_pop_pages", chunk->nr_empty_pop_pages);
 	P("free_size", chunk->free_size);
 	P("contig_hint", chunk->contig_hint);
 	P("sum_frag", sum_frag);
diff --git a/mm/percpu.c b/mm/percpu.c
index 773dafe..657ab08 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -757,11 +757,14 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->immutable = true;
 	bitmap_fill(chunk->populated, chunk->nr_pages);
 	chunk->nr_populated = chunk->nr_pages;
+	chunk->nr_empty_pop_pages = chunk->nr_pages;
 
 	chunk->contig_hint = chunk->free_size = map_size;
 
 	if (chunk->start_offset) {
 		/* hide the beginning of the bitmap */
+		chunk->nr_empty_pop_pages--;
+
 		chunk->map[0] = 1;
 		chunk->map[1] = chunk->start_offset;
 		chunk->map_used = 1;
@@ -773,6 +776,8 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 
 	if (chunk->end_offset) {
 		/* hide the end of the bitmap */
+		chunk->nr_empty_pop_pages--;
+
 		chunk->map[++chunk->map_used] = region_size | 1;
 	}
 
@@ -836,6 +841,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk,
 
 	bitmap_set(chunk->populated, page_start, nr);
 	chunk->nr_populated += nr;
+	chunk->nr_empty_pop_pages += nr;
 	pcpu_nr_empty_pop_pages += nr;
 }
 
@@ -858,6 +864,7 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
 
 	bitmap_clear(chunk->populated, page_start, nr);
 	chunk->nr_populated -= nr;
+	chunk->nr_empty_pop_pages -= nr;
 	pcpu_nr_empty_pop_pages -= nr;
 }
 
@@ -1782,9 +1789,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* link the first chunk in */
 	pcpu_first_chunk = chunk;
-	i = (pcpu_first_chunk->start_offset) ? 1 : 0;
-	pcpu_nr_empty_pop_pages +=
-		pcpu_count_occupied_pages(pcpu_first_chunk, i);
+	pcpu_nr_empty_pop_pages = pcpu_first_chunk->nr_empty_pop_pages;
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
 	pcpu_stats_chunk_alloc();
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
