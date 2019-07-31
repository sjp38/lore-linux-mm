Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8E6C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 743D5206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 743D5206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA3D08E0031; Wed, 31 Jul 2019 11:48:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C546F8E000D; Wed, 31 Jul 2019 11:48:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1BBC8E0031; Wed, 31 Jul 2019 11:48:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64F2A8E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so42622697edr.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sFlY5wD9vuJqu5NJmOfaOAztANUwJRWulkWyU+Es/x8=;
        b=sMzm2tEnPg0aTGK3IKyK3ouz4C3ai1jKTz9ski6KRUpl/bTAPTLaOPO6Yg5Q+mexws
         fvdZCR/WGgJJ1DNcRa3SFr4gBVUUTk/oy5SYTHr78jfU7QONS1QQyWeQbqysRrNa6GIj
         tk7FRr3aOJK28B9FUV4aKYPHqPmTR0siIgSjq6PfYaEG7kxo/VmqZdQfVftPrhzA6uYZ
         hR097SS2PPXyj0r9OjYDoGH66XU2VHJUyPQ6VEVuSC5d8QbldZSOYWFg58ggrA2QIL1Z
         Dy+XfEzcncC1irI01M4X9cZL591H1WHL3Z97cJ4VQmlWodbmjILNSO1ppT2WptdkrUTJ
         XYtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAWyrrjKWu1UeEV5VuipPTQXPhrWuBRhmUdhkz4z80ocsZdo41Ua
	Q57YMTdejJPToPnN0dyajbG6CRcdrauKRB0q22zG0TaZ6MvYA1rIBL1Sb/GbXnYZY4ozlkGt9d5
	WBmFg/L1hL98BD+MxHcSAivlaAJneODDPpzJ+zmBa9/S0XmA0J+jZ744peyxQ1xNCYg==
X-Received: by 2002:a17:906:6bd4:: with SMTP id t20mr90947179ejs.294.1564588083985;
        Wed, 31 Jul 2019 08:48:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIUoS1lW/ToHHc2G4ErQsmKHSab9FRTKgCMwloKcPUzXNjb9qZF1+4iwhNNvPrFzWWnh9F
X-Received: by 2002:a17:906:6bd4:: with SMTP id t20mr90947121ejs.294.1564588083065;
        Wed, 31 Jul 2019 08:48:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588083; cv=none;
        d=google.com; s=arc-20160816;
        b=lUBesGu/bqmnhuVLja0IXuyorgfS+FaprMWXq3RO0BNiJMG5a++qBeIFlCQmwaORjd
         HPLeP9k6kWDmxbuoo82HtIVHzrwsFNLegFKF74Bc6+/wZIzn7YgUK5KX+QiNLduCHuJM
         mb/6ntTs5FKMb9ubLFoDLzhl0LEtmH6UuEmtjpmB5l7YH2a7c1VcS5m2dRug8JyuD7em
         nYBUPgypNBNax3YgUOcCjocKaftbZTLha/LcFElH374y0yEEQquhYqjf3ZofxR4U6GEQ
         6ZssYQWds8tlYgQua4d6lfFYRrKJL7zfGpOrlviL8CXl7GI9HySIbu0Wd18RFVpbmfzm
         rZww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sFlY5wD9vuJqu5NJmOfaOAztANUwJRWulkWyU+Es/x8=;
        b=iTpnmAtWhXqDgbHZwt6UKYj4pHKhyuSOC/IS1/rQxVA1J3Rp5KQclA2uPvIF+Q6v29
         oKO3i1jWwHGoQ2N4ato+q7diO/z5esimHQF2c0i2AIdDUjV8Pe88fxSINCnvLuNBt1mf
         QWm5S+Ccl5ZqIr6XqYbEHl4Gb0n/hQz2K5ykZbRXrLaBYitC+Oaj7Lk2xC3yVDIIewD+
         wGeBcE1nG9maAh7hRNS9x3v/hUOW7TidTF4jMrJ4nj17kL1/oknJSCLQY9V1vGzuaiov
         rU+qz3FzWcwCflU9uL0IAQSOWnWbHQAjB0yTY1DfK77fCX3txSsneoSOnYEQ6pvpWKgx
         WLnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m41si22024842edd.186.2019.07.31.08.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A1F87AF95;
	Wed, 31 Jul 2019 15:48:02 +0000 (UTC)
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
Subject: [PATCH 2/8] arm64: rename variables used to calculate ZONE_DMA32's size
Date: Wed, 31 Jul 2019 17:47:45 +0200
Message-Id: <20190731154752.16557-3-nsaenzjulienne@suse.de>
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

