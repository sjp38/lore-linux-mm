Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12AFFC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 04:55:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 975D020825
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 04:55:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 975D020825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD80C6B0003; Mon, 15 Apr 2019 00:55:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D87096B0006; Mon, 15 Apr 2019 00:55:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5DB06B0007; Mon, 15 Apr 2019 00:55:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 735D36B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 00:55:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o3so1418482edr.6
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 21:55:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Rm3KjdmG1YkCqDiS3Yb2YN6egSA3rxZOYlR2c+5PUCQ=;
        b=cJ2u4o4QLXriObMQfYXQPsgEFMyI198snBhdcrX29LkfU2mtFiIk91pt4mjJ1bNBOI
         2J4xcH13ruRPlEzWhxzTqO/fxJTA46kQ0AkBELM0C6tNb0k7D0xZIHO4eUvusLirYk6g
         EKylzH5pjB9N2WbNzi+/n1qbIxvryDfO/vGNqWDc5iKK70Cr8dAqC58t/p+DbeAGTW+1
         LBOKwkvViB9mtYkDKbVTTwCkev/rMOWZdiblTSWbQdQZSkV6ALnpt8h/2ag0bZgC0vjZ
         zjmqRfu5WJzy/2+TsDE/MOpW80ZVXdhs6FzxFC9Ram31bPtK8Ifcl1eQX9mT2CJ/hiiu
         VxuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWkhyCOXoXlgM37xbIEmn0855djFn2AczvqNXFjACzm3IFyJUuE
	K28Qq86aCkS9mAWaCb7NVgrPKAKFG3WDnB0EP0rTk5dE4I+T8itkzvmh+PneZZ+MEmLBY1FLFoo
	dFcjR72rhoZGhSM95PKr5PdVJH68O+2DsFvKnaZ9RzvV4ZqoVnR+pLvypBqZZPrFZ5w==
X-Received: by 2002:a05:6402:1359:: with SMTP id y25mr2726872edw.18.1555304132981;
        Sun, 14 Apr 2019 21:55:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1DrB2b8issGHEvLwP4SMtfEdRl5nA+cHT2Md/A6XRSyHcozEPi8eCW/6zXQucydimb5b0
X-Received: by 2002:a05:6402:1359:: with SMTP id y25mr2726809edw.18.1555304131858;
        Sun, 14 Apr 2019 21:55:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555304131; cv=none;
        d=google.com; s=arc-20160816;
        b=Ob+Mdz3glsq2/LfW7Ujo2icUFiumb+kdHJwLB0pagtW6q2FKUMuJvEDDS06d8mWwIX
         McyLmwvmh4WsIfPQSqFY2boNBALAdy37uAXASVLi0HMUL4msF8NVuCX7hzc06qIkbU7Y
         ayXB5yG+B1SViRbZP4e93YLIoUytbS1FfuhxBpjaVS5TU25FuJPzMx0o8jlz+ZAGri93
         LXV2+8s+Wus0CL+VsU+M93RaaXuN7OCM6JSmYItKhjlx1rry0YxnieSvhdZNdBAasn0i
         6NfsaeyEa8bNJDxmcrxds8gac3940B84C5SWcqWIKnBCj2kIvHXc2cR80agp/aYe0O0+
         UFIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Rm3KjdmG1YkCqDiS3Yb2YN6egSA3rxZOYlR2c+5PUCQ=;
        b=eG2Jwms1qoxjy58cjKwHSezdNo8u8OV2auIJ3XLkkcSMT7RK3q/OyBziPO5NHoYv+O
         cbAg5+HfqYXdA37eQtg1TWSeq7/GY4j3TC8v7GwVfaD3emSKKqEj8tHCq2RmBW7FpPGu
         80HpjJuJaNnP2vgUWNaKZUJit4CRvnqy252E4bmU2oBgSbpW2T7N44OS5U2zsnQT/F1T
         +FnPLhJTm+4fa34QevtaBi+G6g4+Dd+fsH2VItjML8IzSek2A2q8Isdhztkhb60ic/O9
         RT24xOOq219avFpdPEkynXPv6TbyK2EgOqzkT8xjK0NzpOqMk62ObhyDRMjk2cYDKwuv
         Q/Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s41si1686096eda.339.2019.04.14.21.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 21:55:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3F4nJIS058481
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 00:55:30 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rvdt3up6r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 00:55:29 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 15 Apr 2019 05:55:27 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 15 Apr 2019 05:55:22 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3F4tL3b52428994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 04:55:21 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8EB54A4051;
	Mon, 15 Apr 2019 04:55:21 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5F64AA4057;
	Mon, 15 Apr 2019 04:55:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 15 Apr 2019 04:55:20 +0000 (GMT)
