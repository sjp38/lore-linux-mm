Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A947BC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EA83218A2
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EA83218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EEC58E000E; Wed, 27 Feb 2019 21:19:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C5A18E0001; Wed, 27 Feb 2019 21:19:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28DAA8E000E; Wed, 27 Feb 2019 21:19:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2FA28E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:19:01 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id c9so17119422qte.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:19:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=g2ENlk1zX6grjv7br7W/r2m1obArXEgzzB0drAyc/OA=;
        b=T9rhIkZ5Le5VNN+3TY1nKvRq33MI2UJ2Zp4rajJq+AxxFuVoGolNRf59yj5YyJ4U50
         8KLl+75ooonRUEG5Lq8/BOx234/blQ3ArJnJSSIVYoSGbphDZEwQvgvoK0y2A3br6M22
         c43EWKRpml0yTOt7sivYApyMosiprw2fGFjQsELlr+k2mLbZN0ynYaw/WMf/+5P7lf2P
         F+5z1E8iObpPEGQvzDoVivudBXdSs02G0XKiFA05gPIC1UrO43YA9yzd3bXQpftXqsZy
         N++2tYbsHpsef1r1LwNpeO22xPLEM7J1kNlBqR5VbujNMv7YtHArpVkqHiZejrGg2ToK
         3vrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaaQzMZo+ugiIZmnZIVen7fERCksOtR1b+jEvqc91xCRIJyHoGi
	+MK6OU+WC7JhWk/Trdfb6iYQC8n4UYM/aJpCGzUxfN5GlaRqTu4wLDQUjQWNs1/xEHjkNEmU9Me
	IFw/Cw0Xtl1i4UoiS8UMQYjocmfyeiI+gi+Cai8WrBEaJaXjUFgKiXiicaE6jT9dq04P8pwPR65
	Sev0y/gmOybmXMSNmqGiXjWku7bcjYbd4RlH+JsOZnncKkCqCD62gGohVLlzExBb91LZaOzBffz
	mU2hH8b0BB/0fzgGpuKnHwVFlngWAqOnusQ4Mz5DjLRpv22vTcwpjCKrHo9/Ug1Xl6e9OVEjrkC
	Q3v8xdH/3XwRrGRBblUClMBw/BtwkwGC4C68S0ixdIN30K7ShlmTX7I8FaUgAEg8LaeDHsF6yw=
	=
X-Received: by 2002:ac8:2c92:: with SMTP id 18mr4250022qtw.269.1551320341722;
        Wed, 27 Feb 2019 18:19:01 -0800 (PST)
X-Received: by 2002:ac8:2c92:: with SMTP id 18mr4249980qtw.269.1551320340708;
        Wed, 27 Feb 2019 18:19:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320340; cv=none;
        d=google.com; s=arc-20160816;
        b=DY13jEiBTRoRyhLeVNSGRsWj97Dlmu5PP8BSXKL8rUrwCPyM4Ra7JHDY+X+brYmWeD
         XoHieCtuyUzsCN4PQQnP0I6oEat+nQM9EkdGwh8ubN/kXIwUN4pXFDjyw/qIlBjzPJNF
         UzkqPc2tOocyeS2JxsuLiM8ka0Ie8WSQxcTiCpP871km6A+EJV7kEhYrfyx841ysBxOz
         rptmNlmP8vB1mCJMlERo1YZaR1vIvnmUirBYE2r5pnZhYQQjkyAobY+EYsdtw6KELUqB
         lEnJ2bEgr2qCbsPvo+3WO6MESfmtMD3h4YWnBuJm8jwEc/95A4hrL5PY0/7NCdaH4HM1
         jrmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=g2ENlk1zX6grjv7br7W/r2m1obArXEgzzB0drAyc/OA=;
        b=dmGPEznTskJQbTfMU/DMwH/rnS0jEB3pFGQvEQAICe9sy+irDYv4izUzT26tImKzjA
         IC7GyzE6R9TPCM5nyZPWJYF6FbsAfrJc+L/UvUCK05AnNCqVBoA+Si99iMDZcJABdUo2
         chNeCa1sr91wyyQwpgpuFpVSut9yNAYMEsKLxYdOZb5kwaPLKn5mLvw9GW5P8b0jCPjS
         MYyu52svCBqZrTOXULXrmJNLGuchgmq/Ut++e5r7FKcIRC503+Ci28B1oyNc5XfdjCxr
         5jrsowWgN3cokdpweV8ui/KYh9MLBohReab7XT14GZWobUOSUpmtyNPdoHL3zA7lFVZP
         4geQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n52sor21890925qtk.39.2019.02.27.18.19.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:19:00 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbHe/rxuVJiXM41Enka/t5RwmbfAtxTtVZrOy0xH8T/DXgOeiB+iYMvA8kh0Qu3zNT+r1GO5A==
