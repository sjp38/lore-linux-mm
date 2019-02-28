Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F37D0C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CD4D218A2
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CD4D218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 330A78E000A; Wed, 27 Feb 2019 21:18:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DE228E0001; Wed, 27 Feb 2019 21:18:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F6408E000A; Wed, 27 Feb 2019 21:18:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E087A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:54 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k1so17385605qta.2
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=2UFbqY461brc1FjkureY/Gfr31p0F1luW2ekNOMU524=;
        b=Zq02QsUaqYLmDvGA4eUyMiQYSde9Pe7pWXYWXyLqEoATK63ucMNC+IddQnPJ/7FOX+
         eyqB3cjQw3ZqK1Z07+bhx+maHDRBYU4iIkqU9eXTfgoHJdeD+1S89GlFpF9A/8GhWIX/
         UZgDLZbMc6f+cG495j1mA89gBGPxRMUOmF8H9M23imF6DWw5AZWUc/60yg5dKcIv4KLF
         uyLmjdOpQgfmMZrmDVfRxfdZmyaaX30DWtCP2mlrg69VIpw3hteoX4vi6IeXOgL4cLns
         w9Uy3ENYKVsjqPkNQ8hM+KNdPzGbSK0rczbSnU+/qQKexJ0G90xYFNvkcCNM70iLXOa0
         L82A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW66J3h0TnxoKRxTB/djVhAQem6OS3dvhMZT9Qx5teqZk7VwJwD
	CefMMK927wz64ISnZF3lQC7mSq5iDuhcPLXNG3H7rjls0nk3Tui64Am+byqOEjo3ss+jBGg5LHa
	t/jz2SyWzOL+35xm6yihWh3RyUCtNlZ1WnJZ5iyP5jUy7AdECwxbB6r8OSe6D2TZmoV6Qv2/IIe
	aIzP5s+gbXAmTdoi5B0Y/DcMthXBsTYDrGI7w3sdXYryDzi6UCqqQN37J07XN/bK+7Bc6P1/qXX
	n0ziCRuFekf0cm4KazTgv+USE4BenjIujcrwXaanNW9sqTRO/seCHxHEe/+L11jHP6+vqKFu+f0
	d82szE1iua6J44UsNkAGoJgT1nXs76hQ9HYWtAKPe1pT0CVMiYwRobh/mUC1xW6CwO6wR78fvg=
	=
X-Received: by 2002:a37:2d82:: with SMTP id t124mr4423883qkh.189.1551320334648;
        Wed, 27 Feb 2019 18:18:54 -0800 (PST)
X-Received: by 2002:a37:2d82:: with SMTP id t124mr4423845qkh.189.1551320333211;
        Wed, 27 Feb 2019 18:18:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320333; cv=none;
        d=google.com; s=arc-20160816;
        b=KdkJq3EnVWcwRTog4ea3v10/FAFqauHTaIomjNashQsAVq4g+Ur4ZJsuns/rBXxcZN
         5VLmASY/L3BIIY6dIZznBP9CmWa4FZrbPNRQxzVRwJ69PFkLDKhpNmM+jEzkwAR4CtOz
         cvpB/prw6tIYmixPiytqQLybCNaiZ3Uzdkl/8XJpGnH/W/kT2/WMAGrt1sfNC9GGh7Vb
         0OSzV8ZPAyf+MPbUwqsVsu3OYYXAzMJCUQonNSgrjB1lzaE61gTIgPxYADKfXgzFe6QB
         7rBSAiAkmEo7JsiXsu2xvu2TM4xH7XMxi+DUmjkRyXKPTghR1ZO9QjzW3gt91Ajlyr5W
         zA1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=2UFbqY461brc1FjkureY/Gfr31p0F1luW2ekNOMU524=;
        b=tdintd97NY+wdlHHudGJYuEba85kKnKcIGib29G3FkKkfDxHCbfMhDgXAuZFIhvV6V
         4ROCLfzhNL6XoENoTXpHvxYEAvkNmrCmavstfATaDtAT1DaG/rycT0sb/01bzs8B9MWv
         I+Y9V6MRYYfv5nywU3cl2vo3Ullu/VkPKQ8+wU00OEG7Q4t4KuUbzCt92ZxJS0d9ydQf
         c0OHaSXlM6sOrUT3xejTR9fCoM3o0QGxuPdhPsQJhFDAwJmlrm1Co00knACWP1ZtyAFf
         ydHnr2P70BTzZAUd4Hyh3wpxOdEFGT+jgDcY21Sh/Rz0F8Y+im3pfJ+Is1iRynXubcgk
         wz1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m34sor13959730qtc.49.2019.02.27.18.18.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:53 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqy7SfzqTS2eC6N4NJPS3aEmzBOCrx29EFkHxyf98XFxuUO5ukJK8ov1LOZtSqC2rkGFcsVCeg==
