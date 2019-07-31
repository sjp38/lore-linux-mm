Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD658C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA538208E4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA538208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8CCB8E000D; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D41F68E0042; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07C28E000D; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 667C58E0042
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so42630148edd.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JdEJ1yPdKVolU6ZyqeGm/eidwXHliD8yjDfIXTvtKIU=;
        b=AHqYki7THYJmHjUbIfWmg8K+KfMU8WihnbJ4NydP+5Ks3awYFUvbRBeyzY17oaDJwa
         oGdTcm3groX49pqSNhf5GJp3ztXBsdgw2LA6Ud6y+fotHVLXyn5biGA0NcQa5QH7fg35
         wkOF2E91jus6TpBH40czvXCKlVMhudKbaDidYj12v8dDXIf4URpkJSeuwdd2rkAeh9Dv
         H0dTxj2I9oyPnZu+NynyFh0hp9WVVp3mV/AXMQUkQ6y4Uaj4AcEqvQtGremqUskyxbNm
         M+WHnxFUw0tqnhdKYEEEVWbvUdzrfayrM9W6rr8cwWAaq+iI3yZ/iTYbC3dybTtEHAB6
         EErA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAXGw1dcbJN4yipeZhRhi5QuOfI1JzAFcpU3ZZGJmuylDZUKdLRB
	GBWbf1Kv+kFdrrF3B2y3Q4iQsvXKo4XcToLreMoeGOCeaCoQgHaQyrO46/5aW5eSEgRHfDPoBsg
	IJqbRaXQrBWbkqd/P6xJ10PN9ytGPxSn0vrJXR3Jjjb/Pd3s5M0GySUMp2O2T0o4QiA==
X-Received: by 2002:a50:fa05:: with SMTP id b5mr106165168edq.269.1564588091011;
        Wed, 31 Jul 2019 08:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/jyfQsHKhcAUBdjB7kattfyoPS+1dpZmxeUZwzE6CLnSxanOGnqMtAWiL861tPcv8QQRY
X-Received: by 2002:a50:fa05:: with SMTP id b5mr106165108edq.269.1564588090313;
        Wed, 31 Jul 2019 08:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588090; cv=none;
        d=google.com; s=arc-20160816;
        b=cPyOBxDPCLbat/7NeGvoavtNNmBV6HMSxsRwlj4Is/+w/1us3ZIuR9GiI0Tvs/aHpT
         T2vKE8WhxdM3MN4CFm7mvEW+8gFLN+gWgU3urT/M7jEESzk0DJfzqb/g9wLD5UrlQwhE
         oChoDnNrLPI3K1dVaCcxtcD+P511myg6R4GcVvbr9EFnAY8Nx8S1qCLcSbWHGeT6RPyR
         yntOidI0HP09Y2jAsnxgFxO/ldYG4Ry1ku+CtymDUW9jUh4f4yxnDnydUKzY5rCz6W9y
         78tTX/66uIQOuRetczX8yURmsFIZKT7Ebl9epVYMuvECC7RUOUF4bDUFPDz8ypr4qpUI
         fdQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JdEJ1yPdKVolU6ZyqeGm/eidwXHliD8yjDfIXTvtKIU=;
        b=Mjo5X61TKPd90/wvjP5/lTzwU5jCzLjXvsN8Bs1YII23dqFDAMSwptp6GkRHfSuw26
         lvPadQysGex8UO2eYjLLcKNAy9CgHjpK0MyIichMJJMNGHDPqFRuRMNNq9VOBSOBS2mx
         MsTgs9VRpxM2CP7lSCbiOQDi1Mnm1bANUfqdq+3yiz2v7ze4xEPBsSNYk8vCPmXmwRoc
         gm8+Ul7Ti6h6rJ0P74uQx3z+hJAQeA2npOOmGxDeh65XGLeGfCnvuOIknD8jPkhBrUDz
         oOV78cieORW9V1OCZ7J4N97rsX0lBA981lghDabgxoGcVlTPyuTbdPOHM8S6hAoe12In
         2r8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m55si20893131edm.55.2019.07.31.08.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D42A2B03A;
	Wed, 31 Jul 2019 15:48:09 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	will@kernel.org,
	robh+dt@kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	frowand.list@gmail.com,
	m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org
Subject: [PATCH 7/8] arm64: update arch_zone_dma_bits to fine tune dma-direct min mask
Date: Wed, 31 Jul 2019 17:47:50 +0200
Message-Id: <20190731154752.16557-8-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190731154752.16557-1-nsaenzjulienne@suse.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With the introduction of ZONE_DMA in arm64 devices are not forced to
support 32 bit DMA masks. We have to inform dma-direct of this
limitation whenever it happens.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/arm64/mm/init.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5279ef85756..b809f3259340 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -22,6 +22,7 @@
 #include <linux/of_fdt.h>
 #include <linux/dma-mapping.h>
 #include <linux/dma-contiguous.h>
+#include <linux/dma-direct.h>
 #include <linux/efi.h>
 #include <linux/swiotlb.h>
 #include <linux/vmalloc.h>
@@ -439,10 +440,14 @@ void __init arm64_memblock_init(void)
 
 	early_init_fdt_scan_reserved_mem();
 
-	if (IS_ENABLED(CONFIG_ZONE_DMA))
+	if (IS_ENABLED(CONFIG_ZONE_DMA)) {
 		arm64_dma_phys_limit = max_zone_dma_phys();
-	else
+
+		if (arm64_dma_phys_limit)
+			arch_zone_dma_bits = ilog2(arm64_dma_phys_limit) + 1;
+	} else {
 		arm64_dma_phys_limit = 0;
+	}
 
 	/* 4GB maximum for 32-bit only capable devices */
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
-- 
2.22.0

