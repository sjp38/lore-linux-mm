Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9511C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:11:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AF422173E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:11:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AF422173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A2B6B0008; Mon,  2 Sep 2019 10:10:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 822896B000A; Mon,  2 Sep 2019 10:10:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70D8A6B000C; Mon,  2 Sep 2019 10:10:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEA96B0008
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:10:57 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E7908824CA32
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:10:56 +0000 (UTC)
X-FDA: 75890166912.23.bear69_426f2f85a7254
X-HE-Tag: bear69_426f2f85a7254
X-Filterd-Recvd-Size: 7309
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:10:56 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 75BC9AD78;
	Mon,  2 Sep 2019 14:10:55 +0000 (UTC)
From: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
To: catalin.marinas@arm.com,
	hch@lst.de,
	wahrenst@gmx.net,
	marc.zyngier@arm.com,
	robh+dt@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-riscv@lists.infradead.org,
	Will Deacon <will@kernel.org>
Cc: f.fainelli@gmail.com,
	robin.murphy@arm.com,
	nsaenzjulienne@suse.de,
	linux-kernel@vger.kernel.org,
	mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org,
	phill@raspberrypi.org,
	m.szyprowski@samsung.com
Subject: [PATCH v3 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
Date: Mon,  2 Sep 2019 16:10:41 +0200
Message-Id: <20190902141043.27210-4-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190902141043.27210-1-nsaenzjulienne@suse.de>
References: <20190902141043.27210-1-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

So far all arm64 devices have supported 32 bit DMA masks for their
peripherals. This is not true anymore for the Raspberry Pi 4 as most of
it's peripherals can only address the first GB of memory on a total of
up to 4 GB.

This goes against ZONE_DMA32's intent, as it's expected for ZONE_DMA32
to be addressable with a 32 bit mask. So it was decided to re-introduce
ZONE_DMA in arm64.

ZONE_DMA will contain the lower 1G of memory, which is currently the
memory area addressable by any peripheral on an arm64 device.
ZONE_DMA32 will contain the rest of the 32 bit addressable memory.

Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>

---

Changes in v3:
- Used fixed size ZONE_DMA
- Fix check befor swiotlb_init()

Changes in v2:
- Update comment to reflect new zones split
- ZONE_DMA will never be left empty

 arch/arm64/Kconfig            |  4 +++
 arch/arm64/include/asm/page.h |  2 ++
 arch/arm64/mm/init.c          | 51 ++++++++++++++++++++++++++++-------
 3 files changed, 47 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3adcec05b1f6..a9fd71d3bc8e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -266,6 +266,10 @@ config GENERIC_CSUM
 config GENERIC_CALIBRATE_DELAY
 	def_bool y
=20
+config ZONE_DMA
+	bool "Support DMA zone" if EXPERT
+	default y
+
 config ZONE_DMA32
 	bool "Support DMA32 zone" if EXPERT
 	default y
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.=
h
index d39ddb258a04..7b8c98830101 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -38,4 +38,6 @@ extern int pfn_valid(unsigned long);
=20
 #include <asm-generic/getorder.h>
=20
+#define ARCH_ZONE_DMA_BITS 30
+
 #endif
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 8956c22634dd..f02a4945aeac 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -50,6 +50,13 @@
 s64 memstart_addr __ro_after_init =3D -1;
 EXPORT_SYMBOL(memstart_addr);
=20
+/*
+ * We create both ZONE_DMA and ZONE_DMA32. ZONE_DMA covers the first 1G =
of
+ * memory as some devices, namely the Raspberry Pi 4, have peripherals w=
ith
+ * this limited view of the memory. ZONE_DMA32 will cover the rest of th=
e 32
+ * bit addressable memory area.
+ */
+phys_addr_t arm64_dma_phys_limit __ro_after_init;
 phys_addr_t arm64_dma32_phys_limit __ro_after_init;
=20
 #ifdef CONFIG_KEXEC_CORE
@@ -164,9 +171,9 @@ static void __init reserve_elfcorehdr(void)
 }
 #endif /* CONFIG_CRASH_DUMP */
 /*
- * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32))=
. It
- * currently assumes that for memory starting above 4G, 32-bit devices w=
ill
- * use a DMA offset.
+ * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32))=
 and
+ * ZONE_DMA (DMA_BIT_MASK(30)) respectively. It currently assumes that f=
or
+ * memory starting above 4G, 32-bit devices will use a DMA offset.
  */
 static phys_addr_t __init max_zone_dma32_phys(void)
 {
@@ -174,12 +181,23 @@ static phys_addr_t __init max_zone_dma32_phys(void)
 	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
 }
