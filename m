Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AB77C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A40F420818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZNuLdRhA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A40F420818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76BD96B000A; Tue,  6 Aug 2019 12:06:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A5796B000C; Tue,  6 Aug 2019 12:06:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 486B66B000D; Tue,  6 Aug 2019 12:06:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F20356B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j22so56133126pfe.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SLYhAoIvzDqEf4YX6gjEiCAIywOZyrNyWp5yd9O/FEc=;
        b=eCTL1t08mAvbawsfjOJdOeIncnoJzkajC5LsqfrhRm6aD+Z7rm4qfHk47/3hbwfk/0
         fWD84NupEyKNOvtLFN5x+DlO3NulMpDK3IKWyd90IsjcrcPytwlsutH+bg00/Bi/eFYb
         pKOmYcOTomeNttyQbInaxzsOEWKRI03Bh+F5+OOtrXJEELKuycmk8SCf026vFTgnYbc/
         R49o1wYFx5qBnfnMnJd37OQGR9Vrn1v3ykEJefqLkUFjlX0aoIe1UtXrDPa+dQ5aAps2
         EyJe515dIuihDykgcrTbjWl+kdCnO/XtKoqGWGAkGljk683SePtQTLDnM45dGapXoRdo
         y4mQ==
X-Gm-Message-State: APjAAAXmkD2YQMyLHR5pJ8+kAIBHDjgI5sJv0YJyEtwJPhgdsuwLUo2M
	d6NoLZKChFaZRYnGem6pDVikmnX11r72sEUaOYObLLXzu4HPnRJ8L52SPkeI/XvrwZKMiSD6EKu
	tNTOf8cFtf2poY/zt7G+wWqLBmPHdp/7ipzLR3M3l37cAHdSXBie3OZcnKzQ+e8g=
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr3933554plp.245.1565107570646;
        Tue, 06 Aug 2019 09:06:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw+DYyP3EHreoFnw9k3rilByTtf48/g6QUu23a7S7DRCegjoHyU6+BgLuOWn6vg7GTyjhb
X-Received: by 2002:a17:902:9a07:: with SMTP id v7mr3933489plp.245.1565107569648;
        Tue, 06 Aug 2019 09:06:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107569; cv=none;
        d=google.com; s=arc-20160816;
        b=l/UUi697bdCSmDlK6Nc/J/i8YrCbYsceAmaZBnc2sWdX3ofAaP4ogzXvMygaatJjxQ
         zIpN3FkcstJ2hWJ8pKmyKQk/vpu/l0DIHCaVuSJgLe90s36WeyfHTQXS5704LiFFKmhS
         xRSNAFfiEyqFtkvE1XYNsVSRaMtxoBmO5R37FqgAQPTgADmIX2rxPOBiZvtCpipjGlnS
         bT2NO+EfkkqbV76qBCfN6cvzCXuruOlBeyiYeBnVBK2zBuN4GBlBcukMwcCHHjNbaKdJ
         F+q3t/XaoYXnNEcPv/5d8mHLScp3ekgwjOobV92cMpSXG3yGVMKOvqjk1XPOtFpVJCQA
         JIkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SLYhAoIvzDqEf4YX6gjEiCAIywOZyrNyWp5yd9O/FEc=;
        b=pwyeWd6Tp5DXKFMUZja8IptiuZzOb1t26muAF11CDdzoOZXcyGEmq3GRkjrxZfGzgs
         7UUs428cJCmE8oEdrkjbUe+53UWMfsBArnndjwSaEWzg1/5lE9dileiic0oQMu8T73BP
         ORIDIFPQ1V2MIDKA3o8hnumwpYpgha+Jg/YCQMUMBoJjMKQwVFnePLBm2PCSaxoSJlzD
         4A+NGpctoUoKLq0r2SoAXm794VBeAlC2NohPtjUwJincMtANwPBveEft3JUJ6eQUZ+Iv
         6fZ+fDaWq2YiVxQqDxQA919NBWmWXFetrx5xZNLekVYJIZaSOhMmnSTEFWz39zled07o
         3b8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZNuLdRhA;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q14si14717750pjp.78.2019.08.06.09.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZNuLdRhA;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=SLYhAoIvzDqEf4YX6gjEiCAIywOZyrNyWp5yd9O/FEc=; b=ZNuLdRhAOMk24S174/yZdDV6qO
	lGDI8hj/2Sp6HzhN6L4ltpD8OkBMyBd8t54sr7xtN/Nm0X9aScPZNYbr6e24CdIcFY0ifRnqbhvSx
	g4e1gGltvFziBE4qSwzZL3Mpsx87iJegFvxi/T6uj3sYDUyXUrnVVrzbxRnMDWlxU6AJLWqgv2JK7
	H7WPXVEgRHKLJLJ2yCGHOBFynfDAy/39Yl1kWt9L1tZOkXaAWNOnFq/1380shWLbJiJpBGFU1D6Dq
	3N6XXfM9pTJqjDNxS7LuY57MTjTKAcw3aS1ggvk+SOq+w5ey5DAXmyTNXS5yU3KC4vdcf/IlskrE4
	GWrBdBhg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yQ-0000XS-IJ; Tue, 06 Aug 2019 16:06:06 +0000
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
Subject: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Date: Tue,  6 Aug 2019 19:05:42 +0300
Message-Id: <20190806160554.14046-5-hch@lst.de>
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

