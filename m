Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBAE6C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65F4E2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P2sOiqZ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65F4E2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95F5B6B000D; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D3B76B0266; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 688CE6B000E; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18D0F6B000C
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so59277858pfb.7
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Go3ivFT762jDsG9LuzJRrEjuX4MNRycowFCEpdrDMsM=;
        b=p+IcewXQ1QEAlKUK1A4Y1I3kMybCdqBkCvLo/E+1Yd74uuvbM+HiIjjRZeHxCSJdBt
         Tm9Mcx4SmNo5BVsDZR5ZvACVOiPOxW3Xatq41x8bRQoU4S/xZhDxvURMUpHna3KTLrxM
         HtYXlMwiplAgizUHmQOjYrb4haU5iSsn0RkmD7ye0PpMHa/onS5aqGExULdRJtMm8/rW
         E4mysF5t6DPBZjhco0mVPEMnUK/fAqF7DBlhdBLVB9wuGoO3AbPm9/lOCu//RwNWPlUz
         L/K4AR1hVXnoKyJgzJOffHo2pZ1QKDIk/Ir7LwBVj6GvzEPOgAqSxRnL1uEq31GVZjkg
         rktg==
X-Gm-Message-State: APjAAAUy0vjKyee4mbh5ilPvguZVcLr86kv/vvAJQiEO1s98Jz2b5XES
	RlQa76OQqTIzY3ayGJE/TCGa3Cr1iKi+65/lCYqw87CQW+qil1ydy5WD6SA23CoFXjrwkmsd4Jh
	0ijA8gyuAeOBPtklumwibWdnr0Yh5e5jwMOGy3fE/S1Q/9xzK8CxFAnazOSsS6wQ=
X-Received: by 2002:a17:902:20b:: with SMTP id 11mr14569595plc.78.1565278440585;
        Thu, 08 Aug 2019 08:34:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIx0Z3ljgRvdYQtNbacyVLJfJaUI0RqE1x6IRuASuu8n1mw06fDUt94lpR99aQpl9vpC8X
X-Received: by 2002:a17:902:20b:: with SMTP id 11mr14569384plc.78.1565278438384;
        Thu, 08 Aug 2019 08:33:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278438; cv=none;
        d=google.com; s=arc-20160816;
        b=GCBk7kqNZGecGk7qB8FfdFnb1Jr7yfqIO0UuPLQ2hvd7SlU9TKe8c8SdrwH1CiuWLL
         HmFJrKF7DcKhyJ/MgxoRRN3qPRYI+JiEIa3sjlBlDOTG8HUZ4wONqv1/6JOx5RV85hZR
         SABim6dmn+uWNNYz91S5BRw5OFEeziJNkZL5FOOeCVAub49dAJ3PwI7lT1dWKWP/HZk+
         8WLYHETnHSKZeIEiBOxP8VqrwPpLKo6MHaFDp0d0D9QoaVNG5vePgGuY+v+9A68/FMo6
         3JLHg4nMRxidMFcdhmvm7aQKe9ay0NLssmogxANy+Wv2DuxjYucJZ9/AwQaZ8Z2bZ4nA
         8dOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Go3ivFT762jDsG9LuzJRrEjuX4MNRycowFCEpdrDMsM=;
        b=EZgLkUxpwSLF+CS0YAXNCwp+qprwLoMdvW4Ik1PeqI60ifuxTlHkcivFPifD1kUS2w
         5pe1Px0zGjZaeF3B/GhO4ZUYu6hnkTtuage2MG8jv48WNw2rWcJ7Q0eNwSkc4cRh7In9
         0oYsb3ZQCk26VN2rIGYPKfGKfV9krlUd6UvytdnMPPr+BefOY91RWGXWvJOYv1IJL2lL
         mYTdxSHj59OOL0dRGSfMtfrfV+EXJ/fvN6/JkauqSsVVh9gdj+P0wnBn8xEFKAKSP04z
         oqLP87QFKl1RIyXvuJxGzY/7KuECd00/a+iFP4nXT2vxeYPkZZJEIO2lTE+YOvqjtIZ/
         MZjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P2sOiqZ6;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q32si19004310pgb.408.2019.08.08.08.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:33:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P2sOiqZ6;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Go3ivFT762jDsG9LuzJRrEjuX4MNRycowFCEpdrDMsM=; b=P2sOiqZ60H3Y21U90qds+P/NU9
	hZSiWli509yUTMt1oZgc/VJR1mBk4ZJPXJxl50iV1FgAO98yG6kr4Mz+++i1wcYOew5GDO6q+/BHh
	YhvQ1g16uWSKqMffCNoD4f9PTJC2ilDRrdU+djOJJEaxgzHwvLaqp5Lh6yrTDsl5zEuea4mvSnE0M
	VMINSvl7MtMkhofyPVaGcnsrwOmn/FF589clR0J5Sc47g+g/sdYYOv+F90meo8ALJ5ZDA1PwamX0n
	z3g4g7O+/ud5hd8CmCIg/m5b31G+aTsAdmtYZw0ffhsqdL//aVTT6e+9gpfRQ341HzSFkzTg+o2Cs
	/FBCPVpA==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQK-0005AF-Iw; Thu, 08 Aug 2019 15:33:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/9] mm: turn migrate_vma upside down
