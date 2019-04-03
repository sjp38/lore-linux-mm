Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9571C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 11:29:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 936552082C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 11:29:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 936552082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4439F6B0008; Wed,  3 Apr 2019 07:29:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1736B000A; Wed,  3 Apr 2019 07:29:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E0E46B000C; Wed,  3 Apr 2019 07:29:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1B96B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 07:29:42 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id x66so12009696ywx.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 04:29:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=ScnfQ19nRYLkYJyHyTVUDeskaMIg/C34LR5U0n5IB+s=;
        b=LwwgiJcx3pRhKtjjrcbKZhBr4fKl3jTyCKRcFNRTBssveCpljTu3V+WloG+GHpiqOK
         jJPc9BJQJGQwOmjkrj+jF6ibRleGcV5U2dzMWRWj2XTyu4yADqrnnhQLjZ6xQQWXttsJ
         DEQTp2PkbmiURNKFrY1zuJXA3vq4car0yQo7TGVb/KyyjGsyajrtHnCtOFdnu9zOFtMC
         aGPQl/k80NN58rAfgE7sFIdW64xiIhtnTIotkkp/X8uUkJAsQAMOauGYDEtgaDfk+Win
         yAj0HNGE8fgX4icyDWVK5Q0dj8+IlZYMtXjmDeD53PtXiwpPCRUe9AyOSvYb4G2B8DVO
         v8zQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVb6zyasV0fBobXNTH/EAN5RXI3fIPlP0EU6ko8EPQV2k691uFt
	BaztoVeW/7HvNiVjDzJYH75sivY0xf/FI4OWNuOgC2P0rW7DxLX68DcEpeYf5o+wAmCNp/0tbul
	nyBe8k49hL56GQj+DB2Eu9N/Mja4Er7g7g8R39ZqFJjriz5sWis2i/q6qzgTv/ZWVAA==
X-Received: by 2002:a25:9804:: with SMTP id a4mr245975ybo.241.1554290981751;
        Wed, 03 Apr 2019 04:29:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXzAgFlvnuoz0+239ODz5MsCmAgRACqneiXy3du7byWe1imjlPeIOropgCFPLJMzE11mK3
X-Received: by 2002:a25:9804:: with SMTP id a4mr245926ybo.241.1554290980985;
        Wed, 03 Apr 2019 04:29:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554290980; cv=none;
        d=google.com; s=arc-20160816;
        b=FRHrP6f2cwOfsXLc8k7NG2e8zeuy/iA4+z/OkJiI89uaEQ4KerfaDPFrZNCXqFkcPG
         PCXeNbm1T3518i1egk7QSGvdj5I8NiJBjGSIvf+eWwlpwZ6OgSui7IYmbpxegR3SFnj/
         2AK0/XDP+eP+T6fFvWWQn6NRvgUC5NSLLhdj+bcELs1sQhrl4tJGlOytLnv18CZ5sk7G
         9UhxHgV18iAtPy9BFi6FF2rnyi8jG9PSE0uoabyGpQ0gYCpABudz3sj5aYAR0x9iBmP1
         TRmpvbNN4XeYhUdTpARB5rnqM7fL9LOaGtyvYkrTLYWENeLvTsFZWYE+vaSeI6thQffe
         c0nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=ScnfQ19nRYLkYJyHyTVUDeskaMIg/C34LR5U0n5IB+s=;
        b=cWtRo6FenssdDhEPmGAFE2GjBe1lmh7QZ/LYA4QvxYKQWWlb4nHWfDZk/3/0JLM2FK
         ugZOPP4kMkyMmUWqYPaIYsckJq0gCvEOwzoGG4R7AiQZFg18swu7C5NVfDGQ+cO8X3kI
         y1OzFz1HKrUZOe0QZksiucR34gr/acEbnKvi0KHDEno+Jkhxahusjwl2C4FFIseNwODX
         sJTfSHsZsfsy5jL5wW4zgg8Vj1iIgSh1qnNp8LvLLHs+QLpaUs4ZATeKrnJNF+UdgdAT
         ypuPOLnEgXjwvoWAlKImiPujUpaSXUjuGhuwp8TFJBNCiUJ6A4OPuKpPzeNJMwnnTm+x
         aFkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f187si9597222ybb.297.2019.04.03.04.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 04:29:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33BOlBK008944
	for <linux-mm@kvack.org>; Wed, 3 Apr 2019 07:29:40 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rmsyf5bma-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:29:39 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 3 Apr 2019 12:29:37 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 3 Apr 2019 12:29:33 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x33BTWsg61341696
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 3 Apr 2019 11:29:33 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D04B5A404D;
	Wed,  3 Apr 2019 11:29:32 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F26F4A4040;
	Wed,  3 Apr 2019 11:29:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  3 Apr 2019 11:29:31 +0000 (GMT)
