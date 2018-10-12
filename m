Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 979F76B026B
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:10:09 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c16-v6so8104242wrr.8
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:10:09 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id z6-v6si1389005wrr.456.2018.10.12.11.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 11:10:08 -0700 (PDT)
Date: Fri, 12 Oct 2018 20:10:01 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 05/18] ACPI / APEI: Make estatus queue a Kconfig symbol
Message-ID: <20181012181001.GF12328@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-6-james.morse@arm.com>
 <20181001175956.GF7269@zn.tnic>
 <a562d7c4-2e74-3a18-7fb0-ba8f40d2dce4@arm.com>
 <20181004173416.GC5149@zn.tnic>
 <52228145-f024-0ee1-01c7-da92023d53cc@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <52228145-f024-0ee1-01c7-da92023d53cc@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Oct 12, 2018 at 06:17:48PM +0100, James Morse wrote:
> Ripping out the existing #ifdefs and replacing them with IS_ENABLED() would let
> the compiler work out the estatus stuff is unused, and saves us describing the
> what-uses-it logic in Kconfig.
> 
> But this does expose the x86 nmi stuff on arm64, which doesn't build today.

Gah, that ifdeffery is one big mess. ;-\

One fine day...

> Dragging NMI_HANDLED and friends up to the 'linux' header causes a fair amount
> of noise under arch/x86 (include the new header in 22 files). Adding dummy
> declarations to arm64 fixes this, and doesn't affect the other architectures
> that have an asm/nmi.h
> 
> Alternatively we could leave {un,}register_nmi_handler() under
> CONFIG_HAVE_ACPI_APEI_NMI. I think we need to keep the NOTIFY_NMI kconfig symbol
> around, as its one of the two I can't work out how to fix without the TLBI-IPI.

Hmm, so I just tried the diff below with my arm64 cross compiler and a
defconfig with

CONFIG_ACPI_APEI_GHES=y
CONFIG_EDAC_GHES=y

and it did build fine. What am I missing?

---
diff --git a/drivers/acpi/apei/Kconfig b/drivers/acpi/apei/Kconfig
index 2b191e09b647..52ae5438edeb 100644
--- a/drivers/acpi/apei/Kconfig
+++ b/drivers/acpi/apei/Kconfig
@@ -4,7 +4,6 @@ config HAVE_ACPI_APEI
 
 config HAVE_ACPI_APEI_NMI
 	bool
-	select ACPI_APEI_GHES_ESTATUS_QUEUE
 
 config ACPI_APEI
 	bool "ACPI Platform Error Interface (APEI)"
@@ -34,10 +33,6 @@ config ACPI_APEI_GHES
 	  by firmware to produce more valuable hardware error
 	  information for Linux.
 
-config ACPI_APEI_GHES_ESTATUS_QUEUE
-	bool
-	depends on ACPI_APEI_GHES && ARCH_HAVE_NMI_SAFE_CMPXCHG
-
 config ACPI_APEI_PCIEAER
 	bool "APEI PCIe AER logging/recovering support"
 	depends on ACPI_APEI && PCIEAER
@@ -48,7 +43,6 @@ config ACPI_APEI_PCIEAER
 config ACPI_APEI_SEA
 	bool "APEI Synchronous External Abort logging/recovering support"
 	depends on ARM64 && ACPI_APEI_GHES
-	select ACPI_APEI_GHES_ESTATUS_QUEUE
 	default y
 	help
 	  This option should be enabled if the system supports
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 463c8e6d1bb5..8191d711564b 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -683,7 +683,6 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
-#ifdef CONFIG_ACPI_APEI_GHES_ESTATUS_QUEUE
 /*
  * Handlers for CPER records may not be NMI safe. For example,
  * memory_failure_queue() takes spinlocks and calls schedule_work_on().
@@ -862,10 +861,6 @@ static void ghes_nmi_init_cxt(void)
 	init_irq_work(&ghes_proc_irq_work, ghes_proc_in_irq);
 }
 
-#else
-static inline void ghes_nmi_init_cxt(void) { }
-#endif /* CONFIG_ACPI_APEI_GHES_ESTATUS_QUEUE */
-
 static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
 {
 	int rc;


-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
