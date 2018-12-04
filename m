Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3416B6E08
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:59:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id u20so13619237pfa.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:59:55 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id g7si17886829plb.107.2018.12.04.01.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:59:54 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 1/6] powerpc: prefer memblock APIs returning virtual address
In-Reply-To: <1543852035-26634-2-git-send-email-rppt@linux.ibm.com>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com> <1543852035-26634-2-git-send-email-rppt@linux.ibm.com>
Date: Tue, 04 Dec 2018 20:59:41 +1100
Message-ID: <87woophasy.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

Hi Mike,

Thanks for trying to clean these up.

I think a few could be improved though ...

Mike Rapoport <rppt@linux.ibm.com> writes:
> diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
> index 913bfca..fa884ad 100644
> --- a/arch/powerpc/kernel/paca.c
> +++ b/arch/powerpc/kernel/paca.c
> @@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
>  		nid = early_cpu_to_node(cpu);
>  	}
>  
> -	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
> -	if (!pa) {
> -		pa = memblock_alloc_base(size, align, limit);
> -		if (!pa)
> -			panic("cannot allocate paca data");
> -	}
> +	ptr = memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
> +					 limit, nid);
> +	if (!ptr)
> +		panic("cannot allocate paca data");
  
The old code doesn't zero, but two of the three callers of
alloc_paca_data() *do* zero the whole allocation, so I'd be happy if we
did it in here instead.

That would mean we could use memblock_alloc_try_nid() avoiding the need
to panic() manually.

> diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> index 236c115..d11ee7f 100644
> --- a/arch/powerpc/kernel/setup_64.c
> +++ b/arch/powerpc/kernel/setup_64.c
> @@ -634,19 +634,17 @@ __init u64 ppc64_bolted_size(void)
>  
>  static void *__init alloc_stack(unsigned long limit, int cpu)
>  {
> -	unsigned long pa;
> +	void *ptr;
>  
>  	BUILD_BUG_ON(STACK_INT_FRAME_SIZE % 16);
>  
> -	pa = memblock_alloc_base_nid(THREAD_SIZE, THREAD_SIZE, limit,
> -					early_cpu_to_node(cpu), MEMBLOCK_NONE);
> -	if (!pa) {
> -		pa = memblock_alloc_base(THREAD_SIZE, THREAD_SIZE, limit);
> -		if (!pa)
> -			panic("cannot allocate stacks");
> -	}
> +	ptr = memblock_alloc_try_nid_raw(THREAD_SIZE, THREAD_SIZE,
> +					 MEMBLOCK_LOW_LIMIT, limit,
> +					 early_cpu_to_node(cpu));
> +	if (!ptr)
> +		panic("cannot allocate stacks");
 
Similarly here, several of the callers zero the stack, and I'd rather
all of them did.

So again we could use memblock_alloc_try_nid() here and remove the
memset()s from emergency_stack_init().

> diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
> index 9311560..415a1eb0 100644
> --- a/arch/powerpc/mm/pgtable-radix.c
> +++ b/arch/powerpc/mm/pgtable-radix.c
> @@ -51,24 +51,18 @@ static int native_register_process_table(unsigned long base, unsigned long pg_sz
>  static __ref void *early_alloc_pgtable(unsigned long size, int nid,
>  			unsigned long region_start, unsigned long region_end)
>  {
> -	unsigned long pa = 0;
> +	phys_addr_t min_addr = MEMBLOCK_LOW_LIMIT;
> +	phys_addr_t max_addr = MEMBLOCK_ALLOC_ANYWHERE;
>  	void *pt;
>  
> -	if (region_start || region_end) /* has region hint */
> -		pa = memblock_alloc_range(size, size, region_start, region_end,
> -						MEMBLOCK_NONE);
> -	else if (nid != -1) /* has node hint */
> -		pa = memblock_alloc_base_nid(size, size,
> -						MEMBLOCK_ALLOC_ANYWHERE,
> -						nid, MEMBLOCK_NONE);
> +	if (region_start)
> +		min_addr = region_start;
> +	if (region_end)
> +		max_addr = region_end;
>  
> -	if (!pa)
> -		pa = memblock_alloc_base(size, size, MEMBLOCK_ALLOC_ANYWHERE);
> -
> -	BUG_ON(!pa);
> -
> -	pt = __va(pa);
> -	memset(pt, 0, size);
> +	pt = memblock_alloc_try_nid_nopanic(size, size, min_addr, max_addr,
> +					    nid);
> +	BUG_ON(!pt);

I don't think there's any reason to BUG_ON() here rather than letting
memblock() call panic() for us. So this could also be memblock_alloc_try_nid().

> diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
> index f297152..f62930f 100644
> --- a/arch/powerpc/platforms/pasemi/iommu.c
> +++ b/arch/powerpc/platforms/pasemi/iommu.c
> @@ -208,7 +208,9 @@ static int __init iob_init(struct device_node *dn)
>  	pr_debug(" -> %s\n", __func__);
>  
>  	/* For 2G space, 8x64 pages (2^21 bytes) is max total l2 size */
> -	iob_l2_base = (u32 *)__va(memblock_alloc_base(1UL<<21, 1UL<<21, 0x80000000));
> +	iob_l2_base = memblock_alloc_try_nid_raw(1UL << 21, 1UL << 21,
> +					MEMBLOCK_LOW_LIMIT, 0x80000000,
> +					NUMA_NO_NODE);

This isn't equivalent is it?

memblock_alloc_base() panics on failure but memblock_alloc_try_nid_raw()
doesn't?

Same comment for the other locations that do that conversion.

cheers
