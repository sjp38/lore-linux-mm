Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BE01C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 207AA26303
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 207AA26303
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE6EF6B0283; Thu, 30 May 2019 19:13:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A973C6B0285; Thu, 30 May 2019 19:13:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 986846B0286; Thu, 30 May 2019 19:13:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3306B0283
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o12so4886553pll.17
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=UZfQfw/tv06I09tzxEA1NR+q+/SfO/X5yRnUA7mMO5E=;
        b=Onbxw3zIQzPz50oUlFeLebrhJlVm3bIA1A3GIc0gtcUVJGTKhXkdIwt2TOxVEN0dwJ
         V2NYG6rUWR2bgq87vnJ5ATjvKDykSQ9Ov+0lfEJ6ATBg3dUxu+hFdojGukqcuo98ADgZ
         71g9NS1Yp41ZDkpCuGBFToEAjQpsfG7vdfHqHPcHFMRzZU0B96Kmq7apox1EcmNPO/Ez
         qlYL6V5B2r8ys0WmIRHhyqPKjDwPGx6HeUYRxbQVFwHL+6TpfOuC9K2/Z6+/v7Z+0aF5
         arPJeRtzOl/XZjyW7fHOrEAiro9X9l54jcLR57jw5wVMkiQ/yfQglpJZ3MKimmMOOdyv
         lQ4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXVAZ0phbQ+h0VWpY4XEHxzu/1B9+JmcRKrZsr0Y/fv4EGkWrdT
	HI1uGmSU5v98gXnNfy2ai1WAnHd54e82cnEwdexoG3LY6m4Bcmu5zrBQiTxZDsaMST6CjaQKZsk
	/2KBM2F0h6q82XDF2QMgUzH0E1n3nNdQkMFTtBzp2u7p4l+iGhHMfr3ZVOh3+zjWG2g==
X-Received: by 2002:a17:90a:9602:: with SMTP id v2mr5874757pjo.59.1559258012926;
        Thu, 30 May 2019 16:13:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOB1WGewuxMW2JZU6s/B2rXh0NNIEte9QkuEMxjBBuELcaGUerAy5ECv87NNfCmLozzt3m
X-Received: by 2002:a17:90a:9602:: with SMTP id v2mr5874688pjo.59.1559258011759;
        Thu, 30 May 2019 16:13:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258011; cv=none;
        d=google.com; s=arc-20160816;
        b=GCY+j6/i2QD4uQnTtSPIEv5wB/W9gqbrAps4wkpqwUTV7d87bC2K5PkR2RwRDpnfyL
         JwadDiTNcpn94uDSABgrVkU/VdxGWv4rGYIxHIyaYtcgDTEhUunqksBhWUfhg+eOWUfJ
         Jx4BQtIGx66AcBpbHI25mrZsBDbCqJyeG5rQWMMTFDI4WfCq7VB8ePgUuGZXKffrSjwN
         uaej9yOst9fbRqfpZi3cpzdHYWXLAsP/9UZFdEzJ526ZiheF9IFRsxPI1KQxWxfPIhHw
         uWKGrpzPeKN2WSXu/9fJOqKB0AFkIQiTl/FjNDdpCzbH4bAfj6Vcfa8jcsha+xDVAVxb
         F8yQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=UZfQfw/tv06I09tzxEA1NR+q+/SfO/X5yRnUA7mMO5E=;
        b=QdxfKUV/XEkjVuph04LND5bllT1Xun82x4+0ZHK+OPPd7jTqJXVlHX+bxWHaXjU1Lc
         28BZBkCXHxwVgJpjJPBFxrHxzYaI4RlOXY2lXgyjm90eQc3RC6l2eggEKNKjEfJuTklG
         0OQ8XQTt7XO8K0pqQZ4LnsKGt0i13sl3ax5mtHupVlQcyUtOw5SnSdU0YLmt5vEDZKTG
         qgbG/3E6z+FADksuP0duwklRRFCAHYbaQQrQ83XxOup64+qTr41XLfe/2TccUPJQ16L2
         yubGOFdt5DZPi9oVVivePMeuBpU/cFs4GrIb7O44q2+OnfW3l/QIJ77o2o8NqttKSUm6
         MPyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b9si852431pls.303.2019.05.30.16.13.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:31 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 30 May 2019 16:13:31 -0700