X-Received: by 2002:ac8:34ae:: with SMTP id w43mr4467741qtb.145.1551320332727;
        Wed, 27 Feb 2019 18:18:52 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:51 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 06/12] percpu: set PCPU_BITMAP_BLOCK_SIZE to PAGE_SIZE
Date: Wed, 27 Feb 2019 21:18:33 -0500
Message-Id: <20190228021839.55779-7-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Previously, block size was flexible based on the constraint that the
GCD(PCPU_BITMAP_BLOCK_SIZE, PAGE_SIZE) > 1. However, this carried the
overhead that keeping a floating number of populated free pages required
scanning over the free regions of a chunk.

Setting the block size to be fixed at PAGE_SIZE lets us know when an
empty page becomes used as we will break a full contig_hint of a block.
This means we no longer have to scan the whole chunk upon breaking a
contig_hint which empty page management piggybacks off. A later patch
takes advantage of this to optimize the allocation path by only scanning
forward using the scan_hint introduced later too.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 include/linux/percpu.h |  12 ++---
 mm/percpu-km.c         |   2 +-
 mm/percpu.c            | 111 +++++++++++++++++------------------------
 3 files changed, 49 insertions(+), 76 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 70b7123f38c7..9909dc0e273a 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -26,16 +26,10 @@
 #define PCPU_MIN_ALLOC_SHIFT		2
 #define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
 
-/* number of bits per page, used to trigger a scan if blocks are > PAGE_SIZE */
-#define PCPU_BITS_PER_PAGE		(PAGE_SIZE >> PCPU_MIN_ALLOC_SHIFT)
-
 /*
- * This determines the size of each metadata block.  There are several subtle
- * constraints around this constant.  The reserved region must be a multiple of
- * PCPU_BITMAP_BLOCK_SIZE.  Additionally, PCPU_BITMAP_BLOCK_SIZE must be a
- * multiple of PAGE_SIZE or PAGE_SIZE must be a multiple of
- * PCPU_BITMAP_BLOCK_SIZE to align with the populated page map. The unit_size
- * also has to be a multiple of PCPU_BITMAP_BLOCK_SIZE to ensure full blocks.
+ * The PCPU_BITMAP_BLOCK_SIZE must be the same size as PAGE_SIZE as the
+ * updating of hints is used to manage the nr_empty_pop_pages in both
+ * the chunk and globally.
  */
 #define PCPU_BITMAP_BLOCK_SIZE		PAGE_SIZE
 #define PCPU_BITMAP_BLOCK_BITS		(PCPU_BITMAP_BLOCK_SIZE >>	\
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 0f643dc2dc65..c10bf7466596 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -70,7 +70,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	chunk->base_addr = page_address(pages) - pcpu_group_offsets[0];
 
 	spin_lock_irqsave(&pcpu_lock, flags);
-	pcpu_chunk_populated(chunk, 0, nr_pages, false);
+	pcpu_chunk_populated(chunk, 0, nr_pages);
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	pcpu_stats_chunk_alloc();
diff --git a/mm/percpu.c b/mm/percpu.c
index 3d7deece9556..967c9cc3a928 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -527,37 +527,21 @@ static void pcpu_chunk_relocate(struct pcpu_chunk *chunk, int oslot)
 		__pcpu_chunk_move(chunk, nslot, oslot < nslot);
 }
 
-/**
- * pcpu_cnt_pop_pages- counts populated backing pages in range
+/*
+ * pcpu_update_empty_pages - update empty page counters
  * @chunk: chunk of interest
- * @bit_off: start offset
- * @bits: size of area to check
+ * @nr: nr of empty pages
  *
- * Calculates the number of populated pages in the region
- * [page_start, page_end).  This keeps track of how many empty populated
- * pages are available and decide if async work should be scheduled.
- *
- * RETURNS:
- * The nr of populated pages.
+ * This is used to keep track of the empty pages now based on the premise
+ * a pcpu_block_md covers a page.  The hint update functions recognize if
+ * a block is made full or broken to calculate deltas for keeping track of
+ * free pages.
  */
