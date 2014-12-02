Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id F0DE16B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 17:34:12 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id j7so9605749qaq.15
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 14:34:12 -0800 (PST)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0088.outbound.protection.outlook.com. [65.55.169.88])
        by mx.google.com with ESMTPS id 37si9673284qgo.41.2014.12.02.14.34.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Dec 2014 14:34:11 -0800 (PST)
Message-ID: <547E3E57.3040908@ixiacom.com>
Date: Wed, 3 Dec 2014 00:33:59 +0200
From: Leonard Crestez <lcrestez@ixiacom.com>
MIME-Version: 1.0
Subject: [RFC v2] percpu: Add a separate function to merge free areas
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux-foundation.org>, Sorin Dumitru <sdumitru@ixiacom.com>

Hello,

It seems that free_percpu performance is very bad when working with small 
objects. The easiest way to reproduce this is to allocate and then free a large 
number of percpu int counters in order. Small objects (reference counters and 
pointers) are common users of alloc_percpu and I think this should be fast.
This particular issue can be encountered with very large number of net_device
structs.

The problem seems to be that pcpu_chunk keeps an array of all alocated areas. At 
free time pcpu_free_area will delete items from that array linearly, using 
memmove. This has worst-case quadratic complexity in the number of areas per 
chunk. This gets really bad if the areas are small and are allocated and freed in order.

One way to fix this is to merge free areas in a separate function and handle
multiple frees at once. There is a patch below which does this, but
I'm not sure it's correct.

Instead of merging free areas on every free we only do it when 2/3 of
the slots in the map are used. This should hopefully amortize to linear
complexity instead of quadratic.

I've posted an earlier version of this to lkml earlier but got no response. That
was probably because I only posted to lkml. I now sent to linux-mm and the people
reported by "get_maintainer.pl". Here's a link to the older post:

https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg777188.html

That version of the patch is incorrect. Never updating contig_hint on free means
that once a chunk's contig_hint reaches 0 (when completely allocated) that chunk
will never be considered for allocation again. It also doesn't amortize the frees.

Entirely different solutions could be considered. For example it might make sense to
make chunks smaller (they are about ~40K on the system I care about). Or maybe even
write an entirely custom allocator for very small fixed-size percpu objects.

