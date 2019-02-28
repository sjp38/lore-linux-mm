Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0615C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A91D52083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A91D52083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B6F28E000B; Wed, 27 Feb 2019 21:18:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26A4C8E0001; Wed, 27 Feb 2019 21:18:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 157D28E000B; Wed, 27 Feb 2019 21:18:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDE1A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:55 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b40so17404551qte.1
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OJpWsbdBIyGG6Z7ONuMnLcPyaANJkTqPOgPDMD+CsEE=;
        b=QiIGyvRwjpD4a7WQaaMg9ASMs704FYXRhoDgcFd2rrmrQOBVWVZxusv7PF9rHq1IJC
         hTBW3u+lsDq7UCX8ne95E+fjB3UJWU/ieTjz9hrUw/1FaygU/U3E2tBupik5IT6+d+iY
         kTJNd4CLH5T+qMShh+YwYwoHSPTnF7xSIP7CbENXoHtd4Gf7uw95jnFqDNsTimPkXLI4
         V9nBTZHKCglRnwEGKUZKI40GO25cqGmcX2aEBHYMYxt9aXR5dDy1pg8cSwstNV+UJFMl
         r/H99VZiDTEGdO1zPgui+KDrfuH6bM2aKWY8uLGw7MnRtE0fFWmFdVBElseESMQQdcJQ
         NALw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubmTwfDcFqmtuPVQoTIT73WxxzlwfUxZHgF+Ri3aYcdff8pbNgJ
	UnOpTrgkJOd7Q3ocaNwJQm/qkVyB7zodEMnAxlL3HhKG/JmIPYH9vC/Dt7YXOoAFeCJeqwfoozi
	Mx0tCtX0FjqnhITTJQESUcHQbgOJlGZK59RhEcK0sE0am4j0l4Yflt+IoyiW6IjMfX3ZGFDAtL8
	0XkJwrSRqwqUCPzY8MTgmq4XHORgwisfIWWEcILP4bwmomrMH99F0xPAEX1NbJz/eVQi9qaSfmm
	JbhKgU1mhMxQH8dd3opOxr6mMcguhoNaxzYNnieoaUwgSG88Jl6mymboR8XXj2pN/20xQ3FIWXq
	zxgJIK6CWkplrGPvQsdhXTIqdD2bpwqDAfv6K3uQB87OxvdQxAkDJxVG3eQUjEwV9YoaQHWwog=
	=
X-Received: by 2002:ac8:803:: with SMTP id u3mr4323354qth.108.1551320335653;
        Wed, 27 Feb 2019 18:18:55 -0800 (PST)
X-Received: by 2002:ac8:803:: with SMTP id u3mr4323322qth.108.1551320334697;
        Wed, 27 Feb 2019 18:18:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320334; cv=none;
        d=google.com; s=arc-20160816;
        b=fv0V1K14Tpqvs8flq5CLMtRSIzVQVjCo0YyG5Z+3DBmblBJzHifU86p5+WatrbI+j8
         NsKfpVMlpc2z4LbVKtRDzMEaw2fWPVuPFYNM973lYiEdz4wyZwRZGx6qdw5kbQBqj/nC
         8DDyehytyLa5LT7P9jquDIlMP1NbsXSaSssCGFSVpKXtZ+kce2YyxvVpIR7y8AuuReIG
         GLMHPvBtoatyiczN73l5E9H1sMCT3OKOs3wEhbsIHfm1yGLaEuOvnwQ7TdX5TDNeE1lW
         j4yjcrFtHWhEfjYeiNNq+1NWlGjU6WSVEfBQrwG0RmI0bvtMEgPiGs5d1TQWDedRe1Lo
         iIEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OJpWsbdBIyGG6Z7ONuMnLcPyaANJkTqPOgPDMD+CsEE=;
        b=fuYO+5NyahreVpTDsays2xa9LQYSbbQmVBxEoEYVLp8MOtbevHrxJjSPydLdRqmh2p
         pg/BkiuOqQwh+kMl1wt3S0/wMxElyCNJxT/odlsFSPRIbInuk30vsJzLo8fq8B+MPzLs
         820KPFZT8hZ3Dv9bG1e7JomrbpT19fmTcscaNZKRvKte84drhK7Mw5GRFAul90G1k1km
         kqxDTtq20gOh0qKpuWCx5HBg5PkYfD++2kDh7vZmDdXMCDwylpEQpAstk/Rsk0lCWCDd
         lTWqsJTDLU1RERum1I/JdOMHXBVl5IcIZGO8H4UN7v1LKDAeGviNmigD5INLdKDTtjy2
         gAbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 39sor20029930qvk.54.2019.02.27.18.18.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:54 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxEf9YG/zZ2e72+bT/axnwcoZq+Gcmlr3nYUbo4CauEC6c/+4TlIkIgc9rbYfwL02WxjTt1hg==
