Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC309C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68E4D216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:29:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UOK0LNoA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68E4D216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34D708E000B; Mon, 29 Jul 2019 10:29:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326AC8E0009; Mon, 29 Jul 2019 10:29:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23DD58E000B; Mon, 29 Jul 2019 10:29:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEF848E0009
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:29:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so38612993pfn.5
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:29:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KRhSWVqqlsL4sNnqiKki+hdwEXJ8VTEYKaUDLbMamPM=;
        b=EgiPRatEhl3U8NWAdbdBcRtqrc8N17l8itQzKnm9Hun1TkeAlbI7AKTGTtD23QG56B
         gU0/BkTxKRZFEXTzIaQ52u1Y+NRXKBARvyofd+emo3gpCNMQPXl+Ycl5wRh4ND2veRJB
         KxT8gxqB+IBk6KomhalEFI9mcDPsF8cXzhC1CUpXM4T0AG565e8BD1tTIaamYB3nq6uJ
         bQ0qeK6WCgchm6SR4nqyD7/dNnctLeTKcLNQuaQ6xXQKNTcgpFSy6RoOwUW+Geh0JrcC
         5W6JHb55sgQ7Fdx7zkaxVdXOgIVss9Yv7HrxlejVAQbaR4xLw0zOElG8b7sD2uj+6Tjh
         5MQw==
X-Gm-Message-State: APjAAAXRT2ITS8IdCNJgV6YBSzwB3ga9m4v1T3tlHwo3B/krnTWRHafG
	hsuO3YQk6NFhEPWlwLEFUmf8B0h92EtkZp+WZcvtms+RD2MEsDt13jJDICXqqNJ5ZD6AUq1IuRm
	RMWNjvJ0msLgq6MLDVzaqGEEA59jWGEeYXGtxrSSl8XfSh+JaRmvfQk0zv03bm3I=
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr109628017pjc.23.1564410549597;
        Mon, 29 Jul 2019 07:29:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaA+3jcA1OW3tUBw27FJSxuDwsLL3DSMCCOejzfVubYF39jejUDNH8rVdMbO1cQaUOZizk
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr109627975pjc.23.1564410548855;
        Mon, 29 Jul 2019 07:29:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564410548; cv=none;
        d=google.com; s=arc-20160816;
        b=TYUynDxJor6DYu1oMcOfc2IU6bNxHW56Oi9Mfm98AL+k39O4z0Y5okWw94/6oP5Z7c
         87FdvvXe/gMZ93hsXihf7BEevH/dOX65vGUzndBpGxX7CYVajlm72kUvaNmvlPXjAvAX
         pI/OJbD0UO81JPRWzsTgXJCe1SxvzotSQKuA0DNa3H1oXPOhuj2vI0O0jdOeoaz4jctx
         M8wC5DXsu6vm1/nuUmUKEcYAvYglxmikBXofrhVHjVAgHooOuc8B6ulRX87uRtEL7KPg
         is/5pY0NRHXL5tO6e/As+VVTBCvHGdJDz2EL9vUbt5yZHshHykwxMh8K0Io++1bedL6b
         iMzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KRhSWVqqlsL4sNnqiKki+hdwEXJ8VTEYKaUDLbMamPM=;
        b=BBjoS9NQXtj4UTyDfNQo0CgWzUV/NhAeWnltVLDbXG91CcPY/HAJt8mvqdWYaqrE9u
         12PgItq/46ZF9wuGS+uqYQHfEBFFB87jOWVLuY/VYu9zYSul+4HvBVtRklQSaZ3r3s94
         IqhNtm9kDI58eweJaLQGhAqTb3zvYoo7a5P6XHLGWSMDTOzyYGUYKH2P0dhjsHAQWWsH
         KdoMvt+NLBwPesClbNGROgL72ZG8IkAXuIHn+w1q34ACoduEsb9Qion4ml67A16tM3st
         de8rmDqbn0lxDUfTp3JNHpjV/UA9pIMmC2em3WBVbRvMyf1Jiq4+oX3LiddK3mpNGYFb
         y/oA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UOK0LNoA;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i23si27102827pfa.196.2019.07.29.07.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:29:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UOK0LNoA;
       spf=pass (google.com: best guess record for domain of batv+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+767bd1556e0605a17a22+5818+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=KRhSWVqqlsL4sNnqiKki+hdwEXJ8VTEYKaUDLbMamPM=; b=UOK0LNoApFOGwvTn+Y/XD3jBnG
	TRfhIqboSv8iqXv6omeWkilEGsmxKwQhoeVgR9UwVkpnbiS/E1ecOTCAqXTao8qWeYkvykFlXFDK/
	Ye5pIUMH+Ium1hxsiHtJ8/DyYvvHVnb673b0Q1ak9Biu2jXuy2gNUEP+jaVRTxUqOUnvjDE6IuKbu
	iEbtj/LsXhOByx+dgF6Sv3TpkO9E88HNVVuMBM12gNDgGZtDbAE9gUqgPsBxGBPNiA/8fP7mpHFRn
	qcYcymO5NouySz7CZywQqyMe/t/hyPLhwBjO/65i84oIlD1Z/999t1DYXQH9Z9WD65qRbBOoShss/
	8doBh/yw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs6e9-0006K6-NS; Mon, 29 Jul 2019 14:29:06 +0000
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
Subject: [PATCH 4/9] nouveau: factor out dmem fence completion
Date: Mon, 29 Jul 2019 17:28:38 +0300
Message-Id: <20190729142843.22320-5-hch@lst.de>
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

Factor out the end of fencing logic from the two migration routines.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 33 ++++++++++++--------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index d469bc334438..21052a4aaf69 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -133,6 +133,19 @@ static void nouveau_dmem_page_free(struct page *page)
 	spin_unlock(&chunk->lock);
 }
 
+static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
+{
+	if (fence) {
+		nouveau_fence_wait(*fence, true, false);
+		nouveau_fence_unref(fence);
+	} else {
+		/*
+		 * FIXME wait for channel to be IDLE before calling finalizing
+		 * the hmem object.
+		 */
+	}
+}
+
 static void
 nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 				  const unsigned long *src_pfns,
@@ -236,15 +249,7 @@ nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
 {
 	struct nouveau_drm *drm = fault->drm;
 
-	if (fault->fence) {
-		nouveau_fence_wait(fault->fence, true, false);
-		nouveau_fence_unref(&fault->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before calling finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()).
-		 */
-	}
+	nouveau_dmem_fence_done(&fault->fence);
 
 	while (fault->npages--) {
 		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
@@ -748,15 +753,7 @@ nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
 {
 	struct nouveau_drm *drm = migrate->drm;
 
-	if (migrate->fence) {
-		nouveau_fence_wait(migrate->fence, true, false);
-		nouveau_fence_unref(&migrate->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()) ?
-		 */
-	}
+	nouveau_dmem_fence_done(&migrate->fence);
 
 	while (migrate->dma_nr--) {
 		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
-- 
2.20.1

