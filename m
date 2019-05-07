Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95F88C004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4533C20675
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4533C20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED80F6B000E; Tue,  7 May 2019 20:10:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88C66B0266; Tue,  7 May 2019 20:10:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9E356B026A; Tue,  7 May 2019 20:10:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8D76B000E
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:10:14 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d21so11359731pfr.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:10:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=KmRyp9iGH2ia/dM4+L+AlPWU24ubf//fuPEOuKJI6UE=;
        b=entb8gHfzxqhKRaPCTJ6E25MzhJiqGCYEySZWk73Ozq4ZlCjJ3y7vtQCoBxpmMwr04
         oLASs22tD61QZJNzhlkdWJQyWM0Woe011VyT+Di/p6PEfBa7+C90tCLM/5F9Atw6nige
         1cExxWiWOCJlcb8Lu9IUpnz3pheY03bKC3hn68YxFr0K73c8DDVjbpvRl/Y7QqM+oS4d
         SoTRSQFwfyzHs3My/u5S5T81sn8ATzAXZesuQtmSokb/5vup6CgDSPWANBRCSLno0MMv
         BZx+XkaMirz5Z2qIIKnzqJvzdch6OA5JPaZIjT/rHawNie5NUFS0UoPoTCSxaI9Jyve3
         wKlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVIk3n/tCzl1Wnw67ge+j8C9krlN2XCWeTGR5x4OocwOR6u6ArQ
	iB/2ywDM0FYt4aEexmg/f+kAfLYLadmKSe2geeVZFHq6PpBSsd4Pf0Bx1xw2MMbDm9qCf8B8qSE
	mzykS0hNoO3AiqXTfCclFUT7ONqqmrvqaE47QkAy9X8zFtVotHNq/XDIwlQbhb0kjiw==
X-Received: by 2002:a65:4c0b:: with SMTP id u11mr43592673pgq.405.1557274214252;
        Tue, 07 May 2019 17:10:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0HbcH8t0P7Lc2rWuK+hsh0oly+4k9DrTMYFBkvUKKCqE/aEE+OMdjj0WyFsvHI2jCN2sx
X-Received: by 2002:a65:4c0b:: with SMTP id u11mr43592605pgq.405.1557274213406;
        Tue, 07 May 2019 17:10:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274213; cv=none;
        d=google.com; s=arc-20160816;
        b=rCbZ0H5GpQn/TFcqSNx74JV2VTV8464T0p/2sqXSVBkqbPNv9WrUVexxkNUa6+e6A+
         ksHRH4WuYVAr9Oe2DZX0Kei9qnZgpQ9bmRIcNSg/2jhW8PxRLWCc/44IY/ZCK8noJBco
         BygDG33fyneb7NogVA21DpuBceEOW9Zc7RDdaRnaSuSgE4nku7p9RkPMulmuPzOaIx3I
         9nRLvhjbMGp80RNchJHfngMq5oP75u8rGXpFgHvUv2Rhbk6p7o2HQqZXjskVXFufkvxP
         m7/Ah1TmSdgbbYzmjyAu49Jo8SX9VhXxGuc4IEOzbjYjNctrgYElvG19gEDKy1h1itM7
         +bBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=KmRyp9iGH2ia/dM4+L+AlPWU24ubf//fuPEOuKJI6UE=;
        b=IGKLdcBcxDXCVihXio2uOWGMV6hZ+5W+5MYxOpfxnAZ8MfODmg87JBjBL1IW7KTMud
         IRIsbPTnml01nlNHKm8nCZhaRUektU17fzaGJn+CUnNEKU+ahQZpZyhkDlTmSOFmIjUD
         vV6lqjE9Ah4cO1/jf3cguqIDuxcjuVzSK1FvBzkheWvif74CZueEjR7p0lRkpXiyV09X
         +M43Hxbz9t1ha9SxQ29Jk0qyt6Qjpv7QjWMxD0kG3Ja/w1y42HgbEvIEY33w9n4t6mEA
         3jyZ8/1yXi7jLzKtfwmoRSS57qeqfPLpukNohF/mZufIDFxX9jctveHk8uOCaMoJERI9
         3D7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x28si15777860pff.104.2019.05.07.17.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:10:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:10:13 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga006.jf.intel.com with ESMTP; 07 May 2019 17:10:12 -0700