Signed-off-by: Crestez Dan Leonard <lcrestez@ixiacom.com>
---
 mm/percpu.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 78 insertions(+), 22 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 014bab6..9d85198 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -109,6 +109,7 @@ struct pcpu_chunk {
 
 	int			map_used;	/* # of map entries used before the sentry */
 	int			map_alloc;	/* # of map entries allocated */
+	int			map_free_count;	/* # of map entries freed but not merged */
 	int			*map;		/* allocation map */
 	struct work_struct	map_extend_work;/* async ->map[] extension */
 
@@ -375,6 +376,69 @@ static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
 }
 
 /**
+ * percpu_merge_free_spaces - merge spaces in a chunk
+ * @chunk: chunk of interest
+ *
+ * This function should merge a continous region of free
+ * spaces into a single one.
+ *
+ * CONTEXT:
+ * pcpu_lock.
+ */
+static void pcpu_merge_free_spaces(struct pcpu_chunk *chunk)
+{
+	int start;
+	int i, j;
+
+	chunk->map_free_count = 0;
+
+	/* We copy from map[i] into map[j] while merging free spaces. */
+	i = j = chunk->first_free;
+	/* In case first_free points to something busy */
+	if (chunk->map[i] & 1)
+		goto eat_busy;
+
+eat_free:
+	/* Look for busy space
+	 * Last chunk is always busy, no need to check map_used
+	 */
+	for (start = i; !(chunk->map[i] & 1); ++i);
+
+	/* Collapse */
+	if (j != start)
+		chunk->map[j] = chunk->map[start];
+	++chunk->map_free_count;
+	++j;
+
+	chunk->contig_hint = max(chunk->contig_hint,
+		(chunk->map[i] & ~1) - chunk->map[start]);
+
+eat_busy:
+	/* Look for free space */
+	for (start = i; i <= chunk->map_used && (chunk->map[i] & 1); ++i);
+
+	/* Move stuff if appropriate */
+	if (j != start)
+		memmove(chunk->map + j, chunk->map + start, (i - start) * sizeof(*chunk->map));
+	j += i - start;
+
+	if (i > chunk->map_used)
+		goto end;
+	else
+		goto eat_free;
+
+end:
+	/* Done */
+	chunk->map_used = j - 1;
+}
+
+static inline void pcpu_check_merge_free_spaces(struct pcpu_chunk *chunk)
+{
+	if (chunk->map_free_count * 3 >= chunk->map_used * 2)
+		pcpu_merge_free_spaces(chunk);
+}
+
+/**
  * pcpu_need_to_extend - determine whether chunk area map needs to be extended
  * @chunk: chunk of interest
  * @is_atomic: the allocation context
@@ -623,10 +687,12 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align,
 				*++p = off += head;
 				++i;
 				max_contig = max(head, max_contig);
+				chunk->map_free_count++;
 			}
 			if (tail) {
 				p[1] = off + size;
 				max_contig = max(tail, max_contig);
+				chunk->map_free_count++;
 			}
 		}
 
@@ -641,6 +707,7 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align,
 						 max_contig);
 
 		chunk->free_size -= size;
+		chunk->map_free_count--;
 		*p |= 1;
 
 		*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
@@ -674,8 +741,7 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	int oslot = pcpu_chunk_slot(chunk);
 	int off = 0;
 	unsigned i, j;
-	int to_free = 0;
-	int *p;
+	int this_size;
 
 	freeme |= 1;	/* we are searching for <given offset, in use> pair */
 
@@ -696,28 +762,15 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	if (i < chunk->first_free)
 		chunk->first_free = i;
 
-	p = chunk->map + i;
-	*p = off &= ~1;
-	chunk->free_size += (p[1] & ~1) - off;
-
+	/* Mark this area as free */
+	chunk->map[i] &= ~1;
+	this_size = (chunk->map[i + 1] & ~1) - chunk->map[i];
+	chunk->free_size += this_size;
 	*occ_pages_p = pcpu_count_occupied_pages(chunk, i);
+	chunk->contig_hint = max(chunk->contig_hint, this_size);
+	chunk->map_free_count++;
 
-	/* merge with next? */
-	if (!(p[1] & 1))
-		to_free++;
-	/* merge with previous? */
-	if (i > 0 && !(p[-1] & 1)) {
-		to_free++;
-		i--;
-		p--;
-	}
-	if (to_free) {
-		chunk->map_used -= to_free;
-		memmove(p + 1, p + 1 + to_free,
-			(chunk->map_used - i) * sizeof(chunk->map[0]));
-	}
-
-	chunk->contig_hint = max(chunk->map[i + 1] - chunk->map[i] - 1, chunk->contig_hint);
+	pcpu_check_merge_free_spaces(chunk);
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
@@ -740,6 +793,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->map[0] = 0;
 	chunk->map[1] = pcpu_unit_size | 1;
 	chunk->map_used = 1;
+	chunk->map_free_count = 1;
 
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_WORK(&chunk->map_extend_work, pcpu_map_extend_workfn);
@@ -1669,6 +1723,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	schunk->map[0] = 1;
 	schunk->map[1] = ai->static_size;
 	schunk->map_used = 1;
+	schunk->map_free_count = 1;
 	if (schunk->free_size)
 		schunk->map[++schunk->map_used] = 1 | (ai->static_size + schunk->free_size);
 	else
@@ -1691,6 +1746,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->map[1] = pcpu_reserved_chunk_limit;
 		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
 		dchunk->map_used = 2;
+		dchunk->map_free_count = 1;
 	}
 
 	/* link the first chunk in */
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
