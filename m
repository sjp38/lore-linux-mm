Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D0A5C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 12:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6F7A2084E
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 12:11:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6F7A2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186356B0003; Sun, 14 Apr 2019 08:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E2A6B0005; Sun, 14 Apr 2019 08:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DDB6B0006; Sun, 14 Apr 2019 08:11:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D25876B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:11:11 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id b137so10943185yba.18
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 05:11:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=CgYFChcB40/asR1EHlC2CsIH/NefD407MdpEj/2bfg8=;
        b=YHPFOQVOK1OnN4nVEW5fgeprZ99YXeNpKCqNbS6m9D9QqbEwCAr6Ai4kFFQ0PlMMg/
         TmB9etPkD8XPHLXjrYVjk42u6/BqRd+nspp6jZv1UlpIQg/JIHWCy3R8flgvTyXNBWRS
         73Pp/Fvt2tfbWo7HFT9DywgBnX9P5A9l/WE8VjzlxlHFkI5u0OiOBymvPnRKkje3poBn
         ZNBVGWAO6YY/mJ8grTUAOlqRDQtZezj183Msb+LOOR+QAwJkKq6U46oaaWH+OvYVyq2w
         gtnOWD3YQEULfKO48YefDsJ2YUMpcaZnhKSpcCrpa+WhdIS88eZ4dt9LdNaRWAevAzIa
         9ZaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWNjTQPglFpz8cSm4uK4vAb5Uk5KfftaKNMHkhdw8WZhMEZk6ku
	pDQuwd7xcMS3IS1Hhfcr9zTaJWSqyMaWjA2dzjPlCNgoJTKOB9Ipp5F2aT5p3co7mIXt6Xw4CCC
	x1a9lkmZXHwqvviRAxLCiVlYK7NBIvUgOy9Rvw5rDbyeWURUsHeY0ODIJYcCs0X3kDg==
X-Received: by 2002:a81:2396:: with SMTP id j144mr53660839ywj.458.1555243871576;
        Sun, 14 Apr 2019 05:11:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyof6vS1Zn0tyZJ+8qBscWbIWgEjTWba21nd55kgv41S+1RQ7VMqzPu0Tz+IyYSbyz+U26m
X-Received: by 2002:a81:2396:: with SMTP id j144mr53660763ywj.458.1555243870485;
        Sun, 14 Apr 2019 05:11:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555243870; cv=none;
        d=google.com; s=arc-20160816;
        b=sqUCWV/hm9FSzBorbeHLY1XpTk5Em4+lXAw2Q/YSxpHEHHvbKYS+d54cw+3qxjsCE7
         W5qL7cTvLi9dwjz8V6nSTZaBYwAkdTRGjDGMOrnCaStxZO+Z4flUxwm8JKTGwlB/j7xt
         3B1xSbjwQ1WSAKnlMIjtGGBsXiegcTorRAcyczb2MCrZftY8RgHvJJ1DAl6q5xp9uutI
         OhAmozev9WGOuBDKSDgf+VEnMWmug2PlJhuledbRYjA1r3lDm90vSEiLxFWqy+4JKmiS
         GRmTyDE3ys0mCd+yvkw4XvWr9vvloRsYm7UAAElLlegh/dETiHhwjv2JvVPhh8kZb3Fz
         ElRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=CgYFChcB40/asR1EHlC2CsIH/NefD407MdpEj/2bfg8=;
        b=xVCHfDjkunB2EJYXtOGsIOmTLQQyWK7fpuObQsxv1fzfrka/ICWvoGs6xKDcA1e3FX
         W0d3W2HYNHbEfxGZNpUybspvd5BadsBaipJI6uz9OE/PRbIZIxYye5ZQfrbmQiWhNg9C
         VwHwtbX0eDt+kdUzpBs1hnvL++d0Z/u7fWZYtqnUwOOkhVIDRCJk9kMAKbrciDwxKp8R
         ZYj2kOJaD2mKoX5Oy/iuHFw/P3e31F0gGFMXqAqYTQDQQGTD43UAcarFv0YbVC26hP4r
         mmnl86kIql5zB/wRzcxJarhwgsuXwDAohnlLsodhKGrxLaqoPaKYyh+h2y3isky8/9dK
         jn3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v193si30291868ywa.351.2019.04.14.05.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 05:11:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3EC9EMB191528
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:11:10 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ruw9v3mej-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 08:11:09 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 14 Apr 2019 13:11:07 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 14 Apr 2019 13:11:03 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ECB2gX52822038
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 14 Apr 2019 12:11:02 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A9C25204F;
	Sun, 14 Apr 2019 12:11:02 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 0167C52051;
	Sun, 14 Apr 2019 12:11:00 +0000 (GMT)
