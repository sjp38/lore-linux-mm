Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAC31C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 755E12063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e1I2Wme7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 755E12063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB7CB8E001B; Wed, 26 Jun 2019 08:28:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C42368E0005; Wed, 26 Jun 2019 08:28:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A94488E001B; Wed, 26 Jun 2019 08:28:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7248E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so1676520pfk.12
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q+TYvRiX1OhT+BScY8OczmwoERZbakk+9rslWoznBYs=;
        b=hdEgQceODGpubjzf+6+S8EKRwI0QwUGxJ9daiyWADdJBv3bzDN3Z3oGJ6aJAeEqWPg
         ZQMhF/IV8LfzMiip94/qfUeqJApI9ZCcc16BUeP2dkgXIuizzzM2Sqa3J2jk67Nck57C
         fzfCpFoTVQj46diL0kPGWnpRKLhImF8NmBdiElhkEQDFpJeRoKrscOAaaFPZ/qaZMrke
         4+1n+MzOEscNGMeNTP6DxPokSWbC5b3XO66xtZHnCrO3SIcscVLhDNOc0y1DuIelaEs8
         yylgGk5s7Vfg9M8Qkwqqf0yrbkrTnwDyYnRxQxzf0ggDUyyKzXx5mEtbNRvA7rGuOn/c
         r91w==
X-Gm-Message-State: APjAAAUhtQyzvkFDLNGYRcLUacJyJmsmHSwZv+hKOfmge8ZTTGPUW8xd
	FpPaxxzIpeJwkiL8u8cr//V+7bWA6H4H/t1QuLfQ+k2YS7qZy0ulnlX0Bch/trP6WzBIW3oQDxh
	e+MhBUWDgLBfNNg8fKdp2fKIlnaeMNkAIBIxBLNx8BxpuaBYEY29EMQdv0IrqnpY=
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr4415057pjb.10.1561552104056;
        Wed, 26 Jun 2019 05:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXiKkK3dFHmGdXmYI8rlNig9CVbxb6PTUXF3JdKHWykyQXbsriaX1cZDmK3Z+EXCv8aTo1
X-Received: by 2002:a17:90a:37e9:: with SMTP id v96mr4414987pjb.10.1561552103379;
        Wed, 26 Jun 2019 05:28:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552103; cv=none;
        d=google.com; s=arc-20160816;
        b=tiyyIn1wR+Q7rZ7MhLTwRAjbl/vtudJY9dD3t7UceC7mHsbNeanDPLbf24QbU1lMmX
         i0TVsZjdQhbY7R71mCBReQaXWlTOvltE0SHjk0pbqJeLD3uvF6NPfut70AhEpttdYhQz
         xO6LW9Ij8RafghEvTBlfn+xMn6a0ZUuv3cFnOEKcfmQ65NXihrJG/lsCaxNhqTjhrn1b
         bcEDW0nGzQzb5Nybt5JZ/bep2Fnmyg39za7I55aXMePOyaxwgk9l8d51APR3Qc2/X/9n
         3Pe6Uq2gvaRDJxAMLob2bdayildpX7L+ybptg8zOydw7k3BiHmWUrIBZv8ScCpofQ+o5
         5Bfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Q+TYvRiX1OhT+BScY8OczmwoERZbakk+9rslWoznBYs=;
        b=Rpk7zi6btj7gjatMkbcexjPtfP3JqTFt/aL0pCfxmUKHiYjAt/N3fbhGaNUJHR/Cpk
         Z2DGFa4u2XXPEN4IUbhwK8wPtOfhbvri0V6m7NJpoTZ9VMlauLV7SLc/Gtd/JlPPwo3t
         VfzevIJVGfUmGwggO8SQHncCYmMXFGT6xAQNhlSxOCT4ZF8BHzjVI/nE5lSTOHY0mceQ
         xSfNj/bPgCBJTWrLKhgXL0efhUB1nmiy7p3ivQs2Fs7z1DwVyJR85CN1fEUWzFTHodn3
         gUu1gpZ5oD+SOylJuccIyiEQGN5/Vxax5YI8JAiflKT+YvPoo34DkC+1wc9QfW/y0mKL
         kyOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e1I2Wme7;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b92si2019077pjc.17.2019.06.26.05.28.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e1I2Wme7;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Q+TYvRiX1OhT+BScY8OczmwoERZbakk+9rslWoznBYs=; b=e1I2Wme7Ox3SphXo/U291LQsFi
	3MsV4dR6yO4KCQ2FSAu9/N4uNapXRXs4dz5vWPTNn9ZH7fPwZipzQi6fhI8Ahdaljbwgv8TKqjmXy
	iKSKLEl5eN3aNB5BKVY6ZDuPBgqiMxHFj8zu/PfbrJi+Xtpji+RaiGnOKIVP+UaYs1dxMiAc3tNMj
	xepXmBCES099SHbE2RluDL2qHrXXOo3qYkTaXO9Ys5YBarsJezAR4o94rn4r7aSSJiEUq27AMLr7Q
	Sfv5eRswkyXs4C0cmqD2h6WkAQ+t0O12yKFFanMfEUC3M8QOGS50Xyrtpl16hCtphB5Nujt/+/gJl
	+J5cCWZw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg72C-0001bU-3z; Wed, 26 Jun 2019 12:28:20 +0000
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
Subject: [PATCH 20/25] mm: remove hmm_vma_alloc_locked_page
Date: Wed, 26 Jun 2019 14:27:19 +0200
Message-Id: <20190626122724.13313-21-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626122724.13313-1-hch@lst.de>
References: <20190626122724.13313-1-hch@lst.de>
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
index ba19c19e24ed..1d55b7ea2da6 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -587,9 +587,6 @@ static inline void hmm_mm_init(struct mm_struct *mm) {}
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 struct hmm_devmem;
 
-struct page *hmm_vma_alloc_locked_page(struct vm_area_struct *vma,
-				       unsigned long addr);
-
 /*
  * struct hmm_devmem_ops - callback for ZONE_DEVICE memory events
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index e4470462298f..fdbd48771292 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1330,20 +1330,6 @@ EXPORT_SYMBOL(hmm_range_dma_unmap);
 
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
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

