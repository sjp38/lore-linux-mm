Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95889C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 497C020842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 13:48:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="obBI6q3m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 497C020842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 192878E000C; Mon, 25 Feb 2019 08:48:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11D558E0012; Mon, 25 Feb 2019 08:48:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00B438E000C; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E42E8E0012
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:48:38 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f202so1266945wme.2
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 05:48:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=XoNu5UKdQv6Oj1+txTayOhAazQZhJqCtOSMVXLNcft8=;
        b=eRQZkDGcW7mfZNf4an3bDS4wTIx8jtRCYSklQtJgHwNaSSJRy70EHE324+RLtfu4vF
         yqtVp90SxjlYrynnmUU+taisAli61qWKr2gkdiHbXSTuB1uPzQd51fS1snOOy9w2TJWS
         Uzj7Ss+lw27atXL/4tXj0fuMzFdxvGuOSoiZ1MLs2XkY1d0HZisuHnCXQ0XR8H6UsXAD
         QJFD30L/VYjKYsKOXSMXeydE0PUUlc7O9mwW3slxxBq1fMt36xzemoYrygvfS6vNgXur
         UZ2bJBddq+dWjWuiFUHYp7LLH7jekMJlHX8ZQi849dxlHVHC32oW3mOvAoEkGAH/H/Wj
         NIHw==
X-Gm-Message-State: AHQUAua3E7jPXMZVEqYStBrfU5VTM+be6VCyRdogC05dbuCmTnu3xC4k
	9vp2yJdzDjBWyuUpeRf5RXC4cAHJM5OLAaKadogr0LamJoSjh4R+7RJpxNWnjqjme/Rd9V4mnIY
	usf1q6hhTvQDoGmAlB+pUiM6mIzdxw957zVHxkR8pLN1/9cFcaVEMhXDpvEPoyQOVAA==
X-Received: by 2002:adf:81a1:: with SMTP id 30mr2549810wra.285.1551102518106;
        Mon, 25 Feb 2019 05:48:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZARJg5PCE3SznFmieRcP8Xy4uXXCn6Mbl7mQ6aWL+YcU0Ms3NrGhd365bwiAveVhOLMwcl
X-Received: by 2002:adf:81a1:: with SMTP id 30mr2549764wra.285.1551102517073;
        Mon, 25 Feb 2019 05:48:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551102517; cv=none;
        d=google.com; s=arc-20160816;
        b=eSAHmJRcANcrTITyX7UrhVfl1EZtUinmHq5Ai5J05x61a3MD8eW2sw+DA7U/9lBaRc
         oxZUF2NpDYZUA4RCg/1s+QoZ2sMsLjuyVvVX1b3i+1tubelViIbL3IracUQDd0XNerrx
         DamjuwfvnG/TGz9sSg3/cylXZrG0KPLeDJH5stkcePo7RP2qUIqaX9sYs78pSrAZr8ww
         OlQxi5iqFErr5vxhZkE/nQ/RWPSLq7H//YYOHNgXhOz6dWuBznW0X0csRDu2ejTqz0Fx
         FOuYzba69dEbe5IEknRwNWIn4EYHtQS1kGJLaQY4Z1G0dB7VUkddGSgPdnb/rorgjn1n
         Qadg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=XoNu5UKdQv6Oj1+txTayOhAazQZhJqCtOSMVXLNcft8=;
        b=roLHiNhO7XZ6djCVdTXgFKvcdg785xI/BUkv/VVnk9aGr1/CUbjD/e3W+pXsLh0I/B
         xKyVzvxhgFXkKD3PLY98Sfn8ch1yXyAGKdn18QvQzUqgjxXlu1IjoNvWRO5KntmigEF4
         bAP0ZEFEFMol3l2Pt0XlEg7YnU0QcKC7VuYGnYI29F798jhw7lVLCVfFx7Nq1Bm+S654
         +HnuQGhaBDhkUdVVvvM38M3t7gENBkKrJqnZMz9YTcVm0fEOj51hYEQzzyJw77xmhl+u
         pyw8gYhqszGLyYz7WFJUAJl9XY1fgf9T6CwqfR37Z4cacI+qtXdu7qSgIcT9SJ2MxBM6
         uSRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=obBI6q3m;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id o3si6279894wrm.298.2019.02.25.05.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 05:48:37 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=obBI6q3m;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 447NZR4vl2zB09Zq;
	Mon, 25 Feb 2019 14:48:31 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=obBI6q3m; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id LA2tJU5tYAhl; Mon, 25 Feb 2019 14:48:31 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 447NZR3fQhzB09Zn;
	Mon, 25 Feb 2019 14:48:31 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551102511; bh=XoNu5UKdQv6Oj1+txTayOhAazQZhJqCtOSMVXLNcft8=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=obBI6q3mX7+YpW9Y1c9Gl/ovw23rGdr62p/kAFWaA37NLWH+t9POXaLmL2e6rJnKx
	 qM3DYP2B/GrpF4gFyVfNANCC2a7gtchgtRhRjYVB/mkKH513liSWVG0+mu8gyEPqSp
	 O/8yt7UhWdVeWXNBIzqrN1Dxn2aPnrK3uGcZK9uA=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D1AA78B844;
	Mon, 25 Feb 2019 14:48:35 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id ArQiIcXbIiqH; Mon, 25 Feb 2019 14:48:35 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A205B8B81D;
	Mon, 25 Feb 2019 14:48:35 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 428856F20E; Mon, 25 Feb 2019 13:48:36 +0000 (UTC)
Message-Id: <da8d44e35b0bf638ac537fbbcefc286d9f793794.1551098214.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v7 01/11] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Mon, 25 Feb 2019 13:48:36 +0000 (UTC)
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
 arch/powerpc/kernel/early_32.c | 38 ++++++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 28 ----------------------------
 3 files changed, 39 insertions(+), 29 deletions(-)
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
index 000000000000..99a3d82588e7
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,38 @@
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
+	/* First zero the BSS -- use memset_io, some platforms don't have
+	 * caches on yet */
+	memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
+			__bss_stop - __bss_start);
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

