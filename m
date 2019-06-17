Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9BFBC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93D1620657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hceq9aC6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93D1620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6788E0011; Mon, 17 Jun 2019 08:28:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18F0C8E000B; Mon, 17 Jun 2019 08:28:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 056878E0011; Mon, 17 Jun 2019 08:28:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3E348E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c18so7675033pgk.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GlNxVMm8W4O5v065JMNFU6bkRl3AbEbXSnrBr8peAhc=;
        b=uL8NUXMiHdoL0XUr+wGAiAaPqpQL3dCL1Ko2/LBtvCO2JQsFEONnZ3SkeO6OXyQqrP
         SnaNsWp1TyvXBacVeYDgv7gidSEZzr/K/fC2v8QKlTbfYor8vGZKjk8qxoLC484/KppE
         +yfVjxzscH4iu2TAJbbsJLcF5VepCwM9PVwuoQ1A5fFXWiP+gfKMp2wOJ/tqmmfzvPtl
         Mei72x1PHn/rnWB4oU3bBRUtqyLuBmxTQcYNJAoYI8Y1qzTA6Sj16srnPBW6AgralJeT
         hpYOK6yCLfiHd4siY2BysoUJmM1EljVR/Syf2oA+A9IW4k7iLeZxCvSA9gb2ZMiroryc
         A9Eg==
X-Gm-Message-State: APjAAAVGa4aIuTWbBYoCUKNtKmjvHeucdRccv0+bzguGQrrgBwAcGlnm
	G6IUuQ/D7xCloaX6OkaNweRRDGTgWTmQdMX2GjfBMMIFaFXJQzjdVdgXUuZu5FfDMjSWWHILslL
	zy7Mbe+6jBj5arKxXRFMi4/Lk618dUhvZpYsgmljXi92yLIRC5szcPNg1C5iYVIA=
X-Received: by 2002:a62:ce4f:: with SMTP id y76mr30447961pfg.21.1560774492405;
        Mon, 17 Jun 2019 05:28:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Kw5irBbvopBWrbsOwD34nSjc2zHrH9Axr5+QgUwHDyTOx+phbtAkEH9+bqY9z7Fa5Owd
X-Received: by 2002:a62:ce4f:: with SMTP id y76mr30447914pfg.21.1560774491491;
        Mon, 17 Jun 2019 05:28:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774491; cv=none;
        d=google.com; s=arc-20160816;
        b=lIXdhI6+7EwmRDmEf+QUUCLh57Vh5rMb2NBccKIFs2wOJVIe5MoDzwVYgSmOX/c/lC
         v1uzCQsU3tNF4BHxuebaMyeEkY/c9HI3Le/Pli9os/Cyoob4QvlBSMbqJ29lkZjkQSkn
         WdEmXDIoqQNpfuJSMVKh0RXkPLsZ6Vr4k8GT9vbD17wvHKJdFLSxRgGtZ1IeYG49Rv8X
         lh6em34L4XEG4PGcRXF+kfjicQAWkM9wkiJPD5A74Lwc4m0vV0cCXkDxiHMt4wbHQYlY
         YC5CZib1naQcTkl9H9MbzMytEYyBqczkmRa8uXcCbYCvbEQxenCtroH+Lzaz8beT+F0z
         ZYig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GlNxVMm8W4O5v065JMNFU6bkRl3AbEbXSnrBr8peAhc=;
        b=s+T3jxOEe5261bUObdE6f2OX45KC5rI3qogYZLNPes3CTlNgatc9C9jXzMf4hW9C9w
         IdNiL8E++n7dTYjXyn59Pj55O0pBdoHaM91DxQpDrazn0zKAEf0hHyvnogXDr5B4RmM5
         wsp3q8vDeAi47jDSgryqgbMxohgajHcmljVP+Cj1RY6ASGUfWjV+E6GEJnP2BheoQCsE
         zoBtrP48Bo1ObTNM+XL1uSIxzIgiYcqO+yi827Qphu0pFROs1rytGvpVxY2aKA6qdqhq
         nRo+GB2WvCeO8e2p0UDq4fYeSZO0VoOu5dzrC2ZV0LT8jf7uJejAtioMAp3k7JZLRVCn
         ul4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hceq9aC6;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k15si10763225pgh.331.2019.06.17.05.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hceq9aC6;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=GlNxVMm8W4O5v065JMNFU6bkRl3AbEbXSnrBr8peAhc=; b=hceq9aC6tJ73idi0gys5khCNkb
	4oa/Hc09tP2sutmhvsQMCCgbZeQ65RgYiliHtKl5ES7k4PIx5QoJOmP158XuVwgiaDMwakShQWbmE
	2BQA9YBQorrWSgUr5kX4t9vAcPMRIvxeaD7vV44sRG6NUoWodLAfV48Htg6MQ2WO2MAtKlChRMtf5
	wCam1QxlrgXhMZA6F9p2gc2Ek7aGGPTwazLl9Df998k9Zp7cthixwUdhiZdLy/lL4lTfdFLHfTxA4
	MgbRgO934AqctA5SWdhgmmfrTW0+igprb3FsAQeA/tukrmljjK2fU4vyzRWkn67p8G3T2FPFSv6xF
	0pBQDtSw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqk4-0000Ep-9f; Mon, 17 Jun 2019 12:28:08 +0000
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
Subject: [PATCH 14/25] memremap: provide an optional internal refcount in struct dev_pagemap
Date: Mon, 17 Jun 2019 14:27:22 +0200
Message-Id: <20190617122733.22432-15-hch@lst.de>
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

