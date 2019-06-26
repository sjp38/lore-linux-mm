Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530B7C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 182A420B1F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qt1wzdpe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 182A420B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983F38E0006; Wed, 26 Jun 2019 08:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90CF98E0005; Wed, 26 Jun 2019 08:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FEC8E0006; Wed, 26 Jun 2019 08:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 387848E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id p14so1374248plq.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=;
        b=QG86Gl5gjTkDcVd0KCiaK4D2j85y6OTuL+IQQv8I36qV6wh8yCkNVrL8vXEiFEKBcT
         Jk2xU2MFszdBaANOIGzRaUvg7VxtEuIP1wBXuHd84dHHd5q9NeiZon2oKAc7QEcfHv93
         iKVFOvDEILHT7FdbFiOHCCOOxHE9y25fKvXG8HXxcxrwglSp4su84Hl1uKvZuoZO713U
         w9mc4CYqnA+foLK+EIND42mV8JGgpDiU4ncUYE10Jbuq9jHPrOcTKGiUVUrBTrdj+LFs
         Y9BxOq1mzP3VVLZdBFIwAIVsItzZ/fCZcW3uBI8jv0jRmuqHAOynlARtFF0K/4M/swRw
         8u/g==
X-Gm-Message-State: APjAAAVOwWElTj9Lre8bPXtdwJiYa4TGRmpNUhFfhQ0DPF7mjsRqfffA
	j3q4n94KsDDDAfx8J9D+dusinIDwEyzTDYietcGJeFvo0GdWTjY53brqyTC99Ot+qKAevMpYso7
	eVnw2ZJp/4BzUqdBzvagVFBkJMh4n1i/gKEfe6w+xOyv4P7kIZIc7uq9lrB0SXhM=
X-Received: by 2002:a17:90a:21ac:: with SMTP id q41mr4524156pjc.31.1561552098908;
        Wed, 26 Jun 2019 05:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM8MvUkETI66ssnqn3Zbiqv9VlJgEM94UvuWEbfDVvLTyismajP6JOZFhBFUBmYh3X9tkm
X-Received: by 2002:a17:90a:21ac:: with SMTP id q41mr4524090pjc.31.1561552098281;
        Wed, 26 Jun 2019 05:28:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552098; cv=none;
        d=google.com; s=arc-20160816;
        b=OctmhIqGGOt+LZsXZMUtNcwEk/yqhGk3ij/wzlDNY3D38g7Wq5Kz7JurbLn3XZ/EEw
         9uQNYghbuthzB3rNVnvXaxo6XAv8EAr4W0x57ESjmijQjaAmvgiKFxbb1utBjggK7vp+
         KxwbejGyUs1+/bAfcI44pVLAs2GFaYgwikQ2TJB1b4KGZwOr2+YZBwL0WnwBSY+An7/d
         J1aykTwMRfk/19fANn8HujJQrIGrtWPEodmqFGEXDQDyZa2BB47l13wIPeucTmoeHG48
         Mzup9IMXGLSssq3fk2aOYkefzkJy23rbPylj9L6UdzL9okqLZ8k/OgfODd79+myxX6k9
         pg/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=;
        b=iEeGd7PICx3YrN9DkEe+jwK1utl5ybJfJTD1RZHuoyLgXpHK4aUjSzVJWhgdB4cPtP
         VfZTtlc9ZtsF6NRkuuvcVTOSG+SYZRpmR8i/jNnOjH4cSO5S404k3DVN6Z2fcV7RcZ7e
         9dOFJj9PK/rX4deiBVPfUN92hZof28SVSMbOqfEFxIE4waMHgk/l/+PtLc7FCZRTOflZ
         KearFkER7bwMW2dTHNdv106a59cLyR2LlCdndLs9psc51cjQSXS5g9OFBn1lgYsOWyQL
         jdkL2ouuhZAzmkzpY5t27yW1z+BjirL7/9yjHm2k31S/6GN0v5Yysr4besuaY2jnHc0o
         RnoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qt1wzdpe;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j4si15889591pgh.209.2019.06.26.05.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qt1wzdpe;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=; b=qt1wzdpeXOioJoeLjcBGzBBVU/
	Sr6D01p4bOPlfFv7A/XbcaGQsl1IH01GeMcCCke5SJh7+fpyw5+rIKzgn9byxwe1kgVAu1j/h7ROQ
	4lvA5eeeukgmWSeBeKgEDuEBjjwRhGPDC9AIWQm+7dOYdaQhTinbVKVEskkE0Io3IDHriXiis+aB9
	8mEJ/G0aXx04YeP8uuuRQuTeOrRGeFyVQ4Rx8U+Noyv62xRv450IEmFtFO+E+MvzvI1V277cC6Z8i
	R9Dvb48L9i++e+EKM3J8sWleQK00iEHpItPQXvfVhC/OdM0WIglOrdTN/KRiePoYY842rwdj3ZwLW
	WRt9i5hw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg726-0001ZQ-Su; Wed, 26 Jun 2019 12:28:15 +0000
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
Subject: [PATCH 18/25] nouveau: use alloc_page_vma directly
Date: Wed, 26 Jun 2019 14:27:17 +0200
Message-Id: <20190626122724.13313-19-hch@lst.de>
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

hmm_vma_alloc_locked_page is scheduled to go away, use the proper
mm function directly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 40c47d6a7d78..a50f6fd2fe24 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -148,11 +148,12 @@ nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 		if (!spage || !(src_pfns[i] & MIGRATE_PFN_MIGRATE))
 			continue;
 
-		dpage = hmm_vma_alloc_locked_page(vma, addr);
+		dpage = alloc_page_vma(GFP_HIGHUSER, vma, addr);
 		if (!dpage) {
 			dst_pfns[i] = MIGRATE_PFN_ERROR;
 			continue;
 		}
+		lock_page(dpage);
 
 		dst_pfns[i] = migrate_pfn(page_to_pfn(dpage)) |
 			      MIGRATE_PFN_LOCKED;
-- 
2.20.1