Subject: [PATCH v2 4/8] x86,
 efi: Reserve UEFI 2.8 Specific Purpose Memory for dax
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: x86@kernel.org, Borislav Petkov <bp@alien8.de>,
 Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, kbuild test robot <lkp@intel.com>,
 vishal.l.verma@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 x86@kernel.org, linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:43 -0700
Message-ID: <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

UEFI 2.8 defines an EFI_MEMORY_SP attribute bit to augment the
interpretation of the EFI Memory Types as "reserved for a special
purpose".

The proposed Linux behavior for specific purpose memory is that it is
reserved for direct-access (device-dax) by default and not available for
any kernel usage, not even as an OOM fallback. Later, through udev
scripts or another init mechanism, these device-dax claimed ranges can
be reconfigured and hot-added to the available System-RAM with a unique
node identifier.

This patch introduces 3 new concepts at once given the entanglement
between early boot enumeration relative to memory that can optionally be
reserved from the kernel page allocator by default. The new concepts
are:

- E820_TYPE_SPECIFIC: Upon detecting the EFI_MEMORY_SP attribute on
  EFI_CONVENTIONAL memory, update the E820 map with this new type. Only
  perform this classification if the CONFIG_EFI_SPECIFIC_DAX=y policy is
  enabled, otherwise treat it as typical ram.

- IORES_DESC_APPLICATION_RESERVED: Add a new I/O resource descriptor for
  a device driver to search iomem resources for application specific
  memory. Teach the iomem code to identify such ranges as "Application
  Reserved".

- MEMBLOCK_APP_SPECIFIC: Given the memory ranges can fallback to the
  traditional System RAM pool the expectation is that they will have
  typical SRAT entries. In order to support a policy of device-dax by
  default with the option to hotplug later, the numa initialization code
  is taught to avoid marking online MEMBLOCK_APP_SPECIFIC regions.

A follow-on change integrates parsing of the ACPI HMAT to identify the
node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
now, just identify and reserve memory of this type.

Cc: <x86@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Darren Hart <dvhart@infradead.org>
Cc: Andy Shevchenko <andy@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig                  |   20 ++++++++++++++++++++
 arch/x86/boot/compressed/eboot.c  |    5 ++++-
 arch/x86/boot/compressed/kaslr.c  |    2 +-
 arch/x86/include/asm/e820/types.h |    9 +++++++++
 arch/x86/kernel/e820.c            |    9 +++++++--
 arch/x86/kernel/setup.c           |    1 +
 arch/x86/platform/efi/efi.c       |   37 +++++++++++++++++++++++++++++++++----
 drivers/acpi/numa.c               |   15 ++++++++++++++-
 include/linux/efi.h               |   14 ++++++++++++++
 include/linux/ioport.h            |    1 +
 include/linux/memblock.h          |    7 +++++++
 mm/memblock.c                     |    4 ++++
 12 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2bbbd4d1ba31..2d58f32ed6fa 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1955,6 +1955,26 @@ config EFI_MIXED
 
 	   If unsure, say N.
 
+config EFI_SPECIFIC_DAX
+	bool "DAX Support for EFI Specific Purpose Memory"
+	depends on EFI
+	---help---
+	  On systems that have mixed performance classes of memory EFI
+	  may indicate specific purpose memory with an attribute (See
+	  EFI_MEMORY_SP in UEFI 2.8). A memory range tagged with this
+	  attribute may have unique performance characteristics compared
+	  to the system's general purpose "System RAM" pool. On the
+	  expectation that such memory has application specific usage,
+	  and its base EFI memory type is "conventional" answer Y to
+	  arrange for the kernel to reserve it for direct-access
+	  (device-dax) by default. The memory range can later be
+	  optionally assigned to the page allocator by system
+	  administrator policy via the device-dax kmem facility. Say N
+	  to have the kernel treat this memory as general purpose by
+	  default.
+
+	  If unsure, say Y.
+
 config SECCOMP
 	def_bool y
 	prompt "Enable seccomp to safely compute untrusted bytecode"
