Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DfLwx101464
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:41:24 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DfJ6g2760784
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:41:19 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DfIef008789
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:41:19 GMT
Date: Mon, 4 Dec 2006 14:41:18 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH/RFC 5/5] convert extmem to new interface
Message-ID: <20061204134118.GG9209@osiris.boeblingen.de.ibm.com>
References: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Convert extmem to use [add|remove]_shared_memory().

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/kernel/setup.c |    2 
 arch/s390/mm/extmem.c    |  106 +++++++++++------------------------------------
 2 files changed, 27 insertions(+), 81 deletions(-)

Index: linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/kernel/setup.c
+++ linux-2.6.19-rc6-mm2/arch/s390/kernel/setup.c
@@ -64,7 +64,7 @@ unsigned int console_devno = -1;
 unsigned int console_irq = -1;
 unsigned long machine_flags = 0;
 
-struct mem_chunk memory_chunk[MEMORY_CHUNKS];
+struct mem_chunk __initdata memory_chunk[MEMORY_CHUNKS];
 volatile int __cpu_logical_map[NR_CPUS]; /* logical cpu to cpu address */
 unsigned long __initdata zholes_size[MAX_NR_ZONES];
 static unsigned long __initdata memory_end;
Index: linux-2.6.19-rc6-mm2/arch/s390/mm/extmem.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/extmem.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/extmem.c
@@ -16,6 +16,7 @@
 #include <linux/bootmem.h>
 #include <linux/ctype.h>
 #include <asm/page.h>
+#include <asm/pgtable.h>
 #include <asm/ebcdic.h>
 #include <asm/errno.h>
 #include <asm/extmem.h>
@@ -238,65 +239,6 @@ query_segment_type (struct dcss_segment 
 }
 
 /*
- * check if the given segment collides with guest storage.
- * returns 1 if this is the case, 0 if no collision was found
- */
-static int
-segment_overlaps_storage(struct dcss_segment *seg)
-{
-	int i;
-
-	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++) {
-		if (memory_chunk[i].type != CHUNK_READ_WRITE)
-			continue;
-		if ((memory_chunk[i].addr >> 20) > (seg->end >> 20))
-			continue;
-		if (((memory_chunk[i].addr + memory_chunk[i].size - 1) >> 20)
-				< (seg->start_addr >> 20))
-			continue;
-		return 1;
-	}
-	return 0;
-}
-
-/*
- * check if segment collides with other segments that are currently loaded
- * returns 1 if this is the case, 0 if no collision was found
- */
-static int
-segment_overlaps_others (struct dcss_segment *seg)
-{
-	struct list_head *l;
-	struct dcss_segment *tmp;
-
-	BUG_ON(!mutex_is_locked(&dcss_lock));
-	list_for_each(l, &dcss_list) {
-		tmp = list_entry(l, struct dcss_segment, list);
-		if ((tmp->start_addr >> 20) > (seg->end >> 20))
-			continue;
-		if ((tmp->end >> 20) < (seg->start_addr >> 20))
-			continue;
-		if (seg == tmp)
-			continue;
-		return 1;
-	}
-	return 0;
-}
-
-/*
- * check if segment exceeds the kernel mapping range (detected or set via mem=)
- * returns 1 if this is the case, 0 if segment fits into the range
- */
-static inline int
-segment_exceeds_range (struct dcss_segment *seg)
-{
-	int seg_last_pfn = (seg->end) >> PAGE_SHIFT;
-	if (seg_last_pfn > max_pfn)
-		return 1;
-	return 0;
-}
-
-/*
  * get info about a segment
  * possible return values:
  * -ENOSYS  : we are not running on VM
@@ -341,24 +283,26 @@ __segment_load (char *name, int do_nonsh
 	rc = query_segment_type (seg);
 	if (rc < 0)
 		goto out_free;
-	if (segment_exceeds_range(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - exceeds"
-				" kernel mapping range\n",name);
-		rc = -ERANGE;
+
+	rc = add_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
+
+	switch (rc) {
+	case 0:
+		break;
+	case -ENOSPC:
+		PRINT_WARN("segment_load: not loading segment %s - overlaps "
+			   "storage/segment\n", name);
 		goto out_free;
-	}
-	if (segment_overlaps_storage(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - overlaps"
-				" storage\n",name);
-		rc = -ENOSPC;
+	case -ERANGE:
+		PRINT_WARN("segment_load: not loading segment %s - exceeds "
+			   "kernel mapping range\n", name);
 		goto out_free;
-	}
-	if (segment_overlaps_others(seg)) {
-		PRINT_WARN ("segment_load: not loading segment %s - overlaps"
-				" other segments\n",name);
-		rc = -EBUSY;
+	default:
+		PRINT_WARN("segment_load: not loading segment %s (rc: %d)\n",
+			   name, rc);
 		goto out_free;
 	}
+
 	if (do_nonshared)
 		dcss_command = DCSS_LOADNSR;
 	else
@@ -372,7 +316,7 @@ __segment_load (char *name, int do_nonsh
 		rc = dcss_diag_translate_rc (seg->end);
 		dcss_diag(DCSS_PURGESEG, seg->dcss_name,
 				&seg->start_addr, &seg->end);
-		goto out_free;
+		goto out_shared;
 	}
 	seg->do_nonshared = do_nonshared;
 	atomic_set(&seg->ref_count, 1);
@@ -391,6 +335,8 @@ __segment_load (char *name, int do_nonsh
 				(void*)seg->start_addr, (void*)seg->end,
 				segtype_string[seg->vm_segtype]);
 	goto out;
+ out_shared:
+	remove_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
  out_free:
 	kfree(seg);
  out:
@@ -530,12 +476,12 @@ segment_unload(char *name)
 				"please report to linux390@de.ibm.com\n",name);
 		goto out_unlock;
 	}
-	if (atomic_dec_return(&seg->ref_count) == 0) {
-		list_del(&seg->list);
-		dcss_diag(DCSS_PURGESEG, seg->dcss_name,
-			  &dummy, &dummy);
-		kfree(seg);
-	}
+	if (atomic_dec_return(&seg->ref_count) != 0)
+		goto out_unlock;
+	remove_shared_memory(seg->start_addr, seg->end - seg->start_addr + 1);
+	list_del(&seg->list);
+	dcss_diag(DCSS_PURGESEG, seg->dcss_name, &dummy, &dummy);
+	kfree(seg);
 out_unlock:
 	mutex_unlock(&dcss_lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
