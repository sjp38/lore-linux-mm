Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60839C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EC02206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:48:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EC02206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C4CB8E0041; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 527D08E000D; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F01A8E0041; Wed, 31 Jul 2019 11:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3A1D8E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:48:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so42678326eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:48:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xW9yzjlIisbGkTIVipjGEOl1onAKCapY0yV69WBDskI=;
        b=qa1znJb3IIEdt1uQKBXWk4X6v08L1+4N80G65FUt4LybOhyILGQZcrM1oqn8v3eo/d
         V1U+cMULy8RYnWX9Ni/RyjrQTVKhEzcS4USwPazaG0fRa9fjlqJjBm5i+TKEIJaBIbP9
         qBLjwsLKvZmriC6RVUbE/pgIWpT34J/CO61r4m0qyJjN3vEu3768kbOc930RR3NZD7ru
         8zGJwPm+Eor/eXBjeJC2kv49LY6nSfShn1uKDxsRXPqsaqfZc+Zxsv4OMW4DCkHGM+on
         kaQvjCp8STZ7FHxkK2PmiqyJ1qEAgumO1V4zrv3+qhMuDcZammOiSF2WDzAk6UlbNbsa
         qASw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Gm-Message-State: APjAAAVOWz3EMXUHz5U3V1AyrOo93P6zBpBLxuFdJxhWS/sgY9ZjdIqx
	b6s6qpbN9zC4vPSm2ee0RI+a9VVXnuUZWU2FVcFsDaHwL94BmHtjKqvvyMfRE3N1xYiNKYMaueX
	bbIvfmRweQsf0Ji2YUzE9P96c4gEER7hPQKPrnGiRcGdqvl9MwBoW7eZrf+rd5zr8Mg==
X-Received: by 2002:a17:906:505:: with SMTP id j5mr94950710eja.261.1564588090453;
        Wed, 31 Jul 2019 08:48:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIFu3tmnWYohAAcS1uThVmiJmuAcwS78hs1fsA5JvfB4abQGBcNfuVhRYlRMxui2JkCnLZ
X-Received: by 2002:a17:906:505:: with SMTP id j5mr94950635eja.261.1564588089324;
        Wed, 31 Jul 2019 08:48:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588089; cv=none;
        d=google.com; s=arc-20160816;
        b=RjajqypGNqyKEKNGiMYa8QJ+/vHkhDpe/PbimfGo3YxJFHccw4uAOvxBcgO2hH0Qck
         OTVJSp/jYCtUdaXsp6Lz405mFhDYRveFdK/HsYf1GRc/ph17a6Dy6gwHWh8GQe666LMS
         9VsnDbs7DhI/0/6SvlOYxY7Kj9W0rU9RGal4TfVFZ9MbrAtVWA9NJiZrkmOie1j+sdCO
         sNJeMJCBGwdwl293bHJJTIIZ9sAs5pPNJnHJBLX1LSfmPMlr55qplG4p4FtLVw7BwFf5
         8a3joCzjNyHYPdFS/B7ATXidUxmNg3ZJGcYFCeLZWiQKY9iA/MOLRP87WSgilaPeb+Pi
         vrAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xW9yzjlIisbGkTIVipjGEOl1onAKCapY0yV69WBDskI=;
        b=XZbY7is6ujLbONhd9xJrWqLS4JCRjGFi7OhottYJJ0J409apbewL2An0R3EN0L10nh
         O8maFpCXMQGzHTp45jIu7Szml2rJAGIu+S1IC22bpsCFZys33y8nLoga4Cr9YZvxbqCU
         nkmYtytamdizPGsM+b/tf1UvvXUHGhTDwOSdADDpnXMdjt9F1T9jIS9X/7NvkuLkLv3/
         7153y0oA0T/FwC39m+y8iYW50gbx5swuey7a5fLaWCJKY8kWQXedQPgKKpXYheKZTjWO
         uui/62VDl05mO1JWOc6RiPcnQidQ/Bf34aughP7G4trRYGJFAmOHpMw3Hn9MhwVrlimj
         fTmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u13si19729900ejx.356.2019.07.31.08.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:48:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nsaenzjulienne@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=nsaenzjulienne@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8A38AFFB;
	Wed, 31 Jul 2019 15:48:08 +0000 (UTC)
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
	Marek Szyprowski <m.szyprowski@samsung.com>
Cc: phill@raspberryi.org,
	f.fainelli@gmail.com,
	will@kernel.org,
	linux-kernel@vger.kernel.org,
	robh+dt@kernel.org,
	eric@anholt.net,
	mbrugger@suse.com,
	nsaenzjulienne@suse.de,
	akpm@linux-foundation.org,
	frowand.list@gmail.com,
	linux-rpi-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org
Subject: [PATCH 6/8] dma-direct: turn ARCH_ZONE_DMA_BITS into a variable
Date: Wed, 31 Jul 2019 17:47:49 +0200
Message-Id: <20190731154752.16557-7-nsaenzjulienne@suse.de>
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

