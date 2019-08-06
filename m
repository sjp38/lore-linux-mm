Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F1EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BEA420679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="l2Q5OzCq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BEA420679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C3E86B0269; Tue,  6 Aug 2019 12:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34B956B026A; Tue,  6 Aug 2019 12:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA5A6B026B; Tue,  6 Aug 2019 12:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB3876B0269
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y66so56174427pfb.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ip6Tv7CH1RUCf1zdL/7YnuvbR835Efr9iJJdAFn2xCE=;
        b=HQlQJuX/0MGXCqMZHWqaX35lrVEd55+FnX8dPWdj182ntG0Bvd3AHK1NytLk0bv+ik
         +v4TlQoKARsCCbA+Sytg73jpeUZ1cHTXI1kVKh0dY3H4tzKzkmZzm9LD1l8JQYQCfnrh
         I8TD3b+U+bF2GpZythEmucfdrndSl5aNoGP63t7gssIxijHvqYUZD3GmyXm0kE/b0VAE
         jbPHWBTWTXfEzxBRadYBBeFhdRIhQnU1Y2QTuopiqMpRe5MdgxOJyfrQ230Zzr6LD4d0
         4lz9sx07Esy3VColfDsJh2wdagXKuY58AQJbnlAOMa5QQ02v5OfU7SMHK2MQXXnAgTrl
         G2Zw==
X-Gm-Message-State: APjAAAUPrvsz+/hQYgGykLGB2axSI8Y2Dh1QkcLF/DTfEOGfoBpNXSp5
	lrGi4T36sXNagyOh/8yNeir/KeP9J5OUaB5rj0xOd/1Q5AmfqTkfj35yNj+Q8aler/PTGupk2PA
	T48iokD6LrOfkJn0E7qc221uHVeXuxoEavpbl0AHdXnLuPpo2AEq7kXv25tFO7Fo=
X-Received: by 2002:aa7:98da:: with SMTP id e26mr4462368pfm.34.1565107587573;
        Tue, 06 Aug 2019 09:06:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp7+zO00ME6DkpiC6SPRVU9CiCgIelda0BRHOeWnz2KIY7hUMnKykU7c51o1ynJEPO4jQG
X-Received: by 2002:aa7:98da:: with SMTP id e26mr4462294pfm.34.1565107586824;
        Tue, 06 Aug 2019 09:06:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107586; cv=none;
        d=google.com; s=arc-20160816;
        b=edNYO97A0u3ctVfmyQtUSlduph/G8HWmCtwaKvbdfDuiDmpEb0ctXyxRudBbg0MFLV
         3S04+MNphTxEfYh7ioYnyAx2Zv41qHqHAXSzAseuaiYF3aTLsc/x+gwqXRV5JFW7yoxY
         FVvA8p1bYum0qqJ/kPSQUTqY0A7tUbjOFnfCiGsHkeutTXBYtspqy68ofgqWda/iWXHL
         0ie5ZNPfevneRFkF2AbRaNKZprOt6A693byclEBOzQpriQZu4y3pmkK9UXsZbKvlPn+D
         rIGi2N8NkggysawxIOSpCPoKkqyG3WXkFYarwnRU95J/1MoQocnr8KF2h2HSIWFzBy+U
         SPWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ip6Tv7CH1RUCf1zdL/7YnuvbR835Efr9iJJdAFn2xCE=;
        b=PoRn+ab8pzg0bX47UnaUxHK+yJMex5sy9Hz3h51Y9aQZccOMfakAW4JLhrXSPvwToh
         5xzYqhrwmwYFLJTPwEgWXyUPG0Devl2Ae5t3kJGES1ARjWkmDaKbj7qBrVztkzC1M1Vl
         hptoRQUl/L+uJgTvJkL6wmsupPfMakNn/uROx1VIXXwmWPUXjQRLuIGwx2cpKsoWslSD
         a0Y6DvK5s9ofjstPYpHfF+EvPqlJfMquXjSGYEfi1FpyrTZpXHfeIa17nbmqr7GFm+qj
         jbmrn+lljEb/z9ZebmuVBhEWD5fdu+jL4H//bPxec3/NWuR9aA2mt576jYRx/aUKPAFL
         c8FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=l2Q5OzCq;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i188si46962709pfe.96.2019.08.06.09.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=l2Q5OzCq;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Ip6Tv7CH1RUCf1zdL/7YnuvbR835Efr9iJJdAFn2xCE=; b=l2Q5OzCqYI6K/lwIUdGM/lRV7A
	orDsZpzbT6FSVlceE/hay+znMxbpWMtaDTBHblMXvxERMhczytc2vd81s6BqxCZFw2V+kIC1ehQpp
	k+Rn3H0gbs9x8Wd69M+u5RHtmAxHu33R+eq8t9FPKY41OyzLqR46OnL/3/uJyFvCu0wrsi53OR/mu
	7/mdjcwkmKnzaKrkH5ypk1OTp+rOzbLBQZmdtU0MQuKonn5rYEozOJUnEkPDgPRfYRrrv/ltW03W1
	B3GGyVUnYhFnzA1DZM9OJMMvOYQnSvrnyNNF7TcG618gJsqAjt8SdYkE4ny8fMR5VMnJN6+ThYxIg
	Uq/3HCWw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yf-0000bo-Tk; Tue, 06 Aug 2019 16:06:22 +0000
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
Subject: [PATCH 10/15] mm: only define hmm_vma_walk_pud if needed
Date: Tue,  6 Aug 2019 19:05:48 +0300
Message-Id: <20190806160554.14046-11-hch@lst.de>
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

We only need the special pud_entry walker if PUD-sized hugepages and
pte mappings are supported, else the common pagewalk code will take
care of the iteration.  Not implementing this callback reduced the
amount of code compiled for non-x86 platforms, and also fixes compile
failures with other architectures when helpers like pud_pfn are not
implemented.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 2083e4db46f5..5e7afe685213 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -455,15 +455,6 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 				range->flags[HMM_PFN_VALID];
 }
 
-static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
-{
-	if (!pud_present(pud))
-		return 0;
-	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
-				range->flags[HMM_PFN_WRITE] :
-				range->flags[HMM_PFN_VALID];
-}
-
 static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      unsigned long addr,
 			      unsigned long end,
@@ -700,10 +691,19 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
-static int hmm_vma_walk_pud(pud_t *pudp,
-			    unsigned long start,
-			    unsigned long end,
-			    struct mm_walk *walk)
+#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && \
+    defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
+static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
+{
+	if (!pud_present(pud))
+		return 0;
+	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
+				range->flags[HMM_PFN_WRITE] :
+				range->flags[HMM_PFN_VALID];
+}
+
+static int hmm_vma_walk_pud(pud_t *pudp, unsigned long start, unsigned long end,
+		struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -765,6 +765,9 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 
 	return 0;
 }
+#else
+#define hmm_vma_walk_pud	NULL
+#endif
 
 static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      unsigned long start, unsigned long end,
-- 
2.20.1

