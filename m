Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCD32C433FF
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 833902173C
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:12:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KEcMyEGD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 833902173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 657ED6B0006; Sun, 11 Aug 2019 04:12:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60C436B0008; Sun, 11 Aug 2019 04:12:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FAC66B000A; Sun, 11 Aug 2019 04:12:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 183626B0006
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:12:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s21so59696404plr.2
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:12:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uoRjcc+yME8yAPa9Xc310HToAkfl96lLd5QwWON1ovM=;
        b=DaAe8s4MGGJTlaAWOjZj5IQ5ygSYikAkO8wDrcXMiNA6HJeDLoACa3Fz7y+Wl1gXrM
         P/QJN45k8XoJG9lvyZhZICtfOb6eGRtDmf9cB9DVNsAM+nFzy57jeOWS+0QCcyCbYDy0
         KJHbGiEkJIpIzm3YaAthRaQGkJk3HYrUwb7RFCL/KGBxtnNrwe4TqJKQA9HCABw1j9Ok
         PpFNjKhBVQcGTkl4nSa+FFpd3RH+5LOBzuJ1AMpa7xHfcOGYvNWxlfkeBRr/TGw46zdT
         Q0jzUVUZGHvdsHoKX7cDwDbTlNy92DbtwuW3TgB2AOXs7dki95CxBNdDBQQLjS96VSti
         WBYQ==
X-Gm-Message-State: APjAAAVhYBrp3tlPEnTCXuvGufcGvODigc6ZFt+hRNPAnS6bxh95S5Vz
	eterFbiykoli4OmYVIyR+s4mzK3IhhXBrGRD3ZBGY+QHdqvB13Vc9coDYzOiJfVxR+6klTDf0sl
	X0u5dNsidQXIYlufpo5yPzvCAA5/S4SFkh9pJi9lJMxCRBYILcIybEGDCHU1FCDQ=
X-Received: by 2002:a17:902:7083:: with SMTP id z3mr22604166plk.87.1565511175622;
        Sun, 11 Aug 2019 01:12:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyJvUEWVmE6Ke1tADfrC5aBGPJzoWar1GqosMQdvAmMHRq2ayyNY3jezwU/JjnGV56J9aN
X-Received: by 2002:a17:902:7083:: with SMTP id z3mr22604133plk.87.1565511174875;
        Sun, 11 Aug 2019 01:12:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511174; cv=none;
        d=google.com; s=arc-20160816;
        b=WsP6KEXHzjVaVvlPPcxYOSs0Tp1lOAKy26LLLMe2d1K72Ri92iux3wWZpWx15ER6IW
         NQ+k7+H4Uz5hUA6BHzI3w2tJvzyEz1utk8oVwa48tuBVeYgAOOHaEuccFh7r4IQj+IsM
         tWsOF4+CJx6/Oa8GHSi1KyboAJNEYdrVy54pAEI0GPyWvzLqElIoMOjyhETtV3mVMLUp
         w95mwhjMfm6Vq3/28qDaaZdKxJe+ITidvaLfgW2B1l92YsVrtshuZ0BYBv4yo0y6ydUS
         FKlSMlr36ozdemHA3qXliHq80w6ebWvbZqbvKYwyXCmVJiaB7Kz8f+KIMSCkxm48b6G0
         9hvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uoRjcc+yME8yAPa9Xc310HToAkfl96lLd5QwWON1ovM=;
        b=DZes5e6vCe7CVwwUXY5ZVSsu2G75ycbuPNmtlSQfn3JRj0cD4yB2Sf9+DulT/qdzvc
         voLddTMqFpzvMLvcv8f3VhC1u/JvOODm1dONOQQHQJOTHL5yTnaPfSCizxJuqFVtN9sn
         Zh/gIlYXd8Vse0vGv8k5w+ZmvLfAXsuqqP0RjZ0b+22WnE6SJuP7+uRWn3zxEEUMjAxR
         mtBM5ZQW0+Dr0OLcvpYhFaTS21DI+hp3L0/HYaURkHJCO7doyL1gXu0zyH5LsibYDxxB
         Y7ymBque5xVPdwatCUEU6bjSlZWvQzObqFycDOmkdoXrRizqI+NLRQVJw7Re2/zGyPF9
         pKnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KEcMyEGD;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i1si64162377pfr.203.2019.08.11.01.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:12:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KEcMyEGD;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uoRjcc+yME8yAPa9Xc310HToAkfl96lLd5QwWON1ovM=; b=KEcMyEGDGTyU3DR/tZsAvRAvj9
	QaPfx4IIxQLHeN3VZwLRrkp0R0j7CmmPQUVfzE8mMwlkhfRUD3xuliZaBVBv9otQoT4AHLPWmezWS
	F+D0GqnHXxyke5eZl9lkRS0BcdFFyJpNgV5hnecQACoQKhye9zNIdmNKIqg4Dz+0R4HKBTYR19bke
	rXAlZJSfjmblsw1SNe5dAmUOMP7l7GiiEjuTLIzqzp4jabaFnG0cUGH2TNG5kGU9CdwHwgyeM4lkp
	ga9KAp+07OYjdaeNXIU6yUDKkujJcokbaSDnaTQg5z2Qi6tQvzxBbiKperT51YI2zsAUexe3SnR95
	sw7YqVUg==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiyC-0005CY-IP; Sun, 11 Aug 2019 08:12:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 1/5] resource: pass a name argument to devm_request_free_mem_region