-static inline int pcpu_cnt_pop_pages(struct pcpu_chunk *chunk, int bit_off,
-				     int bits)
+static inline void pcpu_update_empty_pages(struct pcpu_chunk *chunk, int nr)
 {
-	int page_start = PFN_UP(bit_off * PCPU_MIN_ALLOC_SIZE);
-	int page_end = PFN_DOWN((bit_off + bits) * PCPU_MIN_ALLOC_SIZE);
-
-	if (page_start >= page_end)
-		return 0;
-
-	/*
-	 * bitmap_weight counts the number of bits set in a bitmap up to
-	 * the specified number of bits.  This is counting the populated
-	 * pages up to page_end and then subtracting the populated pages
-	 * up to page_start to count the populated pages in
-	 * [page_start, page_end).
-	 */
-	return bitmap_weight(chunk->populated, page_end) -
-	       bitmap_weight(chunk->populated, page_start);
+	chunk->nr_empty_pop_pages += nr;
+	if (chunk != pcpu_reserved_chunk)
+		pcpu_nr_empty_pop_pages += nr;
 }
 
 /*
@@ -611,36 +595,19 @@ static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
  * Updates:
  *      chunk->contig_bits
  *      chunk->contig_bits_start
- *      nr_empty_pop_pages (chunk and global)
  */
 static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
 {
-	int bit_off, bits, nr_empty_pop_pages;
+	int bit_off, bits;
 
 	/* clear metadata */
 	chunk->contig_bits = 0;
 
 	bit_off = chunk->first_bit;
-	bits = nr_empty_pop_pages = 0;
+	bits = 0;
 	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
 		pcpu_chunk_update(chunk, bit_off, bits);
-
-		nr_empty_pop_pages += pcpu_cnt_pop_pages(chunk, bit_off, bits);
 	}
-
-	/*
-	 * Keep track of nr_empty_pop_pages.
-	 *
-	 * The chunk maintains the previous number of free pages it held,
-	 * so the delta is used to update the global counter.  The reserved
-	 * chunk is not part of the free page count as they are populated
-	 * at init and are special to serving reserved allocations.
-	 */
-	if (chunk != pcpu_reserved_chunk)
-		pcpu_nr_empty_pop_pages +=
-			(nr_empty_pop_pages - chunk->nr_empty_pop_pages);
-
-	chunk->nr_empty_pop_pages = nr_empty_pop_pages;
 }
 
 /**
@@ -712,6 +679,7 @@ static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
 static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 					 int bits)
 {
+	int nr_empty_pages = 0;
 	struct pcpu_block_md *s_block, *e_block, *block;
 	int s_index, e_index;	/* block indexes of the freed allocation */
 	int s_off, e_off;	/* block offsets of the freed allocation */
@@ -736,6 +704,9 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 	 * If the allocation breaks the contig_hint, a scan is required to
 	 * restore this hint.
 	 */
