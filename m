Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C5C9C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4B9E2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tMlq/k++"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4B9E2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74DF46B000C; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF8B6B000D; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59FB86B0010; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19B536B000D
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so59338311pfi.6
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r4axfViZZyZ+fuvT3jC+Yx773mt75vv7oepOJvLdF2Q=;
        b=OzGuv7siaaIY+lbPaTnRATyz4pAGqQ2vCInL5C3JCpm2Qf2cp9IYMGKAJtt6AGNT5x
         RGOS+tHJGllOSdGQfaZ+iQGyP6viUjjeqbHF+2443mbrihfYiJRe2PrA21gnilq18Xyk
         9UbJzUgvRJyJsR39assKvM0NC96POQ0uJQaRENy9BPxyIW2VUx/KyqnjMGvxoAJFHK2y
         SSTgVhAEMcrH9/Lo3osRpr9oB8uFhsP/aX6CKBLVMF1xnB06jzLtlqlQhk2PoNdbU+SS
         bo+pNrnIV2hWe9PH3bYp74jZ5A3d1e856FG+NnxgnrWMy+vPXXwTwD099z2yKwDqli5t
         EIJw==
X-Gm-Message-State: APjAAAV1H489V3iVXX62ujv1SG2/Lyzu/GHBCimSEg1OGrfdz80iMBF0
	JPT6ta8DxQzCgPFOJOljDrWIs/f09hF+uEwRh31T5FXJ9YnKIQU/FYi+ipOCSvpX0/PbzvCGMXF
	u7UXitfYohYD2IPYvHfI5s3sFdOIg3fOsbxuZQ9hV2PNLN0mA+q2YLJAc9nc7zwA=
X-Received: by 2002:a17:90a:20c6:: with SMTP id f64mr4683115pjg.57.1565278440736;
        Thu, 08 Aug 2019 08:34:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJWMx7KSRb/IETjzimrWAo69tMWwdRvSvEobSlpwXRUN4PbAjd9IB8TPht0DKq4ADOktq4
X-Received: by 2002:a17:90a:20c6:: with SMTP id f64mr4683046pjg.57.1565278440064;
        Thu, 08 Aug 2019 08:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278440; cv=none;
        d=google.com; s=arc-20160816;
        b=j0mf5OxZfBHuF6e5ll5v1w/HFSw3YZ5U9z4ONuQFsze9lf7xIEit5XlWrqBR2mNWhn
         26Josc+XiypHpCm/azb1oK2BO9yAmd1n0/6lhPZGsk6atbtKyc7T3zsGsnSJGVz+q7QW
         le3XEduYrtz0oXnIM9aV4B4rC96QuxAWez8fdXjRYXa/UjgSLU1/7tKyrLtom9snZHe8
         miRNKutbqj0vbghhEU/cI1XRGYEacUdorSJ6PFfror5WB39CLuQFjv3aUnihYxk2VTOR
         zctwRvCcIS80VE54whTlLVY/RB5/8U8hUSOnLxZE5yxVzcG2nBO/DQyn3qm6ituu/qUC
         sZEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=r4axfViZZyZ+fuvT3jC+Yx773mt75vv7oepOJvLdF2Q=;
        b=Dvu60OIFMrbrpw2pH+nkvYeW50+aRc77m8inHkv8dd3W5MRQy5H6oHiAp70TRcM6+E
         CyA/qBw1dL9nMJMRB8TsYUnGd9jLKryNPhd9woHVek6EvmGELVaqvd+/AFpUC7y9XCFX
         O4tZJdfMr7+c6uNZeQQn6BCWi3ymf/ysAtRSboIeL/Bg//t9xMrzjS1alkDzWYZEiAY1
         vPY5/6/SvJJpIaABtnjWKhAk3wUKKl/+on0WHw8TgZ9+Eqy2NdW2R6ufFZgZdrbf0ulD
         LQuv2zfggfA7Gk7DCCbbxnnqvxSBLt+AlYaH43D1wdN9MueS9LPxj4/dCNeWhWF6bjWt
         mBcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="tMlq/k++";
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c21si2177771pjs.3.2019.08.08.08.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="tMlq/k++";
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=r4axfViZZyZ+fuvT3jC+Yx773mt75vv7oepOJvLdF2Q=; b=tMlq/k++S7BlJF3D0IEJuqTiM6
	oqe5hKyEHH8CDmDKg/HmAt2rE73V4uPht0nVKiXD7U/2sWNbvrtvdTYnSe9A0uMfHV1GTMAocfrZe
	Ez6ZnLo9Oq7Y44HE7PPtfLoXruoTWqHHBDl8c5ijWE+wdI0Mnb4PqsoCzJHFGlgupiuSJHN33JcCC
	yysnIlvB94o4LnPBKd7u77cy+tjNHSPn5szyd/vrNWL1lix66MTnaXSMIrsCC/VYJOmjK1F4TwfAM
	F83YjQ/z5Hu9qyggzcysNHSygOCOmR/cTep7P0Q3SKjtTyRoBCizKh34pseJoX+Esu02CkwQepujN
	9ykuGN1A==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkQN-0005Ak-P2; Thu, 08 Aug 2019 15:33:56 +0000
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
Date: Thu,  8 Aug 2019 18:33:39 +0300
Message-Id: <20190808153346.9061-3-hch@lst.de>
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

When we start a new batch of dma_map operations we need to reset dma_nr,
as we start filling a newly allocated array.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
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

