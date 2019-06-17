Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F6B7C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49D0920657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WuL0DYWb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49D0920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55EB68E0013; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50F288E000B; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D65E8E0013; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02DA98E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so7650825pgh.11
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bqNW86dzEIGFtFX91S0QfixvDgbjQWnIT6qUU0eVEH4=;
        b=bbRxvwUZBnYkuy3b3gk5JBBcpTeig+VyjeSyPHPnqs14sS93OukhPkOm4TRvvetRe0
         RrwpJQTX63fjrnKmp0zCmzdXuPUdkWP86yC9Wk9UeTbwIo5KtWX0VMrSpWkXzjIPJDl3
         ZiM8k+/HuGarYhP3CwkwZPuoPFv/mwWHSGgC37f8zJ3jGhw5W6M6eH7SQ6ctVP/KfMhG
         PHSKtxVr2R3i9ZVnKyenWMxc7OQdYwTKqpt7ARO4zQkvpiS4xFjLCOT/2JbhLSYtzDiD
         0J/21Xj5WIKgh4hD7F3himZcDo1/pYgePPZirg3yuzsD08Y/LWs1YiZT8b7g+1kYLqNI
         Q7cQ==
X-Gm-Message-State: APjAAAVEJ8iLaQNIOPki1G7ZvRaHtVzmguSCtUS8tC88B0AHifzDD78B
	qcN6YKedNZItMOyqsHbGcqmILYCQ4kh8UBjqteu929TlpHSjfXNhEr/i+B+f5DHw87JBUGxUYGE
	bkomvMA5dC9u5uswc2z1RX8qxTDrqKIKKVWohzkXDcgEdcZuYV9arze0/aODA8vg=
X-Received: by 2002:a63:6a47:: with SMTP id f68mr30230491pgc.230.1560774497598;
        Mon, 17 Jun 2019 05:28:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCusz5B3pyoLEKyBvXGROOSqqavVbJQPik6HYMZWSSFEkzzrikvknQefYIGCL4vzV3Mk2M
X-Received: by 2002:a63:6a47:: with SMTP id f68mr30230444pgc.230.1560774496511;
        Mon, 17 Jun 2019 05:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774496; cv=none;
        d=google.com; s=arc-20160816;
        b=YdXInO0qeKenOxKONvNDJgS62X8FWjDKm4pRRCGYHVDKdnmyHaenNyeu06S6fP984i
         lm33ybtHuZxZ/m/BdFsKuhuqpJMe9FvcaIYbc0rpuOh3r3FRlZCumZHZW3X2HN8f1oqV
         YH5LzhHzkv/4SQ4ew8nfCyfGdazahnQwJ+illTQoLEQDBFYVmxtB8quxcZQ9BH5S/591
         6o0tC/V3bf5CR+2wspatt4n/eQT12t5SwImJ2M6MPLCmDMeSHE1FJ4KdTFRm4VRTXhiV
         nERm9YzLfeytyM1LO7PRlUT0ir0g1AND0EoRfHg1bKZmsknMARha1TE9q1WSbOTB9C6g
         OjvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bqNW86dzEIGFtFX91S0QfixvDgbjQWnIT6qUU0eVEH4=;
        b=vHYJWV/v2GcntjBTNEyi813LaAXNlVGSbhXsp5UojF620cflg+EuE5sk0JQUUAHPl2
         aAtn44Df5bqXHWUNRciMuE69z0rSHqaRIQPrYy7PScNB/NBss2xf9EL91qv37LBEPU0D
         KmV2fbHFy7WgfVdaVDSK0i5DRdBQKD0G8tq3MKUb98x52qhtEaklagTWM+AQcFw4etNp
         sYDpcjNwc+wHO/gXIHtlyIhuM5k5VBXt83QOWTHBhKu4CSrdJNWpJY0B+3arbcXzUz77
         A5fu+VEt7SbHuyvxhjKTrl67FEsbZ5xO0/nUaeNHRCJ/CUCoeyYamgl9CU10XbKROR7P
         uffA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WuL0DYWb;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d191si10392726pgc.460.2019.06.17.05.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WuL0DYWb;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=bqNW86dzEIGFtFX91S0QfixvDgbjQWnIT6qUU0eVEH4=; b=WuL0DYWbzTX1df3odeTY431W11
	U+IcQwoSHpIn1fMOzejiKLQ4T8swbios1PHMUkKcA2qDdFfDiObZfLsILw7OcEJxSkmTjZINPR6Ex
	JU5UL9obm/Ujq0gzLG5GLwV6DXCHwO9XcVhmV5JdSTTENkyBGpYwzs9vK4bZgbYpWH0X2uxeezDtb
	zTKdJMavLuTl530T4mh89YjZh7oD2lAFwjczLk5AV3FaKTfWD1grijdKZyC4ZIwEVCxgVy3oz5n7T
	RBeVOLMjWP1rN6VKNGoDkd/NFq1PppJFQffAUKysbEbgpOzqWo2a2uIJuDwVJADkhF56XaEwfYDf2
	sPXWKLLg==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqk8-0000Gn-Ll; Mon, 17 Jun 2019 12:28:12 +0000
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
Subject: [PATCH 16/25] PCI/P2PDMA: use the dev_pagemap internal refcount
Date: Mon, 17 Jun 2019 14:27:24 +0200
Message-Id: <20190617122733.22432-17-hch@lst.de>
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

The functionality is identical to the one currently open coded in
p2pdma.c.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/pci/p2pdma.c | 56 ++++----------------------------------------
 1 file changed, 4 insertions(+), 52 deletions(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 48a88158e46a..608f84df604a 100644
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
@@ -194,22 +156,12 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
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
@@ -223,7 +175,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
 			pci_bus_address(pdev, bar) + offset,
 			resource_size(&pgmap->res), dev_to_node(&pdev->dev),
-			&p2p_pgmap->ref);
+			pgmap->ref);
 	if (error)
 		goto pages_free;
 
@@ -235,7 +187,7 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
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

