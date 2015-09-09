Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id B70126B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 10:16:10 -0400 (EDT)
Received: by iofh134 with SMTP id h134so23606626iof.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:16:10 -0700 (PDT)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com. [209.85.223.173])
        by mx.google.com with ESMTPS id ax3si2283027igc.94.2015.09.09.07.16.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 07:16:09 -0700 (PDT)
Received: by iofb144 with SMTP id b144so23597484iof.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:16:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440609097-14836-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440609097-14836-1-git-send-email-izumi.taku@jp.fujitsu.com>
Date: Wed, 9 Sep 2015 16:16:09 +0200
Message-ID: <CAKv+Gu88nxLQk5R2SGo0pnDA0VyTBvZT6oxLV-Uwc3=3wqjSaA@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] x86, efi: Add "efi_fake_mem_mirror" boot option
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 26 August 2015 at 19:11, Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:
> This patch introduces new boot option named "efi_fake_mem_mirror".
> By specifying this parameter, you can mark specific memory as
> mirrored memory. This is useful for debugging of Address Range
> Mirroring feature.
>
> For example, if you specify "efi_fake_mem_mirror=2G@4G,2G@0x10a0000000",
> the original (firmware provided) EFI memmap will be updated so that
> the specified memory regions have EFI_MEMORY_MORE_RELIABLE attribute:
>
>  <original EFI memmap>
>    efi: mem00: [Boot Data          |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000000000-0x0000000000001000) (0MB)
>    efi: mem01: [Loader Data        |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000001000-0x0000000000002000) (0MB)
>    ...
>    efi: mem35: [Boot Data          |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000047ee6000-0x0000000048014000) (1MB)
>    efi: mem36: [Conventional Memory|  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000100000000-0x00000020a0000000) (129536MB)
>    efi: mem37: [Reserved           |RT|  |  |  |  |   |  |  |  |UC] range=[0x0000000060000000-0x0000000090000000) (768MB)
>
>  <updated EFI memmap>
>    efi: mem00: [Boot Data          |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000000000-0x0000000000001000) (0MB)
>    efi: mem01: [Loader Data        |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000000001000-0x0000000000002000) (0MB)
>    ...
>    efi: mem35: [Boot Data          |  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000047ee6000-0x0000000048014000) (1MB)
>    efi: mem36: [Conventional Memory|  |MR|  |  |  |   |WB|WT|WC|UC] range=[0x0000000100000000-0x0000000180000000) (2048MB)
>    efi: mem37: [Conventional Memory|  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000000180000000-0x00000010a0000000) (61952MB)
>    efi: mem38: [Conventional Memory|  |MR|  |  |  |   |WB|WT|WC|UC] range=[0x00000010a0000000-0x0000001120000000) (2048MB)
>    efi: mem39: [Conventional Memory|  |  |  |  |  |   |WB|WT|WC|UC] range=[0x0000001120000000-0x00000020a0000000) (63488MB)
>    efi: mem40: [Reserved           |RT|  |  |  |  |   |  |  |  |UC] range=[0x0000000060000000-0x0000000090000000) (768MB)
>
> And you will find that the following message is output:
>
>    efi: Memory: 4096M/131455M mirrored memory
>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Hello Taku,

To be honest, I think that the naming of this feature is poorly
chosen. The UEFI spec gets it right by using 'MORE_RELIABLE'. Since
one way to implement more reliable memory ranges is mirroring, the
implementation detail of that has leaked into the generic naming,
which is confusing. Not your fault though, just something I wanted to
highlight.

So first of all, could you please update the example so that it only
shows a single more reliable region (or two but of different sizes)?
It took me a while to figure out that those 2 GB regions are not
mirrors of each other in any way, they are simply two separate regions
that are marked as more reliable than the remaining memory.

I do wonder if this functionality belongs in the kernel, though. I see
how it could be useful, and you can keep it as a local hack, but
generally, the firmware (OVMF?) is a better way to play around with
code like this, I think?

-- 
Ard.

