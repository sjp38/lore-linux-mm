Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86F236B0038
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 22:17:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so104483260pfg.0
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 19:17:52 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id m29si41835152pgn.94.2016.12.11.19.17.49
        for <linux-mm@kvack.org>;
        Sun, 11 Dec 2016 19:17:50 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: Fix NOMAP page initialization
References: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
Date: Mon, 12 Dec 2016 11:12:13 +0800
MIME-Version: 1.0
In-Reply-To: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <rrichter@cavium.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

hi Robert,

On 2016/12/10 2:10, Robert Richter wrote:
> On ThunderX systems with certain memory configurations we see the
> following BUG_ON():
> 
>  kernel BUG at mm/page_alloc.c:1848!
> 
> This happens for some configs with 64k page size enabled. The BUG_ON()
> checks if start and end page of a memmap range belongs to the same
> zone.
> 
> The BUG_ON() check fails if a memory zone contains NOMAP regions. In
> this case the node information of those pages is not initialized. This
> causes an inconsistency of the page links with wrong zone and node
> information for that pages. NOMAP pages from node 1 still point to the
> mem zone from node 0 and have the wrong nid assigned.
> 
The patch can work for zone contains NOMAP regions.

However, if BIOS do not add WB/WT/WC attribute to a physical address range, the
is_memory(md) will return false and this range will not be added to memblock.
   efi_init
      -> reserve_regions
            if (is_memory(md)) {
                early_init_dt_add_memory_arch(paddr, size);

                if (!is_usable_memory(md))
                    memblock_mark_nomap(paddr, size);
            }

Then BUG_ON() check will also fails. Any idea about it?

