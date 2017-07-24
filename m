Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14FC56B037C
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r63so15687262pfb.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q67si1675157pgq.557.2017.07.24.16.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:47 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 10/23] percpu: change the number of pages marked in the first_chunk pop bitmap
Date: Mon, 24 Jul 2017 19:02:07 -0400
Message-ID: <20170724230220.21774-11-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The populated bitmap represents the state of the pages the chunk serves.
Prior, the bitmap was marked completely used as the first chunk was
allocated and immutable. This is misleading because the first chunk may
not be completely filled. Additionally, with moving the base_addr up in
the previous patch, the population check no longer corresponds to what
was being checked.

This patch modifies the population map to be only the number of pages
the region serves and to make what it was checking correspond correctly
again. The change is to remove any misunderstanding between the size of
the populated bitmap and the actual size of it. The work function page
iterators now use nr_pages for the check rather than pcpu_unit_pages
because nr_populated is now chunk specific. Without this, the work
function would try to populate the remainder of these chunks despite it
not serving any more than nr_pages when nr_pages is set less than
pcpu_unit_pages.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 5b1fcef..773dafe 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -737,7 +737,9 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	region_size = PFN_ALIGN(start_offset + map_size);
 
 	/* allocate chunk */
-	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
+				    BITS_TO_LONGS(region_size >> PAGE_SHIFT),
+				    0);
 
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
@@ -746,15 +748,15 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->start_offset = start_offset;
 	chunk->end_offset = region_size - chunk->start_offset - map_size;
 
-	chunk->nr_pages = pcpu_unit_pages;
+	chunk->nr_pages = region_size >> PAGE_SHIFT;
 
 	chunk->map = map;
 	chunk->map_alloc = init_map_size;
 
 	/* manage populated page bitmap */
 	chunk->immutable = true;
-	bitmap_fill(chunk->populated, pcpu_unit_pages);
-	chunk->nr_populated = pcpu_unit_pages;
+	bitmap_fill(chunk->populated, chunk->nr_pages);
+	chunk->nr_populated = chunk->nr_pages;
 
 	chunk->contig_hint = chunk->free_size = map_size;
 
@@ -1212,7 +1214,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 	list_for_each_entry_safe(chunk, next, &to_free, list) {
 		int rs, re;
 
-		pcpu_for_each_pop_region(chunk, rs, re, 0, pcpu_unit_pages) {
+		pcpu_for_each_pop_region(chunk, rs, re, 0, chunk->nr_pages) {
 			pcpu_depopulate_chunk(chunk, rs, re);
 			spin_lock_irq(&pcpu_lock);
 			pcpu_chunk_depopulated(chunk, rs, re);
@@ -1269,7 +1271,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 
 		spin_lock_irq(&pcpu_lock);
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
-			nr_unpop = pcpu_unit_pages - chunk->nr_populated;
+			nr_unpop = chunk->nr_pages - chunk->nr_populated;
 			if (nr_unpop)
 				break;
 		}
@@ -1279,7 +1281,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			continue;
 
 		/* @chunk can't go away while pcpu_alloc_mutex is held */
-		pcpu_for_each_unpop_region(chunk, rs, re, 0, pcpu_unit_pages) {
+		pcpu_for_each_unpop_region(chunk, rs, re, 0, chunk->nr_pages) {
 			int nr = min(re - rs, nr_to_pop);
 
 			ret = pcpu_populate_chunk(chunk, rs, rs + nr);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
