Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 509E9C004C9
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0047B214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:10:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0047B214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1C296B026A; Tue,  7 May 2019 20:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CCBE6B026B; Tue,  7 May 2019 20:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2FC6B026C; Tue,  7 May 2019 20:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50DAD6B026A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:10:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so11307317pfm.18
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=L02iG7m5SsIhvrUm8qkkcbYbvcncK7iQivvm3wqwLGM=;
        b=P/k9Is8gwosxUNuFN86WepxFQp0PJWJZBSYj1zusjyNyJ7ro3WRm5DYRsLQoMZWpMl
         jp7dtuJsknwK7FQN0E98h48pB1V0XeLTaX/qnqDOXk6No7uLHhf7vHiR+L0ofew6kyOY
         d8ToOPq9OfwlvQBvhizXqfqY93Tj+M8XO4hnNo9k8k/3b0ocmz4kxAf4NEfQ0wB21nmb
         vH8z3ArTYA5kBpcp8Q4ACGBGErzOHE83GxmHvBFpspeeQGDLy8wpfDEBV8n1/X6nUxAL
         uTZaxlbrmqc2XqFJrIlHCVcSNkLOdWuLzd1LHU7DEu9eoavrpxW5BCYiVVBjko53m7vK
         zAhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVlNXBwiDBvy9GblpRfIoLlIsAHzJ/Wg7E7VfA3ZtxZQJtJs9zo
	j3ZE6KIEZWNq0MLIkspoYsay4cVQlrGf+oqN5R79n4AsA0ErPOq4LCnCs9WXTYoIRR0f6WOoS+g
	lwKbVH9pEQ0NqqcAyVqEDLKD7V1k0pPtlqbbJ0pWxEkUPmUzvSg2euETtAuwwn3gc1w==
X-Received: by 2002:a63:690:: with SMTP id 138mr42674539pgg.415.1557274219934;
        Tue, 07 May 2019 17:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwImg+JH0Mnq9R71/OS4zqJOoR0mEgCQh2YdQ7CuNa/BN0CjPYxtwyHKSyaqrE7xNsZGTRB
X-Received: by 2002:a63:690:: with SMTP id 138mr42674450pgg.415.1557274218801;
        Tue, 07 May 2019 17:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274218; cv=none;
        d=google.com; s=arc-20160816;
        b=rg053JvOzu3tn0WQEEVK3395pZ/Pxgc+aAJs0nfPcE/o6ZsF3LYE/YMVi0GquhMU5O
         vBC/2ucF1DKXRHSIRWuPaN6ZFxn7o9Fod98x5IJWrKZRzbaR//eQo36N37rsjWkE1nJB
         EwthW/hCtXjc+CYeGeqqjdzx4Dnwm8Umlxx7pXDNfrI6lGoNGnd9QbI3KposHX2urVJP
         D5sjiMKYdfb+mJjUdulSw0LvpRHXC6cMV+NsguN2BEapx7HhUvkHsKrPwc9NOqW/Hk6t
         5elHsRm8Ak1Gr6NTOXUqvA6muawKxSPAijudxnwWlwaWowG9Y9bX/r/KYA0LTbDfnYJv
         ik6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=L02iG7m5SsIhvrUm8qkkcbYbvcncK7iQivvm3wqwLGM=;
        b=K2zEIijC0RQkDUizhJy2tXRAnWGx2aLAgEeVO+g3thARzwCxIiWvtQWyBAWOOviqKU
         ttbb+bjc+Q8FWp54Oit7TQfdGiqDcaeGTJhtmxhcs6F6uFqJ85vY4SNxFhzDOcYPXIxI
         1qK5qFuLyRyar+VY5c1TxeeU8jacWQJzhPeKM2td6icpQk0FufkRDaOI86lfNCb33Tin
         5cnAVaR/xydfipOG0J+tfesARgv0JNlFVf2R/WSpl06T8cdkqF62klXSjeI0dp9liU6/
         4n8pklIZ+/h+utguI6EBC4aLgtMRQFeBpwirZrWz7iNbhpRdp9r+f/1QDFMQStMTX7aG
         /Tsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o64si20563938pfa.274.2019.05.07.17.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:10:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:10:18 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 07 May 2019 17:10:18 -0700
