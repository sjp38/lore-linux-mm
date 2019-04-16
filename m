Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C79A2C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81E5920821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E5920821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 262BF6B000C; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21D976B000E; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B47E6B000D; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id C67486B000A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:25:05 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id d63so9665802oig.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:25:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=tfUsmA0hEYJanNS+lthAom4xjpbj2HEylkOwGowp3c1dOWU6SEQYBpR95e1MH0JoYv
         MZtRrhHKGgIVSDxYiKAnE/g9+0FG72hsY40YDRPQvYgkiw9NdU5Lw5cORnsQVtr+wGWl
         I2tkZtJbEGVlcPkQ+0QD9FTVBWtp11sP4L4zOaxlRfAiD/baeWZ0y+xdFK8I8l7zBZmZ
         ZILavIetHx6wHTgxnjSyHl5Dg/sfmwmoSfi39Tx40Tkh5PX2mOhBVtHVcDK7EXsfPkcz
         kzMM0yW5xOOwb4WRxnatd5aVwpYd5g38pG/W5u9EPXiGN5hany4wBUKqHXJ/pG1gz4qU
         qdlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVf9um07tsof0AP43EWWZT/Vhid5NS/cVA00nex0kKn+rMAx6oT
	Ojw0vy0F2sfMWsJcxcBJQ6OhbqymEsWa4DZODI4AEH/38AMZVfEYQtF0jIkNRI2VpUd6/G5VfsZ
	f2LCl419swcNsz3nLhr4ozAg6DXHPuGBxyUZWUYFiTSdidMgDlcFUlv9boE4UG9GcZQ==
X-Received: by 2002:aca:4507:: with SMTP id s7mr22404615oia.127.1555413905540;
        Tue, 16 Apr 2019 04:25:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxto7OepSxude7d08zh3ob9XGi3Dp8xryaDKUCPUczmWtVAQbVG+L9iuLRkh53FnF2M7eAu
X-Received: by 2002:aca:4507:: with SMTP id s7mr22404592oia.127.1555413904829;
        Tue, 16 Apr 2019 04:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555413904; cv=none;
        d=google.com; s=arc-20160816;
        b=0s8OuV88/zFl3EQBvpVxC250bNi0imjN43m8d7CvjTHsXaucD4hf1OKDAEdIfnjAvq
         6bxIEk8XneiblBz+rKRq/d4iC+iSdjNsmpcY1WrKYZ3P3ETQ3aAQCFJQbhfhidFKCyRO
         wX4AaCjDCpYaEnssyUbKx+T162oe+tHpMFdMWiE2L+dZqODaNHVSgXfIzytl+CrjKXm5
         gOpc8PyfECQrr8ux/1Sri7K5fwZJlfB0UBkPg6QEhWZSTZ2Ru5m1UlhLO37Jaktk4QL2
         Q8cLp4cXfKYaj8AYw7vMZGHA7zPNwwi+XWpSFYpd40cAC/j+WIBKD97vTO3q6vizxnEh
         lDyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=AY67uhSZ46tsiReYE1ExiG2D4jdLCUEtIKo2gbZ2yMtrYs0Q5a6WVrVvzV+joO+jkZ
         Bl7B60E0H7W1N+UJ+rndQ8yQBSgBMjy5rPo6WsR+pw3E66KavF7H3xMrgKhIC2V9tbII
         sUeICweZObe2F65PHqDevbKY0RyZIDV1WcssfQcU1BnPBplG5B59N9R0owPeW35Mr7FH
         LCrsB4S7JuqcH/b0xqy2kH8VP/ZZLm/tI+6EjvvH4vCz68j4uQ9Esi612XU+Fju1Cr37
         7mT0OpghLtdkwgfpALecmURY6aDyaig+MzjpKY1nTbaWYao0N32+9REJRL95UYjIWnoM
         X4Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id m11si14944947otc.49.2019.04.16.04.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 681B4554A1C5BD91B5E9;
	Tue, 16 Apr 2019 19:24:59 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 19:24:49 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [RESEND PATCH v5 2/4] arm64: kdump: support reserving crashkernel above 4G