Subject: [PATCH v2 5/6] PCI/P2PDMA: Track pgmap references per resource,
 not globally
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>, Ira Weiny <ira.weiny@intel.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:26 -0700
Message-ID: <155727338646.292046.9922678317501435597.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for fixing a race between devm_memremap_pages_release()
and the final put of a page from the device-page-map, allocate a
percpu-ref per p2pdma resource mapping.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/pci/p2pdma.c |  124 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 81 insertions(+), 43 deletions(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 595a534bd749..54d475569058 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -20,12 +20,16 @@
 #include <linux/seq_buf.h>
 
 struct pci_p2pdma {
-	struct percpu_ref devmap_ref;
-	struct completion devmap_ref_done;
 	struct gen_pool *pool;
 	bool p2pmem_published;
 };
 
+struct p2pdma_pagemap {
+	struct dev_pagemap pgmap;
+	struct percpu_ref ref;
+	struct completion ref_done;
+};
+
 static ssize_t size_show(struct device *dev, struct device_attribute *attr,
 			 char *buf)
 {
@@ -74,41 +78,45 @@ static const struct attribute_group p2pmem_group = {
 	.name = "p2pmem",
 };
 
+static struct p2pdma_pagemap *to_p2p_pgmap(struct percpu_ref *ref)
+{
+	return container_of(ref, struct p2pdma_pagemap, ref);
+}
+
 static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
 {
-	struct pci_p2pdma *p2p =
-		container_of(ref, struct pci_p2pdma, devmap_ref);
+	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
 
-	complete_all(&p2p->devmap_ref_done);
+	complete(&p2p_pgmap->ref_done);
 }
 
 static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
 {
-	/*
-	 * pci_p2pdma_add_resource() may be called multiple times
-	 * by a driver and may register the percpu_kill devm action multiple
-	 * times. We only want the first action to actually kill the
-	 * percpu_ref.
-	 */
-	if (percpu_ref_is_dying(ref))
-		return;
-
 	percpu_ref_kill(ref);
 }
 
+static void pci_p2pdma_percpu_cleanup(void *ref)
+{
+	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
+
+	wait_for_completion(&p2p_pgmap->ref_done);
+	percpu_ref_exit(&p2p_pgmap->ref);
+}
+
 static void pci_p2pdma_release(void *data)
 {
 	struct pci_dev *pdev = data;
+	struct pci_p2pdma *p2pdma = pdev->p2pdma;
 
-	if (!pdev->p2pdma)
+	if (!p2pdma)
 		return;
 
-	wait_for_completion(&pdev->p2pdma->devmap_ref_done);
-	percpu_ref_exit(&pdev->p2pdma->devmap_ref);
+	/* Flush and disable pci_alloc_p2p_mem() */
+	pdev->p2pdma = NULL;
+	synchronize_rcu();
 
-	gen_pool_destroy(pdev->p2pdma->pool);
+	gen_pool_destroy(p2pdma->pool);
 	sysfs_remove_group(&pdev->dev.kobj, &p2pmem_group);
-	pdev->p2pdma = NULL;
 }
 
 static int pci_p2pdma_setup(struct pci_dev *pdev)
@@ -124,12 +132,6 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
 	if (!p2p->pool)
 		goto out;
 
-	init_completion(&p2p->devmap_ref_done);
-	error = percpu_ref_init(&p2p->devmap_ref,
-			pci_p2pdma_percpu_release, 0, GFP_KERNEL);
-	if (error)
-		goto out_pool_destroy;
-
 	error = devm_add_action_or_reset(&pdev->dev, pci_p2pdma_release, pdev);
 	if (error)
 		goto out_pool_destroy;
@@ -163,6 +165,7 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
 int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			    u64 offset)
 {
+	struct p2pdma_pagemap *p2p_pgmap;
 	struct dev_pagemap *pgmap;
 	void *addr;
 	int error;
@@ -185,14 +188,32 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			return error;
 	}
 
-	pgmap = devm_kzalloc(&pdev->dev, sizeof(*pgmap), GFP_KERNEL);
-	if (!pgmap)
+	p2p_pgmap = devm_kzalloc(&pdev->dev, sizeof(*p2p_pgmap), GFP_KERNEL);
+	if (!p2p_pgmap)
 		return -ENOMEM;
 
+	init_completion(&p2p_pgmap->ref_done);
+	error = percpu_ref_init(&p2p_pgmap->ref,
+			pci_p2pdma_percpu_release, 0, GFP_KERNEL);
+	if (error)
+		goto pgmap_free;
+
+	/*
+	 * FIXME: the percpu_ref_exit needs to be coordinated internal
+	 * to devm_memremap_pages_release(). Duplicate the same ordering
+	 * as other devm_memremap_pages() users for now.
+	 */
+	error = devm_add_action(&pdev->dev, pci_p2pdma_percpu_cleanup,
+			&p2p_pgmap->ref);
+	if (error)
+		goto ref_cleanup;
+
+	pgmap = &p2p_pgmap->pgmap;
+
 	pgmap->res.start = pci_resource_start(pdev, bar) + offset;
 	pgmap->res.end = pgmap->res.start + size - 1;
 	pgmap->res.flags = pci_resource_flags(pdev, bar);
-	pgmap->ref = &pdev->p2pdma->devmap_ref;
+	pgmap->ref = &p2p_pgmap->ref;
 	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
 	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
 		pci_resource_start(pdev, bar);
@@ -201,12 +222,13 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	addr = devm_memremap_pages(&pdev->dev, pgmap);
 	if (IS_ERR(addr)) {
 		error = PTR_ERR(addr);
-		goto pgmap_free;
+		goto ref_exit;
 	}
 
-	error = gen_pool_add_virt(pdev->p2pdma->pool, (unsigned long)addr,
+	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
 			pci_bus_address(pdev, bar) + offset,
-			resource_size(&pgmap->res), dev_to_node(&pdev->dev));
+			resource_size(&pgmap->res), dev_to_node(&pdev->dev),
+			&p2p_pgmap->ref);
 	if (error)
 		goto pages_free;
 
