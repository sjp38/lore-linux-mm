Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CF0AC31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEA522089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mht+KGEK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEA522089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 538798E000C; Mon, 17 Jun 2019 08:28:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E99C8E000B; Mon, 17 Jun 2019 08:28:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 313A78E000C; Mon, 17 Jun 2019 08:28:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7C978E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x18so6970405pfj.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/E0slfLWeDjdtwPv18O2DXUsqAiZEZlsuEH6ro3Vi90=;
        b=G++EXzVjklabD0XgXxdquaY/1qdHJE9Isxq46+qYMYb/Th+yENmaRTnn522+rOTQ5w
         mG6J/7z51R9glrMSNBVusaPWyr8cjrYwbh5qOyskdgO3bZItNrOEOsHiSFmTOc/DUTUM
         P2ZBGX8tPIo6391sr+HaEi0d+nNH1GQ3biIE5Vly9YrskblGlAw4K1tu5G7jHNKQ0I6g
         bFjP/bIzFKrrTe6pXzX0jjVXo65M8nonFyK3c2f6k1qIQA5YCAxMQREOlJVt9VsaVIh9
         ihJeARPMT1fMNZCj/nwCR+VaWJk1/BJKo5x+rf75JJ1cSiR5707pqCm9DYCyBesnK4hC
         DGTQ==
X-Gm-Message-State: APjAAAVXv6+vXdY8Q8RFdTtD8BDIRo0wvlqG7+CbW+Hc2ENMOjZshWxE
	2G6mUjwU3pQm3r2HHgLeX3ED79LYr9eOfg51rf0X5xSOU77lTHAW22ZB6hSORiy+ZURtCHebNto
	X9SKwLA0KqmsXEoiZekAbGvWR8uGOfQ3B+LvO805HPxpMMiUCmlN8aFJ+FuyEJxg=
X-Received: by 2002:a63:f957:: with SMTP id q23mr49641612pgk.326.1560774481516;
        Mon, 17 Jun 2019 05:28:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5x6Pro+qYkd1Vse57iORV8o3BIKM41ojx4G1/ZQ6R3USyk5iY/SYf3dHgNfw06BEoifbc
X-Received: by 2002:a63:f957:: with SMTP id q23mr49641555pgk.326.1560774480437;
        Mon, 17 Jun 2019 05:28:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774480; cv=none;
        d=google.com; s=arc-20160816;
        b=YJhXTRumYRoqGVzMs/fPldvpZAHeQ/mOW5FpBzbtL4h2N5f5reHCJ+bO1MdfeWtzSu
         s30LXYpjq6RCnlSAaPmujsuM1dDxJkDwml6p5HN8+j9yedjlIX0UIUhksUgJPoI63hg0
         7nCWcd9OdyI0qrSFyZ/0pc3MB/b3USi4+5ulsMKSc9mejg5gRFLWjQkmATSyPsJqOJPk
         K5rHXQythprlTKwvi189GF2W5MyfpoNwTqnZ0fTW9WSR34bepusgL76bQa3wmlV06RUD
         6rFIJVF1uxQtLFkOeT3lLulpkrYVZKbbuXAvYo6fCtBCsxFeuezN+0vY6B4ioWuj/Vw0
         LjlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/E0slfLWeDjdtwPv18O2DXUsqAiZEZlsuEH6ro3Vi90=;
        b=fKpXQlkC6gcpGxckvTUTX1dHxa/ryqM75T9F+jQWebnUEd6p1mWKSAWE8I0hMZES0o
         e6WATlDHZFqnrD7oK2/EpaT6bjgqH4pJp0A9uKYLPw27lUnkm+xvsqmwQ3tMsuQxfJzo
         Qbcyi2/FBlesPQ5Pp2MwG8ZZfAOoOhMhQPfMAHp08SrqYV1OuztcrJ+hIwHvf7Fa2K6U
         kP69zj/OwVQ6SGZnnOPwA4j+TUSuKzx3ur+TYHSj+lsbAh6TGHkDxX/zgTgYLQGn/wtY
         vlmFU+39Vdsxwok9ChuJPWL5ir5swV2jTELDZwMvx6B09yLmpl5lvDslgax4JR3PoEqL
         u7zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mht+KGEK;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 31si10846288pgo.151.2019.06.17.05.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mht+KGEK;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=/E0slfLWeDjdtwPv18O2DXUsqAiZEZlsuEH6ro3Vi90=; b=mht+KGEKXAnAR1V8Ic6+i6oeHW
	0tWBsrinEJoG1Q6hZYaYJZDrE5WGaooV4xMjhwwD4YH4ibn3pjK8izm0lzl80dlub7D0orE8Fdkf5
	IzofW4vELGo9HDVR8Gwc0xrPDGISCb8EGT81cEagR2geTnwgoEHNfc4dGwCSfRdXcU/IqTpRLx69U
	/yQ1RGQWhb/Jj50NzebHdvB/+B+EqPw7AmGeHKXz5A4TdKANBAkq9sL2W45y72Bzm/RHdno4LDYdl
	VX6SZ0S352riLt1COZSy1nR/GcbbajQqK32Bc73IiJn4fglImtfxfFJHeg0/SX7cLIatO+K34Do2X
	vCG/QNGA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjt-00008z-Cu; Mon, 17 Jun 2019 12:27:57 +0000
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
	linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>