Date: Tue, 16 Apr 2019 19:35:17 +0800
Message-ID: <20190416113519.90507-3-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416113519.90507-1-chenzhou10@huawei.com>
References: <20190416113519.90507-1-chenzhou10@huawei.com>
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

When crashkernel is reserved above 4G in memory, kernel should
reserve some amount of low memory for swiotlb and some DMA buffers.

Kernel would try to allocate at least 256M below 4G automatically
as x86_64 if crashkernel is above 4G. Meanwhile, support
crashkernel=X,[high,low] in arm64.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/include/asm/kexec.h |  3 +++
 arch/arm64/kernel/setup.c      |  3 +++
 arch/arm64/mm/init.c           | 25 ++++++++++++++++++++-----
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexec.h
index 67e4cb7..32949bf 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -28,6 +28,9 @@
 
 #define KEXEC_ARCH KEXEC_ARCH_AARCH64
 
+/* 2M alignment for crash kernel regions */
+#define CRASH_ALIGN	SZ_2M
+
 #ifndef __ASSEMBLY__
 
 /**
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 413d566..82cd9a0 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
 			request_resource(res, &kernel_data);
 #ifdef CONFIG_KEXEC_CORE
 		/* Userspace will find "Crash kernel" region in /proc/iomem. */
+		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
+		    crashk_low_res.end <= res->end)
+			request_resource(res, &crashk_low_res);
 		if (crashk_res.end && crashk_res.start >= res->start &&
 		    crashk_res.end <= res->end)
 			request_resource(res, &crashk_res);
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 972bf43..f5dde73 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -74,20 +74,30 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
 static void __init reserve_crashkernel(void)
 {
 	unsigned long long crash_base, crash_size;
+	bool high = false;
 	int ret;
 
 	ret = parse_crashkernel(boot_command_line, memblock_phys_mem_size(),
 				&crash_size, &crash_base);
 	/* no crashkernel= or invalid value specified */
-	if (ret || !crash_size)
-		return;
+	if (ret || !crash_size) {
+		/* crashkernel=X,high */
+		ret = parse_crashkernel_high(boot_command_line,
+				memblock_phys_mem_size(),
+				&crash_size, &crash_base);
+		if (ret || !crash_size)
+			return;
+		high = true;
+	}
 
 	crash_size = PAGE_ALIGN(crash_size);
 
 	if (crash_base == 0) {
 		/* Current arm64 boot protocol requires 2MB alignment */
-		crash_base = memblock_find_in_range(0, ARCH_LOW_ADDRESS_LIMIT,
-				crash_size, SZ_2M);
+		crash_base = memblock_find_in_range(0,
+				high ? memblock_end_of_DRAM()
+				: ARCH_LOW_ADDRESS_LIMIT,
+				crash_size, CRASH_ALIGN);
 		if (crash_base == 0) {
 			pr_warn("cannot allocate crashkernel (size:0x%llx)\n",
 				crash_size);
@@ -105,13 +115,18 @@ static void __init reserve_crashkernel(void)
 			return;
 		}
 
-		if (!IS_ALIGNED(crash_base, SZ_2M)) {
+		if (!IS_ALIGNED(crash_base, CRASH_ALIGN)) {
 			pr_warn("cannot reserve crashkernel: base address is not 2MB aligned\n");
 			return;
 		}
 	}
 	memblock_reserve(crash_base, crash_size);
 
+	if (crash_base >= SZ_4G && reserve_crashkernel_low()) {
+		memblock_free(crash_base, crash_size);
+		return;
+	}
+
 	pr_info("crashkernel reserved: 0x%016llx - 0x%016llx (%lld MB)\n",
 		crash_base, crash_base + crash_size, crash_size >> 20);
 
-- 
2.7.4