Subject: [PATCH v2 6/6] mm/devm_memremap_pages: Fix final page put race
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Christoph Hellwig <hch@lst.de>, Ira Weiny <ira.weiny@intel.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:31 -0700
Message-ID: <155727339156.292046.5432007428235387859.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Logan noticed that devm_memremap_pages_release() kills the percpu_ref
drops all the page references that were acquired at init and then
immediately proceeds to unplug, arch_remove_memory(), the backing pages
for the pagemap. If for some reason device shutdown actually collides
with a busy / elevated-ref-count page then arch_remove_memory() should
be deferred until after that reference is dropped.

As it stands the "wait for last page ref drop" happens *after*
devm_memremap_pages_release() returns, which is obviously too late and
can lead to crashes.

Fix this situation by assigning the responsibility to wait for the
percpu_ref to go idle to devm_memremap_pages() with a new ->cleanup()
callback. Implement the new cleanup callback for all
devm_memremap_pages() users: pmem, devdax, hmm, and p2pdma.

Reported-by: Logan Gunthorpe <logang@deltatee.com>
Fixes: 41e94a851304 ("add devm_memremap_pages")
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c              |   13 +++----------
 drivers/nvdimm/pmem.c             |   17 +++++++++++++----
 drivers/pci/p2pdma.c              |   17 +++--------------
 include/linux/memremap.h          |    2 ++
 kernel/memremap.c                 |   17 ++++++++++++-----
 mm/hmm.c                          |   14 +++-----------
 tools/testing/nvdimm/test/iomap.c |    2 ++
 7 files changed, 38 insertions(+), 44 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e428468ab661..e3aa78dd1bb0 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -27,9 +27,8 @@ static void dev_dax_percpu_release(struct percpu_ref *ref)
 	complete(&dev_dax->cmp);
 }
 
