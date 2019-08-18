Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5FCEC3A59E
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A56C62173B
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eHfAZrzi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A56C62173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B946B000A; Sun, 18 Aug 2019 05:12:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A546B000C; Sun, 18 Aug 2019 05:12:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F1036B000D; Sun, 18 Aug 2019 05:12:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1545F6B000A
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:12:42 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BFA6E181AC9B4
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:41 +0000 (UTC)
X-FDA: 75834983322.08.hat44_51b2ed99bdf4d
X-HE-Tag: hat44_51b2ed99bdf4d
X-Filterd-Recvd-Size: 4722
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=b+vo0s9N2g9CNDtpIzFfCAQBglRNbGiW9Jp0nnEhxQw=; b=eHfAZrzirDylAXJSWjBhAngNkE
	0uPVa8U33BCbFJ5FuyG66U51Aakum7WMSPsQu8Wfy8FtWF0TV0X2I+h7bYAkYMrSdQNkJH1DPcLd1
	AUCrVZm7GvKtgCb6HufFhjCISPef39xil1rvUuCQ6U6Q/zz/xfKWaFnmo2U8sUOeT+pBLGI0EaZUq
	gosjp3NIcr7CS2y1Mx66SSW6KIzhQ+NhaB7/eo6LUE7NN3ZqnX48OCKLEUPaX23oGp9rGCBnrCRb0
	cK3fX75riiMU04WEm7SFtiqxtrHul9yOL+OY4TNGn//RmdGLVcwjZBNPp8RSgEpcmoW4JQ61lYXJ+
	cvHghz9w==;
Received: from [2001:4bb8:188:24ee:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hzHEs-00018e-7E; Sun, 18 Aug 2019 09:12:38 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 3/4] memremap: don't use a separate devm action for devmap_managed_enable_get
Date: Sun, 18 Aug 2019 11:05:56 +0200
Message-Id: <20190818090557.17853-4-hch@lst.de>
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

Just clean up for early failures and then piggy back on
devm_memremap_pages_release.  This helps with a pending not device
managed version of devm_memremap_pages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
---
 kernel/memremap.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 600a14cbe663..09a087ca30ff 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -21,13 +21,13 @@ DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
 EXPORT_SYMBOL(devmap_managed_key);
 static atomic_t devmap_managed_enable;
=20
-static void devmap_managed_enable_put(void *data)
+static void devmap_managed_enable_put(void)
 {
 	if (atomic_dec_and_test(&devmap_managed_enable))
 		static_branch_disable(&devmap_managed_key);
 }
=20
-static int devmap_managed_enable_get(struct device *dev, struct dev_page=
map *pgmap)
+static int devmap_managed_enable_get(struct dev_pagemap *pgmap)
 {
 	if (!pgmap->ops || !pgmap->ops->page_free) {
 		WARN(1, "Missing page_free method\n");
@@ -36,13 +36,16 @@ static int devmap_managed_enable_get(struct device *d=
ev, struct dev_pagemap *pgm
=20
 	if (atomic_inc_return(&devmap_managed_enable) =3D=3D 1)
 		static_branch_enable(&devmap_managed_key);
-	return devm_add_action_or_reset(dev, devmap_managed_enable_put, NULL);
+	return 0;
 }
 #else
-static int devmap_managed_enable_get(struct device *dev, struct dev_page=
map *pgmap)
+static int devmap_managed_enable_get(struct dev_pagemap *pgmap)
 {
 	return -EINVAL;
 }
+static void devmap_managed_enable_put(void)
+{
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
=20
 static void pgmap_array_delete(struct resource *res)
@@ -123,6 +126,7 @@ static void devm_memremap_pages_release(void *data)
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
 	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
+	devmap_managed_enable_put();
 }
=20
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
@@ -212,7 +216,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 	}
=20
 	if (need_devmap_managed) {
-		error =3D devmap_managed_enable_get(dev, pgmap);
+		error =3D devmap_managed_enable_get(pgmap);
 		if (error)
 			return ERR_PTR(error);
 	}
@@ -321,6 +325,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
  err_array:
 	dev_pagemap_kill(pgmap);
 	dev_pagemap_cleanup(pgmap);
+	devmap_managed_enable_put();
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
--=20
2.20.1


