Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C927FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909F22083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909F22083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612858E000F; Wed, 27 Feb 2019 21:19:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59B968E0001; Wed, 27 Feb 2019 21:19:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4638A8E000F; Wed, 27 Feb 2019 21:19:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C46D8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:19:03 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id s8so17060142qth.18
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:19:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=qImDKhW66AzCuoNyqvyprY/jSnw+rPbm4Fv7bWHuvuA=;
        b=A7LQh0rBRT0k1bCKZ0DRXwkyzUJ8sh2q/BnXnbNLZqiXIDauuUUcr+NwIubY763kKV
         pYi0fSyw6HVZELgk2uYLG67o0GyXfkJKfRMAm4ne9s1p3P3fVEug3EKekDcxlBJnOCjc
         wCiR8REH8A537TC/MW8CSzphADqD6to6pF0EWcZFW08u23rX9lRyAsBis/JUlp9nI5AV
         Eb4wKZjtz3LcIt7aoZlzlPJCB8BSOfwg2LTPqpkLutmg9rxgO1BKpT6wsd27NGRdXJT3
         iPjBGhwGVZ8kwwFgqCCDuJ7f+vK7fcse7zXl6XXKWXzMFR9JJoVZ5PdMFnjBLHIlBxoI
         Jryw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubKwTbIm+dUeYA6XeFRoVc10/Np10Z/o8L3Je38kzmG91tYZ4bZ
	8Ehi2X7jXE3Y01FAHmH6yMI3AKU6W83hTTyIm2ZuyPVUdsTgQlDBnS5SbTHEJM/SYmHieEVJql/
	H8vaewbsoxky9Xt8QdhOwUcZY6dpUCeGOp/4FTUvHNM98ca4HBP7fK8LR/dmA+XlRn47bcrpRv9
	AMg4Z50+EfZcyML38tOPNDq3uZ2hirQHt8KvjJNlAGVYrNO3OkVHaMbXUwJvLLUlCL718IKpNNx
	YRJYzAFbZgcvVWuxxGI8SVKUiuTJ/iV3IZGMD2Ycqk4Tkqi8Ot1zVF7H6H5Nl0u1AMc8fCIhX2q
	+B5xwrRl4AZHsVlLnSqBZNpk1xs30+MtOOp9d4E1SHkanVWLi0UARbdGlGwzczu8kOv8uwfYJg=
	=
X-Received: by 2002:ac8:2286:: with SMTP id f6mr4429338qta.68.1551320342886;
        Wed, 27 Feb 2019 18:19:02 -0800 (PST)
X-Received: by 2002:ac8:2286:: with SMTP id f6mr4429314qta.68.1551320342147;
        Wed, 27 Feb 2019 18:19:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320342; cv=none;
        d=google.com; s=arc-20160816;
        b=o9VQ4qr57DyfmqWjEnAQmhusvvvqPqwghnN0wRF+2CSzbk84j6l3QK1G542+ALw5wN
         6w6+qyT1YzdqKtg9JuJWtd/kvfxnQI4kAsPmzCbTRJQL9wox07dRQiUXwAwj4tVIYepo
         t1Dvn9lent5Vni2whtYnrqZ24BIeswKQmnmD6K2E/qH3StNq6kBiBvCUpB/nwir6GPyr
         p4IM80GgKF/cx5LPZIK9h5SOf+rAFmxUj5nAKZhiHoiQBGlI10UIHs4h9BzkWKVgAi/p
         /1n+iv47xJ8Zx+U+M+17dbm5ZvxM4GoUzgApde0HJ7NBWheSHiIzMKfPPjZDZ9n6AieQ
         oqbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=qImDKhW66AzCuoNyqvyprY/jSnw+rPbm4Fv7bWHuvuA=;
        b=cZPbgi31q4JgNWj0f2CwezPnFrxDwQIYwhfx2iqp/5volDQTUUAxXqRelltB1JXCnb
         cxh3VjL2l76m6SgLPSSIlrEJDGan0sg+U0pnM5NFpzFdXnSVxyb5MGkLrihBAXqj/4ps
         DTi0dbQdDRg2zC0uevQUYGBoSnXPDMjyRO2DvwmRU4xpxBAh3O2wPxSsmXPOqMnct1WE
         T8Jz9q8cvdXCCWoQ1/lhU80GaYclzD04/GB5P4TgWQTFK7fqn1CsAsw5RH8ZAdNraOfa
         ZN+FOCtJWndXmZ8Vpa+Quj7hcrp3Q5GRja/9fVcj5Oe5/pBfakkSAWMM4ZLiJKS9uQU8
         2t+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i69sor10945361qke.5.2019.02.27.18.19.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:19:02 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IYgGWL916vz2qCJL6FgtJg1g1UrnDtKTf9mK0j3zPUUdDEHBIlwVWx5ZLs8juhi27ZLZhRLpg==
