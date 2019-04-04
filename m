Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B6D4C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:45:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48902206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:45:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48902206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6FF86B0007; Thu,  4 Apr 2019 10:45:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20736B0008; Thu,  4 Apr 2019 10:45:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B916B000A; Thu,  4 Apr 2019 10:45:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5646D6B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 10:45:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so1575629edd.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 07:45:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=SsxzbMjBnzNnK0NTB0YxUR6S5RL58sxFqW+F5UlzZrQ=;
        b=rr8U4ImUr/TWpcyvEMF6bvgnMMTNoagwgY6ERtogyP9KZBFmCUEZ/SIRcEUu3riXMA
         V4h4buWHT/yKsx4f512p5ym8FM5h2cK4x67IkmC0/R5SIm4ByZenaXmjgVo/PCO5Mw9J
         7FE0zvpQEsW0JY5KVKjVRDwB49ScuARlyqC83iMrdwRSZboFHfd/flbqZjGmJSiZL4YG
         kQreJgCvpWMKib3mKUNyKnO5QYAQhSFcNMw5xp+EsdfTZGWs3RABn3LdIbGNSmFFmPbC
         jeMN10iqcYsAI/3aHX5SBQ1N4Wtl08/sY43UrBZU36MQRmeiHcxG343aO06MqI2iF8TD
         P1Ww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWUhgMWQ3NPzJkUWYWC2KWTmWmn1D7NkPCaNPhmiRD6D8Z+kglt
	fR/0yFJ7KrnwE1NU/HFjQ4q5v5krqPIF8YjBZhw3R66rNjQyajToM4vhvK+Jf4UyuGix5FvHVqe
	jb3sybl72/1dqNfojJ6xYDsdnBfCwKobHpk2UKdmtsrSaYlB4irRi7E93p6m+dplWcg==
X-Received: by 2002:a17:906:4bc3:: with SMTP id x3mr3809316ejv.150.1554389140808;
        Thu, 04 Apr 2019 07:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxb+0Xt0W5tApMbIYZF9v8jwpYw6di8wAGiE/ODn3jXTCtXYseUgk5v2LI7u6M15MnGDgjj
X-Received: by 2002:a17:906:4bc3:: with SMTP id x3mr3809262ejv.150.1554389139730;
        Thu, 04 Apr 2019 07:45:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554389139; cv=none;
        d=google.com; s=arc-20160816;
        b=KxkO1daExbfZ9mlC/yPJ1Ghm2xN+Z6+HwQb7xi1FT+fayTzJA5oxFU7CNwKZR+FhnV
         QjnHcoI6vIw8umNOu3ziHuNSzQQR0qxu4zxRS4KLq2IZMLaDcXmCPTSDtSdu3sQYVOcu
         LIlau8iUw8yr+R4f0tuTsXbr99FZeLj3BD7VFssra6KYkuRASq0nHcI6SkynuierjnP2
         NEMlmvwXIoqawDyeB4z99hkgOU6QKu4jyrFSmuZUzRozsPUYkpeLNTqaT8wi5pDL1RKc
         y9INxuUcD6QxxMjBhOykAAm4cZ7Y6zrFwXJgbybjAEoORssV2xJo92g7hXxlE8iilI3C
         aRxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=SsxzbMjBnzNnK0NTB0YxUR6S5RL58sxFqW+F5UlzZrQ=;
        b=T6HwlTZAVkTWLdqkUBrAajO5rA+klmTgvYKjXWanH1Q6s7BX2Omz7DD/ryqZZ63yr0
         8+ow2OD4vH1suOGT3QuthhdjcxXAl1c/QcqfQpacP7VU9gOZzN9LpeKOtLDN7iyzOxF6
         tRWSOaOBFJVLRGSVdo7V+rQ1yAdDMk5amijcKtG9QqR21YqZEH7wlHiJYKpRWJ7Ir3EK
         UCjEEL6mGzlYUTZBO/eHEEXmQkdm7o37y2wRvpJ/CblvjMxENQ6c0qAFlAk7PEP6y0kw
         alUVq9usBk4YS8OW4wDLGT54cm1U/+L87E3t6laPSlYtZEE/LWpWGlgSs5/wlfVtiQe/
         NeUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w27si2541290edl.0.2019.04.04.07.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 07:45:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x34EjJVK106998
	for <linux-mm@kvack.org>; Thu, 4 Apr 2019 10:45:38 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rnjrevh71-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Apr 2019 10:45:32 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 4 Apr 2019 15:44:19 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 4 Apr 2019 15:44:14 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x34EiD9760031084
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 4 Apr 2019 14:44:13 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4C256A405C;
	Thu,  4 Apr 2019 14:44:13 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DE3F2A4054;
	Thu,  4 Apr 2019 14:44:11 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.215])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  4 Apr 2019 14:44:11 +0000 (GMT)
