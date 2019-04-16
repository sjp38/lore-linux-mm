Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 904D3C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DCBC20821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:25:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DCBC20821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AD936B000A; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 632216B000D; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45D4C6B0010; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE9A6B000A
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:25:06 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q15so10539830otl.8
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:25:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ewUYorVIChjnXmYEdq4ua4ZywsVGY6/UWoRBagLdmsc=;
        b=CFv3nJkAMigLlkOBlNDKsFSb5vY2hbOnjxhuNHhqhe69YCzkhwGZdBjxnpMnmClK3g
         4RJBuX/LeDuaVaKiwSWihWS2Lt6Ae1N/4qN+POSsV8tHihwaGylH9piXEAdVCHqCKbZW
         BJXRzhR8+D5QhHdLs/YDbr6cb3MWxsJnIoudCGAoHUfhjFl9742nCZ9qjqf2AiQP0sGK
         p3zU7TZaEaf5j2VcYgFhH/FtgTkvK5Gq+4P+6rZA3lHJjXsILmXFJ/E4FtZLi2WPkE5U
         GhIHWvrHKTgBvi8MqoYc0s2jQg5LZ+oYAk3ENNEySH2y9/2iyK1kG8sbbc9MTCn07FKU
         XCxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAWTlv/B8KsFtU98xXfqYOJUUPVlG6/NNVWxBtyUxd4gxZ8WiHBw
	71dD5FZXBp/72Bfud9P8RP0qiwAKC3p5wACoixTsbdrTeXmmXnGrr/1sx4rQ5855botewCBog2p
	4sMfYqEn3vge6hFutUP8xQm+QBy97BlkfPMzUhtLSOl+ue6eP+ne/tQYu1Azocp3t+Q==
X-Received: by 2002:aca:ad82:: with SMTP id w124mr23845547oie.33.1555413905665;
        Tue, 16 Apr 2019 04:25:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuRza2vFqO8SedRcKoMC4A70X6oy0R6OP2nbZ9NW61LbMC37+7zNrlxDx6qHedyPM7we7E
X-Received: by 2002:aca:ad82:: with SMTP id w124mr23845518oie.33.1555413904798;
        Tue, 16 Apr 2019 04:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555413904; cv=none;
        d=google.com; s=arc-20160816;
        b=zGf6pOeiWOC6pKBwQGRXkOJPA9d1+fLNY19+liu5RR9FsQqIQXy18ZBeQFfCJUd9br
         srIT/6HJgJsrXl/xvDIO+X2JcYmdK7qiBL/dl8nDJdkWil+N+BjSKPZ0X7T5LK4Xs+p9
         woUIkfiRcN4MvfSG+OphBMIebjLiuM3xse+eb7fVdG2HAQzR3UtUtf1HB5V8SAR/mIYj
         CmPPEE0i0KiljjmZNZ6nTrKWFOfXwxtJKdztdTc6HHFQPjRydgGRufjGRrlOiJ7XWzAK
         uXhyQUZR+4wRI7il9/WjhuAEhtqef94ESAADH2pXAtjU2qnM/plPwDSPXF37cybFy2yR
         ztoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ewUYorVIChjnXmYEdq4ua4ZywsVGY6/UWoRBagLdmsc=;
        b=YHoZLZwU/j2SVX5uS7Tt1QC/HhZSGABl47HbwtrMCCG2RQgrkC8D0cKF4D5+LQ7/ph
         LSOMX/CyL9mBlFYXnMMH+Jnts48jwIwBKF0kSxpGjIlq+HCHfnSSYcMKPSAX3bXu3sUI
         H/x+xA1yOBonp5rZIjfn3lFPyLsjieCtkvhhdPZRTJXkL034g6WjAqfBv43YUTgc9sDf
         O/KN6aiD3otn60RqRZwnds5wW60ql77K6SkvRBr8626Y/FHStUbT35JQT4A2xprs5fuS
         EXfD3zminAbY27vQJu8m8qEStlW/UnvoTkV5Z2iY0NrlILdZfitAzIfHpD7AV3Syu/+o
         TPRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id n187si24869230oib.51.2019.04.16.04.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 04:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 7063E3072191F166EEC8;
	Tue, 16 Apr 2019 19:24:59 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Tue, 16 Apr 2019 19:24:51 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Chen
 Zhou" <chenzhou10@huawei.com>
