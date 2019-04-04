Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3150DC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7B042075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7B042075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 893996B0266; Thu,  4 Apr 2019 15:21:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 843896B0269; Thu,  4 Apr 2019 15:21:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734656B026A; Thu,  4 Apr 2019 15:21:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 393426B0266
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u78so2369448pfa.12
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=mUGSMeK/z6xQc5qTC/EsW6ZXZgYY4YzJrYllkb+7LZQ=;
        b=lluvM1ve0zRkY6kgayfbr1eXy82PSEuakoszlEx44fcxAzdCxhlfR+9PqO0lTE+5Ds
         iIPSSd/4KBUVYFAKcgxWWevy2wWIButuxQri8FKDwEzPqQXHVxCaO5+cgiPwXgs2BkpR
         uKEmYoDqU7XrmXdYSdptwpGRIyF2WSD3KoVqKrQOMlBkSiUUSVgnZG/MPEJklgbAxjzN
         MHcfzgAwZg/1E6h1OIj/8lM11VqS6YkdxVip3kyYSU8BEGcBxGYbGxtVz/RCEy8JwX4/
         MMait5SuA+uSQYguuOvhOIBafzw/8hr9Ey4UxgqYPxmYUqMO0ky1D4WKE6JYwga4cyXX
         oNBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWPckm0j1P55qlwv74wBfXw7mu+4RoRLH2ZcUPmeTXOPbPxRhfr
	is+uikRv5iTL9vw9GYZn4gM6DxNIcAdxZBXEElcXgXmunP3QwJUsyXKxzClTIkOlh16rLuiLODs
	0TvJUUOG5j36riV8lezqi0unBttyFy5NmZ+wMLTyu61rmczENEMFKeup1sXGyoW2LCw==
X-Received: by 2002:a62:52c3:: with SMTP id g186mr7732489pfb.173.1554405674760;
        Thu, 04 Apr 2019 12:21:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBEmQNqSr32tgA0YFgy4PgJAjYIe4HA6fF+M8i5OGwSJ3oAjJZhAet9e/zkBfwPrqGA8tF
X-Received: by 2002:a62:52c3:: with SMTP id g186mr7732405pfb.173.1554405673431;
        Thu, 04 Apr 2019 12:21:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405673; cv=none;
        d=google.com; s=arc-20160816;
        b=WICUdgr59c2F9jNGT4uUvDVHlHc5da6vNxUXJ7NKhsn+s27WGOCsUq7f1jhTwIRCo9
         +EXt2LYc5KOEJc36kNuUji7hc/jJAyouVhYdh3/mnvWOYBWFkL8oZSp9gd1i825pDkCw
         Z/nvP0gW2bzSC1FztB6AWW8iCtnGXwCAMjwl+7bZ0kTDCva29j6Cw98fCskk8eItyCFA
         g6YPvr8+HMWEh4ou+H2EVQgXHoMvL9fYQwiJn5INwlpDeiYqI+nIgqo6glYh8I4ci8pd
         w1IzKZi9h41kr7rJleD1yEt1NoYjidawscpv73+g9qYeQ9y98+Qb8dQkGttYpZc+1d/+
         5TAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=mUGSMeK/z6xQc5qTC/EsW6ZXZgYY4YzJrYllkb+7LZQ=;
        b=zEqsOs/7uvujs65ECSOQgF2EsaRDoTuNeFjyX0j0o+sEX470d8HktMBXQgdIyvIYth
         yAdZCSl6fS3QclVA4BN/I+qaHqEArJHNkoWSzkJr5OWb5xhRUlUPihEgBvtwLsy3VN8L
         h8+/QRWtTbi+KpFJUFHoMHmOVRMTh0gUeStUskjLXfmEMkbyFAsKFagQFhb6KSi922nE
         x1xl9p530Ngh13SMjcrvf4EykXUMvmeMSjyTjYuAIIMSZymutJiIwWN619qOan6/NDUO
         4FyGcDYenqzHJL5S1JcEjghaPHVgtG8K8mafWdhICESPk+OV6fYdr5OefUR/sawK7cgf
         g/yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f6si17402503plf.356.2019.04.04.12.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="288767543"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 04 Apr 2019 12:21:12 -0700
Subject: [RFC PATCH 1/5] efi: Detect UEFI 2.8 Special Purpose Memory
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Darren Hart <dvhart@infradead.org>,
 Andy Shevchenko <andy@infradead.org>, vishal.l.verma@intel.com, x86@kernel.org,
 linux-mm@kvack.org, keith.busch@intel.com, vishal.l.verma@intel.com,
 linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:33 -0700