Date: Mon, 15 Apr 2019 07:55:18 +0300
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
 <20190414121315.GD20947@rapoport-lnx>
 <b43e586c-219c-2911-c8c8-ba66ff7ce926@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b43e586c-219c-2911-c8c8-ba66ff7ce926@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041504-0028-0000-0000-00000360CBC8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041504-0029-0000-0000-0000241FFD0A
Message-Id: <20190415045518.GA6167@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-15_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904150032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 10:27:30AM +0800, Chen Zhou wrote:
> Hi Mike,
> 
> On 2019/4/14 20:13, Mike Rapoport wrote:
> > Hi,
> > 
> > On Tue, Apr 09, 2019 at 06:28:18PM +0800, Chen Zhou wrote:
> >> After commit (arm64: kdump: support reserving crashkernel above 4G),
> >> there may be two crash kernel regions, one is below 4G, the other is
> >> above 4G.
> >>
> >> Crash dump kernel reads more than one crash kernel regions via a dtb
> >> property under node /chosen,
> >> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
> > 
> > Somehow I've missed that previously, but how is this supposed to work on
> > EFI systems?
> 
> Whatever the way in which the systems work, there is FDT pointer(__fdt_pointer)
> in arm64 kernel and file /sys/firmware/fdt will be created in late_initcall.
> 
> Kexec-tools read and update file /sys/firmware/fdt in EFI systems to support kdump to
> boot capture kernel.
> 
> For supporting more than one crash kernel regions, kexec-tools make changes accordingly.
> Details are in below:
> http://lists.infradead.org/pipermail/kexec/2019-April/022792.html
 
Thanks for the clarification!