Some architectures, notably arm64, are interested in tweaking this
depending on their runtime dma addressing limitations.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
---

 arch/powerpc/include/asm/page.h |  9 ---------
 arch/powerpc/mm/mem.c           | 14 ++++++++++++--
 arch/s390/include/asm/page.h    |  2 --
 arch/s390/mm/init.c             |  1 +
 include/linux/dma-direct.h      |  2 ++
 kernel/dma/direct.c             |  8 +++-----
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 0d52f57fca04..73668a21ae78 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -319,13 +319,4 @@ struct vm_area_struct;
 #endif /* __ASSEMBLY__ */
 #include <asm/slice.h>
 
-/*
- * Allow 30-bit DMA for very limited Broadcom wifi chips on many powerbooks.
- */
-#ifdef CONFIG_PPC32
-#define ARCH_ZONE_DMA_BITS 30
-#else
-#define ARCH_ZONE_DMA_BITS 31
-#endif
-
 #endif /* _ASM_POWERPC_PAGE_H */
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 9191a66b3bc5..3792a998ca02 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -31,6 +31,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/memremap.h>
+#include <linux/dma-direct.h>
 
 #include <asm/pgalloc.h>
 #include <asm/prom.h>
@@ -201,7 +202,7 @@ static int __init mark_nonram_nosave(void)
  * everything else. GFP_DMA32 page allocations automatically fall back to
  * ZONE_DMA.
  *
- * By using 31-bit unconditionally, we can exploit ARCH_ZONE_DMA_BITS to
+ * By using 31-bit unconditionally, we can exploit arch_zone_dma_bits to
  * inform the generic DMA mapping code.  32-bit only devices (if not handled
  * by an IOMMU anyway) will take a first dip into ZONE_NORMAL and get
  * otherwise served by ZONE_DMA.
@@ -237,9 +238,18 @@ void __init paging_init(void)
 	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
 	       (long int)((top_of_ram - total_ram) >> 20));
 
+	/*
+	 * Allow 30-bit DMA for very limited Broadcom wifi chips on many
+	 * powerbooks.
+	 */
+	if (IS_ENABLED(CONFIG_PPC32))
+		arch_zone_dma_bits = 30;
+	else
+		arch_zone_dma_bits = 31;
+
 #ifdef CONFIG_ZONE_DMA
 	max_zone_pfns[ZONE_DMA]	= min(max_low_pfn,
-				      1UL << (ARCH_ZONE_DMA_BITS - PAGE_SHIFT));
+				      1UL << (arch_zone_dma_bits - PAGE_SHIFT));
 #endif
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 #ifdef CONFIG_HIGHMEM
diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index 823578c6b9e2..a4d38092530a 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -177,8 +177,6 @@ static inline int devmem_is_allowed(unsigned long pfn)
 #define VM_DATA_DEFAULT_FLAGS	(VM_READ | VM_WRITE | \
 				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
 
-#define ARCH_ZONE_DMA_BITS	31
-
 #include <asm-generic/memory_model.h>
 #include <asm-generic/getorder.h>
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 20340a03ad90..07d93955d3e4 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -118,6 +118,7 @@ void __init paging_init(void)
 
 	sparse_memory_present_with_active_regions(MAX_NUMNODES);
 	sparse_init();
+	arch_zone_dma_bits = 31;
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 	max_zone_pfns[ZONE_DMA] = PFN_DOWN(MAX_DMA_ADDRESS);
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
diff --git a/include/linux/dma-direct.h b/include/linux/dma-direct.h
index adf993a3bd58..a1b353b77858 100644
--- a/include/linux/dma-direct.h
+++ b/include/linux/dma-direct.h
@@ -5,6 +5,8 @@
 #include <linux/dma-mapping.h>
 #include <linux/mem_encrypt.h>
 
+extern unsigned int arch_zone_dma_bits;
+
 #ifdef CONFIG_ARCH_HAS_PHYS_TO_DMA
 #include <asm/dma-direct.h>
 #else
diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 59bdceea3737..40dfc9b4ee4c 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -19,9 +19,7 @@
  * Most architectures use ZONE_DMA for the first 16 Megabytes, but
  * some use it for entirely different regions:
  */
-#ifndef ARCH_ZONE_DMA_BITS
-#define ARCH_ZONE_DMA_BITS 24
-#endif
+unsigned int arch_zone_dma_bits __ro_after_init = 24;
 
 static void report_addr(struct device *dev, dma_addr_t dma_addr, size_t size)
 {
@@ -72,7 +70,7 @@ static gfp_t __dma_direct_optimal_gfp_mask(struct device *dev, u64 dma_mask,
 	 * Note that GFP_DMA32 and GFP_DMA are no ops without the corresponding
 	 * zones.
 	 */
-	if (*phys_mask <= DMA_BIT_MASK(ARCH_ZONE_DMA_BITS))
+	if (*phys_mask <= DMA_BIT_MASK(arch_zone_dma_bits))
 		return GFP_DMA;
 	if (*phys_mask <= DMA_BIT_MASK(32))
 		return GFP_DMA32;
@@ -387,7 +385,7 @@ int dma_direct_supported(struct device *dev, u64 mask)
 	u64 min_mask;
 
 	if (IS_ENABLED(CONFIG_ZONE_DMA))
-		min_mask = DMA_BIT_MASK(ARCH_ZONE_DMA_BITS);
+		min_mask = DMA_BIT_MASK(arch_zone_dma_bits);
 	else
 		min_mask = DMA_BIT_MASK(32);
 
-- 
2.22.0

