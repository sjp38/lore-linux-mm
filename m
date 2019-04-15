Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61FF4C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D07E20684
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D07E20684
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E83BC6B000A; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE0436B000C; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CABE86B000D; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A1A446B000A
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q25so8831083otf.6
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2HfS5mdi6OnZ8KWKOdyFVgV0F97qjf8nFM8nzbKXexw=;
        b=gwS2zp6RkyJQ0gcCgWxMeRgRE6KQYXonwMCKcavgo5jf+T4oQORo4iRxxpjlFEQ59o
         ub/slyv1xV0hM9oeLcvDFH6wxsjoSR1NiqvLCXXl4X+3CdtTc8Fl3HezxN9pSki9Xstn
         oLnpWaBqSee8xczDtao4kEChUUGQd87t1Qs1sa4FCETFXuaqdU9UULlt9BPF7O+UjLWN
         u+rgU1rSmPJ70v7a2ILUzAUTZP2k13uVfyjKXVCcZXtI95n7J4sJpQht1y8HM0PFikFq
         ANfEdPESnKMhpc9kDNZF2YEleESZOwSIaifcLg/U7ht/Rs0pp7uLfV3Vv0dRjgIK8yxC
         Gv5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAW5nZ3PN/hT7g908SUnnhksR4U4GifQs9dJDLqn/QBj646aXA0b
	dLBbyVDboPr6KBGeKFR41cqBvEjRDGXt2bmvg1a9neT8SHvtrz9N4Rlx20vxSkNqcdBMa/IZy8N
	oQaToRS+9vHvngHk/oY4de8GDJUr4poEweAwPWboTuO1iUq3rNgxIDgfT28dP478uvA==
X-Received: by 2002:a9d:6d05:: with SMTP id o5mr13951344otp.175.1555325230294;
        Mon, 15 Apr 2019 03:47:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTp6ZI+MrjcpruX1aZsKVlI8EwAeAUXw538rEENqNsGjiJRBrtR3Ec3/vC3/h4sA0hbMSt
X-Received: by 2002:a9d:6d05:: with SMTP id o5mr13951287otp.175.1555325229011;
        Mon, 15 Apr 2019 03:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555325229; cv=none;
        d=google.com; s=arc-20160816;
        b=FB2QGNcw8mB8yCTPxwzZQrAtbH5g/7vJxcLvS5jPtVyDHRLccOTFgL3VKdpI1QxrHf
         nRVs0v00OBtfLk3zWg8aoNZ8obWDD0EFNfDAZzl7/dKbSev3YbW+2JOhIZIWDlQPp9mM
         /mOilFqCMnxCwcSI4G6phTROd851Rf/3A/F36HyAaO6vxfK3SyPptM1b7fUjGRl2ebKg
         D+87IvLTdYKyQj5rc0xjmXrI7Pxhyzbl2PAZvmIMcK9uoP2DLGPurIac+/XilUmoRLHv
         4uDEVm1p5PgGRyaY0ILlIpw+GgqDWix7DZ3jT8PjqTDNDj5A3ZOYgynSFTOLcvLEiNrJ
         wEkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2HfS5mdi6OnZ8KWKOdyFVgV0F97qjf8nFM8nzbKXexw=;
        b=1Iv/z6mrsBMLXt1rtbl6vb1uYejnuyCHv1SEUD3Vx+LQSZZhWwMCkjqP2EPKiizIVw
         p1G1MGmgIBT6qKbVZrpu8Fky3xZ4T4+tB5aZr2qrnzA87nFzhg7Jsv2RxPrxeRwWwUDR
         j/pe6axKs/1HtuwQEDCQ3Yo+Je54zs6RkVnVrwcqJxRkL3AulL2BiVC+qe/rk/hT0e6F
         HcN1aJ+R4t5JclFSzVmSa9vaDqqH9AfOR7CpdOoAtrpX/EGvdEcDiwlHpn0NWEkKC+dn
         8YVXW8HFfXz4MxoA+igR/Mgd40tdBC3kkgmGGepc8yxgnjd3Eong5oU+634ugzEswGdy
         NJYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id t145si23361876oih.106.2019.04.15.03.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 8035E95E669BD9B289C4;
	Mon, 15 Apr 2019 18:47:03 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Mon, 15 Apr 2019 18:46:55 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v4 4/5] arm64: kdump: support more than one crash kernel regions