Date: Sun, 11 Aug 2019 10:12:43 +0200
Message-Id: <20190811081247.22111-2-hch@lst.de>
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

Add an explicit resource name argument to devm_request_free_mem_region.
Besides allowing drivers to request multiple regions per device with
different names, this also prepares for a not device managed version of
the function.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
 include/linux/ioport.h                 | 2 +-
 kernel/resource.c                      | 5 +++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 1333220787a1..aedf18a44789 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -605,7 +605,8 @@ nouveau_dmem_init(struct nouveau_drm *drm)
 	 * and latter if we want to do thing like over commit then we
 	 * could revisit this.
 	 */
-	res = devm_request_free_mem_region(device, &iomem_resource, size);
+	res = devm_request_free_mem_region(device, &iomem_resource, size,
+			dev_name(device));
 	if (IS_ERR(res))
 		goto out_free;
 	drm->dmem->pagemap.type = MEMORY_DEVICE_PRIVATE;
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 5b6a7121c9f0..0dcc48cafa80 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -296,7 +296,7 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
 }
 
 struct resource *devm_request_free_mem_region(struct device *dev,
-		struct resource *base, unsigned long size);
+		struct resource *base, unsigned long size, const char *name);
 
 #endif /* __ASSEMBLY__ */
 #endif	/* _LINUX_IOPORT_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 7ea4306503c5..0ddc558586a7 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1650,13 +1650,14 @@ EXPORT_SYMBOL(resource_list_free);
  * @dev: device struct to bind the resource to
  * @size: size in bytes of the device memory to add
  * @base: resource tree to look in
+ * @name: identifying name for the new resource
  *
  * This function tries to find an empty range of physical address big enough to
  * contain the new resource, so that it can later be hotplugged as ZONE_DEVICE
  * memory, which in turn allocates struct pages.
  */
 struct resource *devm_request_free_mem_region(struct device *dev,
-		struct resource *base, unsigned long size)
+		struct resource *base, unsigned long size, const char *name)
 {
 	resource_size_t end, addr;
 	struct resource *res;
@@ -1670,7 +1671,7 @@ struct resource *devm_request_free_mem_region(struct device *dev,
 				REGION_DISJOINT)
 			continue;
 
-		res = devm_request_mem_region(dev, addr, size, dev_name(dev));
+		res = devm_request_mem_region(dev, addr, size, name);
 		if (!res)
 			return ERR_PTR(-ENOMEM);
 		res->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
-- 
2.20.1

