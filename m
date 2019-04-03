Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EBEBC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C1CC21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 02:54:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C1CC21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9DD56B026F; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4DC66B0272; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D286E6B0275; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A23926B026F
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 22:54:47 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id r23so9495585ota.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 19:54:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UBAKnE8KUH0dKsvUsRf1caQt1pkMsYPo1KirROOGv/A=;
        b=Y+KdDJDocrRlTLZyesn1y09KCjpMJ+iGV+xDyWteDZZRCkdY29mj+QwdsqAM/1NMoN
         7pexG3QYMTajQ2UjL2ydMfNYwOQx/xW8Nh3zl4O+Sg40B2M1af4J5TOU2FPEiyZ0JQri
         cFuU6BfHaBiCAeeHeyyo7M+lYZiTd3R71+S+T3ncilR0905E9SEpfH4WxV3pKdDlaren
         5IjhfRFKjx0jp18BhS2ug71x1YfZHzoeMNhKJuKCSTI4QsczW+zEdMLcd8M8EMMVriz+
         Et/eBB2GhGZA6aG2HfFJYy4PSP3HBiTrHbbyqVdZs/JHY7wWrwWF0rBtS8rjARkOBHV0
         oCJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAVgi8u2JSNwfqkJPbQBFLM32DPFwCCYnnlfeRydgwqb21ZP5Hnw
	8ThQb1Hc2MWwgJYsviTQfqVdBDef+zVjM/OMnAz607HD9yvrFN4j9UipTKrFNv+YFeA8jf1DopI
	RygfhWWypoPYMgua4iu5xdUarA0WVca8qgBkF19qZYGPp/Bisy+CWoVKbwCUTzmDzAg==
X-Received: by 2002:aca:b943:: with SMTP id j64mr206281oif.18.1554260087336;
        Tue, 02 Apr 2019 19:54:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBjVy9jz1Z1K2zGnfv1UNjQEbuvw3GVaPUedv4fwS3ipCGBLoTokf6qPlqdAhTv32Tsntj
X-Received: by 2002:aca:b943:: with SMTP id j64mr206241oif.18.1554260086126;
        Tue, 02 Apr 2019 19:54:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554260086; cv=none;
        d=google.com; s=arc-20160816;
        b=0aRhhzzizI4/+XUkzay8g6dy9bOBlBmMgCXbLAhtzGB7PXrIXXkHpdXLIksjga7iB6
         h93FjWGZm9F2t0TVK0K8yXojpVZMqv4AxN2T9vmtjq/APRZA4+BU9zYAGwMiojyyKObL
         HsxKtRjx3lASg9DrtKWpYs5kxxxA99MzIniaP3toCdPVdWtf21M3fsJ1XreckqLA9Cmr
         FiO0PmKsppwxR0AOqUmcsSrXUabuhsz4ApAwqfSaUCjOtgPcpW+SM54SGqHRECvXb2I7
         JRK0aKe+dFYpeQ/qwjrREhVi8Boh86oMwjzAezfncBRzjpy8+PQUGLW3TMmMuOUtaf9i
         cWDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UBAKnE8KUH0dKsvUsRf1caQt1pkMsYPo1KirROOGv/A=;
        b=HFdPRAEu0j/VlNjLUBYnN53MEIQ+hw5C9EkdbBZaQhf+5LD6wFm2xpts5okJGJFgxs
         MOPMlJ4HVFIJQoaFQxa4cP9g0cXfPJDEkfUz/RiK+Ry2s5ywg4+aOENOSlJ4KyNmpiaW
         m8z9er3m8GgdYvm9TKrD9UD3uD0N9HAyObM4Cw6noCyOr5/a+YtQOIo66JJVFESSo+h+
         24MhP2Q6zX4bZFlG0c3nyS5q7hNJRvRl54TQCQxcc9NubT2igo9wwuOO2ZTnJGV+0t0O
         we913L4MPNQ0JB3j+Amj4WbGIFQG7bRXmurfn/fVJdNP4A9Kyx5cVok5CbRWR7n0oMrT
         goIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id l16si6928456otn.154.2019.04.02.19.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 19:54:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [10.3.19.208])
	by Forcepoint Email with ESMTP id 3DFD7EFA4B81E6ED553E;
	Wed,  3 Apr 2019 10:54:42 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Wed, 3 Apr 2019 10:54:34 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<ard.biesheuvel@linaro.org>, <takahiro.akashi@linaro.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH 2/3] arm64: kdump: support more than one crash kernel regions