+	if (s_block->contig_hint == PCPU_BITMAP_BLOCK_BITS)
+		nr_empty_pages++;
+
 	if (s_off == s_block->first_free)
 		s_block->first_free = find_next_zero_bit(
 					pcpu_index_alloc_map(chunk, s_index),
@@ -763,6 +734,9 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 	 * Update e_block.
 	 */
 	if (s_index != e_index) {
+		if (e_block->contig_hint == PCPU_BITMAP_BLOCK_BITS)
+			nr_empty_pages++;
+
 		/*
 		 * When the allocation is across blocks, the end is along
 		 * the left part of the e_block.
@@ -787,6 +761,7 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 		}
 
 		/* update in-between md_blocks */
+		nr_empty_pages += (e_index - s_index - 1);
 		for (block = s_block + 1; block < e_block; block++) {
 			block->contig_hint = 0;
 			block->left_free = 0;
@@ -794,6 +769,9 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 		}
 	}
 
+	if (nr_empty_pages)
+		pcpu_update_empty_pages(chunk, -1 * nr_empty_pages);
+
 	/*
 	 * The only time a full chunk scan is required is if the chunk
 	 * contig hint is broken.  Otherwise, it means a smaller space
@@ -826,6 +804,7 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 					int bits)
 {
+	int nr_empty_pages = 0;
 	struct pcpu_block_md *s_block, *e_block, *block;
 	int s_index, e_index;	/* block indexes of the freed allocation */
 	int s_off, e_off;	/* block offsets of the freed allocation */
@@ -879,14 +858,19 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 
 	/* update s_block */
 	e_off = (s_index == e_index) ? end : PCPU_BITMAP_BLOCK_BITS;
+	if (!start && e_off == PCPU_BITMAP_BLOCK_BITS)
+		nr_empty_pages++;
 	pcpu_block_update(s_block, start, e_off);
 
 	/* freeing in the same block */
 	if (s_index != e_index) {
 		/* update e_block */
+		if (end == PCPU_BITMAP_BLOCK_BITS)
+			nr_empty_pages++;
 		pcpu_block_update(e_block, 0, end);
 
 		/* reset md_blocks in the middle */
+		nr_empty_pages += (e_index - s_index - 1);
 		for (block = s_block + 1; block < e_block; block++) {
 			block->first_free = 0;
 			block->contig_hint_start = 0;
@@ -896,15 +880,16 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 		}
 	}
 
+	if (nr_empty_pages)
+		pcpu_update_empty_pages(chunk, nr_empty_pages);
+
 	/*
-	 * Refresh chunk metadata when the free makes a page free, a block
-	 * free, or spans across blocks.  The contig hint may be off by up to
-	 * a page, but if the hint is contained in a block, it will be accurate
-	 * with the else condition below.
+	 * Refresh chunk metadata when the free makes a block free or spans
+	 * across blocks.  The contig_hint may be off by up to a page, but if
+	 * the contig_hint is contained in a block, it will be accurate with
+	 * the else condition below.
 	 */
-	if ((ALIGN_DOWN(end, min(PCPU_BITS_PER_PAGE, PCPU_BITMAP_BLOCK_BITS)) >
-	     ALIGN(start, min(PCPU_BITS_PER_PAGE, PCPU_BITMAP_BLOCK_BITS))) ||
-	    s_index != e_index)
+	if (((end - start) >= PCPU_BITMAP_BLOCK_BITS) || s_index != e_index)
 		pcpu_chunk_refresh_hint(chunk);
 	else
 		pcpu_chunk_update(chunk, pcpu_block_off_to_off(s_index, start),
@@ -1164,9 +1149,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->immutable = true;
 	bitmap_fill(chunk->populated, chunk->nr_pages);
 	chunk->nr_populated = chunk->nr_pages;
-	chunk->nr_empty_pop_pages =
-		pcpu_cnt_pop_pages(chunk, start_offset / PCPU_MIN_ALLOC_SIZE,
-				   map_size / PCPU_MIN_ALLOC_SIZE);
+	chunk->nr_empty_pop_pages = chunk->nr_pages;
 
 	chunk->contig_bits = map_size / PCPU_MIN_ALLOC_SIZE;
 	chunk->free_bytes = map_size;
@@ -1261,7 +1244,6 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
  * @chunk: pcpu_chunk which got populated
  * @page_start: the start page
  * @page_end: the end page
- * @for_alloc: if this is to populate for allocation
  *
  * Pages in [@page_start,@page_end) have been populated to @chunk.  Update
  * the bookkeeping information accordingly.  Must be called after each
@@ -1271,7 +1253,7 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
  * is to serve an allocation in that area.
  */
 static void pcpu_chunk_populated(struct pcpu_chunk *chunk, int page_start,
-				 int page_end, bool for_alloc)
+				 int page_end)
 {
 	int nr = page_end - page_start;
 
@@ -1281,10 +1263,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk, int page_start,
 	chunk->nr_populated += nr;
 	pcpu_nr_populated += nr;
 
-	if (!for_alloc) {
-		chunk->nr_empty_pop_pages += nr;
-		pcpu_nr_empty_pop_pages += nr;
-	}
+	pcpu_update_empty_pages(chunk, nr);
 }
 
 /**
@@ -1306,9 +1285,9 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
 
 	bitmap_clear(chunk->populated, page_start, nr);
 	chunk->nr_populated -= nr;
-	chunk->nr_empty_pop_pages -= nr;
-	pcpu_nr_empty_pop_pages -= nr;
 	pcpu_nr_populated -= nr;
+
+	pcpu_update_empty_pages(chunk, -1 * nr);
 }
 
 /*
@@ -1523,7 +1502,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 				err = "failed to populate";
 				goto fail_unlock;
 			}
-			pcpu_chunk_populated(chunk, rs, re, true);
+			pcpu_chunk_populated(chunk, rs, re);
 			spin_unlock_irqrestore(&pcpu_lock, flags);
 		}
 
@@ -1722,7 +1701,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			if (!ret) {
 				nr_to_pop -= nr;
 				spin_lock_irq(&pcpu_lock);
-				pcpu_chunk_populated(chunk, rs, rs + nr, false);
+				pcpu_chunk_populated(chunk, rs, rs + nr);
 				spin_unlock_irq(&pcpu_lock);
 			} else {
 				nr_to_pop = 0;
-- 
2.17.1

