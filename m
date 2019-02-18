Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81414C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C731217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C731217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9E8F8E0005; Mon, 18 Feb 2019 16:07:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FCF28E0002; Mon, 18 Feb 2019 16:07:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 912148E0005; Mon, 18 Feb 2019 16:07:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D55E8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:32 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id a5so8344299wrq.3
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bEc+KUL6oe1C5VhMw4UMHOFR8WN9T26UJj4VRTS+sJw=;
        b=co66ZdMewOASj6OvwWQdSBV7zzTR0QdrrW1SAfrumsn7ty2l19+2M94j9MaZry5yVN
         1xEarMyk/Eqod7wxm7Ypu4OK6rWwUOEQ3L4sMrV0sQsdf07DS8nndeRn6xUUW1wgcXij
         4eEp9QvV1SRmIkN/Th7semvsy6gop/OfLxy8uBcxgde3vtdezaxYvrflqWMXK0rxkuVp
         XbkKwbU41hXozKkBwmcauh0sVWVIljVEvUQZ/na/iiU6F6M5TT0nxxn1ZOh+kU2ZT5ty
         rSOkEhwpfJGwtjI0VKUTR36TlB/JBpQO17+oVciAYx6AYR0nlvLfmDVZl7LKmpRlfQex
         ROjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAualPqVg5j2ctCTeSm5da0/Twf71SxqB6OXWpO6Fe+vOHVSxWZIY
	6JwxPsKvocDDas/sOFBW/M8tw9Q5saarDdL+sot7vk/PpDPA/p2WN4yIPmgQl6yLp2JXY8mIoGJ
	IaAyhE3gsjo9vifCwVE97Pv570uJKuXRI0LskSf7lhTRC9asOlH2GYKRQ42HBenQVVA==
X-Received: by 2002:adf:a104:: with SMTP id o4mr17607580wro.244.1550524051755;
        Mon, 18 Feb 2019 13:07:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iae/GmlaXhCQjRu9X5+FMyN52AoJk8Oq8WHcBbyduuV4/AaxIp5wXMQD7Etj9DZO8RCg7xX
X-Received: by 2002:adf:a104:: with SMTP id o4mr17607547wro.244.1550524050674;
        Mon, 18 Feb 2019 13:07:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524050; cv=none;
        d=google.com; s=arc-20160816;
        b=fksBoXXzUfSMqnTtq7ec9fVrs0+7iKLsxlNaHiJ3z9YnWZrgx7bNe1EblLP1NQGoW2
         n1Nn050cupVGCXNx5X8ufSEFsYP7VWvsn9TzZtbsa8WU5khN1N6GmMyjzWVTWYv77cLm
         1LkvjoAntVpwdKq9VvqWuY/rvdO9GfxY5cU4kyFSZggB2Lz4ECE501F52P2QEDDiEeYB
         3QC1vVk1QG/Ym89ykBrwktrwC0IIKUsfA94nLfqcxEnReOTUIhr/tL6Fso9TagRlGIXo
         D4GBVyGFb33kXBnzoVWCD/zHrZEatSZXFl+9zRr/qGwRCwRmEC9EC3pTAidxOLdaVAcG
         jPEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=bEc+KUL6oe1C5VhMw4UMHOFR8WN9T26UJj4VRTS+sJw=;
        b=ZxfeEdCcfV9mj8by2q7E81mJh4y4g9D/URcWe4A0OGr8M+6pzVKMUczwKOOt1ZvvQn
         jogXolFh1Wz34gyYm14Quv63L7dErLPH+O/XvXJ1BnuEVeRz8htEcqwiWpdbrul3cSq2
         lh9tEcO0uxr/qiTMaIGZ6Vf4lUosBl/HiPpBbaHL9MafDIMmh6CT9HNp9Bi5dVeA10h0
         D4GppCPt09GCLObG5Ro48YjFQruzPjAQrRvtPWc2JAhVaaxBr4l0jgh7XT5p06d3Nw6p
         StZ6iwfOSuxBlAc+Y13PAox+Mee753vmhz+zXBs+LzI7zLzR1HqT/l3ycmf1+7DDEPU6
         hpyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id c187si268448wma.107.2019.02.18.13.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:30 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id 2C06127FD42
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 2/6] Revert "mm/cma: remove unsupported gfp_mask parameter from cma_alloc()"
Date: Mon, 18 Feb 2019 16:07:11 -0500
Message-Id: <20190218210715.1066-3-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This reverts commit 6518202970c1052148daaef9a8096711775e43a2.

