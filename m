Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7E2EC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A7F206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A7F206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 244038E0036; Wed, 31 Jul 2019 11:48:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F21B8E000D; Wed, 31 Jul 2019 11:48:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1090A8E0036; Wed, 31 Jul 2019 11:48:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0BC8E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so42693196eda.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S8bOWZs8wa2CgfkuK8HhPjYI682g9sPrNBOqzgGn9pw=;
        b=T53TECCSr98HczWapl/XunaeeulCiOzflHk/aFjB0D7ArIq1BxDH7MILFijdNhbuhb
         yHsUm2c4n7XeTrh7IEHLVpa10pm+JnbXyMbqAwNRXAwOX0lObAOJ+cbE3e2LRaWkghq3
         ZLTZXoSmwuGNPIybK3s+cjzv18nni4UREHDo6NwPjJrFuLezVOw1vXpDVZbF2CqTS5ln
         pL4v+1NhOfb4OA+hUo+bWqwg53VLcihlhfNouw+gx/p2/VoImbqBOm8PDZ94kTLOnQFC
         6+N21x/XF7chPBbif24h29sixE97I6tLJ2ZDTvn2eaxznescWs0k9dkvcmAOHLz18760
         hmeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAXRyri0l30F3Hy4/akpH0s+zYTzVI35HGrTVX2a6tdugYVINrt2
	HIvxGRfxHO9jdCw6VzBuws7zKC9NQKuRVN56NGjbBZBkdgAowsCKy472a55igjz+To2kNm6KPjl
	BeofZR6FPfE1aeFnFocRePb1bFU9qnWHG1t4HNLfB9LGPh2GoCSefQvz29dr2mw6N/Q==
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr31875934eju.308.1564588088174;
        Wed, 31 Jul 2019 08:48:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+V03FT013E5d/P7+ZJA8Wn7L1TYzmLqL4xM++Z/6ZNvxtX6WJGn5BEqpohr6dtZ0uxF91
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr31875868eju.308.1564588087122;
        Wed, 31 Jul 2019 08:48:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588087; cv=none;
        d=google.com; s=arc-20160816;
        b=Hy/3Ds1wHCNmW60eLp/r0G01OlFMzJSXxQWeRH+7qX4An5FwPbivZwHeSyfKPaQPgJ
         9YELD5+NzW68y88OJY9g66FZi9/JLsIjPEYh9RRSXCI4ktso3hb2Ift4G180oQA78Gik
         MpUIFejWdxIrXfNINiWApl85rZTKL1ubA8xdZk8mDDVkzt5embIfAoG4MfUbiovod9Es
         chbI9e0l2M92EJkH4kZQL7ODGlozWHrVlcG9G1wQR5wWdW4gOUDf1vHB2q2OdlX9ehI6
         Ds9UCImTjE7QztEFexoebYQ0IL1M/C0g8DuaK58TzmhReUakjPxAyTVzJmTLoaEx06Py
         6zOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=S8bOWZs8wa2CgfkuK8HhPjYI682g9sPrNBOqzgGn9pw=;
        b=u4R4zYGcO/NFYv2RYbGnQZIEDvmi+LWxTRLd8cPttjp6koeyhs2hjppkqUa0tYtw1e
         coYt/jjakrNBJ+JOH7ZSbJdIV32sMyMPBRMDnm21x41FMzy4Uc8I47k40wWwDGNhmSx2
         w1HLxSH8Wpiu13MiwXM+w3uSrEI7RenR4fAYTVIc/j6r807dkhNyytZbgBdBqA0vSTol
         Gs2k40LzQf/VZlWEXTVUtY8BA9bk/O/OK4mAsqZuZhN3Tf8t2jpaemwOfeJ19nmVks/p
         EXFkF2oeqksWgIxOVpP8zhZU0ep7FXP8aLJrZWS2xYsS/4M0vmIiFrD+aW71DnXjx3ry
         wjug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t21si19868147edw.253.2019.07.31.08.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A068AAFA5;
	Wed, 31 Jul 2019 15:48:06 +0000 (UTC)
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
	Will Deacon <will@kernel.org>
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org,
	robh+dt@kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	frowand.list@gmail.com,
	m.szyprowski@samsung.com,
	linux-rpi-kernel@lists.infradead.org
Subject: [PATCH 5/8] arm64: use ZONE_DMA on DMA addressing limited devices
Date: Wed, 31 Jul 2019 17:47:48 +0200
Message-Id: <20190731154752.16557-6-nsaenzjulienne@suse.de>
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

So far all arm64 devices have supported 32 bit DMA masks for their
peripherals. This is not true anymore for the Raspberry Pi 4. Most of
it's peripherals can only address the first GB or memory of a total of
up to 4 GB.

