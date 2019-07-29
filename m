Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37038C7618E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E310E2171F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A+IRZ8M1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E310E2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9691E8E000A; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F08B8E0002; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E3988E0009; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0EC8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:07 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o6so33227124plk.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rLwKSOlafAJb8n3hQj6kWA/VptqS/47DN+jL5NpRAcY=;
        b=SdFViyGEOaqfocVvBzdmAi6wZCq1u1OdxVpybRdIjxlcYy2x3ILEzRL0Hb+rh4WLIJ
         uX1FX9qNwlihCNse6e5CTgmcXaBmWhReqT4kGbQgi1cLmedDmyPKGmWYV/s1p0bcB7VW
         9CxGWszvvP6cXWBnSEbFSwbRRtBAwnmTjxiSZi+2Fv9sStAP6qR7WrFYpPbho2yPvcGr
         36ageA4oIt0f+PWpw+xl/Y8n5CYrTO1SoYipIcpsVTWrYmJ+Va9n5qT/NXkuL0bEF4HQ
         BVZ1NoW+J0S616te3zNBwHfnmbDffO+YBWmTVdrdeMKr4yw/DX2QUc8EWqBBRQyNPDyn
         v35w==
X-Gm-Message-State: APjAAAWgA2i3nK8a6duYAu54KZeIXy2jnfXGZZx7Ux+SbVa7W2DkkvL9
	2GOILuavZzMpTNMKQe3rWIuYptsqUQeDGcQKhdM9CwgvwuZ43aXdDpbevxm0wIuQfFoW1g9X5A7
	GILYZTZGDcpGaccSpzu7ymyf7YR1WQqZuxwWm4vcZVyHrP3aT//1YHrAYnNx2kHw=
X-Received: by 2002:a17:90a:20c6:: with SMTP id f64mr113356859pjg.57.1564410546953;
        Mon, 29 Jul 2019 07:29:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTtaJiu6zf5kuLd4cS7B4N0hnbYIiK3d03VWWfO7DYYPs91AxFNIbfASBvMUYQvvicJGvx
X-Received: by 2002:a17:90a:20c6:: with SMTP id f64mr113356810pjg.57.1564410546279;
        Mon, 29 Jul 2019 07:29:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410546; cv=none;
        d=google.com; s=arc-20160816;
        b=VTSPrH15F5Qv3cnGbffz13hdpAak0rjQZy5HsUFtn4clQUKno9NdNcUCuAOXyp08xl
         0myL8069Nl3OWLlrDeTjRT6EgRPnqxYC8t87Cqs8qbXY/e7GgfdV8Ieg11AMEYO+mqc0
         /sefrjT9Bi7Tss7hezL3xKqW6RhzE0S3P2w8Kov8HDwjygcPHfzEtAeTJbtubVWhPdMz
         Nrx4mjmouhkzgZi2ebSOCFpfNdixu2rplOpBgpb0TqwHjMLZKe7vVDxcmPMrxPa3aRZN
         7ddBZ2V8q+W3XIb+soh/89nwjJ7KGOSLw6WH/M2CP7cYF5FKPlvGQ4juOLdWsrPC+FrZ
         00iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rLwKSOlafAJb8n3hQj6kWA/VptqS/47DN+jL5NpRAcY=;
        b=M/SQ+nijbcnPYqyM8/Xv2XoXh9D8M4tSp1trL10MqShgFRoOreFYn5MPnF3D9lsl5+
         BdzDip1GQwEB71gkNzjCHa9qOKMUHr1SHwubfTlhX/A6wp/rhWhRkMexgAbywX1SczuK
         WUc2qQ/IOhvVxhnH3PLdXNxDX2dA7B5nRv+3VKudmS5WOw6S+niEvqfMIURAG+qJHWUt
         FotjDKyfsiRtJimY3TAD9UIWExkhP+MebkF9Ep8ZyU73OMqkQVNEC2GPV7YY52oaLv4b
         YmT7L8oHjiPyPoF2rqpqHmiWjURJdu9RiGfvFZ8IFwoOKKmp73jhXc5LPXMQqe7XZEql
         OxyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A+IRZ8M1;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e123si28219121pfa.252.2019.07.29.07.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A+IRZ8M1;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rLwKSOlafAJb8n3hQj6kWA/VptqS/47DN+jL5NpRAcY=; b=A+IRZ8M1YJH2N/gpPN/5CPiigV
	i/LsLL/cCmEExGvDC7zuiAS3QzG/GI0Ed8MghHETAe8DC5dwOCftZsYXuDgDha21U89uP4jRALlx6
	wYIarlhg/pz70o5kgZxi0oDVRBFxgi2caIj3mgBuRcZbFBF84n+3Ps25EnKxvguNY8dZm/GG6xlCO
	2lPhHQ1IEuUTTjUmEPOo7Qx6Ji0Inu5VxdUlf2aSxirRwZtpZ4Rn+/aQ8E3fFDscxF8hLpUOco1PP
	s5Nej8OFdg0xkTb7AewQR47WxbZ4yp+Hr/wJShONMpmmeawP3eh4LVmkE0GVIWJAp4keNUAaACguQ
	uGoMGT8A==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6e4-0006JM-9F; Mon, 29 Jul 2019 14:29:00 +0000
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
Subject: [PATCH 2/9] nouveau: reset dma_nr in nouveau_dmem_migrate_alloc_and_copy
Date: Mon, 29 Jul 2019 17:28:36 +0300
Message-Id: <20190729142843.22320-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190729142843.22320-1-hch@lst.de>
References: <20190729142843.22320-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we start a new batch of dma_map operations we need to reset dma_nr,
as we start filling a newly allocated array.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 38416798abd4..e696157f771e 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -682,6 +682,7 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	migrate->dma = kmalloc(sizeof(*migrate->dma) * npages, GFP_KERNEL);
 	if (!migrate->dma)
 		goto error;
+	migrate->dma_nr = 0;
 
 	/* Copy things over */
 	copy = drm->dmem->migrate.copy_func;
-- 
2.20.1