Date: Thu,  8 Aug 2019 18:33:38 +0300
Message-Id: <20190808153346.9061-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808153346.9061-1-hch@lst.de>
References: <20190808153346.9061-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There isn't any good reason to pass callbacks to migrate_vma.  Instead
we can just export the three steps done by this function to drivers and
let them sequence the operation without callbacks.  This removes a lot
of boilerplate code as-is, and will allow the drivers to drastically
improve code flow and error handling further on.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 Documentation/vm/hmm.rst               |  55 +-----
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 122 +++++++------
 include/linux/migrate.h                | 118 ++----------
 mm/migrate.c                           | 244 +++++++++++--------------
 4 files changed, 195 insertions(+), 344 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index e63c11f7e0e0..4f81c77059e3 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -339,58 +339,9 @@ Migration to and from device memory
 ===================================
 
 Because the CPU cannot access device memory, migration must use the device DMA
-engine to perform copy from and to device memory. For this we need a new
-migration helper::
-
- int migrate_vma(const struct migrate_vma_ops *ops,
-                 struct vm_area_struct *vma,
-                 unsigned long mentries,
-                 unsigned long start,
-                 unsigned long end,
-                 unsigned long *src,
-                 unsigned long *dst,
-                 void *private);
-
-Unlike other migration functions it works on a range of virtual address, there
-are two reasons for that. First, device DMA copy has a high setup overhead cost
-and thus batching multiple pages is needed as otherwise the migration overhead
-makes the whole exercise pointless. The second reason is because the
-migration might be for a range of addresses the device is actively accessing.
-
-The migrate_vma_ops struct defines two callbacks. First one (alloc_and_copy())
-controls destination memory allocation and copy operation. Second one is there
-to allow the device driver to perform cleanup operations after migration::
-
- struct migrate_vma_ops {
-     void (*alloc_and_copy)(struct vm_area_struct *vma,
-                            const unsigned long *src,
-                            unsigned long *dst,
-                            unsigned long start,
-                            unsigned long end,
-                            void *private);
-     void (*finalize_and_map)(struct vm_area_struct *vma,
-                              const unsigned long *src,
-                              const unsigned long *dst,
-                              unsigned long start,
-                              unsigned long end,
-                              void *private);
- };
-
-It is important to stress that these migration helpers allow for holes in the
-virtual address range. Some pages in the range might not be migrated for all
-the usual reasons (page is pinned, page is locked, ...). This helper does not
-fail but just skips over those pages.
-
-The alloc_and_copy() might decide to not migrate all pages in the
-range (for reasons under the callback control). For those, the callback just
-has to leave the corresponding dst entry empty.
-
-Finally, the migration of the struct page might fail (for file backed page) for
-various reasons (failure to freeze reference, or update page cache, ...). If
-that happens, then the finalize_and_map() can catch any pages that were not
-migrated. Note those pages were still copied to a new page and thus we wasted
-bandwidth but this is considered as a rare event and a price that we are
-willing to pay to keep all the code simpler.
+engine to perform copy from and to device memory. For this we need a new to
+use migrate_vma_setup(), migrate_vma_pages(), and migrate_vma_finalize()
+helpers.
 
 
 Memory cgroup (memcg) and rss accounting
diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 345c63cb752a..38416798abd4 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -131,9 +131,8 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 				  unsigned long *dst_pfns,
 				  unsigned long start,
 				  unsigned long end,
-				  void *private)
+				  struct nouveau_dmem_fault *fault)
 {
-	struct nouveau_dmem_fault *fault = private;
 	struct nouveau_drm *drm = fault->drm;
 	struct device *dev = drm->dev->dev;
 	unsigned long addr, i, npages = 0;
@@ -230,14 +229,9 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 	}
 }
 
-void nouveau_dmem_fault_finalize_and_map(struct vm_area_struct *vma,
-					 const unsigned long *src_pfns,
-					 const unsigned long *dst_pfns,
-					 unsigned long start,
-					 unsigned long end,
-					 void *private)
+static void
+nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
 {
-	struct nouveau_dmem_fault *fault = private;
 	struct nouveau_drm *drm = fault->drm;
 
 	if (fault->fence) {
@@ -257,29 +251,35 @@ void nouveau_dmem_fault_finalize_and_map(struct vm_area_struct *vma,
 	kfree(fault->dma);
 }
 
-static const struct migrate_vma_ops nouveau_dmem_fault_migrate_ops = {
-	.alloc_and_copy		= nouveau_dmem_fault_alloc_and_copy,
-	.finalize_and_map	= nouveau_dmem_fault_finalize_and_map,
-};
-
 static vm_fault_t nouveau_dmem_migrate_to_ram(struct vm_fault *vmf)
 {
 	struct nouveau_dmem *dmem = page_to_dmem(vmf->page);
 	unsigned long src[1] = {0}, dst[1] = {0};
+	struct migrate_vma args = {
+		.vma		= vmf->vma,
+		.start		= vmf->address,
+		.end		= vmf->address + PAGE_SIZE,
+		.src		= src,
+		.dst		= dst,
+	};
 	struct nouveau_dmem_fault fault = { .drm = dmem->drm };
-	int ret;
 
 	/*
 	 * FIXME what we really want is to find some heuristic to migrate more
 	 * than just one page on CPU fault. When such fault happens it is very
 	 * likely that more surrounding page will CPU fault too.
 	 */
-	ret = migrate_vma(&nouveau_dmem_fault_migrate_ops, vmf->vma,
-			vmf->address, vmf->address + PAGE_SIZE,
-			src, dst, &fault);
-	if (ret)
+	if (migrate_vma_setup(&args) < 0)
 		return VM_FAULT_SIGBUS;
+	if (!args.cpages)
+		return 0;
+
+	nouveau_dmem_fault_alloc_and_copy(args.vma, src, dst, args.start,
+			args.end, &fault);
+	migrate_vma_pages(&args);
+	nouveau_dmem_fault_finalize_and_map(&fault);
 
+	migrate_vma_finalize(&args);
 	if (dst[0] == MIGRATE_PFN_ERROR)
 		return VM_FAULT_SIGBUS;
 
@@ -648,9 +648,8 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 				    unsigned long *dst_pfns,
 				    unsigned long start,
 				    unsigned long end,
-				    void *private)
+				    struct nouveau_migrate *migrate)
 {
-	struct nouveau_migrate *migrate = private;
 	struct nouveau_drm *drm = migrate->drm;
 	struct device *dev = drm->dev->dev;
 	unsigned long addr, i, npages = 0;
@@ -747,14 +746,9 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	}
 }
 