X-Received: by 2002:a0c:d0b6:: with SMTP id z51mr4431252qvg.20.1551320334375;
        Wed, 27 Feb 2019 18:18:54 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:53 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/12] percpu: add block level scan_hint
Date: Wed, 27 Feb 2019 21:18:34 -0500
Message-Id: <20190228021839.55779-8-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fragmentation can cause both blocks and chunks to have an early
first_firee bit available, but only able to satisfy allocations much
later on. This patch introduces a scan_hint to help mitigate some
unnecessary scanning.

The scan_hint remembers the largest area prior to the contig_hint. If
the contig_hint == scan_hint, then scan_hint_start > contig_hint_start.
This is necessary for scan_hint discovery when refreshing a block.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu-internal.h |   9 ++++
 mm/percpu.c          | 101 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 103 insertions(+), 7 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index b1739dc06b73..ec58b244545d 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -9,8 +9,17 @@
  * pcpu_block_md is the metadata block struct.
  * Each chunk's bitmap is split into a number of full blocks.
  * All units are in terms of bits.
+ *
+ * The scan hint is the largest known contiguous area before the contig hint.
+ * It is not necessarily the actual largest contig hint though.  There is an
+ * invariant that the scan_hint_start > contig_hint_start iff
+ * scan_hint == contig_hint.  This is necessary because when scanning forward,
+ * we don't know if a new contig hint would be better than the current one.
  */
 struct pcpu_block_md {
+	int			scan_hint;	/* scan hint for block */
+	int			scan_hint_start; /* block relative starting
+						    position of the scan hint */
 	int                     contig_hint;    /* contig hint for block */
 	int                     contig_hint_start; /* block relative starting
 						      position of the contig hint */
diff --git a/mm/percpu.c b/mm/percpu.c
index 967c9cc3a928..df1aacf58ac8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -320,6 +320,34 @@ static unsigned long pcpu_block_off_to_off(int index, int off)
 	return index * PCPU_BITMAP_BLOCK_BITS + off;
 }
 
+/*
+ * pcpu_next_hint - determine which hint to use
+ * @block: block of interest
+ * @alloc_bits: size of allocation
+ *
+ * This determines if we should scan based on the scan_hint or first_free.
+ * In general, we want to scan from first_free to fulfill allocations by
+ * first fit.  However, if we know a scan_hint at position scan_hint_start
+ * cannot fulfill an allocation, we can begin scanning from there knowing
+ * the contig_hint will be our fallback.
+ */
+static int pcpu_next_hint(struct pcpu_block_md *block, int alloc_bits)
+{
+	/*
+	 * The three conditions below determine if we can skip past the
+	 * scan_hint.  First, does the scan hint exist.  Second, is the
+	 * contig_hint after the scan_hint (possibly not true iff
+	 * contig_hint == scan_hint).  Third, is the allocation request
+	 * larger than the scan_hint.
+	 */
+	if (block->scan_hint &&
+	    block->contig_hint_start > block->scan_hint_start &&
+	    alloc_bits > block->scan_hint)
+		return block->scan_hint_start + block->scan_hint;
+
+	return block->first_free;
+}
+
 /**
  * pcpu_next_md_free_region - finds the next hint free area
  * @chunk: chunk of interest
@@ -415,9 +443,11 @@ static void pcpu_next_fit_region(struct pcpu_chunk *chunk, int alloc_bits,
 		if (block->contig_hint &&
 		    block->contig_hint_start >= block_off &&
 		    block->contig_hint >= *bits + alloc_bits) {
+			int start = pcpu_next_hint(block, alloc_bits);
+
 			*bits += alloc_bits + block->contig_hint_start -
-				 block->first_free;
-			*bit_off = pcpu_block_off_to_off(i, block->first_free);
+				 start;
+			*bit_off = pcpu_block_off_to_off(i, start);
 			return;
 		}
 		/* reset to satisfy the second predicate above */
