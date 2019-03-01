Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96C55C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5748120850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="UoyezeC4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5748120850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907C38E0004; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8708F8E0001; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AB888E0004; Fri,  1 Mar 2019 07:33:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id F33A68E0003
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:41 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f21so2478747wmb.5
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
        b=uOm44ZPpB9rn8G8GtWahqqVEz6QNSs5qK6hT9eVLhMJz8ocWCHDFJiNcWfv2BBe0Gh
         kjB9NILBG8U3CDgiFYRvQhkCdmTwSM0bNDMDzOpmab2xGuyKN/S3FXpRPenHa10gHD0C
         roeo46ht/g39/ZURe/W13mxo26Dyg2V8YRnrM+c1Z8P6P5iFlPNydZ/ADVUO6QChnPIZ
         jz5DxUdsA5zOZ/kVezMnp72t9fqpHFs2K0K1NeX5JxnYWONnSnf/ZBDalO7Vb6VJ/Kfx
         TJklVmzDAkbumS6ZcKUQ2QImf02R7SYozpfzEl/g/2WzxjyxXUrcV/EmDGlQ5Yp7rxrk
         LDOA==
X-Gm-Message-State: APjAAAUjPrwgiod6JxeB4I1IEy/m9DER+8ZyofJCfdBCmUteC9v9CEeD
	bk1pYRXMRGPceBmHQ5AjQVFIUWv+s93Jkg0HlI3JkxCpmLt9rAaRB4krS8uC9lK0erfzUF39PWK
	JEzC1ugV+MznP47LBtsmxM5Dma/HD1cb5aUY+CSTewMr8SVJOlUYy8pvxl3acrsgbeA==
X-Received: by 2002:adf:dd8a:: with SMTP id x10mr3438747wrl.117.1551443621393;
        Fri, 01 Mar 2019 04:33:41 -0800 (PST)
X-Google-Smtp-Source: APXvYqytjqQbe3S1xxLTJSBEdcFq9YSpr98wTnF1ukWFOAQAOBPzZqhfvUyG+t4QxIrWFhq9eKq+
X-Received: by 2002:adf:dd8a:: with SMTP id x10mr3438682wrl.117.1551443620316;
        Fri, 01 Mar 2019 04:33:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443620; cv=none;
        d=google.com; s=arc-20160816;
        b=ha9MqPe6bocmOCcGMTcHmMGxWBU3rA5y/dVHFRIDD3ykW18HwZ0R8N3g7CPE84TG4K
         vSd11Nl2oKk8zd/AdpS0LoLqw9OBQQmx+AhGEzTe8fF9aycWcaD9CA/04OPK4/akY+NI
         eqraRGXELA8iJgCARDJLceQUXwJfti2lzto92rE7Tb1r8xJpx/z+tWS2nwmSjhvYwuoX
         X0WhOj7ltM8WBLk3De6kMy2dQxsJLGAnBMRyxUJFayc5l0V2H/LJUL8rKr80fYvZmhIe
         0ipwfYOI0Hk1mEEwQnm2NKlQbFmPUbDkTzYUUkR9/K6liwbSsugTigw6hoxzwl43uoeP
         qTIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
        b=ewStUKkF5DwT4ePTWDe+N2evmWE93Yr6Ie53iyQk2rES00ocnWnuw2r+rLGejBOI9c
         /KSKEifHNHBue6kmGoBA8C4zKXwz8AGPzUlFiyD3U5+AOqBkyZA4Vy2Bt9yAKMypA3X7
         DP0s8GNZ1Zqb46HQ6WUjXaqC2uckL/n12n0n+89CzVKE5/vF9mMD0ZYxYe2g36/7jCLX
         Zha4mAeS4Qfp9sf14++McrsCYPr33jOAEQbRRs7WOte8mf8WLj86hn6F20nm0ptErRfI
         pU1HFPMPVvUltmJs4y9K91lD5w8K5+NIY9gO3weBlk+aSaO3EX3MbPrTy8YZ3m+3Bx/S
         SwnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UoyezeC4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id e7si13601877wro.168.2019.03.01.04.33.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:40 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=UoyezeC4;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkB3nFkz9txrl;
	Fri,  1 Mar 2019 13:33:38 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=UoyezeC4; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id GNQHZWQb3DZC; Fri,  1 Mar 2019 13:33:38 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkB2hDpz9txrh;
	Fri,  1 Mar 2019 13:33:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443618; bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=UoyezeC4Nkg7VNVUYh7Ecn5ckHsefqvJAUs3xCw146U5PqPKaDlTS59zIUgSE74nd
	 mM09balArJe9Macn9bay6HhE5CG2VwysPNRCyFygJT6NVD+Dv1XLXp26aeec9PFgI2
	 vTxVCKUy6xAMy0YeKfQz4/00GNHF3vRzfxW1qoUA=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A72678BB8B;
	Fri,  1 Mar 2019 13:33:39 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id bwV5OrdEw_e1; Fri,  1 Mar 2019 13:33:39 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 403AA8BB73;
	Fri,  1 Mar 2019 13:33:39 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 24B736F89E; Fri,  1 Mar 2019 12:33:39 +0000 (UTC)
