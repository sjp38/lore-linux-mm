Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id BAF1D6B0036
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:56:05 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so4967151pbc.23
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:56:05 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id bs8si3653561pad.53.2014.03.28.05.56.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 05:56:04 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so4976895pbc.37
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:56:04 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 2/2] mm/percpu.c: don't bother to re-walk the pcpu_slot list if nobody free space since we last drop pcpu_lock
Date: Fri, 28 Mar 2014 20:55:57 +0800
Message-Id: <1396011357-21560-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Currently, after we fail the first try to walk the pcpu_slot list
to find a chunk for allocating, we just drop the pcpu_lock spinlock,
and go allocating a new chunk. Then we re-gain the pcpu_lock and
anchoring our hope on that during this period, some guys might have
freed space for us(we still hold the pcpu_alloc_mutex during this
period, so only freeing or reclaiming could happen), we do a fully
rewalk of the pcpu_slot list.

However if nobody free space, this fully rewalk may seem too silly,
and we would eventually fall back to the new chunk.

And since we hold pcpu_alloc_mutex, only freeing or reclaiming path
could touch the pcpu_slot(which just need holding a pcpu_lock), we
could maintain a pcpu_slot_stat bitmap to record that during the period
we don't have the pcpu_lock, if anybody free space to any slot we
interest in. If so, we just just go inside these slots for a try;
if not, we just do allocation using the newly-allocated fully-free
new chunk.

Quoted tj: 
>Hmmm... I'm not sure whether the added complexity is worthwhile.  It's
>a fairly cold path.  Can you show how helpful this optimization is?

The patch is quite less intrusive in the normal path
and if we fall on the cold path, it means after satifying this allocation 
the chunk may be moved to lower slot, and the follow-up allocation 
of same or larger size(though rare) is likely to fail to cold path again. So
this patch could be based on to do some heuristic later.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/percpu.c | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 65 insertions(+), 12 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 63e24fb..2d100b6 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -179,6 +179,10 @@ static DEFINE_MUTEX(pcpu_alloc_mutex);	/* protects whole alloc and reclaim */
 static DEFINE_SPINLOCK(pcpu_lock);	/* protects index data structures */
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
+/* A bitmap to record the stat of pcpu_slot, protected by pcpu_lock.
+ * If the correspoding bit == 0, that slot doesn't get changed during
+ * pcpu_lock dropped period; if bit == 1, otherwise. */
+static unsigned long *pcpu_slot_stat_bitmap;
 
 /* reclaim work to release fully free chunks, scheduled from free path */
 static void pcpu_reclaim(struct work_struct *work);
@@ -314,10 +318,13 @@ static void pcpu_mem_free(void *ptr, size_t size)
 		vfree(ptr);
 }
 
+#define PCPU_ALLOC 1
+#define PCPU_FREE  0
 /**
  * pcpu_chunk_relocate - put chunk in the appropriate chunk slot
  * @chunk: chunk of interest
  * @oslot: the previous slot it was on
+ * @reason: why we get here, from allocating or freeing path?
  *
  * This function is called after an allocation or free changed @chunk.
  * New slot according to the changed state is determined and @chunk is
@@ -327,15 +334,23 @@ static void pcpu_mem_free(void *ptr, size_t size)
  * CONTEXT:
  * pcpu_lock.
  */
-static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
+static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot,
+				int reason)
 {
 	int nslot = pcpu_chunk_slot(chunk);
 
-	if (chunk != pcpu_reserved_chunk && oslot != nslot) {
-		if (oslot < nslot)
+	if (chunk != pcpu_reserved_chunk) {
+		if (oslot < nslot) {
 			list_move(&chunk->list, &pcpu_slot[nslot]);
-		else
+			/* oslot < nslot means we get more space
+			 * in this chunk, so mark it */
+			__set_bit(nslot, pcpu_slot_stat_bitmap);
+		} else if (oslot > nslot)
 			list_move_tail(&chunk->list, &pcpu_slot[nslot]);
+		else if (reason == PCPU_FREE)
+			/* oslot == nslot, but we are freeing space
+			 * in this chunk, worth trying, mark it */
+			__set_bit(nslot, pcpu_slot_stat_bitmap);
 	}
 }
 
@@ -526,12 +541,12 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align)
 		chunk->free_size -= size;
 		*p |= 1;
 
-		pcpu_chunk_relocate(chunk, oslot);
+		pcpu_chunk_relocate(chunk, oslot, PCPU_ALLOC);
 		return off;
 	}
 
 	chunk->contig_hint = max_contig;	/* fully scanned */
