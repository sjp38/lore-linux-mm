Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2ADAC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CF9520818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MUB+vxB5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CF9520818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B4496B000E; Tue,  6 Aug 2019 12:06:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0159F6B0010; Tue,  6 Aug 2019 12:06:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D83F16B0266; Tue,  6 Aug 2019 12:06:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3E06B000E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so56188919pfz.10
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q9JVQd7TJgJOaVqaurRsAZJZ/a1e9OVXXKhPpucQrUU=;
        b=Nt2iU0MDfDXZpTJiqMwUBGHCmcVRuhfJCrhDe+KMT5XRY2kWDG5AxatvodNcPu7ZAJ
         l0hp9W/LShQ2790Qn5OZe8TVeOH/KJCpsk3JVRIKBWHZnrACJGbdYW9EGjCddOmXHV1A
         pP6fQaAJ+nWREX3FC0/VCaW5d31P54KeVXJ5TWbh74g4hUwNmJyz53tG9/jxM9mrDI5c
         MEWzQyu/uFGjzioqYh0lKw6/cgePoz3P1r8+hj3B90ZKNGyHtl/7FmXn/vp4shLAsV+E
         jB/Ym64IGTD1bxiuOC7iHotrPSSdS+QOj67XR7y4Ue0lwj9Ksebr/CeP461x87b7+dPq
         jxGQ==
X-Gm-Message-State: APjAAAUSOA3GTyuULF4xP9PkniM+hgNSGzKUnuZOK95L8Fpffx1fQJ1F
	fnwYXILIHePcOzKNc9o1vwSInz7l/fL57ayxiMmgH/U0MugaIoiOh0elvcOVl6soD2wpi8I06VL
	1U40Z3s+yn4mIjp/haRBaJgDryJmA+PI+xcCFJMx8OYol/KtPyJlntJ/zxTG8rqQ=
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr3954555pls.267.1565107579211;
        Tue, 06 Aug 2019 09:06:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJY84jSwBRVzEChCiRnQsG+zZKLLtECZCof4RYKxdSb2Qdjhx1HIzGGG/5mDwMlN17Sa+y
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr3954412pls.267.1565107577531;
        Tue, 06 Aug 2019 09:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107577; cv=none;
        d=google.com; s=arc-20160816;
        b=w0WY2jOFHB+qcMMqtE1uQrclo1uydvKHvoixUwl7S+A+DZlZVNqI4Hldr1EkNqnt9V
         08OwnoMGQUTF4iLJpjmqpy7wMO9yTpWKqOKs8RzulTeTG2zLsHzLmIniibjU/UW89qZI
         vF7HX5+losi1T4EplWqWWb6qLl4FKt1vHjFytHu7kJgJcWhNctK/mo56TV3g6f2Wf9iX
         QNy1u0p94XPTvkafIEKGXUmgjzT1nDfANyWewFNfdddEfVkjtA388kb5Od4Pj9s+ltpI
         gLSoZyl7921MRKm+Est7PhFEMXQwLRYtIdoCj28Cfv1kDprcin+J6ntymdKvYqn93ww8
         +apA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Q9JVQd7TJgJOaVqaurRsAZJZ/a1e9OVXXKhPpucQrUU=;
        b=Gg6rb7tgxlNj3bBzCt4YPVTIVCNSuvMTIK2ZhdVQVsBmKIDNcFimpUkKQc/tdvx3ZW
         QddvMXGtXmyQYx/S4QL33xg5uvIlWpMGm68LUiUkP8QIOTNXrGKMyBXqLSzmjn3Rn3kR
         WyfG+Uw7knL3iGdpEzaq07IkTbUA1DaLAAaq66CgsfgXxtwmep/I4blD5nnAnFmFVilI
         3XbMfs8JV9uV3Am/YNgmBH/OuEK7v6v6jx9Q/a/+x61qWER9c7To93v8AtUCWPfP3EQe
         /9h5tiMUJ71mb7c1DuyN7f7Ry8QzsxQ4v9k+JGb8ZmpagGKrG3Lsr9/QZWTM0msr6GGs
         VAqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MUB+vxB5;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d1si42643375pla.75.2019.08.06.09.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MUB+vxB5;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Q9JVQd7TJgJOaVqaurRsAZJZ/a1e9OVXXKhPpucQrUU=; b=MUB+vxB5rP4ER3qjacjm5Pc9YP
	3rAbr813U0gZg9RKoi/v6hUQNTqTGuX2TKWFEsWPO2TzaiCevtIz8l3d9wFFfuVazPHbL4Q7e3/V7
	297l7eXFcTe1sz/yBPuXzv3RlMt4n22/OHc3vCQp/7VMF48E3Fa0iWiBY0lbRVYM+hpUv8UAxCNJG
	nyFiAT9g8ZXX7m01dK89ZkBAMY31IThBAc5yPgsvVZTgPBBqOroW6dAYgn51tTUBJSlbkLe3o6Jnu
	gbVCcpEJ8Iwmt/ac+R1QY9t3e2kTHFs8ljzE8q6wgdh4Wr+DcSGIhSXm/BTvvok7Sm1Dl9CrS/CR+
	iv/kqmIQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yY-0000ZU-88; Tue, 06 Aug 2019 16:06:14 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/15] mm: remove the page_shift member from struct hmm_range