Message-ID: <155440491334.3190322.44013027330479237.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
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

The proposed Linux behavior for special purpose memory is that it is
reserved for direct-access (device-dax) by default and not available for
any kernel usage, not even as an OOM fallback. Later, through udev
scripts or another init mechanism, these device-dax claimed ranges can
be reconfigured and hot-added to the available System-RAM with a unique
node identifier.

A follow-on patch integrates parsing of the ACPI HMAT to identify the
node and sub-range boundaries of EFI_MEMORY_SP designated memory. For
now, arrange for EFI_MEMORY_SP memory to be reserved.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Darren Hart <dvhart@infradead.org>
Cc: Andy Shevchenko <andy@infradead.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/Kconfig                  |   18 ++++++++++++++++++
 arch/x86/boot/compressed/eboot.c  |    5 ++++-
 arch/x86/boot/compressed/kaslr.c  |    2 +-
 arch/x86/include/asm/e820/types.h |    9 +++++++++
 arch/x86/kernel/e820.c            |    9 +++++++--
 arch/x86/platform/efi/efi.c       |   10 +++++++++-
 include/linux/efi.h               |   14 ++++++++++++++
 include/linux/ioport.h            |    1 +
 8 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c1f9b3cf437c..cb9ca27de7a5 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1961,6 +1961,24 @@ config EFI_MIXED
 
 	   If unsure, say N.
 
+config EFI_SPECIAL_MEMORY
+	bool "EFI Special Purpose Memory Support"
+	depends on EFI
+	---help---
+	  On systems that have mixed performance classes of memory EFI
+	  may indicate special purpose memory with an attribute (See
+	  EFI_MEMORY_SP in UEFI 2.8). A memory range tagged with this
+	  attribute may have unique performance characteristics compared
+	  to the system's general purpose "System RAM" pool. On the
+	  expectation that such memory has application specific usage
+	  answer Y to arrange for the kernel to reserve it for
+	  direct-access (device-dax) by default. The memory range can
+	  later be optionally assigned to the page allocator by system
+	  administrator policy. Say N to have the kernel treat this
+	  memory as general purpose by default.
+
+	  If unsure, say Y.
+
 config SECCOMP
 	def_bool y
 	prompt "Enable seccomp to safely compute untrusted bytecode"
diff --git a/arch/x86/boot/compressed/eboot.c b/arch/x86/boot/compressed/eboot.c
index 544ac4fafd11..9b90fae21abe 100644
--- a/arch/x86/boot/compressed/eboot.c
+++ b/arch/x86/boot/compressed/eboot.c
@@ -560,7 +560,10 @@ setup_e820(struct boot_params *params, struct setup_data *e820ext, u32 e820ext_s
 		case EFI_BOOT_SERVICES_CODE:
 		case EFI_BOOT_SERVICES_DATA:
 		case EFI_CONVENTIONAL_MEMORY:
-			e820_type = E820_TYPE_RAM;
+			if (is_efi_special(d))
+				e820_type = E820_TYPE_SPECIAL;
+			else
+				e820_type = E820_TYPE_RAM;
 			break;
 
 		case EFI_ACPI_MEMORY_NVS:
diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index 2e53c056ba20..897e46eb9714 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -757,7 +757,7 @@ process_efi_entries(unsigned long minimum, unsigned long image_size)
 		 *
 		 * Only EFI_CONVENTIONAL_MEMORY is guaranteed to be free.
 		 */
-		if (md->type != EFI_CONVENTIONAL_MEMORY)
+		if (md->type != EFI_CONVENTIONAL_MEMORY || is_efi_special(md))
 			continue;
 
 		if (efi_mirror_found &&
diff --git a/arch/x86/include/asm/e820/types.h b/arch/x86/include/asm/e820/types.h
index c3aa4b5e49e2..0ab8abae2e8b 100644
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
+	E820_TYPE_SPECIAL	= 0xefffffff,
+
 	/*
 	 * Reserved RAM used by the kernel itself if
 	 * CONFIG_INTEL_TXT=y is enabled, memory of this type
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 2879e234e193..9f50dd0bbb04 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -176,6 +176,7 @@ static void __init e820_print_type(enum e820_type type)
 	switch (type) {
 	case E820_TYPE_RAM:		/* Fall through: */
 	case E820_TYPE_RESERVED_KERN:	pr_cont("usable");			break;
+	case E820_TYPE_SPECIAL:		/* Fall through: */
 	case E820_TYPE_RESERVED:	pr_cont("reserved");			break;
 	case E820_TYPE_ACPI:		pr_cont("ACPI data");			break;
 	case E820_TYPE_NVS:		pr_cont("ACPI NVS");			break;
@@ -1023,6 +1024,7 @@ static const char *__init e820_type_to_string(struct e820_entry *entry)
 	case E820_TYPE_UNUSABLE:	return "Unusable memory";
 	case E820_TYPE_PRAM:		return "Persistent Memory (legacy)";
 	case E820_TYPE_PMEM:		return "Persistent Memory";
+	case E820_TYPE_SPECIAL:		/* Fall-through: */
 	case E820_TYPE_RESERVED:	return "Reserved";
 	default:			return "Unknown E820 type";
 	}
@@ -1038,6 +1040,7 @@ static unsigned long __init e820_type_to_iomem_type(struct e820_entry *entry)
 	case E820_TYPE_UNUSABLE:	/* Fall-through: */
 	case E820_TYPE_PRAM:		/* Fall-through: */
 	case E820_TYPE_PMEM:		/* Fall-through: */
+	case E820_TYPE_SPECIAL:		/* Fall-through: */
 	case E820_TYPE_RESERVED:	/* Fall-through: */
 	default:			return IORESOURCE_MEM;
 	}
