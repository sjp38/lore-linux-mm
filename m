Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D171C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 487842084F
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:17:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 487842084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47FB86B0010; Tue,  9 Apr 2019 06:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4329B6B0266; Tue,  9 Apr 2019 06:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D3596B0269; Tue,  9 Apr 2019 06:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 083A96B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:17:39 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v4so6013657vka.10
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TeOuXwnzP0/2bZoD0vz687cTVHAax5QzABrgfzFZYnM=;
        b=XAogGmVS5ZhDfFV0GzNU8RRApIEVyj4c8qFzU0qNGis3DlRmgNYpUKGzs8HxFJkftr
         Lm1WxF1R8ZRxK/NyHJDBvjDleDoWmD3/j7b3Fx3xjnGZ9PrKfG4u1zrOxQQQQ4rOXC0D
         MKayveOkwwIA8Bdki1RXOb0ISTl5DzuJ4WVS/mMFaqow/JH1Zclg3Og6gDXo9t6tYj1A
         xB9gpVRHOnUB4qdhJDSqDoO3zb30oXGqvMckQClmwoxShlvVe5OOg4wz+eB3flKzj2b2
         yy96OSIBriV1nF3w9lQJWq8ehqXkoNz8wIyMXdrAaRQz0WEPkrs1bMXT0resPqZH4Z6f
         tgwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUjOH/Ly4n/yCuXmkhKv8qcGuR05c3emDi1FcyhQng6hC/EfY/v
	yBZwwtKpFpzSX0jA2oYcAs32Ntgq3AALEiMzXbJjVHoSbYAqnjrUeNy+CGquv/JtNT01Y0t/6te
	agPHBWRiVGANdnlZegY9ZC8thyWRyNoQub2GuciSDPXSqhGAdK/y3VEaUsK+XN/MyUg==
X-Received: by 2002:a67:f416:: with SMTP id p22mr20084019vsn.175.1554805058656;
        Tue, 09 Apr 2019 03:17:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQwoTi85OIRmNXE7qOxqiUAf8k11fvgPXV8XnLDp/NmSbv+dLRN4OOcheBPcVq+sxIpAV5
X-Received: by 2002:a67:f416:: with SMTP id p22mr20083951vsn.175.1554805057028;
        Tue, 09 Apr 2019 03:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554805057; cv=none;
        d=google.com; s=arc-20160816;
        b=K0lLaqltnkygDLN18VIhzBS/wOp9DcPMIUb33+NLnY5z/qzGaQMy63i6xSJUTG5FfL
         uPE8Tjsmnoo3k1U6CF6mv60FcKdRTgjsQJICs8pXfIrFL6CrZuU+OeGPDImZEuKWeI3y
         xEvDX8EdAT29BXKfAWI7vsHhxjRD3bnxU5xZt8JFpuDN5hE8chd2zIYp5OsS5P/Gj/pr
         M5pmePjQcPdIsZfC9T1x730wCaMNV7IcFl9d+zc5seoPyE+9pBY23qHTCNXAcqZx+la/
         jUVBDlkg7HUy44Fo4SfvKCHwZpNGISNCJvTPeCTBz5zBcrLKk2FFglt6Q5Tzw5V8Phav
         23Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TeOuXwnzP0/2bZoD0vz687cTVHAax5QzABrgfzFZYnM=;
        b=TIE2b4GQgvxBeuv1K9DVI2uTWQ9wNM1WpWsk9YgPtv8EPRHd11TnveRt2+8e5vLpfL
         /nCuY31/JOgj22/Ua6tHGQpt3Ytr0b3Ak20DbuWeO7aWqorRBAHrl9yQtGBV4KItLMA8
         7cdpkrAkPaagsFsfL7d57dPFJewrM0a/2kttTBjecPuEMVEcN+qTEWQ4b0g8rOA5Dsi2
         +2o9MnMuWBJ313iCWEUWUJ5HTtp8qwbMP7EWMeKBGutgRbV32oxVuPz2ilQ4cT46NpX9
         tTNaSxvDIiQa/SxLNXUrN0Eil/S+bdSgJ2fT8xdjSIaKoqzbvxxX0IsFQGg1S9wdfJBh
         dGOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id s12si5363628vss.204.2019.04.09.03.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:17:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 4E19590136526AEF6836;
	Tue,  9 Apr 2019 18:17:31 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 9 Apr 2019 18:17:22 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v3 1/4] x86: kdump: move reserve_crashkernel_low() into kexec_core.c
Date: Tue, 9 Apr 2019 18:28:16 +0800
Message-ID: <20190409102819.121335-2-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190409102819.121335-1-chenzhou10@huawei.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for supporting more than one crash kernel regions
in arm64 as x86_64 does, move reserve_crashkernel_low() into
kexec/kexec_core.c.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/x86/include/asm/kexec.h |  3 ++
 arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
 include/linux/kexec.h        |  1 +
 kernel/kexec_core.c          | 53 +++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+), 59 deletions(-)

diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index 003f2da..485a514 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -18,6 +18,9 @@
 
 # define KEXEC_CONTROL_CODE_MAX_SIZE	2048
 
+/* 16M alignment for crash kernel regions */
+#define CRASH_ALIGN		(16 << 20)
+
 #ifndef __ASSEMBLY__
 
 #include <linux/string.h>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3773905..4182035 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -447,9 +447,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 
 #ifdef CONFIG_KEXEC_CORE
 