> Thanks,
> Chen Zhou
> 
> >  
> >> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> >> ---
> >>  arch/arm64/mm/init.c     | 66 ++++++++++++++++++++++++++++++++++++++++--------
> >>  include/linux/memblock.h |  6 +++++
> >>  mm/memblock.c            |  7 ++---
> >>  3 files changed, 66 insertions(+), 13 deletions(-)
> >>
> >> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> >> index 3bebddf..0f18665 100644
> >> --- a/arch/arm64/mm/init.c
> >> +++ b/arch/arm64/mm/init.c
> >> @@ -65,6 +65,11 @@ phys_addr_t arm64_dma_phys_limit __ro_after_init;
> >>  
> >>  #ifdef CONFIG_KEXEC_CORE
> >>  
> >> +/* at most two crash kernel regions, low_region and high_region */
> >> +#define CRASH_MAX_USABLE_RANGES	2
> >> +#define LOW_REGION_IDX			0
> >> +#define HIGH_REGION_IDX			1
> >> +
> >>  /*
> >>   * reserve_crashkernel() - reserves memory for crash kernel
> >>   *
> >> @@ -297,8 +302,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
> >>  		const char *uname, int depth, void *data)
> >>  {
> >>  	struct memblock_region *usablemem = data;
> >> -	const __be32 *reg;
> >> -	int len;
> >> +	const __be32 *reg, *endp;
> >> +	int len, nr = 0;
> >>  
> >>  	if (depth != 1 || strcmp(uname, "chosen") != 0)
> >>  		return 0;
> >> @@ -307,22 +312,63 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
> >>  	if (!reg || (len < (dt_root_addr_cells + dt_root_size_cells)))
> >>  		return 1;
> >>  
> >> -	usablemem->base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> >> -	usablemem->size = dt_mem_next_cell(dt_root_size_cells, &reg);
> >> +	endp = reg + (len / sizeof(__be32));
> >> +	while ((endp - reg) >= (dt_root_addr_cells + dt_root_size_cells)) {
> >> +		usablemem[nr].base = dt_mem_next_cell(dt_root_addr_cells, &reg);
> >> +		usablemem[nr].size = dt_mem_next_cell(dt_root_size_cells, &reg);
> >> +
> >> +		if (++nr >= CRASH_MAX_USABLE_RANGES)
> >> +			break;
> >> +	}
> >>  
> >>  	return 1;
> >>  }
> >>  
> >>  static void __init fdt_enforce_memory_region(void)
> >>  {
> >> -	struct memblock_region reg = {
> >> -		.size = 0,
> >> -	};
> >> +	int i, cnt = 0;
> >> +	struct memblock_region regs[CRASH_MAX_USABLE_RANGES];
> >> +
> >> +	memset(regs, 0, sizeof(regs));
> >> +	of_scan_flat_dt(early_init_dt_scan_usablemem, regs);
> >> +
> >> +	for (i = 0; i < CRASH_MAX_USABLE_RANGES; i++)
> >> +		if (regs[i].size)
> >> +			cnt++;
> >> +		else
> >> +			break;
> >> +
> >> +	if (cnt - 1 == LOW_REGION_IDX)
> >> +		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
> >> +				regs[LOW_REGION_IDX].size);
> >> +	else if (cnt - 1 == HIGH_REGION_IDX) {
> >> +		/*
> >> +		 * Two crash kernel regions, cap the memory range
> >> +		 * [regs[LOW_REGION_IDX].base, regs[HIGH_REGION_IDX].end]
> >> +		 * and then remove the memory range in the middle.
> >> +		 */
> >> +		int start_rgn, end_rgn, i, ret;
> >> +		phys_addr_t mid_base, mid_size;
> >> +
> >> +		mid_base = regs[LOW_REGION_IDX].base + regs[LOW_REGION_IDX].size;
> >> +		mid_size = regs[HIGH_REGION_IDX].base - mid_base;
> >> +		ret = memblock_isolate_range(&memblock.memory, mid_base,
> >> +				mid_size, &start_rgn, &end_rgn);
> >>  
> >> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> >> +		if (ret)
> >> +			return;
> >>  
> >> -	if (reg.size)
> >> -		memblock_cap_memory_range(reg.base, reg.size);
> >> +		memblock_cap_memory_range(regs[LOW_REGION_IDX].base,
> >> +				regs[HIGH_REGION_IDX].base -
> >> +				regs[LOW_REGION_IDX].base +
> >> +				regs[HIGH_REGION_IDX].size);
> >> +		for (i = end_rgn - 1; i >= start_rgn; i--) {
> >> +			if (!memblock_is_nomap(&memblock.memory.regions[i]))
> >> +				memblock_remove_region(&memblock.memory, i);
> >> +		}
> >> +		memblock_remove_range(&memblock.reserved, mid_base,
> >> +				mid_base + mid_size);
> >> +	}
> >>  }
> >>  
> >>  void __init arm64_memblock_init(void)
> >> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> >> index 294d5d8..787d252 100644
> >> --- a/include/linux/memblock.h
> >> +++ b/include/linux/memblock.h
> >> @@ -110,9 +110,15 @@ void memblock_discard(void);
> >>  
> >>  phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
> >>  				   phys_addr_t size, phys_addr_t align);
> >> +void memblock_remove_region(struct memblock_type *type, unsigned long r);
> >>  void memblock_allow_resize(void);
> >>  int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
> >>  int memblock_add(phys_addr_t base, phys_addr_t size);
> >> +int memblock_isolate_range(struct memblock_type *type,
> >> +					phys_addr_t base, phys_addr_t size,
> >> +					int *start_rgn, int *end_rgn);
> >> +int memblock_remove_range(struct memblock_type *type,
> >> +					phys_addr_t base, phys_addr_t size);
> >>  int memblock_remove(phys_addr_t base, phys_addr_t size);
> >>  int memblock_free(phys_addr_t base, phys_addr_t size);
> >>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
> >> diff --git a/mm/memblock.c b/mm/memblock.c
> >> index e7665cf..1846e2d 100644
> >> --- a/mm/memblock.c
> >> +++ b/mm/memblock.c
> >> @@ -357,7 +357,8 @@ phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
> >>  	return ret;
> >>  }
> >>  
> >> -static void __init_memblock memblock_remove_region(struct memblock_type *type, unsigned long r)
> >> +void __init_memblock memblock_remove_region(struct memblock_type *type,
> >> +					unsigned long r)
> >>  {
> >>  	type->total_size -= type->regions[r].size;
> >>  	memmove(&type->regions[r], &type->regions[r + 1],
> >> @@ -724,7 +725,7 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
> >>   * Return:
> >>   * 0 on success, -errno on failure.
> >>   */
> >> -static int __init_memblock memblock_isolate_range(struct memblock_type *type,
> >> +int __init_memblock memblock_isolate_range(struct memblock_type *type,
> >>  					phys_addr_t base, phys_addr_t size,
> >>  					int *start_rgn, int *end_rgn)
> >>  {
> >> @@ -784,7 +785,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
> >>  	return 0;
> >>  }
> >>  
> >> -static int __init_memblock memblock_remove_range(struct memblock_type *type,
> >> +int __init_memblock memblock_remove_range(struct memblock_type *type,
> >>  					  phys_addr_t base, phys_addr_t size)
> >>  {
> >>  	int start_rgn, end_rgn;
> >> -- 
> >> 2.7.4
> >>
> > 
> 

-- 
Sincerely yours,
Mike.

