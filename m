Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56E9BC31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1215220866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oOXLpQSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1215220866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F35656B0276; Fri, 14 Jun 2019 09:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB9FA6B0277; Fri, 14 Jun 2019 09:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5BD86B0278; Fri, 14 Jun 2019 09:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A73C6B0276
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so1831287pfb.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ve9eOR0n9NYQG/06xL1T/7RN+D+EYosn1r01rGXCWe8=;
        b=obhYcmmUYl6pUbBjJUONd2d+4is1Iku056NgtzC1+7aMPONmiQs7e+XE2oGWKb7w/3
         GeZZfzIKxpIZWyiusgW9rN1fsMMKxxSHnseg7kYgKf/joMjRL2lQJZgFR20htQ2+rgFD
         AleCkKKbHEZfaoLHdWG+/K5D4frKMmeLM5pCfaU5rGl7wA1NP7vpTqVcSIVDse21QfP7
         h+NDrsQmJ/MnpsU0jlwv5SRZjG7t6t+MVd81iJJ7eTvBpcIC3bkeNgQgd5y9T1I/sPdC
         rPU5JA8bVD4tAOstW7oM/DXPY7/88eMwFcIa69DBqTcNCzClgekoZq1BPvau0A7Mt4sI
         cLTQ==
X-Gm-Message-State: APjAAAVhxDZfnI9083AQ1U1k726zgs566FAMGKCtt7lAp8wrucDHGM7u
	m6Mj63zcVbgGd8hJq2AWGcQ0gEooHPGtbwQjt6D3WWVRthn5Vn76LLWiDIuZ4V8JbVwnioKn2Ds
	imdXL4JNUlZhfmQt6nT2FE7/eGa9TYcqp+3KuDrZj7ylHv2KryqzpbHhbTMJYt8E=
X-Received: by 2002:a17:902:bd46:: with SMTP id b6mr92875168plx.173.1560520123208;
        Fri, 14 Jun 2019 06:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKg6Cr7KmeoKNFR4sahavMJDhjX+ceVnhsMAYVIKpl+ewyRCOiYIW+pp+0nA7DvLQ89yoF
X-Received: by 2002:a17:902:bd46:: with SMTP id b6mr92875105plx.173.1560520122336;
        Fri, 14 Jun 2019 06:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520122; cv=none;
        d=google.com; s=arc-20160816;
        b=kCGe/HW+LT3jpklTm+xkRNbpSAxPGesiGL8bfoc4SYMT8R1KeYV8YbV7KCH9bSh+KK
         hRHGQGotpAHRyjYzkQ6Bd/prFaEKsR752yTwipWPK1XuJKch4WgGEMRB8OO6gJrQGqDH
         ErAPy/FF8ORrZgvlkl69oL/CquNh88uvkjAw+qcsaZS3EskhoUXX1r7p7RnrFEFh2lKt
         8aEefgNd9lGhRxG0wshFO8HLkfl90AGaOV77PqrC4wQ6H2hM73F5WZTHrNs/6Gi8tc/C
         e/I9BB3gsnk53UYJ4zN42AmvkT0NqrCG0CFb5co/uox388ofrYtjxCEDErFNqzaZT4m8
         VX+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ve9eOR0n9NYQG/06xL1T/7RN+D+EYosn1r01rGXCWe8=;
        b=OQeeIKwlb9h0gGpb9vONTA6XNFvYKtGUCStAiySpWBQdXP9acl0imKqqX9N38U3ajf
         4lTCQVaFWuEIt70NBy3Hsn0WoxPWYjKMEzK2UbgwPkm19UVZFSzY9F8rJHU/Lj5qD1ZC
         qDmcqQ7tigtn+wUlZSDgcnqZk17qtDUHBVrTU2QL4L71+ICB6jZ8QC5QKPvYD37quxgW
         6/vx6sgulKSNRd6ZPRXUyHjOPle+dbsUphMujKkyugwnfHbyxKpDp/OgwHvcSAH7mcG7
         aCYcuJseWRZQpyvFggtUnxl/Of8dO/A633gfwAjlQEeV1lPftln57f42A/QQm8202U9B
         yqPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oOXLpQSB;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l2si2753554pgs.315.2019.06.14.06.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oOXLpQSB;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ve9eOR0n9NYQG/06xL1T/7RN+D+EYosn1r01rGXCWe8=; b=oOXLpQSB9eTwi5cRnaIs3K9jSP
	U3nYifQRasO4H8c9LydLZ7aFiLS8AmMO8L7HX1fSqc06MgW+WgkhhHaoKo2MKfTDNYkKunWyK4auH
	sDEmoQgB8oqOU4hpKwhX2F52HvfX8JBk7RhqZQB3ZfChLLyBOjp1aO1CsWRbTm+0Fj1lVP/P78vhq
	Q/tTXEXgky31g4PmH9ZYyI2SmqKT0gbaGOa4wj3ZMyfwF3m6qpJz2Hgvhxr+PiNdqUsIFqqBd/Bdq
	t5+5nb9o2JxesKPlAa9uOOJPL3zGPLmnTYV+Z+YPjVKvRBW0T/H3FZDUMD4bcdC4PQzCFzjLGL6V3
	kn/hUemg==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmZB-0005nI-Ab; Fri, 14 Jun 2019 13:48:30 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 16/16] dma-mapping: use exact allocation in dma_alloc_contiguous