X-Received: by 2002:ac8:1a56:: with SMTP id q22mr4290404qtk.59.1551320340377;
        Wed, 27 Feb 2019 18:19:00 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:59 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/12] percpu: convert chunk hints to be based on pcpu_block_md
Date: Wed, 27 Feb 2019 21:18:38 -0500
Message-Id: <20190228021839.55779-12-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As mentioned in the last patch, a chunk's hints are no different than a
block just responsible for more bits. This converts chunk level hints to
use a pcpu_block_md to maintain them. This lets us reuse the same hint
helper functions as a block. The left_free and right_free are unused by
the chunk's pcpu_block_md.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu-internal.h |   5 +-
 mm/percpu-stats.c    |   5 +-
 mm/percpu.c          | 120 +++++++++++++++++++------------------------
 3 files changed, 57 insertions(+), 73 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 119bd1119aa7..0468ba500bd4 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -39,9 +39,7 @@ struct pcpu_chunk {
 
 	struct list_head	list;		/* linked to pcpu_slot lists */
 	int			free_bytes;	/* free bytes in the chunk */
-	int			contig_bits;	/* max contiguous size hint */
-	int			contig_bits_start; /* contig_bits starting
-						      offset */
+	struct pcpu_block_md	chunk_md;
 	void			*base_addr;	/* base address of this chunk */
 
 	unsigned long		*alloc_map;	/* allocation map */
@@ -49,7 +47,6 @@ struct pcpu_chunk {
 	struct pcpu_block_md	*md_blocks;	/* metadata blocks */
 
 	void			*data;		/* chunk data */
-	int			first_bit;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
 	int			start_offset;	/* the overlap with the previous
 						   region to have a page aligned
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index b5fdd43b60c9..ef5034a0464e 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -53,6 +53,7 @@ static int find_max_nr_alloc(void)
 static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 			    int *buffer)
 {
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	int i, last_alloc, as_len, start, end;
 	int *alloc_sizes, *p;
 	/* statistics */
@@ -121,9 +122,9 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
 	P("empty_pop_pages", chunk->nr_empty_pop_pages);
-	P("first_bit", chunk->first_bit);
+	P("first_bit", chunk_md->first_free);
 	P("free_bytes", chunk->free_bytes);
-	P("contig_bytes", chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
+	P("contig_bytes", chunk_md->contig_hint * PCPU_MIN_ALLOC_SIZE);
 	P("sum_frag", sum_frag);
 	P("max_frag", max_frag);
 	P("cur_min_alloc", cur_min_alloc);
diff --git a/mm/percpu.c b/mm/percpu.c
index 7cdf14c242de..197479f2c489 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -233,10 +233,13 @@ static int pcpu_size_to_slot(int size)
 
 static int pcpu_chunk_slot(const struct pcpu_chunk *chunk)
 {
-	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE || chunk->contig_bits == 0)
+	const struct pcpu_block_md *chunk_md = &chunk->chunk_md;
+
+	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE ||
+	    chunk_md->contig_hint == 0)
 		return 0;
 
-	return pcpu_size_to_slot(chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
+	return pcpu_size_to_slot(chunk_md->contig_hint * PCPU_MIN_ALLOC_SIZE);
 }
 
 /* set the pointer to a chunk in a page struct */
@@ -592,54 +595,6 @@ static inline bool pcpu_region_overlap(int a, int b, int x, int y)
 	return false;
 }
 
-/**
- * pcpu_chunk_update - updates the chunk metadata given a free area
- * @chunk: chunk of interest
- * @bit_off: chunk offset
- * @bits: size of free area
- *
- * This updates the chunk's contig hint and starting offset given a free area.
- * Choose the best starting offset if the contig hint is equal.
- */
-static void pcpu_chunk_update(struct pcpu_chunk *chunk, int bit_off, int bits)
-{
-	if (bits > chunk->contig_bits) {
-		chunk->contig_bits_start = bit_off;
-		chunk->contig_bits = bits;
-	} else if (bits == chunk->contig_bits && chunk->contig_bits_start &&
-		   (!bit_off ||
-		    __ffs(bit_off) > __ffs(chunk->contig_bits_start))) {
-		/* use the start with the best alignment */
-		chunk->contig_bits_start = bit_off;
-	}
-}
-
-/**
- * pcpu_chunk_refresh_hint - updates metadata about a chunk
- * @chunk: chunk of interest
- *
- * Iterates over the metadata blocks to find the largest contig area.
- * It also counts the populated pages and uses the delta to update the
- * global count.
- *
- * Updates:
- *      chunk->contig_bits
- *      chunk->contig_bits_start
- */
-static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
-{
-	int bit_off, bits;
-
-	/* clear metadata */
-	chunk->contig_bits = 0;
-
-	bit_off = chunk->first_bit;
-	bits = 0;
-	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
-		pcpu_chunk_update(chunk, bit_off, bits);
-	}
-}
-
 /**
  * pcpu_block_update - updates a block given a free area
  * @block: block of interest
@@ -753,6 +708,29 @@ static void pcpu_block_update_scan(struct pcpu_chunk *chunk, int bit_off,
 	pcpu_block_update(block, s_off, e_off);
 }
 
+/**
+ * pcpu_chunk_refresh_hint - updates metadata about a chunk
+ * @chunk: chunk of interest
+ *
+ * Iterates over the metadata blocks to find the largest contig area.
+ * It also counts the populated pages and uses the delta to update the
+ * global count.
+ */
+static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
+{
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
+	int bit_off, bits;
+
+	/* clear metadata */
+	chunk_md->contig_hint = 0;
+
+	bit_off = chunk_md->first_free;
+	bits = 0;
+	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
+		pcpu_block_update(chunk_md, bit_off, bit_off + bits);
+	}
+}
+
 /**
  * pcpu_block_refresh_hint
  * @chunk: chunk of interest
@@ -800,6 +778,7 @@ static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
 static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 					 int bits)
 {
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	int nr_empty_pages = 0;
 	struct pcpu_block_md *s_block, *e_block, *block;
 	int s_index, e_index;	/* block indexes of the freed allocation */
