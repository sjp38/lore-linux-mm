Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EA50C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:09:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55B4B213A2
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:09:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55B4B213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D6E8E016D; Sun, 24 Feb 2019 23:09:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDD898E016A; Sun, 24 Feb 2019 23:09:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA67D8E016D; Sun, 24 Feb 2019 23:09:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB1CA8E016A
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:09:17 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k21so1677765qkg.19
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 20:09:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=IW+cUG9+FDp837h14vRqndjO41FEGbfzx4F2fGQ8/Ao=;
        b=a17cvhyWr6Nn+vEYKGuU/D2tckdp+PPFqShLGkeQ8IsXUi1rM3STo/Y+pbpyrMdgYr
         n9BSVFVji8xVNA/IMoC7j/jAiQo9H3MghYjkeN53eEtyPBXvZ2KPypXw1ek4KYmgmkM+
         FoIRjB2g7Qiztk1gJWgOAY1gEtNq566kTLxw1mdfxllU6irle7DEr2GO82XrdA4urM49
         Zu9ewMKh6f6A5TpM/piiGxA1aqh0IItVNyR2f+4Nw8m+82hKSDHaOawIMAtXZvTQnDmj
         IEfHxTfLPafznuVvhZFrQVaQpLeQEDcMd/MOMJ2ErwR+MqyLopqM5/G9OtXy4vIWLgH9
         hXcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua5weNi+JnoAcMs5QBaboNTUoVfB3tTW2GQdXgH0Qb9ZNoCSiRO
	iiQfV1XIDXS/zlfFYVmjBDoWizslnTTV2gYkMHJbEyE4UhgKFntwZKAfJbP8rl5e+Q5zHpYq27E
	ST7N9Y5gjcgNwLPK8Pydx0jMFcX06sS0lAD8t7cMEvdxp/UjXmSDFcfpd+HLQqKd8Dg==
X-Received: by 2002:a0c:be91:: with SMTP id n17mr12230399qvi.32.1551067757448;
        Sun, 24 Feb 2019 20:09:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibh55HbLKd3UWpus2ontibnzeRZ/ku9khXbF6I+5606bgCY/k9jmWNrGJIts2amADXP/P90
X-Received: by 2002:a0c:be91:: with SMTP id n17mr12230371qvi.32.1551067756616;
        Sun, 24 Feb 2019 20:09:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551067756; cv=none;
        d=google.com; s=arc-20160816;
        b=ozt7RHUe712zMhvr8xJc+HykyFKY27LvLPFg50jy5+JoGGFYNPXsjsPEbLx8HY4gv2
         qnk9FadiTmHsqdH7adeXmnrUfzhz6Vl8NwkPCt5B8SNOwQVtPqCFqJqcYxw0ZB7eGZEy
         CEwmX+gzECs2IiqoUsfa8SHCMlq3RUHWf5LYlaCzBAVdaTvcfO66R5ukUPPhPzRAm0uS
         uY2Bav8j4Nfr+jC2U7xnlyZmUrD0c53atbX0vV18fcjCEeA41uOYbp8MqS513eUoW+q1
         hZc6tIcKi7VaWSaH0PrPJn8lzFAqLhBplLpTB6fNcfntg+gomXCfi52VvmfjxArWv5yq
         ZltQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=IW+cUG9+FDp837h14vRqndjO41FEGbfzx4F2fGQ8/Ao=;
        b=uc/MwlwAnvLrHE2VJbMqn7LCsXWX5Q4rRgx8mPH62lX2WG8F0hANi64K6mtBMx96Vb
         9NhSlWqh6pb6AuHnWEq5BlNDt4KKux9D3xG+nqt7Hj9EemseuoHtI3aGze03+U8AxBFw
         1rAXHPASntnIalks1La1A3bSrPWovHOTYG1rUV5YmsqUI8iRX4h+Jy08yp/AR9FuhWue
         bkmZW/A9NYKqgT2f9lFoHzkwSLCRYDUQOXaKLcqbkidbxQnRUeTfNZcb2VqsyReyvTbR
         jLCySbZWUTrgPPU1piSIvEGQmO43166eVxtQuIv37W3caQZGZJysI20gLRaGWyFvfypy
         b3XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l32si3014340qve.83.2019.02.24.20.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 20:09:16 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8540F3680A;
	Mon, 25 Feb 2019 04:09:15 +0000 (UTC)
