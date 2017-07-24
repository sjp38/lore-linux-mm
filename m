Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 713606B02F4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:43 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r7so26292824wrb.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:43 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p3si13514673wrd.273.2017.07.24.16.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:41 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 03/23] percpu: remove has_reserved from pcpu_chunk
Date: Mon, 24 Jul 2017 19:02:00 -0400
Message-ID: <20170724230220.21774-4-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Prior this variable was used to manage statistics when the first chunk
had a reserved region. The previous patch introduced start_offset to
keep track of the offset by value rather than boolean. Therefore,
has_reserved can be removed.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h | 5 -----
 mm/percpu-stats.c    | 2 +-
 mm/percpu.c          | 3 ---
 3 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 92fc012..c876b5b 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -23,11 +23,6 @@ struct pcpu_chunk {
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
-	bool			has_reserved;	/* Indicates if chunk has reserved space
-						   at the beginning. Reserved chunk will
-						   contain reservation for static chunk.
-						   Dynamic chunk will contain reservation
-						   for static and reserved chunks. */
 	int			start_offset;	/* the overlap with the previous
 						   region to have a page aligned
 						   base_addr */
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 44e561d..32f3550 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -58,7 +58,7 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 	int cur_min_alloc = 0, cur_med_alloc = 0, cur_max_alloc = 0;
 
 	alloc_sizes = buffer;
-	s_index = chunk->has_reserved ? 1 : 0;
+	s_index = (chunk->start_offset) ? 1 : 0;
 
 	/* find last allocation */
 	last_alloc = -1;
diff --git a/mm/percpu.c b/mm/percpu.c
index e94f0d1..470e1a0 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -727,7 +727,6 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->map[0] = 0;
 	chunk->map[1] = pcpu_unit_size | 1;
 	chunk->map_used = 1;
-	chunk->has_reserved = false;
 
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
@@ -1704,7 +1703,6 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	schunk->map[1] = schunk->start_offset;
 	schunk->map[2] = (ai->static_size + schunk->free_size) | 1;
 	schunk->map_used = 2;
-	schunk->has_reserved = true;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
@@ -1724,7 +1722,6 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->map[1] = dchunk->start_offset;
 		dchunk->map[2] = (dchunk->start_offset + dchunk->free_size) | 1;
 		dchunk->map_used = 2;
-		dchunk->has_reserved = true;
 	}
 
 	/* link the first chunk in */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
