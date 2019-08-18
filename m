Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 880B7C3A59F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42F2E2183E
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AzgRNbcm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42F2E2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4E1A6B0008; Sun, 18 Aug 2019 05:12:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E07196B000A; Sun, 18 Aug 2019 05:12:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEDFF6B000C; Sun, 18 Aug 2019 05:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0213.hostedemail.com [216.40.44.213])
	by kanga.kvack.org (Postfix) with ESMTP id B0EF86B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:12:40 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5B0B2181AC9B4
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:40 +0000 (UTC)
X-FDA: 75834983280.19.sort26_517be09066114
X-HE-Tag: sort26_517be09066114
X-Filterd-Recvd-Size: 4457
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:12:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Ybl6KWkI9r5RiELOPQNVwBgBcMfR1YS4dX2AUNxc4u0=; b=AzgRNbcmu8a6MZwuoiTuScTGjo
	re7HmmJo0FyV4s7q+yx3NU78IRkpJbcuzl4lC3iaUMeyGKOHEX+eP9aunnP04z8WMn+zmL9R0Ts/D
	vFHqGdCf6pKfcUkjEzAbb17peu97HD76/EQk1BjGuuOM3vtJy3Nqe8bp6YsdZKICTAvyzDvXzm+TQ
	HtFyvU61DDFMNBtepPkuICsVgx5PCp/XZe7qXXhajE1vWCw8gJgsF5leIDeMlGD1OHK3aJ8C2Rus4
	QbE+O6EgCfpHWOHUgDOqwYxXz+y1RD5Z3FN6DU37ZCy0IRkz8f3rFieIoHQVr5+nG6I8eRQgPVEKp
	ATdz2K2w==;
Received: from 213-225-6-198.nat.highway.a1.net ([213.225.6.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hzHEp-00018U-8I; Sun, 18 Aug 2019 09:12:35 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH 2/4] memremap: remove the dev field in struct dev_pagemap
Date: Sun, 18 Aug 2019 11:05:55 +0200
Message-Id: <20190818090557.17853-3-hch@lst.de>
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

The dev field in struct dev_pagemap is only used to print dev_name in
two places, which are at best nice to have.  Just remove the field
and thus the name in those two messages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/memremap.h | 1 -
 kernel/memremap.c        | 6 +-----
 mm/page_alloc.c          | 2 +-
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f8a5b2a19945..8f0013e18e14 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -109,7 +109,6 @@ struct dev_pagemap {
 	struct percpu_ref *ref;
 	struct percpu_ref internal_ref;
 	struct completion done;
-	struct device *dev;
 	enum memory_type type;
 	unsigned int flags;
 	u64 pci_p2pdma_bus_offset;
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6ee03a816d67..600a14cbe663 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -96,7 +96,6 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgm=
ap)
 static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap =3D data;
-	struct device *dev =3D pgmap->dev;
 	struct resource *res =3D &pgmap->res;
 	unsigned long pfn;
 	int nid;
@@ -123,8 +122,7 @@ static void devm_memremap_pages_release(void *data)
=20
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
-	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
-		      "%s: failed to free all reserved pages\n", __func__);
+	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
 }
=20
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
@@ -245,8 +243,6 @@ void *devm_memremap_pages(struct device *dev, struct =
dev_pagemap *pgmap)
 		goto err_array;
 	}
=20
-	pgmap->dev =3D dev;
-
 	error =3D xa_err(xa_store_range(&pgmap_array, PHYS_PFN(res->start),
 				PHYS_PFN(res->end), pgmap, GFP_KERNEL));
 	if (error)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..b39baa2b1faf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5982,7 +5982,7 @@ void __ref memmap_init_zone_device(struct zone *zon=
e,
 		}
 	}
=20
-	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
+	pr_info("%s initialised %lu pages in %ums\n", __func__,
 		size, jiffies_to_msecs(jiffies - start));
 }
=20
--=20
2.20.1


