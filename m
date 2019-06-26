Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 026FDC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B262E2063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uYRez3iz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B262E2063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208CE8E0019; Wed, 26 Jun 2019 08:28:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195068E0005; Wed, 26 Jun 2019 08:28:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0349B8E0019; Wed, 26 Jun 2019 08:28:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B876C8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k19so1541021pgl.0
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O8xTiSY5VJngyKM6+yEPSiv/sNrzxm4spoPZD5fr/FE=;
        b=KAjDH2wHx9HsXr3HqrMItRY+orju0KeGU1ozD0TavnK7QzIrCYoWPVnEWMhus3imBJ
         y5EjXMq980G+7381M9uA7UZyY6kV9SSs5AQbg+/uH0rhlzsKaS0iecWVnA4y/sieEYpE
         SSW7h5I36HzTVyd4vt7xLMXcmv8Ptgz75lOjAPXAvrrVALV2tiHnh0gvReBbOtcp74Cq
         o4C95f6Q7WRuPWGYv2X0MwbW/R8W+w/ya5G8s4o7mwl1KHOZhXvIRlRN2RXbAb5z77Wi
         vxgoDKFS0lezqd0tkdxuT2AAv400o5/CvM+bq3SPubDl1Lt9jT0sxzM/d2bcTgu6qhUz
         h3BA==
X-Gm-Message-State: APjAAAVlyWUUZpXvSQr8Fo3sj42F3kDa/C9EoAnURLMj4NOQiy9HOgKG
	W5M3GKPe/vR1j3cMMkwuQVfdCjW5fPEmYtFww3lVwJgelqn4C5cboZZ9u/kadsktNzhrLHK0ugf
	12TkgIr7F7s4uExe5Mw1Ndzy9ulYBy1MgNYa14vDjPfj7nhL/aF3bKcRBHRT5cjY=
X-Received: by 2002:a65:50c3:: with SMTP id s3mr2711265pgp.177.1561552096265;
        Wed, 26 Jun 2019 05:28:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsTsF0YN4CLkc08GfUsrrCWNyYUUJSS0BmoKie8uvij7eB9SCC2ypoWgMOr99S6ueMZY70
X-Received: by 2002:a65:50c3:: with SMTP id s3mr2711218pgp.177.1561552095471;
        Wed, 26 Jun 2019 05:28:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552095; cv=none;
        d=google.com; s=arc-20160816;
        b=XR0YxXhR8mXOCat6nlaHZj+gGUIwsl1gvTE3sVq8iGwg+U3CL8Ne2LMXFUyr+T9jaQ
         HhgF/pwnlEQd1+DqO/Yv5MJxY2pUYy+SQUuvv0ohI6X9zhdm1bnU4SM+F6nclXU/5pjX
         zME5vNfTwrNpyJ76ydom8JHmt8dlr5xU+TYxii7LtmE2pZhw8p5HmsQdi63QJWANLk8l
         1Yv6P6EjAho7z02FF/qtuXg5+wqNSmrlDbfCQmfi5TILO8/mjFuOlVDhEl3+Q+07/HU6
         TRhdeSKXhXXvVC2YdpKFxmV6FdyRY2Sp7OBIhsGG/5lhWtPM9hqf/SOzQBUSzZS/5kGH
         53lA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=O8xTiSY5VJngyKM6+yEPSiv/sNrzxm4spoPZD5fr/FE=;
        b=jYBpoBEDPeW5mK6fVPfvu7TOwU7G9FegEH9icDLCKlLApsCVW6wWfXjyxwWw+sjyyF
         93JbPt++cGx1tVZsMZag+cHMV1N5//vCZD3lqWwT7gT/Cee0tgI52K4wMK1+UUSciFWW
         gDaVlfelS2wy6FCJGO2mVsT5/i8ygR+kaptaiDqs/+Epu7SrtJu+QLaUWu+et6h84+UJ
         7Pg2EHbBvZDWBKsGjKtpTsJq5WMYjDXq/kZA6y8ZS8kMzRLTf76GWx0PWS0KFFAwv9Kb
         TzSUiIM8wJ8JeBlu4n5zIY3DrXP10/Fd3iwX7vnotFzMp2hAeX1pXXlG9fyHoVJTUMX2
         zPYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uYRez3iz;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m7si1911832pjs.63.2019.06.26.05.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uYRez3iz;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=O8xTiSY5VJngyKM6+yEPSiv/sNrzxm4spoPZD5fr/FE=; b=uYRez3izVT1tTJ2inEjlr+sqzJ
	mQ/FCU73nGQFwZr8hbyBONC+pRy4Y5zWmPKwE4e+/VnM1Wd54RXoko27P7OJdwYWEVZyOfhCpakZS
	NceKKQi8BIED/6Zf1boEQOc2fhm7lXJtPKrQRbyudvIk9ok/2lsM7oKgHQmN0A0NUt1wauMOTrnNb
	YztM4+JK3tURRAcVPdB2QDw04eLlKqyMRUZblAnCS+8D4s/P8NuKrPuYvEzOGKhpFIyCfq1gDkpSy
	T+Z7xfSW0MFySDPpzpi2T3kL1+k8AT2+W9JX8ZK8GzydNUFd8VyzyqZ163oz2EZ+8MZT6vIfA9Trk
	2ljmFk6A==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg724-0001YD-CI; Wed, 26 Jun 2019 12:28:12 +0000
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
Subject: [PATCH 17/25] PCI/P2PDMA: use the dev_pagemap internal refcount
Date: Wed, 26 Jun 2019 14:27:16 +0200
Message-Id: <20190626122724.13313-18-hch@lst.de>
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

