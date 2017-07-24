Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1B06B03B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r7so26293517wrb.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n8si13633811wra.23.2017.07.24.16.02.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:53 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 13/23] percpu: generalize bitmap (un)populated iterators
Date: Mon, 24 Jul 2017 19:02:10 -0400
Message-ID: <20170724230220.21774-14-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The area map allocator only used a bitmap for the backing page state.
The new bitmap allocator will use bitmaps to manage the allocation
region in addition to this.

This patch generalizes the bitmap iterators so they can be reused with
the bitmap allocator.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index dc755721..84cc255 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -253,35 +253,32 @@ static unsigned long pcpu_chunk_addr(struct pcpu_chunk *chunk,
 	       pcpu_unit_page_offset(cpu, page_idx);
 }
 
-static void __maybe_unused pcpu_next_unpop(struct pcpu_chunk *chunk,
-					   int *rs, int *re, int end)
+static void pcpu_next_unpop(unsigned long *bitmap, int *rs, int *re, int end)
 {
-	*rs = find_next_zero_bit(chunk->populated, end, *rs);
-	*re = find_next_bit(chunk->populated, end, *rs + 1);
+	*rs = find_next_zero_bit(bitmap, end, *rs);
+	*re = find_next_bit(bitmap, end, *rs + 1);
 }
 
-static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
-					 int *rs, int *re, int end)
+static void pcpu_next_pop(unsigned long *bitmap, int *rs, int *re, int end)
 {
-	*rs = find_next_bit(chunk->populated, end, *rs);
-	*re = find_next_zero_bit(chunk->populated, end, *rs + 1);
+	*rs = find_next_bit(bitmap, end, *rs);
+	*re = find_next_zero_bit(bitmap, end, *rs + 1);
 }
 
 /*
- * (Un)populated page region iterators.  Iterate over (un)populated
- * page regions between @start and @end in @chunk.  @rs and @re should
- * be integer variables and will be set to start and end page index of
- * the current region.
+ * Bitmap region iterators.  Iterates over the bitmap between
+ * [@start, @end) in @chunk.  @rs and @re should be integer variables
+ * and will be set to start and end index of the current free region.
  */
-#define pcpu_for_each_unpop_region(chunk, rs, re, start, end)		    \
-	for ((rs) = (start), pcpu_next_unpop((chunk), &(rs), &(re), (end)); \
-	     (rs) < (re);						    \
-	     (rs) = (re) + 1, pcpu_next_unpop((chunk), &(rs), &(re), (end)))
+#define pcpu_for_each_unpop_region(bitmap, rs, re, start, end)		     \
+	for ((rs) = (start), pcpu_next_unpop((bitmap), &(rs), &(re), (end)); \
+	     (rs) < (re);						     \
+	     (rs) = (re) + 1, pcpu_next_unpop((bitmap), &(rs), &(re), (end)))
 
-#define pcpu_for_each_pop_region(chunk, rs, re, start, end)		    \
-	for ((rs) = (start), pcpu_next_pop((chunk), &(rs), &(re), (end));   \
-	     (rs) < (re);						    \
-	     (rs) = (re) + 1, pcpu_next_pop((chunk), &(rs), &(re), (end)))
+#define pcpu_for_each_pop_region(bitmap, rs, re, start, end)		     \
+	for ((rs) = (start), pcpu_next_pop((bitmap), &(rs), &(re), (end));   \
+	     (rs) < (re);						     \
+	     (rs) = (re) + 1, pcpu_next_pop((bitmap), &(rs), &(re), (end)))
 
 /**
  * pcpu_mem_zalloc - allocate memory
@@ -521,7 +518,8 @@ static int pcpu_fit_in_area(struct pcpu_chunk *chunk, int off, int this_size,
 		page_end = PFN_UP(head + off + size);
 
 		rs = page_start;
-		pcpu_next_unpop(chunk, &rs, &re, PFN_UP(off + this_size));
+		pcpu_next_unpop(chunk->populated, &rs, &re,
+				PFN_UP(off + this_size));
 		if (rs >= page_end)
 			return head;
 		cand_off = re * PAGE_SIZE;
@@ -1071,7 +1069,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		page_start = PFN_DOWN(off);
 		page_end = PFN_UP(off + size);
 
-		pcpu_for_each_unpop_region(chunk, rs, re, page_start, page_end) {
+		pcpu_for_each_unpop_region(chunk->populated, rs, re,
+					   page_start, page_end) {
 			WARN_ON(chunk->immutable);
 
 			ret = pcpu_populate_chunk(chunk, rs, re);
@@ -1221,7 +1220,8 @@ static void pcpu_balance_workfn(struct work_struct *work)
 	list_for_each_entry_safe(chunk, next, &to_free, list) {
 		int rs, re;
 
-		pcpu_for_each_pop_region(chunk, rs, re, 0, chunk->nr_pages) {
+		pcpu_for_each_pop_region(chunk->populated, rs, re, 0,
+					 chunk->nr_pages) {
 			pcpu_depopulate_chunk(chunk, rs, re);
 			spin_lock_irq(&pcpu_lock);
 			pcpu_chunk_depopulated(chunk, rs, re);
@@ -1288,7 +1288,8 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			continue;
 
 		/* @chunk can't go away while pcpu_alloc_mutex is held */
-		pcpu_for_each_unpop_region(chunk, rs, re, 0, chunk->nr_pages) {
+		pcpu_for_each_unpop_region(chunk->populated, rs, re, 0,
+					   chunk->nr_pages) {
 			int nr = min(re - rs, nr_to_pop);
 
 			ret = pcpu_populate_chunk(chunk, rs, rs + nr);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