-static void dev_dax_percpu_exit(void *data)
+static void dev_dax_percpu_exit(struct percpu_ref *ref)
 {
-	struct percpu_ref *ref = data;
 	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
 
 	dev_dbg(&dev_dax->dev, "%s\n", __func__);
@@ -468,18 +467,12 @@ int dev_dax_probe(struct device *dev)
 	if (rc)
 		return rc;
 
-	rc = devm_add_action_or_reset(dev, dev_dax_percpu_exit, &dev_dax->ref);
-	if (rc)
-		return rc;
-
 	dev_dax->pgmap.ref = &dev_dax->ref;
 	dev_dax->pgmap.kill = dev_dax_percpu_kill;
+	dev_dax->pgmap.cleanup = dev_dax_percpu_exit;
 	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
-	if (IS_ERR(addr)) {
-		devm_remove_action(dev, dev_dax_percpu_exit, &dev_dax->ref);
-		percpu_ref_exit(&dev_dax->ref);
+	if (IS_ERR(addr))
 		return PTR_ERR(addr);
-	}
 
 	inode = dax_inode(dax_dev);
 	cdev = inode->i_cdev;
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 0279eb1da3ef..1c9181712fa4 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -304,11 +304,19 @@ static const struct attribute_group *pmem_attribute_groups[] = {
 	NULL,
 };
 
-static void pmem_release_queue(void *q)
+static void __pmem_release_queue(struct percpu_ref *ref)
 {
+	struct request_queue *q;
+
+	q = container_of(ref, typeof(*q), q_usage_counter);
 	blk_cleanup_queue(q);
 }
 
+static void pmem_release_queue(void *ref)
+{
+	__pmem_release_queue(ref);
+}
+
 static void pmem_freeze_queue(struct percpu_ref *ref)
 {
 	struct request_queue *q;
@@ -400,12 +408,10 @@ static int pmem_attach_disk(struct device *dev,
 	if (!q)
 		return -ENOMEM;
 
-	if (devm_add_action_or_reset(dev, pmem_release_queue, q))
-		return -ENOMEM;
-
 	pmem->pfn_flags = PFN_DEV;
 	pmem->pgmap.ref = &q->q_usage_counter;
 	pmem->pgmap.kill = pmem_freeze_queue;
+	pmem->pgmap.cleanup = __pmem_release_queue;
 	if (is_nd_pfn(dev)) {
 		if (setup_pagemap_fsdax(dev, &pmem->pgmap))
 			return -ENOMEM;
@@ -426,6 +432,9 @@ static int pmem_attach_disk(struct device *dev,
 		pmem->pfn_flags |= PFN_MAP;
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
 	} else {
+		if (devm_add_action_or_reset(dev, pmem_release_queue,
+					&q->q_usage_counter))
+			return -ENOMEM;
 		addr = devm_memremap(dev, pmem->phys_addr,
 				pmem->size, ARCH_MEMREMAP_PMEM);
 		memcpy(&bb_res, &nsio->res, sizeof(bb_res));
diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 54d475569058..a7a66b958720 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -95,7 +95,7 @@ static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
 	percpu_ref_kill(ref);
 }
 
-static void pci_p2pdma_percpu_cleanup(void *ref)
+static void pci_p2pdma_percpu_cleanup(struct percpu_ref *ref)
 {
 	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
 
@@ -198,16 +198,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	if (error)
 		goto pgmap_free;
 
-	/*
-	 * FIXME: the percpu_ref_exit needs to be coordinated internal
-	 * to devm_memremap_pages_release(). Duplicate the same ordering
-	 * as other devm_memremap_pages() users for now.
-	 */
-	error = devm_add_action(&pdev->dev, pci_p2pdma_percpu_cleanup,
-			&p2p_pgmap->ref);
-	if (error)
-		goto ref_cleanup;
-
 	pgmap = &p2p_pgmap->pgmap;
 
 	pgmap->res.start = pci_resource_start(pdev, bar) + offset;
@@ -218,11 +208,12 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
 		pci_resource_start(pdev, bar);
 	pgmap->kill = pci_p2pdma_percpu_kill;
+	pgmap->cleanup = pci_p2pdma_percpu_cleanup;
 
 	addr = devm_memremap_pages(&pdev->dev, pgmap);
 	if (IS_ERR(addr)) {
 		error = PTR_ERR(addr);
-		goto ref_exit;
+		goto pgmap_free;
 	}
 
 	error = gen_pool_add_owner(pdev->p2pdma->pool, (unsigned long)addr,
@@ -239,8 +230,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 
 pages_free:
 	devm_memunmap_pages(&pdev->dev, pgmap);
-ref_cleanup:
-	percpu_ref_exit(&p2p_pgmap->ref);
 pgmap_free:
 	devm_kfree(&pdev->dev, p2p_pgmap);
 	return error;
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7601ee314c4a..1732dea030b2 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -81,6 +81,7 @@ typedef void (*dev_page_free_t)(struct page *page, void *data);
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
  * @kill: callback to transition @ref to the dead state
+ * @cleanup: callback to wait for @ref to be idle and reap it
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
@@ -92,6 +93,7 @@ struct dev_pagemap {
 	struct resource res;
 	struct percpu_ref *ref;
 	void (*kill)(struct percpu_ref *ref);
+	void (*cleanup)(struct percpu_ref *ref);
 	struct device *dev;
 	void *data;
 	enum memory_type type;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 65afbacab44e..05d1af5a2f15 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -96,6 +96,7 @@ static void devm_memremap_pages_release(void *data)
 	pgmap->kill(pgmap->ref);
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
+	pgmap->cleanup(pgmap->ref);
 
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -134,8 +135,8 @@ static void devm_memremap_pages_release(void *data)
  * 2/ The altmap field may optionally be initialized, in which case altmap_valid
  *    must be set to true
  *
- * 3/ pgmap->ref must be 'live' on entry and will be killed at
- *    devm_memremap_pages_release() time, or if this routine fails.
+ * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
+ *    at devm_memremap_pages_release() time, or if this routine fails.
  *
  * 4/ res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
@@ -151,8 +152,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
 
-	if (!pgmap->ref || !pgmap->kill)
+	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
+		WARN(1, "Missing reference count teardown definition\n");
 		return ERR_PTR(-EINVAL);
+	}
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -163,14 +166,16 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (conflict_pgmap) {
 		dev_WARN(dev, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
-		return ERR_PTR(-ENOMEM);
+		error = -ENOMEM;
+		goto err_array;
 	}
 
 	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
 	if (conflict_pgmap) {
 		dev_WARN(dev, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
-		return ERR_PTR(-ENOMEM);
+		error = -ENOMEM;
+		goto err_array;
 	}
 
 	is_ram = region_intersects(align_start, align_size,
@@ -262,6 +267,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgmap_array_delete(res);
  err_array:
 	pgmap->kill(pgmap->ref);
+	pgmap->cleanup(pgmap->ref);
+
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
diff --git a/mm/hmm.c b/mm/hmm.c
index fe1cd87e49ac..225ade644058 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -975,9 +975,8 @@ static void hmm_devmem_ref_release(struct percpu_ref *ref)
 	complete(&devmem->completion);
 }
 
-static void hmm_devmem_ref_exit(void *data)
+static void hmm_devmem_ref_exit(struct percpu_ref *ref)
 {
-	struct percpu_ref *ref = data;
 	struct hmm_devmem *devmem;
 
 	devmem = container_of(ref, struct hmm_devmem, ref);
@@ -1054,10 +1053,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	if (ret)
 		return ERR_PTR(ret);
 
-	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit, &devmem->ref);
-	if (ret)
-		return ERR_PTR(ret);
-
 	size = ALIGN(size, PA_SECTION_SIZE);
 	addr = min((unsigned long)iomem_resource.end,
 		   (1UL << MAX_PHYSMEM_BITS) - 1);
@@ -1096,6 +1091,7 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.ref = &devmem->ref;
 	devmem->pagemap.data = devmem;
 	devmem->pagemap.kill = hmm_devmem_ref_kill;
+	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
@@ -1133,11 +1129,6 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	if (ret)
 		return ERR_PTR(ret);
 
-	ret = devm_add_action_or_reset(device, hmm_devmem_ref_exit,
-			&devmem->ref);
-	if (ret)
-		return ERR_PTR(ret);
-
 	devmem->pfn_first = devmem->resource->start >> PAGE_SHIFT;
 	devmem->pfn_last = devmem->pfn_first +
 			   (resource_size(devmem->resource) >> PAGE_SHIFT);
@@ -1150,6 +1141,7 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
 	devmem->pagemap.ref = &devmem->ref;
 	devmem->pagemap.data = devmem;
 	devmem->pagemap.kill = hmm_devmem_ref_kill;
+	devmem->pagemap.cleanup = hmm_devmem_ref_exit;
 
 	result = devm_memremap_pages(devmem->device, &devmem->pagemap);
 	if (IS_ERR(result))
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index c6635fee27d8..219dd0a1cb08 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -108,7 +108,9 @@ static void nfit_test_kill(void *_pgmap)
 {
 	struct dev_pagemap *pgmap = _pgmap;
 
+	WARN_ON(!pgmap || !pgmap->ref || !pgmap->kill || !pgmap->cleanup);
 	pgmap->kill(pgmap->ref);
+	pgmap->cleanup(pgmap->ref);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)

