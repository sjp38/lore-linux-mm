Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD956B0292
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:13:19 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id k36so5124739otb.3
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:13:19 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0083.outbound.protection.outlook.com. [104.47.37.83])
        by mx.google.com with ESMTPS id 75si1087144otc.12.2017.06.07.12.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:13:17 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 00/34] x86: Secure Memory Encryption (AMD)
Date: Wed, 07 Jun 2017 14:13:10 -0500
Message-ID: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This patch series provides support for AMD's new Secure Memory Encryption (SME)
feature.

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

---

This patch series is based off of the master branch of tip.
  Commit 53614fbd7961 ("Merge branch 'WIP.x86/fpu'")

Source code is also available at https://github.com/codomania/tip/tree/sme-v6


Still to do:
- Kdump support, including using memremap() instead of ioremap_cache()

Changes since v5:
- Added support for 5-level paging
- Added IOMMU support
- Created a generic asm/mem_encrypt.h in order to remove a bunch of
  #ifndef/#define entries
- Removed changes to the __va() macro and defined a function to return
  the true physical address in cr3
- Removed sysfs support as it was determined not to be needed
- General code cleanup based on feedback
- General cleanup of patch subjects and descriptions

Changes since v4:
- Re-worked mapping of setup data to not use a fixed list. Rather, check
  dynamically whether the requested early_memremap()/memremap() call
  needs to be mapped decrypted.
- Moved SME cpu feature into scattered features
- Moved some declarations into header files
- Cleared the encryption mask from the __PHYSICAL_MASK so that users
  of macros such as pmd_pfn_mask() don't have to worry/know about the
  encryption mask
- Updated some return types and values related to EFI and e820 functions
  so that an error could be returned
- During cpu shutdown, removed cache disabling and added a check for kexec
  in progress to use wbinvd followed immediately by halt in order to avoid
  any memory corruption
- Update how persistent memory is identified
- Added a function to find command line arguments and their values
- Added sysfs support
- General code cleanup based on feedback
- General cleanup of patch subjects and descriptions


Changes since v3:
- Broke out some of the patches into smaller individual patches
- Updated Documentation
- Added a message to indicate why the IOMMU was disabled
- Updated CPU feature support for SME by taking into account whether
  BIOS has enabled SME
- Eliminated redundant functions
- Added some warning messages for DMA usage of bounce buffers when SME
  is active
- Added support for persistent memory
- Added support to determine when setup data is being mapped and be sure
  to map it un-encrypted
- Added CONFIG support to set the default action of whether to activate
  SME if it is supported/enabled
- Added support for (re)booting with kexec

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

