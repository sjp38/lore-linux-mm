Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA0B16B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:42:44 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a63so13250477wrc.1
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 01:42:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v43si91907edm.63.2017.11.24.01.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 01:42:43 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAO9e0h2037051
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:42:42 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2eef79w0wk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 04:42:41 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Fri, 24 Nov 2017 09:42:40 -0000
Date: Fri, 24 Nov 2017 09:42:33 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/5] mm: memory_hotplug: Memory hotplug (add) support
 for arm64
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
 <ba9c72239dc5986edc6ca29fc58fefb306e4b52d.1511433386.git.ar@linux.vnet.ibm.com>
 <CAKZGPAPN7migyvpNJDu1bA+ditb0TJV4WLqZuPdkxOU3kYQ9Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKZGPAPN7migyvpNJDu1bA+ditb0TJV4WLqZuPdkxOU3kYQ9Ng@mail.gmail.com>
Message-Id: <20171124094232.GA18120@samekh>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks.linux@gmail.com>
Cc: Maciej Bielski <m.bielski@virtualopensystems.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, mhocko@suse.com, realean2@ie.ibm.com

Hi Arun,


On Fri 24 Nov 2017, 11:25, Arun KS wrote:
> On Thu, Nov 23, 2017 at 4:43 PM, Maciej Bielski
> <m.bielski@virtualopensystems.com> wrote:
>> [ ...]
> > Introduces memory hotplug functionality (hot-add) for arm64.
> > @@ -615,6 +616,44 @@ void __init paging_init(void)
> >                       SWAPPER_DIR_SIZE - PAGE_SIZE);
> >  }
> >
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +
> > +/*
> > + * hotplug_paging() is used by memory hotplug to build new page tables
> > + * for hot added memory.
> > + */
> > +
> > +struct mem_range {
> > +       phys_addr_t base;
> > +       phys_addr_t size;
> > +};
> > +
> > +static int __hotplug_paging(void *data)
> > +{
> > +       int flags = 0;
> > +       struct mem_range *section = data;
> > +
> > +       if (debug_pagealloc_enabled())
> > +               flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> > +
> > +       __create_pgd_mapping(swapper_pg_dir, section->base,
> > +                       __phys_to_virt(section->base), section->size,
> > +                       PAGE_KERNEL, pgd_pgtable_alloc, flags);
> 
> Hello Andrea,
> 
> __hotplug_paging runs on stop_machine context.
> cpu stop callbacks must not sleep.
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/stop_machine.c?h=v4.14#n479
> 
> __create_pgd_mapping uses pgd_pgtable_alloc. which does
> __get_free_page(PGALLOC_GFP)
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/mm/mmu.c?h=v4.14#n342
> 
> PGALLOC_GFP has GFP_KERNEL which inturn has __GFP_RECLAIM
> 
> #define PGALLOC_GFP     (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
> #define GFP_KERNEL      (__GFP_RECLAIM | __GFP_IO | __GFP_FS)
> 
> Now, prepare_alloc_pages() called by __alloc_pages_nodemask checks for
> 
> might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v4.14#n4150
> 
> and then BUG()

Well spotted, thanks for reporting the problem. One possible solution
would be to revert back to building the updated page tables on a copy
pgdir (as it was done in v1 of this patchset) and then replacing swapper
atomically with stop_machine.

Actually, I am not sure if stop_machine is strictly needed,
if we modify the swapper pgdir live: for example, in x86_64
kernel_physical_mapping_init, atomicity is ensured by spin-locking on
init_mm.page_table_lock.
https://elixir.free-electrons.com/linux/v4.14/source/arch/x86/mm/init_64.c#L684
I'll spend some time investigating whoever else could be working
concurrently on the swapper pgdir.

Any suggestion or pointer is very welcome.

Thanks,
Andrea

> I was testing on 4.4 kernel, but cross checked with 4.14 as well.
> 
> Regards,
> Arun
> 
> 
> > +
> > +       return 0;
> > +}
> > +
> > +inline void hotplug_paging(phys_addr_t start, phys_addr_t size)
> > +{
> > +       struct mem_range section = {
> > +               .base = start,
> > +               .size = size,
> > +       };
> > +
> > +       stop_machine(__hotplug_paging, &section, NULL);
> > +}
> > +#endif /* CONFIG_MEMORY_HOTPLUG */
> > +
> >  /*
> >   * Check whether a kernel address is valid (derived from arch/x86/).
> >   */
> > --
> > 2.7.4
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
