Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE7A86B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 03:59:04 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x7-v6so6576978iob.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 00:59:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor404715ita.67.2018.04.20.00.58.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 00:58:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419214204.19322-1-stefan@agner.ch>
References: <20180419214204.19322-1-stefan@agner.ch>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 20 Apr 2018 09:58:15 +0200
Message-ID: <CAKv+Gu_PuSZFY_FKuGG6MCK7riMPmpU5pTWSULOph662kuQ56w@mail.gmail.com>
Subject: Re: [PATCH] treewide: use PHYS_ADDR_MAX to avoid type casting ULLONG_MAX
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Agner <stefan@agner.ch>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 19 April 2018 at 23:42, Stefan Agner <stefan@agner.ch> wrote:
> With PHYS_ADDR_MAX there is now a type safe variant for all
> bits set. Make use of it.
>
> Patch created using a sematic patch as follows:
>
> // <smpl>
> @@
> typedef phys_addr_t;
> @@
> -(phys_addr_t)ULLONG_MAX
> +PHYS_ADDR_MAX
> // </smpl>
>
> Signed-off-by: Stefan Agner <stefan@agner.ch>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  arch/arm64/mm/init.c               | 6 +++---
>  arch/mips/kernel/setup.c           | 4 ++--
>  arch/powerpc/mm/mem.c              | 2 +-
>  arch/sparc/mm/init_64.c            | 2 +-
>  arch/x86/mm/init_32.c              | 2 +-
>  arch/x86/mm/init_64.c              | 2 +-
>  drivers/firmware/efi/arm-init.c    | 2 +-
>  drivers/remoteproc/qcom_q6v5_pil.c | 2 +-
>  drivers/soc/qcom/mdt_loader.c      | 4 ++--
>  9 files changed, 13 insertions(+), 13 deletions(-)
>
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 9f3c47acf8ff..f48b19496141 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -310,7 +310,7 @@ static void __init arm64_memory_present(void)
>  }
>  #endif
>
> -static phys_addr_t memory_limit = (phys_addr_t)ULLONG_MAX;
> +static phys_addr_t memory_limit = PHYS_ADDR_MAX;
>
>  /*
>   * Limit the memory size that was specified via FDT.
> @@ -401,7 +401,7 @@ void __init arm64_memblock_init(void)
>          * high up in memory, add back the kernel region that must be accessible
>          * via the linear mapping.
>          */
> -       if (memory_limit != (phys_addr_t)ULLONG_MAX) {
> +       if (memory_limit != PHYS_ADDR_MAX) {
>                 memblock_mem_limit_remove_map(memory_limit);
>                 memblock_add(__pa_symbol(_text), (u64)(_end - _text));
>         }
> @@ -664,7 +664,7 @@ __setup("keepinitrd", keepinitrd_setup);
>   */
>  static int dump_mem_limit(struct notifier_block *self, unsigned long v, void *p)
>  {
> -       if (memory_limit != (phys_addr_t)ULLONG_MAX) {
> +       if (memory_limit != PHYS_ADDR_MAX) {
>                 pr_emerg("Memory Limit: %llu MB\n", memory_limit >> 20);
>         } else {
>                 pr_emerg("Memory Limit: none\n");
> diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
> index 563188ac6fa2..2c96c0c68116 100644
> --- a/arch/mips/kernel/setup.c
> +++ b/arch/mips/kernel/setup.c
> @@ -93,7 +93,7 @@ void __init add_memory_region(phys_addr_t start, phys_addr_t size, long type)
>          * If the region reaches the top of the physical address space, adjust
>          * the size slightly so that (start + size) doesn't overflow
>          */
> -       if (start + size - 1 == (phys_addr_t)ULLONG_MAX)
> +       if (start + size - 1 == PHYS_ADDR_MAX)
>                 --size;
>
>         /* Sanity check */
> @@ -376,7 +376,7 @@ static void __init bootmem_init(void)
>         unsigned long reserved_end;
>         unsigned long mapstart = ~0UL;
>         unsigned long bootmap_size;
> -       phys_addr_t ramstart = (phys_addr_t)ULLONG_MAX;
> +       phys_addr_t ramstart = PHYS_ADDR_MAX;
>         bool bootmap_valid = false;
>         int i;
>
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 737f8a4632cc..7607a509c695 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -213,7 +213,7 @@ void __init mem_topology_setup(void)
>         /* Place all memblock_regions in the same node and merge contiguous
>          * memblock_regions
>          */
> -       memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
> +       memblock_set_node(0, PHYS_ADDR_MAX, &memblock.memory, 0);
>  }
>
>  void __init initmem_init(void)
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 8aeb1aabe76e..f396048a0d68 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -1620,7 +1620,7 @@ static void __init bootmem_init_nonnuma(void)
>                (top_of_ram - total_ram) >> 20);
>
>         init_node_masks_nonnuma();
> -       memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
> +       memblock_set_node(0, PHYS_ADDR_MAX, &memblock.memory, 0);
>         allocate_node_data(0);
>         node_set_online(0);
>  }
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index c893c6a3d707..979e0a02cbe1 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -692,7 +692,7 @@ void __init initmem_init(void)
>         high_memory = (void *) __va(max_low_pfn * PAGE_SIZE - 1) + 1;
>  #endif
>
> -       memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
> +       memblock_set_node(0, PHYS_ADDR_MAX, &memblock.memory, 0);
>         sparse_memory_present_with_active_regions(0);
>
>  #ifdef CONFIG_FLATMEM
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 0a400606dea0..765a50fb6364 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -742,7 +742,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
>  #ifndef CONFIG_NUMA
>  void __init initmem_init(void)
>  {
> -       memblock_set_node(0, (phys_addr_t)ULLONG_MAX, &memblock.memory, 0);
> +       memblock_set_node(0, PHYS_ADDR_MAX, &memblock.memory, 0);
>  }
>  #endif
>
> diff --git a/drivers/firmware/efi/arm-init.c b/drivers/firmware/efi/arm-init.c
> index 80d1a885def5..b5214c143fee 100644
> --- a/drivers/firmware/efi/arm-init.c
> +++ b/drivers/firmware/efi/arm-init.c
> @@ -193,7 +193,7 @@ static __init void reserve_regions(void)
>          * uses its own memory map instead.
>          */
>         memblock_dump_all();
> -       memblock_remove(0, (phys_addr_t)ULLONG_MAX);
> +       memblock_remove(0, PHYS_ADDR_MAX);
>
>         for_each_efi_memory_desc(md) {
>                 paddr = md->phys_addr;
> diff --git a/drivers/remoteproc/qcom_q6v5_pil.c b/drivers/remoteproc/qcom_q6v5_pil.c
> index 8e70a627e0bb..da8edf3f85b3 100644
> --- a/drivers/remoteproc/qcom_q6v5_pil.c
> +++ b/drivers/remoteproc/qcom_q6v5_pil.c
> @@ -615,7 +615,7 @@ static int q6v5_mpss_load(struct q6v5 *qproc)
>         struct elf32_hdr *ehdr;
>         phys_addr_t mpss_reloc;
>         phys_addr_t boot_addr;
> -       phys_addr_t min_addr = (phys_addr_t)ULLONG_MAX;
> +       phys_addr_t min_addr = PHYS_ADDR_MAX;
>         phys_addr_t max_addr = 0;
>         bool relocate = false;
>         char seg_name[10];
> diff --git a/drivers/soc/qcom/mdt_loader.c b/drivers/soc/qcom/mdt_loader.c
> index 17b314d9a148..dc09d7ac905f 100644
> --- a/drivers/soc/qcom/mdt_loader.c
> +++ b/drivers/soc/qcom/mdt_loader.c
> @@ -50,7 +50,7 @@ ssize_t qcom_mdt_get_size(const struct firmware *fw)
>         const struct elf32_phdr *phdrs;
>         const struct elf32_phdr *phdr;
>         const struct elf32_hdr *ehdr;
> -       phys_addr_t min_addr = (phys_addr_t)ULLONG_MAX;
> +       phys_addr_t min_addr = PHYS_ADDR_MAX;
>         phys_addr_t max_addr = 0;
>         int i;
>
> @@ -97,7 +97,7 @@ int qcom_mdt_load(struct device *dev, const struct firmware *fw,
>         const struct elf32_hdr *ehdr;
>         const struct firmware *seg_fw;
>         phys_addr_t mem_reloc;
> -       phys_addr_t min_addr = (phys_addr_t)ULLONG_MAX;
> +       phys_addr_t min_addr = PHYS_ADDR_MAX;
>         phys_addr_t max_addr = 0;
>         size_t fw_name_len;
>         ssize_t offset;
> --
> 2.17.0
>
