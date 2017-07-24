Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 884116B0491
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u17so142036764pfa.6
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:58 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 68si7555361pgc.96.2017.07.24.16.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:57 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 19/23] percpu: update alloc path to only scan if contig hints are broken
Date: Mon, 24 Jul 2017 19:02:16 -0400
Message-ID: <20170724230220.21774-20-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Metadata is kept per block to keep track of where the contig hints are.
Scanning can be avoided when the contig hints are not broken. In that
case, left and right contigs have to be managed manually.

This patch changes the allocation path hint updating to only scan when
contig hints are broken.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 56 insertions(+), 3 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index aaad747..2bf2cfc 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -514,6 +514,10 @@ static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
  * @chunk: chunk of interest
  * @bit_off: chunk offset
  * @bits: size of request
+ *
+ * Updates metadata for the allocation path.  The metadata only has to be
+ * refreshed by a full scan iff the chunk's contig hint is broken.  Block level
+ * scans are required if the block's contig hint is broken.
  */
 static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 					 int bits)
@@ -538,14 +542,56 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 
 	/*
 	 * Update s_block.
+	 * block->first_free must be updated if the allocation takes its place.
+	 * If the allocation breaks the contig_hint, a scan is required to
+	 * restore this hint.
 	 */
-	pcpu_block_refresh_hint(chunk, s_index);
+	if (s_off == s_block->first_free)
+		s_block->first_free = find_next_zero_bit(
+					pcpu_index_alloc_map(chunk, s_index),
+					PCPU_BITMAP_BLOCK_BITS,
+					s_off + bits);
+
+	if (s_off >= s_block->contig_hint_start &&
+	    s_off < s_block->contig_hint_start + s_block->contig_hint) {
+		/* block contig hint is broken - scan to fix it */
+		pcpu_block_refresh_hint(chunk, s_index);
+	} else {
+		/* update left and right contig manually */
+		s_block->left_free = min(s_block->left_free, s_off);
+		if (s_index == e_index)
+			s_block->right_free = min_t(int, s_block->right_free,
+					PCPU_BITMAP_BLOCK_BITS - e_off);
+		else
+			s_block->right_free = 0;
+	}
 
 	/*
 	 * Update e_block.
 	 */
 	if (s_index != e_index) {
-		pcpu_block_refresh_hint(chunk, e_index);
+		/*
+		 * When the allocation is across blocks, the end is along
+		 * the left part of the e_block.
+		 */
+		e_block->first_free = find_next_zero_bit(
+				pcpu_index_alloc_map(chunk, e_index),
+				PCPU_BITMAP_BLOCK_BITS, e_off);
+
+		if (e_off == PCPU_BITMAP_BLOCK_BITS) {
+			/* reset the block */
+			e_block++;
+		} else {
+			if (e_off > e_block->contig_hint_start) {
+				/* contig hint is broken - scan to fix it */
+				pcpu_block_refresh_hint(chunk, e_index);
+			} else {
+				e_block->left_free = 0;
+				e_block->right_free =
+					min_t(int, e_block->right_free,
+					      PCPU_BITMAP_BLOCK_BITS - e_off);
+			}
+		}
 
 		/* update in-between md_blocks */
 		for (block = s_block + 1; block < e_block; block++) {
@@ -555,7 +601,14 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 		}
 	}
 
-	pcpu_chunk_refresh_hint(chunk);
+	/*
+	 * The only time a full chunk scan is required is if the chunk
+	 * contig hint is broken.  Otherwise, it means a smaller space
+	 * was used and therefore the chunk contig hint is still correct.
+	 */
+	if (bit_off >= chunk->contig_bits_start  &&
+	    bit_off < chunk->contig_bits_start + chunk->contig_bits)
+		pcpu_chunk_refresh_hint(chunk);
 }
 
 /**
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
