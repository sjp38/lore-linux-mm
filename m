Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900FEC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FDB12147A
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:38:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FDB12147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA7BB6B000A; Mon,  8 Apr 2019 11:38:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2E9F6B000C; Mon,  8 Apr 2019 11:38:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF6826B000D; Mon,  8 Apr 2019 11:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 841966B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 11:38:57 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id l85so7054439vke.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 08:38:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=B2zQdtwjklDumVUu5gcZqByPiJgG72Kp5qgn10S2SP4=;
        b=P3BOzocZxnqTmTttbwE891X6YtcEcrYGfu6jNBew3i2Syq2NTGJ+UI8MH/MbC5oI32
         y0CHp5op/KFtSBeU5v5mD50kNQIdb+uRv8qCbzOsI0sUSR+x4GkgXqWtJcFP32SDc5G3
         O9ODSyN9xxeahZjxS5p9+Ycxr7ctCmjd5Ece7dhNJrFDLwnLTLcXoCJcfjyQZB9x0GIx
         fr5WqOGRint7PqA7stIEY8soZ6fk6D/vDfInpLpd7guWEYMaAunvBrDd+bL4hUItQ/Q3
         A/AgORpuNNF0LPKnD4K+XGJQ1mvlxw2TXK0TTh2OlKlRA7dVeOXmdtI0Dn+t0qQfkG71
         63xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAXMZhFCi2Gmx+Bb6m9iDkN8716ahoBM8w6JqY9hBDM7Il1AtpE1
	PlRIQ9PF1RR8ya+WP3QBOwEKsqJDZKe9wYW4UOOFwcA1V+sHdlG0jDd+PNq8FtZ3Nw9NB1HokS7
	Y3sBFNgkd1kmYVKD++lpM6nzsQMDjQhY/v1LQQFs8kxuU8mQU61FCxrDQ0UsuCR2rrA==
X-Received: by 2002:ab0:20a6:: with SMTP id y6mr14970842ual.98.1554737937214;
        Mon, 08 Apr 2019 08:38:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWxxzqcQvPInB2ANgYnwuP+se5c5AFsGyVBKaeR8izq6y1fo2sO99YwQr0TMK8KICeZ5f+
X-Received: by 2002:ab0:20a6:: with SMTP id y6mr14970797ual.98.1554737936339;
        Mon, 08 Apr 2019 08:38:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554737936; cv=none;
        d=google.com; s=arc-20160816;
        b=tsTefj+11sHPe5i4FEPNQP82psqSG5IJWX6zQiJgZNKftg3cXSg7rlzj6WfbNCbLIp
         SqjWVG+8FEzalPcj6tFaeNS6gNF8L4HJxDKryBYjigcz8Dif4LLhvldcn2UgMn551Z8z
         vEg/sn0j3hzcOL1jXNKkZdkT4dQwP3M36pIZ7Ni+kC8hZcWHm86UAtWjGlvLFdV24UiS
         9TbM6GHlhJP+FYjgq98hj8b9o1zpmVsWTz60eTP8oHRjJj31ZLkgs3+LUIpoMRW3d1sQ
         A3ORHrl9k6Q5ROXFjh90MqgZPCTcPYnlx51Q9eYifN8d8vGLrRyBe43UFh5X0Va55B1d
         4CgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=B2zQdtwjklDumVUu5gcZqByPiJgG72Kp5qgn10S2SP4=;
        b=ndrPvXG0pbRW8P7oScHtyRQuxU1VhPhQkob4Ff7o8h6ArHGYT/fNYE44BGPIcFPaES
         M4u5zn/iId3G5QOZJsCkHrrOD7erLL0aZwOaB+1Vskh6ydACTjzULCsaRk60JLQaUZ1O
         vnpw+Y+lcF0ZDUmtHa0AsT4xaTkdB4XsASNhZZJFjp6lyIRhbx6NPykjMj0y8sY1S36W
         BaA/x6kU1YKrs24axfemBSTEPdw5UtSqwr/pEJOXTIaCTMfCAMS4hX7pEiAaon7EHI6H
         FNZAJWSgRbBWy2BCrieagPwmpsVAq6jSsKFAVm0D/hMh3U+8njWkOizFEXZSWUOuqzrA
         9qlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id x25si5436290uar.209.2019.04.08.08.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 08:38:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 6796C636F9A6EFFFA345;
	Mon,  8 Apr 2019 23:38:49 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Mon, 8 Apr 2019
 23:38:42 +0800
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
To: Mike Rapoport <rppt@linux.ibm.com>
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
 <20190404144408.GA6433@rapoport-lnx>
 <783b8712-ddb1-a52b-81ee-0c6a216e5b7d@huawei.com>
 <4b188535-c12d-e05b-9154-2c2d580f903b@huawei.com>
 <20190408065711.GA8403@rapoport-lnx>
 <3fc772a2-292b-9c2a-465f-eabe86961dfd@huawei.com>
CC: <wangkefeng.wang@huawei.com>, <ard.biesheuvel@linaro.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<takahiro.akashi@linaro.org>, <akpm@linux-foundation.org>,
	<kexec@lists.infradead.org>, <linux-arm-kernel@lists.infradead.org>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <2aadfb89-4ac0-a9a9-e157-a23d686cb374@huawei.com>
Date: Mon, 8 Apr 2019 23:38:41 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <3fc772a2-292b-9c2a-465f-eabe86961dfd@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 2019/4/8 16:39, Chen Zhou wrote:

>>>
>>> Sorry, just ignore my previous reply, I got that wrong.
>>>
>>> I think it carefully, we can cap the memory range for [min(regs[*].start, max(regs[*].end)]
>>> firstly. But how to remove the middle ranges, we still can't use memblock_cap_memory_range()
>>> directly and the extra remove operation may be complex.
>>>
>>> For more than one regions, i think add a new memblock_cap_memory_ranges() may be better.
>>> Besides, memblock_cap_memory_ranges() is also applicable for one region.
>>>
>>> How about replace memblock_cap_memory_range() with memblock_cap_memory_ranges()?
>>
>> arm64 is the only user of both MEMBLOCK_NOMAP and memblock_cap_memory_range()
>> and I don't expect other architectures will use these interfaces.
>> It seems that capping the memory for arm64 crash kernel the way I've
>> suggested can be implemented in fdt_enforce_memory_region(). If we'd ever
>> need such functionality elsewhere or CRASH_MAX_USABLE_RANGES will need to
>> grow we'll rethink the solution.
> 
> Ok, i will implement that in fdt_enforce_memory_region() in next version.
> And we will support at most two crash kernel regions now.
> 
> Thanks,
> Chen Zhou
> 

I implement that in fdt_enforce_memory_region() simply as below.
You have a look at if it is the way you suggested.

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f9fa5f8..52bd69db 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;

 #ifdef CONFIG_KEXEC_CORE

+/* at most two crash kernel regions, low_region and high_region */
+#define CRASH_MAX_USABLE_RANGES        2
+#define LOW_REGION_IDX                 0
+#define HIGH_REGION_IDX                        1
+
 /*
  * reserve_crashkernel() - reserves memory for crash kernel
  *
@@ -296,8 +301,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
                const char *uname, int depth, void *data)
 {
        struct memblock_region *usablemem = data;
-       const __be32 *reg;
-       int len;
+       const __be32 *reg, *endp;
+       int len, nr = 0;

        if (depth != 1 || strcmp(uname, "chosen") != 0)
                return 0;
@@ -306,22 +311,62 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
        if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
                return 1;

-       usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
-       usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
+       endp = reg + (len / sizeof(__be32));
+       while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
+               usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
+               usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
+
+               if (++nr >= CRASH_MAX_USABLE_RANGES)
+                       break;
+       }

        return 1;
 }

 static void __init fdt_enforce_memory_region(void)
 {
-       struct memblock_region reg = {
-               .size = 0,
-       };
+       int i, cnt = 0;
+       struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
+
+       memset(regs, 0, sizeof(regs));
+       of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
+
+       for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
+               if (regs[i].size)
+                       cnt++;
+               else
+                       break;
+
+       if (cnt - 1 == LOW_REGION_IDX)
+               memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
+                               regs[LOW_REGION_IDX].size);
+       else if (cnt - 1 == HIGH_REGION_IDX) {
+               /*
+                * Two crash kernel regions, cap the memory range
+                * [regs[LOW_REGION_IDX].base, regs[HIGH_REGION_IDX].end]
+                * and then remove the memory range in the middle.
+                */
+               int start_rgn, end_rgn, i, ret;
+               phys_addr_t mid_base, mid_size;
+
+               mid_base = regs[LOW_REGION_IDX].base + regs[LOW_REGION_IDX].size;
+               mid_size = regs[HIGH_REGION_IDX].base - mid_base;
+               ret = memblock_isolate_range(&memblock.memory, mid_base, mid_size,
+                               &start_rgn, &end_rgn);

-       of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
+               if (ret)
+                       return;

-       if (reg.size)
-               memblock_cap_memory_range(reg.base, reg.size);
+               memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
+                               regs[HIGH_REGION_IDX].base - regs[LOW_REGION_IDX].base +
+                               regs[HIGH_REGION_IDX].size);
+               for (i = end_rgn - 1; i >= start_rgn; i--) {
+                       if (!memblock_is_nomap(&memblock.memory.regions[i]))
+                               memblock_remove_region(&memblock.memory, i);
+               }
+               memblock_remove_range(&memblock.reserved, mid_base,
+                               mid_base + mid_size);
+       }
 }

 void __init arm64_memblock_init(void)
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d8..787d252 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -110,9 +110,15 @@ void memblock_discard(void);

 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
                                   phys_addr_t size, phys_addr_t align);
+void memblock_remove_region(struct memblock_type *type, unsigned long r);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
+int memblock_isolate_range(struct memblock_type *type,
+                                       phys_addr_t base, phys_addr_t size,
+                                       int *start_rgn, int *end_rgn);
+int memblock_remove_range(struct memblock_type *type,
+                                       phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf..7130c3a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -357,7 +357,7 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
        return ret;
 }

-static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
+void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
 {
        type->total_size -= type->regions[r].size;
        memmove(&type->regions[r], &type->regions[r + 1],
@@ -724,7 +724,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
  * Return:
  * 0 on success, -errno on failure.
  */
-static int __init_memblock memblock_isolate_range(struct memblock_type *type,
+int __init_memblock memblock_isolate_range(struct memblock_type *type,
                                        phys_addr_t base, phys_addr_t size,
                                        int *start_rgn, int *end_rgn)
 {
@@ -784,7 +784,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
        return 0;
 }

-static int __init_memblock memblock_remove_range(struct memblock_type *type,
+int __init_memblock memblock_remove_range(struct memblock_type *type,
                                          phys_addr_t base, phys_addr_t size)
 {
        int start_rgn, end_rgn;


Thanks,
Chen Zhou



> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
> .
> 