Date: Thu, 4 Apr 2019 17:44:09 +0300
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
 <20190403112929.GA7715@rapoport-lnx>
 <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f98a5559-3659-fb35-3765-15861e70a796@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19040414-0020-0000-0000-0000032C4832
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19040414-0021-0000-0000-0000217E5AC0
Message-Id: <20190404144408.GA6433@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904040095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 03, 2019 at 09:51:27PM +0800, Chen Zhou wrote:
> Hi Mike,
> 
> On 2019/4/3 19:29, Mike Rapoport wrote:
> > On Wed, Apr 03, 2019 at 11:05:45AM +0800, Chen Zhou wrote:
> >> After commit (arm64: kdump: support reserving crashkernel above 4G),
> >> there may be two crash kernel regions, one is below 4G, the other is
> >> above 4G.
> >>
> >> Crash dump kernel reads more than one crash kernel regions via a dtb
> >> property under node /chosen,
> >> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>
> >>
> >> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> >> ---
> >>  arch/arm64/mm/init.c     | 37 +++++++++++++++++++++++++------------
> >>  include/linux/memblock.h |  1 +
> >>  mm/memblock.c            | 40 ++++++++++++++++++++++++++++++++++++++++
> >>  3 files changed, 66 insertions(+), 12 deletions(-)
> >>
> >> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> >> index ceb2a25..769c77a 100644
> >> --- a/arch/arm64/mm/init.c
> >> +++ b/arch/arm64/mm/init.c
> >> @@ -64,6 +64,8 @@ EXPORT_SYMBOL(memstart_addr);
> >>  phys_addr_t arm64_dma_phys_limit __ro_after_init;
> >>  
> >>  #ifdef CONFIG_KEXEC_CORE
> >> +# define CRASH_MAX_USABLE_RANGES        2
> >> +
> >>  static int __init reserve_crashkernel_low(void)
> >>  {
> >>  	unsigned long long base, low_base = 0, low_size = 0;
> >> @@ -346,8 +348,8 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
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
> >> @@ -356,22 +358,33 @@ static int __init early_init_dt_scan_usablemem(unsigned long node,
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
> >> -
> >> -	of_scan_flat_dt(early_init_dt_scan_usablemem, &reg);
> >> -
> >> -	if (reg.size)
> >> -		memblock_cap_memory_range(reg.base, reg.size);
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
> >> +	if (cnt)
> >> +		memblock_cap_memory_ranges(regs, cnt);
> > 
> > Why not simply call memblock_cap_memory_range() for each region?
> 
> Function memblock_cap_memory_range() removes all memory type ranges except specified range.
> So if we call memblock_cap_memory_range() for each region simply, there will be no usable-memory
> on kdump capture kernel.

Thanks for the clarification.
I still think that memblock_cap_memory_ranges() is overly complex. 

How about doing something like this:

Cap the memory range for [min(regs[*].start, max(regs[*].end)] and then
removing the range in the middle?
 
> Thanks,
> Chen Zhou
> 
> > 
> >>  }
> >>  
> >>  void __init arm64_memblock_init(void)
> >> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> >> index 47e3c06..aeade34 100644
> >> --- a/include/linux/memblock.h
> >> +++ b/include/linux/memblock.h
> >> @@ -446,6 +446,7 @@ phys_addr_t memblock_start_of_DRAM(void);
> >>  phys_addr_t memblock_end_of_DRAM(void);
> >>  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> >>  void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
> >> +void memblock_cap_memory_ranges(struct memblock_region *regs, int cnt);
> >>  void memblock_mem_limit_remove_map(phys_addr_t limit);
> >>  bool memblock_is_memory(phys_addr_t addr);
> >>  bool memblock_is_map_memory(phys_addr_t addr);
> >> diff --git a/mm/memblock.c b/mm/memblock.c
> >> index 28fa8926..1a7f4ee7c 100644
> >> --- a/mm/memblock.c
> >> +++ b/mm/memblock.c
> >> @@ -1697,6 +1697,46 @@ void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> >>  			base + size, PHYS_ADDR_MAX);
> >>  }
> >>  
> >> +void __init memblock_cap_memory_ranges(struct memblock_region *regs, int cnt)
> >> +{
> >> +	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> >> +	int i, j, ret, nr = 0;
> >> +
> >> +	for (i = 0; i < cnt; i++) {
> >> +		ret = memblock_isolate_range(&memblock.memory, regs[i].base,
> >> +				regs[i].size, &start_rgn[i], &end_rgn[i]);
> >> +		if (ret)
> >> +			break;
> >> +		nr++;
> >> +	}
> >> +	if (!nr)
> >> +		return;
> >> +
> >> +	/* remove all the MAP regions */
> >> +	for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
> >> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> >> +			memblock_remove_region(&memblock.memory, i);
> >> +
> >> +	for (i = nr - 1; i > 0; i--)
> >> +		for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
> >> +			if (!memblock_is_nomap(&memblock.memory.regions[j]))
> >> +				memblock_remove_region(&memblock.memory, j);
> >> +
> >> +	for (i = start_rgn[0] - 1; i >= 0; i--)
> >> +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> >> +			memblock_remove_region(&memblock.memory, i);
> >> +
> >> +	/* truncate the reserved regions */
> >> +	memblock_remove_range(&memblock.reserved, 0, regs[0].base);
> >> +
> >> +	for (i = nr - 1; i > 0; i--)
> >> +		memblock_remove_range(&memblock.reserved,
> >> +				regs[i].base, regs[i - 1].base + regs[i - 1].size);
> >> +
> >> +	memblock_remove_range(&memblock.reserved,
> >> +			regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
> >> +}
> >> +
> >>  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> >>  {
> >>  	phys_addr_t max_addr;
> >> -- 
> >> 2.7.4
> >>
> > 
> 

-- 
Sincerely yours,
Mike.

