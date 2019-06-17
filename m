Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E48C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34F902084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:29:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="idjxwSVc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34F902084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2BB28E001C; Mon, 17 Jun 2019 08:28:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7088E000B; Mon, 17 Jun 2019 08:28:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97D9D8E001C; Mon, 17 Jun 2019 08:28:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA478E000B
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:37 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k2so7647106pga.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:28:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I8PlqMUI4C1+5AXdWNAvJGUn4z7E5OvP3cFwdUwwRcM=;
        b=MZPUxNAPLsiAwiDQsBffWiDBsUu2NmJJx3+SnadGpWRWufTRrAFY3ARX4yltzcIt5n
         Eqo1txcUDKnaNQJwGDv1w5xEHO0wWo6cLi7pRUjacS7YeZ8sHTKODzzubAaUCcM5hjyL
         OhpnFktvx7Sg8jfxQ45YsWOaoaDyzex9gfQUVlNtZmICfSZ5+VgjJJaTCOm5DD3S/Nax
         8hLuXnQxnhEuGy4HJ74p16LpabbcS/pQDrFLSbTdWIBluuYwWZkmCal41NQgqYexeBc1
         IlZdBJEz7LlvKr+ftsizZnA0SptZYBOdhkvQc5q0EUObUCdC7LLoRiOwK+n8UpB4MSnK
         781A==
X-Gm-Message-State: APjAAAXOaqOGbT1JY5yznElWXFIxhoYXX4GDEVyUeJWwtvtR1qCUWN4y
	vd3VJqV/s3zGzmPD0pgR1HpEy2Upuevnmr+f3OC8ZHzTmJu0f2hQY5Mi3ydPP+cl8fqNht+msCd
	gaOvuVnb+tjySlzYm4WxPjCUZJ7W6hU6IlFerTzWbZWEThWHb3wnFfziklA6qAKk=
X-Received: by 2002:a63:c301:: with SMTP id c1mr40749467pgd.41.1560774516950;
        Mon, 17 Jun 2019 05:28:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3qJUYy6ApN1i7Tpy3xC2kRFGYutrOAz8nV2SW31Aa5a/zeHMpCnrvR+CXA7ck6dUkO3HJ
X-Received: by 2002:a63:c301:: with SMTP id c1mr40749432pgd.41.1560774516291;
        Mon, 17 Jun 2019 05:28:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774516; cv=none;
        d=google.com; s=arc-20160816;
        b=SI59YAn4z20vluHvBIO1zpHnQzbrjtx2P3C/qRn3s3TgiqagUEjA07431Wl3Tc8hAl
         zZMyScYb7ui9pSH25cPZy/YSD/D7DZGIdFI1SV2+DZRtj+SPc1TnazUfxattpZqjIr5S
         G9YgOnYZvtq81jfeOdvsWDr0L8O+TH8hOtAS90SH60Jk7JohBiVJCwbBVjW8mSSJwn2r
         wvuxfnNbguIA2SB67VZEl7WeZ9Gezz0BiMz7KcxF8TvjEglPw4uBeosvmyABA1v0hJE0
         k/7HrdwVErNvXtvUpOUayPavR0y0PhFhnAAQF3mWkUexvSLGKCASYGmjLG0Kvm3oodMP
         mYow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=I8PlqMUI4C1+5AXdWNAvJGUn4z7E5OvP3cFwdUwwRcM=;
        b=nQWOGPSXFOkiAjgVpN1gWXdleUy+RvssA/TcH1G3h5i6gUxvpr91lWFSTCMczoQqx4
         bN4+njxgnBYSfdgjR479dQ+tL9cKdEy7gwP5h+UHJF0Mvszoy4hVkGG3qYe2XhjkgAtV
         UiXrxs2gj0B4SXKMaD6eMXLYDW5LJCccUyPqahd+jLPd3weasY1zjdVGSYKp8zpptpQa
         ymMpUX1L28+FzqMbsueXhsj3/RMNlYv2d8+0iQDx2yc6Il5msd6qqoK77pgjdmEqANew
         iMi8TZtXUY0pTHaGTXBbV72r33zi7weodracFqM06+t3XJvmMOZhF/d9wBCJG4L1H6gJ
         yMIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=idjxwSVc;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1si10862240pld.418.2019.06.17.05.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:28:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=idjxwSVc;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=I8PlqMUI4C1+5AXdWNAvJGUn4z7E5OvP3cFwdUwwRcM=; b=idjxwSVcGR8gj/Hv9rgN32Pbhq
	n+B3Dw/eAY5nzc0hWjvE0/DJdYcXUudxghMTEfuhBlOZzQqw6Kp9Ri+RNMJ+ZbD/rpwTc7jNnggaJ
	oWqEp9P7byqhhh4K1c+iPeFxUZ8V7J2oZFOxQqqzjxHYw+5SJgb3oBcJchVokBPs8JXyeVW8tAhRx
	i7ntPKqW6sOS8kblCvWSXQcLZNVxYW/7zdv6j5cHwyvtGEDGaTmZwfX2j/Yje0mucmxOeMh4+QyGl
	st8aBl75weQTuuByjCtZpmELlzhnz8odxyh1rYlQ1/iPx/2DY6A/ochv2KYvVjetIbSP6uDrsRviB
	sLz4N94A==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqkS-0000eV-VL; Mon, 17 Jun 2019 12:28:33 +0000
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
Subject: [PATCH 25/25] mm: don't select MIGRATE_VMA_HELPER from HMM_MIRROR
Date: Mon, 17 Jun 2019 14:27:33 +0200
Message-Id: <20190617122733.22432-26-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The migrate_vma helper is only used by noveau to migrate device private
pages around.  Other HMM_MIRROR users like amdgpu or infiniband don't
need it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/Kconfig | 1 +
 mm/Kconfig                      | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
index 66c839d8e9d1..96b9814e6d06 100644
--- a/drivers/gpu/drm/nouveau/Kconfig
+++ b/drivers/gpu/drm/nouveau/Kconfig
@@ -88,6 +88,7 @@ config DRM_NOUVEAU_SVM
 	depends on DRM_NOUVEAU
 	depends on HMM_MIRROR
 	depends on STAGING
+	select MIGRATE_VMA_HELPER
 	default n
 	help
 	  Say Y here if you want to enable experimental support for
diff --git a/mm/Kconfig b/mm/Kconfig
index 7fa785551f96..55c9c661e2ee 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -680,7 +680,6 @@ config HMM_MIRROR
 	depends on (X86_64 || PPC64)
 	depends on MMU && 64BIT
 	select MMU_NOTIFIER
-	select MIGRATE_VMA_HELPER
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
 	  process into a device page table. Here, mirror means "keep synchronized".
-- 
2.20.1