-void nouveau_dmem_migrate_finalize_and_map(struct vm_area_struct *vma,
-					   const unsigned long *src_pfns,
-					   const unsigned long *dst_pfns,
-					   unsigned long start,
-					   unsigned long end,
-					   void *private)
+static void
+nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
 {
-	struct nouveau_migrate *migrate = private;
 	struct nouveau_drm *drm = migrate->drm;
 
 	if (migrate->fence) {
@@ -779,10 +773,15 @@ void nouveau_dmem_migrate_finalize_and_map(struct vm_area_struct *vma,
 	 */
 }
 
-static const struct migrate_vma_ops nouveau_dmem_migrate_ops = {
-	.alloc_and_copy		= nouveau_dmem_migrate_alloc_and_copy,
-	.finalize_and_map	= nouveau_dmem_migrate_finalize_and_map,
-};
+static void nouveau_dmem_migrate_chunk(struct migrate_vma *args,
+		struct nouveau_migrate *migrate)
+{
+	nouveau_dmem_migrate_alloc_and_copy(args->vma, args->src, args->dst,
+			args->start, args->end, migrate);
+	migrate_vma_pages(args);
+	nouveau_dmem_migrate_finalize_and_map(migrate);
+	migrate_vma_finalize(args);
+}
 
 int
 nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
@@ -790,40 +789,45 @@ nouveau_dmem_migrate_vma(struct nouveau_drm *drm,
 			 unsigned long start,
 			 unsigned long end)
 {
-	unsigned long *src_pfns, *dst_pfns, npages;
-	struct nouveau_migrate migrate = {0};
-	unsigned long i, c, max;
-	int ret = 0;
-
-	npages = (end - start) >> PAGE_SHIFT;
-	max = min(SG_MAX_SINGLE_ALLOC, npages);
-	src_pfns = kzalloc(sizeof(long) * max, GFP_KERNEL);
-	if (src_pfns == NULL)
-		return -ENOMEM;
-	dst_pfns = kzalloc(sizeof(long) * max, GFP_KERNEL);
-	if (dst_pfns == NULL) {
-		kfree(src_pfns);
-		return -ENOMEM;
-	}
+	unsigned long npages = (end - start) >> PAGE_SHIFT;
+	unsigned long max = min(SG_MAX_SINGLE_ALLOC, npages);
+	struct migrate_vma args = {
+		.vma		= vma,
+		.start		= start,
+	};
+	struct nouveau_migrate migrate = {
+		.drm		= drm,
+		.vma		= vma,
+		.npages		= npages,
+	};
+	unsigned long c, i;
+	int ret = -ENOMEM;
+
+	args.src = kzalloc(sizeof(long) * max, GFP_KERNEL);
+	if (!args.src)
+		goto out;
+	args.dst = kzalloc(sizeof(long) * max, GFP_KERNEL);
+	if (!args.dst)
+		goto out_free_src;
 
-	migrate.drm = drm;
-	migrate.vma = vma;
-	migrate.npages = npages;
 	for (i = 0; i < npages; i += c) {
-		unsigned long next;
-
 		c = min(SG_MAX_SINGLE_ALLOC, npages);
-		next = start + (c << PAGE_SHIFT);
-		ret = migrate_vma(&nouveau_dmem_migrate_ops, vma, start,
-				  next, src_pfns, dst_pfns, &migrate);
+		args.end = start + (c << PAGE_SHIFT);
+		ret = migrate_vma_setup(&args);
 		if (ret)
-			goto out;
-		start = next;
+			goto out_free_dst;
+
+		if (args.cpages)
+			nouveau_dmem_migrate_chunk(&args, &migrate);
+		args.start = args.end;
 	}
 
+	ret = 0;
+out_free_dst:
+	kfree(args.dst);
+out_free_src:
+	kfree(args.src);
 out:
-	kfree(dst_pfns);
-	kfree(src_pfns);
 	return ret;
 }
 
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 7f04754c7f2b..18156d379ebf 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -182,107 +182,27 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
 	return (pfn << MIGRATE_PFN_SHIFT) | MIGRATE_PFN_VALID;
 }
 
-/*
- * struct migrate_vma_ops - migrate operation callback
- *
- * @alloc_and_copy: alloc destination memory and copy source memory to it
- * @finalize_and_map: allow caller to map the successfully migrated pages
- *
- *
- * The alloc_and_copy() callback happens once all source pages have been locked,
- * unmapped and checked (checked whether pinned or not). All pages that can be
- * migrated will have an entry in the src array set with the pfn value of the
- * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set (other
- * flags might be set but should be ignored by the callback).
- *
- * The alloc_and_copy() callback can then allocate destination memory and copy
- * source memory to it for all those entries (ie with MIGRATE_PFN_VALID and
- * MIGRATE_PFN_MIGRATE flag set). Once these are allocated and copied, the
- * callback must update each corresponding entry in the dst array with the pfn
- * value of the destination page and with the MIGRATE_PFN_VALID and
- * MIGRATE_PFN_LOCKED flags set (destination pages must have their struct pages
- * locked, via lock_page()).
- *
- * At this point the alloc_and_copy() callback is done and returns.
- *
- * Note that the callback does not have to migrate all the pages that are
- * marked with MIGRATE_PFN_MIGRATE flag in src array unless this is a migration
- * from device memory to system memory (ie the MIGRATE_PFN_DEVICE flag is also
- * set in the src array entry). If the device driver cannot migrate a device
- * page back to system memory, then it must set the corresponding dst array
- * entry to MIGRATE_PFN_ERROR. This will trigger a SIGBUS if CPU tries to
- * access any of the virtual addresses originally backed by this page. Because
- * a SIGBUS is such a severe result for the userspace process, the device
- * driver should avoid setting MIGRATE_PFN_ERROR unless it is really in an
- * unrecoverable state.
- *
- * For empty entry inside CPU page table (pte_none() or pmd_none() is true) we
- * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array thus
- * allowing device driver to allocate device memory for those unback virtual
- * address. For this the device driver simply have to allocate device memory
- * and properly set the destination entry like for regular migration. Note that
- * this can still fails and thus inside the device driver must check if the
- * migration was successful for those entry inside the finalize_and_map()
- * callback just like for regular migration.
- *
- * THE alloc_and_copy() CALLBACK MUST NOT CHANGE ANY OF THE SRC ARRAY ENTRIES
- * OR BAD THINGS WILL HAPPEN !
- *
- *
- * The finalize_and_map() callback happens after struct page migration from
- * source to destination (destination struct pages are the struct pages for the
- * memory allocated by the alloc_and_copy() callback).  Migration can fail, and
- * thus the finalize_and_map() allows the driver to inspect which pages were
- * successfully migrated, and which were not. Successfully migrated pages will
- * have the MIGRATE_PFN_MIGRATE flag set for their src array entry.
- *
- * It is safe to update device page table from within the finalize_and_map()
- * callback because both destination and source page are still locked, and the
- * mmap_sem is held in read mode (hence no one can unmap the range being
- * migrated).
- *
- * Once callback is done cleaning up things and updating its page table (if it
- * chose to do so, this is not an obligation) then it returns. At this point,
- * the HMM core will finish up the final steps, and the migration is complete.
- *
- * THE finalize_and_map() CALLBACK MUST NOT CHANGE ANY OF THE SRC OR DST ARRAY
- * ENTRIES OR BAD THINGS WILL HAPPEN !
- */
-struct migrate_vma_ops {
-	void (*alloc_and_copy)(struct vm_area_struct *vma,
-			       const unsigned long *src,
-			       unsigned long *dst,
-			       unsigned long start,
-			       unsigned long end,
-			       void *private);
-	void (*finalize_and_map)(struct vm_area_struct *vma,
-				 const unsigned long *src,
-				 const unsigned long *dst,
-				 unsigned long start,
-				 unsigned long end,
-				 void *private);
+struct migrate_vma {
+	struct vm_area_struct	*vma;
+	/*
+	 * Both src and dst array must be big enough for
+	 * (end - start) >> PAGE_SHIFT entries.
+	 *
+	 * The src array must not be modified by the caller after
+	 * migrate_vma_setup(), and must not change the dst array after
+	 * migrate_vma_pages() returns.
+	 */
+	unsigned long		*dst;
+	unsigned long		*src;
+	unsigned long		cpages;
+	unsigned long		npages;
+	unsigned long		start;
+	unsigned long		end;
 };
 
-#if defined(CONFIG_MIGRATE_VMA_HELPER)
-int migrate_vma(const struct migrate_vma_ops *ops,
-		struct vm_area_struct *vma,
-		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private);
-#else
-static inline int migrate_vma(const struct migrate_vma_ops *ops,
-			      struct vm_area_struct *vma,
-			      unsigned long start,
-			      unsigned long end,
-			      unsigned long *src,
-			      unsigned long *dst,
-			      void *private)
-{
-	return -EINVAL;
-}
-#endif /* IS_ENABLED(CONFIG_MIGRATE_VMA_HELPER) */
+int migrate_vma_setup(struct migrate_vma *args);
+void migrate_vma_pages(struct migrate_vma *migrate);
+void migrate_vma_finalize(struct migrate_vma *migrate);
 
 #endif /* CONFIG_MIGRATION */
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 8992741f10aa..e2565374d330 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2118,16 +2118,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #endif /* CONFIG_NUMA */
 
 #if defined(CONFIG_MIGRATE_VMA_HELPER)
-struct migrate_vma {
-	struct vm_area_struct	*vma;
-	unsigned long		*dst;
-	unsigned long		*src;
-	unsigned long		cpages;
-	unsigned long		npages;
-	unsigned long		start;
-	unsigned long		end;
-};
-
 static int migrate_vma_collect_hole(unsigned long start,
 				    unsigned long end,
 				    struct mm_walk *walk)
@@ -2578,6 +2568,110 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 	}
 }
 