Received: from localhost (ovpn-8-18.pek2.redhat.com [10.72.8.18])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B0FDD19C7B;
	Mon, 25 Feb 2019 04:09:11 +0000 (UTC)
From: Ming Lei <ming.lei@redhat.com>
To: "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org,
	Ming Lei <ming.lei@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>,
	Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>,
	Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Date: Mon, 25 Feb 2019 12:09:04 +0800
Message-Id: <20190225040904.5557-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 25 Feb 2019 04:09:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

XFS uses kmalloc() to allocate sector sized IO buffer.

Turns out buffer allocated via kmalloc(sector sized) can't
be guaranteed to be 512 byte aligned, and actually slab only provides
ARCH_KMALLOC_MINALIGN alignment, even though it is observed
that the sector size allocation is often 512 byte aligned. When
KASAN or other memory debug options are enabled, the allocated
buffer becomes not aliged with 512 byte any more.

This unalgined IO buffer causes at least two issues:

1) some storage controller requires IO buffer to be 512 byte aligned,
and data corruption is observed

2) loop/dio requires the IO buffer to be logical block size aligned,
and loop's default logcial block size is 512 byte, then one xfs image
can't be mounted via loop/dio any more.

Use page_frag_alloc() to allocate the sector sized buffer, then the
above issue can be fixed because offset_in_page of allocated buffer
is always sector aligned.

Not see any regression with this patch on xfstests.

Cc: Jens Axboe <axboe@kernel.dk>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Darrick J. Wong <darrick.wong@oracle.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: linux-mm@kvack.org
Cc: linux-block@vger.kernel.org
Link: https://marc.info/?t=153734857500004&r=1&w=2
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/xfs/xfs_buf.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
index 4f5f2ff3f70f..92b8cdf5e51c 100644
--- a/fs/xfs/xfs_buf.c
+++ b/fs/xfs/xfs_buf.c
@@ -340,12 +340,27 @@ xfs_buf_free(
 			__free_page(page);
 		}
 	} else if (bp->b_flags & _XBF_KMEM)
-		kmem_free(bp->b_addr);
+		page_frag_free(bp->b_addr);
 	_xfs_buf_free_pages(bp);
 	xfs_buf_free_maps(bp);
 	kmem_zone_free(xfs_buf_zone, bp);
 }
 
+static DEFINE_PER_CPU(struct page_frag_cache, xfs_frag_cache);
+
+static void *xfs_alloc_frag(int size)
+{
+	struct page_frag_cache *nc;
+	void *data;
+
+	preempt_disable();
+	nc = this_cpu_ptr(&xfs_frag_cache);
+	data = page_frag_alloc(nc, size, GFP_ATOMIC);
+	preempt_enable();
+
+	return data;
+}
+
 /*
  * Allocates all the pages for buffer in question and builds it's page list.
  */
@@ -368,7 +383,7 @@ xfs_buf_allocate_memory(
 	 */
 	size = BBTOB(bp->b_length);
 	if (size < PAGE_SIZE) {
-		bp->b_addr = kmem_alloc(size, KM_NOFS);
+		bp->b_addr = xfs_alloc_frag(size);
 		if (!bp->b_addr) {
 			/* low memory - use alloc_page loop instead */
 			goto use_alloc_page;
@@ -377,7 +392,7 @@ xfs_buf_allocate_memory(
 		if (((unsigned long)(bp->b_addr + size - 1) & PAGE_MASK) !=
 		    ((unsigned long)bp->b_addr & PAGE_MASK)) {
 			/* b_addr spans two pages - use alloc_page instead */
-			kmem_free(bp->b_addr);
+			page_frag_free(bp->b_addr);
 			bp->b_addr = NULL;
 			goto use_alloc_page;
 		}
-- 
2.9.5

