Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9211CC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 512D820868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 07:33:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 512D820868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 117E86B0008; Tue, 16 Apr 2019 03:33:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD4A6B000D; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9CAD6B0008; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99E376B000C
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 03:33:36 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i203so9362449oih.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 00:33:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=o0dmMhSOY0P0arluYgW/A7kRbjmCVA9cq9ZXzsB640qNJf4xkoRjo5DF4UZkCWQZUh
         fFgb71AEG7F3W18r5b27XJWCxbnowaZcKFiUuzhMp3Nz7W33LOLDZFyqFziEVYY1ml9d
         CR/qavNSrQWfRYxGIiV/kRT8hr/LOx+eTE0Tn22qPSgcbsQmIDzg98/aMDGjdJZIwtv+
         mpsI1+B/Kb6tiNLvT/9OGrfLpZkKDPEwlgWacC7VRGRe0iO4j3qXhE5pXAOgDZAkkgU4
         JvvD/WnRelRWxXTB8KW8hq/BiCHFFsm/ofqzbREq+m1iY/ajbHN5/qUfUOlqFFlxUfN8
         C/uQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAV3pQnQJoOoCfldCIw7mabyY8PB/skfm+616XCQVyggCDXHfcTx
	ktzVQmM6bNo+ME4ZwRo+unptdIOT69Zrzz+rtLg4Bee1DsxZtMfVnfRbTKWk4+Q2v4ri8gWw3AZ
	SNZrbMUyqmcNOtt7wtDfRzBb+jqmd6/DE2ds5ElFQKg7Yc2vZlrxZOoAEcVBPMREEYA==
X-Received: by 2002:a9d:3f4b:: with SMTP id m69mr49984594otc.246.1555400016299;
        Tue, 16 Apr 2019 00:33:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2Hb1Y87+v/CmjAjTZDErH6SQkFnLBZtW755hCePECz1i/T6aOsItawe/KRq69MI1C/5h6
X-Received: by 2002:a9d:3f4b:: with SMTP id m69mr49984543otc.246.1555400014986;
        Tue, 16 Apr 2019 00:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555400014; cv=none;
        d=google.com; s=arc-20160816;
        b=ebVHCPC+rLcz22zZzuPFDXPjs6rkqJVkfFDO41cV9rW7hNtbx+nHouscSDHdL8HiXh
         DFO3+uGhRXeyavBr0r1Q0Aij3pm1m3qaD2Svta5usYTkFOHg7nG86tbP4l0t70H/VcaD
         t2n9ACfD5+S0N0Mk//1KUlz8TrfatysZDaF4hmLxXrEnKiWIo1vHOKk2FrkbkFz+smYX
         u7Fq6wi3R4ttHr23KTRyypBks1QC5jUjubVzuT7K8Btw1GrkBCmyN9R4P/ON3ZYupHu6
         TWueUKlJ0TUhWJ12rCUL/mLQ5xikNtCdwT1Jv532xnC7bqdYTnSedMYywA35GV/sHKhR
         /Rhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=msW/DfQw6RLXEJV1GdO6xcS+vBgdX+OmDHFBMpqAuDk=;
        b=a7vfhKGHaAc3bINYVdM/85L4Mzt9zdYTWcN+72CSoIhJwqkYTGL4TB4jOsD7DrXkmk
         n4AxAPompKoUJoG5IJGnDq52V0CJvLL7tU9fZcslSTrNJyc/1ax7qXXRudKzjS7F0ubM
         o5tmJNB4a7cIJXSzyGY3+DwVEtizJkba3lQROnVE4oPGF3xXY1dVbHoDmQ3Kj+DIoWq5
         8DxER4dTSvURT7O1ZwXX0QkP+Fyw+sdQxWVvp7hn0nEso0v1X1j5H747eeFZmItrlfqi
         w9efqTRtski75rp71E5q5tmr28HoAa7LBXLjSv59aXfqHuTr123rwA4mVPk5Yxl/hnY3
         zyng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 31si27731872oty.209.2019.04.16.00.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 00:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 9A06628F29508A9FEC9C;
	Tue, 16 Apr 2019 15:33:23 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 15:33:14 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v5 2/4] arm64: kdump: support reserving crashkernel above 4G
Date: Tue, 16 Apr 2019 15:43:27 +0800
Message-ID: <20190416074329.44928-3-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190416074329.44928-1-chenzhou10@huawei.com>
References: <20190416074329.44928-1-chenzhou10@huawei.com>
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