@@ -910,8 +889,9 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 	 * contig hint is broken.  Otherwise, it means a smaller space
 	 * was used and therefore the chunk contig hint is still correct.
 	 */
-	if (pcpu_region_overlap(chunk->contig_bits_start,
-				chunk->contig_bits_start + chunk->contig_bits,
+	if (pcpu_region_overlap(chunk_md->contig_hint_start,
+				chunk_md->contig_hint_start +
+				chunk_md->contig_hint,
 				bit_off,
 				bit_off + bits))
 		pcpu_chunk_refresh_hint(chunk);
@@ -930,9 +910,10 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
  *
  * A chunk update is triggered if a page becomes free, a block becomes free,
  * or the free spans across blocks.  This tradeoff is to minimize iterating
- * over the block metadata to update chunk->contig_bits.  chunk->contig_bits
- * may be off by up to a page, but it will never be more than the available
- * space.  If the contig hint is contained in one block, it will be accurate.
+ * over the block metadata to update chunk_md->contig_hint.
+ * chunk_md->contig_hint may be off by up to a page, but it will never be more
+ * than the available space.  If the contig hint is contained in one block, it
+ * will be accurate.
  */
 static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 					int bits)
@@ -1026,8 +1007,9 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 	if (((end - start) >= PCPU_BITMAP_BLOCK_BITS) || s_index != e_index)
 		pcpu_chunk_refresh_hint(chunk);
 	else
-		pcpu_chunk_update(chunk, pcpu_block_off_to_off(s_index, start),
-				  end - start);
+		pcpu_block_update(&chunk->chunk_md,
+				  pcpu_block_off_to_off(s_index, start),
+				  end);
 }
 
 /**
@@ -1082,6 +1064,7 @@ static bool pcpu_is_populated(struct pcpu_chunk *chunk, int bit_off, int bits,
 static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 			       size_t align, bool pop_only)
 {
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	int bit_off, bits, next_off;
 
 	/*
@@ -1090,12 +1073,12 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	 * cannot fit in the global hint, there is memory pressure and creating
 	 * a new chunk would happen soon.
 	 */
