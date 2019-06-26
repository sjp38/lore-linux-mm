Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3654EC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D53102063F
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:28:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="N//4HeEC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D53102063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA7A48E0018; Wed, 26 Jun 2019 08:28:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE15B8E000E; Wed, 26 Jun 2019 08:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AB8A8E0018; Wed, 26 Jun 2019 08:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 592C08E000E
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:28:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i35so1517823pgi.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:28:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MSqhsOhHHQhh/vRiKblwUI14+k+RDGeRz1Fjt2V0teQ=;
        b=TasEaDV61rdmVbHsVHqh05pe36oRdzApImoUxR8jPnlQNsE3PGi7xINkduF/QingQy
         mCSGrdrJwnYoNcPgWpFjkTPMfoduBufePe9J/+qbZvctrqh3nOjjEUUY5k1sZWXhv2p8
         GaMD7OL2QGJR0E2Y+CuaN5fOyU1vY5m/W1XrRrPCjgKFOqe9czlomoue6ql+pICbQ89N
         65i7/HfwhfoiOgr71NbYyYBGeneEW0kXWBiJlhYBTrlaUTQykzWI/gW4wVVW/LEs9CPo
         Hsy/OCtNUEHKnOBQ4VwL5TtZcX2S8NtNhqaica2nA6lzdQvIMDIuFKKL57uoiEhehNY8
         Nz4g==
X-Gm-Message-State: APjAAAUI+IXTEptlwRbngIul3DFg//qK7JVXiNGRux+K0mYd8UhFB0uQ
	UG0eenubPx3IIc7/8nHTuZyHleIeuFWXJRahp1FqzCTqhtF1Ita9f6v/F2BQBvaah2GWbulz611
	qtRszt8ZhNJcp+lCPgXJkzTciXI2ZNcEUSu0wrlWtr1eQMj3P9NeDAUeRpm4I3+0=
X-Received: by 2002:a63:2323:: with SMTP id j35mr2758351pgj.166.1561552091915;
        Wed, 26 Jun 2019 05:28:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7DWOiGDWNNw9oVvn5plMMoKGsxqvIfeNI6hpeUsKDJ5YO+EBj8TJ97+m6lXxLk+Rvg370
X-Received: by 2002:a63:2323:: with SMTP id j35mr2758287pgj.166.1561552090938;
        Wed, 26 Jun 2019 05:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552090; cv=none;
        d=google.com; s=arc-20160816;
        b=OqLzZvs4jeqtInJ1XFuy41brz5OXyxpyywvZc9TvkTW+r1aDvgP7hwRKkeSKVs1E4N
         8ojkXt9EYO3RrHnj+zvg+fwAF0RC8QlR9ehMpGKBpIFaDXlAMSa9zC5EaHJoH6XwB745
         JS1heKrAnlk8hzz8swTJSDFKoXhGfOViA7KA/fmYlKhV1gJSaczhlo0GqzFtkYAP2+KY
         gAogqs1T+Xcp2vD58xT5L0BsXxH8PqfJyfuXcO803ktxPWWsr8gpZJ8L28LJpVrDpHBw
         dYcPPe+kqGpd4YoUUXuwYpddqksbvhoqF+GEWAASCJSxZUU6Wcj2YqOe2KI8fzdNxkor
         CBJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MSqhsOhHHQhh/vRiKblwUI14+k+RDGeRz1Fjt2V0teQ=;
        b=Wz4o+OLuRtUQHUJAtJj3yB0Qj/tvRMRhocZUeb9b9k/ndGGk8B84JHwuEpmSsOypJm
         NciKUVkyqd6VQdB8LBPikFiOkzB8BSWZesXC92V7PRand8ox8SlyVXNDUxCodEMfsX7g
         goJyumyvRjaYMZQfTTrJfbPFyTG1Qy1Gz+bfYct9EYhQ3GnA5uUu8CthPDt1yeKzrUSM
         OWGUVtthxxomPJlBQuXLR2BL26PNLkgpcVh5gaBkqlfiyHiJ22qxQpjFnXbQzhBxz+bN
         Z2KPYMySHWevNkpLCnM5XYo1cwEMIVvdT1Lka6YA3NWUsjCrPxyccOERw8IkunKmjvMQ
         lrUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N//4HeEC";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v18si3084501ply.276.2019.06.26.05.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:28:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="N//4HeEC";
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=MSqhsOhHHQhh/vRiKblwUI14+k+RDGeRz1Fjt2V0teQ=; b=N//4HeECq3UJOCKX62rkn37gSh
	ROohrNo4+XO2CypRboXwHfZL+x2pNZEqi/UIkkXTH/PQ3nlapb8sMzHVKe1fHcLMMZzb6wYHCmzyH
	DDjydit/uxRXm8YaKxHe3ZtRKYidhunf9j4brsDVxF63wuI/6JXONJeVNPHGm5xq7ao/0hJ+pWvNA
	B389MJkFLJVTCKHUMYaoZaXc109b5oFZFWiSVj2wstJp2EODd1ShO4JNs5qDLmHPnz9nTOowKwXpG
	kdLfgq9FfnwVfh6DxraUsJMGYBfzTxKILw6eBtZgS+WwfEUfRQeXrnJ0FkZJWo4zlmzPKAZv7ufMy
	ndCZw/WA==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71y-0001Vr-Ul; Wed, 26 Jun 2019 12:28:07 +0000
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
Subject: [PATCH 15/25] memremap: provide an optional internal refcount in struct dev_pagemap
Date: Wed, 26 Jun 2019 14:27:14 +0200
Message-Id: <20190626122724.13313-16-hch@lst.de>
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