Tom Lendacky (34):
      x86: Document AMD Secure Memory Encryption (SME)
      x86/mm/pat: Set write-protect cache mode for full PAT support
      x86, mpparse, x86/acpi, x86/PCI, x86/dmi, SFI: Use memremap for RAM mappings
      x86/CPU/AMD: Add the Secure Memory Encryption CPU feature
      x86/CPU/AMD: Handle SME reduction in physical address size
      x86/mm: Add Secure Memory Encryption (SME) support
      x86/mm: Don't use phys_to_virt in ioremap() if SME is active
      x86/mm: Add support to enable SME in early boot processing
      x86/mm: Simplify p[gum]d_page() macros
      x86, x86/mm, x86/xen, olpc: Use __va() against just the physical address in cr3
      x86/mm: Provide general kernel support for memory encryption
      x86/mm: Extend early_memremap() support with additional attrs
      x86/mm: Add support for early encrypt/decrypt of memory
      x86/mm: Insure that boot memory areas are mapped properly
      x86/boot/e820: Add support to determine the E820 type of an address
      efi: Add an EFI table address match function
      efi: Update efi_mem_type() to return an error rather than 0
      x86/efi: Update EFI pagetable creation to work with SME
      x86/mm: Add support to access boot related data in the clear
      x86, mpparse: Use memremap to map the mpf and mpc data
      x86/mm: Add support to access persistent memory in the clear
      x86/mm: Add support for changing the memory encryption attribute
      x86, realmode: Decrypt trampoline area if memory encryption is active
      x86, swiotlb: Add memory encryption support
      swiotlb: Add warnings for use of bounce buffers with SME
      iommu/amd: Allow the AMD IOMMU to work with memory encryption
      x86, realmode: Check for memory encryption on the APs
      x86, drm, fbdev: Do not specify encrypted memory for video mappings
      kvm: x86: svm: Support Secure Memory Encryption within KVM
      x86/mm, kexec: Allow kexec to be used with SME
      x86/mm: Use proper encryption attributes with /dev/mem
      x86/mm: Add support to encrypt the kernel in-place
      x86/boot: Add early cmdline parsing for options with arguments
      x86/mm: Add support to make use of Secure Memory Encryption


 Documentation/admin-guide/kernel-parameters.txt |   11 
 Documentation/x86/amd-memory-encryption.txt     |   68 ++
 arch/ia64/kernel/efi.c                          |    4 
 arch/x86/Kconfig                                |   26 +
 arch/x86/boot/compressed/pagetable.c            |    7 
 arch/x86/include/asm/cmdline.h                  |    2 
 arch/x86/include/asm/cpufeatures.h              |    1 
 arch/x86/include/asm/dma-mapping.h              |    5 
 arch/x86/include/asm/dmi.h                      |    8 
 arch/x86/include/asm/e820/api.h                 |    2 
 arch/x86/include/asm/fixmap.h                   |   20 +
 arch/x86/include/asm/init.h                     |    1 
 arch/x86/include/asm/io.h                       |    7 
 arch/x86/include/asm/kexec.h                    |    8 
 arch/x86/include/asm/kvm_host.h                 |    2 
 arch/x86/include/asm/mem_encrypt.h              |  112 ++++
 arch/x86/include/asm/msr-index.h                |    2 
 arch/x86/include/asm/page_types.h               |    2 
 arch/x86/include/asm/pgtable.h                  |   28 +
 arch/x86/include/asm/pgtable_types.h            |   54 +-
 arch/x86/include/asm/processor.h                |    3 
 arch/x86/include/asm/realmode.h                 |   12 
 arch/x86/include/asm/set_memory.h               |    3 
 arch/x86/include/asm/special_insns.h            |    9 
 arch/x86/include/asm/vga.h                      |   14 
 arch/x86/kernel/acpi/boot.c                     |    6 
 arch/x86/kernel/cpu/amd.c                       |   17 +
 arch/x86/kernel/cpu/scattered.c                 |    1 
 arch/x86/kernel/e820.c                          |   26 +
 arch/x86/kernel/espfix_64.c                     |    2 
 arch/x86/kernel/head64.c                        |   42 +
 arch/x86/kernel/head_64.S                       |   80 ++-
 arch/x86/kernel/kdebugfs.c                      |   34 -
 arch/x86/kernel/ksysfs.c                        |   28 -
 arch/x86/kernel/machine_kexec_64.c              |   35 +
 arch/x86/kernel/mpparse.c                       |  108 +++-
 arch/x86/kernel/pci-dma.c                       |   11 
 arch/x86/kernel/pci-nommu.c                     |    2 
 arch/x86/kernel/pci-swiotlb.c                   |   15 -
 arch/x86/kernel/process.c                       |   17 +
 arch/x86/kernel/setup.c                         |    9 
 arch/x86/kvm/mmu.c                              |   12 
 arch/x86/kvm/mmu.h                              |    2 
 arch/x86/kvm/svm.c                              |   35 +
 arch/x86/kvm/vmx.c                              |    3 
 arch/x86/kvm/x86.c                              |    3 
 arch/x86/lib/cmdline.c                          |  105 ++++
 arch/x86/mm/Makefile                            |    3 
 arch/x86/mm/fault.c                             |   10 
 arch/x86/mm/ident_map.c                         |   12 
 arch/x86/mm/ioremap.c                           |  277 +++++++++-
 arch/x86/mm/kasan_init_64.c                     |    4 
 arch/x86/mm/mem_encrypt.c                       |  667 +++++++++++++++++++++++
 arch/x86/mm/mem_encrypt_boot.S                  |  150 +++++
 arch/x86/mm/pageattr.c                          |   67 ++
 arch/x86/mm/pat.c                               |    9 
 arch/x86/pci/common.c                           |    4 
 arch/x86/platform/efi/efi.c                     |    6 
 arch/x86/platform/efi/efi_64.c                  |   15 -
 arch/x86/platform/olpc/olpc-xo1-pm.c            |    2 
 arch/x86/power/hibernate_64.c                   |    2 
 arch/x86/realmode/init.c                        |   15 +
 arch/x86/realmode/rm/trampoline_64.S            |   24 +
 arch/x86/xen/mmu_pv.c                           |    6 
 drivers/firmware/dmi-sysfs.c                    |    5 
 drivers/firmware/efi/efi.c                      |   33 +
 drivers/firmware/pcdp.c                         |    4 
 drivers/gpu/drm/drm_gem.c                       |    2 
 drivers/gpu/drm/drm_vm.c                        |    4 
 drivers/gpu/drm/ttm/ttm_bo_vm.c                 |    7 
 drivers/gpu/drm/udl/udl_fb.c                    |    4 
 drivers/iommu/amd_iommu.c                       |   36 +
 drivers/iommu/amd_iommu_init.c                  |   18 -
 drivers/iommu/amd_iommu_proto.h                 |   10 
 drivers/iommu/amd_iommu_types.h                 |    2 
 drivers/sfi/sfi_core.c                          |   22 -
 drivers/video/fbdev/core/fbmem.c                |   12 
 include/asm-generic/early_ioremap.h             |    2 
 include/asm-generic/mem_encrypt.h               |   45 ++
 include/asm-generic/pgtable.h                   |    8 
 include/linux/dma-mapping.h                     |    9 
 include/linux/efi.h                             |    9 
 include/linux/io.h                              |    2 
 include/linux/kexec.h                           |   14 
 include/linux/mem_encrypt.h                     |   18 +
 include/linux/swiotlb.h                         |    1 
 init/main.c                                     |   13 
 kernel/kexec_core.c                             |    6 
 kernel/memremap.c                               |   20 +
 lib/swiotlb.c                                   |   59 ++
 mm/early_ioremap.c                              |   30 +
 91 files changed, 2411 insertions(+), 261 deletions(-)
 create mode 100644 Documentation/x86/amd-memory-encryption.txt
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/mm/mem_encrypt.c
 create mode 100644 arch/x86/mm/mem_encrypt_boot.S
 create mode 100644 include/asm-generic/mem_encrypt.h
 create mode 100644 include/linux/mem_encrypt.h

-- 
Tom Lendacky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
