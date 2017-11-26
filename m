Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B40816B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 01:58:03 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id o27so12924308uaj.5
        for <linux-mm@kvack.org>; Sat, 25 Nov 2017 22:58:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor2261545uaf.191.2017.11.25.22.58.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 Nov 2017 22:58:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171124105308.GA10023@tpad>
References: <cover.1511433386.git.ar@linux.vnet.ibm.com> <ba9c72239dc5986edc6ca29fc58fefb306e4b52d.1511433386.git.ar@linux.vnet.ibm.com>
 <CAKZGPAPN7migyvpNJDu1bA+ditb0TJV4WLqZuPdkxOU3kYQ9Ng@mail.gmail.com>
 <20171124094232.GA18120@samekh> <20171124105308.GA10023@tpad>
From: Arun KS <arunks.linux@gmail.com>
Date: Sun, 26 Nov 2017 12:28:01 +0530
Message-ID: <CAKZGPAMByPKcEmWf_QMm6k4WomH8ZJjjj3YNyBU617DZN1VwMQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] mm: memory_hotplug: Memory hotplug (add) support
 for arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maciej Bielski <m.bielski@virtualopensystems.com>
Cc: Andrea Reale <ar@linux.vnet.ibm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, Catalin Marinas <catalin.marinas@arm.com>, mhocko@suse.com, realean2@ie.ibm.com

On Fri, Nov 24, 2017 at 4:23 PM, Maciej Bielski
<m.bielski@virtualopensystems.com> wrote:
> On Fri, Nov 24, 2017 at 09:42:33AM +0000, Andrea Reale wrote:
>> Hi Arun,
>>
>>
>> On Fri 24 Nov 2017, 11:25, Arun KS wrote:
>> > On Thu, Nov 23, 2017 at 4:43 PM, Maciej Bielski
>> > <m.bielski@virtualopensystems.com> wrote:
>> >> [ ...]
>> > > Introduces memory hotplug functionality (hot-add) for arm64.
>> > > @@ -615,6 +616,44 @@ void __init paging_init(void)
>> > >                       SWAPPER_DIR_SIZE - PAGE_SIZE);
>> > >  }
>> > >
>> > > +#ifdef CONFIG_MEMORY_HOTPLUG
>> > > +
>> > > +/*
>> > > + * hotplug_paging() is used by memory hotplug to build new page tables
>> > > + * for hot added memory.
>> > > + */
>> > > +
>> > > +struct mem_range {
>> > > +       phys_addr_t base;
>> > > +       phys_addr_t size;
>> > > +};
>> > > +
>> > > +static int __hotplug_paging(void *data)
>> > > +{
>> > > +       int flags = 0;
>> > > +       struct mem_range *section = data;
>> > > +
>> > > +       if (debug_pagealloc_enabled())
>> > > +               flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>> > > +
>> > > +       __create_pgd_mapping(swapper_pg_dir, section->base,
>> > > +                       __phys_to_virt(section->base), section->size,
>> > > +                       PAGE_KERNEL, pgd_pgtable_alloc, flags);
>> >
>> > Hello Andrea,
>> >
>> > __hotplug_paging runs on stop_machine context.
>> > cpu stop callbacks must not sleep.
>> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/kernel/stop_machine.c?h=v4.14#n479
>> >
>> > __create_pgd_mapping uses pgd_pgtable_alloc. which does
>> > __get_free_page(PGALLOC_GFP)
>> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/mm/mmu.c?h=v4.14#n342
>> >
>> > PGALLOC_GFP has GFP_KERNEL which inturn has __GFP_RECLAIM
>> >
>> > #define PGALLOC_GFP     (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
>> > #define GFP_KERNEL      (__GFP_RECLAIM | __GFP_IO | __GFP_FS)
>> >
>> > Now, prepare_alloc_pages() called by __alloc_pages_nodemask checks for
>> >
>> > might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>> >
>> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/mm/page_alloc.c?h=v4.14#n4150
>> >
>> > and then BUG()
>>
>> Well spotted, thanks for reporting the problem. One possible solution
>> would be to revert back to building the updated page tables on a copy
>> pgdir (as it was done in v1 of this patchset) and then replacing swapper
>> atomically with stop_machine.
>>
>> Actually, I am not sure if stop_machine is strictly needed,
>> if we modify the swapper pgdir live: for example, in x86_64
>> kernel_physical_mapping_init, atomicity is ensured by spin-locking on
>> init_mm.page_table_lock.
>> https://elixir.free-electrons.com/linux/v4.14/source/arch/x86/mm/init_64.c#L684
>> I'll spend some time investigating whoever else could be working
>> concurrently on the swapper pgdir.
>>
>> Any suggestion or pointer is very welcome.
>
> Hi Andrea, Arun,
>
> Alternative approach could be implementing pgd_pgtable_alloc_nosleep() and
> pointing this to hotplug_paging(). Subsequently, it could use different flags,
> eg:
>
> #define PGALLOC_GFP_NORECLAIM   (__GFP_IO | __GFP_FS | __GFP_NOTRACK | __GFP_ZERO)

This solves the problem with __get_free_page.

But pgd_pgtable_alloc() ->  pgtable_page_ctor() -> ptlock_alloc() and
then kmem_cache_alloc(page_ptl_cachep, GFP_KERNEL)
Same BUG again.

Regards,
Arun

>
> Is this unefficient approach in any way?
> Do we like the fact that the memory-attaching thread can go to sleep?
>
> BR,
>
>>
>> Thanks,
>> Andrea
>>
>> > I was testing on 4.4 kernel, but cross checked with 4.14 as well.
>> >
>> > Regards,
>> > Arun
>> >
>> >
>> > > +
>> > > +       return 0;
>> > > +}
>> > > +
>> > > +inline void hotplug_paging(phys_addr_t start, phys_addr_t size)
>> > > +{
>> > > +       struct mem_range section = {
>> > > +               .base = start,
>> > > +               .size = size,
>> > > +       };
>> > > +
>> > > +       stop_machine(__hotplug_paging, &section, NULL);
>> > > +}
>> > > +#endif /* CONFIG_MEMORY_HOTPLUG */
>> > > +
>> > >  /*
>> > >   * Check whether a kernel address is valid (derived from arch/x86/).
>> > >   */
>> > > --
>> > > 2.7.4
>> > >
>> >
>>
>
> --
> Maciej Bielski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
