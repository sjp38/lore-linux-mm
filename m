Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A9F8D6B0035
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 07:06:13 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3341856pad.0
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 04:06:13 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id ob6si1281192pbb.1.2014.03.27.04.06.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 04:06:12 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so3220027pdb.28
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 04:06:12 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 2/2] mm/percpu.c: don't bother to re-walk the pcpu_slot list if nobody free space since we last drop pcpu_lock.
Date: Thu, 27 Mar 2014 19:06:03 +0800
Message-Id: <1395918363-6823-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Presently, after we fail the first try to walk the pcpu_slot list
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

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/percpu.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 69 insertions(+), 11 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index cfda29c..4e81367 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -178,6 +178,13 @@ static DEFINE_MUTEX(pcpu_alloc_mutex);	/* protects whole alloc and reclaim */
 static DEFINE_SPINLOCK(pcpu_lock);	/* protects index data structures */
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
+/* A bitmap to record the stat of pcpu_slot, protected by pcpu_lock.
+ * If the correspoding bit == 0, that slot doesn't get changed during
+ * pcpu_lock dropped period; if bit == 1, otherwise.
+ *
+ * We have to defer its initialization until we konw the exact value of
+ * pcpu_nr_slots. */
+static unsigned long *pcpu_slot_stat_bitmap;
 
 /* reclaim work to release fully free chunks, scheduled from free path */
 static void pcpu_reclaim(struct work_struct *work);
@@ -313,10 +320,13 @@ static void pcpu_mem_free(void *ptr, size_t size)
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
@@ -326,15 +336,23 @@ static void pcpu_mem_free(void *ptr, size_t size)
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
 
@@ -546,12 +564,12 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align)
 		chunk->free_size -= chunk->map[i];
 		chunk->map[i] = -chunk->map[i];
 
-		pcpu_chunk_relocate(chunk, oslot);
+		pcpu_chunk_relocate(chunk, oslot, PCPU_ALLOC);
 		return off;
 	}
 
 	chunk->contig_hint = max_contig;	/* fully scanned */
-	pcpu_chunk_relocate(chunk, oslot);
+	pcpu_chunk_relocate(chunk, oslot, PCPU_ALLOC);
 
 	/* tell the upper layer that this chunk has no matching area */
 	return -1;
@@ -600,7 +618,7 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme)
 	}
 
 	chunk->contig_hint = max(chunk->map[i], chunk->contig_hint);
-	pcpu_chunk_relocate(chunk, oslot);
+	pcpu_chunk_relocate(chunk, oslot, PCPU_FREE);
 }
 
 static struct pcpu_chunk *pcpu_alloc_chunk(void)
@@ -714,6 +732,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	int slot, off, new_alloc;
 	unsigned long flags;
 	void __percpu *ptr;
+	bool retry = false;
+	int base_slot = pcpu_size_to_slot(size);
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "
@@ -752,7 +772,12 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 
 restart:
 	/* search through normal chunks */
-	for (slot = pcpu_size_to_slot(size); slot < pcpu_nr_slots; slot++) {
+	for (slot = base_slot; slot < pcpu_nr_slots; slot++) {
+		/* even we fall back to retry, just look inside those
+		 * changed slots */
+		if (retry && !test_bit(slot, pcpu_slot_stat_bitmap))
+			continue;
+
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
 			if (size > chunk->contig_hint)
 				continue;
@@ -770,6 +795,7 @@ restart:
 				 * pcpu_lock has been dropped, need to
 				 * restart cpu_slot list walking.
 				 */
+				retry = false;
 				goto restart;
 			}
 
@@ -780,6 +806,7 @@ restart:
 	}
 
 	/* hmmm... no space left, create a new chunk */
+	bitmap_zero(pcpu_slot_stat_bitmap, pcpu_nr_slots);
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	chunk = pcpu_create_chunk();
@@ -789,7 +816,28 @@ restart:
 	}
 
 	spin_lock_irqsave(&pcpu_lock, flags);
-	pcpu_chunk_relocate(chunk, -1);
+	/* put the new chunk it slot list, we deem it a freeing action.*/
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
@@ -1315,11 +1363,20 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * empty chunks.
 	 */
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
+	/* We allocate the space for pcpu_slot and pcpu_slot_stat_bitmap
+	 * in one go. */
 	pcpu_slot = memblock_virt_alloc(
-			pcpu_nr_slots * sizeof(pcpu_slot[0]), 0);
+		pcpu_nr_slots * sizeof(pcpu_slot[0]) +
+		BITS_TO_LONGS(pcpu_nr_slots) * sizeof(unsigned long), 0);
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
+	pcpu_slot_stat_bitmap = (unsigned long *)PTR_ALIGN(
+		(char *)pcpu_slot + pcpu_nr_slots * sizeof(pcpu_slot[0]),
+				sizeof(unsigned long));
+	bitmap_zero(pcpu_slot_stat_bitmap, pcpu_nr_slots);
+
+
 	/*
 	 * Initialize static chunk.  If reserved_size is zero, the
 	 * static chunk covers static area + dynamic allocation area
@@ -1366,7 +1423,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* link the first chunk in */
 	pcpu_first_chunk = dchunk ?: schunk;
-	pcpu_chunk_relocate(pcpu_first_chunk, -1);
+	/* put the new chunk it slot list, we deem it a freeing action.*/
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