Date: Wed, 3 Apr 2019 14:29:30 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
        ard.biesheuvel@linaro.org, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH 2/3] arm64: kdump: support more than one crash kernel
 regions
References: <20190403030546.23718-1-chenzhou10@huawei.com>
 <20190403030546.23718-3-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403030546.23718-3-chenzhou10@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19040311-0008-0000-0000-000002D5C88A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040311-0009-0000-0000-00002241D02C
Message-Id: <20190403112929.GA7715@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904030079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
> After commit (arm64: kdump: support reserving crashkernel above 4G),
> there may be two crash kernel regions, one is below 4G, the other is
> above 4G.
> 
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
> 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
>  include/linux/memblock.h |  1 +
>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 66 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index ceb2a25..769c77a 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
> +# define CRASH_MAX_USABLE_RANGES        2
> +
>  static int __init reserve_crashkernel_low(void)
>  {
>  	unsigned long long base, low_base = 0, low_size = 0;
> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>  		const char *uname, int depth, void *data)
>  {
>  	struct memblock_region *usablemem = data;
> -	const __be32 *reg;
> -	int len;
> +	const __be32 *reg, *endp;
> +	int len, nr = 0;
>  
>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
>  		return 0;
> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
>  		return 1;
>  
> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +	endp = reg + (len / sizeof(__be32));
> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +
> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
> +			break;
> +	}
>  
>  	return 1;
>  }
>  
>  static void __init fdt_enforce_memory_region(void)
>  {
> -	struct memblock_region reg = {
> -		.size = 0,
> -	};
> -
> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> -
> -	if (reg.size)
> -		memblock_cap_memory_range(reg.base, reg.size);
> +	int i, cnt = 0;
> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
> +
> +	memset(regs, 0, sizeof(regs));
> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
> +
> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
> +		if (regs[i].size)
> +			cnt++;
> +		else
> +			break;
> +	if (cnt)
> +		memblock_cap_memory_ranges(regs, cnt);

Why not simply call memblock_cap_memory_range() for each region?

>  }
>  
>  void __init arm64_memblock_init(void)
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 47e3c06..aeade34 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
>  phys_addr_t memblock_end_of_DRAM(void);
>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
>  void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
> +void memblock_cap_memory_ranges(struct memblock_region *regs, int cnt);
>  void memblock_mem_limit_remove_map(phys_addr_t limit);
>  bool memblock_is_memory(phys_addr_t addr);
>  bool memblock_is_map_memory(phys_addr_t addr);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 28fa8926..1a7f4ee7c 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1697,6 +1697,46 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
>  			base + size, PHYS_ADDR_MAX);
>  }
>  
> +void __init memblock_cap_memory_ranges(struct memblock_region *regs, int cnt)
> +{
> +	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> +	int i, j, ret, nr = 0;
> +
> +	for (i = 0; i < cnt; i++) {
> +		ret = memblock_isolate_range(&memblock.memory, regs[i].base,
> +				regs[i].size, &start_rgn[i], &end_rgn[i]);
> +		if (ret)
> +			break;
> +		nr++;
> +	}
> +	if (!nr)
> +		return;
> +
> +	/* remove all the MAP regions */
> +	for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +			memblock_remove_region(&memblock.memory, i);
> +
> +	for (i = nr - 1; i > 0; i--)
> +		for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
> +			if (!memblock_is_nomap(&memblock.memory.regions[j]))
> +				memblock_remove_region(&memblock.memory, j);
> +
> +	for (i = start_rgn[0] - 1; i >= 0; i--)
> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +			memblock_remove_region(&memblock.memory, i);
> +
> +	/* truncate the reserved regions */
> +	memblock_remove_range(&memblock.reserved, 0, regs[0].base);
> +
> +	for (i = nr - 1; i > 0; i--)
> +		memblock_remove_range(&memblock.reserved,
> +				regs[i].base, regs[i - 1].base + regs[i - 1].size);
> +
> +	memblock_remove_range(&memblock.reserved,
> +			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
> +}
> +
>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
>  {
>  	phys_addr_t max_addr;
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