-	bit_off = ALIGN(chunk->contig_bits_start, align) -
-		  chunk->contig_bits_start;
-	if (bit_off + alloc_bits > chunk->contig_bits)
+	bit_off = ALIGN(chunk_md->contig_hint_start, align) -
+		  chunk_md->contig_hint_start;
+	if (bit_off + alloc_bits > chunk_md->contig_hint)
 		return -1;
 
-	bit_off = chunk->first_bit;
+	bit_off = chunk_md->first_free;
 	bits = 0;
 	pcpu_for_each_fit_region(chunk, alloc_bits, align, bit_off, bits) {
 		if (!pop_only || pcpu_is_populated(chunk, bit_off, bits,
@@ -1190,6 +1173,7 @@ static unsigned long pcpu_find_zero_area(unsigned long *map,
 static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 			   size_t align, int start)
 {
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	size_t align_mask = (align) ? (align - 1) : 0;
 	unsigned long area_off = 0, area_bits = 0;
 	int bit_off, end, oslot;
@@ -1222,8 +1206,8 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 	chunk->free_bytes -= alloc_bits * PCPU_MIN_ALLOC_SIZE;
 
 	/* update first free bit */
-	if (bit_off == chunk->first_bit)
-		chunk->first_bit = find_next_zero_bit(
+	if (bit_off == chunk_md->first_free)
+		chunk_md->first_free = find_next_zero_bit(
 					chunk->alloc_map,
 					pcpu_chunk_map_bits(chunk),
 					bit_off + alloc_bits);
@@ -1245,6 +1229,7 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
  */
 static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 {
+	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	int bit_off, bits, end, oslot;
 
 	lockdep_assert_held(&pcpu_lock);
@@ -1264,7 +1249,7 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 	chunk->free_bytes += bits * PCPU_MIN_ALLOC_SIZE;
 
 	/* update first free bit */
-	chunk->first_bit = min(chunk->first_bit, bit_off);
+	chunk_md->first_free = min(chunk_md->first_free, bit_off);
 
 	pcpu_block_update_hint_free(chunk, bit_off, bits);
 
@@ -1285,6 +1270,9 @@ static void pcpu_init_md_blocks(struct pcpu_chunk *chunk)
 {
 	struct pcpu_block_md *md_block;
 
+	/* init the chunk's block */
+	pcpu_init_md_block(&chunk->chunk_md, pcpu_chunk_map_bits(chunk));
+
 	for (md_block = chunk->md_blocks;
 	     md_block != chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
 	     md_block++)
@@ -1352,7 +1340,6 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_populated = chunk->nr_pages;
 	chunk->nr_empty_pop_pages = chunk->nr_pages;
 
-	chunk->contig_bits = map_size / PCPU_MIN_ALLOC_SIZE;
 	chunk->free_bytes = map_size;
 
 	if (chunk->start_offset) {
@@ -1362,7 +1349,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 		set_bit(0, chunk->bound_map);
 		set_bit(offset_bits, chunk->bound_map);
 
-		chunk->first_bit = offset_bits;
+		chunk->chunk_md.first_free = offset_bits;
 
 		pcpu_block_update_hint_alloc(chunk, 0, offset_bits);
 	}
@@ -1415,7 +1402,6 @@ static struct pcpu_chunk *pcpu_alloc_chunk(gfp_t gfp)
 	pcpu_init_md_blocks(chunk);
 
 	/* init metadata */
-	chunk->contig_bits = region_bits;
 	chunk->free_bytes = chunk->nr_pages * PAGE_SIZE;
 
 	return chunk;
-- 
2.17.1

