Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B7B4C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41F4521670
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41F4521670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CE9F6B0008; Fri,  6 Sep 2019 08:06:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72F1D6B000A; Fri,  6 Sep 2019 08:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D2CA6B000C; Fri,  6 Sep 2019 08:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 36D5A6B0008
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:06:32 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C2A51180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:06:31 +0000 (UTC)
X-FDA: 75904368582.30.hose70_560ebae2c100a
X-HE-Tag: hose70_560ebae2c100a
X-Filterd-Recvd-Size: 7470
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:06:31 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2A59CAF9F;
	Fri,  6 Sep 2019 12:06:30 +0000 (UTC)
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
Subject: [PATCH v4 3/4] arm64: use both ZONE_DMA and ZONE_DMA32
Date: Fri,  6 Sep 2019 14:06:14 +0200
Message-Id: <20190906120617.18836-4-nsaenzjulienne@suse.de>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190906120617.18836-1-nsaenzjulienne@suse.de>
References: <20190906120617.18836-1-nsaenzjulienne@suse.de>
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

Changes in v4:
- Fixed issue when NUMA=3Dn and ZONE_DMA=3Dn
- Merged two max_zone_dma*_phys() functions

Changes in v3:
- Used fixed size ZONE_DMA
- Fix check befor swiotlb_init()

Changes in v2:
- Update comment to reflect new zones split
- ZONE_DMA will never be left empty

 arch/arm64/Kconfig            |  4 +++
 arch/arm64/include/asm/page.h |  2 ++
 arch/arm64/mm/init.c          | 51 ++++++++++++++++++++++++++---------
 3 files changed, 44 insertions(+), 13 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6b6362b83004..2dbe0165bd15 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -267,6 +267,10 @@ config GENERIC_CSUM
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
index 8e9bc64c5878..95ee7e839c75 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -56,6 +56,13 @@ EXPORT_SYMBOL(physvirt_offset);
 struct page *vmemmap __ro_after_init;
 EXPORT_SYMBOL(vmemmap);
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
@@ -169,15 +176,16 @@ static void __init reserve_elfcorehdr(void)
 {
 }
 #endif /* CONFIG_CRASH_DUMP */
+
 /*
- * Return the maximum physical address for ZONE_DMA32 (DMA_BIT_MASK(32))=
. It
- * currently assumes that for memory starting above 4G, 32-bit devices w=
ill
- * use a DMA offset.
+ * Return the maximum physical address for a zone with a given address s=
ize
+ * limit. It currently assumes that for memory starting above 4G, 32-bit
+ * devices will use a DMA offset.
  */
-static phys_addr_t __init max_zone_dma32_phys(void)
+static phys_addr_t __init max_zone_phys(unsigned int zone_bits)
 {
 	phys_addr_t offset =3D memblock_start_of_DRAM() & GENMASK_ULL(63, 32);
-	return min(offset + (1ULL << 32), memblock_end_of_DRAM());
+	return min(offset + (1ULL << zone_bits), memblock_end_of_DRAM());
 }
=20
 #ifdef CONFIG_NUMA
@@ -186,6 +194,9 @@ static void __init zone_sizes_init(unsigned long min,=
 unsigned long max)
 {
 	unsigned long max_zone_pfns[MAX_NR_ZONES]  =3D {0};
=20
+#ifdef CONFIG_ZONE_DMA
+	max_zone_pfns[ZONE_DMA] =3D PFN_DOWN(arm64_dma_phys_limit);
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	max_zone_pfns[ZONE_DMA32] =3D PFN_DOWN(arm64_dma32_phys_limit);
 #endif
@@ -201,13 +212,18 @@ static void __init zone_sizes_init(unsigned long mi=
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
+	max_dma32 =3D max_dma;
+#endif
 #ifdef CONFIG_ZONE_DMA32
 	max_dma32 =3D PFN_DOWN(arm64_dma32_phys_limit);
-	zone_size[ZONE_DMA32] =3D max_dma32 - min;
+	zone_size[ZONE_DMA32] =3D max_dma32 - max_dma;
 #endif
 	zone_size[ZONE_NORMAL] =3D max - max_dma32;
=20
@@ -219,11 +235,17 @@ static void __init zone_sizes_init(unsigned long mi=
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
@@ -418,9 +440,11 @@ void __init arm64_memblock_init(void)
=20
 	early_init_fdt_scan_reserved_mem();
=20
-	/* 4GB maximum for 32-bit only capable devices */
+	if (IS_ENABLED(CONFIG_ZONE_DMA))
+		arm64_dma_phys_limit =3D max_zone_phys(ARCH_ZONE_DMA_BITS);
+
 	if (IS_ENABLED(CONFIG_ZONE_DMA32))
-		arm64_dma32_phys_limit =3D max_zone_dma32_phys();
+		arm64_dma32_phys_limit =3D max_zone_phys(32);
 	else
 		arm64_dma32_phys_limit =3D PHYS_MASK + 1;
=20
@@ -430,7 +454,7 @@ void __init arm64_memblock_init(void)
=20
 	high_memory =3D __va(memblock_end_of_DRAM() - 1) + 1;
=20
-	dma_contiguous_reserve(arm64_dma32_phys_limit);
+	dma_contiguous_reserve(arm64_dma_phys_limit ? : arm64_dma32_phys_limit)=
;
 }
=20
 void __init bootmem_init(void)
@@ -534,6 +558,7 @@ static void __init free_unused_memmap(void)
 void __init mem_init(void)
 {
 	if (swiotlb_force =3D=3D SWIOTLB_FORCE ||
+	    max_pfn > (arm64_dma_phys_limit >> PAGE_SHIFT) ||
 	    max_pfn > (arm64_dma32_phys_limit >> PAGE_SHIFT))
 		swiotlb_init(1);
 	else
--=20
2.23.0


