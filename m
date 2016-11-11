Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6CF280284
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:19:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so3489834pfk.3
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:19:17 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0048.outbound.protection.outlook.com. [104.47.1.48])
        by mx.google.com with ESMTPS id v1si7876992pge.21.2016.11.10.19.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 19:19:16 -0800 (PST)
Date: Fri, 11 Nov 2016 11:19:04 +0800
From: Dennis Chen <dennis.chen@arm.com>
Subject: Re: [PATCH v27 1/9] memblock: add memblock_cap_memory_range()
Message-ID: <20161111031903.GB15997@arm.com>
References: <20161102044959.11954-1-takahiro.akashi@linaro.org>
 <20161102045153.12008-1-takahiro.akashi@linaro.org>
 <20161110172720.GB17134@arm.com>
 <20161111025049.GG381@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161111025049.GG381@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: AKASHI Takahiro <takahiro.akashi@linaro.org>, Will Deacon <will.deacon@arm.com>, catalin.marinas@arm.com, akpm@linux-foundation.org, james.morse@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Fri, Nov 11, 2016 at 11:50:50AM +0900, AKASHI Takahiro wrote:
> Will,
> (+ Cc: Dennis)
> 
> On Thu, Nov 10, 2016 at 05:27:20PM +0000, Will Deacon wrote:
> > On Wed, Nov 02, 2016 at 01:51:53PM +0900, AKASHI Takahiro wrote:
> > > Add memblock_cap_memory_range() which will remove all the memblock regions
> > > except the range specified in the arguments.
> > > 
> > > This function, like memblock_mem_limit_remove_map(), will not remove
> > > memblocks with MEMMAP_NOMAP attribute as they may be mapped and accessed
> > > later as "device memory."
> > > See the commit a571d4eb55d8 ("mm/memblock.c: add new infrastructure to
> > > address the mem limit issue").
> > > 
> > > This function is used, in a succeeding patch in the series of arm64 kdump
> > > suuport, to limit the range of usable memory, System RAM, on crash dump
> > > kernel.
> > > (Please note that "mem=" parameter is of little use for this purpose.)
> > > 
> > > Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
> > > Cc: linux-mm@kvack.org
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > ---
> > >  include/linux/memblock.h |  1 +
> > >  mm/memblock.c            | 28 ++++++++++++++++++++++++++++
> > >  2 files changed, 29 insertions(+)
> > > 
> > > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > > index 5b759c9..0e770af 100644
> > > --- a/include/linux/memblock.h
> > > +++ b/include/linux/memblock.h
> > > @@ -334,6 +334,7 @@ phys_addr_t memblock_start_of_DRAM(void);
> > >  phys_addr_t memblock_end_of_DRAM(void);
> > >  void memblock_enforce_memory_limit(phys_addr_t memory_limit);
> > >  void memblock_mem_limit_remove_map(phys_addr_t limit);
> > > +void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
> > >  bool memblock_is_memory(phys_addr_t addr);
> > >  int memblock_is_map_memory(phys_addr_t addr);
> > >  int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
> > > diff --git a/mm/memblock.c b/mm/memblock.c
> > > index 7608bc3..eb53876 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -1544,6 +1544,34 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
> > >  			      (phys_addr_t)ULLONG_MAX);
> > >  }
> > >  
> > > +void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
> > > +{
> > > +	int start_rgn, end_rgn;
> > > +	int i, ret;
> > > +
> > > +	if (!size)
> > > +		return;
> > > +
> > > +	ret = memblock_isolate_range(&memblock.memory, base, size,
> > > +						&start_rgn, &end_rgn);
> > > +	if (ret)
> > > +		return;
> > > +
> > > +	/* remove all the MAP regions */
> > > +	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
> > > +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> > > +			memblock_remove_region(&memblock.memory, i);
> > > +
> > > +	for (i = start_rgn - 1; i >= 0; i--)
> > > +		if (!memblock_is_nomap(&memblock.memory.regions[i]))
> > > +			memblock_remove_region(&memblock.memory, i);
> > > +
> > > +	/* truncate the reserved regions */
> > > +	memblock_remove_range(&memblock.reserved, 0, base);
> > > +	memblock_remove_range(&memblock.reserved,
> > > +			base + size, (phys_addr_t)ULLONG_MAX);
> > > +}
> > 
> > This duplicates a bunch of the logic in memblock_mem_limit_remove_map. Can
> > you not implement that in terms of your new, more general, function? e.g.
> > by passing base == 0, and size == limit?
> 
> Obviously it's possible.
> I actually talked to Dennis before about merging them,
> but he was against my idea.
>
Oops! I thought we have reached agreement in the thread:http://lists.infradead.org/pipermail/linux-arm-kernel/2016-July/442817.html
So feel free to do that as Will'll do
> 
> Thanks,
> -Takahiro AKASHI
> 
> > Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