Provide an internal refcounting logic if no ->ref field is provided
in the pagemap passed into devm_memremap_pages so that callers don't
have to reinvent it poorly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h          |  4 ++
 kernel/memremap.c                 | 64 ++++++++++++++++++++++++-------
 tools/testing/nvdimm/test/iomap.c | 17 ++++++--
 3 files changed, 68 insertions(+), 17 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7289eb091b04..7e0f072ddce7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -95,6 +95,8 @@ struct dev_pagemap_ops {
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
+ * @internal_ref: internal reference if @ref is not provided by the caller
+ * @done: completion for @internal_ref
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
@@ -105,6 +107,8 @@ struct dev_pagemap {
 	struct vmem_altmap altmap;
 	struct resource res;
 	struct percpu_ref *ref;
+	struct percpu_ref internal_ref;
+	struct completion done;
 	struct device *dev;
 	enum memory_type type;
 	unsigned int flags;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index b41d98a64ebf..60693a1e8e92 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -29,7 +29,7 @@ static void dev_pagemap_put_ops(void *data)
 
 static int dev_pagemap_get_ops(struct device *dev, struct dev_pagemap *pgmap)
 {
-	if (!pgmap->ops->page_free) {
+	if (!pgmap->ops || !pgmap->ops->page_free) {
 		WARN(1, "Missing page_free method\n");
 		return -EINVAL;
 	}
@@ -75,6 +75,24 @@ static unsigned long pfn_next(unsigned long pfn)
 #define for_each_device_pfn(pfn, map) \
 	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn = pfn_next(pfn))
 
+static void dev_pagemap_kill(struct dev_pagemap *pgmap)
+{
+	if (pgmap->ops && pgmap->ops->kill)
+		pgmap->ops->kill(pgmap);
+	else
+		percpu_ref_kill(pgmap->ref);
+}
+
+static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
+{
+	if (pgmap->ops && pgmap->ops->cleanup) {
+		pgmap->ops->cleanup(pgmap);
+	} else {
+		wait_for_completion(&pgmap->done);
+		percpu_ref_exit(pgmap->ref);
+	}
+}
+
 static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap = data;
@@ -84,10 +102,10 @@ static void devm_memremap_pages_release(void *data)
 	unsigned long pfn;
 	int nid;
 
-	pgmap->ops->kill(pgmap);
+	dev_pagemap_kill(pgmap);
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
-	pgmap->ops->cleanup(pgmap);
+	dev_pagemap_cleanup(pgmap);
 
 	/* pages are dead and unused, undo the arch mapping */
 	align_start = res->start & ~(SECTION_SIZE - 1);
@@ -114,20 +132,29 @@ static void devm_memremap_pages_release(void *data)
 		      "%s: failed to free all reserved pages\n", __func__);
 }
 
+static void dev_pagemap_percpu_release(struct percpu_ref *ref)
+{
+	struct dev_pagemap *pgmap =
+		container_of(ref, struct dev_pagemap, internal_ref);
+
+	complete(&pgmap->done);
+}
+
 /**
  * devm_memremap_pages - remap and provide memmap backing for the given resource
  * @dev: hosting device for @res
  * @pgmap: pointer to a struct dev_pagemap
  *
  * Notes:
- * 1/ At a minimum the res, ref and type and ops members of @pgmap must be
- *    initialized by the caller before passing it to this function
+ * 1/ At a minimum the res and type members of @pgmap must be initialized
+ *    by the caller before passing it to this function
  *
  * 2/ The altmap field may optionally be initialized, in which case
  *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
  *
- * 3/ pgmap->ref must be 'live' on entry and will be killed and reaped
- *    at devm_memremap_pages_release() time, or if this routine fails.
+ * 3/ The ref field may optionally be provided, in which pgmap->ref must be
+ *    'live' on entry and will be killed and reaped at
+ *    devm_memremap_pages_release() time, or if this routine fails.
  *
  * 4/ res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
@@ -178,10 +205,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		break;
 	}
 
-	if (!pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
-	    !pgmap->ops->cleanup) {
-		WARN(1, "Missing reference count teardown definition\n");
-		return ERR_PTR(-EINVAL);
+	if (!pgmap->ref) {
+		if (pgmap->ops && (pgmap->ops->kill || pgmap->ops->cleanup))
+			return ERR_PTR(-EINVAL);
+
+		init_completion(&pgmap->done);
+		error = percpu_ref_init(&pgmap->internal_ref,
+				dev_pagemap_percpu_release, 0, GFP_KERNEL);
+		if (error)
+			return ERR_PTR(error);
+		pgmap->ref = &pgmap->internal_ref;
+	} else {
+		if (!pgmap->ops || !pgmap->ops->kill || !pgmap->ops->cleanup) {
+			WARN(1, "Missing reference count teardown definition\n");
+			return ERR_PTR(-EINVAL);
+		}
 	}
 
 	if (pgmap->type != MEMORY_DEVICE_PCI_P2PDMA) {
@@ -299,8 +337,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:
-	pgmap->ops->kill(pgmap);
-	pgmap->ops->cleanup(pgmap);
+	dev_pagemap_kill(pgmap);
+	dev_pagemap_cleanup(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index 3a1fa7735f47..8cd9b9873a7f 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -106,10 +106,19 @@ EXPORT_SYMBOL(__wrap_devm_memremap);
 
 static void nfit_test_kill(void *_pgmap)
 {
-	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops->kill ||
-		!pgmap->ops->cleanup);
-	pgmap->ops->kill(pgmap);
-	pgmap->ops->cleanup(pgmap);
+	WARN_ON(!pgmap || !pgmap->ref)
+
+	if (pgmap->ops && pgmap->ops->kill)
+		pgmap->ops->kill(pgmap);
+	else
+		percpu_ref_kill(pgmap->ref);
+
+	if (pgmap->ops && pgmap->ops->cleanup) {
+		pgmap->ops->cleanup(pgmap);
+	} else {
+		wait_for_completion(&pgmap->done);
+		percpu_ref_exit(pgmap->ref);
+	}
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

