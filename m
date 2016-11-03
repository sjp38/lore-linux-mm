Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A80F3280250
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 12:07:05 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id d128so68986537ybh.6
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 09:07:05 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d9si8660956paf.112.2016.11.03.09.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 09:07:04 -0700 (PDT)
From: Shiraz Hashim <shashim@codeaurora.org>
Subject: [PATCH 1/1] mm: cma: check the max limit for cma allocation
Date: Thu,  3 Nov 2016 21:36:51 +0530
Message-Id: <1478189211-3467-1-git-send-email-shashim@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, sfr@canb.auug.org.au, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shiraz Hashim <shashim@codeaurora.org>

CMA allocation request size is represented by size_t that
gets truncated when same is passed as int to
bitmap_find_next_zero_area_off.

We observe that during fuzz testing when cma allocation
request is too high, bitmap_find_next_zero_area_off still
returns success due to the truncation. This leads to
kernel crash, as subsequent code assumes that requested
memory is available.

Fail cma allocation in case the request breaches the
corresponding cma region size.

Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
---
 mm/cma.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 384c2cb..c960459 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -385,6 +385,9 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 	bitmap_maxno = cma_bitmap_maxno(cma);
 	bitmap_count = cma_bitmap_pages_to_bits(cma, count);
 
+	if (bitmap_count > bitmap_maxno)
+		return NULL;
+
 	for (;;) {
 		mutex_lock(&cma->lock);
 		bitmap_no = bitmap_find_next_zero_area_off(cma->bitmap,
-- 
Shiraz Hashim

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
