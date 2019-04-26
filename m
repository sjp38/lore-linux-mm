Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C66AC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3243206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="mWZhJNl5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3243206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 644FB6B0003; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A1E26B000A; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 372FF6B0006; Fri, 26 Apr 2019 12:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA04E6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:27 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r7so3871865wrc.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
        b=CThEU/820AKa35QkQW8cUIsIqtrhlrNPg2oJcms8HqXqTpk5Sk66V1y5c/4qNS/W45
         ygbGYYeTxXxV7N2VYDG7EktL6GGZ64RSZ5cE6bTStNw5rCUhMgGD7MwE66/LZv7GTc6z
         1xyBmGnP67ovc2UCc5Kl8w8toncZhMjSEU6Qj47Ccr9wuiuKj8F7J25U1kaoMC9f4zqH
         7urEc9SOUQChz2Gq+f7eboFGwBzKRSv8t3qdRfR8u7hpjzjoOhoPDdTJA9ruB3BoxeXk
         g+q1JzURPheIYoTTByt3zCUk9PmW5EyNkQyvGFnC7B3vpw6U/wBBOkarSHyUH1/ziAI+
         K5Qw==
X-Gm-Message-State: APjAAAWxdZXiPVZWWGteByIqLjHuHHgBym0qzORc5bYu/s7tT0DbtO0k
	95JonWBxMVdYCrdOgI3B7ZbUbfYefY6RFrfRshoAN4NaSxwK8tz5vJ0lYC92HikyKMKte0aHnU+
	FyHHWvRtTU07OXXaf4X7f3ur+TdJhfGttd+gH+o6Ei8OFZXyZwjBJtG3qrPmMXphcYA==
X-Received: by 2002:a1c:9950:: with SMTP id b77mr7695935wme.133.1556295807211;
        Fri, 26 Apr 2019 09:23:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsqltkkL+JM/DeUGHI83IIuMwQRVaIidOK9FDYiI3bCRSX9BSbOvIgbEf+SjWsgVgTqTex
X-Received: by 2002:a1c:9950:: with SMTP id b77mr7695881wme.133.1556295806150;
        Fri, 26 Apr 2019 09:23:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295806; cv=none;
        d=google.com; s=arc-20160816;
        b=ocjfiEAoY39P0cNYyhiaI6Q7FZpGkoNZj+sggwLpl94SkJNscdWlFypIFlRH0aJsVo
         DQ8YLvHIXDjW/brCU28a2MgNYqZY3LhUCSORMPbCzOZtBrk6Vr8CXrue9UAfeFRikHIm
         8mrvkFLlfzd4FcYb90TfpDi310HJ1jgiJXpGXqHEyLXBfvxAmqO+g3WGhiv74QRvMCb1
         1kWH7MuW+Dv/xyasWfFLr2dt3UDc4O01ipSRCmI6LJ6jvWlhyPCJdHeJMbWUnCtXm40m
         IOcippK1EdKkXBwU1RdjAdzwjexeLzaZpRtgUjTBU0VfoWORwiCIUIgsTaCpWp+mwLrg
         J1Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
        b=gRzcylCfR0dbvdvI9i9Rv+UsNwvYbMMLYLNdfR0W5/S1uaGn8/261NbfIASJtbq8+K
         GErsf6WMNbWCSSbawHJ4/ZK8fx42m6BHuJgI4Fl4/OnPo/DiXEzql+bgFCOts6ZgZVGa
         9GTT/HHKJGQonJxlt+1SpR3GxtBTaZj3sEfYPGq8zeCGdKkgcefW2PSY4+mUNdQ1Wj0p
         WU0GljAR2M9eaV7fnMp2+dC8ZqLgXneiLxmHMFtAuckLa7J/Qot5Oe3qrZr8Bo4kWM1F
         +mfpy3UjzMwcJlzjsulonIHSb4DS8n8IOlpfrjStdOf/84c3Eq58pm1d0hgzkhAt6b0k
         zsuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mWZhJNl5;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id r18si18904785wrq.137.2019.04.26.09.23.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mWZhJNl5;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9R75Mtz9v0yl;
	Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=mWZhJNl5; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id pejyN-_vvrtx; Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9R5xkrz9v0yk;
	Fri, 26 Apr 2019 18:23:23 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295803; bh=fZn4Ngfk7JFea7diHSde6/p9kbdGl4xxyo9G2/zdnzw=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=mWZhJNl5MWALH4/OfSNMVfEu1NejXIYc7UcvDCpghObfYB4nyCs/wX5jepBmownAe
	 eBPMUO3zybB7urQ4m3pSV8cfEBPSBWj983mrTSTyCVckhQI0uB/UsQ2QhVnWMkpmbo
	 hsdoXz3FgMXRMlMa4vlTi25bPgR6n/tkJ9LjoXxg=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 7B5068B950;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 8G4B9HTiNuxM; Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 4B7BD8B82F;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 43345666FE; Fri, 26 Apr 2019 16:23:25 +0000 (UTC)
Message-Id: <08b3159b2094581c71e002dec1865e99e08e2320.1556295459.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 01/13] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:25 +0000 (UTC)
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