X-Received: by 2002:a37:4e97:: with SMTP id c145mr4659307qkb.85.1551320341809;
        Wed, 27 Feb 2019 18:19:01 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.19.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:19:00 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 12/12] percpu: use chunk scan_hint to skip some scanning
Date: Wed, 27 Feb 2019 21:18:39 -0500
Message-Id: <20190228021839.55779-13-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just like blocks, chunks now maintain a scan_hint. This can be used to
skip some scanning by promoting the scan_hint to be the contig_hint.
The chunk's scan_hint is primarily updated on the backside and relies on
full scanning when a block becomes free or the free region spans across
blocks.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 197479f2c489..40d49d7fb286 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -711,20 +711,31 @@ static void pcpu_block_update_scan(struct pcpu_chunk *chunk, int bit_off,
 /**
  * pcpu_chunk_refresh_hint - updates metadata about a chunk
  * @chunk: chunk of interest
+ * @full_scan: if we should scan from the beginning
  *
  * Iterates over the metadata blocks to find the largest contig area.
- * It also counts the populated pages and uses the delta to update the
- * global count.
+ * A full scan can be avoided on the allocation path as this is triggered
+ * if we broke the contig_hint.  In doing so, the scan_hint will be before
+ * the contig_hint or after if the scan_hint == contig_hint.  This cannot
+ * be prevented on freeing as we want to find the largest area possibly
+ * spanning blocks.
  */
-static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
+static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk, bool full_scan)
 {
 	struct pcpu_block_md *chunk_md = &chunk->chunk_md;
 	int bit_off, bits;
 
-	/* clear metadata */
-	chunk_md->contig_hint = 0;
+	/* promote scan_hint to contig_hint */
+	if (!full_scan && chunk_md->scan_hint) {
+		bit_off = chunk_md->scan_hint_start + chunk_md->scan_hint;
+		chunk_md->contig_hint_start = chunk_md->scan_hint_start;
+		chunk_md->contig_hint = chunk_md->scan_hint;
+		chunk_md->scan_hint = 0;
+	} else {
+		bit_off = chunk_md->first_free;
+		chunk_md->contig_hint = 0;
+	}
 
-	bit_off = chunk_md->first_free;
 	bits = 0;
 	pcpu_for_each_md_free_region(chunk, bit_off, bits) {
 		pcpu_block_update(chunk_md, bit_off, bit_off + bits);
@@ -884,6 +895,13 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 	if (nr_empty_pages)
 		pcpu_update_empty_pages(chunk, -1 * nr_empty_pages);
 
+	if (pcpu_region_overlap(chunk_md->scan_hint_start,
+				chunk_md->scan_hint_start +
+				chunk_md->scan_hint,
+				bit_off,
+				bit_off + bits))
+		chunk_md->scan_hint = 0;
+
 	/*
 	 * The only time a full chunk scan is required is if the chunk
 	 * contig hint is broken.  Otherwise, it means a smaller space
@@ -894,7 +912,7 @@ static void pcpu_block_update_hint_alloc(struct pcpu_chunk *chunk, int bit_off,
 				chunk_md->contig_hint,
 				bit_off,
 				bit_off + bits))
-		pcpu_chunk_refresh_hint(chunk);
+		pcpu_chunk_refresh_hint(chunk, false);
 }
 
 /**
@@ -1005,7 +1023,7 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 	 * the else condition below.
 	 */
 	if (((end - start) >= PCPU_BITMAP_BLOCK_BITS) || s_index != e_index)
-		pcpu_chunk_refresh_hint(chunk);
+		pcpu_chunk_refresh_hint(chunk, true);
 	else
 		pcpu_block_update(&chunk->chunk_md,
 				  pcpu_block_off_to_off(s_index, start),
@@ -1078,7 +1096,7 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	if (bit_off + alloc_bits > chunk_md->contig_hint)
 		return -1;
 
-	bit_off = chunk_md->first_free;
+	bit_off = pcpu_next_hint(chunk_md, alloc_bits);
 	bits = 0;
 	pcpu_for_each_fit_region(chunk, alloc_bits, align, bit_off, bits) {
 		if (!pop_only || pcpu_is_populated(chunk, bit_off, bits,
-- 
2.17.1

