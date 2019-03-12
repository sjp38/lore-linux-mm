Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AF7FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DED49213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Y8gsJdMA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DED49213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 504988E0005; Tue, 12 Mar 2019 18:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48ADD8E0003; Tue, 12 Mar 2019 18:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3055F8E0005; Tue, 12 Mar 2019 18:16:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7FF88E0003
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:10 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h79so1034281wme.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
        b=cp1s1lcJf8yPz0cgkimg6MiUxnDSOvCtACmua/HM3dyTeUWbBsh47z1e6Xfvx2oBtK
         RR2SaVoR6/sGuZmpD/prjoYOHweXJKAKUUB39F5pDjoVB6KCNWUIVjqo3GTglvR3gaIa
         Y3slVisuza3YYcG7M0RelUf2Np/FyBn1TxtYkjtWPhuCYs1Z+1Alm8OftEmqB3bcnWAY
         Pl2jhz0atvUmd+XkkTUNDojy9Ca4ir2fHxpxOQQQh8laaw3kjXByJ/9tH1tNJMymlxqL
         0XW5i6hTICcmyVmphpcEAqkS6wKM2z8n6xjFo/nPJx/27M6qDhwcdAGxQ3xEtC4cx46T
         RFpQ==
X-Gm-Message-State: APjAAAVM8dYv4hq0GKdqs2Ksow1I0cgR6rRilg0vWG+cYYfMJetSGYjD
	VtDoUOOz8lTvkgDInxuq2PF2UTNjpjtG15Nvx952YQm7DKrg7wKazND28pSxBb9/lO3koDnwUkb
	sqoFzC6Y7eqS9BPuyHNMbNGk7wC9guTUXp2JPFBlvp9f6YYhT6txMndYfHh79X7z44Q==
X-Received: by 2002:adf:ed48:: with SMTP id u8mr18465249wro.185.1552428970035;
        Tue, 12 Mar 2019 15:16:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJ+ETr32BKNwHls4oFEFvvN4mz2/JIxiniGQcKuSpHk0HlN53UVxByUCcewhml8dxtvYZS
X-Received: by 2002:adf:ed48:: with SMTP id u8mr18465211wro.185.1552428968760;
        Tue, 12 Mar 2019 15:16:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428968; cv=none;
        d=google.com; s=arc-20160816;
        b=xR7KuLn8bpi86k5AxhQbKtob5GIXl0vlBKzRAudT5ejEUt8hUjFuoBg782q4iFi2at
         863G9DTtSZ+kQWWnQc4Cu/mIKjWaHJcdOl7RK/LhdPxhmLQo77vKXN0VLPHnIfWATo3f
         3zPr6IjpZfQYAZfXgfejF95JRDT+vsjdj7xnU4YVxPfoyzX01ACfwlckBCGdLqGtsscN
         9QWknmAux7Pch3bVh5qEsUp0Aj4wgywjxFr3Ai3rXdZsISimP0zSL+ckQUj4KSWHbW1x
         FWjBjy0OeklFq0CddmnBMQYeAw0+17Mlc8LKTyto7uEr9uytBQ4lXCXT37jLOGoOfPn5
         t4rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
        b=rR4hj3p1sdreP+g1CIUm2BJWByisHy4ZAsGf8emRH/LMCc1FUG157k+6WBlVM+Ps8s
         /uRrqKjX3tbaH4hVwgOJtfo3iurOfIqeiuCAaWbIVm+rsGkP6YIDnnhSc8aN6qEd6gD6
         js9FU6KfI/g300+xqpwYmab2iRtczdTfWt99Y0YvzJZAKExHbB+98y1PpBH3IXeAz0JD
         DEZsdSULk+xu1NY181vOoAX2DCzndRYabSTnbcuO3n+B0DOagWcdTqRE6rdFUhESwjOo
         xQhWWZ58lGlB3k8MkK9JgS7LCN7G7PQYYyhlICHdahPJmBtQEuQgoLXzkbwceI38FXOx
         w1LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Y8gsJdMA;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 4si13815wma.133.2019.03.12.15.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=Y8gsJdMA;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7D0GS6z9vRb5;
	Tue, 12 Mar 2019 23:16:08 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Y8gsJdMA; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id eMIA2_JKQpuj; Tue, 12 Mar 2019 23:16:07 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7C69p1z9vRb0;
	Tue, 12 Mar 2019 23:16:07 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428967; bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Y8gsJdMA5GXDZeMcgNgsR7alt/mVnPZ6JaVQyWb/hBAIiQ4/3bPBWZRORtN/JZR2g
	 6P0VwAKSHk0QsYNOc6mnJvYkRLLZDteEi4U6qhdwfqZcC4yiuqdDUHWoVXDnFzNiSx
	 pukj6CB1uVQSRYGUT8arvUIT0A3t1i4KQe0A0HIE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 153158B8B1;
	Tue, 12 Mar 2019 23:16:08 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 6NxrO2II63pO; Tue, 12 Mar 2019 23:16:07 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CD5D58B8A7;
	Tue, 12 Mar 2019 23:16:07 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id A73A96FA15; Tue, 12 Mar 2019 22:16:07 +0000 (UTC)
Message-Id: <3c64608cacd6706fc026575bdaf4f24a20ad1fc7.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 02/18] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:07 +0000 (UTC)
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
index 4a65e08a6042..3fb9f64f88fd 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -64,34 +64,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
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

