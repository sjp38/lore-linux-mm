Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2486B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:34:37 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id a184so159569515ybb.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:34:37 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0076.outbound.protection.outlook.com. [104.47.38.76])
        by mx.google.com with ESMTPS id 87si1441633iot.201.2016.11.09.16.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:34:36 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 00/20] x86: Secure Memory Encryption (AMD)
Date: Wed, 9 Nov 2016 18:34:27 -0600
Message-ID: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This RFC patch series provides support for AMD's new Secure Memory
Encryption (SME) feature.

SME can be used to mark individual pages of memory as encrypted through the
page tables. A page of memory that is marked encrypted will be automatically
decrypted when read from DRAM and will be automatically encrypted when
written to DRAM. Details on SME can found in the links below.

The SME feature is identified through a CPUID function and enabled through
the SYSCFG MSR. Once enabled, page table entries will determine how the
memory is accessed. If a page table entry has the memory encryption mask set,
then that memory will be accessed as encrypted memory. The memory encryption
mask (as well as other related information) is determined from settings
returned through the same CPUID function that identifies the presence of the
feature.

The approach that this patch series takes is to encrypt everything possible
starting early in the boot where the kernel is encrypted. Using the page
table macros the encryption mask can be incorporated into all page table
entries and page allocations. By updating the protection map, userspace
allocations are also marked encrypted. Certain data must be accounted for
as having been placed in memory before SME was enabled (EFI, initrd, etc.)
and accessed accordingly.

This patch series is a pre-cursor to another AMD processor feature called
Secure Encrypted Virtualization (SEV). The support for SEV will build upon
the SME support and will be submitted later. Details on SEV can be found
in the links below.

The following links provide additional detail:

AMD Memory Encryption whitepaper:
   http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/AMD_Memory_Encryption_Whitepaper_v7-Public.pdf

AMD64 Architecture Programmer's Manual:
   http://support.amd.com/TechDocs/24593.pdf
   SME is section 7.10
   SEV is section 15.34

This patch series is based off of the master branch of tip.
  Commit 14dc61ac9587 ("Merge branch 'x86/fpu'")

---

Still to do: kexec support, IOMMU support

Changes since v2:
- Updated Documentation
- Make the encryption mask available outside of arch/x86 through a
  standard include file
- Conversion of assembler routines to C where possible (not everything
  could be converted, e.g. the routine that does the actual encryption
  needs to be copied into a safe location and it is difficult to
  determine the actual length of the function in order to copy it)
- Fix SME feature use of scattered CPUID feature
- Creation of SME specific functions for things like encrypting
  the setup data, ramdisk, etc.
- New take on early_memremap / memremap encryption support
- Additional support for accessing video buffers (fbdev/gpu) as
  un-encrypted
- Disable IOMMU for now - need to investigate further in relation to
  how it needs to be programmed relative to accessing physical memory

Changes since v1:
- Added Documentation.
- Removed AMD vendor check for setting the PAT write protect mode
- Updated naming of trampoline flag for SME as well as moving of the
  SME check to before paging is enabled.
- Change to early_memremap to identify the data being mapped as either
  boot data or kernel data.  The idea being that boot data will have
  been placed in memory as un-encrypted data and would need to be accessed
  as such.
- Updated debugfs support for the bootparams to access the data properly.
- Do not set the SYSCFG[MEME] bit, only check it.  The setting of the
  MemEncryptionModeEn bit results in a reduction of physical address size
  of the processor.  It is possible that BIOS could have configured resources
  resources into a range that will now not be addressable.  To prevent this,
  rely on BIOS to set the SYSCFG[MEME] bit and only then enable memory
  encryption support in the kernel.

