Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CCD2C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0048521773
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BNpweUzH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0048521773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4AF6B000C; Sun, 18 Aug 2019 05:12:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55456B000D; Sun, 18 Aug 2019 05:12:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 970506B000E; Sun, 18 Aug 2019 05:12:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id 749B96B000C
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:12:45 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 2A36D8248ABF
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:45 +0000 (UTC)
X-FDA: 75834983490.30.bit91_522904b4dcc3e
X-HE-Tag: bit91_522904b4dcc3e
X-Filterd-Recvd-Size: 8488
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=XHUyB9CWr0UZbWKK6wZpfXFP3u0SKSAB4X0VpzLA/8I=; b=BNpweUzHFydimszWGKSQwsbUDL
	oVWgIkoTWERwtt2ERYmPL6f9bxxBQbkjmVVG6NLRdRnOp7Qus74ojQgbESKr15Seu8JmfkxYuAy24
	RUAC45FOvJK0427ygD1DrBnWk0/XxQj87cjOc/JFggtIlBwrdUQ6rFA+gieqQUeo/WtMIk64Kl6Zz
	GObVorRR+fb4/L2C2+3vImX2eN7ER6xQwtf6pfm5ppeQiiJU2CU4HniN/xfpcm964ksdwskQb/G+Y
	juUbIxEuMge7qw6GCxKGdjhqGJMuzxJcC12Y4/+fTjLdPvnrn9PbEAuh7jn5UBhXcNs2AK+h8ZzMl
	XC11bHeQ==;
Received: from [2001:4bb8:188:24ee:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hzHEu-0001Ew-Vw; Sun, 18 Aug 2019 09:12:41 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 4/4] memremap: provide a not device managed memremap_pages
Date: Sun, 18 Aug 2019 11:05:57 +0200
Message-Id: <20190818090557.17853-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190818090557.17853-1-hch@lst.de>
References: <20190818090557.17853-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kvmppc ultravisor code wants a device private memory pool that is
system wide and not attached to a device.  Instead of faking up one
provide a low-level memremap_pages for it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/memremap.h |  2 +
 kernel/memremap.c        | 84 +++++++++++++++++++++++++---------------
 2 files changed, 54 insertions(+), 32 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 8f0013e18e14..fb2a0bd826b9 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -123,6 +123,8 @@ static inline struct vmem_altmap *pgmap_altmap(struct=
 dev_pagemap *pgmap)
 }
=20
 #ifdef CONFIG_ZONE_DEVICE
+void *memremap_pages(struct dev_pagemap *pgmap, int nid);
+void memunmap_pages(struct dev_pagemap *pgmap);
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)=
;
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 09a087ca30ff..77a77704eb28 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -96,9 +96,8 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgm=
ap)
 	}
 }
=20
-static void devm_memremap_pages_release(void *data)
+void memunmap_pages(struct dev_pagemap *pgmap)
 {
-	struct dev_pagemap *pgmap =3D data;
 	struct resource *res =3D &pgmap->res;
 	unsigned long pfn;
 	int nid;
@@ -128,6 +127,12 @@ static void devm_memremap_pages_release(void *data)
 	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
 	devmap_managed_enable_put();
 }
+EXPORT_SYMBOL_GPL(memunmap_pages);
+
+static void devm_memremap_pages_release(void *data)
+{
+	memunmap_pages(data);
+}
=20
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
 {
@@ -137,27 +142,12 @@ static void dev_pagemap_percpu_release(struct percp=
u_ref *ref)
 	complete(&pgmap->done);
 }
=20
-/**
- * devm_memremap_pages - remap and provide memmap backing for the given =
resource
- * @dev: hosting device for @res
- * @pgmap: pointer to a struct dev_pagemap
- *
- * Notes:
- * 1/ At a minimum the res and type members of @pgmap must be initialize=
d
- *    by the caller before passing it to this function
- *
- * 2/ The altmap field may optionally be initialized, in which case
- *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
- *
- * 3/ The ref field may optionally be provided, in which pgmap->ref must=
 be
- *    'live' on entry and will be killed and reaped at
- *    devm_memremap_pages_release() time, or if this routine fails.
- *
- * 4/ res is expected to be a host memory range that could feasibly be
- *    treated as a "System RAM" range, i.e. not a device mmio range, but
- *    this is not enforced.
+/*
+ * Not device managed version of dev_memremap_pages, undone by
+ * memunmap_pages().  Please use dev_memremap_pages if you have a struct
+ * device available.
  */
-void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
+void *memremap_pages(struct dev_pagemap *pgmap, int nid)
 {
 	struct resource *res =3D &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
@@ -168,7 +158,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 		.altmap =3D pgmap_altmap(pgmap),
 	};
 	pgprot_t pgprot =3D PAGE_KERNEL;
-	int error, nid, is_ram;
+	int error, is_ram;
 	bool need_devmap_managed =3D true;
=20
 	switch (pgmap->type) {
@@ -223,7 +213,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
=20
 	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(res->start), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error =3D -ENOMEM;
 		goto err_array;
@@ -231,7 +221,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
=20
 	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(res->end), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error =3D -ENOMEM;
 		goto err_array;
@@ -252,7 +242,6 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 	if (error)
 		goto err_array;
=20
-	nid =3D dev_to_node(dev);
 	if (nid < 0)
 		nid =3D numa_mem_id();
=20
@@ -308,12 +297,6 @@ void *devm_memremap_pages(struct device *dev, struct=
 dev_pagemap *pgmap)
 				PHYS_PFN(res->start),
 				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
-
-	error =3D devm_add_action_or_reset(dev, devm_memremap_pages_release,
-			pgmap);
-	if (error)
-		return ERR_PTR(error);
-
 	return __va(res->start);
=20
  err_add_memory:
@@ -328,6 +311,43 @@ void *devm_memremap_pages(struct device *dev, struct=
 dev_pagemap *pgmap)
 	devmap_managed_enable_put();
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(memremap_pages);
+
+/**
+ * devm_memremap_pages - remap and provide memmap backing for the given =
resource
+ * @dev: hosting device for @res
+ * @pgmap: pointer to a struct dev_pagemap
+ *
+ * Notes:
+ * 1/ At a minimum the res and type members of @pgmap must be initialize=
d
+ *    by the caller before passing it to this function
+ *
+ * 2/ The altmap field may optionally be initialized, in which case
+ *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
+ *
+ * 3/ The ref field may optionally be provided, in which pgmap->ref must=
 be
+ *    'live' on entry and will be killed and reaped at
+ *    devm_memremap_pages_release() time, or if this routine fails.
+ *
+ * 4/ res is expected to be a host memory range that could feasibly be
+ *    treated as a "System RAM" range, i.e. not a device mmio range, but
+ *    this is not enforced.
+ */
+void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
+{
+	int error;
+	void *ret;
+
+	ret =3D memremap_pages(pgmap, dev_to_node(dev));
+	if (IS_ERR(ret))
+		return ret;
+
+	error =3D devm_add_action_or_reset(dev, devm_memremap_pages_release,
+			pgmap);
+	if (error)
+		return ERR_PTR(error);
+	return ret;
+}
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
=20
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap)
--=20
2.20.1