Date: Mon, 15 Apr 2019 18:57:24 +0800
Message-ID: <20190415105725.22088-5-chenzhou10@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190415105725.22088-1-chenzhou10@huawei.com>
References: <20190415105725.22088-1-chenzhou10@huawei.com>
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

After commit (arm64: kdump: support reserving crashkernel above 4G),
there may be two crash kernel regions, one is below 4G, the other is
above 4G. Use memblock_cap_memory_ranges() to support multiple crash
kernel regions.

Crash dump kernel reads more than one crash kernel regions via a dtb
property under node /chosen,
linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Besides, replace memblock_cap_memory_range() with
memblock_cap_memory_ranges().

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
 include/linux/memblock.h |  1 -
 mm/memblock.c            | 41 ++++++++++++-----------------------------
 3 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5dde73..921953d 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -52,6 +52,9 @@
 #include <asm/tlb.h>
 #include <asm/alternative.h>
 
+/* at most two crash kernel regions, low_region and high_region */
+#define CRASH_MAX_USABLE_RANGES	2
+
 /*
  * We need to be able to catch inadvertent references to memstart_addr
  * that occur (potentially in generic code) before arm64_memblock_init()
@@ -295,9 +298,9 @@ early_param("mem", early_mem);
 static int __init early_init_dt_scan_usablemem(unsigned long node,
 		const char *uname, int depth, void *data)
 {
-	struct memblock_region *usablemem = data;
-	const __be32 *reg;
-	int len;
+	struct memblock_type *usablemem = data;
+	const __be32 *reg, *endp;
+	int len, nr = 0;
 
 	if (depth != 1 || strcmp(uname, "chosen") != 0)
 		return 0;
@@ -306,22 +309,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		unsigned long base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		unsigned long size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+		if (memblock_add_range(usablemem, base, size, NUMA_NO_NODE,
+				       MEMBLOCK_NONE))
+			return 0;
+		if (++nr >= CRASH_MAX_USABLE_RANGES)
+			break;
+	}
 
 	return 1;
 }
 
 static void __init fdt_enforce_memory_region(void)
 {
-	struct memblock_region reg = {
-		.size = 0,
+	struct memblock_region usable_regions[CRASH_MAX_USABLE_RANGES];
+	struct memblock_type usablemem = {
+		.max = CRASH_MAX_USABLE_RANGES,
+		.regions = usable_regions,
 	};
 
-	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
+	of_scan_flat_dt(early_init_dt_scan_usablemem, &usablemem);
 
-	if (reg.size)
-		memblock_cap_memory_range(reg.base, reg.size);
+	if (usablemem.cnt)
+		memblock_cap_memory_ranges(&usablemem);
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 180877c..f04dfc1 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -445,7 +445,6 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
-void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
 void memblock_cap_memory_ranges(struct memblock_type *regions_to_keep);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index 9661807..9b5cef4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1669,34 +1669,6 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
 			      PHYS_ADDR_MAX);
 }
 
-void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
-{
-	int start_rgn, end_rgn;
-	int i, ret;
-
-	if (!size)
-		return;
-
-	ret = memblock_isolate_range(&memblock.memory, base, size,
-						&start_rgn, &end_rgn);
-	if (ret)
-		return;
-
-	/* remove all the MAP regions */
-	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
-
-	for (i = start_rgn - 1; i >= 0; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
-
-	/* truncate the reserved regions */
-	memblock_remove_range(&memblock.reserved, 0, base);
-	memblock_remove_range(&memblock.reserved,
-			base + size, PHYS_ADDR_MAX);
-}
-
 void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
 {
 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
@@ -1744,6 +1716,16 @@ void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
 
 void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 {
+	struct memblock_region rgn = {
+		.base = 0,
+	};
+
+	struct memblock_type region_to_keep = {
+		.cnt = 1,
+		.max = 1,
+		.regions = &rgn,
+	};
+
 	phys_addr_t max_addr;
 
 	if (!limit)
@@ -1755,7 +1737,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 	if (max_addr == PHYS_ADDR_MAX)
 		return;
 
-	memblock_cap_memory_range(0, max_addr);
+	region_to_keep.regions[0].size = max_addr;
+	memblock_cap_memory_ranges(&region_to_keep);
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
2.7.4

