Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8325CC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3214E2075E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3214E2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCF6D6B026E; Fri, 29 Mar 2019 11:40:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D56BF6B026F; Fri, 29 Mar 2019 11:40:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF9DA6B0270; Fri, 29 Mar 2019 11:40:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8305C6B026E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:40:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so1742927pfo.2
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:40:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=9jYpiNvxrjAb8tEF/6LpJuv4nBpUNEzwmCJO9xz0jaY=;
        b=WlAEKrBJ3EMayedUxEMhaIDrif1X6lKx/pACvtJ+pDTKLUsmmPku6J5XsjVfQnpVwk
         OPFYqvHC69LmLWwAXFfTyv0WMdOwMo6B11icL7THbV4EOKcfxkPhcCPh/gh12PJxKgru
         wAx8V+Y3rKO6TnKgK6esM04OGqWO9/JTgDDInb4PvxQ3OK6fqTYeksKIaFFCl6dgQlMe
         fYkQostolbxiRklMW+FTSeddx2IphzAEcEKc+wdLJm1AEmoigJqZ/G3DytYa4z+CmCcL
         vMVjQykZnfrF/fJyJ/J8ZrZ/J3LMKyZdXQR1KQMCWTdbNlh0yWFROl7grmsDFsJPc0hT
         TXpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXOXVrCVRiLOTwKwkppnj7rcOcvxr3k6iep+3PH4sApIMno6mjN
	jwjhRLebh+UunI2Pw83+ixlHYiRUIh9TCQD/I4GwY9Holfqh5fvJOH1dwwv92ZRMvTDFhYJy/3J
	Di2DMAq/FicIcD6dGH9DOFU7pT/rDP8zzZgZI3dZeE0uoXFsLRLM88Z+6s6fAbqZJYA==
X-Received: by 2002:a62:1d0d:: with SMTP id d13mr13126074pfd.96.1553874032110;
        Fri, 29 Mar 2019 08:40:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8Xdo0X9XDrJErtGB4zMH2wLpZKZeJavyohejLILZKNdcIfH2JbriK7Sdd8DplTjfepqAS
X-Received: by 2002:a62:1d0d:: with SMTP id d13mr13125992pfd.96.1553874031179;
        Fri, 29 Mar 2019 08:40:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874031; cv=none;
        d=google.com; s=arc-20160816;
        b=ML6WPUCk2bg1tyZN6HbVAqiwcxt+WJoohXyJHVwW47SBOJsAwmSjWP/UPpWR2xWsHN
         5UYwEczsxudBwFawsZalRQrz4I2ls3bCtY3AYQvopcn8HQOwnvzwLTTln4V4PuXQS42+
         R2ysaYVVxO3SygKWJ1Pimm2f4dABqSK2bus0zW2b4NJYY/avHqc3y9fco2AjcTBBqul3
         /xwyTA6LDV02Ex6Jw8yB3orkjq+yJvtExkukOgv6a6crdKlL1vKIQD9S9MlZNvprAvg5
         +CoCG59jlaLTNSHMxUY96i84yOKEvEIlF0Kv7G4JV8q3y+xGDNsBvGvX3N3DKu3e8QPa
         6gdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=9jYpiNvxrjAb8tEF/6LpJuv4nBpUNEzwmCJO9xz0jaY=;
        b=jbqN5ns+tOVwp1eYCSqbIGO4EkYfufblN35G1zcrkQxwnZ9ddHVZhNMBnpbwAenGpP
         4uv5nLzt4j9AnEH5ECvFtuJQhSuhuBqAfSikFa8fZgJ74mQGm4lKcqU5tpEZfVLA7hiM
         +DNbwtFebN1NV1mhUF3mZ4FzMIZg6aBYLfGzBb6t82DmVrBzdHtGOZJGTavMq9UvLHuE
         XYeVvVSjRzf9ME0rr6QsIg8U/XUtM+7acc0erFlJ87AzjsAcMfRVprfmshSxdkOABsy4
         JpHt4VuFU6o9qPYu6IUj6f4Ne2oNYnAdf5JG35ORth5huMXBRByvsEQ0Rj0PKY2ojAH5
         QZ8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b7si2240094pla.195.2019.03.29.08.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:40:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 08:40:30 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,284,1549958400"; 
   d="scan'208";a="144965899"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by FMSMGA003.fm.intel.com with ESMTP; 29 Mar 2019 08:40:29 -0700
Subject: [PATCH 5/6] pci/p2pdma: Track pgmap references per resource,
 not globally
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-pci@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 29 Mar 2019 08:27:50 -0700
Message-ID: <155387327020.2443841.6446837127378298192.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/pci/p2pdma.c |  114 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 73 insertions(+), 41 deletions(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 595a534bd749..1b96c1688715 100644
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
@@ -74,28 +78,31 @@ static const struct attribute_group p2pmem_group = {
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
@@ -103,12 +110,12 @@ static void pci_p2pdma_release(void *data)
 	if (!pdev->p2pdma)
 		return;
 
-	wait_for_completion(&pdev->p2pdma->devmap_ref_done);
-	percpu_ref_exit(&pdev->p2pdma->devmap_ref);
+	/* Flush and disable pci_alloc_p2p_mem() */
+	pdev->p2pdma = NULL;
+	synchronize_rcu();
 
 	gen_pool_destroy(pdev->p2pdma->pool);
 	sysfs_remove_group(&pdev->dev.kobj, &p2pmem_group);
-	pdev->p2pdma = NULL;
 }
 
 static int pci_p2pdma_setup(struct pci_dev *pdev)
@@ -124,12 +131,6 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
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
@@ -163,6 +164,7 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
 int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			    u64 offset)
 {
+	struct p2pdma_pagemap *p2p_pgmap;
 	struct dev_pagemap *pgmap;
 	void *addr;
 	int error;
@@ -185,14 +187,32 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
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
@@ -201,12 +221,13 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
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
 
@@ -217,8 +238,10 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 
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
@@ -555,19 +578,25 @@ EXPORT_SYMBOL_GPL(pci_p2pmem_find_many);
  */
 void *pci_alloc_p2pmem(struct pci_dev *pdev, size_t size)
 {
-	void *ret;
+	void *ret = NULL;
+	struct percpu_ref *ref;
 
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
@@ -580,8 +609,11 @@ EXPORT_SYMBOL_GPL(pci_alloc_p2pmem);
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
 