Date: Sun, 14 Apr 2019 15:10:59 +0300
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
 <20190410130917.GC17196@rapoport-lnx>
 <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041412-0008-0000-0000-000002D9A1AB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041412-0009-0000-0000-00002245D2D0
Message-Id: <20190414121058.GC20947@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-14_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904140091
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Apr 11, 2019 at 08:17:43PM +0800, Chen Zhou wrote:
> Hi Mike,
> 
> This overall looks well.
> Replacing memblock_cap_memory_range() with memblock_cap_memory_ranges() was what i wanted
> to do in v1, sorry for don't express that clearly.

I didn't object to memblock_cap_memory_ranges() in general, I was worried
about it's complexity and I hoped that we could find a simpler solution.
 
> But there are some issues as below. After fixing this, it can work correctly.
> 
> On 2019/4/10 21:09, Mike Rapoport wrote:
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
> >>
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
> > 
> > I only now noticed that fdt_enforce_memory_region() uses memblock_region to
> > pass the ranges around. If we'd switch to memblock_type instead, the
> > implementation of memblock_cap_memory_ranges() would be really
> > straightforward. Can you check if the below patch works for you? 
> > 
> >>From e476d584098e31273af573e1a78e308880c5cf28 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.ibm.com>
> > Date: Wed, 10 Apr 2019 16:02:32 +0300
> > Subject: [PATCH] memblock: extend memblock_cap_memory_range to multiple ranges
> > 
> > The memblock_cap_memory_range() removes all the memory except the range
> > passed to it. Extend this function to recieve memblock_type with the
> > regions that should be kept. This allows switching to simple iteration over
> > memblock arrays with 'for_each_mem_range' to remove the unneeded memory.
> > 
> > Enable use of this function in arm64 for reservation of multile regions for
> > the crash kernel.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  arch/arm64/mm/init.c     | 34 ++++++++++++++++++++++++----------
> >  include/linux/memblock.h |  2 +-
> >  mm/memblock.c            | 45 ++++++++++++++++++++++-----------------------
> >  3 files changed, 47 insertions(+), 34 deletions(-)
> > 
> >  
> > -void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> > +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
> >  {
> > -	int start_rgn, end_rgn;
> > -	int i, ret;
> > -
> > -	if (!size)
> > -		return;
> > -
> > -	ret = memblock_isolate_range(&memblock.memory, base, size,
> > -						&start_rgn, &end_rgn);
> > -	if (ret)
> > -		return;
> > -
> > -	/* remove all the MAP regions */
> > -	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> > -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> > -			memblock_remove_region(&memblock.memory, i);
> > +	phys_addr_t start, end;
> > +	u64 i;
> >  
> > -	for (i = start_rgn - 1; i >= 0; i--)
> > -		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> > -			memblock_remove_region(&memblock.memory, i);
> > +	/* truncate memory while skipping NOMAP regions */
> > +	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
> > +			   MEMBLOCK_NONE, &start, &end, NULL)
> > +		memblock_remove(start, end);
> 
> 1. use memblock_remove(start, size) instead of memblock_remove(start, end).
> 
> 2. There is a another hidden issue. We couldn't mix __next_mem_range()(called by for_each_mem_range) operation
> with remove operation because __next_mem_range() records the index of last time. If we do remove between
> __next_mem_range(), the index may be mess.

Oops, I've really missed that :)
 
