Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F44EC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AC2121473
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 09:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VblDbKsZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AC2121473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A10AD6B026B; Thu, 13 Jun 2019 05:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94BB36B026C; Thu, 13 Jun 2019 05:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C5C06B026D; Thu, 13 Jun 2019 05:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC946B026B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u21so10989191pfn.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 02:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+F36Qtp9KNZlJRbFfbQN1eq8EHq+227/7sfzGGclHLw=;
        b=gO5X9JPQJfoN15ilVkCvcbklXNw6+CIShPiG3h4GadFWATIRhYgCPgc3k7UKeG2W9+
         kuAPxTE+J5mmhvcoFBHHFgpiXciIJMKcDf5FdoBZyLwldl31tjRkANgp4Z4xzsfjxmVC
         A96gaiZHLkSWS2UqO1YWmwaZ+lQAmJqCkQHCKf06W60AUD8Ity53uO347YokfKycG2iY
         VVSDut7ixn6mXYkXtIWNxHNg6x2vBldhULGYl3QstX+PsGqIFS3r490xxbPN95wv3IXs
         5B6J0aMILNijtix8wclcpzIwQuj+hj1iaW69RyVIEDYu1MCm9mvb7cl8vpmrM3lbNHmm
         pdiA==
X-Gm-Message-State: APjAAAVTxVmuiH7jnsGXifxIFpCzeYU52KI0NEMEQOcHAgkNE2d4YAD2
	pBYdTpvbQTNHB/1ZVVvqVHke2V0I22zL70TnZq2jK+11/aJUcTN0HEhA/PPTZh2HflwKIQyeonS
	DCBDwHqj733jxYIrdM8YDk80ItZjBL5jnnn0oXYopsrY7l7N6KQbvKsd3xrnkZQw=
X-Received: by 2002:a17:90a:7f02:: with SMTP id k2mr4380174pjl.78.1560419047893;
        Thu, 13 Jun 2019 02:44:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySzrQQcDOgwP95BvsVCOVNkBjigqHxvIEiwByaw4e4bjyyJqUDUKlVUC3UwOm9+5xcQF4W
