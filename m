Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C51B56B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:29:41 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z190so13900303qkc.4
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:29:41 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id p29si1465610qta.7.2016.10.11.06.29.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 06:29:41 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH 1/1] mm/percpu.c: fix several trivial issues
Message-ID: <e9cf3570-2c35-42f6-4bb1-f60734651e6c@zoho.com>
Date: Tue, 11 Oct 2016 21:29:27 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

as shown by pcpu_setup_first_chunk(), the first chunk is same as the
reserved chunk if the reserved size is nonzero but the dynamic is zero
this special scenario is referred as the special case by below content

fix several trivial issues:

1) correct or fix several comments
the LSB of a chunk->map element is used as free/in-use flag and is cleared
for free area and set for in-use, rather than use positive/negative number
to mark area state.

2) change atomic size to PAGE_SIZE for consistency when CONFIG_SMP == n
both default setup_per_cpu_areas() and pcpu_page_first_chunk()
use PAGE_SIZE as atomic size when CONFIG_SMP == y; however
setup_per_cpu_areas() allocates memory for the only unit with alignment
PAGE_SIZE but assigns unit size to atomic size when CONFIG_SMP == n, so the
atomic size isn't consistent with either the alignment or the SMP ones.
fix it by changing atomic size to PAGE_SIZE when CONFIG_SMP == n

3) correct empty and populated pages statistic error
in order to service dynamic atomic memory allocation, the number of empty
and populated pages of chunks is counted to maintain above a low threshold.
however, for the special case, the first chunk is took into account by
pcpu_setup_first_chunk(), it is meaningless since the chunk don't include
any dynamic areas.
fix it by excluding the reserved chunk before statistic as the other
contexts do.

4) fix potential memory leakage for percpu_init_late()
in order to manage chunk->map memory uniformly, for the first and reserved
chunks, percpu_init_late() will allocate memory to replace the static
chunk->map array within section .init.data after slab is brought up
however, for the special case, memory are allocated for the same chunk->map
twice since the first chunk reference is same as the reserved, so the
memory allocated at the first time are leaked obviously.
fix it by eliminating the second memory allocation under the special case

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/percpu.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 26d1c73bd9e2..760a4730f6fd 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -36,8 +36,8 @@
  * chunk maps unnecessarily.
  *
  * Allocation state in each chunk is kept using an array of integers
- * on chunk->map.  A positive value in the map represents a free
- * region and negative allocated.  Allocation inside a chunk is done
+ * on chunk->map.  A LSB cleared value in the map represents a free
+ * region and set allocated.  Allocation inside a chunk is done
  * by scanning this map sequentially and serving the first matching
  * entry.  This is mostly copied from the percpu_modalloc() allocator.
  * Chunks can be determined from the address using the index field
@@ -93,9 +93,9 @@
 #endif
 #ifndef __pcpu_ptr_to_addr
 #define __pcpu_ptr_to_addr(ptr)						\
-	(void __force *)((unsigned long)(ptr) +				\
-			 (unsigned long)pcpu_base_addr -		\
-			 (unsigned long)__per_cpu_start)
+	(void __force *)((unsigned long)(ptr) -				\
+			 (unsigned long)__per_cpu_start +		\
+			 (unsigned long)pcpu_base_addr)
 #endif
 #else	/* CONFIG_SMP */
 /* on UP, it's always identity mapped */
@@ -583,6 +583,11 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align,
 		 * merge'em.  Note that 'small' is defined as smaller
 		 * than sizeof(int), which is very small but isn't too
 		 * uncommon for percpu allocations.
+		 *
+		 * it is unnecessary to append i > 0 to make sure p[-1]
+		 * available: the offset of the first area is 0 and is aligned
+		 * very well, no head free area is left if segments one piece
+		 * from it
 		 */
 		if (head && (head < sizeof(int) || !(p[-1] & 1))) {
 			*p = off += head;
@@ -1707,8 +1712,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* link the first chunk in */
 	pcpu_first_chunk = dchunk ?: schunk;
-	pcpu_nr_empty_pop_pages +=
-		pcpu_count_occupied_pages(pcpu_first_chunk, 1);
+	if (pcpu_first_chunk != pcpu_reserved_chunk)
+		pcpu_nr_empty_pop_pages +=
+				pcpu_count_occupied_pages(pcpu_first_chunk, 1);
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
 	/* we're done */
@@ -2266,7 +2272,7 @@ void __init setup_per_cpu_areas(void)
 
 	ai->dyn_size = unit_size;
 	ai->unit_size = unit_size;
-	ai->atom_size = unit_size;
+	ai->atom_size = PAGE_SIZE;
 	ai->alloc_size = unit_size;
 	ai->groups[0].nr_units = 1;
 	ai->groups[0].cpu_map[0] = 0;
@@ -2291,6 +2297,9 @@ void __init percpu_init_late(void)
 	unsigned long flags;
 	int i;
 
+	if (pcpu_first_chunk == pcpu_reserved_chunk)
+		target_chunks[1] = NULL;
+
 	for (i = 0; (chunk = target_chunks[i]); i++) {
 		int *map;
 		const size_t size = PERCPU_DYNAMIC_EARLY_SLOTS * sizeof(map[0]);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
