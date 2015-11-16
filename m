Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id CB0826B0258
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:50:12 -0500 (EST)
Received: by ykba77 with SMTP id a77so257955169ykb.2
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:50:12 -0800 (PST)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id c70si16920841ywb.23.2015.11.16.11.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 11:50:12 -0800 (PST)
Received: by ykdr82 with SMTP id r82so258341051ykd.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:50:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
Date: Mon, 16 Nov 2015 19:50:11 +0000
Message-ID: <CAD0U-hKfQvV_Dagc2BomK1wuJQG_-bsnLSyGcRduUN9zf30AHg@mail.gmail.com>
Subject: Re: [PATCH v2 00/12] UEFI boot and runtime services support for
 32-bit ARM
From: Ryan Harkin <ryan.harkin@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-efi@vger.kernel.org, Matt Fleming <matt.fleming@intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org

Hi Ard,

On 16 November 2015 at 18:32, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> This series adds support for booting the 32-bit ARM kernel directly from
> UEFI firmware using a builtin UEFI stub. It mostly reuses refactored arm64
> code, and the differences (primarily the PE/COFF header and entry point and
> the efi_create_mapping() implementation) are split out into arm64 and ARM
> versions.
>
> Changes since v1:
> - The primary difference between this version and the first one is that all
>   prerequisites have either been merged, dropped for now (early FDT handling)
>   or folded into this series (MEMBLOCK_NOMAP). IOW, this series can be applied
>   on top of v4.4-rc1 directly.
> - Dropped handling of UEFI permission bits. The reason is that the UEFIv2.5
>   approach (EFI_PROPERTIES_TABLE) is flawed, and will be replaced by something
>   better in the next version of the spec.
>
> Patch #1 adds support for the MEMBLOCK_NOMAP attribute to the generic memblock
> code. Its purpose is to annotate memory regions as normal memory even if they
> are removed from the kernel direct mapping.
>
> Patch #2 implements MEMBLOCK_NOMAP support for arm64
>
> Patch #3 updates the EFI init code to remove UEFI reserved regions and regions
> used by runtime services from the kernel direct mapping
>
> Patch #4 splits off most of arch/arm64/kernel/efi.c into arch agnostic files
> arm-init.c and arm-runtime.c under drivers/firmware/efi.
>
> Patch #5 refactors the code split off in patch #1 to isolate the arm64 specific
> pieces, and change a couple of arm64-isms that ARM handles slightly differently.
>
> Patch #6 enables the generic early_ioremap and early_memremap implementations
> for ARM. It reuses the kmap fixmap region, which is not used that early anyway.
>
> Patch #7 splits off the core functionality of create_mapping() into a new
> function __create_mapping() that we can reuse for mapping UEFI runtime regions.
>
> Patch #8 factors out the early_alloc() routine so we can invoke __create_mapping
> using another (late) allocator.
>
> Patch #9 implements create_mapping_late() that uses a late allocator.
>
> Patch #10 implements MEMBLOCK_NOMAP support for ARM
>
> Patch #11 implements the UEFI support in the kernel proper to probe the UEFI
> memory map and map the runtime services.
>
> Patch #12 ties together all of the above, by implementing the UEFI stub, and
> introducing the Kconfig symbols that allow all of this to be built.
>
> Instructions how to build and run the 32-bit ARM UEFI firmware can be found here:
> https://wiki.linaro.org/LEG/UEFIforQEMU
>
> Ard Biesheuvel (11):
>   mm/memblock: add MEMBLOCK_NOMAP attribute to memblock memory table
>   arm64: only consider memblocks with NOMAP cleared for linear mapping
>   arm64/efi: mark UEFI reserved regions as MEMBLOCK_NOMAP
>   arm64/efi: split off EFI init and runtime code for reuse by 32-bit ARM
>   arm64/efi: refactor EFI init and runtime code for reuse by 32-bit ARM
>   ARM: add support for generic early_ioremap/early_memremap
>   ARM: split off core mapping logic from create_mapping
>   ARM: factor out allocation routine from __create_mapping()
>   ARM: implement create_mapping_late() for EFI use
>   ARM: only consider memblocks with NOMAP cleared for linear mapping
>   ARM: wire up UEFI init and runtime support
>
> Roy Franz (1):
>   ARM: add UEFI stub support
>
>  arch/arm/Kconfig                          |  20 ++
>  arch/arm/boot/compressed/Makefile         |   4 +-
>  arch/arm/boot/compressed/efi-header.S     | 130 ++++++++
>  arch/arm/boot/compressed/head.S           |  54 +++-
>  arch/arm/boot/compressed/vmlinux.lds.S    |   7 +
>  arch/arm/include/asm/Kbuild               |   1 +
>  arch/arm/include/asm/efi.h                |  90 ++++++
>  arch/arm/include/asm/fixmap.h             |  29 +-
>  arch/arm/include/asm/mach/map.h           |   1 +
>  arch/arm/kernel/Makefile                  |   1 +
>  arch/arm/kernel/efi.c                     |  38 +++
>  arch/arm/kernel/setup.c                   |  10 +-
>  arch/arm/mm/init.c                        |   5 +-
>  arch/arm/mm/ioremap.c                     |   9 +
>  arch/arm/mm/mmu.c                         | 110 ++++---
>  arch/arm64/include/asm/efi.h              |  16 +
>  arch/arm64/kernel/efi.c                   | 331 ++------------------
>  arch/arm64/mm/init.c                      |   2 +-
>  arch/arm64/mm/mmu.c                       |   2 +
>  drivers/firmware/efi/Makefile             |   4 +
>  drivers/firmware/efi/arm-init.c           | 197 ++++++++++++
>  drivers/firmware/efi/arm-runtime.c        | 134 ++++++++
>  drivers/firmware/efi/efi.c                |   2 +
>  drivers/firmware/efi/libstub/Makefile     |   9 +
>  drivers/firmware/efi/libstub/arm-stub.c   |   4 +-
>  drivers/firmware/efi/libstub/arm32-stub.c |  85 +++++
>  include/linux/memblock.h                  |   8 +
>  mm/memblock.c                             |  28 ++
>  28 files changed, 975 insertions(+), 356 deletions(-)
>  create mode 100644 arch/arm/boot/compressed/efi-header.S
>  create mode 100644 arch/arm/include/asm/efi.h
>  create mode 100644 arch/arm/kernel/efi.c
>  create mode 100644 drivers/firmware/efi/arm-init.c
>  create mode 100644 drivers/firmware/efi/arm-runtime.c
>  create mode 100644 drivers/firmware/efi/libstub/arm32-stub.c
>
> --
> 1.9.1
>

I've tested this series against 4.4-rc1 on Versatile Express TC2,
booting both as a "regular" kernel and as a EFI Stub on BusyBox and
OpenEmbedded.  So if it helps any, you can add my:

Tested-by: Ryan Harkin <ryan.harkin@linaro.org>

I'm afraid I'm not knowledgeable enough to review the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