There is only a single place where the pgmap is passed over a function
call, so replace it with local variables in the places where we deal
with the pgmap.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 62 ++++++++++++++++++++++++--------------------------------
 1 file changed, 27 insertions(+), 35 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 9a908902e4cc..d66fa29b42e0 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -278,7 +278,6 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
 
 struct hmm_vma_walk {
 	struct hmm_range	*range;
-	struct dev_pagemap	*pgmap;
 	unsigned long		last;
 	unsigned int		flags;
 };
@@ -475,6 +474,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
+	struct dev_pagemap *pgmap = NULL;
 	unsigned long pfn, npages, i;
 	bool fault, write_fault;
 	uint64_t cpu_flags;
@@ -490,17 +490,14 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 	pfn = pmd_pfn(pmd) + pte_index(addr);
 	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
 		if (pmd_devmap(pmd)) {
-			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
-					      hmm_vma_walk->pgmap);
-			if (unlikely(!hmm_vma_walk->pgmap))
+			pgmap = get_dev_pagemap(pfn, pgmap);
+			if (unlikely(!pgmap))
 				return -EBUSY;
 		}
 		pfns[i] = hmm_device_entry_from_pfn(range, pfn) | cpu_flags;
 	}
-	if (hmm_vma_walk->pgmap) {
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap = NULL;
-	}
+	if (pgmap)
+		put_dev_pagemap(pgmap);
 	hmm_vma_walk->last = end;
 	return 0;
 #else
@@ -520,7 +517,7 @@ static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
 
 static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 			      unsigned long end, pmd_t *pmdp, pte_t *ptep,
-			      uint64_t *pfn)
+			      uint64_t *pfn, struct dev_pagemap **pgmap)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -591,9 +588,8 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		goto fault;
 
 	if (pte_devmap(pte)) {
-		hmm_vma_walk->pgmap = get_dev_pagemap(pte_pfn(pte),
-					      hmm_vma_walk->pgmap);
-		if (unlikely(!hmm_vma_walk->pgmap))
+		*pgmap = get_dev_pagemap(pte_pfn(pte), *pgmap);
+		if (unlikely(!*pgmap))
 			return -EBUSY;
 	} else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte)) {
 		*pfn = range->values[HMM_PFN_SPECIAL];
@@ -604,10 +600,10 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 	return 0;
 
 fault:
-	if (hmm_vma_walk->pgmap) {
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap = NULL;
-	}
+	if (*pgmap)
+		put_dev_pagemap(*pgmap);
+	*pgmap = NULL;
+
 	pte_unmap(ptep);
 	/* Fault any virtual address we were asked to fault */
 	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
@@ -620,6 +616,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
+	struct dev_pagemap *pgmap = NULL;
 	uint64_t *pfns = range->pfns;
 	unsigned long addr = start, i;
 	pte_t *ptep;
@@ -683,23 +680,21 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
 		int r;
 
-		r = hmm_vma_handle_pte(walk, addr, end, pmdp, ptep, &pfns[i]);
+		r = hmm_vma_handle_pte(walk, addr, end, pmdp, ptep, &pfns[i],
+				&pgmap);
 		if (r) {
 			/* hmm_vma_handle_pte() did unmap pte directory */
 			hmm_vma_walk->last = addr;
 			return r;
 		}
 	}
-	if (hmm_vma_walk->pgmap) {
-		/*
-		 * We do put_dev_pagemap() here and not in hmm_vma_handle_pte()
-		 * so that we can leverage get_dev_pagemap() optimization which
-		 * will not re-take a reference on a pgmap if we already have
-		 * one.
-		 */
-		put_dev_pagemap(hmm_vma_walk->pgmap);
-		hmm_vma_walk->pgmap = NULL;
-	}
+	/*
+	 * We do put_dev_pagemap() here and not in hmm_vma_handle_pte() so that
+	 * we can leverage the get_dev_pagemap() optimization which will not
+	 * re-take a reference on a pgmap if we already have one.
+	 */
+	if (pgmap)
+		put_dev_pagemap(pgmap);
 	pte_unmap(ptep - 1);
 
 	hmm_vma_walk->last = addr;
@@ -714,6 +709,7 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	unsigned long addr = start, next;
+	struct dev_pagemap *pgmap = NULL;
 	pmd_t *pmdp;
 	pud_t pud;
 	int ret;
@@ -744,17 +740,14 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 
 		pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 		for (i = 0; i < npages; ++i, ++pfn) {
-			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
-					      hmm_vma_walk->pgmap);
-			if (unlikely(!hmm_vma_walk->pgmap))
+			pgmap = get_dev_pagemap(pfn, pgmap);
+			if (unlikely(!pgmap))
 				return -EBUSY;
 			pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
 				  cpu_flags;
 		}
-		if (hmm_vma_walk->pgmap) {
-			put_dev_pagemap(hmm_vma_walk->pgmap);
-			hmm_vma_walk->pgmap = NULL;
-		}
+		if (pgmap)
+			put_dev_pagemap(pgmap);
 		hmm_vma_walk->last = end;
 		return 0;
 	}
@@ -1002,7 +995,6 @@ long hmm_range_fault(struct hmm_range *range, unsigned int flags)
 			return -EPERM;
 		}
 
-		hmm_vma_walk.pgmap = NULL;
 		hmm_vma_walk.last = start;
 		hmm_vma_walk.flags = flags;
 		hmm_vma_walk.range = range;
-- 
2.20.1