The functionality is identical to the one currently open coded in
p2pdma.c.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/p2pdma.c | 57 ++++----------------------------------------
 1 file changed, 4 insertions(+), 53 deletions(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index ebd8ce3bba2e..608f84df604a 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -24,12 +24,6 @@ struct pci_p2pdma {
 	bool p2pmem_published;
 };
 
-struct p2pdma_pagemap {
-	struct dev_pagemap pgmap;
-	struct percpu_ref ref;
-	struct completion ref_done;
-};
-
 static ssize_t size_show(struct device *dev, struct device_attribute *attr,
 			 char *buf)
 {
@@ -78,32 +72,6 @@ static const struct attribute_group p2pmem_group = {
 	.name = "p2pmem",
 };
 
-static struct p2pdma_pagemap *to_p2p_pgmap(struct percpu_ref *ref)
-{
-	return container_of(ref, struct p2pdma_pagemap, ref);
-}
-
-static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
-{
-	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
-
-	complete(&p2p_pgmap->ref_done);
-}
-
-static void pci_p2pdma_percpu_kill(struct dev_pagemap *pgmap)
-{
-	percpu_ref_kill(pgmap->ref);
-}
-
-static void pci_p2pdma_percpu_cleanup(struct dev_pagemap *pgmap)
-{
-	struct p2pdma_pagemap *p2p_pgmap =
-		container_of(pgmap, struct p2pdma_pagemap, pgmap);
-
-	wait_for_completion(&p2p_pgmap->ref_done);
-	percpu_ref_exit(&p2p_pgmap->ref);
-}
-
 static void pci_p2pdma_release(void *data)
 {
 	struct pci_dev *pdev = data;
@@ -153,11 +121,6 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
 	return error;
 }
 
-static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
-	.kill		= pci_p2pdma_percpu_kill,
-	.cleanup	= pci_p2pdma_percpu_cleanup,
-};
-
 /**
  * pci_p2pdma_add_resource - add memory for use as p2p memory
  * @pdev: the device to add the memory to
@@ -171,7 +134,6 @@ static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
 int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			    u64 offset)
 {
-	struct p2pdma_pagemap *p2p_pgmap;
 	struct dev_pagemap *pgmap;
 	void *addr;
 	int error;
@@ -194,26 +156,15 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			return error;
 	}
 
-	p2p_pgmap = devm_kzalloc(&pdev->dev, sizeof(*p2p_pgmap), GFP_KERNEL);
-	if (!p2p_pgmap)
+	pgmap = devm_kzalloc(&pdev->dev, sizeof(*pgmap), GFP_KERNEL);
+	if (!pgmap)
 		return -ENOMEM;
-
-	init_completion(&p2p_pgmap->ref_done);
-	error = percpu_ref_init(&p2p_pgmap->ref,
-			pci_p2pdma_percpu_release, 0, GFP_KERNEL);
-	if (error)
-		goto pgmap_free;
-
-	pgmap = &p2p_pgmap->pgmap;
-
 	pgmap->res.start = pci_resource_start(pdev, bar) + offset;
 	pgmap->res.end = pgmap->res.start + size - 1;
 	pgmap->res.flags = pci_resource_flags(pdev, bar);
-	pgmap->ref = &p2p_pgmap->ref;
 	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
 	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
 		pci_resource_start(pdev, bar);
-	pgmap->ops = &pci_p2pdma_pagemap_ops;
 
 	addr = devm_memremap_pages(&pdev->dev, pgmap);
 	if (IS_ERR(addr)) {
@@ -224,7 +175,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
 			pci_bus_address(pdev, bar) + offset,
 			resource_size(&pgmap->res), dev_to_node(&pdev->dev),
-			&p2p_pgmap->ref);
+			pgmap->ref);
 	if (error)
 		goto pages_free;
 
@@ -236,7 +187,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 pages_free:
 	devm_memunmap_pages(&pdev->dev, pgmap);
 pgmap_free:
-	devm_kfree(&pdev->dev, p2p_pgmap);
+	devm_kfree(&pdev->dev, pgmap);
 	return error;
 }
 EXPORT_SYMBOL_GPL(pci_p2pdma_add_resource);
-- 
2.20.1