Message-Id: <eafeb41d203b3a18c900eb7f2ed332745125d591.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 01/11] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation of KASAN, move early_init() into a separate
file in order to allow deactivation of KASAN for that function.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile   |  2 +-
 arch/powerpc/kernel/early_32.c | 36 ++++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 28 ----------------------------
 3 files changed, 37 insertions(+), 29 deletions(-)
 create mode 100644 arch/powerpc/kernel/early_32.c

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index cddadccf551d..45e47752b692 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -93,7 +93,7 @@ extra-y				+= vmlinux.lds
 
 obj-$(CONFIG_RELOCATABLE)	+= reloc_$(BITS).o
 
-obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o
+obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o early_32.o
 obj-$(CONFIG_PPC64)		+= dma-iommu.o iommu.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_BOOTX_TEXT)	+= btext.o
diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
new file mode 100644
index 000000000000..cf3cdd81dc47
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,36 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Early init before relocation
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <asm/setup.h>
+#include <asm/sections.h>
+#include <asm/asm-prototypes.h>
+
+/*
+ * We're called here very early in the boot.
+ *
+ * Note that the kernel may be running at an address which is different
+ * from the address that it was linked at, so we must use RELOC/PTRRELOC
+ * to access static data (including strings).  -- paulus
+ */
+notrace unsigned long __init early_init(unsigned long dt_ptr)
+{
+	unsigned long offset = reloc_offset();
+
+	/* First zero the BSS -- use memset_io, some platforms don't have caches on yet */
+	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+
+	/*
+	 * Identify the CPU type and fix up code sections
+	 * that depend on which cpu we have.
+	 */
+	identify_cpu(offset, mfspr(SPRN_PVR));
+
+	apply_feature_fixups();
+
+	return KERNELBASE + offset;
+}
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 1f0b7629c1a6..3f0d51b4b2f5 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -63,34 +63,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
 EXPORT_SYMBOL(DMA_MODE_WRITE);
 
 /*
- * We're called here very early in the boot.
- *
- * Note that the kernel may be running at an address which is different
- * from the address that it was linked at, so we must use RELOC/PTRRELOC
- * to access static data (including strings).  -- paulus
- */
-notrace unsigned long __init early_init(unsigned long dt_ptr)
-{
-	unsigned long offset = reloc_offset();
-
-	/* First zero the BSS -- use memset_io, some platforms don't have
-	 * caches on yet */
-	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
-			__bss_stop - __bss_start);
-
-	/*
-	 * Identify the CPU type and fix up code sections
-	 * that depend on which cpu we have.
-	 */
-	identify_cpu(offset, mfspr(SPRN_PVR));
-
-	apply_feature_fixups();
-
-	return KERNELBASE + offset;
-}
-
-
-/*
  * This is run before start_kernel(), the kernel has been relocated
  * and we are running with enough of the MMU enabled to have our
  * proper kernel virtual addresses
-- 
2.13.3

