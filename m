Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C119BC00319
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76213218E0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76213218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB7C8E0003; Wed, 27 Feb 2019 21:18:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3F5D8E0001; Wed, 27 Feb 2019 21:18:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A34238E0003; Wed, 27 Feb 2019 21:18:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 719AF8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:57 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n197so14918923qke.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=oDNiSsuPdsF/XOcfjzvj8LVYLn1xaHI/O2WR5uD3c+0=;
        b=M8XvkKiozDKde098DTMUNR1fr5dDnebJH+Xv9aiysM0Qvf5f8lQBpdLrZIkIgGp6zL
         dlgdT1xWAkNm11I/uPjpq7TVbs6vOCw4c9c2fNjO7mZ9MC5UzTT8o+SLedUFXSGtqERX
         jVkkGAlJ3Tf5oZrR9umNehKEY9DCw4H5onSzoPNPsqaV+2dLa5ac1dyn91ybTry22C7S
         EsnAWFFgfzOy/a4I9eBASCnA5YXKz7J6DyLnj+VFUrSc8eY2vNo7ys0dxB+JwtTmq9jW
         LnKVsfApArXf/2v2SmDVZVQaWpgYLypnhlfPdHfUlwAN8CYkbULVukq00WYqI3NlAJQF
         yMww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubjvBq1EKXbg4qUrCYJjhzRkduXW+mIW/gNYMfzbI+Gim9CxLRC
	Paud+moh2VasytnmEhhAIOawHr9vfsS3LzdJjx2U57t/iF/ejVBWfmBqXw4eIIVuWIOz6ijSimd
	rNi59VP7fJfNVsVH0T+dGYHpegMLFDY0E6s5PWsgluCnpjbWjl+nwe7yGFWTkOIWedz7WevPwlF
	8C8uFyRAivb2SUQrbU5WYLhx5UO1cRalz+fkhSVTrZGL89/G8feeXNaa17aEH8bvru+RpEbUJxr
	7FvdmHmtifUzmpv7O5Q4jcIZ4fFwUlHs53Dn37Z72Yfr9o61PY6HqmxJZQcQ3QQHj7Cikh9ahCl
	l08UeeKB+Q45YL8uJ4+R4pf03qEZgRb8eqau1/pTP7B6zSpGB0LzmRx2aTcPO5TS08kpZsCD4w=
	=
X-Received: by 2002:a37:b12:: with SMTP id 18mr4644401qkl.125.1551320337148;
        Wed, 27 Feb 2019 18:18:57 -0800 (PST)
X-Received: by 2002:a37:b12:: with SMTP id 18mr4644373qkl.125.1551320336241;
        Wed, 27 Feb 2019 18:18:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320336; cv=none;
        d=google.com; s=arc-20160816;
        b=ltMP9A26zUpDUfurW9U/Ycx+yGkd257QuvnCkImG6fnXX14/sINK9LF67hNIcoi6e3
         Hbol83ujtKxbieQlVpakw2SX81px4+btNeOgrnqAULHhyRC837oAjr2M5SRT1kfXhDcA
         v0Y3rFzoQNOYz6z71DbZ/0NPt86WJ78Pi9bSE+10fpaLYf9TBEG4T7+DeGHR/wcfMo/2
         xdP4PWF88QqapBZT+snRvNRw53VNh6puDDQ0+fP4VjTIBWKLyaz5B64whwaQl7VOC2wp
         3dVUmGEnGAd3POsMsrZHOj3mng7ZJW91hoP/j9p3teUaFGqejk9dol1TDZZ+EPAYdkwi
         /ARg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=oDNiSsuPdsF/XOcfjzvj8LVYLn1xaHI/O2WR5uD3c+0=;
        b=nGKU8iJTRg3tGFjSSQJRdQ1hhr8zi2pWypSlpevdFQNWbqHsCCB2blYTRx7Kzya6np
         ii7rWtItE0Wg+0ssVPiTariQda92QIPFzipi0+TuurlB4+f1nmVl8FW7MEk+sAgMYYF6
         YBPqNcNtOyB1E4V2GFUMArJgOQMk24GSGcmTaE23KEyNXF5wunrEXvD2tb8l6FFLeMK7
         8IER4MTgwdaE1a7Y9ljdya4QlZhh9JFnSdHydbGhedvFQdH00fOLs5CCHKPlh+Wu6Yae
         NEXU3i+SWYGWEGIVO47XrFi4ZxWo3AU9in10ISOLsPl71cyA6jacdI+SV7UbqIOXcGvh
         4yYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23sor10846020qkc.142.2019.02.27.18.18.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:56 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyYBVI/T7ds+Dzo/USUVcDodJI0nlbspO0X1XTek/TSd9ZKWp/VHGFig0uB1cuf3Gy8qdZb3A==
X-Received: by 2002:a37:c097:: with SMTP id v23mr4655782qkv.62.1551320335886;
        Wed, 27 Feb 2019 18:18:55 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:55 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/12] percpu: remember largest area skipped during allocation
