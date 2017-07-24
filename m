Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A59C6B0492
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:03:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p17so3422031wmd.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:03:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f40si10433052wra.464.2017.07.24.16.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:59 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 18/23] percpu: keep track of the best offset for contig hints
Date: Mon, 24 Jul 2017 19:02:15 -0400
Message-ID: <20170724230220.21774-19-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch makes the contig hint starting offset optimization from the
previous patch as honest as it can be. For both chunk and block starting
offsets, make sure it keeps the starting offset with the best alignment.

The block skip optimization is added in a later patch when the
pcpu_find_block_fit iterator is swapped in.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 3732373..aaad747 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -394,12 +394,18 @@ static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk, int bit_off,
  * @bits: size of free area
  *
  * This updates the chunk's contig hint and starting offset given a free area.
+ * Choose the best starting offset if the contig hint is equal.
  */
 static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
 {
 	if (bits > chunk->contig_bits) {
 		chunk->contig_bits_start = bit_off;
 		chunk->contig_bits = bits;
+	} else if (bits == chunk->contig_bits && chunk->contig_bits_start &&
+		   (!bit_off ||
+		    __ffs(bit_off) > __ffs(chunk->contig_bits_start))) {
+		/* use the start with the best alignment */
+		chunk->contig_bits_start = bit_off;
 	}
 }
 
@@ -454,7 +460,8 @@ static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
  * @end: end offset in block
  *
  * Updates a block given a known free area.  The region [start, end) is
- * expected to be the entirety of the free area within a block.
+ * expected to be the entirety of the free area within a block.  Chooses
+ * the best starting offset if the contig hints are equal.
  */
 static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
 {
@@ -470,6 +477,10 @@ static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
 	if (contig > block->contig_hint) {
 		block->contig_hint_start = start;
 		block->contig_hint = contig;
+	} else if (block->contig_hint_start && contig == block->contig_hint &&
+		   (!start || __ffs(start) > __ffs(block->contig_hint_start))) {
+		/* use the start with the best alignment */
+		block->contig_hint_start = start;
 	}
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