diff --git a/arch/x86/boot/compressed/eboot.c b/arch/x86/boot/compressed/eboot.c
index 544ac4fafd11..5afa6de508e4 100644
--- a/arch/x86/boot/compressed/eboot.c
+++ b/arch/x86/boot/compressed/eboot.c
@@ -560,7 +560,10 @@ setup_e820(struct boot_params *params, struct setup_data *e820ext, u32 e820ext_s
 		case EFI_BOOT_SERVICES_CODE:
 		case EFI_BOOT_SERVICES_DATA:
 		case EFI_CONVENTIONAL_MEMORY:
-			e820_type = E820_TYPE_RAM;
+			if (is_efi_dax(d))
+				e820_type = E820_TYPE_SPECIFIC;
+			else
+				e820_type = E820_TYPE_RAM;
 			break;
 
 		case EFI_ACPI_MEMORY_NVS:
diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index 2e53c056ba20..8af8b4d4ebc9 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -757,7 +757,7 @@ process_efi_entries(unsigned long minimum, unsigned long image_size)
 		 *
 		 * Only EFI_CONVENTIONAL_MEMORY is guaranteed to be free.
 		 */
-		if (md->type != EFI_CONVENTIONAL_MEMORY)
+		if (md->type != EFI_CONVENTIONAL_MEMORY || is_efi_dax(md))
 			continue;
 
 		if (efi_mirror_found &&
diff --git a/arch/x86/include/asm/e820/types.h b/arch/x86/include/asm/e820/types.h
index c3aa4b5e49e2..7209e611a89d 100644
--- a/arch/x86/include/asm/e820/types.h
+++ b/arch/x86/include/asm/e820/types.h
@@ -28,6 +28,15 @@ enum e820_type {
 	 */
 	E820_TYPE_PRAM		= 12,
 
+	/*
+	 * Special-purpose / application-specific memory is indicated to
+	 * the system via the EFI_MEMORY_SP attribute. Define an e820
+	 * translation of this memory type for the purpose of
+	 * reserving this range and marking it with the
+	 * IORES_DESC_APPLICATION_RESERVED designation.
+	 */
+	E820_TYPE_SPECIFIC	= 0xefffffff,
+
 	/*
 	 * Reserved RAM used by the kernel itself if
 	 * CONFIG_INTEL_TXT=y is enabled, memory of this type
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 8f32e705a980..735f86594cab 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -189,6 +189,7 @@ static void __init e820_print_type(enum e820_type type)
 	switch (type) {
 	case E820_TYPE_RAM:		/* Fall through: */
 	case E820_TYPE_RESERVED_KERN:	pr_cont("usable");			break;
+	case E820_TYPE_SPECIFIC:	pr_cont("application reserved");	break;
 	case E820_TYPE_RESERVED:	pr_cont("reserved");			break;
 	case E820_TYPE_ACPI:		pr_cont("ACPI data");			break;
 	case E820_TYPE_NVS:		pr_cont("ACPI NVS");			break;
@@ -1036,6 +1037,7 @@ static const char *__init e820_type_to_string(struct e820_entry *entry)
 	case E820_TYPE_UNUSABLE:	return "Unusable memory";
 	case E820_TYPE_PRAM:		return "Persistent Memory (legacy)";
 	case E820_TYPE_PMEM:		return "Persistent Memory";
+	case E820_TYPE_SPECIFIC:	return "Application Reserved";
 	case E820_TYPE_RESERVED:	return "Reserved";
 	default:			return "Unknown E820 type";
 	}
@@ -1051,6 +1053,7 @@ static unsigned long __init e820_type_to_iomem_type(struct e820_entry *entry)
 	case E820_TYPE_UNUSABLE:	/* Fall-through: */
 	case E820_TYPE_PRAM:		/* Fall-through: */
 	case E820_TYPE_PMEM:		/* Fall-through: */
+	case E820_TYPE_SPECIFIC:	/* Fall-through: */
 	case E820_TYPE_RESERVED:	/* Fall-through: */
 	default:			return IORESOURCE_MEM;
 	}
@@ -1063,6 +1066,7 @@ static unsigned long __init e820_type_to_iores_desc(struct e820_entry *entry)
 	case E820_TYPE_NVS:		return IORES_DESC_ACPI_NV_STORAGE;
 	case E820_TYPE_PMEM:		return IORES_DESC_PERSISTENT_MEMORY;
 	case E820_TYPE_PRAM:		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
+	case E820_TYPE_SPECIFIC:	return IORES_DESC_APPLICATION_RESERVED;
 	case E820_TYPE_RESERVED_KERN:	/* Fall-through: */
 	case E820_TYPE_RAM:		/* Fall-through: */
 	case E820_TYPE_UNUSABLE:	/* Fall-through: */
@@ -1078,13 +1082,14 @@ static bool __init do_mark_busy(enum e820_type type, struct resource *res)
 		return true;
 
 	/*
-	 * Treat persistent memory like device memory, i.e. reserve it
-	 * for exclusive use of a driver
+	 * Treat persistent memory and other special memory ranges like
+	 * device memory, i.e. reserve it for exclusive use of a driver
 	 */
 	switch (type) {
 	case E820_TYPE_RESERVED:
 	case E820_TYPE_PRAM:
 	case E820_TYPE_PMEM:
+	case E820_TYPE_SPECIFIC:
 		return false;
 	case E820_TYPE_RESERVED_KERN:
 	case E820_TYPE_RAM:
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 08a5f4a131f5..ddde1c7b1f9a 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1109,6 +1109,7 @@ void __init setup_arch(char **cmdline_p)
 
 	if (efi_enabled(EFI_MEMMAP)) {
 		efi_fake_memmap();
+		efi_find_app_specific();
 		efi_find_mirror();
 		efi_esrt_init();
 
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index e1cb01a22fa8..899f1305c77a 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -123,10 +123,15 @@ void __init efi_find_mirror(void)
  * more than the max 128 entries that can fit in the e820 legacy
  * (zeropage) memory map.
  */
+enum add_efi_mode {
+	ADD_EFI_ALL,
+	ADD_EFI_APP_SPECIFIC,
+};
 
-static void __init do_add_efi_memmap(void)
+static void __init do_add_efi_memmap(enum add_efi_mode mode)
 {
 	efi_memory_desc_t *md;
+	int add = 0;
 
 	for_each_efi_memory_desc(md) {
 		unsigned long long start = md->phys_addr;
@@ -139,7 +144,9 @@ static void __init do_add_efi_memmap(void)
 		case EFI_BOOT_SERVICES_CODE:
 		case EFI_BOOT_SERVICES_DATA:
 		case EFI_CONVENTIONAL_MEMORY:
-			if (md->attribute & EFI_MEMORY_WB)
+			if (is_efi_dax(md))
+				e820_type = E820_TYPE_SPECIFIC;
+			else if (md->attribute & EFI_MEMORY_WB)
 				e820_type = E820_TYPE_RAM;
 			else
 				e820_type = E820_TYPE_RESERVED;
@@ -165,9 +172,24 @@ static void __init do_add_efi_memmap(void)
 			e820_type = E820_TYPE_RESERVED;
 			break;
 		}
+
+		if (e820_type == E820_TYPE_SPECIFIC) {
+			memblock_remove(start, size);
+			memblock_add_range(&memblock.reserved, start, size,
+					MAX_NUMNODES, MEMBLOCK_APP_SPECIFIC);
+		} else if (mode != ADD_EFI_APP_SPECIFIC)
+			continue;
+
+		add++;
 		e820__range_add(start, size, e820_type);
 	}
-	e820__update_table(e820_table);
+	if (add)
+		e820__update_table(e820_table);
+}
+
+void __init efi_find_app_specific(void)
+{
+	do_add_efi_memmap(ADD_EFI_APP_SPECIFIC);
 }
 
 int __init efi_memblock_x86_reserve_range(void)
@@ -200,7 +222,7 @@ int __init efi_memblock_x86_reserve_range(void)
 		return rv;
 
 	if (add_efi_memmap)
-		do_add_efi_memmap();
+		do_add_efi_memmap(ADD_EFI_ALL);
 
 	WARN(efi.memmap.desc_version != 1,
 	     "Unexpected EFI_MEMORY_DESCRIPTOR version %ld",
@@ -753,6 +775,13 @@ static bool should_map_region(efi_memory_desc_t *md)
 	if (IS_ENABLED(CONFIG_X86_32))
 		return false;
 
+	/*
+	 * Specific purpose memory assigned to device-dax is
+	 * not mapped by default.
+	 */
+	if (is_efi_dax(md))
+		return false;
+
 	/*
 	 * Map all of RAM so that we can access arguments in the 1:1
 	 * mapping when making EFI runtime calls.
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 30995834ad70..9083bb8f611b 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -260,7 +260,7 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
-	u64 start, end;
+	u64 start, end, i, a_start, a_end;
 	u32 hotpluggable;
 	int node, pxm;
 
@@ -283,6 +283,19 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if (acpi_srat_revision <= 1)
 		pxm &= 0xff;
 
+	/* Clamp Application Specific Memory */
+	for_each_mem_range(i, &memblock.reserved, NULL, NUMA_NO_NODE,
+			MEMBLOCK_APP_SPECIFIC, &a_start, &a_end, NULL) {
+		pr_debug("%s: SP: %#llx %#llx SRAT: %#llx %#llx\n", __func__,
+				a_start, a_end, start, end);
+		if (a_start <= start && a_end >= end)
+			goto out_err;
+		if (a_start >= start && a_start < end)
+			start = a_start;
+		if (a_end <= end && end > start)
+			end = a_end;
+	}
+
 	node = acpi_map_pxm_to_node(pxm);
 	if (node == NUMA_NO_NODE || node >= MAX_NUMNODES) {
 		pr_err("SRAT: Too many proximity domains.\n");
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 91368f5ce114..b57b123cbdf9 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -129,6 +129,19 @@ typedef struct {
 	u64 attribute;
 } efi_memory_desc_t;
 
+#ifdef CONFIG_EFI_SPECIFIC_DAX
+static inline bool is_efi_dax(efi_memory_desc_t *md)
+{
+	return md->type == EFI_CONVENTIONAL_MEMORY
+		&& (md->attribute & EFI_MEMORY_SP);
+}
+#else
+static inline bool is_efi_dax(efi_memory_desc_t *md)
+{
+	return false;
+}
+#endif
+
 typedef struct {
 	efi_guid_t guid;
 	u32 headersize;
@@ -1043,6 +1056,7 @@ extern efi_status_t efi_query_variable_store(u32 attributes,
 					     unsigned long size,
 					     bool nonblocking);
 extern void efi_find_mirror(void);
+extern void efi_find_app_specific(void);
 #else
 
 static inline efi_status_t efi_query_variable_store(u32 attributes,
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index da0ebaec25f0..2d79841ee9b9 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -133,6 +133,7 @@ enum {
 	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
 	IORES_DESC_DEVICE_PRIVATE_MEMORY	= 6,
 	IORES_DESC_DEVICE_PUBLIC_MEMORY		= 7,
+	IORES_DESC_APPLICATION_RESERVED		= 8,
 };
 
 /* helpers to define resources */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 676d3900e1bd..58c29180f2cd 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -35,12 +35,14 @@ extern unsigned long long max_possible_pfn;
  * @MEMBLOCK_HOTPLUG: hotpluggable region
  * @MEMBLOCK_MIRROR: mirrored region
  * @MEMBLOCK_NOMAP: don't add to kernel direct mapping
+ * @MEMBLOCK_APP_SPECIFIC: reserved / application specific range
  */
 enum memblock_flags {
 	MEMBLOCK_NONE		= 0x0,	/* No special request */
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
 	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
+	MEMBLOCK_APP_SPECIFIC	= 0x8,  /* reserved / application specific range */
 };
 
 /**
@@ -215,6 +217,11 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
 	return m->flags & MEMBLOCK_MIRROR;
 }
 
+static inline bool memblock_is_app_specific(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_APP_SPECIFIC;
+}
+
 static inline bool memblock_is_nomap(struct memblock_region *m)
 {
 	return m->flags & MEMBLOCK_NOMAP;
diff --git a/mm/memblock.c b/mm/memblock.c
index 6bbad46f4d2c..654fecb52ba5 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -982,6 +982,10 @@ static bool should_skip_region(struct memblock_region *m, int nid, int flags)
 	if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
 		return true;
 
+	/* if we want specific memory skip non-specific memory regions */
+	if ((flags & MEMBLOCK_APP_SPECIFIC) && !memblock_is_app_specific(m))
+		return true;
+
 	/* skip nomap memory unless we were asked for it explicitly */
 	if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
 		return true;

