Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C20566B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:47:53 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id q107so8087450qgd.1
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:47:53 -0800 (PST)
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
        by mx.google.com with ESMTPS id j34si11345265qgj.152.2014.02.18.15.47.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 15:47:53 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id e16so27027792qcx.10
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:47:53 -0800 (PST)
Date: Tue, 18 Feb 2014 18:47:50 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
In-Reply-To: <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
Message-ID: <alpine.LFD.2.11.1402181755031.17677@knanqh.ubzr>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Tue, 18 Feb 2014, Laura Abbott wrote:

> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
> 
> Acked-by: Jason Cooper <jason@lakedaemon.net>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Acked-by: Kukjin Kim <kgene.kim@samsung.com>
> Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Reviewed-by: Nicolas Pitre <nico@linaro.org>

A small comments below.

> diff --git a/arch/arm/include/asm/setup.h b/arch/arm/include/asm/setup.h
> index 8d6a089..0196091 100644
> --- a/arch/arm/include/asm/setup.h
> +++ b/arch/arm/include/asm/setup.h
> @@ -26,29 +26,6 @@ static const struct tagtable __tagtable_##fn __tag = { tag, fn }
>   */
>  #define NR_BANKS	CONFIG_ARM_NR_BANKS

This may go as well now.  Please consider this patch as well for your 
series:

Subject: [PATCH] arm: Get rid of NR_BANKS

This constant is no longer used, except in the atag_to_fdt compatibility
layer where a local definition is now provided.  This could be removed
entirely i.e. having no limits but this is probably not worth it.

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index e254198177..1ca42ed304 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1090,11 +1090,6 @@ source "arch/arm/firmware/Kconfig"
 
 source arch/arm/mm/Kconfig
 
-config ARM_NR_BANKS
-	int
-	default 16 if ARCH_EP93XX
-	default 8
-
 config IWMMXT
 	bool "Enable iWMMXt support" if !CPU_PJ4
 	depends on CPU_XSCALE || CPU_XSC3 || CPU_MOHAWK || CPU_PJ4
diff --git a/arch/arm/boot/compressed/atags_to_fdt.c b/arch/arm/boot/compressed/atags_to_fdt.c
index d1153c8a76..9448aa0c66 100644
--- a/arch/arm/boot/compressed/atags_to_fdt.c
+++ b/arch/arm/boot/compressed/atags_to_fdt.c
@@ -7,6 +7,8 @@
 #define do_extend_cmdline 0
 #endif
 
+#define NR_BANKS 16
+
 static int node_offset(void *fdt, const char *node_path)
 {
 	int offset = fdt_path_offset(fdt, node_path);
diff --git a/arch/arm/include/asm/setup.h b/arch/arm/include/asm/setup.h
index 01960916dd..e0adb9f1bf 100644
--- a/arch/arm/include/asm/setup.h
+++ b/arch/arm/include/asm/setup.h
@@ -21,11 +21,6 @@
 #define __tagtable(tag, fn) \
 static const struct tagtable __tagtable_##fn __tag = { tag, fn }
 
-/*
- * Memory map description
- */
-#define NR_BANKS	CONFIG_ARM_NR_BANKS
-
 extern int arm_add_memory(u64 start, u64 size);
 extern void early_print(const char *str, ...);
 extern void dump_machine_table(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
