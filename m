Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55789C41514
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A67B21655
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="I3T8QraO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A67B21655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEE326B0008; Fri, 16 Aug 2019 02:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C76616B000A; Fri, 16 Aug 2019 02:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B66E46B000C; Fri, 16 Aug 2019 02:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id 89FAC6B0008
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:54:52 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 266EE81D6
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:52 +0000 (UTC)
X-FDA: 75827378424.02.ring01_4790340239956
X-HE-Tag: ring01_4790340239956
X-Filterd-Recvd-Size: 4622
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tXcE1XGfAjBldp4qZPqG6onLgHm1jEyfgSiznWOouFY=; b=I3T8QraOQoXLX7b/3Lnh/DGNnY
	0Lo8ks5Flw6fLn8VtJSnb6371a63J3dg/ngEtGCdAP3hO3S2xSjjMgjCApwx5dU0AoitlgMZ8BcN1
	TNz8sL2XwZ7ZWL6X86A2rGJbcWyOx3OfM5lu4tXtuYa/jgA+rAJcM1oSD2Fpv7cksDCgUJC/fn9Kq
	nTAiST3Dnx0BeidJNl39SLSRug9Wcm6I4KcVLRaKNMWlFNVLoynlTpYBVLH114vG62z0+eRGKTfvN
	biBEvbSMgMzXSstGo8fHxOrdnwa/1RwqGz+5oEpCIvgTw0FvnwHhrfWzzmrI3E17qFXjN1l8el6bE
	tD/zuFow==;
Received: from [2001:4bb8:18c:28b5:44f9:d544:957f:32cb] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hyW8O-0008Hc-Qe; Fri, 16 Aug 2019 06:54:49 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 3/4] memremap: don't use a separate devm action for devmap_managed_enable_get
Date: Fri, 16 Aug 2019 08:54:33 +0200
Message-Id: <20190816065434.2129-4-hch@lst.de>
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

Just clean up for early failures and then piggy back on
devm_memremap_pages_release.  This helps with a pending not device
managed version of devm_memremap_pages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/memremap.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/memremap.c b/mm/memremap.c
index 416b4129acbb..4e11da4ecab9 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
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
@@ -129,6 +132,7 @@ static void devm_memremap_pages_release(void *data)
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
 	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
+	devmap_managed_enable_put();
 }
=20
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
@@ -218,7 +222,7 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 	}
=20
 	if (need_devmap_managed) {
-		error =3D devmap_managed_enable_get(dev, pgmap);
+		error =3D devmap_managed_enable_get(pgmap);
 		if (error)
 			return ERR_PTR(error);
 	}
@@ -327,6 +331,7 @@ void *devm_memremap_pages(struct device *dev, struct =
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


