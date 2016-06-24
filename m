Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE076B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 06:43:54 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u81so125709417oia.3
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:43:54 -0700 (PDT)
Received: from mail-it0-x234.google.com (mail-it0-x234.google.com. [2607:f8b0:4001:c0b::234])
        by mx.google.com with ESMTPS id c98si5725734ioa.83.2016.06.24.03.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 03:43:53 -0700 (PDT)
Received: by mail-it0-x234.google.com with SMTP id a5so11985875ita.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:43:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1466738027-15066-2-git-send-email-dennis.chen@arm.com>
References: <1466738027-15066-1-git-send-email-dennis.chen@arm.com> <1466738027-15066-2-git-send-email-dennis.chen@arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 24 Jun 2016 12:43:52 +0200
Message-ID: <CAKv+Gu8ZyWG-OZ8=2u9jrdS-0j+qL1sstPQ0uX=j7wyj+ETo-w@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] arm64:acpi Fix the acpi alignment exeception when
 'mem=' specified
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Chen <dennis.chen@arm.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, nd@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Matt Fleming <matt@codeblueprint.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>

On 24 June 2016 at 05:13, Dennis Chen <dennis.chen@arm.com> wrote:
> When booting an ACPI enabled kernel with 'mem=', probably the ACPI data
> regions loaded by firmware will beyond the limit of the memory, in this
> case we need to nomap the region above the limit while not removing
> it from memblock, because once region removed from memblock, the ACPI
> will think that region is not a normal memory and map it as device type
> memory accordingly. Since the ACPI core will produce non-alignment access
> when paring AML data stream, hence result in alignment fault upon the io
> mapped memory space.
>
> For example, below is an alignment exception observed on softIron board
> when booting the kernel with 'acpi=force mem=8G':
> ...
> [ 0.542475] Unable to handle kernel paging request at virtual address ffff0000080521e7
> [ 0.550457] pgd = ffff000008aa0000
> [ 0.553880] [ffff0000080521e7] *pgd=000000801fffe003, *pud=000000801fffd003, *pmd=000000801fffc003, *pte=00e80083ff1c1707
> [    0.564939] Internal error: Oops: 96000021 [#1] PREEMPT SMP
> [    0.570553] Modules linked in:
> [    0.573626] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.7.0-rc3-next-20160616+ #172
> [    0.581344] Hardware name: AMD Overdrive/Supercharger/Default string, BIOS ROD1001A 02/09/2016
> [    0.590025] task: ffff800001ef0000 ti: ffff800001ef8000 task.ti: ffff800001ef8000
> [    0.597571] PC is at acpi_ns_lookup+0x520/0x734
> [    0.602134] LR is at acpi_ns_lookup+0x4a4/0x734
> [    0.606693] pc : [<ffff0000083b8b10>] lr : [<ffff0000083b8a94>] pstate: 60000045
> [    0.614145] sp : ffff800001efb8b0
> [    0.617478] x29: ffff800001efb8c0 x28: 000000000000001b
> [    0.622829] x27: 0000000000000001 x26: 0000000000000000
> [    0.628181] x25: ffff800001efb9e8 x24: ffff000008a10000
> [    0.633531] x23: 0000000000000001 x22: 0000000000000001
> [    0.638881] x21: ffff000008724000 x20: 000000000000001b
> [    0.644230] x19: ffff0000080521e7 x18: 000000000000000d
> [    0.649580] x17: 00000000000038ff x16: 0000000000000002
> [    0.654929] x15: 0000000000000007 x14: 0000000000007fff
> [    0.660278] x13: ffffff0000000000 x12: 0000000000000018
> [    0.665627] x11: 000000001fffd200 x10: 00000000ffffff76
> [    0.670978] x9 : 000000000000005f x8 : ffff000008725fa8
> [    0.676328] x7 : ffff000008a8df70 x6 : ffff000008a8df70
> [    0.681679] x5 : ffff000008a8d000 x4 : 0000000000000010
> [    0.687027] x3 : 0000000000000010 x2 : 000000000000000c
> [    0.692378] x1 : 0000000000000006 x0 : 0000000000000000
> ...
> [    1.262235] [<ffff0000083b8b10>] acpi_ns_lookup+0x520/0x734
> [    1.267845] [<ffff0000083a7160>] acpi_ds_load1_begin_op+0x174/0x4fc
> [    1.274156] [<ffff0000083c1f4c>] acpi_ps_build_named_op+0xf8/0x220
> [    1.280380] [<ffff0000083c227c>] acpi_ps_create_op+0x208/0x33c
> [    1.286254] [<ffff0000083c1820>] acpi_ps_parse_loop+0x204/0x838
> [    1.292215] [<ffff0000083c2fd4>] acpi_ps_parse_aml+0x1bc/0x42c
> [    1.298090] [<ffff0000083bc6e8>] acpi_ns_one_complete_parse+0x1e8/0x22c
> [    1.304753] [<ffff0000083bc7b8>] acpi_ns_parse_table+0x8c/0x128
> [    1.310716] [<ffff0000083bb8fc>] acpi_ns_load_table+0xc0/0x1e8
> [    1.316591] [<ffff0000083c9068>] acpi_tb_load_namespace+0xf8/0x2e8
> [    1.322818] [<ffff000008984128>] acpi_load_tables+0x7c/0x110
> [    1.328516] [<ffff000008982ea4>] acpi_init+0x90/0x2c0
> [    1.333603] [<ffff0000080819fc>] do_one_initcall+0x38/0x12c
> [    1.339215] [<ffff000008960cd4>] kernel_init_freeable+0x148/0x1ec
> [    1.345353] [<ffff0000086b7d30>] kernel_init+0x10/0xec
> [    1.350529] [<ffff000008084e10>] ret_from_fork+0x10/0x40
> [    1.355878] Code: b9009fbc 2a00037b 36380057 3219037b (b9400260)
> [    1.362035] ---[ end trace 03381e5eb0a24de4 ]---
> [    1.366691] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
>
> With 'efi=debug', we can see those ACPI regions loaded by firmware on
> that board as:
> [    0.000000] efi:   0x0083ff1b5000-0x0083ff1c2fff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]*
> [    0.000000] efi:   0x0083ff223000-0x0083ff224fff [ACPI Memory NVS    |   |  |  |  |  |  |  |   |WB|WT|WC|UC]*
>
> This patch is trying to address the above issues by nomaping the region
> instead of removing it.
>
> Signed-off-by: Dennis Chen <dennis.chen@arm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Matt Fleming <matt@codeblueprint.co.uk>
> Cc: linux-mm@kvack.org
> Cc: linux-acpi@vger.kernel.org
> Cc: linux-efi@vger.kernel.org
> ---
> Changes in v2:
> Update the commit message and remove the memblock_is_map_memory() check
> according to the suggestion from Mark Rutland.
>
>  arch/arm64/mm/init.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index d45f862..6af2456 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -222,12 +222,13 @@ void __init arm64_memblock_init(void)
>
>         /*
>          * Apply the memory limit if it was set. Since the kernel may be loaded
> -        * high up in memory, add back the kernel region that must be accessible
> -        * via the linear mapping.
> +        * in the memory regions above the limit, so we need to clear the
> +        * MEMBLOCK_NOMAP flag of this region to make it can be accessible via
> +        * the linear mapping.
>          */
>         if (memory_limit != (phys_addr_t)ULLONG_MAX) {
> -               memblock_enforce_memory_limit(memory_limit);
> -               memblock_add(__pa(_text), (u64)(_end - _text));
> +               memblock_mem_limit_mark_nomap(memory_limit);
> +               memblock_clear_nomap(__pa(_text), (u64)(_end - _text));

Up until now, we have ignored the effect of having NOMAP memblocks on
the return values of functions like memblock_phys_mem_size() and
memblock_mem_size(), since they could reasonably be expected to cover
only a small slice of all available memory. However, after applying
this patch, it may well be the case that most of memory is marked
NOMAP, and these functions will cease to work as expected.

This means NOMAP is really only suited to punch some holes into the
kernel direct mapping, and so implementing the memory limit by marking
everything NOMAP is not the way to go. Instead, we should probably
reorder the init sequence so that the regions that are reserved in the
UEFI memory map are declared and marked NOMAP [again] after applying
the memory limit in the old way.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
