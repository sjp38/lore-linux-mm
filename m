Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E49AC0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 523D0217D4
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RipnxiPt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 523D0217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B156F6B000D; Sun, 11 Aug 2019 04:13:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9CA66B000E; Sun, 11 Aug 2019 04:13:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F3FE6B0010; Sun, 11 Aug 2019 04:13:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 579526B000D
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:13:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a9so1894932pga.16
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:13:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Y01FamiaByfIvO4XPWaRUQIkSGmHIczQrp+AHvWAufA=;
        b=dQM/Bl6h/FjPv6d5z/Ltbx/ys5m3oX9WOUY6qx+1sTg4GcY7hzFUKvxz+zH6MKQPgT
         XS3HZmCs2jySUVQMsLWH5H0Q7VWSAekGnNKgMtf7b1v5nx52Qu1ixkyGxLuwkKi1dGuJ
         sA7nZf5zFfkoSpdUGNaSj7Ngcg7D9tHz0LPUAcjxgKc3qK5FZunout/EvTDp9hOt2Pry
         TaywGG8sCsihH/0s6TgjDtMd+X09SKdDMTpi7v1d8yn7lX4YIKkhPd9IcAIx6V7aytzW
         TwCIV4vDavh0GMbImQkRx5Mh7CuMo8jgMZzGWqsaud2/2hPzlcgvtCoJapGSSFd+NLU9
         8otQ==
X-Gm-Message-State: APjAAAU+WNvcrMAhQlZRUXeoVRit6j6z278G+IKWD6KC5VMuqBMjJkoq
	HUVMjPpISuS1h0wPVtU4bCJnInQ94ND1WIYbpcMM/C2EQkaZRN3GQoq9ybIxAUZl//SBH7xyw5q
	+Wf+Eb+s6MADGMkKFuecqQ4E5mNrXjWio/Y9OfNf6QY1my//YnmKvQ2RQIhRy3OY=
X-Received: by 2002:a17:902:f46:: with SMTP id 64mr27788158ply.235.1565511181997;
        Sun, 11 Aug 2019 01:13:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsrrFqHUmOJOcPjuLkCGrlg+GHXRip0pIlI2qfsMIYoWEGn+hW3dTRj4Ab7vvBCrwDl00V
X-Received: by 2002:a17:902:f46:: with SMTP id 64mr27788129ply.235.1565511181288;
        Sun, 11 Aug 2019 01:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511181; cv=none;
        d=google.com; s=arc-20160816;
        b=UPsgBTYXntOnTFdw2lQ+Tdhx5tevqoPA7vd7bUPxJ3TGemMt4BiIvaVsK6kSsi6WGz
         HH4bcG614AtNS3+BTTnDbrGhbnvN3eIqhJTTJQT9d58kyDhOhuxibaJXxtfW99vXa9Rs
         dlmrIu+Z8KiSw4qMbRUfiCUoVvk3APZqcH3X1kWUMRq+6+nivlCzKEcHBrx8uCbQM7sZ
         v8Vn9bTFCRDQ766LDBOfYOJTmi0kKwSASXU42/B7RaTXOFSG76uDtQpOPkBPSbv2NSpl
         Md0B9loqPcnWdpftAHdMBkL+R/Pt44dPpbdZg8C39tphLVAkCkWpH7fEJExHRuF6MuIN
         tOIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Y01FamiaByfIvO4XPWaRUQIkSGmHIczQrp+AHvWAufA=;
        b=LK6gRCAar4o/rvz3yEB0QQIXXLGRTAMkvq8NHCIZLJGzwA+uA9NeVGZYrhEeAYne2s
         +ulriQYBx/Vz7va2ZbrbnxgjuP9TH34w9ftCvFdXUpDn7HddavgfiAF9HiMbPpW/2kAy
         KLbb0TRtV7GqgZw9oeBOCIzMmioBmUb6adVyPYkBPmXfrFY80YeYGmRdpHtFFc0sFDad
         IVraQ/kqr/0pneKvBtYakU+9fDf8XArW9Yews0v4PLs2d+0BQd4JmRs+r2l92XPJu/K2
         cmNiTliv/mtYvP44S+fpfJfc9AoLV8LJ0EpNlZsRK7tfBkifOf0SDOJImgP5v1qteHfT
         Dh5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RipnxiPt;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q15si57074655pgt.150.2019.08.11.01.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:13:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RipnxiPt;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Y01FamiaByfIvO4XPWaRUQIkSGmHIczQrp+AHvWAufA=; b=RipnxiPt/PMVgl31RtWtQJu3OX
	VrtuUEa9DBkTysRlMPDs1dgFUPp6qSJxDMt8qbJIFjXY/4T/9DAI7jJLR/l2QUJ1Wr9wEEXr5LAFk
	Fc8vtOysZAZCOegxYg4kgsM9/0zvRpon6JcD/C5G8Op2oi4kUx8EBWDh5SfZhCgKFDpQF/2Vxy87W
	JebOmEQSEZX2iS4UyphPWLOkEXGYARp8ynsC9ruErseHKFgsWmV9WDZU0NnMtbKg2xMhYlZQVqBUV
	Dkkj6+wq8Q0is5FJ/jAexn89X7iyHKgpKE9rC9YP5uR6T7HX7Ir9Wrurtsb57fn8FnyfLdogrv0Cf
	+fokE9LQ==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiyI-0005DL-9r; Sun, 11 Aug 2019 08:12:58 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 3/5] memremap: remove the dev field in struct dev_pagemap
Date: Sun, 11 Aug 2019 10:12:45 +0200
Message-Id: <20190811081247.22111-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190811081247.22111-1-hch@lst.de>
References: <20190811081247.22111-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dev field in struct dev_pagemap is only used to print dev_name in
two places, which are at best nice to have.  Just remove the field
and thus the name in those two messages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/memremap.h | 1 -
 mm/memremap.c            | 6 +-----
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
diff --git a/mm/memremap.c b/mm/memremap.c
index 6ee03a816d67..600a14cbe663 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -96,7 +96,6 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
 static void devm_memremap_pages_release(void *data)
 {
 	struct dev_pagemap *pgmap = data;
-	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
 	unsigned long pfn;
 	int nid;
@@ -123,8 +122,7 @@ static void devm_memremap_pages_release(void *data)
 
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
-	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
-		      "%s: failed to free all reserved pages\n", __func__);
+	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
 }
 
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
@@ -245,8 +243,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_array;
 	}
 
-	pgmap->dev = dev;
-
 	error = xa_err(xa_store_range(&pgmap_array, PHYS_PFN(res->start),
 				PHYS_PFN(res->end), pgmap, GFP_KERNEL));
 	if (error)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 272c6de1bf4e..b39baa2b1faf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5982,7 +5982,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		}
 	}
 
-	pr_info("%s initialised, %lu pages in %ums\n", dev_name(pgmap->dev),
+	pr_info("%s initialised %lu pages in %ums\n", __func__,
 		size, jiffies_to_msecs(jiffies - start));
 }
 
-- 
2.20.1

