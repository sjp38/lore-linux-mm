Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8545C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DE7F2083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="eeyCfSIW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DE7F2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CA898E0005; Tue, 19 Feb 2019 12:23:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1EB8E0002; Tue, 19 Feb 2019 12:23:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734CB8E0005; Tue, 19 Feb 2019 12:23:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1673D8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:23:13 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f4so9239292wrj.11
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:23:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=31DOHOTY8TAFQbUw3ju2ZitoNlqS/Q9KBZdABQSjtuY=;
        b=DqqHfWEaoID6t5sICO1szqeo2LWSqrtx0wty6fgN68vuhJEGnEN82RLql8a637D9OX
         1kvhA3eN2CvT8DGcWP7MaQoVvESlwqZeS2GSxugsKdk1lHBftH4lICOjAvKjADSXSBbb
         xs8iynJ/8saNNmoA6guilOD07rZo02eHRATfiq/4k+UAlfVFOGO8NgQwehp8ifuLNGU+
         G16L+PWImVBCc9QnmdGd4lmdn2tGx6j7FWybwTM8iF0XcE1s5C6F/ODnMgME7B3QtjXn
         2IEt/vqAPP1MhZsv33wuY1TyKESBaRBw3IuAh7LzmeP8xs9ZWMnr9Be4qiMycA8jpVEr
         +CCA==
X-Gm-Message-State: AHQUAuZK1ZaMor5naeUZlXh6Yqm8I53krt9WWsO+kHFpKxOjAC53UfBC
	Au7rUpHrJonc1jTX4h6wcVqHMKL0Qq9OfaZK7fJ7ezKTYcCcl/iqPtXk6USZ0HwUjN8mK7Qbatq
	4Ij+80/IxUk9QrTuS3vDABFx2HGSfa1ka5fKfxxb/hB+hKT8QaZ1G9wPFPW5m9a42Vg==
X-Received: by 2002:a1c:f509:: with SMTP id t9mr3826372wmh.76.1550596992598;
        Tue, 19 Feb 2019 09:23:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBlNtOKdWMGXwXLENxRPlJt0uuL4DPNYbmW6UzR+1RvAiXUEHJrJfAY+VYwyUhph6qZXzD
X-Received: by 2002:a1c:f509:: with SMTP id t9mr3826315wmh.76.1550596991430;
        Tue, 19 Feb 2019 09:23:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550596991; cv=none;
        d=google.com; s=arc-20160816;
        b=wC9t19wkbIF2cr8e8A0eU8T55mKJD/uwkHR2X5/qIuSklepmc2A8lD0/JHye/aBnzt
         vfcKt9idG/zLErDXmE5NMQ1VbZBVoNjkeYyBNR8uHqAWgSXuDW/sVFbj8nSAu6O2T9mA
         UQr3hZ/cNQ/OMmI6BcYRW1ZwYRZTOrIlomKDG9sfFPHOfiPXqUZe8E5RtubKqMA4e/xX
         YDuQYkIOk3gcCotTBXvKZ1s5L9aO6LtGO8NQrOyiM7VVKMMvqb20QLo6BgNYq8LUJa8N
         xl2z9HXaKxYxdq8T5k1a2aJHTHAEPZzUP8G9m5fvEvMA1slWE/MZ1aOYe6E0ggCfocA5
         63wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=31DOHOTY8TAFQbUw3ju2ZitoNlqS/Q9KBZdABQSjtuY=;
        b=aGxdrfenWhZas665JQsfL977dZx/KJ0i2w2I5JleboqBV5ZaYpbHZ/GPMw1XoTjSzq
         2r50oXOHjhBeI2co74w0b9hOZzHyDo0kPoqpAP3EV9zJu/c4TbSASNkd3/tTC/HBCl1h
         zsjeYKj76krCZXsazuAZW5Gx5ZYRpKFKtkr2NlQzZZNSnauH9zi4pFB/yjtcJeElVjVR
         /k73BdcbjvbkGhu7Ly+8ysHn61RYaK/EsVn67VGJJPIzG6CT/bniUIhvbUhoULl8tjQu
         iL04YX6EHbRnwyBXX/MO2NQJGL6gKEsQVoHiPkFIYMF2CBwWFhVssE8DQqbexXAwpFeF
         Q9uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=eeyCfSIW;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr ([93.17.236.30])
        by mx.google.com with ESMTPS id y7si1219323wrr.182.2019.02.19.09.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:23:11 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=eeyCfSIW;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443ncs1wXHz9v4wj;
	Tue, 19 Feb 2019 18:23:09 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=eeyCfSIW; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id NCfK9Cf0tjfn; Tue, 19 Feb 2019 18:23:09 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443ncs0h5Hz9v4wf;
	Tue, 19 Feb 2019 18:23:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550596989; bh=31DOHOTY8TAFQbUw3ju2ZitoNlqS/Q9KBZdABQSjtuY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=eeyCfSIWTvudaQye+j75JBejWpowCePo06pzvNaHZE9zrJtNT9Gp6pp9Bg7hxckIM
	 19cNQByqbDCTRfrxe+fkaVAQhxyp/aVaNfrs+uJNv9w6+2BeHUdZCV7GSVzTV9IYYH
	 rZShjWWGuxczfMabwwXpSORweBAJD4gbz78QHC9o=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B49B28B7FE;
	Tue, 19 Feb 2019 18:23:10 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id PNPdzjkKRflZ; Tue, 19 Feb 2019 18:23:10 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 757D98B7F9;
	Tue, 19 Feb 2019 18:23:10 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5C83E6E81D; Tue, 19 Feb 2019 17:23:10 +0000 (UTC)
Message-Id: <d115246239e400a98cc2cd78701984886a85277c.1550596242.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1550596242.git.christophe.leroy@c-s.fr>
References: <cover.1550596242.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v6 2/6] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 19 Feb 2019 17:23:10 +0000 (UTC)
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
 arch/powerpc/kernel/setup_32.c | 26 --------------------------
 3 files changed, 37 insertions(+), 27 deletions(-)
 create mode 100644 arch/powerpc/kernel/early_32.c

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index cb7f0bb9ee71..879b36602748 100644
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
index 000000000000..3482118ffe76
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
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
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
index 5e761eb16a6d..b46a9a33225b 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -63,32 +63,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
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
-	/* First zero the BSS */
-	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
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

