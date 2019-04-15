Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DB35C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5DB32087C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 10:47:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5DB32087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 647716B0008; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 580C36B000A; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 494D76B000C; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21E856B0008
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 06:47:10 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id w10so7734396oie.1
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 03:47:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xXTptsneB+kP0gcjLWhElHF2YJCjnVugAtGJoCyGJpk=;
        b=PZVfrKuOO+bzzGp1sPTvv3aPAtQ1EXX5FmHqeYQAdeIwWeLR/+wBFDmvAH3ZJd9BRy
         HBaK6EakDhSqsB2sONgWI/CGcZjx79ol7LB3OSYTydc9QEEYNlr4C1vpLQM4vtryANxL
         yTz783AOP+M4YEG9A7bm6M3sJ4YTAb7qqS7uHeAo3FMFFOyae7F987DB1rInYcsEbPN4
         1+1E8n06E6Md3vBxOz2+JkY6dTQrPhGpiuXLfJY/1LcyIlMSlP4nPSEB32usi1XsDPVx
         tBREfkkmLNPD01QZokkdZgHIvrx5KVgtLVrqSANzZ+754fN0pLfpZSsO730URH46NLcY
         EUKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUjCd+yDakZVkEVWH2i8qO+cVpoJSSz5hs6FC6qwRHXcx6IFu8a
	cssy/UcHyRDwfRhFdxcIVxsoBsfMG3cvZwSL6grhF5RJSK14K1LxiIsq7HsiWSJa7lG7jaNrunu
	ZJh+GI/e43gsjpP2ebP7Mibk3ZJt6xzjj2lgMOi2AQ02cOnoCbJrEim1y5gIYrAPHcA==
X-Received: by 2002:aca:5842:: with SMTP id m63mr19791607oib.10.1555325229802;
        Mon, 15 Apr 2019 03:47:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybcYWBEcZFJbNWrGqUHxbeobWuM1IjEhz2pHhr/OGMjIXegvxvFJN4iOFL7rv5RaF2RF8J
X-Received: by 2002:aca:5842:: with SMTP id m63mr19791576oib.10.1555325228949;
        Mon, 15 Apr 2019 03:47:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555325228; cv=none;
        d=google.com; s=arc-20160816;
        b=oBK5k1ct24LwdaOLvu6nzTHQt9h9lg4ujvEb5/ACeLLWDpSGuQ7OJYDBAHHylgKLex
         HbQW0JOp8a/sjqoezy/bTvjdTlSnwDdPsC2KUGSRJpivFR59GPeROmaEscpeMQpaZqPB
         g+iFr3GEiftN/dLeTDZu9utNO2CW68qEuO0ZVlbVSLUPnHonQ1GBV1CJlX2GyZOS3Agv
         P6WHL8Sb7u7+CSde0DDpHfBFqAOo7inWDa7nQLfbKjLHGwFxxpT7HUCuGjccN5HxJDkw
         dmlTYiN4lObBSb4cGheagbW0hv0hZORjCOuEuMxItwg98jirlZIo2W97oR0+A3hHBbyR
         bopA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xXTptsneB+kP0gcjLWhElHF2YJCjnVugAtGJoCyGJpk=;
        b=kijTT6YYm1Am7xDebV4W2Jis8VEuuxw9Bm32k90G6nlH5PM0lrKDbKqQTvMhqNlQu0
         8kx9Kxreez4WkvbWcQ8dqwnnaC4JnjzA59lBJ9uA8manKH1DHwzKA7ZtKizNVptA4Jx2
         0mqCm/vj95e7S2UcyQcb9tOZl+U0IpY4SfuuXacMyHFfpMEq3UOIyWlExIFaaTIUF+mc
         WIl3h6FmT8TPKx+TawG/gnrj98xAUcEUFfwZVKUaBx2SdqQ/rspM31mzDKhTocK6JfKY
         vvlvD/L1drQ0AYGceLESlErbePt1jffSIhCmm8mKqzLhk7zojJS9TwE/LrqdFesGKOKV
         xW4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id z6si22469128oto.251.2019.04.15.03.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 03:47:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 75C8BB19C81F804D5FBC;
	Mon, 15 Apr 2019 18:47:03 +0800 (CST)
Received: from localhost.localdomain.localdomain (10.175.113.25) by
 DGGEMS408-HUB.china.huawei.com (10.3.19.208) with Microsoft SMTP Server id
 14.3.408.0; Mon, 15 Apr 2019 18:46:53 +0800
From: Chen Zhou <chenzhou10@huawei.com>
To: <tglx@linutronix.de>, <mingo@redhat.com>, <bp@alien8.de>,
	<ebiederm@xmission.com>, <rppt@linux.ibm.com>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <akpm@linux-foundation.org>,
	<ard.biesheuvel@linaro.org>
CC: <horms@verge.net.au>, <takahiro.akashi@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-kernel@vger.kernel.org>,
	<kexec@lists.infradead.org>, <linux-mm@kvack.org>,
	<wangkefeng.wang@huawei.com>, Chen Zhou <chenzhou10@huawei.com>
Subject: [PATCH v4 3/5] memblock: add memblock_cap_memory_ranges for multiple ranges
Date: Mon, 15 Apr 2019 18:57:23 +0800
Message-ID: <20190415105725.22088-4-chenzhou10@huawei.com>
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

The memblock_cap_memory_range() removes all the memory except the
range passed to it. Extend this function to receive memblock_type
with the regions that should be kept.

Enable this function in arm64 for reservation of multiple regions
for the crash kernel.

Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 47e3c06..180877c 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
+void memblock_cap_memory_ranges(struct memblock_type *regions_to_keep);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
 bool memblock_is_memory(phys_addr_t addr);
 bool memblock_is_map_memory(phys_addr_t addr);
diff --git a/mm/memblock.c b/mm/memblock.c
index f315eca..9661807 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1697,6 +1697,51 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
 			base + size, PHYS_ADDR_MAX);
 }
 
+void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
+{
+	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
+	int i, j, ret, nr = 0;
+	struct memblock_region *regs = regions_to_keep->regions;
+
+	for (i = 0; i < regions_to_keep->cnt; i++) {
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
+	for (i = nr - 1; i > 0; i--) {
+		phys_addr_t remove_base = regs[i - 1].base + regs[i - 1].size;
+		phys_addr_t remove_size = regs[i].base - remove_base;
+
+		memblock_remove_range(&memblock.reserved, remove_base,
+				remove_size);
+	}
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

