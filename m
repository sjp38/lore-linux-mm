Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1991E6B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:17:39 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n186so49500167qkb.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:17:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p89si3807919qtd.31.2017.03.01.01.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 01:17:38 -0800 (PST)
Date: Wed, 1 Mar 2017 17:17:25 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [RFC PATCH v4 00/28] x86: Secure Memory Encryption (AMD)
Message-ID: <20170301091725.GA8353@dhcp-128-65.nay.redhat.com>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, kexec@lists.infradead.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Hi Tom,

On 02/16/17 at 09:41am, Tom Lendacky wrote:
> This RFC patch series provides support for AMD's new Secure Memory
> Encryption (SME) feature.
> 
> SME can be used to mark individual pages of memory as encrypted through the
> page tables. A page of memory that is marked encrypted will be automatically
> decrypted when read from DRAM and will be automatically encrypted when
> written to DRAM. Details on SME can found in the links below.
> 
> The SME feature is identified through a CPUID function and enabled through
> the SYSCFG MSR. Once enabled, page table entries will determine how the
> memory is accessed. If a page table entry has the memory encryption mask set,
> then that memory will be accessed as encrypted memory. The memory encryption
> mask (as well as other related information) is determined from settings
> returned through the same CPUID function that identifies the presence of the
> feature.
> 
> The approach that this patch series takes is to encrypt everything possible
> starting early in the boot where the kernel is encrypted. Using the page
> table macros the encryption mask can be incorporated into all page table
> entries and page allocations. By updating the protection map, userspace
> allocations are also marked encrypted. Certain data must be accounted for
> as having been placed in memory before SME was enabled (EFI, initrd, etc.)
> and accessed accordingly.
> 
> This patch series is a pre-cursor to another AMD processor feature called
> Secure Encrypted Virtualization (SEV). The support for SEV will build upon
> the SME support and will be submitted later. Details on SEV can be found
> in the links below.
> 
> The following links provide additional detail:
> 
> AMD Memory Encryption whitepaper:
>    http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/AMD_Memory_Encryption_Whitepaper_v7-Public.pdf
> 
> AMD64 Architecture Programmer's Manual:
>    http://support.amd.com/TechDocs/24593.pdf
>    SME is section 7.10
>    SEV is section 15.34
> 
> This patch series is based off of the master branch of tip.
>   Commit a27cb9e1b2b4 ("Merge branch 'WIP.sched/core'")
> 
> ---
> 
> Still to do: IOMMU enablement support
> 
> Changes since v3:
> - Broke out some of the patches into smaller individual patches
> - Updated Documentation
> - Added a message to indicate why the IOMMU was disabled
> - Updated CPU feature support for SME by taking into account whether
>   BIOS has enabled SME
> - Eliminated redundant functions
> - Added some warning messages for DMA usage of bounce buffers when SME
>   is active
> - Added support for persistent memory
> - Added support to determine when setup data is being mapped and be sure
>   to map it un-encrypted
> - Added CONFIG support to set the default action of whether to activate
>   SME if it is supported/enabled
> - Added support for (re)booting with kexec

Could you please add kexec list in cc when you updating the patches so
that kexec/kdump people do not miss them?