-/* 16M alignment for crash kernel regions */
-#define CRASH_ALIGN		(16 << 20)
-
 /*
  * Keep the crash kernel below this limit.  On 32 bits earlier kernels
  * would limit the kernel to the low 512 MiB due to mapping restrictions.
@@ -463,59 +460,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 # define CRASH_ADDR_HIGH_MAX	MAXMEM
 #endif
 
-static int __init reserve_crashkernel_low(void)
-{
-#ifdef CONFIG_X86_64
-	unsigned long long base, low_base = 0, low_size = 0;
-	unsigned long total_low_mem;
-	int ret;
-
-	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
-
-	/* crashkernel=Y,low */
-	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
-	if (ret) {
-		/*
-		 * two parts from lib/swiotlb.c:
-		 * -swiotlb size: user-specified with swiotlb= or default.
-		 *
-		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
-		 * to 8M for other buffers that may need to stay low too. Also
-		 * make sure we allocate enough extra low memory so that we
-		 * don't run out of DMA buffers for 32-bit devices.
-		 */
-		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
-	} else {
-		/* passed with crashkernel=0,low ? */
-		if (!low_size)
-			return 0;
-	}
-
-	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, CRASH_ALIGN);
-	if (!low_base) {
-		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
-		       (unsigned long)(low_size >> 20));
-		return -ENOMEM;
-	}
-
-	ret = memblock_reserve(low_base, low_size);
-	if (ret) {
-		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
-		return ret;
-	}
-
-	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System low RAM: %ldMB)\n",
-		(unsigned long)(low_size >> 20),
-		(unsigned long)(low_base >> 20),
-		(unsigned long)(total_low_mem >> 20));
-
-	crashk_low_res.start = low_base;
-	crashk_low_res.end   = low_base + low_size - 1;
-	insert_resource(&iomem_resource, &crashk_low_res);
-#endif
-	return 0;
-}
-
 static void __init reserve_crashkernel(void)
 {
 	unsigned long long crash_size, crash_base, total_mem;
@@ -573,9 +517,13 @@ static void __init reserve_crashkernel(void)
 		return;
 	}
 
-	if (crash_base >= (1ULL << 32) && reserve_crashkernel_low()) {
-		memblock_free(crash_base, crash_size);
-		return;
+	if (crash_base >= (1ULL << 32)) {
+		if (reserve_crashkernel_low()) {
+			memblock_free(crash_base, crash_size);
+			return;
+		}
+
+		insert_resource(&iomem_resource, &crashk_low_res);
 	}
 
 	pr_info("Reserving %ldMB of memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index b9b1bc5..6140cf8 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -281,6 +281,7 @@ extern void __crash_kexec(struct pt_regs *);
 extern void crash_kexec(struct pt_regs *);
 int kexec_should_crash(struct task_struct *);
 int kexec_crash_loaded(void);
+int __init reserve_crashkernel_low(void);
 void crash_save_cpu(struct pt_regs *regs, int cpu);
 extern int kimage_crash_copy_vmcoreinfo(struct kimage *image);
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d714044..f8e8f80 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -39,6 +39,8 @@
 #include <linux/compiler.h>
 #include <linux/hugetlb.h>
 #include <linux/frame.h>
+#include <linux/memblock.h>
+#include <linux/swiotlb.h>
 
 #include <asm/page.h>
 #include <asm/sections.h>
@@ -96,6 +98,57 @@ int kexec_crash_loaded(void)
 }
 EXPORT_SYMBOL_GPL(kexec_crash_loaded);
 
+int __init reserve_crashkernel_low(void)
+{
+	unsigned long long base, low_base = 0, low_size = 0;
+	unsigned long total_low_mem;
+	int ret;
+
+	total_low_mem = memblock_mem_size(1UL << (32 - PAGE_SHIFT));
+
+	/* crashkernel=Y,low */
+	ret = parse_crashkernel_low(boot_command_line, total_low_mem, &low_size, &base);
+	if (ret) {
+		/*
+		 * two parts from lib/swiotlb.c:
+		 * -swiotlb size: user-specified with swiotlb= or default.
+		 *
+		 * -swiotlb overflow buffer: now hardcoded to 32k. We round it
+		 * to 8M for other buffers that may need to stay low too. Also
+		 * make sure we allocate enough extra low memory so that we
+		 * don't run out of DMA buffers for 32-bit devices.
+		 */
+		low_size = max(swiotlb_size_or_default() + (8UL << 20), 256UL << 20);
+	} else {
+		/* passed with crashkernel=0,low ? */
+		if (!low_size)
+			return 0;
+	}
+
+	low_base = memblock_find_in_range(0, 1ULL << 32, low_size, CRASH_ALIGN);
+	if (!low_base) {
+		pr_err("Cannot reserve %ldMB crashkernel low memory, please try smaller size.\n",
+		       (unsigned long)(low_size >> 20));
+		return -ENOMEM;
+	}
+
+	ret = memblock_reserve(low_base, low_size);
+	if (ret) {
+		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
+		return ret;
+	}
+
+	pr_info("Reserving %ldMB of low memory at %ldMB for crashkernel (System low RAM: %ldMB)\n",
+		(unsigned long)(low_size >> 20),
+		(unsigned long)(low_base >> 20),
+		(unsigned long)(total_low_mem >> 20));
+
+	crashk_low_res.start = low_base;
+	crashk_low_res.end   = low_base + low_size - 1;
+
+	return 0;
+}
+
 /*
  * When kexec transitions to the new kernel there is a one-to-one
  * mapping between physical and virtual addresses.  On processors
-- 
2.7.4

