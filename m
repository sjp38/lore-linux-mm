Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60CABC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 101DD21BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NeD1Drfq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 101DD21BF6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9F856B0266; Wed, 24 Jul 2019 02:53:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A508D8E0003; Wed, 24 Jul 2019 02:53:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 965EF8E0002; Wed, 24 Jul 2019 02:53:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 615B26B0266
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:24 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t18so17688373pgu.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=;
        b=KcjjiKr2g+A3+O3CGm2ocnwS0HL2NH4710p2Jo4AX5xS1h4+UOawvgNZg+mtJmOEjK
         +bqZYsZWEYo9GW3BsqhlxtsY7H7QVw9D0ZabI7zlg7gPU+ObogvXLLwC29zSbnPfMBrM
         2ohPVYMW8fWUuVgNE714tYxxds2jygEJA6qBAnzlULdc1+EQmuKwv7Y29llok2hvesph
         618Hdd0tec+ozTP0XEQv0lZdrK4SEOGmUBKUEdE06oZZjfsUcw02nLuCLR8j8ntdhz2N
         /2Ms6ZkEObTJyrSP1XMxjQDhR+Tdy7MpsxE042XOkQZ2J91qj2tm9U7xdWx7lO7w8u6W
         EOog==
X-Gm-Message-State: APjAAAWjiq9A/E1ZeOYx0IIrUi3la9gjMIZg7fYLFDaXTdm86qx+8SBd
	XQ5eErgCal9fqVKvy42CyqP7rKeJ0kUkQzQbudyHVAIzBAxmeeFrL6mGKbpv0Ckvda3lbzMHXg8
	/aOOgVzXhaq//hTj7svBsL31moU0wVRx/M4MB3b3kMWIWLDBKz0v+/zrRphW9gc0=
X-Received: by 2002:a63:2cd1:: with SMTP id s200mr75962190pgs.10.1563951203947;
        Tue, 23 Jul 2019 23:53:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6B49HpVhh//vAjPYR26DJRZJaeyMbmCwwCt2nXxN/tVmgLoyfj4bxHm1wIHvmRqzzMFz0
X-Received: by 2002:a63:2cd1:: with SMTP id s200mr75962135pgs.10.1563951202880;
        Tue, 23 Jul 2019 23:53:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951202; cv=none;
        d=google.com; s=arc-20160816;
        b=z8fxq5Cr4tfm2Icf8AidFVBGbquaoQBB8dgwXtvO7yNx8LUKxaZA39BbPcjAqn4pFB
         GTTcMrY3dKYzrWXB6gcSoydL2EFy10+V/c//UeH3b4GzIrEqS2zm8ZLdWQTJ1yORPw9x
         +C0tPLnk7xJ0+5Arl8QL3TzRs4Ig1SqVnP9CNujDx7FPdxScqZ/iuyzNh/4wn7897rFS
         VWq7LVLc2eae/rUl5ettEq5b1z68Z3c/ab0O74pCxAdeutAfVdG88TrFMZWTWBzhO9oT
         dm/ik9XRL6W9Ig3EdcfpdZ8g25svhtfJ8Ujf49b1HTAAZpwaT+eLcT5kudCOemCE4crX
         VuXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=;
        b=TCT/CZJY5rlnkTIxmgX//CxDJRhc7PqPpVeZij2n8+BQLVhIpWdpNEsdpdny4FdVik
         LPD3TF3uNnHihh9diEovE+SDSytlC6qqZ8dvebx8S03juWtnFKfN21XgXwgng4G0MrKf
         u43BfpHwKLVCdguIPOvQp0RZ9MBKixoAlEJq6rJfF9CLrv6H02sL3ys3T0pOR/gLQtY/
         soDwzFl4FclR71ISl1V8Yt7/YRnRX0hGbtxr+m5eI7kIqHnQEON0W7bnSSRpb+eAW9hI
         srU0oD9bSvD1rh5mABPMGRClrLeSK5kpNJI2ZkHiHDbHcup8XZFYqxbxqb+dL6IR2Wgu
         999w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NeD1Drfq;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 15si7657871pga.575.2019.07.23.23.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NeD1Drfq;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=; b=NeD1DrfqPt1oy2G0vMdRBaqZGV
	CC4SdQefxYev59DIrDbfQwqxCI+OEzPSDDrmK0L8pVNYjgmpeIX70d26fK/mB9MsKOqyEn2VDh01r
	1KMgsxxNgJSL9hn/k/UbDA8IT6xBQFfGF1EWdzQg0A9GVIfoRS+3uhQ9kyVPg5vA8kyRUw1L622ne
	uxUa6B8lYIRt4QEzX3MKh8nzqEeQmRmKUZpR549QMpaIKCX6KiVwC5VuFF8/rLLxq5LlsbU7LucVV
	YdaemJz96Lh3aCOuT2NNyYezvhJ8HO74amgu3fUNv1Jg/Wz56Fvuf7tI0Ir1iRpDjv1nhHBNj4y81
	pLxwCmKw==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9M-0004LT-GL; Wed, 24 Jul 2019 06:53:21 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 6/7] mm: remove the legacy hmm_pfn_* APIs
Date: Wed, 24 Jul 2019 08:52:57 +0200
Message-Id: <20190724065258.16603-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch the one remaining user in nouveau over to its replacement,
and remove all the wrappers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
 include/linux/hmm.h                    | 34 --------------------------
 2 files changed, 1 insertion(+), 35 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 1333220787a1..345c63cb752a 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -845,7 +845,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 		struct page *page;
 		uint64_t addr;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7ef56dc18050..9f32586684c9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -290,40 +290,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
 		range->flags[HMM_PFN_VALID];
 }
 
-/*
- * Old API:
- * hmm_pfn_to_page()
- * hmm_pfn_to_pfn()
- * hmm_pfn_from_page()
- * hmm_pfn_from_pfn()
- *
- * This are the OLD API please use new API, it is here to avoid cross-tree
- * merge painfullness ie we convert things to new API in stages.
- */
-static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_page(range, pfn);
-}
-
-static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_pfn(range, pfn);
-}
-
-static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
-					 struct page *page)
-{
-	return hmm_device_entry_from_page(range, page);
-}
-
-static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
-					unsigned long pfn)
-{
-	return hmm_device_entry_from_pfn(range, pfn);
-}
-
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
-- 
2.20.1