Date: Tue,  6 Aug 2019 19:05:45 +0300
Message-Id: <20190806160554.14046-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All users pass PAGE_SIZE here, and if we wanted to support single
entries for huge pages we should really just add a HMM_FAULT_HUGEPAGE
flag instead that uses the huge page size instead of having the
caller calculate that size once, just for the hmm code to verify it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c |  1 -
 drivers/gpu/drm/nouveau/nouveau_svm.c   |  1 -
 include/linux/hmm.h                     | 22 -------------
 mm/hmm.c                                | 42 ++++++-------------------
 4 files changed, 9 insertions(+), 57 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 71d6e7087b0b..8bf79288c4e2 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -818,7 +818,6 @@ int amdgpu_ttm_tt_get_user_pages(struct amdgpu_bo *bo, struct page **pages)
 				0 : range->flags[HMM_PFN_WRITE];
 	range->pfn_flags_mask = 0;
 	range->pfns = pfns;
-	range->page_shift = PAGE_SHIFT;
 	range->start = start;
 	range->end = start + ttm->num_pages * PAGE_SIZE;
 
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 41fad4719ac6..668d4bd0c118 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -680,7 +680,6 @@ nouveau_svm_fault(struct nvif_notify *notify)
 			 args.i.p.addr + args.i.p.size, fn - fi);
 
 		/* Have HMM fault pages within the fault window to the GPU. */