Commit 6518202970c1 ("mm/cma: remove unsupported gfp_mask parameter from
cma_alloc()") attempts to make more clear that the CMA allocator doesn't
support all of the standard GFP flags by removing that parameter from
cma_alloc().  Unfortunately, this don't make things much more clear
about what CMA supports, as exemplified by the ARM DMA layer issue,
which simply masks away the GFP_NOIO flag when calling the CMA
allocator, letting it assume it is always the hardcoded GFP_KERNEL.

The removal of gfp_flags doesn't make any easier to eventually support
these flags in the CMA allocator, like the rest of this series attempt
to do.  Instead, this patch and the previous one restore that parameter.

CC: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
---
 arch/powerpc/kvm/book3s_hv_builtin.c       | 2 +-
 drivers/s390/char/vmcp.c                   | 2 +-
 drivers/staging/android/ion/ion_cma_heap.c | 2 +-
 include/linux/cma.h                        | 2 +-
 kernel/dma/contiguous.c                    | 3 +--
 mm/cma.c                                   | 8 ++++----
 mm/cma_debug.c                             | 2 +-
 7 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
index a71e2fc00a4e..925e8f9fc10d 100644
--- a/arch/powerpc/kvm/book3s_hv_builtin.c
+++ b/arch/powerpc/kvm/book3s_hv_builtin.c
@@ -77,7 +77,7 @@ struct page *kvm_alloc_hpt_cma(unsigned long nr_pages)
 	VM_BUG_ON(order_base_2(nr_pages) < KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
 
 	return cma_alloc(kvm_cma, nr_pages, order_base_2(HPT_ALIGN_PAGES),
-			 false);
+			 GFP_KERNEL);
 }
 EXPORT_SYMBOL_GPL(kvm_alloc_hpt_cma);
 
diff --git a/drivers/s390/char/vmcp.c b/drivers/s390/char/vmcp.c
index 0fa1b6b1491a..948ce82a7725 100644
--- a/drivers/s390/char/vmcp.c
+++ b/drivers/s390/char/vmcp.c
@@ -68,7 +68,7 @@ static void vmcp_response_alloc(struct vmcp_session *session)
 	 * anymore the system won't work anyway.
 	 */
 	if (order > 2)
-		page = cma_alloc(vmcp_cma, nr_pages, 0, false);
+		page = cma_alloc(vmcp_cma, nr_pages, 0, GFP_KERNEL);
 	if (page) {
 		session->response = (char *)page_to_phys(page);
 		session->cma_alloc = 1;
diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index 3fafd013d80a..49718c96bf9e 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -39,7 +39,7 @@ static int ion_cma_allocate(struct ion_heap *heap, struct ion_buffer *buffer,
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	pages = cma_alloc(cma_heap->cma, nr_pages, align, false);
+	pages = cma_alloc(cma_heap->cma, nr_pages, align, GFP_KERNEL);
 	if (!pages)
 		return -ENOMEM;
 
diff --git a/include/linux/cma.h b/include/linux/cma.h
index 190184b5ff32..bf90f0bb42bd 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -33,7 +33,7 @@ extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					const char *name,
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
-			      bool no_warn);
+			      gfp_t gfp_mask);
 extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
 
 extern int cma_for_each_area(int (*it)(struct cma *cma, void *data), void *data);
diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c
index b1c3109bbd26..54a33337680f 100644
--- a/kernel/dma/contiguous.c
+++ b/kernel/dma/contiguous.c
@@ -195,8 +195,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	return cma_alloc(dev_get_cma_area(dev), count, align,
-			 gfp_mask & __GFP_NOWARN);
+	return cma_alloc(dev_get_cma_area(dev), count, align, gfp_mask);
 }
 
 /**
diff --git a/mm/cma.c b/mm/cma.c
index c7b39dd3b4f6..fdad7ad0d9c4 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -395,13 +395,13 @@ static inline void cma_debug_show_areas(struct cma *cma) { }
  * @cma:   Contiguous memory region for which the allocation is performed.
  * @count: Requested number of pages.
  * @align: Requested alignment of pages (in PAGE_SIZE order).
- * @no_warn: Avoid printing message about failed allocation
+ * @gfp_mask:  GFP mask to use during compaction
  *
  * This function allocates part of contiguous memory on specific
  * contiguous memory area.
  */
 struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
-		       bool no_warn)
+		       gfp_t gfp_mask)
 {
 	unsigned long mask, offset;
 	unsigned long pfn = -1;
@@ -448,7 +448,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
 		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
-				     GFP_KERNEL | (no_warn ? __GFP_NOWARN : 0));
+					 gfp_mask);
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
@@ -477,7 +477,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 			page_kasan_tag_reset(page + i);
 	}
 
-	if (ret && !no_warn) {
+	if (ret && !(gfp_mask & __GFP_NOWARN)) {
 		pr_err("%s: alloc failed, req-size: %zu pages, ret: %d\n",
 			__func__, count, ret);
 		cma_debug_show_areas(cma);
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index ad6723e9d110..f23467291cfb 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -139,7 +139,7 @@ static int cma_alloc_mem(struct cma *cma, int count)
 	if (!mem)
 		return -ENOMEM;
 
-	p = cma_alloc(cma, count, 0, false);
+	p = cma_alloc(cma, count, 0, GFP_KERNEL);
 	if (!p) {
 		kfree(mem);
 		return -ENOMEM;
-- 
2.20.1