This goes against ZONE_DMA32's original intent, and breaks other
subsystems as it's expected for ZONE_DMA32 to be addressable with a 32
bit mask. So it was decided to use ZONE_DMA for this specific case.

Devices with with 32 bit DMA addressing support will still bypass
ZONE_DMA but those who don't will create both zones. ZONE_DMA will
contain the memory addressable by all the SoC's devices and ZONE_DMA32
the rest of the 32 bit addressable memory.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/arm64/Kconfig   |  4 ++++
 arch/arm64/mm/init.c | 38 ++++++++++++++++++++++++++++++++------
 2 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..a9fd71d3bc8e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -266,6 +266,10 @@ config GENERIC_CSUM
 config GENERIC_CALIBRATE_DELAY
 	def_bool y
 
+config ZONE_DMA
+	bool "Support DMA zone" if EXPERT
+	default y
+
 config ZONE_DMA32
 	bool "Support DMA32 zone" if EXPERT
 	default y
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 1c4ffabbe1cb..f5279ef85756 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -50,6 +50,13 @@
 s64 memstart_addr __ro_after_init = -1;
 EXPORT_SYMBOL(memstart_addr);
 
+/*
+ * We might create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA is needed if there
+ * are periferals unable to address the first naturally aligned 4GB of ram.
+ * ZONE_DMA32 will be expanded to cover the rest of that memory. If such
+ * limitations doesn't exist only ZONE_DMA32 is created.
+ */
+phys_addr_t arm64_dma_phys_limit __ro_after_init;
 phys_addr_t arm64_dma32_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
@@ -193,6 +200,9 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  = {0};
 
+#ifdef CONFIG_ZONE_DMA
+	max_zone_pfns[ZONE_DMA] = PFN_DOWN(arm64_dma_phys_limit);
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	max_zone_pfns[ZONE_DMA32] = PFN_DOWN(arm64_dma32_phys_limit);
 #endif
@@ -207,14 +217,19 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 {
 	struct memblock_region *reg;
 	unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
+	unsigned long max_dma = PFN_DOWN(arm64_dma_phys_limit);
 	unsigned long max_dma32 = min;
 
 	memset(zone_size, 0, sizeof(zone_size));
 
+#ifdef CONFIG_ZONE_DMA
+	if (max_dma)
+		zone_size[ZONE_DMA] = max_dma - min;
+#endif
 	/* 4GB maximum for 32-bit only capable devices */
 #ifdef CONFIG_ZONE_DMA32
 	max_dma32 = PFN_DOWN(arm64_dma32_phys_limit);
-	zone_size[ZONE_DMA32] = max_dma32 - min;
+	zone_size[ZONE_DMA32] = max_dma32 - max_dma - min;
 #endif
 	zone_size[ZONE_NORMAL] = max - max_dma32;
 
@@ -226,11 +241,17 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 
 		if (start >= max)
 			continue;
-
+#ifdef CONFIG_ZONE_DMA
+		if (start < max_dma) {
+			unsigned long dma_end = min_not_zero(end, max_dma);
+			zhole_size[ZONE_DMA] -= dma_end - start;
+		}
+#endif
 #ifdef CONFIG_ZONE_DMA32
 		if (start < max_dma32) {
-			unsigned long dma_end = min(end, max_dma32);
-			zhole_size[ZONE_DMA32] -= dma_end - start;
+			unsigned long dma32_end = min(end, max_dma32);
+			unsigned long dma32_start = max(start, max_dma);
+			zhole_size[ZONE_DMA32] -= dma32_end - dma32_start;
 		}
 #endif
 		if (end > max_dma32) {
@@ -418,6 +439,11 @@ void __init arm64_memblock_init(void)
 
 	early_init_fdt_scan_reserved_mem();
 
+	if (IS_ENABLED(CONFIG_ZONE_DMA))
+		arm64_dma_phys_limit = max_zone_dma_phys();
+	else
+		arm64_dma_phys_limit = 0;
+
 	/* 4GB maximum for 32-bit only capable devices */
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
 		arm64_dma32_phys_limit = max_zone_dma32_phys();
@@ -430,7 +456,7 @@ void __init arm64_memblock_init(void)
 
 	high_memory = __va(memblock_end_of_DRAM() - 1) + 1;
 
-	dma_contiguous_reserve(arm64_dma32_phys_limit);
+	dma_contiguous_reserve(arm64_dma_phys_limit ? : arm64_dma32_phys_limit);
 }
 
 void __init bootmem_init(void)
@@ -533,7 +559,7 @@ static void __init free_unused_memmap(void)
  */
 void __init mem_init(void)
 {
-	if (swiotlb_force == SWIOTLB_FORCE ||
+	if (swiotlb_force == SWIOTLB_FORCE || arm64_dma_phys_limit ||
 	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
 		swiotlb_init(1);
 	else
-- 
2.22.0

