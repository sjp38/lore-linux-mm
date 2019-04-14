Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E5B0C10F14
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 12:13:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEF2A218D3
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 12:13:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEF2A218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A35C6B0006; Sun, 14 Apr 2019 08:13:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5523A6B0008; Sun, 14 Apr 2019 08:13:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 445366B000A; Sun, 14 Apr 2019 08:13:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 22A826B0006
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:13:30 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id d2so10982215ybs.10
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 05:13:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/sc9vOX18YlqKfm790V6NiArrrHvfnAN1w8Ri0xFbwQ=;
        b=V+UVH40qG34eC48TPkq1Fmr6t3EkZI3Y0cpZVwZiy/l0LzdIQirhJkLcMAkWqBRgBO
         Av6u68EIsmx1rLDaLv973ti5HcuZy1JNOUbZykCgDlUKHAzg8u1wd0QbGshzRgirfXNV
         8Lwi4mwXgLW8jWXLrkm5+4tQ5Tul2JqPYlALk0EnRJH7LRf3RyStfAkGcKeeRfhxsJFN
         QzMLGJ6tlt+2xm2EjngVBNwjkW+rcXvWwjNklJ9cWRINbh2McA8isgpGLP/EPNupkCVn
         0LKfKROFMt2xn3ZpxmJqjof2bFUUwYKDpEkgYWQYcM+h/4BBbFJ2ZL5YJnCKz+a7BPhG
         w9rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWHC7ce9p/NbXQh4wnq1yg2j6U8SsgfipBBydRZD4QhGzZf+hPp
	qoNuX7qRQnX3G0NJwgNnOq80NjsLX80j1bTd/SrxkRqv6TNG6bIXgMovKLVXABPcu28/5iZCYfR
	DVTTrQFo4O702Z9fZn0x3FBaIJfF3fId6BjdhIeZqkvo6/Cqpj2oDuv3LfD96mi3tTA==
X-Received: by 2002:a25:3187:: with SMTP id x129mr56511610ybx.315.1555244009861;
        Sun, 14 Apr 2019 05:13:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp8lW+ZPX3MwzimVSZeQRe42GTrRgGfM/jQ4Pk57o+BTtCT23GWaVWUtyXS38rWmAxQrch
X-Received: by 2002:a25:3187:: with SMTP id x129mr56511547ybx.315.1555244009010;
        Sun, 14 Apr 2019 05:13:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555244009; cv=none;
        d=google.com; s=arc-20160816;
        b=oSzpb7d/cVuTBDWowbxPzWj3stsz6ETKmG1i/iizMUjOwaJFjweiikvosra+mfLuin
         xv8TZaeHplE4Q54WemcWW/VdOfxRV8CeMfWX2jfvb7JqWWY2vm9fTsqEfmOcEZb9anbY
         zM0uF8Cxlc/Cc4eAqQ0ohaBsw7YHdQ435NQdrBUkUINMctiMunbtg1xVmQ//ntcTaCkc
         csRJARfK6dkUJfyopzpHpZBv64Sarczgx+TNoHFvR5xRDD0filFxPw+fpH2uzgyFT9A8
         riE0XWrXaEkXChNOP4kb9tZHPhA3R5lxdqrl/f0lHTZhJZfT3tXXAzLLaAF8iRGZZfCA
         GkZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/sc9vOX18YlqKfm790V6NiArrrHvfnAN1w8Ri0xFbwQ=;
        b=Kgu4LxW9WxDxYcJTkFRxeIjPTmw2sCOwOXeL9eDy/ozw7V32GYE0AoxG7raOpHNfub
         El+yOg6O2Ybz/Ad/qIq561v652z/b/DQ4slnupjZDR8sDvjwt9c/ZOzcP05KxXODqcwI
         97BmYxcmtM6pLEdhDgZsQhJY7ZyfzD9hNiSL2o2QJJtOgf/OqAOd76Y00LMddBbpTAPF
         52dJotcke2miBYpW+aAj01i7hyd470OMseMDpnbHTW3joplMR5fsqSZR5YkOOjBzEIt6
         dm1HQsq7TFIF00pL5lU6REd60NhWqXlA2NxC4qaPrLZ/yVsBxTRlFC+DjiTFor8O01A0
         21pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b3si456366ybb.138.2019.04.14.05.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 05:13:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3EC9D0r006270
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:13:28 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ruwgeb43x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:13:27 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 14 Apr 2019 13:13:25 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 14 Apr 2019 13:13:19 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ECDItF53608470
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 14 Apr 2019 12:13:18 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C937B11C04C;
	Sun, 14 Apr 2019 12:13:18 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9CE4C11C04A;
	Sun, 14 Apr 2019 12:13:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun, 14 Apr 2019 12:13:17 +0000 (GMT)
