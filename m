Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9CC2C282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9962E217D4
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 14:28:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="cd/kQGj0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9962E217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E69F8E0005; Tue, 22 Jan 2019 09:28:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 572788E0001; Tue, 22 Jan 2019 09:28:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C6598E0005; Tue, 22 Jan 2019 09:28:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D97188E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:28:53 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w12so12426621wru.20
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:28:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=Lvm2rwvLbDpB8+eMYK6LEC1hUfeGhdVz1cN6XKiIah16uc4IP2WqOO4nFSAqNbIWjw
         1yGAhcyfaPHKY36poo2Fefbvbz1Dxv9u5Xf4oKqYW3lyy+knx9jd13iePURzpFUgG7Us
         z/N7s2z0gOuGweopOF/OpW7aJ4Zv7wwo1W3UKWqC/QzhN5VZndIetVInhNfW3g6S9+1x
         BU8UtVmglARwPcLuq9j5pio39CHZx17btcVJtRBpi49xlqJSv0sY2rrk3dYAAdhNue+c
         xIesR5H3GxMwJEYmTjsZ56raxGAP5MSqqXU08+Jj7FW7cPl9W5elNc1Fd4d4AU3Yf6Wp
         FnXg==
X-Gm-Message-State: AJcUukf/vdwo5vObPam9FQhROv1RiGp1awalin5gQHT1h01uG9yDMLPW
	XPrW/M2EDXlRKaP2kjYu1nJQQokcBjR1XV+BPy9wbamdZAela9agXqip7RnpDAkY0UZkJmI+zC6
	bIxC6Q+gSJgGbblYyrxkRJFRxOUS/D5cncESp9fGpHouIUj6xdV7dAkybCD89IS0BCQ==
X-Received: by 2002:a5d:67cf:: with SMTP id n15mr32129228wrw.211.1548167333379;
        Tue, 22 Jan 2019 06:28:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN54nEDUYx04fhnam1DSUkCHHO3MBt4RpN4PwVzslXiRr8i/oL/byZa3kvAKof3R4tNdy0KE
X-Received: by 2002:a5d:67cf:: with SMTP id n15mr32129172wrw.211.1548167332332;
        Tue, 22 Jan 2019 06:28:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548167332; cv=none;
        d=google.com; s=arc-20160816;
        b=NBFLEYwNyh7DZC9KSt/qw6XbOJGiCGX17x/nY+h32eTNkM36+c7DEzHSX1OcHY+Ohj
         NlmnOjdPq2o0t+M7LD7rek3JCU7PYS90oLeltTneBBfZ3rdaZj6fsbBn0P5uItuZl9XR
         Auenj7hkc3YqbGHGZztv09JNLF1BcPDzVFV6QJjHCH/tX8/ZWGcJFBY+qMWZijcKrCdR
         dAYk/UKTs5Jr8bXkVL70Kapjwqzx7+aJ/y5Bp4TalLYGOMPJ510bMozmdaoZIq5+uM+C
         FBOrOaFDOSXbmhxvVR1gZ7kESC2+fE+SfL0fpcQ4FwnwA7RtMLDPSAcMEA6pK1WiaP3W
         f5pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=odsVGwstaPAq12uIo6doCZ95GW3cp3XK5/uNBBfKeBqvCNvLAISMEWgqaWJVnaKE7Q
         G3oF4Mi/TVT+LUfsjuGV4su82KE+7GqtFt6u/+tbsTf1RtXh0nK5RimScekXdJOW+oo/
         oX7MYf7OJ4U9m4VSCMiT2uou2uCP6s+ujH/ARTEEfRvv89RnUlR/o0p7GUDfiuNvXa1X
         hnouz2TVr3kNYPBEhkNMAFZ+Ck0PV+xtFhzafbtr53IILKvPJuXRsI4L5fFsroITM2WE
         yYJQ8VJLb/ijK7xBhBliSafzSMb5FckNgf7XiVA5gGx47xZ8Qx+IKDyA71jDyOeg4xpq
         PHGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="cd/kQGj0";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q6si38451593wma.72.2019.01.22.06.28.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 06:28:52 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="cd/kQGj0";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43kW4f2xs7z9txr6;
	Tue, 22 Jan 2019 15:28:50 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=cd/kQGj0; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id WKb52jQ-cS70; Tue, 22 Jan 2019 15:28:50 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43kW4f1Ytsz9txqk;
	Tue, 22 Jan 2019 15:28:50 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1548167330; bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=cd/kQGj01O5x21Nxyh7nw+C5H6U3PzO3onwCFflpAoheUflGWni6sLi7jGItCHtMY
	 TMHo5znKpnjwZMrHQEOzpt5S55W0TZy1F8dmvfe5gNXMqsqzpPIa1pXWmIaJU87a3q
	 yYar88SFf6GWzZpWntZp/8uAjP7xz12KPjX0W+yU=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 73EA68B7E9;
	Tue, 22 Jan 2019 15:28:51 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id HKsT0I6a6L_u; Tue, 22 Jan 2019 15:28:51 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2F6E78B7CE;
	Tue, 22 Jan 2019 15:28:51 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5B239717D8; Tue, 22 Jan 2019 14:28:44 +0000 (UTC)
Message-Id:
 <19df7bcebff432dd843b4da670121f69459ace9e.1548166824.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1548166824.git.christophe.leroy@c-s.fr>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v4 2/3] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 22 Jan 2019 14:28:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190122142844.b0ouPFZTg0QcN0ee2fc1mZpVb3df2eemEzSve390Jwo@z>

In preparation of KASAN, move early_init() into a separate
file in order to allow deactivation of KASAN for that function.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile   |  2 +-
 arch/powerpc/kernel/early_32.c | 35 +++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 26 --------------------------
 3 files changed, 36 insertions(+), 27 deletions(-)
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
index 000000000000..b3e40d6d651c
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,35 @@
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

