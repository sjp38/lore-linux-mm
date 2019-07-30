Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BF58C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 404E92087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PwwV1uMv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 404E92087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46A708E000C; Tue, 30 Jul 2019 01:52:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41BA58E0003; Tue, 30 Jul 2019 01:52:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 309068E000C; Tue, 30 Jul 2019 01:52:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E778E8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y22so34629079plr.20
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b/9edj6OiWVlv3WVS80N1fYDkV0WF2l+sPw3a4dWbfc=;
        b=ELmOQdk0bz1tM8O1cmExKAVVT402fenrsYg5+HA0CsWqsv7Zg+O6XgGniQcm2yRiov
         DS9GCASlbDZSRGhQfu1cMP1Ybo576vGBdooYfHbL+mEWDEn7alaGcuK4iOMbiiultAWI
         MOp2uX+hx0ZRryYjVc1WX1rko4LbJDqI3Y9spEw9H3EgEg++TulFbnc5iJeckLK3dQ3G
         Gi9xgOHLThF7xSvLJaWAdBfQSUYyyDKxA6IBkzCV5QvU9xlprSnP/lSZdteN4PiGvr3U
         k8M5xfMRcCpmH1wvkODZzLkCYOA+tyoEFl4kOREdGaKtc3c2N5WHffrkREP86V6oDSpy
         11IQ==
X-Gm-Message-State: APjAAAU4wJevYbQYNGQUdYQyv2wAngxR+j1gttH9fzOb/lCEZnXpfkOh
	73yrb7bPx6X9o6/q8DI2lu+qpP2abWgZSgQ9GhAPHEJ5pma+VPnUXnB6S00qCxDP2C+BnEtw47W
	xUMsLId/H7Vab4bO8GVYpZM+v/WZGegWsXOs8m7SXc0Al/Tb8A0FAJUyM4kIyLjE=
X-Received: by 2002:a17:90a:8a0b:: with SMTP id w11mr114774558pjn.125.1564465960586;
        Mon, 29 Jul 2019 22:52:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhFNV2HVZDyyloEysCFl1W88tCq1PIK1xUlGmcD2S5s4BF061V0/rYmTLSXISQTvnGR3iw
X-Received: by 2002:a17:90a:8a0b:: with SMTP id w11mr114774503pjn.125.1564465959160;
        Mon, 29 Jul 2019 22:52:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465959; cv=none;
        d=google.com; s=arc-20160816;
        b=WDcALmaHWEq9iLAjNSsmLr5NmahYSgu+Uj89tHFwsFi71JDzuXDbJmqzYUekfosrn/
         Ix5M4bKNKHohz+mhvBX2f38HgpNyps/fNC+EIT/CCOXVpWzPHyopvi1YVnsO24hr3Nr4
         scxC2eNO2T8Kw2FV/BlNFly7kax0Eu2kbnh3AUtXdBp8BQcyLWm0eOcHmm8i9klqtjl5
         HMPeM0VViaUbOJwqdJxOQkknglGjKegaZ3UX23jJKxsykcx/0RyEEUz2LUADCSdIiJIm
         BjYSLS5jprjvcyeeA8sg4VGZv75pHtrcYTnK8mrCnnndF0BsAFeBx0BO07Bu5XrehvTr
         M4rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=b/9edj6OiWVlv3WVS80N1fYDkV0WF2l+sPw3a4dWbfc=;
        b=FFH7nxpvnb+CouIb9HGhm/vSR2mjh9vOa+L5sLwpl9090Yep9QzGf0Kc5RqZT9dhCQ
         Sv5E09wIMKhITIFilhOcs7aiOqyWRRf5tGoP8q5ahbhsCaXKh74/uaAx7J0Tjnor/KoP
         r/m1vDhxHtUWnX+ysBOTDWXZvopw4JRRfBSq7e6TRmjfJbPcAMQes21Spct2ssLTB4Yo
         DAQ60b1t5ee/URpBSvXaFQLbcGOGUHSI6vMkqJndmGqZYyX6KIutqoORCBRNL23mtbKf
         JH7YFiQswJ5ULFv1HBimtztEOMVFKENjxDR8lWyYQpuDO9YXkDX62hYAUHBNj8p8n+vU
         /S5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PwwV1uMv;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w12si29460467pgs.364.2019.07.29.22.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PwwV1uMv;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=b/9edj6OiWVlv3WVS80N1fYDkV0WF2l+sPw3a4dWbfc=; b=PwwV1uMvlDTXpPMRUViyPmLA2/
	KJsCq+/JAnSamHewYk0gwqaFOPbXwmsNCa2YJoj20TrOwbiu2CkUo9kffkHl7l9A0DZBCXiXZmvAw
	iadlnyzca9yIJdOResfC3lkn4ew1r36r6S76Y7jp0faIKHtyrxyzEHZ9ZBgLxuhJK7GmkdHLnqf0M
	SYysK8E8UKfghD8G7ENuOr/r5Lec21/Og/wNdau5FEW3XUL3VsSpKcCo5h7ZN4dL704rvxk9Guetm
	mdGAHO9k3kia0714GeokE/q5sdBs2Z7cRgkPK2NMyZpZdfZyI7e2iZieUJUgn6jmWmhyaaO7SNAm7
	P+AUia3g==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3r-0001JT-2V; Tue, 30 Jul 2019 05:52:35 +0000
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
Subject: [PATCH 07/13] mm: remove the page_shift member from struct hmm_range
Date: Tue, 30 Jul 2019 08:51:57 +0300
Message-Id: <20190730055203.28467-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
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
index 40e706234554..e7068ce46949 100644
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