Provide an internal refcounting logic if no ->ref field is provided
in the pagemap passed into devm_memremap_pages so that callers don't
have to reinvent it poorly.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h          |  4 ++
 kernel/memremap.c                 | 64 ++++++++++++++++++++++++-------
 tools/testing/nvdimm/test/iomap.c | 58 ++++++++++++++++++++++------
 3 files changed, 101 insertions(+), 25 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index e25685b878e9..f8a5b2a19945 100644
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
index eee490e7d7e1..bea6f887adad 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -29,7 +29,7 @@ static void devmap_managed_enable_put(void *data)
 
 static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
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
@@ -175,10 +202,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
 
 	if (need_devmap_managed) {
@@ -296,8 +334,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
index 82f901569e06..cd040b5abffe 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -100,26 +100,60 @@ static void nfit_test_kill(void *_pgmap)
 {
 	struct dev_pagemap *pgmap = _pgmap;
 
-	WARN_ON(!pgmap || !pgmap->ref || !pgmap->ops || !pgmap->ops->kill ||
-		!pgmap->ops->cleanup);
-	pgmap->ops->kill(pgmap);
-	pgmap->ops->cleanup(pgmap);
+	WARN_ON(!pgmap || !pgmap->ref);
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
+}
+
+static void dev_pagemap_percpu_release(struct percpu_ref *ref)
+{
+	struct dev_pagemap *pgmap =
+		container_of(ref, struct dev_pagemap, internal_ref);
+
+	complete(&pgmap->done);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
+	int error;
 	resource_size_t offset = pgmap->res.start;
 	struct nfit_test_resource *nfit_res = get_nfit_res(offset);
 
-	if (nfit_res) {
-		int rc;
-
-		rc = devm_add_action_or_reset(dev, nfit_test_kill, pgmap);
-		if (rc)
-			return ERR_PTR(rc);
-		return nfit_res->buf + offset - nfit_res->res.start;
+	if (!nfit_res)
+		return devm_memremap_pages(dev, pgmap);
+
+	pgmap->dev = dev;
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
-	return devm_memremap_pages(dev, pgmap);
+
+	error = devm_add_action_or_reset(dev, nfit_test_kill, pgmap);
+	if (error)
+		return ERR_PTR(error);
+	return nfit_res->buf + offset - nfit_res->res.start;
 }
 EXPORT_SYMBOL_GPL(__wrap_devm_memremap_pages);
 
-- 
2.20.1

