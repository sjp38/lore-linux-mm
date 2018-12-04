Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E61FB6B6FCE
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 12:13:47 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e17so8447550edr.7
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 09:13:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s29-v6si4307994ejk.263.2018.12.04.09.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 09:13:46 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB4H9ZM1056606
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 12:13:44 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p5vapd757-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:13:43 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Dec 2018 17:13:41 -0000
Date: Tue, 4 Dec 2018 19:13:28 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 1/6] powerpc: prefer memblock APIs returning virtual
 address
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
 <1543852035-26634-2-git-send-email-rppt@linux.ibm.com>
 <87woophasy.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87woophasy.fsf@concordia.ellerman.id.au>
Message-Id: <20181204171327.GL26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Tue, Dec 04, 2018 at 08:59:41PM +1100, Michael Ellerman wrote:
> Hi Mike,
> 
> Thanks for trying to clean these up.
> 
> I think a few could be improved though ...
> 
> Mike Rapoport <rppt@linux.ibm.com> writes:
> > diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
> > index 913bfca..fa884ad 100644
> > --- a/arch/powerpc/kernel/paca.c
> > +++ b/arch/powerpc/kernel/paca.c
> > @@ -42,17 +42,15 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
> >  		nid = early_cpu_to_node(cpu);
> >  	}
> >  
> > -	pa = memblock_alloc_base_nid(size, align, limit, nid, MEMBLOCK_NONE);
> > -	if (!pa) {
> > -		pa = memblock_alloc_base(size, align, limit);
> > -		if (!pa)
> > -			panic("cannot allocate paca data");
> > -	}
> > +	ptr = memblock_alloc_try_nid_raw(size, align, MEMBLOCK_LOW_LIMIT,
> > +					 limit, nid);
> > +	if (!ptr)
> > +		panic("cannot allocate paca data");
>   
> The old code doesn't zero, but two of the three callers of
> alloc_paca_data() *do* zero the whole allocation, so I'd be happy if we
> did it in here instead.

I looked at the callers and couldn't tell if zeroing memory in
init_lppaca() would be ok.
I'll remove the _raw here.
 
> That would mean we could use memblock_alloc_try_nid() avoiding the need
> to panic() manually.

Actual, my plan was to remove panic() from all memblock_alloc* and make all
callers to check the returned value.
I believe it's cleaner and also allows more meaningful panic messages. Not
mentioning the reduction of memblock code.
 
> > diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> > index 236c115..d11ee7f 100644
> > --- a/arch/powerpc/kernel/setup_64.c
> > +++ b/arch/powerpc/kernel/setup_64.c
> > @@ -634,19 +634,17 @@ __init u64 ppc64_bolted_size(void)
> >  
> >  static void *__init alloc_stack(unsigned long limit, int cpu)
> >  {
> > -	unsigned long pa;
> > +	void *ptr;
> >  
> >  	BUILD_BUG_ON(STACK_INT_FRAME_SIZE % 16);
> >  
> > -	pa = memblock_alloc_base_nid(THREAD_SIZE, THREAD_SIZE, limit,
> > -					early_cpu_to_node(cpu), MEMBLOCK_NONE);
> > -	if (!pa) {
> > -		pa = memblock_alloc_base(THREAD_SIZE, THREAD_SIZE, limit);
> > -		if (!pa)
> > -			panic("cannot allocate stacks");
> > -	}
> > +	ptr = memblock_alloc_try_nid_raw(THREAD_SIZE, THREAD_SIZE,
> > +					 MEMBLOCK_LOW_LIMIT, limit,
> > +					 early_cpu_to_node(cpu));
> > +	if (!ptr)
> > +		panic("cannot allocate stacks");
>  
> Similarly here, several of the callers zero the stack, and I'd rather
> all of them did.
> 
> So again we could use memblock_alloc_try_nid() here and remove the
> memset()s from emergency_stack_init().

Ok
 
> > diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
> > index 9311560..415a1eb0 100644
> > --- a/arch/powerpc/mm/pgtable-radix.c
> > +++ b/arch/powerpc/mm/pgtable-radix.c
> > @@ -51,24 +51,18 @@ static int native_register_process_table(unsigned long base, unsigned long pg_sz
> >  static __ref void *early_alloc_pgtable(unsigned long size, int nid,
> >  			unsigned long region_start, unsigned long region_end)
> >  {
> > -	unsigned long pa = 0;
> > +	phys_addr_t min_addr = MEMBLOCK_LOW_LIMIT;
> > +	phys_addr_t max_addr = MEMBLOCK_ALLOC_ANYWHERE;
> >  	void *pt;
> >  
> > -	if (region_start || region_end) /* has region hint */
> > -		pa = memblock_alloc_range(size, size, region_start, region_end,
> > -						MEMBLOCK_NONE);
> > -	else if (nid != -1) /* has node hint */
> > -		pa = memblock_alloc_base_nid(size, size,
> > -						MEMBLOCK_ALLOC_ANYWHERE,
> > -						nid, MEMBLOCK_NONE);
> > +	if (region_start)
> > +		min_addr = region_start;
> > +	if (region_end)
> > +		max_addr = region_end;
> >  
> > -	if (!pa)
> > -		pa = memblock_alloc_base(size, size, MEMBLOCK_ALLOC_ANYWHERE);
> > -
> > -	BUG_ON(!pa);
> > -
> > -	pt = __va(pa);
> > -	memset(pt, 0, size);
> > +	pt = memblock_alloc_try_nid_nopanic(size, size, min_addr, max_addr,
> > +					    nid);
> > +	BUG_ON(!pt);
> 
> I don't think there's any reason to BUG_ON() here rather than letting
> memblock() call panic() for us. So this could also be memblock_alloc_try_nid().

I'd prefer to panic here.
 
> > diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
> > index f297152..f62930f 100644
> > --- a/arch/powerpc/platforms/pasemi/iommu.c
> > +++ b/arch/powerpc/platforms/pasemi/iommu.c
> > @@ -208,7 +208,9 @@ static int __init iob_init(struct device_node *dn)
> >  	pr_debug(" -> %s\n", __func__);
> >  
> >  	/* For 2G space, 8x64 pages (2^21 bytes) is max total l2 size */
> > -	iob_l2_base = (u32 *)__va(memblock_alloc_base(1UL<<21, 1UL<<21, 0x80000000));
> > +	iob_l2_base = memblock_alloc_try_nid_raw(1UL << 21, 1UL << 21,
> > +					MEMBLOCK_LOW_LIMIT, 0x80000000,
> > +					NUMA_NO_NODE);
> 
> This isn't equivalent is it?
> 
> memblock_alloc_base() panics on failure but memblock_alloc_try_nid_raw()
> doesn't?

Right, this should be either a memblock function that panic()'s or a call
to panic() if the returned value is NULL.
My preference is for the second variant :)
 
> Same comment for the other locations that do that conversion.
> 
> cheers
> 

-- 
Sincerely yours,
Mike.