> 
> Changes since v2:
> - Updated Documentation
> - Make the encryption mask available outside of arch/x86 through a
>   standard include file
> - Conversion of assembler routines to C where possible (not everything
>   could be converted, e.g. the routine that does the actual encryption
>   needs to be copied into a safe location and it is difficult to
>   determine the actual length of the function in order to copy it)
> - Fix SME feature use of scattered CPUID feature
> - Creation of SME specific functions for things like encrypting
>   the setup data, ramdisk, etc.
> - New take on early_memremap / memremap encryption support
> - Additional support for accessing video buffers (fbdev/gpu) as
>   un-encrypted
> - Disable IOMMU for now - need to investigate further in relation to
>   how it needs to be programmed relative to accessing physical memory
> 
> Changes since v1:
> - Added Documentation.
> - Removed AMD vendor check for setting the PAT write protect mode
> - Updated naming of trampoline flag for SME as well as moving of the
>   SME check to before paging is enabled.
> - Change to early_memremap to identify the data being mapped as either
>   boot data or kernel data.  The idea being that boot data will have
>   been placed in memory as un-encrypted data and would need to be accessed
>   as such.
> - Updated debugfs support for the bootparams to access the data properly.
> - Do not set the SYSCFG[MEME] bit, only check it.  The setting of the
>   MemEncryptionModeEn bit results in a reduction of physical address size
>   of the processor.  It is possible that BIOS could have configured resources
>   resources into a range that will now not be addressable.  To prevent this,
>   rely on BIOS to set the SYSCFG[MEME] bit and only then enable memory
>   encryption support in the kernel.
> 
> Tom Lendacky (28):
>       x86: Documentation for AMD Secure Memory Encryption (SME)
>       x86: Set the write-protect cache mode for full PAT support
>       x86: Add the Secure Memory Encryption CPU feature
>       x86: Handle reduction in physical address size with SME
>       x86: Add Secure Memory Encryption (SME) support
>       x86: Add support to enable SME during early boot processing
>       x86: Provide general kernel support for memory encryption
>       x86: Extend the early_memremap support with additional attrs
>       x86: Add support for early encryption/decryption of memory
>       x86: Insure that boot memory areas are mapped properly
>       x86: Add support to determine the E820 type of an address
>       efi: Add an EFI table address match function
>       efi: Update efi_mem_type() to return defined EFI mem types
>       Add support to access boot related data in the clear
>       Add support to access persistent memory in the clear
>       x86: Add support for changing memory encryption attribute
>       x86: Decrypt trampoline area if memory encryption is active
>       x86: DMA support for memory encryption
>       swiotlb: Add warnings for use of bounce buffers with SME
>       iommu/amd: Disable AMD IOMMU if memory encryption is active
>       x86: Check for memory encryption on the APs
>       x86: Do not specify encrypted memory for video mappings
>       x86/kvm: Enable Secure Memory Encryption of nested page tables
>       x86: Access the setup data through debugfs decrypted
>       x86: Access the setup data through sysfs decrypted
>       x86: Allow kexec to be used with SME
>       x86: Add support to encrypt the kernel in-place
>       x86: Add support to make use of Secure Memory Encryption
> 
> 
>  Documentation/admin-guide/kernel-parameters.txt |   11 +
>  Documentation/x86/amd-memory-encryption.txt     |   57 ++++
>  arch/x86/Kconfig                                |   26 ++
>  arch/x86/boot/compressed/pagetable.c            |    7 +
>  arch/x86/include/asm/cacheflush.h               |    5 
>  arch/x86/include/asm/cpufeature.h               |    7 -
>  arch/x86/include/asm/cpufeatures.h              |    5 
>  arch/x86/include/asm/disabled-features.h        |    3 
>  arch/x86/include/asm/dma-mapping.h              |    5 
>  arch/x86/include/asm/e820/api.h                 |    2 
>  arch/x86/include/asm/e820/types.h               |    2 
>  arch/x86/include/asm/fixmap.h                   |   20 +
>  arch/x86/include/asm/init.h                     |    1 
>  arch/x86/include/asm/io.h                       |    3 
>  arch/x86/include/asm/kvm_host.h                 |    3 
>  arch/x86/include/asm/mem_encrypt.h              |  108 ++++++++
>  arch/x86/include/asm/msr-index.h                |    2 
>  arch/x86/include/asm/page.h                     |    4 
>  arch/x86/include/asm/pgtable.h                  |   26 +-
>  arch/x86/include/asm/pgtable_types.h            |   54 +++-
>  arch/x86/include/asm/processor.h                |    3 
>  arch/x86/include/asm/realmode.h                 |   12 +
>  arch/x86/include/asm/required-features.h        |    3 
>  arch/x86/include/asm/setup.h                    |    8 +
>  arch/x86/include/asm/vga.h                      |   13 +
>  arch/x86/kernel/Makefile                        |    3 
>  arch/x86/kernel/cpu/common.c                    |   23 ++
>  arch/x86/kernel/e820.c                          |   26 ++
>  arch/x86/kernel/espfix_64.c                     |    2 
>  arch/x86/kernel/head64.c                        |   46 +++
>  arch/x86/kernel/head_64.S                       |   65 ++++-
>  arch/x86/kernel/kdebugfs.c                      |   30 +-
>  arch/x86/kernel/ksysfs.c                        |   27 +-
>  arch/x86/kernel/machine_kexec_64.c              |    3 
>  arch/x86/kernel/mem_encrypt_boot.S              |  156 ++++++++++++
>  arch/x86/kernel/mem_encrypt_init.c              |  310 +++++++++++++++++++++++
>  arch/x86/kernel/pci-dma.c                       |   11 +
>  arch/x86/kernel/pci-nommu.c                     |    2 
>  arch/x86/kernel/pci-swiotlb.c                   |    8 -
>  arch/x86/kernel/process.c                       |   43 +++
>  arch/x86/kernel/setup.c                         |   43 +++
>  arch/x86/kernel/smp.c                           |    4 
>  arch/x86/kvm/mmu.c                              |    8 -
>  arch/x86/kvm/vmx.c                              |    3 
>  arch/x86/kvm/x86.c                              |    3 
>  arch/x86/mm/Makefile                            |    1 
>  arch/x86/mm/ident_map.c                         |    6 
>  arch/x86/mm/ioremap.c                           |  157 ++++++++++++
>  arch/x86/mm/kasan_init_64.c                     |    4 
>  arch/x86/mm/mem_encrypt.c                       |  218 ++++++++++++++++
>  arch/x86/mm/pageattr.c                          |   71 +++++
>  arch/x86/mm/pat.c                               |    6 
>  arch/x86/platform/efi/efi.c                     |    4 
>  arch/x86/platform/efi/efi_64.c                  |   16 +
>  arch/x86/realmode/init.c                        |   16 +
>  arch/x86/realmode/rm/trampoline_64.S            |   17 +
>  drivers/firmware/efi/efi.c                      |   33 ++
>  drivers/gpu/drm/drm_gem.c                       |    2 
>  drivers/gpu/drm/drm_vm.c                        |    4 
>  drivers/gpu/drm/ttm/ttm_bo_vm.c                 |    7 -
>  drivers/gpu/drm/udl/udl_fb.c                    |    4 
>  drivers/iommu/amd_iommu_init.c                  |    7 +
>  drivers/video/fbdev/core/fbmem.c                |   12 +
>  include/asm-generic/early_ioremap.h             |    2 
>  include/asm-generic/pgtable.h                   |    8 +
>  include/linux/dma-mapping.h                     |   11 +
>  include/linux/efi.h                             |    7 +
>  include/linux/mem_encrypt.h                     |   53 ++++
>  include/linux/swiotlb.h                         |    1 
>  init/main.c                                     |   13 +
>  kernel/kexec_core.c                             |   24 ++
>  kernel/memremap.c                               |   11 +
>  lib/swiotlb.c                                   |   59 ++++
>  mm/early_ioremap.c                              |   28 ++
>  74 files changed, 1880 insertions(+), 128 deletions(-)
>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>  create mode 100644 arch/x86/kernel/mem_encrypt_boot.S
>  create mode 100644 arch/x86/kernel/mem_encrypt_init.c
>  create mode 100644 arch/x86/mm/mem_encrypt.c
>  create mode 100644 include/linux/mem_encrypt.h
> 
> -- 
> Tom Lendacky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-efi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks a lot!
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
