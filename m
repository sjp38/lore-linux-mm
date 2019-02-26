Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B550AC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7229221848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:22:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="TVhWyjgH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7229221848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 860C88E0001; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B57E8E0005; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 543178E0001; Tue, 26 Feb 2019 12:22:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC5B18E0003
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:44 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id i64so559351wmg.3
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
        b=ajlwUD0q8tR4O2Qar+UBz79buwsEiaW3ReaBPS8K6Etx14U4dwDWruZUBoGyuvWjmf
         EZ1fgZ26nbbsPxSPkUcLLV8RDnSDM8PFmPdQom1gwfeIRqYmgabTaLw4zVLuHe/DD2SM
         8XkC8Etpumql8/wBZ1O3KM/iTIN7hzsGy/nnxZ950VW1Kkxn9VTjg8OfxzSXgtDCUX0i
         GbUcM9L8o7NYCxfwUV+NdYBVnsluaogcMR4JjfekJL8bvrBnGZ0PkcN9OMd3GhAN9b4i
         D5uIducR8jjEdc/Y09DyC41mVUjcgIUPqITpls103sn1NcRg2Z5Qe/T+B8PtApsItCc+
         OYvA==
X-Gm-Message-State: AHQUAuZIQdRh6qU0tfuVCm+kq9d0Ud5tlTIItUVMVlftMD9cZ3ujivs0
	pp+EL1Za6ydowRrshJ2JVVKsePhQwkdKrfPcrBQO/ghoZqXmXoegNSCSLojvjolw7+zjG8QPIUe
	/PrIhzwcv4cZoTmLWJC0Qqa0Gklo+PFhl3EfXyVyAHxm5brqm0HeDYucg1l3fiemJqA==
X-Received: by 2002:adf:f7c9:: with SMTP id a9mr18393319wrq.39.1551201764375;
        Tue, 26 Feb 2019 09:22:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYAopQX7kPWwU61T+5uGwPlfAOqsOrbaG3AhuabvlWtefQfvFcUju8/BLaOlCI13nuePF75
X-Received: by 2002:adf:f7c9:: with SMTP id a9mr18393269wrq.39.1551201763354;
        Tue, 26 Feb 2019 09:22:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201763; cv=none;
        d=google.com; s=arc-20160816;
        b=HD4K3vQL6BhFCyf+Pqd6mjPdI02n9VqC6SXu/dfXg8M1UGBJQJC3MOUPj7lHQwo55G
         hmIJpsy9+t4+0wlljHepwUgAOYFKxqV5yf/fH48uzc4vqJVngffcSsrpnzWP8oEL8p2N
         I8sdTZQSw9986F32YSNlZnh5BwgZXSTJm+lqHCW0jI6GP/Yyh1rrPLHJj8ZQLxLzs0an
         pXwyml4fsEXeoK7zP7yHFjYih0CVrCHxWNvYje21zlFB4nYN+pGicEnP11kF0DZnAxgj
         UWx0OcaW03EF7P2u+qfhKrBSEpg4R4cC2AVD6zlcANEC3UsZG5e+++y+vve01YlKKtEP
         4TZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
        b=uAYp1iSkhkFAXqSl5CQzrO2Cnz1/FNvmTo6es1rrUF63mxefAUTQtffW7x3T/03fMz
         ZYNR0yqj2EOO33upBb6Lh6YARAXmCZdKKQP+rGDMj6sGsKqRLGyne8elMiW9WQUBaPb9
         a6a/ygMuGMcePHNyWMjy1rHCiBKSfV8r9RcHYfl40ReI8OIpePmkkSOTiPzpujxQ2EgR
         0dVFcnjIz3HBJ/cLQvlli/BPCTWffBL8/RHIrlkSMRDQr51pnqAe6Q68v5Coh7s3HQBn
         XDR7JzLh8aqheH1ECNu842PqcbZodOv1mzYhC7WmKMtjdiGgJpBBQYdn+c0lMUQT5NfP
         1i8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TVhWyjgH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 124si7639007wmz.184.2019.02.26.09.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:43 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=TVhWyjgH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485H51f9Tz9vJLZ;
	Tue, 26 Feb 2019 18:22:41 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=TVhWyjgH; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id 6uGqo0zc52lX; Tue, 26 Feb 2019 18:22:41 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485H504Blz9vJLY;
	Tue, 26 Feb 2019 18:22:41 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201761; bh=hTJrfrNY8LS5ZO8s8Ac31/wAdL77hGVOtcoy12Rml60=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=TVhWyjgH1Q5l/zPFKGL2XOV/0dKMvxZVzAzU1iTxKD8gWl376rKS2541nFKJ6b7n/
	 O9sgsEHg+YpxoHQzQi0z8jDI1sDtrMyrEmbG9TvZGJrgsN/n8cuXL2o7Wf6GpPCDp9
	 m7EwZJMQ2kjc8ZJjpWlOqiguBGC0gDRI7QsnMO3k=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A21F48B97A;
	Tue, 26 Feb 2019 18:22:42 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id w_bvTWO6jymg; Tue, 26 Feb 2019 18:22:42 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5A7C08B96A;
	Tue, 26 Feb 2019 18:22:42 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 3A79F6F7B5; Tue, 26 Feb 2019 17:22:42 +0000 (UTC)
Message-Id: <85668899ce3782a11045f678390ac36ca60ef153.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 01/11] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:42 +0000 (UTC)
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