+/**
+ * migrate_vma_setup() - prepare to migrate a range of memory
+ * @args: contains the vma, start, and and pfns arrays for the migration
+ *
+ * Returns: negative errno on failures, 0 when 0 or more pages were migrated
+ * without an error.
+ *
+ * Prepare to migrate a range of memory virtual address range by collecting all
+ * the pages backing each virtual address in the range, saving them inside the
+ * src array.  Then lock those pages and unmap them. Once the pages are locked
+ * and unmapped, check whether each page is pinned or not.  Pages that aren't
+ * pinned have the MIGRATE_PFN_MIGRATE flag set (by this function) in the
+ * corresponding src array entry.  Then restores any pages that are pinned, by
+ * remapping and unlocking those pages.
+ *
+ * The caller should then allocate destination memory and copy source memory to
+ * it for all those entries (ie with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE
+ * flag set).  Once these are allocated and copied, the caller must update each
+ * corresponding entry in the dst array with the pfn value of the destination
+ * page and with the MIGRATE_PFN_VALID and MIGRATE_PFN_LOCKED flags set
+ * (destination pages must have their struct pages locked, via lock_page()).
+ *
+ * Note that the caller does not have to migrate all the pages that are marked
+ * with MIGRATE_PFN_MIGRATE flag in src array unless this is a migration from
+ * device memory to system memory.  If the caller cannot migrate a device page
+ * back to system memory, then it must return VM_FAULT_SIGBUS, which has severe
+ * consequences for the userspace process, so it must be avoided if at all
+ * possible.
+ *
+ * For empty entries inside CPU page table (pte_none() or pmd_none() is true) we
+ * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array thus
+ * allowing the caller to allocate device memory for those unback virtual
+ * address.  For this the caller simply has to allocate device memory and
+ * properly set the destination entry like for regular migration.  Note that
+ * this can still fails and thus inside the device driver must check if the
+ * migration was successful for those entries after calling migrate_vma_pages()
+ * just like for regular migration.
+ *
+ * After that, the callers must call migrate_vma_pages() to go over each entry
+ * in the src array that has the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag
+ * set. If the corresponding entry in dst array has MIGRATE_PFN_VALID flag set,
+ * then migrate_vma_pages() to migrate struct page information from the source
+ * struct page to the destination struct page.  If it fails to migrate the
+ * struct page information, then it clears the MIGRATE_PFN_MIGRATE flag in the
+ * src array.
+ *
+ * At this point all successfully migrated pages have an entry in the src
+ * array with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set and the dst
+ * array entry with MIGRATE_PFN_VALID flag set.
+ *
+ * Once migrate_vma_pages() returns the caller may inspect which pages were
+ * successfully migrated, and which were not.  Successfully migrated pages will
+ * have the MIGRATE_PFN_MIGRATE flag set for their src array entry.
+ *
+ * It is safe to update device page table from within the finalize_and_map()
+ * callback because both destination and source page are still locked, and the
+ * mmap_sem is held in read mode (hence no one can unmap the range being
+ * migrated).
+ *
+ * Once the caller is done cleaning up things and updating its page table (if it
+ * chose to do so, this is not an obligation) it finally calls
+ * migrate_vma_finalize() to update the CPU page table to point to new pages
+ * for successfully migrated pages or otherwise restore the CPU page table to
+ * point to the original source pages.
+ */
+int migrate_vma_setup(struct migrate_vma *args)
+{
+	long nr_pages = (args->end - args->start) >> PAGE_SHIFT;
+
+	args->start &= PAGE_MASK;
+	args->end &= PAGE_MASK;
+	if (!args->vma || is_vm_hugetlb_page(args->vma) ||
+	    (args->vma->vm_flags & VM_SPECIAL) || vma_is_dax(args->vma))
+		return -EINVAL;
+	if (nr_pages <= 0)
+		return -EINVAL;
+	if (args->start < args->vma->vm_start ||
+	    args->start >= args->vma->vm_end)
+		return -EINVAL;
+	if (args->end <= args->vma->vm_start || args->end > args->vma->vm_end)
+		return -EINVAL;
+	if (!args->src || !args->dst)
+		return -EINVAL;
+
+	memset(args->src, 0, sizeof(*args->src) * nr_pages);
+	args->cpages = 0;
+	args->npages = 0;
+
+	migrate_vma_collect(args);
+	if (args->cpages)
+		migrate_vma_prepare(args);
+	if (args->cpages)
+		migrate_vma_unmap(args);
+
+	/*
+	 * At this point pages are locked and unmapped, and thus they have
+	 * stable content and can safely be copied to destination memory that
+	 * is allocated by the drivers.
+	 */
+	return 0;
+
+}
+EXPORT_SYMBOL(migrate_vma_setup);
+
 static void migrate_vma_insert_page(struct migrate_vma *migrate,
 				    unsigned long addr,
 				    struct page *page,
@@ -2709,7 +2803,7 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
 	*src &= ~MIGRATE_PFN_MIGRATE;
 }
 