-	pcpu_chunk_relocate(chunk, oslot);
+	pcpu_chunk_relocate(chunk, oslot, PCPU_ALLOC);
 
 	/* tell the upper layer that this chunk has no matching area */
 	return -1;
@@ -596,7 +611,7 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme)
 	}
 
 	chunk->contig_hint = max(chunk->map[i + 1] - chunk->map[i] - 1, chunk->contig_hint);
-	pcpu_chunk_relocate(chunk, oslot);
+	pcpu_chunk_relocate(chunk, oslot, PCPU_FREE);
 }
 
 static struct pcpu_chunk *pcpu_alloc_chunk(void)
@@ -712,6 +727,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	int slot, off, new_alloc;
 	unsigned long flags;
 	void __percpu *ptr;
+	bool retry = false;
+	int base_slot = pcpu_size_to_slot(size);
 
 	/*
 	 * We want the lowest bit of offset available for in-use/free
@@ -760,7 +777,12 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 
 restart:
 	/* search through normal chunks */
-	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
+	for (slot = base_slot; slot < pcpu_nr_slots; slot++) {
+		/* even we fall back to retry, just look inside those
+		 * changed slots */
+		if (unlikely(retry) && !test_bit(slot, pcpu_slot_stat_bitmap))
+			continue;
+
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
 			if (size > chunk->contig_hint)
 				continue;
@@ -778,6 +800,7 @@ restart:
 				 * pcpu_lock has been dropped, need to
 				 * restart cpu_slot list walking.
 				 */
+				retry = false;
 				goto restart;
 			}
 
@@ -788,6 +811,7 @@ restart:
 	}
 
 	/* hmmm... no space left, create a new chunk */
+	bitmap_zero(pcpu_slot_stat_bitmap, pcpu_nr_slots);
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	chunk = pcpu_create_chunk();
@@ -797,7 +821,28 @@ restart:
 	}
 
 	spin_lock_irqsave(&pcpu_lock, flags);
-	pcpu_chunk_relocate(chunk, -1);
+	/* put the new chunk in slot list, we deem it a freeing action.*/
+	pcpu_chunk_relocate(chunk, -1, PCPU_FREE);
+
+	/*
+	 * If during the period since we last drop the lock,
+	 * no others free space to the pcpu_slot, then
+	 * don't bother walking pcpu_slot list again,
+	 * just alloc from the newly-alloc'ed chunk.
+	 */
+	bitmap_zero(pcpu_slot_stat_bitmap, base_slot);
+
+	/* pcpu_chunk_relocate() will put the new chunk
+	 * in slot[pcpu_nr_slots - 1], thus don't test it.*/
+	if (bitmap_empty(pcpu_slot_stat_bitmap,
+			pcpu_nr_slots - 1 - base_slot)) {
+		off = pcpu_alloc_area(chunk, size, align);
+		if (likely(off >= 0))
+			goto area_found;
+	}
+
+	/* somebody might free enough space, worth trying again. */
+	retry = true;
 	goto restart;
 
 area_found:
@@ -1323,10 +1368,17 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * empty chunks.
 	 */
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
-	pcpu_slot = memblock_virt_alloc(
-			pcpu_nr_slots * sizeof(pcpu_slot[0]), 0);
+	/* We allocate the space for pcpu_slot and pcpu_slot_stat_bitmap
+	 * in one go. */
+	pcpu_slot = memblock_virt_alloc(ALIGN(
+		pcpu_nr_slots * sizeof(pcpu_slot[0]), sizeof(unsigned long)) +
+		BITS_TO_LONGS(pcpu_nr_slots) * sizeof(unsigned long), 0);
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
+	pcpu_slot_stat_bitmap = (unsigned long *)PTR_ALIGN(
+		(char *)pcpu_slot + pcpu_nr_slots * sizeof(pcpu_slot[0]),
+		sizeof(unsigned long));
+	bitmap_zero(pcpu_slot_stat_bitmap, pcpu_nr_slots);
 
 	/*
 	 * Initialize static chunk.  If reserved_size is zero, the
@@ -1380,7 +1432,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* link the first chunk in */
 	pcpu_first_chunk = dchunk ?: schunk;
-	pcpu_chunk_relocate(pcpu_first_chunk, -1);
+	/* put the new chunk in slot list, we deem it a freeing action.*/
+	pcpu_chunk_relocate(pcpu_first_chunk, -1, PCPU_FREE);
 
 	/* we're done */
 	pcpu_base_addr = base_addr;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