Tom Lendacky (20):
      x86: Documentation for AMD Secure Memory Encryption (SME)
      x86: Set the write-protect cache mode for full PAT support
      x86: Add the Secure Memory Encryption cpu feature
      x86: Handle reduction in physical address size with SME
      x86: Add Secure Memory Encryption (SME) support
      x86: Add support to enable SME during early boot processing
      x86: Provide general kernel support for memory encryption
      x86: Add support for early encryption/decryption of memory
      x86: Insure that boot memory areas are mapped properly
      Add support to access boot related data in the clear
      x86: Add support for changing memory encryption attribute
      x86: Decrypt trampoline area if memory encryption is active
      x86: DMA support for memory encryption
      iommu/amd: Disable AMD IOMMU if memory encryption is active
      x86: Check for memory encryption on the APs
      x86: Do not specify encrypted memory for video mappings
      x86/kvm: Enable Secure Memory Encryption of nested page tables
      x86: Access the setup data through debugfs un-encrypted
      x86: Add support to make use of Secure Memory Encryption
      x86: Add support to make use of Secure Memory Encryption


 Documentation/kernel-parameters.txt         |    5 
 Documentation/x86/amd-memory-encryption.txt |   40 ++++
 arch/x86/Kconfig                            |    9 +
 arch/x86/boot/compressed/pagetable.c        |    7 +
 arch/x86/include/asm/cacheflush.h           |    3 
 arch/x86/include/asm/cpufeatures.h          |    1 
 arch/x86/include/asm/dma-mapping.h          |    5 
 arch/x86/include/asm/e820.h                 |    1 
 arch/x86/include/asm/fixmap.h               |   16 ++
 arch/x86/include/asm/kvm_host.h             |    3 
 arch/x86/include/asm/mem_encrypt.h          |   90 +++++++++
 arch/x86/include/asm/msr-index.h            |    2 
 arch/x86/include/asm/page.h                 |    4 
 arch/x86/include/asm/pgtable.h              |   20 +-
 arch/x86/include/asm/pgtable_types.h        |   53 ++++-
 arch/x86/include/asm/processor.h            |    3 
 arch/x86/include/asm/realmode.h             |   12 +
 arch/x86/include/asm/vga.h                  |   13 +
 arch/x86/kernel/Makefile                    |    3 
 arch/x86/kernel/cpu/common.c                |   30 +++
 arch/x86/kernel/cpu/scattered.c             |    1 
 arch/x86/kernel/e820.c                      |   16 ++
 arch/x86/kernel/espfix_64.c                 |    2 
 arch/x86/kernel/head64.c                    |   33 +++
 arch/x86/kernel/head_64.S                   |   54 ++++-
 arch/x86/kernel/kdebugfs.c                  |   30 +--
 arch/x86/kernel/mem_encrypt_boot.S          |  156 +++++++++++++++
 arch/x86/kernel/mem_encrypt_init.c          |  283 +++++++++++++++++++++++++++
 arch/x86/kernel/pci-dma.c                   |   11 +
 arch/x86/kernel/pci-nommu.c                 |    2 
 arch/x86/kernel/pci-swiotlb.c               |    8 +
 arch/x86/kernel/setup.c                     |    9 +
 arch/x86/kvm/mmu.c                          |    8 +
 arch/x86/kvm/vmx.c                          |    3 
 arch/x86/kvm/x86.c                          |    3 
 arch/x86/mm/Makefile                        |    1 
 arch/x86/mm/ioremap.c                       |  117 +++++++++++
 arch/x86/mm/kasan_init_64.c                 |    4 
 arch/x86/mm/mem_encrypt.c                   |  261 +++++++++++++++++++++++++
 arch/x86/mm/pageattr.c                      |   76 +++++++
 arch/x86/mm/pat.c                           |    4 
 arch/x86/platform/efi/efi_64.c              |   12 +
 arch/x86/realmode/init.c                    |   13 +
 arch/x86/realmode/rm/trampoline_64.S        |   19 ++
 drivers/firmware/efi/efi.c                  |   33 +++
 drivers/gpu/drm/drm_gem.c                   |    2 
 drivers/gpu/drm/drm_vm.c                    |    4 
 drivers/gpu/drm/ttm/ttm_bo_vm.c             |    7 -
 drivers/gpu/drm/udl/udl_fb.c                |    4 
 drivers/iommu/amd_iommu_init.c              |    5 
 drivers/video/fbdev/core/fbmem.c            |   12 +
 include/asm-generic/early_ioremap.h         |    2 
 include/linux/efi.h                         |    2 
 include/linux/mem_encrypt.h                 |   30 +++
 include/linux/swiotlb.h                     |    1 
 init/main.c                                 |   13 +
 kernel/memremap.c                           |    8 +
 lib/swiotlb.c                               |   58 +++++-
 mm/early_ioremap.c                          |   33 +++
 59 files changed, 1564 insertions(+), 96 deletions(-)
 create mode 100644 Documentation/x86/amd-memory-encryption.txt
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/kernel/mem_encrypt_boot.S
 create mode 100644 arch/x86/kernel/mem_encrypt_init.c
 create mode 100644 arch/x86/mm/mem_encrypt.c
 create mode 100644 include/linux/mem_encrypt.h

-- 
Tom Lendacky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
