Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0649C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 942842238E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:53:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 942842238E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14C5E6B000E; Tue, 23 Jul 2019 01:53:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC426B000D; Tue, 23 Jul 2019 01:53:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8ECE6B0008; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7738E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:53:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so25400252pfk.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=6EWw24Yvhd9ee6OVfFoWsGLD54Y6AhwGzrLymy71djY=;
        b=qR7U5ikXTRJlh0/HHlltJZtzrw0EK32ZNsYhFxRuPTtIHipEPhfqz+XHk6eJMzBNmh
         m7LdZHf4zm/9neQgFcvPoV7U/y3KGxH497iBX0TcB3NCqFbl3kgCFGVnp9MqFFqpHeWL
         ZCuKMjD8oe+crEUBB8Caz8zYoXcpn5TTdhjVoeNQQvCi3+nZIQxonTWHK4asDAIka5Zp
         mf/wkufAuvRbfde3ZvdOaiWCkH3uyzl7AYQQjohxPk04/aoDMIUd5Y+2uJtnKZe5ebxo
         QSrh2Vd0Hy1tu9mQumuJHmKMOXF3KrrCoQLsQcQbOG8ggrQ+tI7j/KXS1KRWeuP7QFk8
         +34Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAUEsUUvR1RC0rmfMs5aQockxOKLF77BPI+OzIxKeh+c0Mjxl8ls
	CXwMTKW/Yumc9nWQtFdn76p+DzAnYCQMgOPRIxwKG59itDNXmYOlhF8aVKeQayVCk1syy8VNRKC
	AwDWpiSzdO+XXShX17QI8fg0ct/JJYBfYqWClZJ733CN5SF6n9OYYK1KKl2ypKFBNwQ==
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr51207016pjk.132.1563861232322;
        Mon, 22 Jul 2019 22:53:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8K/FKKqwvROJKmJzciDayNJfDncQLjrFmVx4Z7W476QTtqmWOv/JnwU658Bh+ia1VXYdM
X-Received: by 2002:a17:90a:7788:: with SMTP id v8mr51206952pjk.132.1563861231130;
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861231; cv=none;
        d=google.com; s=arc-20160816;
        b=USJU5SC8MHO9KrdsnCsH3JSr6EekD/ULSxR/KBpYyiACbswI032DssThHWTWMgxXUl
         DDAF6t5h5Qkl857PfscWc6ATMY715LLlZGJKmk9m3yFdxojsE5M2K5XV4blbEctkZWPc
         MuuOO+V6nzVzOk9jvphPDtlgB32Xnk1CDvIJJIH6k/S1yNXs8ytSZmtQyXp6C5Vq2GyY
         9M5wj+hQdlVyjvjKiRUbMqln32QcfJvuwLSsc4pHX/GH/Rwq/L9ch0kccmEk9X08Uqde
         GTXjx3OIqltLKpGVmoA+HlqtHJ0K2c62USWhh7FrhzW9J6guahG+hyFVHv51I/8QWeya
         xImw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=6EWw24Yvhd9ee6OVfFoWsGLD54Y6AhwGzrLymy71djY=;
        b=BmELkruGDJfDRavTI/f0txB7j2IqIvv0B3hFWYfeGtOGvFuvavc8lCAiq5F6rupERf
         ceMc8LuihK4rLVSwo0eMvoeX0N/kFI85qeid1tAXcVG9FdY30vV09ejFKLhA3GNodqmf
         fEU/SXzgsMPf+aZwQxoEsmE0eaTenn3Pno+iU022FZfWJRipvi+8F8iiCLE3PwC33sfg
         c2rrX0MUHtGF7rfEOaepP/EnBGA8Pyfxz6SH3heeTrLTN6kmAmj6EO4h75dAsMkQjK8o
         Ld+qYEYLBfvqzqZMC6Z4If8dl1YFBk9OzdCzs+kXZumsl48NReGOxiBTYUrhGjI0Hqzm
         M7Qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id o12si12344358pjp.72.2019.07.22.22.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id DB94EAB89D521717DF39;
	Tue, 23 Jul 2019 13:53:49 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.439.0; Tue, 23 Jul 2019 13:53:44 +0800
From: Hanjun Guo <guohanjun@huawei.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton
	<akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, "Jia
 He" <hejianet@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Will Deacon
	<will@kernel.org>
CC: <linux-arm-kernel@lists.infradead.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>
Subject: [PATCH v12 2/2] mm: page_alloc: reduce unnecessary binary search in memblock_next_valid_pfn
Date: Tue, 23 Jul 2019 13:51:13 +0800
Message-ID: <1563861073-47071-3-git-send-email-guohanjun@huawei.com>
X-Mailer: git-send-email 1.7.12.4
In-Reply-To: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
References: <1563861073-47071-1-git-send-email-guohanjun@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jia He <hejianet@gmail.com>

After skipping some invalid pfns in memmap_init_zone(), there is still
some room for improvement.

E.g. if pfn and pfn+1 are in the same memblock region, we can simply pfn++
instead of doing the binary search in memblock_next_valid_pfn.

Furthermore, if the pfn is in a gap of two memory region, skip to next
region directly to speedup the binary search.

Signed-off-by: Jia He <hejianet@gmail.com>
Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
---
 mm/memblock.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d57ba51bb9cd..95d5916716a0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1256,28 +1256,53 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 {
 	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
 	unsigned int right = type->cnt;
 	unsigned int mid, left = 0;
+	unsigned long start_pfn, end_pfn, next_start_pfn;
 	phys_addr_t addr = PFN_PHYS(++pfn);
+	static int early_region_idx __initdata_memblock = -1;
 
+	/* fast path, return pfn+1 if next pfn is in the same region */
+	if (early_region_idx != -1) {
+		start_pfn = PFN_DOWN(regions[early_region_idx].base);
+		end_pfn = PFN_DOWN(regions[early_region_idx].base +
+				regions[early_region_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return pfn;
+
+		/* try slow path */
+		if (++early_region_idx == type->cnt)
+			goto slow_path;
+
+		next_start_pfn = PFN_DOWN(regions[early_region_idx].base);
+
+		if (pfn >= end_pfn && pfn <= next_start_pfn)
+			return next_start_pfn;
+	}
+
+slow_path:
+	/* slow path, do the binary searching */
 	do {
 		mid = (right + left) / 2;
 
-		if (addr < type->regions[mid].base)
+		if (addr < regions[mid].base)
 			right = mid;
-		else if (addr >= (type->regions[mid].base +
-				  type->regions[mid].size))
+		else if (addr >= (regions[mid].base + regions[mid].size))
 			left = mid + 1;
 		else {
-			/* addr is within the region, so pfn is valid */
+			early_region_idx = mid;
 			return pfn;
 		}
 	} while (left < right);
 
 	if (right == type->cnt)
 		return -1UL;
-	else
-		return PHYS_PFN(type->regions[right].base);
+
+	early_region_idx = right;
+
+	return PHYS_PFN(regions[early_region_idx].base);
 }
 EXPORT_SYMBOL(memblock_next_valid_pfn);
 #endif /* CONFIG_HAVE_MEMBLOCK_PFN_VALID */
-- 
2.19.1