=20
+static phys_addr_t __init max_zone_dma_phys(void)
+{
+	phys_addr_t offset =3D memblock_start_of_DRAM() & GENMASK_ULL(63, 32);
+
+	return min(offset + (1ULL << ARCH_ZONE_DMA_BITS),
+		   memblock_end_of_DRAM());
+}
+
 #ifdef CONFIG_NUMA
=20
 static void __init zone_sizes_init(unsigned long min, unsigned long max)
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  =3D {0};
=20
+#ifdef CONFIG_ZONE_DMA
+	max_zone_pfns[ZONE_DMA] =3D PFN_DOWN(arm64_dma_phys_limit);
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(arm64_dma32_phys_limit);
 #endif
@@ -195,13 +213,17 @@ static void __init zone_sizes_init(unsigned long mi=
n, unsigned long max)
 	struct memblock_region *reg;
 	unsigned long zone_size[MAX_NR_ZONES], zhole_size[MAX_NR_ZONES];
 	unsigned long max_dma32 =3D min;
+	unsigned long max_dma =3D min;
=20
 	memset(zone_size, 0, sizeof(zone_size));
=20
-	/* 4GB maximum for 32-bit only capable devices */
+#ifdef CONFIG_ZONE_DMA
+	max_dma =3D PFN_DOWN(arm64_dma_phys_limit);
+	zone_size[ZONE_DMA] =3D max_dma - min;
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	max_dma32 =3D PFN_DOWN(arm64_dma32_phys_limit);
-	zone_size[ZONE_DMA32] =3D max_dma32 - min;
+	zone_size[ZONE_DMA32] =3D max_dma32 - max_dma;
 #endif
 	zone_size[ZONE_NORMAL] =3D max - max_dma32;
=20
@@ -213,11 +235,17 @@ static void __init zone_sizes_init(unsigned long mi=
n, unsigned long max)
=20
 		if (start >=3D max)
 			continue;
-
+#ifdef CONFIG_ZONE_DMA
+		if (start < max_dma) {
+			unsigned long dma_end =3D min_not_zero(end, max_dma);
+			zhole_size[ZONE_DMA] -=3D dma_end - start;
+		}
+#endif
 #ifdef CONFIG_ZONE_DMA32
 		if (start < max_dma32) {
-			unsigned long dma_end =3D min(end, max_dma32);
-			zhole_size[ZONE_DMA32] -=3D dma_end - start;
+			unsigned long dma32_end =3D min(end, max_dma32);
+			unsigned long dma32_start =3D max(start, max_dma);
+			zhole_size[ZONE_DMA32] -=3D dma32_end - dma32_start;
 		}
 #endif
 		if (end > max_dma32) {
@@ -405,7 +433,9 @@ void __init arm64_memblock_init(void)
=20
 	early_init_fdt_scan_reserved_mem();
=20
-	/* 4GB maximum for 32-bit only capable devices */
+	if (IS_ENABLED(CONFIG_ZONE_DMA))
+		arm64_dma_phys_limit =3D max_zone_dma_phys();
+
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
 		arm64_dma32_phys_limit =3D max_zone_dma32_phys();
 	else
@@ -417,7 +447,7 @@ void __init arm64_memblock_init(void)
=20
 	high_memory =3D __va(memblock_end_of_DRAM() - 1) + 1;
=20
-	dma_contiguous_reserve(arm64_dma32_phys_limit);
+	dma_contiguous_reserve(arm64_dma_phys_limit ? : arm64_dma32_phys_limit)=
;
 }
=20
 void __init bootmem_init(void)
@@ -521,6 +551,7 @@ static void __init free_unused_memmap(void)
 void __init mem_init(void)
 {
 	if (swiotlb_force =3D=3D SWIOTLB_FORCE ||
+	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT) ||
 	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
 		swiotlb_init(1);
 	else
--=20
2.23.0