X-Received: by 2002:a17:90a:7f02:: with SMTP id k2mr4380057pjl.78.1560419046937;
        Thu, 13 Jun 2019 02:44:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560419046; cv=none;
        d=google.com; s=arc-20160816;
        b=I6kqfVFJ7tbRVQKMiR+K5q1fCZbUSiS6vGgCsHv9Dv+YZ6HrlaLbHGMtsSrB/k6a9D
         NeKaiclDhKka2szzeBir9h3g8QpFu5EoLc3jOLpMeWiIgrKzhFip2nAQgqtxxh5CrxSL
         Pn5WZPC8lnmR0n+yr+mG6V6ZEaFbea2+dM1kqPJUT4w+mu/jvu0y/Bib7sK6s9EcBkE8
         HptggjIJrTe6H9iZZTSmPD6dsXTdJXu/TodlACGep6k5+cf/yvq2vZteRjV4whSCqptZ
         emInILgQP6PPIxN9e5tHDI+/c7ATvRktLOMRnQxVYYee85hZs4Zacqp4Own4EB9UWQhl
         lh+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+F36Qtp9KNZlJRbFfbQN1eq8EHq+227/7sfzGGclHLw=;
        b=EJYvk2mP9uazVEfYTJtif2fjR/AbcaaTsINWf/a1wHKQ27QcYOAYOJBrcp4L3UAokH
         v0h5UzqK88brIbnULMYeHExk90RtyNhWM62nc+rn53vwdE4tluf07N6rfAzk0O9S8Ca4
         jpG7h1OC9nNWzDWr5odWeVMUvdumT3aWDZNyvvWtCnpr1Gi98DnGfq76th5PfOsj6+7d
         w9zEuKD2nwew1ZMkr2szuZiEBwvw9IqZJqh4j8u9r1NvPRRplZZeJ2ABE1EgHtwHmU9e
         U1Fy3tvViRxaSwB6QGlLlM8ciG6ScGbb1UmdOS25pzKeOuxSccUtbSJVzB8xJaW1Cyzm
         s9pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VblDbKsZ;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b6si2691531pgq.465.2019.06.13.02.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 13 Jun 2019 02:44:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VblDbKsZ;
       spf=pass (google.com: best guess record for domain of batv+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aff2f865c54b6c032bcd+5772+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=+F36Qtp9KNZlJRbFfbQN1eq8EHq+227/7sfzGGclHLw=; b=VblDbKsZb0RRpnPdAvevOdbtuG
	06yzYUmtWkiIPsoP1nmvo3AnrsDTuJovv6fNdum1MQwQKL25pb99SXJvc4gW0o62hlT7lLlTc/WjS
	K8qZKqiBN5WxofN6jGW7fAo3QUQf+dfuCfyvrfo4N272eB6mZoLfEfgv+BoGYRDNyl7Vb5xEuzWlM
	N6FMty3/n4xFBrIv2BT8kRH14dLL54XD4q2x0fsA6G1rQEvtBsX62S7CCnV4Mt/JdWcLV2XjWf64q
	xbmSBMtbYVIv7Cq/AJJH58RKU1ONXDRSyMYUcP30T1sQI1wMywIlngAo880SbnoVdXJORn4vkMSFl
	G7SCcZbA==;
Received: from mpp-cp1-natpool-1-198.ethz.ch ([82.130.71.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbMH5-0001qr-IT; Thu, 13 Jun 2019 09:44:03 +0000
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
Subject: [PATCH 12/22] memremap: provide an optional internal refcount in struct dev_pagemap
Date: Thu, 13 Jun 2019 11:43:15 +0200
Message-Id: <20190613094326.24093-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
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
 include/linux/memremap.h          |  4 +++
 kernel/memremap.c                 | 60 ++++++++++++++++++++++++++-----
 tools/testing/nvdimm/test/iomap.c |  9 +++--
 3 files changed, 62 insertions(+), 11 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 75b80de6394a..b77ed00851ce 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -88,6 +88,8 @@ struct dev_pagemap_ops {
  * @altmap: pre-allocated/reserved memory for vmemmap allocations
  * @res: physical address range covered by @ref
  * @ref: reference count that pins the devm_memremap_pages() mapping
+ * @internal_ref: internal reference if @ref is not provided by the caller
+ * @done: completion for @internal_ref
  * @dev: host device of the mapping for debug
  * @data: private data pointer for page_free()
  * @type: memory type: see MEMORY_* in memory_hotplug.h
@@ -98,6 +100,8 @@ struct dev_pagemap {
 	bool altmap_valid;
 	struct resource res;
 	struct percpu_ref *ref;
+	struct percpu_ref internal_ref;
+	struct completion done;
 	struct device *dev;
 	enum memory_type type;
 	u64 pci_p2pdma_bus_offset;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5c94ad4f5783..edca4389da68 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -83,6 +83,14 @@ static unsigned long pfn_next(unsigned long pfn)
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
 static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap = data;
@@ -92,7 +100,8 @@ static void devm_memremap_pages_release(void *data)
 	unsigned long pfn;
 	int nid;
 
-	pgmap->ops->kill(pgmap);
+	dev_pagemap_kill(pgmap);
+
 	for_each_device_pfn(pfn, pgmap)
 		put_page(pfn_to_page(pfn));
 
@@ -121,20 +130,37 @@ static void devm_memremap_pages_release(void *data)
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
+static void dev_pagemap_percpu_exit(void *data)
+{
+	struct dev_pagemap *pgmap = data;
+
+	wait_for_completion(&pgmap->done);
+	percpu_ref_exit(pgmap->ref);
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
  * 2/ The altmap field may optionally be initialized, in which case altmap_valid
  *    must be set to true
  *
- * 3/ pgmap->ref must be 'live' on entry and will be killed at
- *    devm_memremap_pages_release() time, or if this routine fails.
+ * 3/ The ref field may optionally be provided, in which pgmap->ref must be
+ *    'live' on entry and will be killed at devm_memremap_pages_release() time,
+ *    or if this routine fails.
  *
  * 4/ res is expected to be a host memory range that could feasibly be
  *    treated as a "System RAM" range, i.e. not a device mmio range, but
@@ -156,10 +182,26 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
 
-	if (!pgmap->ref || !pgmap->ops || !pgmap->ops->kill)
-		return ERR_PTR(-EINVAL);
+	if (!pgmap->ref) {
+		if (pgmap->ops && pgmap->ops->kill)
+			return ERR_PTR(-EINVAL);
+
+		init_completion(&pgmap->done);
+		error = percpu_ref_init(&pgmap->internal_ref,
+				dev_pagemap_percpu_release, 0, GFP_KERNEL);
+		if (error)
+			return ERR_PTR(error);
+		pgmap->ref = &pgmap->internal_ref;
+		error = devm_add_action_or_reset(dev, dev_pagemap_percpu_exit,
+				pgmap);
+		if (error)
+			return ERR_PTR(error);
+	} else {
+		if (!pgmap->ops || !pgmap->ops->kill)
+			return ERR_PTR(-EINVAL);
+	}
 
-	if (pgmap->ops->page_free) {
+	if (pgmap->ops && pgmap->ops->page_free) {
 		error = dev_pagemap_enable(dev);
 		if (error)
 			return ERR_PTR(error);
@@ -272,7 +314,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:
-	pgmap->ops->kill(pgmap);
+	dev_pagemap_kill(pgmap);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index ee07c4de2b35..3d0e916f9fff 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -104,9 +104,14 @@ void *__wrap_devm_memremap(struct device *dev, resource_size_t offset,
 }
 EXPORT_SYMBOL(__wrap_devm_memremap);
 
-static void nfit_test_kill(void *pgmap)
+static void nfit_test_kill(void *data)
 {
-	pgmap->ops->kill(pgmap);
+	struct dev_pagemap *pgmap = data;
+
+	if (pgmap->ops && pgmap->ops->kill)
+		pgmap->ops->kill(pgmap);
+	else
+		percpu_ref_kill(pgmap->ref);
 }
 
 void *__wrap_devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
-- 
2.20.1