-/*
+/**
  * migrate_vma_pages() - migrate meta-data from src page to dst page
  * @migrate: migrate struct containing all migration information
  *
@@ -2717,7 +2811,7 @@ static void migrate_vma_insert_page(struct migrate_vma *migrate,
  * struct page. This effectively finishes the migration from source page to the
  * destination page.
  */
-static void migrate_vma_pages(struct migrate_vma *migrate)
+void migrate_vma_pages(struct migrate_vma *migrate)
 {
 	const unsigned long npages = migrate->npages;
 	const unsigned long start = migrate->start;
@@ -2791,8 +2885,9 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 	if (notified)
 		mmu_notifier_invalidate_range_only_end(&range);
 }
+EXPORT_SYMBOL(migrate_vma_pages);
 
-/*
+/**
  * migrate_vma_finalize() - restore CPU page table entry
  * @migrate: migrate struct containing all migration information
  *
@@ -2803,7 +2898,7 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
  * This also unlocks the pages and puts them back on the lru, or drops the extra
  * refcount, for device pages.
  */
-static void migrate_vma_finalize(struct migrate_vma *migrate)
+void migrate_vma_finalize(struct migrate_vma *migrate)
 {
 	const unsigned long npages = migrate->npages;
 	unsigned long i;
@@ -2846,124 +2941,5 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 		}
 	}
 }