Date: Wed, 27 Feb 2019 21:18:35 -0500
Message-Id: <20190228021839.55779-9-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Percpu allocations attempt to do first fit by scanning forward from the
first_free of a block. However, fragmentation from allocation requests
can cause holes not seen by block hint update functions. To address
this, create a local version of bitmap_find_next_zero_area_off() that
remembers the largest area skipped over. The caveat is that it only sees
regions skipped over due to not fitting, not regions skipped due to
alignment. Prior to updating the scan_hint, a scan backwards is done to
try and recover free bits skipped due to alignment. While this can cause
scanning to miss earlier possible free areas, smaller allocations will
eventually fill those holes.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 101 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 99 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index df1aacf58ac8..dac18968d79f 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -716,6 +716,43 @@ static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
 	}
 }
 
+/*
+ * pcpu_block_update_scan - update a block given a free area from a scan
+ * @chunk: chunk of interest
+ * @bit_off: chunk offset
+ * @bits: size of free area
+ *
+ * Finding the final allocation spot first goes through pcpu_find_block_fit()
+ * to find a block that can hold the allocation and then pcpu_alloc_area()
+ * where a scan is used.  When allocations require specific alignments,
+ * we can inadvertently create holes which will not be seen in the alloc
+ * or free paths.
+ *
+ * This takes a given free area hole and updates a block as it may change the
+ * scan_hint.  We need to scan backwards to ensure we don't miss free bits
+ * from alignment.
+ */
+static void pcpu_block_update_scan(struct pcpu_chunk *chunk, int bit_off,
+				   int bits)
+{
+	int s_off = pcpu_off_to_block_off(bit_off);
+	int e_off = s_off + bits;
+	int s_index, l_bit;
+	struct pcpu_block_md *block;
+
+	if (e_off > PCPU_BITMAP_BLOCK_BITS)
+		return;
+
+	s_index = pcpu_off_to_block_index(bit_off);
+	block = chunk->md_blocks + s_index;
+
+	/* scan backwards in case of alignment skipping free bits */
+	l_bit = find_last_bit(pcpu_index_alloc_map(chunk, s_index), s_off);
+	s_off = (s_off == l_bit) ? 0 : l_bit + 1;
+
+	pcpu_block_update(block, s_off, e_off);
+}
+
 /**
  * pcpu_block_refresh_hint
  * @chunk: chunk of interest
@@ -1064,6 +1101,62 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	return bit_off;
 }
 
+/*
+ * pcpu_find_zero_area - modified from bitmap_find_next_zero_area_off
+ * @map: the address to base the search on
+ * @size: the bitmap size in bits
+ * @start: the bitnumber to start searching at
+ * @nr: the number of zeroed bits we're looking for
+ * @align_mask: alignment mask for zero area
+ * @largest_off: offset of the largest area skipped
+ * @largest_bits: size of the largest area skipped
+ *
+ * The @align_mask should be one less than a power of 2.
+ *
+ * This is a modified version of bitmap_find_next_zero_area_off() to remember
+ * the largest area that was skipped.  This is imperfect, but in general is
+ * good enough.  The largest remembered region is the largest failed region
+ * seen.  This does not include anything we possibly skipped due to alignment.
+ * pcpu_block_update_scan() does scan backwards to try and recover what was
+ * lost to alignment.  While this can cause scanning to miss earlier possible
+ * free areas, smaller allocations will eventually fill those holes.
+ */
+static unsigned long pcpu_find_zero_area(unsigned long *map,
+					 unsigned long size,
+					 unsigned long start,
+					 unsigned long nr,
+					 unsigned long align_mask,
+					 unsigned long *largest_off,
+					 unsigned long *largest_bits)
+{
+	unsigned long index, end, i, area_off, area_bits;
+again:
+	index = find_next_zero_bit(map, size, start);
+
+	/* Align allocation */
+	index = __ALIGN_MASK(index, align_mask);
+	area_off = index;
+
+	end = index + nr;
+	if (end > size)
+		return end;
+	i = find_next_bit(map, end, index);
+	if (i < end) {
+		area_bits = i - area_off;
+		/* remember largest unused area with best alignment */
+		if (area_bits > *largest_bits ||
+		    (area_bits == *largest_bits && *largest_off &&
+		     (!area_off || __ffs(area_off) > __ffs(*largest_off)))) {
+			*largest_off = area_off;
+			*largest_bits = area_bits;
+		}
+
+		start = i + 1;
+		goto again;
+	}
+	return index;
+}
+
 /**
  * pcpu_alloc_area - allocates an area from a pcpu_chunk
  * @chunk: chunk of interest
@@ -1087,6 +1180,7 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 			   size_t align, int start)
 {
 	size_t align_mask = (align) ? (align - 1) : 0;
+	unsigned long area_off = 0, area_bits = 0;
 	int bit_off, end, oslot;
 
 	lockdep_assert_held(&pcpu_lock);
@@ -1098,11 +1192,14 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 	 */
 	end = min_t(int, start + alloc_bits + PCPU_BITMAP_BLOCK_BITS,
 		    pcpu_chunk_map_bits(chunk));
-	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
-					     alloc_bits, align_mask);
+	bit_off = pcpu_find_zero_area(chunk->alloc_map, end, start, alloc_bits,
+				      align_mask, &area_off, &area_bits);
 	if (bit_off >= end)
 		return -1;
 
+	if (area_bits)
+		pcpu_block_update_scan(chunk, area_off, area_bits);
+
 	/* update alloc map */
 	bitmap_set(chunk->alloc_map, bit_off, alloc_bits);
 
-- 
2.17.1

