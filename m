Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D332C3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4604921655
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ScVOhPcz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4604921655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9AE86B000A; Fri, 16 Aug 2019 02:54:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23056B000C; Fri, 16 Aug 2019 02:54:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEBAF6B000D; Fri, 16 Aug 2019 02:54:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id A54246B000A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:54:56 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4B2B9181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:56 +0000 (UTC)
X-FDA: 75827378592.09.move15_48286a96a245f
X-HE-Tag: move15_48286a96a245f
X-Filterd-Recvd-Size: 8557
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YFr/r1WuSTNnE+OoNkjNf7rF5XlC5mR260Fl41QkQtk=; b=ScVOhPczdoQh3syfKvqiHDyb1v
	jJtMUtelYGfsTjCkQb5HfKS7wb8XT5N8KY02z4QsvqIZp3TgnLkUeK32IAudoaO0d61J/gnViDM1b
	RIxKBXUiB4iRMEEPX6+D2bcTFUxDVKzWIhRZjEMKygaAgix7Wofw1xEtKYoGrTlBlNlYQ2U/gb8vP
	+sxPK6xFJKYg8eN9u4lhUVpy4B0dljq0CnHFu+KAR71lqOhmxuq8N14XGj2WK58Gh8/P+QJezepP8
	qcUqfw13++G/pqXpLKkeYWyNgAVLsmU1lX3QxQQB4PQdJIko51aWFCQzqtwBoSQX1dyZQ7KyDUK/Y
	HhJZEzkw==;
Received: from [2001:4bb8:18c:28b5:44f9:d544:957f:32cb] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hyW8R-0008I8-TD; Fri, 16 Aug 2019 06:54:52 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 4/4] memremap: provide a not device managed memremap_pages
Date: Fri, 16 Aug 2019 08:54:34 +0200
Message-Id: <20190816065434.2129-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190816065434.2129-1-hch@lst.de>
References: <20190816065434.2129-1-hch@lst.de>
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
provide a low-level memremap_pages for it.  Note that this function is
not exported, and doesn't have a cleanup routine associated with it to
discourage use from more driver like users.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h |  2 +
 mm/memremap.c            | 84 +++++++++++++++++++++++++---------------
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
diff --git a/mm/memremap.c b/mm/memremap.c
index 4e11da4ecab9..9e163fe367ae 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -102,9 +102,8 @@ static void dev_pagemap_cleanup(struct dev_pagemap *p=
gmap)
 		pgmap->ref =3D NULL;
 }
=20
-static void devm_memremap_pages_release(void *data)
+void memunmap_pages(struct dev_pagemap *pgmap)
 {
-	struct dev_pagemap *pgmap =3D data;
 	struct resource *res =3D &pgmap->res;
 	unsigned long pfn;
 	int nid;
@@ -134,6 +133,12 @@ static void devm_memremap_pages_release(void *data)
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
@@ -143,27 +148,12 @@ static void dev_pagemap_percpu_release(struct percp=
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
@@ -174,7 +164,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 		.altmap =3D pgmap_altmap(pgmap),
 	};
 	pgprot_t pgprot =3D PAGE_KERNEL;
-	int error, nid, is_ram;
+	int error, is_ram;
 	bool need_devmap_managed =3D true;
=20
 	switch (pgmap->type) {
@@ -229,7 +219,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
=20
 	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(res->start), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error =3D -ENOMEM;
 		goto err_array;
@@ -237,7 +227,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
=20
 	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(res->end), NULL);
 	if (conflict_pgmap) {
-		dev_WARN(dev, "Conflicting mapping in same section\n");
+		WARN(1, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		error =3D -ENOMEM;
 		goto err_array;
@@ -258,7 +248,6 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 	if (error)
 		goto err_array;
=20
-	nid =3D dev_to_node(dev);
 	if (nid < 0)
 		nid =3D numa_mem_id();
=20
@@ -314,12 +303,6 @@ void *devm_memremap_pages(struct device *dev, struct=
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
@@ -334,6 +317,43 @@ void *devm_memremap_pages(struct device *dev, struct=
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


