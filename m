Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 859098E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 03:34:04 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so19408032ioh.21
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 00:34:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor14588368itb.4.2019.01.14.00.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 00:34:02 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-4-git-send-email-kernelfans@gmail.com> <20190114075113.GB1973@rapoport-lnx>
In-Reply-To: <20190114075113.GB1973@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 14 Jan 2019 16:33:50 +0800
Message-ID: <CAFgQCTtN4CGFz5xf+uci1ow032oQMB5pExHG01EtgrOpqXrJKA@mail.gmail.com>
Subject: Re: [PATCHv2 3/7] mm/memblock: introduce allocation boundary for
 tracing purpose
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 14, 2019 at 3:51 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Hi Pingfan,
>
> On Fri, Jan 11, 2019 at 01:12:53PM +0800, Pingfan Liu wrote:
> > During boot time, there is requirement to tell whether a series of func
> > call will consume memory or not. For some reason, a temporary memory
> > resource can be loan to those func through memblock allocator, but at a
> > check point, all of the loan memory should be turned back.
> > A typical using style:
> >  -1. find a usable range by memblock_find_in_range(), said, [A,B]
> >  -2. before calling a series of func, memblock_set_current_limit(A,B,true)
> >  -3. call funcs
> >  -4. memblock_find_in_range(A,B,B-A,1), if failed, then some memory is not
> >      turned back.
> >  -5. reset the original limit
> >
> > E.g. in the case of hotmovable memory, some acpi routines should be called,
> > and they are not allowed to own some movable memory. Although at present
> > these functions do not consume memory, but later, if changed without
> > awareness, they may do. With the above method, the allocation can be
> > detected, and pr_warn() to ask people to resolve it.
>
> To ensure there were that a sequence of function calls didn't create new
> memblock allocations you can simply check the number of the reserved
> regions before and after that sequence.
>
Yes, thank you point out it.

> Still, I'm not sure it would be practical to try tracking what code that's called
> from x86::setup_arch() did memory allocation.
> Probably a better approach is to verify no memory ended up in the movable
> areas after their extents are known.
>
It is a probability problem whether allocated memory sit on hotmovable
memory or not. And if warning based on the verification, then it is
also a probability problem and maybe we will miss it.

Thanks and regards,
Pingfan

> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Borislav Petkov <bp@alien8.de>
> > Cc: "H. Peter Anvin" <hpa@zytor.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Andy Lutomirski <luto@kernel.org>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <lenb@kernel.org>
> > Cc: Yinghai Lu <yinghai@kernel.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
> > Cc: Baoquan He <bhe@redhat.com>
> > Cc: Juergen Gross <jgross@suse.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: x86@kernel.org
> > Cc: linux-acpi@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > ---
> >  arch/arm/mm/init.c              |  3 ++-
> >  arch/arm/mm/mmu.c               |  4 ++--
> >  arch/arm/mm/nommu.c             |  2 +-
> >  arch/csky/kernel/setup.c        |  2 +-
> >  arch/microblaze/mm/init.c       |  2 +-
> >  arch/mips/kernel/setup.c        |  2 +-
> >  arch/powerpc/mm/40x_mmu.c       |  6 ++++--
> >  arch/powerpc/mm/44x_mmu.c       |  2 +-
> >  arch/powerpc/mm/8xx_mmu.c       |  2 +-
> >  arch/powerpc/mm/fsl_booke_mmu.c |  5 +++--
> >  arch/powerpc/mm/hash_utils_64.c |  4 ++--
> >  arch/powerpc/mm/init_32.c       |  2 +-
> >  arch/powerpc/mm/pgtable-radix.c |  2 +-
> >  arch/powerpc/mm/ppc_mmu_32.c    |  8 ++++++--
> >  arch/powerpc/mm/tlb_nohash.c    |  6 ++++--
> >  arch/unicore32/mm/mmu.c         |  2 +-
> >  arch/x86/kernel/setup.c         |  2 +-
> >  arch/xtensa/mm/init.c           |  2 +-
> >  include/linux/memblock.h        | 10 +++++++---
> >  mm/memblock.c                   | 23 ++++++++++++++++++-----
> >  20 files changed, 59 insertions(+), 32 deletions(-)
> >
> > diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> > index 32e4845..58a4342 100644
> > --- a/arch/arm/mm/init.c
> > +++ b/arch/arm/mm/init.c
> > @@ -93,7 +93,8 @@ __tagtable(ATAG_INITRD2, parse_tag_initrd2);
> >  static void __init find_limits(unsigned long *min, unsigned long *max_low,
> >                              unsigned long *max_high)
> >  {
> > -     *max_low = PFN_DOWN(memblock_get_current_limit());
> > +     memblock_get_current_limit(NULL, max_low);
> > +     *max_low = PFN_DOWN(*max_low);
> >       *min = PFN_UP(memblock_start_of_DRAM());
> >       *max_high = PFN_DOWN(memblock_end_of_DRAM());
> >  }
> > diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> > index f5cc1cc..9025418 100644
> > --- a/arch/arm/mm/mmu.c
> > +++ b/arch/arm/mm/mmu.c
> > @@ -1240,7 +1240,7 @@ void __init adjust_lowmem_bounds(void)
> >               }
> >       }
> >
> > -     memblock_set_current_limit(memblock_limit);
> > +     memblock_set_current_limit(0, memblock_limit, false);
> >  }
> >
> >  static inline void prepare_page_table(void)
> > @@ -1625,7 +1625,7 @@ void __init paging_init(const struct machine_desc *mdesc)
> >
> >       prepare_page_table();
> >       map_lowmem();
> > -     memblock_set_current_limit(arm_lowmem_limit);
> > +     memblock_set_current_limit(0, arm_lowmem_limit, false);
> >       dma_contiguous_remap();
> >       early_fixmap_shutdown();
> >       devicemaps_init(mdesc);
> > diff --git a/arch/arm/mm/nommu.c b/arch/arm/mm/nommu.c
> > index 7d67c70..721535c 100644
> > --- a/arch/arm/mm/nommu.c
> > +++ b/arch/arm/mm/nommu.c
> > @@ -138,7 +138,7 @@ void __init adjust_lowmem_bounds(void)
> >       adjust_lowmem_bounds_mpu();
> >       end = memblock_end_of_DRAM();
> >       high_memory = __va(end - 1) + 1;
> > -     memblock_set_current_limit(end);
> > +     memblock_set_current_limit(0, end, false);
> >  }
> >
> >  /*
> > diff --git a/arch/csky/kernel/setup.c b/arch/csky/kernel/setup.c
> > index dff8b89..e6f88bf 100644
> > --- a/arch/csky/kernel/setup.c
> > +++ b/arch/csky/kernel/setup.c
> > @@ -100,7 +100,7 @@ static void __init csky_memblock_init(void)
> >
> >       highend_pfn = max_pfn;
> >  #endif
> > -     memblock_set_current_limit(PFN_PHYS(max_low_pfn));
> > +     memblock_set_current_limit(0, PFN_PHYS(max_low_pfn), false);
> >
> >       dma_contiguous_reserve(0);
> >
> > diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> > index b17fd8a..cee99da 100644
> > --- a/arch/microblaze/mm/init.c
> > +++ b/arch/microblaze/mm/init.c
> > @@ -353,7 +353,7 @@ asmlinkage void __init mmu_init(void)
> >       /* Shortly after that, the entire linear mapping will be available */
> >       /* This will also cause that unflatten device tree will be allocated
> >        * inside 768MB limit */
> > -     memblock_set_current_limit(memory_start + lowmem_size - 1);
> > +     memblock_set_current_limit(0, memory_start + lowmem_size - 1, false);
> >  }
> >
> >  /* This is only called until mem_init is done. */
> > diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> > index 8c6c48ed..62dabe1 100644
> > --- a/arch/mips/kernel/setup.c
> > +++ b/arch/mips/kernel/setup.c
> > @@ -862,7 +862,7 @@ static void __init arch_mem_init(char **cmdline_p)
> >        * with memblock_reserve; memblock_alloc* can be used
> >        * only after this point
> >        */
> > -     memblock_set_current_limit(PFN_PHYS(max_low_pfn));
> > +     memblock_set_current_limit(0, PFN_PHYS(max_low_pfn), false);
> >
> >  #ifdef CONFIG_PROC_VMCORE
> >       if (setup_elfcorehdr && setup_elfcorehdr_size) {
> > diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
> > index 61ac468..427bb56 100644
> > --- a/arch/powerpc/mm/40x_mmu.c
> > +++ b/arch/powerpc/mm/40x_mmu.c
> > @@ -141,7 +141,7 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
> >        * coverage with normal-sized pages (or other reasons) do not
> >        * attempt to allocate outside the allowed range.
> >        */
> > -     memblock_set_current_limit(mapped);
> > +     memblock_set_current_limit(0, mapped, false);
> >
> >       return mapped;
> >  }
> > @@ -155,5 +155,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >       BUG_ON(first_memblock_base != 0);
> >
> >       /* 40x can only access 16MB at the moment (see head_40x.S) */
> > -     memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
> > +     memblock_set_current_limit(0,
> > +             min_t(u64, first_memblock_size, 0x00800000),
> > +             false);
> >  }
> > diff --git a/arch/powerpc/mm/44x_mmu.c b/arch/powerpc/mm/44x_mmu.c
> > index 12d9251..3cf127d 100644
> > --- a/arch/powerpc/mm/44x_mmu.c
> > +++ b/arch/powerpc/mm/44x_mmu.c
> > @@ -225,7 +225,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >
> >       /* 44x has a 256M TLB entry pinned at boot */
> >       size = (min_t(u64, first_memblock_size, PPC_PIN_SIZE));
> > -     memblock_set_current_limit(first_memblock_base + size);
> > +     memblock_set_current_limit(0, first_memblock_base + size, false);
> >  }
> >
> >  #ifdef CONFIG_SMP
> > diff --git a/arch/powerpc/mm/8xx_mmu.c b/arch/powerpc/mm/8xx_mmu.c
> > index 01b7f51..c75bca6 100644
> > --- a/arch/powerpc/mm/8xx_mmu.c
> > +++ b/arch/powerpc/mm/8xx_mmu.c
> > @@ -135,7 +135,7 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
> >        * attempt to allocate outside the allowed range.
> >        */
> >       if (mapped)
> > -             memblock_set_current_limit(mapped);
> > +             memblock_set_current_limit(0, mapped, false);
> >
> >       block_mapped_ram = mapped;
> >
> > diff --git a/arch/powerpc/mm/fsl_booke_mmu.c b/arch/powerpc/mm/fsl_booke_mmu.c
> > index 080d49b..3be24b8 100644
> > --- a/arch/powerpc/mm/fsl_booke_mmu.c
> > +++ b/arch/powerpc/mm/fsl_booke_mmu.c
> > @@ -252,7 +252,8 @@ void __init adjust_total_lowmem(void)
> >       pr_cont("%lu Mb, residual: %dMb\n", tlbcam_sz(tlbcam_index - 1) >> 20,
> >               (unsigned int)((total_lowmem - __max_low_memory) >> 20));
> >
> > -     memblock_set_current_limit(memstart_addr + __max_low_memory);
> > +     memblock_set_current_limit(0,
> > +             memstart_addr + __max_low_memory, false);
> >  }
> >
> >  void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> > @@ -261,7 +262,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >       phys_addr_t limit = first_memblock_base + first_memblock_size;
> >
> >       /* 64M mapped initially according to head_fsl_booke.S */
> > -     memblock_set_current_limit(min_t(u64, limit, 0x04000000));
> > +     memblock_set_current_limit(0, min_t(u64, limit, 0x04000000), false);
> >  }
> >
> >  #ifdef CONFIG_RELOCATABLE
> > diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> > index 0cc7fbc..30fba80 100644
> > --- a/arch/powerpc/mm/hash_utils_64.c
> > +++ b/arch/powerpc/mm/hash_utils_64.c
> > @@ -925,7 +925,7 @@ static void __init htab_initialize(void)
> >               BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
> >                               prot, mmu_linear_psize, mmu_kernel_ssize));
> >       }
> > -     memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
> > +     memblock_set_current_limit(0, MEMBLOCK_ALLOC_ANYWHERE, false);
> >
> >       /*
> >        * If we have a memory_limit and we've allocated TCEs then we need to
> > @@ -1867,7 +1867,7 @@ void hash__setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >                       ppc64_rma_size = min_t(u64, ppc64_rma_size, 0x40000000);
> >
> >               /* Finally limit subsequent allocations */
> > -             memblock_set_current_limit(ppc64_rma_size);
> > +             memblock_set_current_limit(0, ppc64_rma_size, false);
> >       } else {
> >               ppc64_rma_size = ULONG_MAX;
> >       }
> > diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
> > index 3e59e5d..863d710 100644
> > --- a/arch/powerpc/mm/init_32.c
> > +++ b/arch/powerpc/mm/init_32.c
> > @@ -183,5 +183,5 @@ void __init MMU_init(void)
> >  #endif
> >
> >       /* Shortly after that, the entire linear mapping will be available */
> > -     memblock_set_current_limit(lowmem_end_addr);
> > +     memblock_set_current_limit(0, lowmem_end_addr, false);
> >  }
> > diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
> > index 9311560..8cd5f2d 100644
> > --- a/arch/powerpc/mm/pgtable-radix.c
> > +++ b/arch/powerpc/mm/pgtable-radix.c
> > @@ -603,7 +603,7 @@ void __init radix__early_init_mmu(void)
> >               radix_init_pseries();
> >       }
> >
> > -     memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
> > +     memblock_set_current_limit(0, MEMBLOCK_ALLOC_ANYWHERE, false);
> >
> >       radix_init_iamr();
> >       radix_init_pgtable();
> > diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
> > index f6f575b..80927ad 100644
> > --- a/arch/powerpc/mm/ppc_mmu_32.c
> > +++ b/arch/powerpc/mm/ppc_mmu_32.c
> > @@ -283,7 +283,11 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >
> >       /* 601 can only access 16MB at the moment */
> >       if (PVR_VER(mfspr(SPRN_PVR)) == 1)
> > -             memblock_set_current_limit(min_t(u64, first_memblock_size, 0x01000000));
> > +             memblock_set_current_limit(0,
> > +                     min_t(u64, first_memblock_size, 0x01000000),
> > +                     false);
> >       else /* Anything else has 256M mapped */
> > -             memblock_set_current_limit(min_t(u64, first_memblock_size, 0x10000000));
> > +             memblock_set_current_limit(0,
> > +                     min_t(u64, first_memblock_size, 0x10000000),
> > +                     false);
> >  }
> > diff --git a/arch/powerpc/mm/tlb_nohash.c b/arch/powerpc/mm/tlb_nohash.c
> > index ae5d568..d074362 100644
> > --- a/arch/powerpc/mm/tlb_nohash.c
> > +++ b/arch/powerpc/mm/tlb_nohash.c
> > @@ -735,7 +735,7 @@ static void __init early_mmu_set_memory_limit(void)
> >                * reduces the memory available to Linux.  We need to
> >                * do this because highmem is not supported on 64-bit.
> >                */
> > -             memblock_enforce_memory_limit(linear_map_top);
> > +             memblock_enforce_memory_limit(0, linear_map_top, false);
> >       }
> >  #endif
> >
> > @@ -792,7 +792,9 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
> >               ppc64_rma_size = min_t(u64, first_memblock_size, 0x40000000);
> >
> >       /* Finally limit subsequent allocations */
> > -     memblock_set_current_limit(first_memblock_base + ppc64_rma_size);
> > +     memblock_set_current_limit(0,
> > +                     first_memblock_base + ppc64_rma_size,
> > +                     false);
> >  }
> >  #else /* ! CONFIG_PPC64 */
> >  void __init early_init_mmu(void)
> > diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
> > index 040a8c2..6d62529 100644
> > --- a/arch/unicore32/mm/mmu.c
> > +++ b/arch/unicore32/mm/mmu.c
> > @@ -286,7 +286,7 @@ static void __init sanity_check_meminfo(void)
> >       int i, j;
> >
> >       lowmem_limit = __pa(vmalloc_min - 1) + 1;
> > -     memblock_set_current_limit(lowmem_limit);
> > +     memblock_set_current_limit(0, lowmem_limit, false);
> >
> >       for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
> >               struct membank *bank = &meminfo.bank[j];
> > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> > index dc8fc5d..a0122cd 100644
> > --- a/arch/x86/kernel/setup.c
> > +++ b/arch/x86/kernel/setup.c
> > @@ -1130,7 +1130,7 @@ void __init setup_arch(char **cmdline_p)
> >               memblock_set_bottom_up(true);
> >  #endif
> >       init_mem_mapping();
> > -     memblock_set_current_limit(get_max_mapped());
> > +     memblock_set_current_limit(0, get_max_mapped(), false);
> >
> >       idt_setup_early_pf();
> >
> > diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
> > index 30a48bb..b924387 100644
> > --- a/arch/xtensa/mm/init.c
> > +++ b/arch/xtensa/mm/init.c
> > @@ -60,7 +60,7 @@ void __init bootmem_init(void)
> >       max_pfn = PFN_DOWN(memblock_end_of_DRAM());
> >       max_low_pfn = min(max_pfn, MAX_LOW_PFN);
> >
> > -     memblock_set_current_limit(PFN_PHYS(max_low_pfn));
> > +     memblock_set_current_limit(0, PFN_PHYS(max_low_pfn), false);
> >       dma_contiguous_reserve(PFN_PHYS(max_low_pfn));
> >
> >       memblock_dump_all();
> > diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> > index aee299a..49676f0 100644
> > --- a/include/linux/memblock.h
> > +++ b/include/linux/memblock.h
> > @@ -88,6 +88,8 @@ struct memblock_type {
> >   */
> >  struct memblock {
> >       bool bottom_up;  /* is bottom up direction? */
> > +     bool enforce_checking;
> > +     phys_addr_t start_limit;
> >       phys_addr_t current_limit;
> >       struct memblock_type memory;
> >       struct memblock_type reserved;
> > @@ -482,12 +484,14 @@ static inline void memblock_dump_all(void)
> >   * memblock_set_current_limit - Set the current allocation limit to allow
> >   *                         limiting allocations to what is currently
> >   *                         accessible during boot
> > - * @limit: New limit value (physical address)
> > + * [start_limit, end_limit]: New limit value (physical address)
> > + * enforcing: whether check against the limit boundary or not
> >   */
> > -void memblock_set_current_limit(phys_addr_t limit);
> > +void memblock_set_current_limit(phys_addr_t start_limit,
> > +     phys_addr_t end_limit, bool enforcing);
> >
> >
> > -phys_addr_t memblock_get_current_limit(void);
> > +bool memblock_get_current_limit(phys_addr_t *start, phys_addr_t *end);
> >
> >  /*
> >   * pfn conversion functions
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 81ae63c..b792be0 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -116,6 +116,8 @@ struct memblock memblock __initdata_memblock = {
> >  #endif
> >
> >       .bottom_up              = false,
> > +     .enforce_checking       = false,
> > +     .start_limit            = 0,
> >       .current_limit          = MEMBLOCK_ALLOC_ANYWHERE,
> >  };
> >
> > @@ -261,8 +263,11 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
> >  {
> >       phys_addr_t kernel_end, ret;
> >
> > +     if (unlikely(memblock.enforce_checking)) {
> > +             start = memblock.start_limit;
> > +             end = memblock.current_limit;
> >       /* pump up @end */
> > -     if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> > +     } else if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
> >               end = memblock.current_limit;
> >
> >       /* avoid allocating the first page */
> > @@ -1826,14 +1831,22 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
> >       }
> >  }
> >
> > -void __init_memblock memblock_set_current_limit(phys_addr_t limit)
> > +void __init_memblock memblock_set_current_limit(phys_addr_t start,
> > +     phys_addr_t end, bool enforcing)
> >  {
> > -     memblock.current_limit = limit;
> > +     memblock.start_limit = start;
> > +     memblock.current_limit = end;
> > +     memblock.enforce_checking = enforcing;
> >  }
> >
> > -phys_addr_t __init_memblock memblock_get_current_limit(void)
> > +bool __init_memblock memblock_get_current_limit(phys_addr_t *start,
> > +     phys_addr_t *end)
> >  {
> > -     return memblock.current_limit;
> > +     if (start)
> > +             *start = memblock.start_limit;
> > +     if (end)
> > +             *end = memblock.current_limit;
> > +     return memblock.enforce_checking;
> >  }
> >
> >  static void __init_memblock memblock_dump(struct memblock_type *type)
> > --
> > 2.7.4
> >
>
> --
> Sincerely yours,
> Mike.
>