@@ -217,8 +239,10 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 
 pages_free:
 	devm_memunmap_pages(&pdev->dev, pgmap);
+ref_cleanup:
+	percpu_ref_exit(&p2p_pgmap->ref);
 pgmap_free:
-	devm_kfree(&pdev->dev, pgmap);
+	devm_kfree(&pdev->dev, p2p_pgmap);
 	return error;
 }
 EXPORT_SYMBOL_GPL(pci_p2pdma_add_resource);
@@ -555,19 +579,30 @@ EXPORT_SYMBOL_GPL(pci_p2pmem_find_many);
  */
 void *pci_alloc_p2pmem(struct pci_dev *pdev, size_t size)
 {
-	void *ret;
+	void *ret = NULL;
+	struct percpu_ref *ref;
 
+	/*
+	 * Pairs with synchronize_rcu() in pci_p2pdma_release() to
+	 * ensure pdev->p2pdma is non-NULL for the duration of the
+	 * read-lock.
+	 */
+	rcu_read_lock();
 	if (unlikely(!pdev->p2pdma))
-		return NULL;
-
-	if (unlikely(!percpu_ref_tryget_live(&pdev->p2pdma->devmap_ref)))
-		return NULL;
-
-	ret = (void *)gen_pool_alloc(pdev->p2pdma->pool, size);
+		goto out;
 
-	if (unlikely(!ret))
-		percpu_ref_put(&pdev->p2pdma->devmap_ref);
+	ret = (void *)gen_pool_alloc_owner(pdev->p2pdma->pool, size,
+			(void **) &ref);
+	if (!ret)
+		goto out;
 
+	if (unlikely(!percpu_ref_tryget_live(ref))) {
+		gen_pool_free(pdev->p2pdma->pool, (unsigned long) ret, size);
+		ret = NULL;
+		goto out;
+	}
+out:
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(pci_alloc_p2pmem);
@@ -580,8 +615,11 @@ EXPORT_SYMBOL_GPL(pci_alloc_p2pmem);
  */
 void pci_free_p2pmem(struct pci_dev *pdev, void *addr, size_t size)
 {
-	gen_pool_free(pdev->p2pdma->pool, (uintptr_t)addr, size);
-	percpu_ref_put(&pdev->p2pdma->devmap_ref);
+	struct percpu_ref *ref;
+
+	gen_pool_free_owner(pdev->p2pdma->pool, (uintptr_t)addr, size,
+			(void **) &ref);
+	percpu_ref_put(ref);
 }
 EXPORT_SYMBOL_GPL(pci_free_p2pmem);
 