-		range.page_shift = PAGE_SHIFT;
 		range.start = args.i.p.addr;
 		range.end = args.i.p.addr + args.i.p.size;
 		range.pfns = args.phys;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index c5b51376b453..51e18fbb8953 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -158,7 +158,6 @@ enum hmm_pfn_value_e {
  * @values: pfn value for some special case (none, special, error, ...)
  * @default_flags: default flags for the range (write, read, ... see hmm doc)
  * @pfn_flags_mask: allows to mask pfn flags so that only default_flags matter
- * @page_shift: device virtual address shift value (should be >= PAGE_SHIFT)
  * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
  * @valid: pfns array did not change since it has been fill by an HMM function
  */
@@ -172,31 +171,10 @@ struct hmm_range {
 	const uint64_t		*values;
 	uint64_t		default_flags;
 	uint64_t		pfn_flags_mask;
-	uint8_t			page_shift;
 	uint8_t			pfn_shift;
 	bool			valid;
 };
 
-/*
- * hmm_range_page_shift() - return the page shift for the range
- * @range: range being queried
- * Return: page shift (page size = 1 << page shift) for the range
- */
-static inline unsigned hmm_range_page_shift(const struct hmm_range *range)
-{
-	return range->page_shift;
-}
-
-/*
- * hmm_range_page_size() - return the page size for the range
- * @range: range being queried
- * Return: page size for the range in bytes
- */
-static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
-{
-	return 1UL << hmm_range_page_shift(range);
-}
-
 /*
  * hmm_range_wait_until_valid() - wait for range to be valid
  * @range: range affected by invalidation to wait on
diff --git a/mm/hmm.c b/mm/hmm.c
index 926735a3aef9..f26d6abc4ed2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -344,13 +344,12 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	uint64_t *pfns = range->pfns;
-	unsigned long i, page_size;
+	unsigned long i;
 
 	hmm_vma_walk->last = addr;
-	page_size = hmm_range_page_size(range);
-	i = (addr - range->start) >> range->page_shift;
+	i = (addr - range->start) >> PAGE_SHIFT;
 
-	for (; addr < end; addr += page_size, i++) {
+	for (; addr < end; addr += PAGE_SIZE, i++) {
 		pfns[i] = range->values[HMM_PFN_NONE];
 		if (fault || write_fault) {
 			int ret;
@@ -772,7 +771,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
-	unsigned long addr = start, i, pfn, mask, size, pfn_inc;
+	unsigned long addr = start, i, pfn, mask;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
@@ -783,24 +782,12 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 	pte_t entry;
 	int ret = 0;
 
-	size = huge_page_size(h);
-	mask = size - 1;
-	if (range->page_shift != PAGE_SHIFT) {
-		/* Make sure we are looking at a full page. */
-		if (start & mask)
-			return -EINVAL;
-		if (end < (start + size))
-			return -EINVAL;
-		pfn_inc = size >> PAGE_SHIFT;
-	} else {
-		pfn_inc = 1;
-		size = PAGE_SIZE;
-	}
+	mask = huge_page_size(h) - 1;
 
 	ptl = huge_pte_lock(hstate_vma(vma), walk->mm, pte);
 	entry = huge_ptep_get(pte);
 
-	i = (start - range->start) >> range->page_shift;
+	i = (start - range->start) >> PAGE_SHIFT;
 	orig_pfn = range->pfns[i];
 	range->pfns[i] = range->values[HMM_PFN_NONE];
 	cpu_flags = pte_to_hmm_pfn_flags(range, entry);
@@ -812,8 +799,8 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 		goto unlock;
 	}
 
-	pfn = pte_pfn(entry) + ((start & mask) >> range->page_shift);
-	for (; addr < end; addr += size, i++, pfn += pfn_inc)
+	pfn = pte_pfn(entry) + ((start & mask) >> PAGE_SHIFT);
+	for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
 		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
 				 cpu_flags;
 	hmm_vma_walk->last = end;
@@ -850,14 +837,13 @@ static void hmm_pfns_clear(struct hmm_range *range,
  */
 int hmm_range_register(struct hmm_range *range, struct hmm_mirror *mirror)
 {
-	unsigned long mask = ((1UL << range->page_shift) - 1UL);
 	struct hmm *hmm = mirror->hmm;
 	unsigned long flags;
 
 	range->valid = false;
 	range->hmm = NULL;
 
-	if ((range->start & mask) || (range->end & mask))
+	if ((range->start & (PAGE_SIZE - 1)) || (range->end & (PAGE_SIZE - 1)))
 		return -EINVAL;
 	if (range->start >= range->end)
 		return -EINVAL;
@@ -964,16 +950,6 @@ long hmm_range_fault(struct hmm_range *range, unsigned int flags)
 		if (vma == NULL || (vma->vm_flags & device_vma))
 			return -EFAULT;
 
-		if (is_vm_hugetlb_page(vma)) {
-			if (huge_page_shift(hstate_vma(vma)) !=
-			    range->page_shift &&
-			    range->page_shift != PAGE_SHIFT)
-				return -EINVAL;
-		} else {
-			if (range->page_shift != PAGE_SHIFT)
-				return -EINVAL;
-		}
-
 		if (!(vma->vm_flags & VM_READ)) {
 			/*
 			 * If vma do not allow read access, then assume that it
-- 
2.20.1

