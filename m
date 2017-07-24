Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 030FD6B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r63so15683508pfb.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i11si7633845plk.472.2017.07.24.16.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:37 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 02/23] percpu: introduce start_offset to pcpu_chunk
Date: Mon, 24 Jul 2017 19:01:59 -0400
Message-ID: <20170724230220.21774-3-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The reserved chunk arithmetic uses a global variable
pcpu_reserved_chunk_limit that is set in the first chunk init code to
hide a portion of the area map. The bitmap allocator to come will
eventually move the base_addr up and require both the reserved chunk
and static chunk to maintain this offset. pcpu_reserved_chunk_limit is
removed and start_offset is added.

The first chunk that is circulated and is pcpu_first_chunk serves the
dynamic region, the region following the reserved region. The reserved
chunk address check will temporarily use the first chunk to identify its
address range. A following patch will increase the base_addr and remove
this. If there is no reserved chunk, this will check the static region
and return false because those values should never be passed into the
allocator.

Lastly, when linking in the first chunk, make sure to count the right
free region for the number of empty populated pages.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |  3 +++
 mm/percpu.c          | 21 ++++++++++-----------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index c9158a4..92fc012 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -28,6 +28,9 @@ struct pcpu_chunk {
 						   contain reservation for static chunk.
 						   Dynamic chunk will contain reservation
 						   for static and reserved chunks. */
+	int			start_offset;	/* the overlap with the previous
+						   region to have a page aligned
+						   base_addr */
 	int			nr_populated;	/* # of populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
diff --git a/mm/percpu.c b/mm/percpu.c
index 3602d41..e94f0d1 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -145,13 +145,10 @@ struct pcpu_chunk *pcpu_first_chunk __ro_after_init;
 
 /*
  * Optional reserved chunk.  This chunk reserves part of the first
- * chunk and serves it for reserved allocations.  The amount of
- * reserved offset is in pcpu_reserved_chunk_limit.  When reserved
- * area doesn't exist, the following variables contain NULL and 0
- * respectively.
+ * chunk and serves it for reserved allocations.  When the reserved
+ * region doesn't exist, the following variable is NULL.
  */
 struct pcpu_chunk *pcpu_reserved_chunk __ro_after_init;
-static int pcpu_reserved_chunk_limit __ro_after_init;
 
 DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
 static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
@@ -196,7 +193,7 @@ static bool pcpu_addr_in_reserved_chunk(void *addr)
 	void *first_start = pcpu_first_chunk->base_addr;
 
 	return addr >= first_start &&
-		addr < first_start + pcpu_reserved_chunk_limit;
+		addr < first_start + pcpu_first_chunk->start_offset;
 }
 
 static int __pcpu_size_to_slot(int size)
@@ -1687,6 +1684,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	INIT_LIST_HEAD(&schunk->list);
 	INIT_LIST_HEAD(&schunk->map_extend_list);
 	schunk->base_addr = base_addr;
+	schunk->start_offset = ai->static_size;
 	schunk->map = smap;
 	schunk->map_alloc = ARRAY_SIZE(smap);
 	schunk->immutable = true;
@@ -1696,7 +1694,6 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	if (ai->reserved_size) {
 		schunk->free_size = ai->reserved_size;
 		pcpu_reserved_chunk = schunk;
-		pcpu_reserved_chunk_limit = ai->static_size + ai->reserved_size;
 	} else {
 		schunk->free_size = dyn_size;
 		dyn_size = 0;			/* dynamic area covered */
@@ -1704,7 +1701,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	schunk->contig_hint = schunk->free_size;
 	schunk->map[0] = 1;
-	schunk->map[1] = ai->static_size;
+	schunk->map[1] = schunk->start_offset;
 	schunk->map[2] = (ai->static_size + schunk->free_size) | 1;
 	schunk->map_used = 2;
 	schunk->has_reserved = true;
@@ -1715,6 +1712,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		INIT_LIST_HEAD(&dchunk->list);
 		INIT_LIST_HEAD(&dchunk->map_extend_list);
 		dchunk->base_addr = base_addr;
+		dchunk->start_offset = ai->static_size + ai->reserved_size;
 		dchunk->map = dmap;
 		dchunk->map_alloc = ARRAY_SIZE(dmap);
 		dchunk->immutable = true;
@@ -1723,16 +1721,17 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 		dchunk->contig_hint = dchunk->free_size = dyn_size;
 		dchunk->map[0] = 1;
-		dchunk->map[1] = pcpu_reserved_chunk_limit;
-		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
+		dchunk->map[1] = dchunk->start_offset;
+		dchunk->map[2] = (dchunk->start_offset + dchunk->free_size) | 1;
 		dchunk->map_used = 2;
 		dchunk->has_reserved = true;
 	}
 
 	/* link the first chunk in */
 	pcpu_first_chunk = dchunk ?: schunk;
+	i = (pcpu_first_chunk->start_offset) ? 1 : 0;
 	pcpu_nr_empty_pop_pages +=
-		pcpu_count_occupied_pages(pcpu_first_chunk, 1);
+		pcpu_count_occupied_pages(pcpu_first_chunk, i);
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
 	pcpu_stats_chunk_alloc();
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