@@ -632,12 +662,57 @@ static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
 		block->right_free = contig;
 
 	if (contig > block->contig_hint) {
+		/* promote the old contig_hint to be the new scan_hint */
+		if (start > block->contig_hint_start) {
+			if (block->contig_hint > block->scan_hint) {
+				block->scan_hint_start =
+					block->contig_hint_start;
+				block->scan_hint = block->contig_hint;
+			} else if (start < block->scan_hint_start) {
+				/*
+				 * The old contig_hint == scan_hint.  But, the
+				 * new contig is larger so hold the invariant
+				 * scan_hint_start < contig_hint_start.
+				 */
+				block->scan_hint = 0;
+			}
+		} else {
+			block->scan_hint = 0;
+		}
 		block->contig_hint_start = start;
 		block->contig_hint = contig;
-	} else if (block->contig_hint_start && contig == block->contig_hint &&
-		   (!start || __ffs(start) > __ffs(block->contig_hint_start))) {
-		/* use the start with the best alignment */
-		block->contig_hint_start = start;
+	} else if (contig == block->contig_hint) {
+		if (block->contig_hint_start &&
+		    (!start ||
+		     __ffs(start) > __ffs(block->contig_hint_start))) {
+			/* start has a better alignment so use it */
+			block->contig_hint_start = start;
+			if (start < block->scan_hint_start &&
+			    block->contig_hint > block->scan_hint)
+				block->scan_hint = 0;
+		} else if (start > block->scan_hint_start ||
+			   block->contig_hint > block->scan_hint) {
+			/*
+			 * Knowing contig == contig_hint, update the scan_hint
+			 * if it is farther than or larger than the current
+			 * scan_hint.
+			 */
+			block->scan_hint_start = start;
+			block->scan_hint = contig;
+		}
+	} else {
+		/*
+		 * The region is smaller than the contig_hint.  So only update
+		 * the scan_hint if it is larger than or equal and farther than
+		 * the current scan_hint.
+		 */
+		if ((start < block->contig_hint_start &&
+		     (contig > block->scan_hint ||
+		      (contig == block->scan_hint &&
+		       start > block->scan_hint_start)))) {
+			block->scan_hint_start = start;
+			block->scan_hint = contig;
+		}
 	}
 }
 
@@ -656,7 +731,7 @@ static void pcpu_block_refresh_hint(struct pcpu_chunk *chunk, int index)
 	int rs, re;	/* region start, region end */
 
 	/* clear hints */
-	block->contig_hint = 0;
+	block->contig_hint = block->scan_hint = 0;
 	block->left_free = block->right_free = 0;
 
 	/* iterate over free areas and update the contig hints */
@@ -713,6 +788,12 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 					PCPU_BITMAP_BLOCK_BITS,
 					s_off + bits);
 
+	if (pcpu_region_overlap(s_block->scan_hint_start,
+				s_block->scan_hint_start + s_block->scan_hint,
+				s_off,
+				s_off + bits))
+		s_block->scan_hint = 0;
+
 	if (pcpu_region_overlap(s_block->contig_hint_start,
 				s_block->contig_hint_start +
 				s_block->contig_hint,
@@ -749,6 +830,9 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 			/* reset the block */
 			e_block++;
 		} else {
+			if (e_off > e_block->scan_hint_start)
+				e_block->scan_hint = 0;
+
 			if (e_off > e_block->contig_hint_start) {
 				/* contig hint is broken - scan to fix it */
 				pcpu_block_refresh_hint(chunk, e_index);
@@ -763,6 +847,7 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 		/* update in-between md_blocks */
 		nr_empty_pages += (e_index - s_index - 1);
 		for (block = s_block + 1; block < e_block; block++) {
+			block->scan_hint = 0;
 			block->contig_hint = 0;
 			block->left_free = 0;
 			block->right_free = 0;
@@ -873,6 +958,7 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 		nr_empty_pages += (e_index - s_index - 1);
 		for (block = s_block + 1; block < e_block; block++) {
 			block->first_free = 0;
+			block->scan_hint = 0;
 			block->contig_hint_start = 0;
 			block->contig_hint = PCPU_BITMAP_BLOCK_BITS;
 			block->left_free = PCPU_BITMAP_BLOCK_BITS;
@@ -1084,6 +1170,7 @@ static void pcpu_init_md_blocks(struct pcpu_chunk *chunk)
 	for (md_block = chunk->md_blocks;
 	     md_block != chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
 	     md_block++) {
+		md_block->scan_hint = 0;
 		md_block->contig_hint = PCPU_BITMAP_BLOCK_BITS;
 		md_block->left_free = PCPU_BITMAP_BLOCK_BITS;
 		md_block->right_free = PCPU_BITMAP_BLOCK_BITS;
-- 
2.17.1