Subject: [PATCH 09/25] memremap: pass a struct dev_pagemap to ->kill and ->cleanup
Date: Mon, 17 Jun 2019 14:27:17 +0200
Message-Id: <20190617122733.22432-10-hch@lst.de>
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

Passing the actual typed structure leads to more understandable code
vs just passing the ref member.

Reported-by: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c              | 12 ++++++------
 drivers/nvdimm/pmem.c             | 18 +++++++++---------
 drivers/pci/p2pdma.c              | 11 ++++++-----
 include/linux/memremap.h          |  4 ++--
 kernel/memremap.c                 |  8 ++++----
 mm/hmm.c                          | 10 +++++-----
 tools/testing/nvdimm/test/iomap.c |  4 ++--
 7 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index cd483050a775..17b46c1a76b4 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -27,21 +27,21 @@ static void dev_dax_percpu_release(struct percpu_ref *ref)
 	complete(&dev_dax->cmp);
 }
 
-static void dev_dax_percpu_exit(struct percpu_ref *ref)
+static void dev_dax_percpu_exit(struct dev_pagemap *pgmap)
 {
-	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
 
 	dev_dbg(&dev_dax->dev, "%s\n", __func__);
 	wait_for_completion(&dev_dax->cmp);
-	percpu_ref_exit(ref);
+	percpu_ref_exit(pgmap->ref);
 }
 
-static void dev_dax_percpu_kill(struct percpu_ref *ref)
+static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
 {
-	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
+	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
 
 	dev_dbg(&dev_dax->dev, "%s\n", __func__);
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
 static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 1a9986dc4dc6..469a0f5b3380 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -311,24 +311,24 @@ static const struct attribute_group *pmem_attribute_groups[] = {
 	NULL,
 };
 
-static void pmem_pagemap_cleanup(struct percpu_ref *ref)
+static void pmem_pagemap_cleanup(struct dev_pagemap *pgmap)
 {
-	struct request_queue *q;
+	struct request_queue *q =
+		container_of(pgmap->ref, struct request_queue, q_usage_counter);
 
-	q = container_of(ref, typeof(*q), q_usage_counter);
 	blk_cleanup_queue(q);
 }
 
-static void pmem_release_queue(void *ref)
+static void pmem_release_queue(void *pgmap)
 {
-	pmem_pagemap_cleanup(ref);
+	pmem_pagemap_cleanup(pgmap);
 }
 
-static void pmem_pagemap_kill(struct percpu_ref *ref)
+static void pmem_pagemap_kill(struct dev_pagemap *pgmap)
 {
-	struct request_queue *q;
+	struct request_queue *q =
+		container_of(pgmap->ref, struct request_queue, q_usage_counter);
 
-	q = container_of(ref, typeof(*q), q_usage_counter);
 	blk_freeze_queue_start(q);
 }
 
@@ -443,7 +443,7 @@ static int pmem_attach_disk(struct device *dev,
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
 	} else {
 		if (devm_add_action_or_reset(dev, pmem_release_queue,
-					&q->q_usage_counter))
+					&pmem->pgmap))
 			return -ENOMEM;
 		addr = devm_memremap(dev, pmem->phys_addr,
 				pmem->size, ARCH_MEMREMAP_PMEM);
diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index e083567d26ef..48a88158e46a 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -90,17 +90,18 @@ static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
 	complete(&p2p_pgmap->ref_done);
 }
 
-static void pci_p2pdma_percpu_kill(struct percpu_ref *ref)
+static void pci_p2pdma_percpu_kill(struct dev_pagemap *pgmap)
 {
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
-static void pci_p2pdma_percpu_cleanup(struct percpu_ref *ref)
+static void pci_p2pdma_percpu_cleanup(struct dev_pagemap *pgmap)
 {
-	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
+	struct p2pdma_pagemap *p2p_pgmap =
+		container_of(pgmap, struct p2pdma_pagemap, pgmap);
 
 	wait_for_completion(&p2p_pgmap->ref_done);
-	percpu_ref_exit(ref);
+	percpu_ref_exit(&p2p_pgmap->ref);
 }
 
 static void pci_p2pdma_release(void *data)
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 1cdcfd595770..cec02d5400f1 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -74,12 +74,12 @@ struct dev_pagemap_ops {
 	/*
 	 * Transition the refcount in struct dev_pagemap to the dead state.
 	 */
-	void (*kill)(struct percpu_ref *ref);
+	void (*kill)(struct dev_pagemap *pgmap);
 
 	/*
 	 * Wait for refcount in struct dev_pagemap to be idle and reap it.
 	 */
-	void (*cleanup)(struct percpu_ref *ref);
+	void (*cleanup)(struct dev_pagemap *pgmap);
 };
 
 /**
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 85635ff57e04..ba7156bd52d1 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -92,10 +92,10 @@ static void devm_memremap_pages_release(void *data)
 	unsigned long pfn;
 	int nid;
 
-	pgmap->ops->kill(pgmap->ref);
+	pgmap->ops->kill(pgmap);
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
-	pgmap->ops->cleanup(pgmap->ref);
+	pgmap->ops->cleanup(pgmap);
 
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -299,8 +299,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:
-	pgmap->ops->kill(pgmap->ref);
-	pgmap->ops->cleanup(pgmap->ref);
+	pgmap->ops->kill(pgmap);
+	pgmap->ops->cleanup(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
diff --git a/mm/hmm.c b/mm/hmm.c
index 694e53bc55f4..ec3bf2c5c699 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1349,18 +1349,18 @@ static void hmm_devmem_ref_release(struct percpu_ref *ref)
 	complete(&devmem->completion);
 }
 
-static void hmm_devmem_ref_exit(struct percpu_ref *ref)
+static void hmm_devmem_ref_exit(struct dev_pagemap *pgmap)
 {
 	struct hmm_devmem *devmem;
 
-	devmem = container_of(ref, struct hmm_devmem, ref);
+	devmem = container_of(pgmap, struct hmm_devmem, pagemap);
 	wait_for_completion(&devmem->completion);
-	percpu_ref_exit(ref);
+	percpu_ref_exit(pgmap->ref);
 }
 
-static void hmm_devmem_ref_kill(struct percpu_ref *ref)
+static void hmm_devmem_ref_kill(struct dev_pagemap *pgmap)
 {
-	percpu_ref_kill(ref);
+	percpu_ref_kill(pgmap->ref);
 }
 
 static vm_fault_t hmm_devmem_fault(struct vm_area_struct *vma,
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index a667d974155e..3a1fa7735f47 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -108,8 +108,8 @@ static void nfit_test_kill(void *_pgmap)
 {
 	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops->kill ||
 		!pgmap->ops->cleanup);
-	pgmap->ops->kill(pgmap->ref);
-	pgmap->ops->cleanup(pgmap->ref);
+	pgmap->ops->kill(pgmap);
+	pgmap->ops->cleanup(pgmap);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

