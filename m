Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18B48C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6A782133F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JsU0PRWo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6A782133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 650308E0013; Wed, 26 Jun 2019 08:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D8878E000E; Wed, 26 Jun 2019 08:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 479438E0013; Wed, 26 Jun 2019 08:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06B458E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so1361798pla.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rtJGcfjUDQlFpvWbHrrX6xK7ULlnRWoqdWy/YtJ84s0=;
        b=f8R2IhTFLMdk8RTqTJVd0NTDxzuorWuBLY5RO+7soA7xg+uTFDxmPh1cKLM1QRorcC
         50AVQ8rD5xjIY+xT8ioY3IOCNTWEAQtZT0nDRIQjLRd4HNrhdqfGp8+7x6FNYk0d1udN
         QiKFwi+i3PGz8TD+4vuReQ34bmTwZvz3w9Szzo9umxUDxBIgCM3MlRZUAWwNH0ttaYCS
         Ezd3CECQbKrQT18hANiKFa+LIQLdFb+K2nwzdpyZmvJ/u/uDl8NVuLVPuX0aZ/9Ie1I3
         CvusVucwV634GjLykJJedG1mDXRqTS2rQZfyG/BGpvoC++eFjtuyAQoHRkt2EZ1AhsYG
         UaZQ==
X-Gm-Message-State: APjAAAVwjaIwmgCXwITTjBGpSYRjv5waXEAvGhqmMENCCLRNkwnYJfAm
	Kn44iPAlL9iqFwIYz0FYo6sESbSA6ZHnxM0sRgxPxrFpF8RJ31OU61p1bnjSohASMOCXVNJaPn0
	lWfFJlDdpcgBXme0HQXZzYPWGJWOaM5SntKezPuuaFfPHE/csuzYd66vGe/bVE3I=
X-Received: by 2002:a63:f959:: with SMTP id q25mr2713819pgk.357.1561552078561;
        Wed, 26 Jun 2019 05:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmCZ/l5zE0i3okNmCloSjh2okVvCGBtz12XlLcAXStA94i2N11+Z2AMd83LJFLBuwYtpNt
X-Received: by 2002:a63:f959:: with SMTP id q25mr2713720pgk.357.1561552077113;
        Wed, 26 Jun 2019 05:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552077; cv=none;
        d=google.com; s=arc-20160816;
        b=pgCdWJ8TfosDxs8sdYmOicq7tCubleOpRSWBFJHkEYyHlIhSC9qyL/YCHW5hFaYr55
         ZkDCI7zAcGCXMN6SSkE1lKdGThOyO3pwuGyjuq04hXf3A/7PVREtRLO1TT9Udt1LUTq6
         ilGvb9X6K1aqcUOwVjd19/7bx40MCaiCC3yj/0myExA7vgw5dAtMy9wq8KtH8uHjFo1/
         Jb7/Wv5lpriSiqenDV8T4NsxAo/nq6F1DBt3VvC61YeZmMXhnknmqigFARYRNbdDLwa8
         7WH2hK4mFUfeJLqnXk6pSsO/6FGEiL+lMwRtw58A4R3j3tgE3d4LIYsP3/wdL69ZBqvU
         6vbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rtJGcfjUDQlFpvWbHrrX6xK7ULlnRWoqdWy/YtJ84s0=;
        b=0hG5luUV+RPBNkYeiCmeY87+BIYAN9EpDkISNzsAqkNNNmtOe87/jwOktYUU99Sroq
         f+d9/olYPHJTuSrqTytq3zzFx0eqoQpJNQxsjkM+5XhjJ/nT2R6DwbxjV6kjYnNARP9C
         QaaMkzIggtqHJiO8ZqtRJCfo5OMLbgsKZ5JPACgsg3tJXvP/6YvuveGvdh8Us778r8R+
         UGzWFnYWXvndGFNaWfXy3fyQyCDTxxi01cRojjWSbV8udYUyvizaJGGmYuQGPT3ytGA/
         w18MN9FhmAzHGNFF1QUMt4QVGXrxUKZJWNHqkn3XaKIcjTfppVboWKYV+0l9GQcTxUYq
         BRZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JsU0PRWo;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 73si15858917pga.407.2019.06.26.05.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JsU0PRWo;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=rtJGcfjUDQlFpvWbHrrX6xK7ULlnRWoqdWy/YtJ84s0=; b=JsU0PRWoaqGs3UQyylIEwmDtdn
	2TemCnUZ66h0rFK9ZysafSXF03WYA9z/emHgo8b6CyUuAvtIgGodgEUSFXvd9srXK0N3Gyr7ROlBx
	bErGCjaOj4Iaq3X2zUgHeTzRcB4pyhFpXsGnR2bEuY/hlS7Wf4MBYVmBc4Zm4/buBbNnp2KSY3tHn
	3VJC6WmHgvAfVbIM5g4LXxoS7dlACia8ntMhn1fWpXgN9XRCge7/U4JYyrVm7KLDaOOMXHhxOOD57
	d1Js7Bb4F9uAiJydcnGC/XehZS0getHOL7CQApbXDT6rGYa2aa7wN10/VDWJV4wj7dts0e6GmZF1k
	RBfdcEFw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71l-0001QQ-QT; Wed, 26 Jun 2019 12:27:54 +0000
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
Subject: [PATCH 10/25] memremap: pass a struct dev_pagemap to ->kill and ->cleanup
Date: Wed, 26 Jun 2019 14:27:09 +0200
Message-Id: <20190626122724.13313-11-hch@lst.de>
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
 drivers/pci/p2pdma.c              |  9 +++++----
 include/linux/memremap.h          |  4 ++--
 kernel/memremap.c                 |  8 ++++----
 mm/hmm.c                          | 10 +++++-----
 tools/testing/nvdimm/test/iomap.c |  4 ++--
 7 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index f390083a64d7..b5257038c188 100644
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
index c2449af2b388..9dac48359353 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -303,24 +303,24 @@ static const struct attribute_group *pmem_attribute_groups[] = {
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
 
@@ -435,7 +435,7 @@ static int pmem_attach_disk(struct device *dev,
 		memcpy(&bb_res, &pmem->pgmap.res, sizeof(bb_res));
 	} else {
 		if (devm_add_action_or_reset(dev, pmem_release_queue,
-					&q->q_usage_counter))
+					&pmem->pgmap))
 			return -ENOMEM;
 		addr = devm_memremap(dev, pmem->phys_addr,
 				pmem->size, ARCH_MEMREMAP_PMEM);
diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index 13f0380a8c7f..ebd8ce3bba2e 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -90,14 +90,15 @@ static void pci_p2pdma_percpu_release(struct percpu_ref *ref)
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
 	percpu_ref_exit(&p2p_pgmap->ref);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 919755f48c7e..b8666a0d8665 100644
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
index 0824237ef979..00c1ceb60c19 100644
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
@@ -294,8 +294,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
index 583a02a16872..987793fba923 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1352,18 +1352,18 @@ static void hmm_devmem_ref_release(struct percpu_ref *ref)
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
index cf3f064a697d..82f901569e06 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -102,8 +102,8 @@ static void nfit_test_kill(void *_pgmap)
 
 	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
 		!pgmap->ops->cleanup);
-	pgmap->ops->kill(pgmap->ref);
-	pgmap->ops->cleanup(pgmap->ref);
+	pgmap->ops->kill(pgmap);
+	pgmap->ops->cleanup(pgmap);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

