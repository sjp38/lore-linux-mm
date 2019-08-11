Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 225EBC0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC1C208C2
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="kc3X0PTL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC1C208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3BDC6B000E; Sun, 11 Aug 2019 04:13:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA19B6B0266; Sun, 11 Aug 2019 04:13:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98CD46B0269; Sun, 11 Aug 2019 04:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9D56B000E
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:13:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so62622642pgg.15
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:13:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wlIHq+QByXfQFn2NhPBNjI0aq3Vrr70dQs8BcS07ZzU=;
        b=FkVivsUa2SJfpiQ7I6SN2XHXOmedyXhwE5et13msL/s9lvZS5e1b5dH+Lj40Ps3WWl
         34qqmvB5gZ/+xvX0Fy9P/CfNwTujpLo4Ik6IGUd5UmiGLJifqNNyy5UEli/rnq1EGW0e
         Wl1yLe9YbxPNf098IVzhmDA35o96Hs9w33FcR9Z7BN75wSJ50B8FV6RTKgM52gz07zmq
         UOVN9mqkzaSsckyq1YaL6kulYiXG/1bXcGMqS5WLD5npYuWmqpzhiqivu3i7ENu62lmM
         TgTSaraxHsZ5p43S2DOEqyqbOV2q4qDX/yYgpnZ5SUs4A31fTFAJlJ/yCHG+Lzw1tDC1
         DMBA==
X-Gm-Message-State: APjAAAWPyKQ8aIdiPQdtLlzSZQW4zBmU1htze92MV5ITALHVQzylQQ/t
	syv5EcePGZyB7oVvl0Zpitk6vUY+17s4LBcWe5y7p6J6R5PFwypYDvfoKi7f18zAC70x274Pi0S
	7IwDDqDmj0XFeOL2es2w8DR+//I5z4IbjnReMs6imuoMzD5N0Ygb46jiSAAYCx/A=
X-Received: by 2002:a17:902:2ea2:: with SMTP id r31mr27839241plb.200.1565511184028;
        Sun, 11 Aug 2019 01:13:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwbY4RBGCpI3ecO5zEq+wRS+/9OuNR3zO3uIfTunCDjoG+PZ2Sh9T+GTTI4Wte+r6ZOkvZ
X-Received: by 2002:a17:902:2ea2:: with SMTP id r31mr27839219plb.200.1565511183402;
        Sun, 11 Aug 2019 01:13:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511183; cv=none;
        d=google.com; s=arc-20160816;
        b=maHCPaVYzNbHNhnQscdSqhCtJQzo7MXziJLIsSQDo2JOsHmI8hgPXDPDllaEP5m+Fh
         WvKNm2FzZp3bxMuj8kgoPZzqQHfmBvNVYIvYZ22SCikWdxkPLG0w/1lkiG+kpVHUJMAJ
         H+yU9p46qgSmbrT4cXCiR3brjewlIVsB4MIo/u3efHFtGkkAAIOzXWvkjV5rBzywBgjl
         eupFzP+knbEiv6HNagBPncnNzpjYJZ070iF3Pp5/Pd4/oELbw8VjaRyr3zy2jZ4Ohorg
         YfejAhlxCHaghl8xRJPP6/aXorXa42c1evt4TIcApYmptbptyw8GuFgHFObxQVsuVP9V
         TLpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wlIHq+QByXfQFn2NhPBNjI0aq3Vrr70dQs8BcS07ZzU=;
        b=BAN812JsyMIR8HgTzUeCnRF/P2rL2I5ArKfUHNpNEzHmqyhd4iLqDN6ubm596kjy8/
         Paqj+PqWGRM0PfglwK5Ntsh9GCKM7HdSywTFtZjqoRHLOr0wHAPf+lwG4danXQr+RNfR
         lPYAD1IeBcXw04chYAQwKhfgaRvad+Rc9eeYFv3vDRq/ot4UFoRfutGlUi7IoPBZ4jLc
         +DMluqwUqfpdKfPGpv5cAuo/lxbI3SqrvhQcpT4DCCsiYd9P93UZppr0fdfUmt1Rt7Rs
         4gcQspSBpp83mdqqwrLtEFHrmTzEpzIAs1uuKXxO8/LnEEKFAr7nr5VoRajMQxs/8FKZ
         jw5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kc3X0PTL;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t135si59528410pfc.251.2019.08.11.01.13.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:13:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=kc3X0PTL;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=wlIHq+QByXfQFn2NhPBNjI0aq3Vrr70dQs8BcS07ZzU=; b=kc3X0PTLwMO5fuhqlS6Qovruk8
	pDoyHkdZ+189ETCogs3IobPSptChmx20eLInajEaYa9SOM7Pu0nJdngc2DDaOBv0RtJyetKzZeBTk
	5u+SvBBaD19zrH72HD/iouIYz6pEmZoqRW1d+CernqP+Rvl1BCHCHKpAZmq41FiyvqG10jXSsjizQ
	lmAoD+M/3j/w6cUPONNpkZHits/zCfz91+B8ELezWMJqODmz+6Z867v/DGRNrXyNRy/ej2Qsv26ox
	MWJjal2GweQyLKvR3qdqWJm3DyKrLYCm/mXgb6XBkhRBKIc4VWBdo/FVTXaUYpePhl2cr5Nf9YJMS
	4VOyPYIg==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiyK-0005Dt-VH; Sun, 11 Aug 2019 08:13:01 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 4/5] memremap: don't use a separate devm action for devmap_managed_enable_get