Date: Wed, 3 Apr 2019 11:05:45 +0800
Message-ID: <20190403030546.23718-3-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403030546.23718-1-chenzhou10@huawei.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.175.113.25]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

After commit (arm64: kdump: support reserving crashkernel above 4G),
there may be two crash kernel regions, one is below 4G, the other is
above 4G.

Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 12 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index ceb2a25..769c77a 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
+# define CRASH_MAX_USABLE_RANGES        2
+
 static int __init reserve_crashkernel_low(void)
 {
 	unsigned long long base, low_base = 0, low_size = 0;
@@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 		const char *uname, int depth, void *data)
 {
 	struct memblock_region *usablemem = data;
-	const __be32 *reg;
-	int len;
+	const __be32 *reg, *endp;
+	int len, nr = 0;
 
 	if (depth != 1 || strcmp(uname, "chosen") != 0)
 		return 0;
@@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+		if (++nr >= CRASH_MAX_USABLE_RANGES)
+			break;
+	}
 
 	return 1;
 }
 
 static void __init fdt_enforce_memory_region(void)
 {
-	struct memblock_region reg = {
-		.size = 0,
-	};
-
-	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
-
-	if (reg.size)
-		memblock_cap_memory_range(reg.base, reg.size);
+	int i, cnt = 0;
+	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
+
+	memset(regs, 0, sizeof(regs));
+	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
+
+	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
+		if (regs[i].size)
+			cnt++;
+		else
+			break;
+	if (cnt)
+		memblock_cap_memory_ranges(regs, cnt);
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 47e3c06..aeade34 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
+void memblock_cap_memory_ranges(struct memblock_region *regs, int cnt);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 bool memblock_is_map_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index 28fa8926..1a7f4ee7c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1697,6 +1697,46 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
 			base + size, PHYS_ADDR_MAX);
 }
 
+void __init memblock_cap_memory_ranges(struct memblock_region *regs, int cnt)
+{
+	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
+	int i, j, ret, nr = 0;
+
+	for (i = 0; i < cnt; i++) {
+		ret = memblock_isolate_range(&memblock.memory, regs[i].base,
+				regs[i].size, &start_rgn[i], &end_rgn[i]);
+		if (ret)
+			break;
+		nr++;
+	}
+	if (!nr)
+		return;
+
+	/* remove all the MAP regions */
+	for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
+		if (!memblock_is_nomap(&memblock.memory.regions[i]))
+			memblock_remove_region(&memblock.memory, i);
+
+	for (i = nr - 1; i > 0; i--)
+		for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
+			if (!memblock_is_nomap(&memblock.memory.regions[j]))
+				memblock_remove_region(&memblock.memory, j);
+
+	for (i = start_rgn[0] - 1; i >= 0; i--)
+		if (!memblock_is_nomap(&memblock.memory.regions[i]))
+			memblock_remove_region(&memblock.memory, i);
+
+	/* truncate the reserved regions */
+	memblock_remove_range(&memblock.reserved, 0, regs[0].base);
+
+	for (i = nr - 1; i > 0; i--)
+		memblock_remove_range(&memblock.reserved,
+				regs[i].base, regs[i - 1].base + regs[i - 1].size);
+
+	memblock_remove_range(&memblock.reserved,
+			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
+}
+
 void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 {
 	phys_addr_t max_addr;
-- 
2.7.4