> ---
>  Documentation/kernel-parameters.txt |   8 ++
>  arch/x86/include/asm/efi.h          |   1 +
>  arch/x86/kernel/setup.c             |   4 +-
>  arch/x86/platform/efi/efi.c         |   2 +-
>  drivers/firmware/efi/Kconfig        |  12 +++
>  drivers/firmware/efi/Makefile       |   1 +
>  drivers/firmware/efi/fake_mem.c     | 204 ++++++++++++++++++++++++++++++++++++
>  include/linux/efi.h                 |   6 ++
>  8 files changed, 236 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/firmware/efi/fake_mem.c
>
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 1d6f045..0efded6 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1092,6 +1092,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>                         you are really sure that your UEFI does sane gc and
>                         fulfills the spec otherwise your board may brick.
>
> +       efi_fake_mem_mirror=nn[KMG]@ss[KMG][,nn[KMG]@ss[KMG],..] [EFI; X86]
> +                       Mark specific memory as mirrored memory and update
> +                       EFI memory map.
> +                       Region of memory to be marked is from ss to ss+nn.
> +                       Using this parameter you can do debugging of Address
> +                       Range Mirroring feature even if your box doesn't support
> +                       it.
> +
>         eisa_irq_edge=  [PARISC,HW]
>                         See header of drivers/parisc/eisa.c.
>
> diff --git a/arch/x86/include/asm/efi.h b/arch/x86/include/asm/efi.h
> index 155162e..479fd51 100644
> --- a/arch/x86/include/asm/efi.h
> +++ b/arch/x86/include/asm/efi.h
> @@ -93,6 +93,7 @@ extern void __init efi_set_executable(efi_memory_desc_t *md, bool executable);
>  extern int __init efi_memblock_x86_reserve_range(void);
>  extern pgd_t * __init efi_call_phys_prolog(void);
>  extern void __init efi_call_phys_epilog(pgd_t *save_pgd);
> +extern void __init print_efi_memmap(void);
>  extern void __init efi_unmap_memmap(void);
>  extern void __init efi_memory_uc(u64 addr, unsigned long size);
>  extern void __init efi_map_region(efi_memory_desc_t *md);
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 80f874b..e3ed628 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1104,8 +1104,10 @@ void __init setup_arch(char **cmdline_p)
>         memblock_set_current_limit(ISA_END_ADDRESS);
>         memblock_x86_fill();
>
> -       if (efi_enabled(EFI_BOOT))
> +       if (efi_enabled(EFI_BOOT)) {
> +               efi_fake_memmap();
>                 efi_find_mirror();
> +       }
>
>         /*
>          * The EFI specification says that boot service code won't be called
> diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
> index e4308fe..eee8068 100644
> --- a/arch/x86/platform/efi/efi.c
> +++ b/arch/x86/platform/efi/efi.c
> @@ -222,7 +222,7 @@ int __init efi_memblock_x86_reserve_range(void)
>         return 0;
>  }
>
> -static void __init print_efi_memmap(void)
> +void __init print_efi_memmap(void)
>  {
>  #ifdef EFI_DEBUG
>         efi_memory_desc_t *md;
> diff --git a/drivers/firmware/efi/Kconfig b/drivers/firmware/efi/Kconfig
> index 54071c1..4fafebe 100644
> --- a/drivers/firmware/efi/Kconfig
> +++ b/drivers/firmware/efi/Kconfig
> @@ -52,6 +52,18 @@ config EFI_RUNTIME_MAP
>
>           See also Documentation/ABI/testing/sysfs-firmware-efi-runtime-map.
>
> +config EFI_FAKE_MEMMAP
> +       bool "Enable EFI Fake memory mirror"
> +       depends on EFI && X86
> +       default n
> +       help
> +         Saying Y here will enable "efi_fake_mem_miror" boot option.
> +         By specifying this parameter, you can mark specific memory as
> +         mirrored memory by updating original (firmware provided) EFI memmap.
> +         This is useful for debugging of Memory Address Range Mirroring
> +         feature.
> +
> +
>  config EFI_PARAMS_FROM_FDT
>         bool
>         help
> diff --git a/drivers/firmware/efi/Makefile b/drivers/firmware/efi/Makefile
> index 6fd3da9..c24f005 100644
> --- a/drivers/firmware/efi/Makefile
> +++ b/drivers/firmware/efi/Makefile
> @@ -9,3 +9,4 @@ obj-$(CONFIG_UEFI_CPER)                 += cper.o
>  obj-$(CONFIG_EFI_RUNTIME_MAP)          += runtime-map.o
>  obj-$(CONFIG_EFI_RUNTIME_WRAPPERS)     += runtime-wrappers.o
>  obj-$(CONFIG_EFI_STUB)                 += libstub/
> +obj-$(CONFIG_EFI_FAKE_MEMMAP)          += fake_mem.o
> diff --git a/drivers/firmware/efi/fake_mem.c b/drivers/firmware/efi/fake_mem.c
> new file mode 100644
> index 0000000..2645d4a
> --- /dev/null
> +++ b/drivers/firmware/efi/fake_mem.c
> @@ -0,0 +1,204 @@
> +/*
> + * fake_mem.c
> + *
> + * Copyright (C) 2015 FUJITSU LIMITED
> + * Author: Taku Izumi <izumi.taku@jp.fujitsu.com>
> + *
> + * This code introduces new boot option named "efi_fake_mem_mirror"
> + * By specifying this parameter, you can mark specific memory as
> + * mirrored memory by updating original (firmware provided) EFI
> + * memmap.
> + *
> + *  This program is free software; you can redistribute it and/or modify it
> + *  under the terms and conditions of the GNU General Public License,
> + *  version 2, as published by the Free Software Foundation.
> + *
> + *  This program is distributed in the hope it will be useful, but WITHOUT
> + *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + *  more details.
> + *
> + *  You should have received a copy of the GNU General Public License along with
> + *  this program; if not, see <http://www.gnu.org/licenses/>.
> + *
> + *  The full GNU General Public License is included in this distribution in
> + *  the file called "COPYING".
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/efi.h>
> +#include <linux/init.h>
> +#include <linux/memblock.h>
> +#include <linux/types.h>
> +#include <asm/efi.h>
> +
> +#define EFI_MAX_FAKE_MIRROR 8
> +static struct range fake_mirrors[EFI_MAX_FAKE_MIRROR];
> +static int num_fake_mirror;
> +
> +void __init efi_fake_memmap(void)
> +{
> +       u64 start, end, m_start, m_end;
> +       int new_nr_map = memmap.nr_map;
> +       efi_memory_desc_t *md;
> +       u64 new_memmap_phy;
> +       void *new_memmap;
> +       void *old, *new;
> +       int i;
> +
> +       if (!num_fake_mirror)
> +               return;
> +
> +       /* count up the number of EFI memory descriptor */
> +       for (old = memmap.map; old < memmap.map_end; old += memmap.desc_size) {
> +               md = old;
> +               start = md->phys_addr;
> +               end = start + (md->num_pages << EFI_PAGE_SHIFT) - 1;
> +
> +               for (i = 0; i < num_fake_mirror; i++) {
> +                       /* mirroring range */
> +                       m_start = fake_mirrors[i].start;
> +                       m_end = fake_mirrors[i].end;
> +
> +                       if (m_start <= start) {
> +                               /* split into 2 parts */
> +                               if (start < m_end && m_end < end)
> +                                       new_nr_map++;
> +                       }
> +                       if (start < m_start && m_start < end) {
> +                               /* split into 3 parts */
> +                               if (m_end < end)
> +                                       new_nr_map += 2;
> +                               /* split into 2 parts */
> +                               if (end <= m_end)
> +                                       new_nr_map++;
> +                       }
> +               }
> +       }
> +
> +       /* allocate memory for new EFI memmap */
> +       new_memmap_phy = memblock_alloc(memmap.desc_size * new_nr_map,
> +                                       PAGE_SIZE);
> +       if (!new_memmap_phy)
> +               return;
> +
> +       /* create new EFI memmap */
> +       new_memmap = early_memremap(new_memmap_phy,
> +                                   memmap.desc_size * new_nr_map);
> +       for (old = memmap.map, new = new_memmap;
> +            old < memmap.map_end;
> +            old += memmap.desc_size, new += memmap.desc_size) {
> +
> +               /* copy original EFI memory descriptor */
> +               memcpy(new, old, memmap.desc_size);
> +               md = new;
> +               start = md->phys_addr;
> +               end = md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT) - 1;
> +
> +               for (i = 0; i < num_fake_mirror; i++) {
> +                       /* mirroring range */
> +                       m_start = fake_mirrors[i].start;
> +                       m_end = fake_mirrors[i].end;
> +
> +                       if (m_start <= start && end <= m_end)
> +                               md->attribute |= EFI_MEMORY_MORE_RELIABLE;
> +
> +                       if (m_start <= start &&
> +                           (start < m_end && m_end < end)) {
> +                               /* first part */
> +                               md->attribute |= EFI_MEMORY_MORE_RELIABLE;
> +                               md->num_pages = (m_end - md->phys_addr + 1) >>
> +                                       EFI_PAGE_SHIFT;
> +                               /* latter part */
> +                               new += memmap.desc_size;
> +                               memcpy(new, old, memmap.desc_size);
> +                               md = new;
> +                               md->phys_addr = m_end + 1;
> +                               md->num_pages = (end - md->phys_addr + 1) >>
> +                                       EFI_PAGE_SHIFT;
> +                       }
> +
> +                       if ((start < m_start && m_start < end) && m_end < end) {
> +                               /* first part */
> +                               md->num_pages = (m_start - md->phys_addr) >>
> +                                       EFI_PAGE_SHIFT;
> +                               /* middle part */
> +                               new += memmap.desc_size;
> +                               memcpy(new, old, memmap.desc_size);
> +                               md = new;
> +                               md->attribute |= EFI_MEMORY_MORE_RELIABLE;
> +                               md->phys_addr = m_start;
> +                               md->num_pages = (m_end - m_start + 1) >>
> +                                       EFI_PAGE_SHIFT;
> +                               /* last part */
> +                               new += memmap.desc_size;
> +                               memcpy(new, old, memmap.desc_size);
> +                               md = new;
> +                               md->phys_addr = m_end + 1;
> +                               md->num_pages = (end - m_end) >>
> +                                       EFI_PAGE_SHIFT;
> +                       }
> +
> +                       if ((start < m_start && m_start < end) &&
> +                           (end <= m_end)) {
> +                               /* first part */
> +                               md->num_pages = (m_start - md->phys_addr) >>
> +                                       EFI_PAGE_SHIFT;
> +                               /* latter part */
> +                               new += memmap.desc_size;
> +                               memcpy(new, old, memmap.desc_size);
> +                               md = new;
> +                               md->phys_addr = m_start;
> +                               md->num_pages = (end - md->phys_addr + 1) >>
> +                                       EFI_PAGE_SHIFT;
> +                               md->attribute |= EFI_MEMORY_MORE_RELIABLE;
> +                       }
> +               }
> +       }
> +
> +       /* swap into new EFI memmap */
> +       efi_unmap_memmap();
> +       memmap.map = new_memmap;
> +       memmap.phys_map = (void *)new_memmap_phy;
> +       memmap.nr_map = new_nr_map;
> +       memmap.map_end = memmap.map + memmap.nr_map * memmap.desc_size;
> +       set_bit(EFI_MEMMAP, &efi.flags);
> +
> +       /* print new EFI memmap */
> +       print_efi_memmap();
> +}
> +
> +static int __init setup_fake_mem_mirror(char *p)
> +{
> +       u64 start = 0, mem_size = 0;
> +       int i;
> +
> +       if (!p)
> +               return -EINVAL;
> +
> +       while (*p != '\0') {
> +               mem_size = memparse(p, &p);
> +               if (*p == '@')
> +                       start = memparse(p+1, &p);
> +               else
> +                       break;
> +
> +               num_fake_mirror = add_range_with_merge(fake_mirrors,
> +                                                      EFI_MAX_FAKE_MIRROR,
> +                                                      num_fake_mirror,
> +                                                      start,
> +                                                      start + mem_size - 1);
> +               if (*p == ',')
> +                       p++;
> +       }
> +
> +       sort_range(fake_mirrors, num_fake_mirror);
> +
> +       for (i = 0; i < num_fake_mirror; i++)
> +               pr_info("efi_fake_mem_mirror: [mem 0x%016llx-0x%016llx] marked as mirrored memory",
> +                       fake_mirrors[i].start, fake_mirrors[i].end);
> +
> +       return *p == '\0' ? 0 : -EINVAL;
> +}
> +
> +early_param("efi_fake_mem_mirror", setup_fake_mem_mirror);
> diff --git a/include/linux/efi.h b/include/linux/efi.h
> index 85ef051..620baec 100644
> --- a/include/linux/efi.h
> +++ b/include/linux/efi.h
> @@ -908,6 +908,12 @@ extern struct kobject *efi_kobj;
>  extern int efi_reboot_quirk_mode;
>  extern bool efi_poweroff_required(void);
>
> +#ifdef CONFIG_EFI_FAKE_MEMMAP
> +extern void __init efi_fake_memmap(void);
> +#else
> +static inline void efi_fake_memmap(void) { }
> +#endif
> +
>  /* Iterate through an efi_memory_map */
>  #define for_each_efi_memory_desc(m, md)                                           \
>         for ((md) = (m)->map;                                              \
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
