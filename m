Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C80F3C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8363420657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NvmFARNv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8363420657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B3938E0014; Mon, 17 Jun 2019 08:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1652B8E000B; Mon, 17 Jun 2019 08:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C658E0014; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2CD88E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so5918950plb.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=;
        b=i3N0TrXhisLFTgS+Ij+S9CxTUNP+F1RGCSYfnVv0YRrkoeDWAV0SJLw8/Gjt4bcnG3
         3ENMe0zZRXHi8yt9pYytDbwdIDRduqKZHZwOsSIczXK3S7ZxZEIGt+A3PuWDfmrI1D/7
         Bzi+79/CYv7fffzVtshhM+1O578en+IMd6b31hv+nJwif2hPjKhdQx7qM/TjZcen8UHa
         ZN9fLxF47YgT4Ok5/4meKIYs3T7cir8CWDsQIw6S2As/hnzhLqFSvLlQcy9NKg5ZdgEx
         Z6B2/JTavyCQEmK5QqVu4cvnB6h3rdYyzPXxD+H0Gv3Hqft33osixqa406J1idJ+ZVoI
         a3Sw==
X-Gm-Message-State: APjAAAWN40wIqVuVkTJ5t6AV5b9fePklIYQMESlAUGk4CorXBbEwCbhe
	8K8BbaOCsxvFWQiIkj1vG4JqvSo8KteDCZD2QcDlYhzsvckgsRIc5/4PqNp80/I+xjQ/OPFjviP
	jB1I53yxzyKtdmh+4WAhNrxpkNiIbBLEhHYH9lGKqvrQAta4plRwShuNl3GaO45I=
X-Received: by 2002:a17:90a:3585:: with SMTP id r5mr24597549pjb.15.1560774498481;
        Mon, 17 Jun 2019 05:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVX0tyQC6/RHV/SFYH/6ZQ9TkAwAhAW3RvqCe17nWCKpCGNKDyJtbYkdVwWEwAjh7k7WLI
X-Received: by 2002:a17:90a:3585:: with SMTP id r5mr24597506pjb.15.1560774497842;
        Mon, 17 Jun 2019 05:28:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774497; cv=none;
        d=google.com; s=arc-20160816;
        b=Jhl5K7qgBNx0ESErhsS4QFQJDhBVb2LZKdBXLFRlIyjtFYBwQPImeRGV08lbO7wO8+
         E69lPDppSefH52pUjzfcloatKFT+N5OKg2cyfCvdNP+Mj0IyYLgYTPL4mUXGDhySF1d+
         VY3w2WLToRbJsrnJbnUFoxKh63T4Az1i/LxZ02+x+SjEjDz8Xv6TOeCOzIKtFAeOhiPy
         sH5/p5M4QAt90rdtXJeMjpHYPm8xvgmruXUfBrfJjuVm8uv76dXszrO2YffLi+HblpLc
         WyzDEiea5vnYN9s5FtCYOOiar/tgZRglIfmWJBueaZ2FMJCPZ003t3T5d/RVD1hVMzxM
         C4MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=;
        b=G9yjQQIPErkavKvnOmQSG/sr3b8yxz+Rglbqn6EOHCzcnXRQQpds7SWRqmxcxYXvol
         Hy53WadqCPDHtMjhGBS5xbANNqcjhVTf2iWxS5w1bECCUidbXMEvI07FCYSLcGuY7uRZ
         5EQhT0xwwOhZq0SYWMya2VkEIP5+ZZwVQCKptD0rqqAgVrqteDMiHnaOglTSjwgNkX3M
         ptAyXwelw+RfwT8mLOKc1pg3LHH68pWTH6eS/NBMkam2VbUWiQoMCI9XElcYp9ZL6l4P
         HcgBALB7SnR5aNOElXgm7Dgy6kGK1s698fY4RxeSfeKzLz1sEGD7DrCXdCwQ5j6pd7tW
         wczg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NvmFARNv;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g2si3581782plp.1.2019.06.17.05.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NvmFARNv;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wJ4xmBbrpfmUG188a6jPO21+BmohIhmVPW5AXcG365o=; b=NvmFARNv3ttc4OZA1xiWtFgk6o
	tdVi27VruAOhBspuUA7ohwBhG+sI+yUMmYAM2rIE5UYw1cs2pTWfZ5xIVYWVSXUUYfaE8dtGle2Q+
	38vp2DyzOrGYunTTU5sPPOW1gV+9VLzWPhfKjWesQc1OJz9ey6i02luy1iyDV8NU1UR55DXdLFs9z
	B9xnWZA1uQSxsPRX5ddbG4TDgFEBCcCk03gT6ou9BHPOe0aifePHXmZwWJ2ck3Ck5I+IpfSXcmFDY
	+sO1BEfn842pbMLtdEO4fcpFGGwrpdcLeDmymIa1vyB92Bk6rnJwTQxlA1Cs4HiPx7qswZydHD0rW
	ZXjVyVEQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkA-0000HW-SJ; Mon, 17 Jun 2019 12:28:15 +0000
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
Subject: [PATCH 17/25] nouveau: use alloc_page_vma directly
Date: Mon, 17 Jun 2019 14:27:25 +0200
Message-Id: <20190617122733.22432-18-hch@lst.de>
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