Date: Sun, 14 Apr 2019 15:13:15 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
        horms@verge.net.au, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190409102819.121335-4-chenzhou10@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041412-4275-0000-0000-00000327A73C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041412-4276-0000-0000-00003836CE81
Message-Id: <20190414121315.GD20947@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-14_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904140091
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
> After commit (arm64: kdump: support reserving crashkernel above 4G),
> there may be two crash kernel regions, one is below 4G, the other is
> above 4G.
> 
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>

Somehow I've missed that previously, but how is this supposed to work on
EFI systems?
 
> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> ---
>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
>  include/linux/memblock.h |  6 +++++
>  mm/memblock.c            |  7 ++---
>  3 files changed, 66 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 3bebddf..0f18665 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
>  
>  #ifdef CONFIG_KEXEC_CORE
>  
> +/* at most two crash kernel regions, low_region and high_region */
> +#define CRASH_MAX_USABLE_RANGES	2
> +#define LOW_REGION_IDX			0
> +#define HIGH_REGION_IDX			1
> +
>  /*
>   * reserve_crashkernel() - reserves memory for crash kernel
>   *
> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
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
> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
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
> +
> +	if (cnt - 1 == LOW_REGION_IDX)
> +		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
> +				regs[LOW_REGION_IDX].size);
> +	else if (cnt - 1 == HIGH_REGION_IDX) {
> +		/*
> +		 * Two crash kernel regions, cap the memory range
> +		 * [regs[LOW_REGION_IDX].base, regs[HIGH_REGION_IDX].end]
> +		 * and then remove the memory range in the middle.
> +		 */
> +		int start_rgn, end_rgn, i, ret;
> +		phys_addr_t mid_base, mid_size;
> +
> +		mid_base = regs[LOW_REGION_IDX].base + regs[LOW_REGION_IDX].size;
> +		mid_size = regs[HIGH_REGION_IDX].base - mid_base;
> +		ret = memblock_isolate_range(&memblock.memory, mid_base,
> +				mid_size, &start_rgn, &end_rgn);
>  
> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> +		if (ret)
> +			return;
>  
> -	if (reg.size)
> -		memblock_cap_memory_range(reg.base, reg.size);
> +		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
> +				regs[HIGH_REGION_IDX].base -
> +				regs[LOW_REGION_IDX].base +
> +				regs[HIGH_REGION_IDX].size);
> +		for (i = end_rgn - 1; i >= start_rgn; i--) {
> +			if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +				memblock_remove_region(&memblock.memory, i);
> +		}
> +		memblock_remove_range(&memblock.reserved, mid_base,
> +				mid_base + mid_size);
> +	}
>  }
>  
>  void __init arm64_memblock_init(void)
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 294d5d8..787d252 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -110,9 +110,15 @@ void memblock_discard(void);
>  
>  phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
>  				   phys_addr_t size, phys_addr_t align);
> +void memblock_remove_region(struct memblock_type *type, unsigned long r);
>  void memblock_allow_resize(void);
>  int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
>  int memblock_add(phys_addr_t base, phys_addr_t size);
> +int memblock_isolate_range(struct memblock_type *type,
> +					phys_addr_t base, phys_addr_t size,
> +					int *start_rgn, int *end_rgn);
> +int memblock_remove_range(struct memblock_type *type,
> +					phys_addr_t base, phys_addr_t size);
>  int memblock_remove(phys_addr_t base, phys_addr_t size);
>  int memblock_free(phys_addr_t base, phys_addr_t size);
>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index e7665cf..1846e2d 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -357,7 +357,8 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
>  	return ret;
>  }
>  
> -static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
> +void __init_memblock memblock_remove_region(struct memblock_type *type,
> +					unsigned long r)
>  {
>  	type->total_size -= type->regions[r].size;
>  	memmove(&type->regions[r], &type->regions[r + 1],
> @@ -724,7 +725,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
>   * Return:
>   * 0 on success, -errno on failure.
>   */
> -static int __init_memblock memblock_isolate_range(struct memblock_type *type,
> +int __init_memblock memblock_isolate_range(struct memblock_type *type,
>  					phys_addr_t base, phys_addr_t size,
>  					int *start_rgn, int *end_rgn)
>  {
> @@ -784,7 +785,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
>  	return 0;
>  }
>  
> -static int __init_memblock memblock_remove_range(struct memblock_type *type,
> +int __init_memblock memblock_remove_range(struct memblock_type *type,
>  					  phys_addr_t base, phys_addr_t size)
>  {
>  	int start_rgn, end_rgn;
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