@@ -1050,6 +1053,7 @@ static unsigned long __init e820_type_to_iores_desc(struct e820_entry *entry)
 	case E820_TYPE_NVS:		return IORES_DESC_ACPI_NV_STORAGE;
 	case E820_TYPE_PMEM:		return IORES_DESC_PERSISTENT_MEMORY;
 	case E820_TYPE_PRAM:		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
+	case E820_TYPE_SPECIAL:		return IORES_DESC_APPLICATION_RESERVED;
 	case E820_TYPE_RESERVED_KERN:	/* Fall-through: */
 	case E820_TYPE_RAM:		/* Fall-through: */
 	case E820_TYPE_UNUSABLE:	/* Fall-through: */
@@ -1065,13 +1069,14 @@ static bool __init do_mark_busy(enum e820_type type, struct resource *res)
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
+	case E820_TYPE_SPECIAL:
 		return false;
 	case E820_TYPE_RESERVED_KERN:
 	case E820_TYPE_RAM:
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index e1cb01a22fa8..d227751f331b 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -139,7 +139,9 @@ static void __init do_add_efi_memmap(void)
 		case EFI_BOOT_SERVICES_CODE:
 		case EFI_BOOT_SERVICES_DATA:
 		case EFI_CONVENTIONAL_MEMORY:
-			if (md->attribute & EFI_MEMORY_WB)
+			if (is_efi_special(md))
+				e820_type = E820_TYPE_SPECIAL;
+			else if (md->attribute & EFI_MEMORY_WB)
 				e820_type = E820_TYPE_RAM;
 			else
 				e820_type = E820_TYPE_RESERVED;
@@ -753,6 +755,12 @@ static bool should_map_region(efi_memory_desc_t *md)
 	if (IS_ENABLED(CONFIG_X86_32))
 		return false;
 
+	/*
+	 * Special purpose memory is not mapped by default.
+	 */
+	if (is_efi_special(md))
+		return false;
+
 	/*
 	 * Map all of RAM so that we can access arguments in the 1:1
 	 * mapping when making EFI runtime calls.
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 54357a258b35..cecbc2bda1da 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -112,6 +112,7 @@ typedef	struct {
 #define EFI_MEMORY_MORE_RELIABLE \
 				((u64)0x0000000000010000ULL)	/* higher reliability */
 #define EFI_MEMORY_RO		((u64)0x0000000000020000ULL)	/* read-only */
+#define EFI_MEMORY_SP		((u64)0x0000000000040000ULL)	/* special purpose */
 #define EFI_MEMORY_RUNTIME	((u64)0x8000000000000000ULL)	/* range requires runtime mapping */
 #define EFI_MEMORY_DESCRIPTOR_VERSION	1
 
@@ -128,6 +129,19 @@ typedef struct {
 	u64 attribute;
 } efi_memory_desc_t;
 
+#ifdef CONFIG_EFI_SPECIAL_MEMORY
+static inline bool is_efi_special(efi_memory_desc_t *md)
+{
+	return md->type == EFI_CONVENTIONAL_MEMORY
+		&& (md->attribute & EFI_MEMORY_SP);
+}
+#else
+static inline bool is_efi_special(efi_memory_desc_t *md)
+{
+	return false;
+}
+#endif
+
 typedef struct {
 	efi_guid_t guid;
 	u32 headersize;
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

