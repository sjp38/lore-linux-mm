Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AFAC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DE5120835
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:42:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DE5120835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775896B0007; Mon,  6 May 2019 23:42:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727A46B0008; Mon,  6 May 2019 23:42:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63ECF6B000A; Mon,  6 May 2019 23:42:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 392606B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:42:18 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id k90so8559802otk.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:42:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GzzSFJ5ZcDAgbPLgqQMBmNbo+FYPTpZunI5GjWwF7e4=;
        b=Vs9oMBw3ufezGM6hR8C+1EHcGrGe+7k1FLcMP6zv75bs1C0/k57VjQyLdkG5hy6VEr
         YUCg3ALwMnB3id5DtQEtpZjFDABiTqAudONokvr7Hc9VHes2aSYRc/9Noa8W6li9OZkH
         cymz/CMVC576Q5zj0dzEANruZOAz9ayitbIgthvOR+7JBhKUgBLKGehoDtFRslea6bwB
         6xL2eAdE42jbovEjqrPWbTnYliy7pMOpmhhYLtHIbu6AxFOC+KRjxR0XXYyBTtEPqKuy
         j53nZRxHrHCpoBJqR0dHDldx0urwHvCl9e9nVP8spuqSqmyY5yDoOcH3Vdj7TiDgfvEm
         8I8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUQNGeEF89Z5cprzSTBG+s/6RdO0+GdWxoyEpvsV9VOuVXS2T4d
	X2+xbg/hMMWwpD9igejH3g5OHyICOMUmKEQ7qrwOLXmsy3vHLbtD3UZ+0WRJtYLdRcNy6ywhCWt
	fEZM6psjPoA8Tq8zfHvSBW5kNtlHpgxAKguJjWvSlMB8UXqphk+Yc6eMHuxB0QWjpjQ==
X-Received: by 2002:a9d:77c8:: with SMTP id w8mr19702273otl.365.1557200537923;
        Mon, 06 May 2019 20:42:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFe7EqvvuM7SvAk77rSAcQo0pWlPQWon/KO1IZY8CuaFqq363PnX9gau6stIp+27lzL5V/
X-Received: by 2002:a9d:77c8:: with SMTP id w8mr19702215otl.365.1557200536459;
        Mon, 06 May 2019 20:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557200536; cv=none;
        d=google.com; s=arc-20160816;
        b=t2sXY0NdptRtnJvuAtG5dklqRH2YJY/JQFwAwuJ51ih0YNKPRhVGunEmLlysn3IaCO
         qgutwFm5qHRYDkptrZT7iGCnJNRQHnwrbDyvMnT/U0NfRAwT4E/e2oejQzHe4zGservj
         cryYcJWDv8vo+BAWmesb5zePWSCnlKb6RaiSpH6fq2S84JCTKrITQjSM6/G4UMeo5NN4
         DmtrH2JnZyesa8oxCEMGNTENRdJw3T9tETipbO0BwjyyCTJLXNQaKOSJAjAsAsGKxJ3B
         WO4Ambk4Mwy0YAqE6m0GnNsE4nvY2B4XJfYiNe0RzkbUY7IfhsyJoaHNtLX1AEM2ZGni
         lmew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GzzSFJ5ZcDAgbPLgqQMBmNbo+FYPTpZunI5GjWwF7e4=;
        b=ICkwhMm434WYq+jmaIXsBhxceMVTX/g+ANs7C8hELK4eIM/hTYEw9vKRIHldAtWByW
         63ZixLul8haQMQB7IHExr4bcOdIFwJuyDK+hwq8DYNdTaMTpV90PuLBD5lTP0oBMfXwg
         r0bixPimLUgKfNwVhpAbyfy7p1nGNbTL0Y9obiiLJ9v1whzS15hXw5Q2RVylw2F7Exeb
         ydP5WqLUziliOQ/Ilq4RjQs8udQto+cMRxxT1Ki8f17u1b9L72kYFAm6u/GDN0uGqsaw
         zpTI0Pxs5mwp14dn9zcVvJ0exLg7sY4+tf8SKjKiWzi7tQ57RN0Qc7zJIM5UAw9umdco
         9gTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v62si7188557oia.93.2019.05.06.20.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:42:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 61A06FA6DD0FEF377DF2;
	Tue,  7 May 2019 11:42:10 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS403-HUB.china.huawei.com (10.3.19.203) with Microsoft SMTP Server id
 14.3.439.0; Tue, 7 May 2019 11:42:00 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 1/4] x86: kdump: move reserve_crashkernel_low() into kexec_core.c
Date: Tue, 7 May 2019 11:50:55 +0800
Message-ID: <20190507035058.63992-2-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507035058.63992-1-chenzhou10@huawei.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
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

In preparation for supporting reserving crashkernel above 4G
in arm64 as x86_64 does, move reserve_crashkernel_low() into
kexec/kexec_core.c.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/x86/include/asm/kexec.h |  3 ++
 arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
 include/linux/kexec.h        |  5 ++++
 kernel/kexec_core.c          | 56 +++++++++++++++++++++++++++++++++++++
 4 files changed, 71 insertions(+), 59 deletions(-)

diff --git a/arch/x86/include/asm/kexec.h b/arch/x86/include/asm/kexec.h
index 003f2da..c51f293 100644
--- a/arch/x86/include/asm/kexec.h
+++ b/arch/x86/include/asm/kexec.h
@@ -18,6 +18,9 @@
 
 # define KEXEC_CONTROL_CODE_MAX_SIZE	2048
 
+/* 16M alignment for crash kernel regions */
+#define CRASH_ALIGN		SZ_16M
+
 #ifndef __ASSEMBLY__
 
 #include <linux/string.h>
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 905dae8..9ee33b6 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -448,9 +448,6 @@ static void __init memblock_x86_reserve_range_setup_data(void)
 
 #ifdef CONFIG_KEXEC_CORE
 
-/* 16M alignment for crash kernel regions */
-#define CRASH_ALIGN		SZ_16M
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
@@ -579,9 +523,13 @@ static void __init reserve_crashkernel(void)
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
index b9b1bc5..096ad63 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -63,6 +63,10 @@
 
 #define KEXEC_CORE_NOTE_NAME	CRASH_CORE_NOTE_NAME
 
+#ifndef CRASH_ALIGN
+#define CRASH_ALIGN SZ_128M
+#endif
+
 /*
  * This structure is used to hold the arguments that are used when loading
  * kernel binaries.
@@ -281,6 +285,7 @@ extern void __crash_kexec(struct pt_regs *);
 extern void crash_kexec(struct pt_regs *);
 int kexec_should_crash(struct task_struct *);
 int kexec_crash_loaded(void);
+int __init reserve_crashkernel_low(void);
 void crash_save_cpu(struct pt_regs *regs, int cpu);
 extern int kimage_crash_copy_vmcoreinfo(struct kimage *image);
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index d714044..3492abd 100644
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
@@ -96,6 +98,60 @@ int kexec_crash_loaded(void)
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
+	ret = parse_crashkernel_low(boot_command_line, total_low_mem,
+			&low_size, &base);
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
+		low_size = max(swiotlb_size_or_default() + (8UL << 20),
+				256UL << 20);
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
+		pr_err("%s: Error reserving crashkernel low memblock.\n",
+				__func__);
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