> Therefore, we could do remove operation after for_each_mem_range like this, solution A:
>  void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
>  {
> -	phys_addr_t start, end;
> -	u64 i;
> +	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> +	phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> +	u64 i, nr = 0;
> 
>  	/* truncate memory while skipping NOMAP regions */
>  	for_each_mem_range(i, &memblock.memory, regions_to_keep, NUMA_NO_NODE,
> -			   MEMBLOCK_NONE, &start, &end, NULL)
> -		memblock_remove(start, end);
> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
> +		nr++;
> +	for (i = 0; i < nr; i++)
> +		memblock_remove(start[i], end[i] - start[i]);
> 
>  	/* truncate the reserved regions */
> +	nr = 0;
>  	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
> -			   MEMBLOCK_NONE, &start, &end, NULL)
> -		memblock_remove_range(&memblock.reserved, start, end);
> +			   MEMBLOCK_NONE, &start[nr], &end[nr], NULL)
> +		nr++;
> +	for (i = 0; i < nr; i++)
> +		memblock_remove_range(&memblock.reserved, start[i],
> +				end[i] - start[i]);
>  }
> 
> But a warning occurs when compiling:
>   CALL    scripts/atomic/check-atomics.sh
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CC      mm/memblock.o
> mm/memblock.c: In function ‘memblock_cap_memory_ranges’:
> mm/memblock.c:1635:1: warning: the frame size of 36912 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>  }
> 
> another solution is my implementation in v1, solution B:
> +void __init memblock_cap_memory_ranges(struct memblock_type *regions_to_keep)
> +{
> +   int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> +   int i, j, ret, nr = 0;
> +   memblock_region *regs = regions_to_keep->regions;
> +
> +   nr = regions_to_keep -> cnt;
> +   if (!nr)
> +       return;
> +
> +   /* remove all the MAP regions */
> +   for (i = memblock.memory.cnt - 1; i >= end_rgn[nr - 1]; i--)
> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +           memblock_remove_region(&memblock.memory, i);
> +
> +   for (i = nr - 1; i > 0; i--)
> +       for (j = start_rgn[i] - 1; j >= end_rgn[i - 1]; j--)
> +           if (!memblock_is_nomap(&memblock.memory.regions[j]))
> +               memblock_remove_region(&memblock.memory, j);
> +
> +   for (i = start_rgn[0] - 1; i >= 0; i--)
> +       if (!memblock_is_nomap(&memblock.memory.regions[i]))
> +           memblock_remove_region(&memblock.memory, i);
> +
> +   /* truncate the reserved regions */
> +   memblock_remove_range(&memblock.reserved, 0, regs[0].base);
> +
> +   for (i = nr - 1; i > 0; i--)
> +       memblock_remove_range(&memblock.reserved,
> +               regs[i - 1].base + regs[i - 1].size,
> +		regs[i].base - regs[i - 1].base - regs[i - 1].size);
> +
> +   memblock_remove_range(&memblock.reserved,
> +           regs[nr - 1].base + regs[nr - 1].size, PHYS_ADDR_MAX);
> +}
> 
> solution A: 	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> 		phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> start, end is physical addr
> 
> solution B: 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> start_rgn, end_rgn is rgn index		
> 
> Solution B do less remove operations and with no warning comparing to solution A.
> I think solution B is better, could you give some suggestions?
 
Solution B is indeed better that solution A, but I'm still worried by
relatively large arrays on stack and the amount of loops :(

The very least we could do is to call memblock_cap_memory_range() to drop
the memory before and after the ranges we'd like to keep.

> >  
> >  	/* truncate the reserved regions */
> > -	memblock_remove_range(&memblock.reserved, 0, base);
> > -	memblock_remove_range(&memblock.reserved,
> > -			base + size, PHYS_ADDR_MAX);
> > +	for_each_mem_range(i, &memblock.reserved, regions_to_keep, NUMA_NO_NODE,
> > +			   MEMBLOCK_NONE, &start, &end, NULL)
> > +		memblock_remove_range(&memblock.reserved, start, end);
> 
> There are the same issues as above.
> 
> >  }
> >  
> >  void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> >  {
> > +	struct memblock_region rgn = {
> > +		.base = 0,
> > +	};
> > +
> > +	struct memblock_type region_to_keep = {
> > +		.cnt = 1,
> > +		.max = 1,
> > +		.regions = &rgn,
> > +	};
> > +
> >  	phys_addr_t max_addr;
> >  
> >  	if (!limit)
> > @@ -1646,7 +1644,8 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> >  	if (max_addr == PHYS_ADDR_MAX)
> >  		return;
> >  
> > -	memblock_cap_memory_range(0, max_addr);
> > +	region_to_keep.regions[0].size = max_addr;
> > +	memblock_cap_memory_ranges(&region_to_keep);
> >  }
> >  
> >  static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
> > 
> 
> Thanks,
> Chen Zhou
> 

-- 
Sincerely yours,
Mike.

