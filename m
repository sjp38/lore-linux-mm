Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DC71C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28F0020657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oLig9/TE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28F0020657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5101E8E0016; Mon, 17 Jun 2019 08:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EA8D8E000B; Mon, 17 Jun 2019 08:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33AC88E0016; Mon, 17 Jun 2019 08:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F11388E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u21so6961509pfn.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rfiOsXsxRAZCFDVo21abTS19/9zGASI6nRdrjMvZ5Iw=;
        b=r/9U07BOMINXczGGs4S3462isyzzGKsxXw0idrnk/IIhaxzzhy09pnpIQ80fmGg5t3
         16OdHGD5kqMoeEktlQf7wuZYDxr5hExudt5XBncfkaeotq51eKvJn5gdmPmxuJC1c7ju
         R7Ye2sBtdzBv2PPvHdME2EWXBziHe3juVmx/pA92lbIfK0Fl+7RJR1L1TWVREihgAhB8
         mHbJaSh4JBATpoaGqtR61G/29RflHJU2K9NJpHsklaIALgW19PQ+JEWo3TFx/i5A8tns
         UBWgf7GHLE7wKTanTnY1TlVtjrTlO6Qi783+TW7sns4jFqzAPYdsDvjtejAQU7Yi1xl2
         oNNA==
X-Gm-Message-State: APjAAAUUWUyac7r6Zv6bbIHq/L1VlDd5KV8uxCqE1TO75eb1CxXj7tzN
	KrrBitMZFjJtRHfzctr1RrkEjrbrzLq/KejaHJvSSa3neeZ+diYYeWYjcTl39SFQt7VoANYVzoJ
	saoqQyd96seSobQVb6J83fU2k/v/+gK0DziMIDc/+cDoduiOJFhmwE507SY46M34=
X-Received: by 2002:a63:fc15:: with SMTP id j21mr9605408pgi.217.1560774504578;
        Mon, 17 Jun 2019 05:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0ihKrPyURP9aQyYEa8VLnFHn8jLFe+9OLkBhER2Vo2dvpZHtSCVRUnmKKJfQwGplruYA3
X-Received: by 2002:a63:fc15:: with SMTP id j21mr9605373pgi.217.1560774503645;
        Mon, 17 Jun 2019 05:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774503; cv=none;
        d=google.com; s=arc-20160816;
        b=upTibT9PZeJWIBuxufmFewsI7SFqgX/dZ0dYul7Vi61sn9cG6R6Y5wzrU+eZytsrJD
         7o0LCqXrESQP1+zMl9rdAkU6Ph+2Xb9n7mKyiXbPffvA0Zz3qzegzwSKNZZstczCaw8l
         tZVWNngokKuBTSdp3KwWj4m7gRW9X+6hnH2CjyJyrPsqAN5DlkFqJkSgQHFqJEpmzQL8
         8lTjXEvZrSL10OrCkPluVitDK2D4h/Pv1VVgGezO42QY9IiKiYFaqieTeQDrtvcrYcC5
         8Tzn0uSawyRIuY2Lgo6hmxJ3lKU7YWnk3PRTT9SxbdPrrdnX8WF1l781LahM+ZVq9A7J
         2pKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rfiOsXsxRAZCFDVo21abTS19/9zGASI6nRdrjMvZ5Iw=;
        b=RN3BB6qN/oLMl7Rd6jMazMwMED07ZKzXu0V3zRA0FbSwcZsGEgHP36jNPjzejeyKrN
         QGn+6wgs+3+D8CIKWtcRYtpaoKzCWVl4yvh8FSenVIVN67Gv3sQpjwl9Yvm/wHL3udF2
         4uNdF3Ety+B9HgOir0QUBiMeHY77l+fAUuLWoJ+3Y/ZqQ8qso+xgByj/tRvNgo36JGMx
         rgwMhpjynxDl0pUwh8vNrb6rL670tQhiXjrrPcqVaQf5l52LvHtE3Vsi0ZHIvj7sBaYz
         7doo3b9MfY7X7B8LrzFNsdv0hFt3J3nRLu6IYAri/kuAe8LNkglbWkdlG4wkfw0T1uBy
         tz1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="oLig9/TE";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h2si10899109plh.380.2019.06.17.05.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="oLig9/TE";
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rfiOsXsxRAZCFDVo21abTS19/9zGASI6nRdrjMvZ5Iw=; b=oLig9/TEaZEXPR+t7+dEa5tPGZ
	RpcPa/hgJAoKo4WO6XIcMV1sCs82yI/lf9OjzRWEj+XFibg0CgidALCirzn9I/Ux8nEqBtGYl0Qhp
	UjkLcxgYpbFIOCt2hu8a+nzyW05x/LYTS/62NJNSg1oHibCDD2QPN0COJRNN2zrq9SkAjfzaA6Lr+
	zYAG9oM+7PFTegy2bOQY0pdWVMTOTKk33rjMgeztaj1iyS1JvSCd/oKCL5f0rojkYJR/4cRDYuLKc
	J4VWWF9tGqI6teBCMBGayYjyd6VOGU6+ryOE8y398cTseQsF6pbV13QaK/gGJKuNaKx6HgHODXtXL
	AcMMPXXQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkF-0000KX-9f; Mon, 17 Jun 2019 12:28:19 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 19/25] mm: remove hmm_vma_alloc_locked_page
Date: Mon, 17 Jun 2019 14:27:27 +0200
Message-Id: <20190617122733.22432-20-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The only user of it has just been removed, and there wasn't really any need
to wrap a basic memory allocator to start with.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/hmm.h |  3 ---
 mm/hmm.c            | 14 --------------
 2 files changed, 17 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e64824334b85..89571e8d9c63 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -589,9 +589,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
 struct hmm_devmem;
 
-struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
-				       unsigned long addr);
-
 /*
  * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index 307c12d7531c..0ef1a1921afb 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1327,20 +1327,6 @@ EXPORT_SYMBOL(hmm_range_dma_unmap);
 
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
-struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
-				       unsigned long addr)
-{
-	struct page *page;
-
-	page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
-	if (!page)
-		return NULL;
-	lock_page(page);
-	return page;
-}
-EXPORT_SYMBOL(hmm_vma_alloc_locked_page);
-
-
 static void hmm_devmem_ref_release(struct percpu_ref *ref)
 {
 	struct hmm_devmem *devmem;
-- 
2.20.1