-
-/*
- * migrate_vma() - migrate a range of memory inside vma
- *
- * @ops: migration callback for allocating destination memory and copying
- * @vma: virtual memory area containing the range to be migrated
- * @start: start address of the range to migrate (inclusive)
- * @end: end address of the range to migrate (exclusive)
- * @src: array of hmm_pfn_t containing source pfns
- * @dst: array of hmm_pfn_t containing destination pfns
- * @private: pointer passed back to each of the callback
- * Returns: 0 on success, error code otherwise
- *
- * This function tries to migrate a range of memory virtual address range, using
- * callbacks to allocate and copy memory from source to destination. First it
- * collects all the pages backing each virtual address in the range, saving this
- * inside the src array. Then it locks those pages and unmaps them. Once the pages
- * are locked and unmapped, it checks whether each page is pinned or not. Pages
- * that aren't pinned have the MIGRATE_PFN_MIGRATE flag set (by this function)
- * in the corresponding src array entry. It then restores any pages that are
- * pinned, by remapping and unlocking those pages.
- *
- * At this point it calls the alloc_and_copy() callback. For documentation on
- * what is expected from that callback, see struct migrate_vma_ops comments in
- * include/linux/migrate.h
- *
- * After the alloc_and_copy() callback, this function goes over each entry in
- * the src array that has the MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag
- * set. If the corresponding entry in dst array has MIGRATE_PFN_VALID flag set,
- * then the function tries to migrate struct page information from the source
- * struct page to the destination struct page. If it fails to migrate the struct
- * page information, then it clears the MIGRATE_PFN_MIGRATE flag in the src
- * array.
- *
- * At this point all successfully migrated pages have an entry in the src
- * array with MIGRATE_PFN_VALID and MIGRATE_PFN_MIGRATE flag set and the dst
- * array entry with MIGRATE_PFN_VALID flag set.
- *
- * It then calls the finalize_and_map() callback. See comments for "struct
- * migrate_vma_ops", in include/linux/migrate.h for details about
- * finalize_and_map() behavior.
- *
- * After the finalize_and_map() callback, for successfully migrated pages, this
- * function updates the CPU page table to point to new pages, otherwise it
- * restores the CPU page table to point to the original source pages.
- *
- * Function returns 0 after the above steps, even if no pages were migrated
- * (The function only returns an error if any of the arguments are invalid.)
- *
- * Both src and dst array must be big enough for (end - start) >> PAGE_SHIFT
- * unsigned long entries.
- */
-int migrate_vma(const struct migrate_vma_ops *ops,
-		struct vm_area_struct *vma,
-		unsigned long start,
-		unsigned long end,
-		unsigned long *src,
-		unsigned long *dst,
-		void *private)
-{
-	struct migrate_vma migrate;
-
-	/* Sanity check the arguments */
-	start &= PAGE_MASK;
-	end &= PAGE_MASK;
-	if (!vma || is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
-			vma_is_dax(vma))
-		return -EINVAL;
-	if (start < vma->vm_start || start >= vma->vm_end)
-		return -EINVAL;
-	if (end <= vma->vm_start || end > vma->vm_end)
-		return -EINVAL;
-	if (!ops || !src || !dst || start >= end)
-		return -EINVAL;
-
-	memset(src, 0, sizeof(*src) * ((end - start) >> PAGE_SHIFT));
-	migrate.src = src;
-	migrate.dst = dst;
-	migrate.start = start;
-	migrate.npages = 0;
-	migrate.cpages = 0;
-	migrate.end = end;
-	migrate.vma = vma;
-
-	/* Collect, and try to unmap source pages */
-	migrate_vma_collect(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/* Lock and isolate page */
-	migrate_vma_prepare(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/* Unmap pages */
-	migrate_vma_unmap(&migrate);
-	if (!migrate.cpages)
-		return 0;
-
-	/*
-	 * At this point pages are locked and unmapped, and thus they have
-	 * stable content and can safely be copied to destination memory that
-	 * is allocated by the callback.
-	 *
-	 * Note that migration can fail in migrate_vma_struct_page() for each
-	 * individual page.
-	 */
-	ops->alloc_and_copy(vma, src, dst, start, end, private);
-
-	/* This does the real migration of struct page */
-	migrate_vma_pages(&migrate);
-
-	ops->finalize_and_map(vma, src, dst, start, end, private);
-
-	/* Unlock and remap pages */
-	migrate_vma_finalize(&migrate);
-
-	return 0;
-}
-EXPORT_SYMBOL(migrate_vma);
+EXPORT_SYMBOL(migrate_vma_finalize);
 #endif /* defined(MIGRATE_VMA_HELPER) */
-- 
2.20.1