Let the name indicate that they are used to calculate ZONE_DMA32's size
as opposed to ZONE_DMA.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/arm64/mm/init.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6112d6c90fa8..8956c22634dd 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -50,7 +50,7 @@
 s64 memstart_addr __ro_after_init = -1;
 EXPORT_SYMBOL(memstart_addr);
 
-phys_addr_t arm64_dma_phys_limit __ro_after_init;
+phys_addr_t arm64_dma32_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
 /*
@@ -168,7 +168,7 @@ static void __init reserve_elfcorehdr(void)
  * currently assumes that for memory starting above 4G, 32-bit devices will
  * use a DMA offset.
  */
-static phys_addr_t __init max_zone_dma_phys(void)
+static phys_addr_t __init max_zone_dma32_phys(void)
 {
 	phys_addr_t offset = memblock_start_of_DRAM() & GENMASK_ULL(63, 32);
 	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
@@ -181,7 +181,7 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  = {0};
 
 #ifdef CONFIG_ZONE_DMA32
-	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(arm64_dma_phys_limit);
+	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(arm64_dma32_phys_limit);
 #endif
 	max_zone_pfns[ZONE_NORMAL] = max;
 
@@ -194,16 +194,16 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 {
 	struct memblock_region *reg;
 	unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
-	unsigned long max_dma = min;
+	unsigned long max_dma32 = min;
 
 	memset(zone_size, 0, sizeof(zone_size));
 
 	/* 4GB maximum for 32-bit only capable devices */
 #ifdef CONFIG_ZONE_DMA32
-	max_dma = PFN_DOWN(arm64_dma_phys_limit);
-	zone_size[ZONE_DMA32] = max_dma - min;
+	max_dma32 = PFN_DOWN(arm64_dma32_phys_limit);
+	zone_size[ZONE_DMA32] = max_dma32 - min;
 #endif
-	zone_size[ZONE_NORMAL] = max - max_dma;
+	zone_size[ZONE_NORMAL] = max - max_dma32;
 
 	memcpy(zhole_size, zone_size, sizeof(zhole_size));
 
@@ -215,14 +215,14 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 			continue;
 
 #ifdef CONFIG_ZONE_DMA32
-		if (start < max_dma) {
-			unsigned long dma_end = min(end, max_dma);
+		if (start < max_dma32) {
+			unsigned long dma_end = min(end, max_dma32);
 			zhole_size[ZONE_DMA32] -= dma_end - start;
 		}
 #endif
-		if (end > max_dma) {
+		if (end > max_dma32) {
 			unsigned long normal_end = min(end, max);
-			unsigned long normal_start = max(start, max_dma);
+			unsigned long normal_start = max(start, max_dma32);
 			zhole_size[ZONE_NORMAL] -= normal_end - normal_start;
 		}
 	}
@@ -407,9 +407,9 @@ void __init arm64_memblock_init(void)
 
 	/* 4GB maximum for 32-bit only capable devices */
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
-		arm64_dma_phys_limit = max_zone_dma_phys();
+		arm64_dma32_phys_limit = max_zone_dma32_phys();
 	else
-		arm64_dma_phys_limit = PHYS_MASK + 1;
+		arm64_dma32_phys_limit = PHYS_MASK + 1;
 
 	reserve_crashkernel();
 
@@ -417,7 +417,7 @@ void __init arm64_memblock_init(void)
 
 	high_memory = __va(memblock_end_of_DRAM() - 1) + 1;
 
-	dma_contiguous_reserve(arm64_dma_phys_limit);
+	dma_contiguous_reserve(arm64_dma32_phys_limit);
 }
 
 void __init bootmem_init(void)
@@ -521,7 +521,7 @@ static void __init free_unused_memmap(void)
 void __init mem_init(void)
 {
 	if (swiotlb_force == SWIOTLB_FORCE ||
-	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT))
+	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
 		swiotlb_init(1);
 	else
 		swiotlb_force = SWIOTLB_NO_FORCE;
-- 
2.22.0