Date: Fri, 14 Jun 2019 15:47:26 +0200
Message-Id: <20190614134726.3827-17-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Many architectures (e.g. arm, m68 and sh) have always used exact
allocation in their dma coherent allocator, which avoids a lot of
memory waste especially for larger allocations.  Lift this behavior
into the generic allocator so that dma-direct and the generic IOMMU
code benefit from this behavior as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-contiguous.h |  8 +++++---
 kernel/dma/contiguous.c        | 17 +++++++++++------
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index c05d4e661489..2e542e314acf 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -161,15 +161,17 @@ static inline struct page *dma_alloc_contiguous(struct device *dev, size_t size,
 		gfp_t gfp)
 {
 	int node = dev ? dev_to_node(dev) : NUMA_NO_NODE;
-	size_t align = get_order(PAGE_ALIGN(size));
+	void *cpu_addr = alloc_pages_exact_node(node, size, gfp);
 
-	return alloc_pages_node(node, gfp, align);
+	if (!cpu_addr)
+		return NULL;
+	return virt_to_page(p);
 }
 
 static inline void dma_free_contiguous(struct device *dev, struct page *page,
 		size_t size)
 {
-	__free_pages(page, get_order(size));
+	free_pages_exact(page_address(page), get_order(size));
 }
 
 #endif
diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c
index bfc0c17f2a3d..84f41eea2741 100644
--- a/kernel/dma/contiguous.c
+++ b/kernel/dma/contiguous.c
@@ -232,9 +232,8 @@ struct page *dma_alloc_contiguous(struct device *dev, size_t size, gfp_t gfp)
 {
 	int node = dev ? dev_to_node(dev) : NUMA_NO_NODE;
 	size_t count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	size_t align = get_order(PAGE_ALIGN(size));
-	struct page *page = NULL;
 	struct cma *cma = NULL;
+	void *cpu_addr;
 
 	if (dev && dev->cma_area)
 		cma = dev->cma_area;
@@ -243,14 +242,20 @@ struct page *dma_alloc_contiguous(struct device *dev, size_t size, gfp_t gfp)
 
 	/* CMA can be used only in the context which permits sleeping */
 	if (cma && gfpflags_allow_blocking(gfp)) {
+		size_t align = get_order(PAGE_ALIGN(size));
+		struct page *page;
+
 		align = min_t(size_t, align, CONFIG_CMA_ALIGNMENT);
 		page = cma_alloc(cma, count, align, gfp & __GFP_NOWARN);
+		if (page)
+			return page;
 	}
 
 	/* Fallback allocation of normal pages */
-	if (!page)
-		page = alloc_pages_node(node, gfp, align);
-	return page;
+	cpu_addr = alloc_pages_exact_node(node, size, gfp);
+	if (!cpu_addr)
+		return NULL;
+	return virt_to_page(cpu_addr);
 }
 
 /**
@@ -267,7 +272,7 @@ struct page *dma_alloc_contiguous(struct device *dev, size_t size, gfp_t gfp)
 void dma_free_contiguous(struct device *dev, struct page *page, size_t size)
 {
 	if (!cma_release(dev_get_cma_area(dev), page, size >> PAGE_SHIFT))
-		__free_pages(page, get_order(size));
+		free_pages_exact(page_address(page), get_order(size));
 }
 
 /*
-- 
2.20.1