Here is the crash log I got from D05:
crash log---------------
[    0.000000] Booting Linux on physical CPU 0x10000
[    0.000000] Linux version 4.9.0-rc8+ (xys@linux-ibm) (gcc version 6.1.1 20160711 (Linaro GCC 6.1-2016.08) ) #61 SMP Fri Dec 9 19:46:24 CST 2016
[    0.000000] Boot CPU: AArch64 Processor [410fd082]
[    0.000000] earlycon: pl11 at MMIO32 0x00000000602b0000 (options '')
[    0.000000] bootconsole [pl11] enabled
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi:   System Table: 0x000000003f150018
[    0.000000] efi:   MemMap Address: 0x0000000031b33018
[    0.000000] efi:   MemMap Size: 0x000009f0
[    0.000000] efi:   MemMap Desc. Size: 0x00000030
[    0.000000] efi:   MemMap Desc. Version: 0x00000001
[    0.000000] efi: EFI v2.60 by EDK II
[    0.000000] efi:  SMBIOS=0x3f130000  SMBIOS 3.0=0x39ca0000  ACPI=0x39d70000  ACPI 2.0=0x39d70014  MEMATTR=0x3ce14018
[    0.000000] efi: Processing EFI memory map:
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0x0 reserved size = 0x1000
[    0.000000]  memory.cnt  = 0x1
[    0.000000]  memory[0x0]	[0x00000000000000-0xffffffffffffffff], 0x0 bytes on node 0 flags: 0x0
[    0.000000]  reserved.cnt  = 0x1
[    0.000000]  reserved[0x0]	[0x0000001e400000-0x0000001e400fff], 0x1000 bytes flags: 0x0
[    0.000000] efi:   0x000000000000-0x00000007ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000000000000-0x0000000007ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000000080000-0x0000016cffff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000000080000-0x000000016cffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x0000016d0000-0x00001e3fffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x000000016d0000-0x0000001e3fffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00001e400000-0x00001e40ffff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000001e400000-0x0000001e40ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00001e410000-0x00001e47ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000001e410000-0x0000001e47ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00001e480000-0x00001fffffff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000001e480000-0x0000001fffffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000020000000-0x00002fbfffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000020000000-0x0000002fbfffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00002fc00000-0x00002fc1ffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000002fc00000-0x0000002fc1ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00002fc20000-0x00003049cfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000002fc20000-0x0000003049ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003049d000-0x000031b0ffff [Loader Code        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000030490000-0x00000031b0ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031b10000-0x000031b2ffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031b10000-0x00000031b2ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031b30000-0x000031b32fff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031b30000-0x00000031b3ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031b33000-0x000031b33fff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031b30000-0x00000031b3ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031b34000-0x000031b37fff [Reserved           |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031b30000-0x00000031b3ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031b38000-0x000031baefff [Boot Code          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031b30000-0x00000031baffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000031baf000-0x000039baffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000031ba0000-0x00000039baffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039bb0000-0x000039beffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039bb0000-0x00000039beffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039bf0000-0x000039c3ffff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039bf0000-0x00000039c3ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039c40000-0x000039c4ffff [ACPI Memory NVS    |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039c40000-0x00000039c4ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039c50000-0x000039c8ffff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039c50000-0x00000039c8ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039c90000-0x000039d0ffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039c90000-0x00000039d0ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039d10000-0x000039d5ffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039d10000-0x00000039d5ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039d60000-0x000039d7ffff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039d60000-0x00000039d7ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039d80000-0x000039dcffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039d80000-0x00000039dcffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039dd0000-0x000039e1ffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039dd0000-0x00000039e1ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039e20000-0x000039e6ffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039e20000-0x00000039e6ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039e70000-0x000039f3ffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039e70000-0x00000039f3ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039f40000-0x000039faffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039f40000-0x00000039faffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x000039fb0000-0x000039ffffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00000039fb0000-0x00000039ffffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a000000-0x00003a04ffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a000000-0x0000003a04ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a050000-0x00003a09ffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a050000-0x0000003a09ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a0a0000-0x00003a0effff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a0a0000-0x0000003a0effff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a0f0000-0x00003a13ffff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a0f0000-0x0000003a13ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a140000-0x00003a140fff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a140000-0x0000003a14ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a141000-0x00003a14bfff [Boot Code          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a140000-0x0000003a14ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003a14c000-0x00003c31dfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003a140000-0x0000003c31ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003c31e000-0x00003cdcdfff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003c310000-0x0000003cdcffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003cdce000-0x00003cdfdfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003cdc0000-0x0000003cdfffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003cdfe000-0x00003ef7ffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003cdf0000-0x0000003ef7ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003ef80000-0x00003ef81fff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003ef80000-0x0000003ef8ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003ef82000-0x00003f10ffff [Boot Code          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003ef80000-0x0000003f10ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003f110000-0x00003f12ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003f110000-0x0000003f12ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003f130000-0x00003f15ffff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003f130000-0x0000003f15ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003f160000-0x00003f16ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003f160000-0x0000003f16ffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003f170000-0x00003fbfffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x0000003f170000-0x0000003fbfffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x00003fc00000-0x00003fffffff [Reserved           |   |  |  |  |  |  |  |   |  |  |  |  ]
[    0.000000] efi:   0x000078000000-0x00007800ffff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]
[    0.000000] efi:   0x0000a4000000-0x0000a4ffffff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]
[    0.000000] efi:   0x0000a6000000-0x0000a600ffff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]
[    0.000000] efi:   0x0000d00e0000-0x0000d00effff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]
[    0.000000] efi:   0x001040000000-0x0013fbffffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00001040000000-0x000013fbffffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x041000000000-0x0413fbfeffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x00041000000000-0x000413fbfeffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] efi:   0x0413fbff0000-0x0413fbffffff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] memblock_add: [0x000413fbff0000-0x000413fbffffff] flags 0x0 early_init_dt_add_memory_arch+0x54/0x5c
[    0.000000] memblock_reserve: [0x0000003ce14018-0x0000003ce14657] flags 0x0 efi_memattr_init+0x8c/0xa8
[    0.000000] memblock_reserve: [0x00000031b30000-0x00000031b3ffff] flags 0x0 efi_init+0xa8/0x148
[    0.000000] memblock_add: [0x0000001e480000-0x0000001fffffff] flags 0x0 arm64_memblock_init+0x16c/0x248
[    0.000000] memblock_reserve: [0x0000001e480000-0x0000001fffffff] flags 0x0 arm64_memblock_init+0x178/0x248
[    0.000000] memblock_reserve: [0x00000000080000-0x000000016cffff] flags 0x0 arm64_memblock_init+0x1b0/0x248
[    0.000000] memblock_reserve: [0x0000001e480000-0x0000001fffdc62] flags 0x0 arm64_memblock_init+0x1cc/0x248
[    0.000000] cma: Failed to reserve 512 MiB
[    0.000000] memblock_reserve: [0x000013fbff0000-0x000013fbffffff] flags 0x0 memblock_alloc_range_nid+0x30/0x48
[    0.000000] memblock_reserve: [0x000013fbfe0000-0x000013fbfeffff] flags 0x0 memblock_alloc_range_nid+0x30/0x48
[    0.000000] memblock_reserve: [0x000013fbfd0000-0x000013fbfdffff] flags 0x0 memblock_alloc_range_nid+0x30/0x48
[    0.000000] memblock_reserve: [0x000013fbfc0000-0x000013fbfcffff] flags 0x0 memblock_alloc_range_nid+0x30/0x48
[    0.000000] memblock_reserve: [0x000013fbfb0000-0x000013fbfbffff] flags 0x0 memblock_alloc_range_nid+0x30/0x48
[    0.000000]    memblock_free: [0x000013fbff0000-0x000013fbffffff] paging_init+0x65c/0x6ac
[    0.000000]    memblock_free: [0x000000016c0000-0x000000016cffff] paging_init+0x690/0x6ac
[...]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000013fbffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   1: [mem 0x0000000000000000-0x000000000001ffff]
[    0.000000]   node   1: [mem 0x0000000000030000-0x0000000031b0ffff]
[    0.000000]   node   1: [mem 0x0000000031b10000-0x0000000031b3ffff]
[    0.000000]   node   1: [mem 0x0000000031b40000-0x0000000039baffff]
[    0.000000]   node   1: [mem 0x0000000039bb0000-0x000000003a13ffff]
[    0.000000]   node   1: [mem 0x000000003a140000-0x000000003f12ffff]
[    0.000000]   node   1: [mem 0x000000003f130000-0x000000003f15ffff]
[    0.000000]   node   1: [mem 0x000000003f160000-0x000000003fbfffff]
[    0.000000]   node   1: [mem 0x0000001040000000-0x00000013fbffffff]
[    0.000000] Could not find start_pfn for node 0
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x0000000000000000]
[    0.000000] Initmem setup node 1 [mem 0x0000000000000000-0x00000013fbffffff]
[    0.000000] Could not find start_pfn for node 2
[    0.000000] Initmem setup node 2 [mem 0x0000000000000000-0x0000000000000000]
[    0.000000] Could not find start_pfn for node 3
[    0.000000] Initmem setup node 3 [mem 0x0000000000000000-0x0000000000000000]
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0x3fbc00000 reserved size = 0x42a7cc0
[    0.000000]  memory.cnt  = 0x9
[    0.000000]  memory[0x0]	[0x00000000000000-0x000000000257ff], 0x25800 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x1]	[0x00000000025800-0x00000031b0ffff], 0x31aea800 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x2]	[0x00000031b10000-0x00000031b3ffff], 0x30000 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x3]	[0x00000031b40000-0x00000039baffff], 0x8070000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x4]	[0x00000039bb0000-0x0000003a13ffff], 0x590000 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x5]	[0x0000003a140000-0x0000003f12ffff], 0x4ff0000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x6]	[0x0000003f130000-0x0000003f15ffff], 0x30000 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x7]	[0x0000003f160000-0x0000003fbfffff], 0xaa0000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x8]	[0x00001040000000-0x000013fbffffff], 0x3bc000000 bytes on node 1 flags: 0x0
[    0.000000]  reserved.cnt  = 0x8
[    0.000000]  reserved[0x0]	[0x00000000080000-0x000000016bffff], 0x1640000 bytes flags: 0x0
[    0.000000]  reserved[0x1]	[0x0000001e400000-0x0000001e400fff], 0x1000 bytes flags: 0x0
[    0.000000]  reserved[0x2]	[0x0000001e480000-0x0000001fffffff], 0x1b80000 bytes flags: 0x0
[    0.000000]  reserved[0x3]	[0x00000031b30000-0x00000031b3ffff], 0x10000 bytes flags: 0x0
[    0.000000]  reserved[0x4]	[0x0000003ce14018-0x0000003ce14657], 0x640 bytes flags: 0x0
[    0.000000]  reserved[0x5]	[0x000013fad20000-0x000013fbd2ffff], 0x1010000 bytes flags: 0x0
[    0.000000]  reserved[0x6]	[0x000013fbf37380-0x000013fbfeffff], 0xb8c80 bytes flags: 0x0
[    0.000000]  reserved[0x7]	[0x000013fbff2600-0x000013fbffffff], 0xda00 bytes flags: 0x0
[    0.000000] memblock_reserve: [0x0000003fbfff80-0x0000003fbfffbf] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbfff00-0x0000003fbfff3f] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffe80-0x0000003fbffebf] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffe00-0x0000003fbffe3f] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffd80-0x0000003fbffdbf] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffd00-0x0000003fbffd3f] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffc80-0x0000003fbffcbf] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffc00-0x0000003fbffc3f] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[    0.000000] memblock_reserve: [0x0000003fbffb80-0x0000003fbffbbf] flags 0x0 __alloc_memory_core_early+0x9c/0xe4
[...]
[    5.081443] move_freepages: start_page info: zonenum = 0, nid = 1, pfn = 8192,  valid = 1, phys = 0x20000000
[    5.081443] move_freepages: end_page   info: zonenum = 0, nid = 0, pfn = 16383, valid = 0, phys = 0x3fff0000
[    5.091280] ------------[ cut here ]------------
[    5.095971] kernel BUG at mm/page_alloc.c:1871!     ----> is mm/page_alloc.c:1863! without add debug log.
[    5.100576] Internal error: Oops - BUG: 0 [#1] SMP
[    5.105446] Modules linked in:
[    5.108552] CPU: 61 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc8+ #61
[    5.115101] Hardware name: Huawei Taishan 2280 /D05, BIOS Hisilicon D05 UEFI 16.08 RC1 12/08/2016
[    5.124126] task: fffffe13f23d1700 task.stack: fffffe13f66a0000
[    5.130157] PC is at move_freepages+0x280/0x288
[    5.134764] LR is at move_freepages+0x23c/0x288
[    5.139365] pc : [<fffffc00081e9698>] lr : [<fffffc00081e9654>] pstate: 200000c5
[    5.146889] sp : fffffe13f66a38d0
[    5.150253] x29: fffffe13f66a38f0 x28: fffffdff80000000
[    5.155652] x27: 0000000000003fff x26: 0000000000002000
[    5.161051] x25: 0000000000000000 x24: 0000000000000000
[    5.166453] x23: 0000000000000001 x22: fffffc0008e12328
[    5.171851] x21: fffffdff800fffc0 x20: fffffe13fbf62680
[    5.177251] x19: fffffdff80080000 x18: 0000000000000010
[    5.182652] x17: 0000000000000000 x16: 0000000000000000
[    5.188053] x15: 0000000000000006 x14: 702c29302c312864
[    5.193455] x13: 696c61762c293338 x12: 3336312c32393138
[    5.198854] x11: 286e66702c29302c x10: 0000000000000559
[    5.204258] x9 : 000000000000006e x8 : 302c303030303030
[    5.209663] x7 : 3032783028737968 x6 : fffffe13fbff2680
[    5.215068] x5 : 0000000000000001 x4 : fffffe13fbf62680
[    5.220468] x3 : 0000000000000000 x2 : 0000000000000000
[    5.225870] x1 : fffffe13fbff2680 x0 : fffffe13fbf62680
[...]
[    5.793294] [<fffffc00081e9698>] move_freepages+0x280/0x288
[    5.798964] [<fffffc00081e9748>] move_freepages_block+0xa8/0xb8
[    5.804994] [<fffffc00081e9cc4>] __rmqueue+0x494/0x5f0
[    5.810225] [<fffffc00081eb214>] get_page_from_freelist+0x5ec/0xb58
[    5.816603] [<fffffc00081ebd54>] __alloc_pages_nodemask+0x144/0xd08
[    5.822979] [<fffffc000824061c>] alloc_page_interleave+0x64/0xc0
[    5.829092] [<fffffc0008240c28>] alloc_pages_current+0x108/0x168
[    5.835207] [<fffffc0008c75410>] atomic_pool_init+0x78/0x1cc
[    5.840970] [<fffffc0008c755a0>] arm64_dma_init+0x3c/0x44
[    5.846471] [<fffffc0008082d94>] do_one_initcall+0x44/0x138
[    5.852143] [<fffffc0008c70d54>] kernel_init_freeable+0x1ec/0x28c
[    5.858351] [<fffffc00088a7af0>] kernel_init+0x18/0x110
[    5.863665] [<fffffc0008082b30>] ret_from_fork+0x10/0x20
[    5.869078] Code: 8b001c80 8b011cc1 eb00003f 54fff080 (d4210000)
[    5.875318] ---[ end trace b723f6d3d3b4c326 ]---
[    5.880038] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    5.880038]
[    5.889340] SMP: stopping secondary CPUs
[    5.893339] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