Subject: [RESEND PATCH v5 3/4] memblock: extend memblock_cap_memory_range to multiple ranges
Date: Tue, 16 Apr 2019 19:35:18 +0800
Message-ID: <20190416113519.90507-4-chenzhou10@huawei.com>
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

From: Mike Rapoport <rppt@linux.ibm.com>

The memblock_cap_memory_range() removes all the memory except the
range passed to it. Extend this function to receive an array of
memblock_regions that should be kept. This allows switching to
simple iteration over memblock arrays with 'for_each_mem_range_rev'
to remove the unneeded memory.

Enable use of this function in arm64 for reservation of multiple
regions for the crash kernel.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
---
 arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
 include/linux/memblock.h |  2 +-
 mm/memblock.c            | 44 ++++++++++++++++++++------------------------
 3 files changed, 45 insertions(+), 35 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5dde73..7f999bf 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -64,6 +64,10 @@ EXPORT_SYMBOL(memstart_addr);
 phys_addr_t arm64_dma_phys_limit __ro_after_init;
 
 #ifdef CONFIG_KEXEC_CORE
+
+/* at most two crash kernel regions, low_region and high_region */
+#define CRASH_MAX_USABLE_RANGES	2
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -295,9 +299,9 @@ early_param("mem", early_mem);
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
@@ -306,22 +310,32 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
 	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
 		return 1;
 
-	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+	endp = reg + (len / sizeof(__be32));
+	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+		unsigned long base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+		unsigned long size = dt_mem_next_cell(dt_root_size_cells, &reg);
 
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
+		memblock_cap_memory_ranges(usablemem.regions, usablemem.cnt);
 }
 
 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 47e3c06..e490a73 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -445,7 +445,7 @@ phys_addr_t memblock_mem_size(unsigned long limit_pfn);
 phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
-void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
+void memblock_cap_memory_ranges(struct memblock_region *regions, int count);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 bool memblock_is_map_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index f315eca..08581b1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1669,36 +1669,31 @@ void __init memblock_enforce_memory_limit(phys_addr_t limit)
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
+void __init memblock_cap_memory_ranges(struct memblock_region *regions,
+				       int count)
+{
+	struct memblock_type regions_to_keep = {
+		.max = count,
+		.cnt = count,
+		.regions = regions,
+	};
+	phys_addr_t start, end;
+	u64 i;
 
-	for (i = start_rgn - 1; i >= 0; i--)
-		if (!memblock_is_nomap(&memblock.memory.regions[i]))
-			memblock_remove_region(&memblock.memory, i);
+	/* truncate memory while skipping NOMAP regions */
+	for_each_mem_range_rev(i, &memblock.memory, &regions_to_keep,
+			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove(start, end - start);
 
 	/* truncate the reserved regions */
-	memblock_remove_range(&memblock.reserved, 0, base);
-	memblock_remove_range(&memblock.reserved,
-			base + size, PHYS_ADDR_MAX);
+	for_each_mem_range_rev(i, &memblock.reserved, &regions_to_keep,
+			       NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL)
+		memblock_remove_range(&memblock.reserved, start, end - start);
 }
 
 void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 {
+	struct memblock_region region = { 0 };
 	phys_addr_t max_addr;
 
 	if (!limit)
@@ -1710,7 +1705,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 	if (max_addr == PHYS_ADDR_MAX)
 		return;
 
-	memblock_cap_memory_range(0, max_addr);
+	region.size = max_addr;
+	memblock_cap_memory_ranges(&region, 1);
 }
 
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
-- 
2.7.4

