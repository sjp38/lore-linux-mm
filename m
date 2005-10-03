Received: by zproxy.gmail.com with SMTP id k1so230618nzf
        for <linux-mm@kvack.org>; Mon, 03 Oct 2005 02:59:40 -0700 (PDT)
Message-ID: <aec7e5c30510030259j2698f982ue7169768730f3d53@mail.gmail.com>
Date: Mon, 3 Oct 2005 18:59:38 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH 07/07] i386: numa emulation on pc
In-Reply-To: <1128106512.8123.26.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	 <20050930073308.10631.24247.sendpatchset@cherry.local>
	 <1128106512.8123.26.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, Isaku Yamahata <yamahata@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi again Dave,

On 10/1/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
> >  void __init nid_zone_sizes_init(int nid)
> >  {
> >       unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
> > -     unsigned long max_dma;
> > +     unsigned long max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
> >       unsigned long start = node_start_pfn[nid];
> >       unsigned long end = node_end_pfn[nid];
> >
> >       if (node_has_online_mem(nid)){
> > -             if (nid_starts_in_highmem(nid)) {
> > -                     zones_size[ZONE_HIGHMEM] = nid_size_pages(nid);
> > -             } else {
> > -                     max_dma = min(max_hardware_dma_pfn(), max_low_pfn);
> > -                     zones_size[ZONE_DMA] = max_dma;
> > -                     zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
> > -                     zones_size[ZONE_HIGHMEM] = end - max_low_pfn;
> > +             if (start < max_dma) {
> > +                     zones_size[ZONE_DMA] = min(end, max_dma) - start;
> > +             }
> > +             if (start < max_low_pfn && max_dma < end) {
> > +                     zones_size[ZONE_NORMAL] = min(end, max_low_pfn) - max(start, max_dma);
> > +             }
> > +             if (max_low_pfn <= end) {
> > +                     zones_size[ZONE_HIGHMEM] = end - max(start, max_low_pfn);
> >               }
> >       }
>
> That is a decent cleanup all by itself.  You might want to break it out.
> Take a look at the patches I just sent out.  They do some similar things
> to the same code.

Break it out, sure! I'm not sure which patch to look at, though.

> > @@ -1270,7 +1273,12 @@ void __init setup_bootmem_allocator(void
> >       /*
> >        * Initialize the boot-time allocator (with low memory only):
> >        */
> > +#ifdef CONFIG_NUMA_EMU
> > +     bootmap_size = init_bootmem(max(min_low_pfn, node_start_pfn[0]),
> > +                                 min(max_low_pfn, node_end_pfn[0]));
> > +#else
> >       bootmap_size = init_bootmem(min_low_pfn, max_low_pfn);
> > +#endif
>
> This shouldn't be necessary.  Again, take a look at my discontig
> separation patches and see if what I did works for you here.

Do you mean "discontig-consolidate0.patch"? Maybe I'm misunderstanding.

> > +#ifdef CONFIG_NUMA_EMU
> ...
> > +#endif
>
> Ewwwwww :)  No real need to put new function in a big #ifdef like that.
> Can you just create a new file for NUMA emulation?

Hehe, what is this, a beauty contest? =) I agree, but I guess the
reason for this code to be here is that a similar arrangement is done
by x86_64...

I will create a new file. Is arch/i386/mm/numa_emu.c good?

> > --- from-0001/include/asm-i386/numnodes.h
> > +++ to-work/include/asm-i386/numnodes.h       2005-09-28 17:49:53.000000000 +0900
> > @@ -8,7 +8,7 @@
> >  /* Max 16 Nodes */
> >  #define NODES_SHIFT  4
> >
> > -#elif defined(CONFIG_ACPI_SRAT)
> > +#elif defined(CONFIG_ACPI_SRAT) || defined(CONFIG_NUMA_EMU)
> >
> >  /* Max 8 Nodes */
> >  #define NODES_SHIFT  3
>
> Geez.  We should probably just do those in the Kconfig files.  Would
> look much simpler.  But, that's a patch for another day.  This is fine
> by itself.

No biggie, I will add a config option.

But first, you have written lots and lots of patches, and I am
confused. Could you please tell me on which patches I should base my
code to make things as easy as possible?

Many thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