Date: Sun, 11 Aug 2019 10:12:46 +0200
Message-Id: <20190811081247.22111-5-hch@lst.de>
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

Just clean up for early failures and then piggy back on
devm_memremap_pages_release.  This helps with a pending not device
managed version of devm_memremap_pages.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/memremap.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/memremap.c b/mm/memremap.c
index 600a14cbe663..09a087ca30ff 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -21,13 +21,13 @@ DEFINE_STATIC_KEY_FALSE(devmap_managed_key);
 EXPORT_SYMBOL(devmap_managed_key);
 static atomic_t devmap_managed_enable;
 
-static void devmap_managed_enable_put(void *data)
+static void devmap_managed_enable_put(void)
 {
 	if (atomic_dec_and_test(&devmap_managed_enable))
 		static_branch_disable(&devmap_managed_key);
 }
 
-static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
+static int devmap_managed_enable_get(struct dev_pagemap *pgmap)
 {
 	if (!pgmap->ops || !pgmap->ops->page_free) {
 		WARN(1, "Missing page_free method\n");
@@ -36,13 +36,16 @@ static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgm
 
 	if (atomic_inc_return(&devmap_managed_enable) == 1)
 		static_branch_enable(&devmap_managed_key);
-	return devm_add_action_or_reset(dev, devmap_managed_enable_put, NULL);
+	return 0;
 }
 #else
-static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
+static int devmap_managed_enable_get(struct dev_pagemap *pgmap)
 {
 	return -EINVAL;
 }
+static void devmap_managed_enable_put(void)
+{
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static void pgmap_array_delete(struct resource *res)
@@ -123,6 +126,7 @@ static void devm_memremap_pages_release(void *data)
 	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
 	WARN_ONCE(pgmap->altmap.alloc, "failed to free all reserved pages\n");
+	devmap_managed_enable_put();
 }
 
 static void dev_pagemap_percpu_release(struct percpu_ref *ref)
@@ -212,7 +216,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	}
 
 	if (need_devmap_managed) {
-		error = devmap_managed_enable_get(dev, pgmap);
+		error = devmap_managed_enable_get(pgmap);
 		if (error)
 			return ERR_PTR(error);
 	}
@@ -321,6 +325,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
  err_array:
 	dev_pagemap_kill(pgmap);
 	dev_pagemap_cleanup(pgmap);
+	devmap_managed_enable_put();
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(devm_memremap_pages);
-- 
2.20.1

