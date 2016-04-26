Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1182D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:56:05 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id n2so52177232obo.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:56:05 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0068.outbound.protection.outlook.com. [65.55.169.68])
        by mx.google.com with ESMTPS id eo8si9113023igc.75.2016.04.26.15.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:56:04 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Date: Tue, 26 Apr 2016 17:55:53 -0500
Message-ID: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

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
  Commit 8d54fcebd9b3 ("Merge branch 'x86/urgent'")

---

Tom Lendacky (18):
      x86: Set the write-protect cache mode for AMD processors
      x86: Secure Memory Encryption (SME) build enablement
      x86: Secure Memory Encryption (SME) support
      x86: Add the Secure Memory Encryption cpu feature
      x86: Handle reduction in physical address size with SME
      x86: Provide general kernel support for memory encryption
      x86: Extend the early_memmap support with additional attrs
      x86: Add support for early encryption/decryption of memory
      x86: Insure that memory areas are encrypted when possible
      x86/efi: Access EFI related tables in the clear
      x86: Decrypt trampoline area if memory encryption is active
      x86: Access device tree in the clear
      x86: DMA support for memory encryption
      iommu/amd: AMD IOMMU support for memory encryption
      x86: Enable memory encryption on the APs
      x86: Do not specify encrypted memory for VGA mapping
      x86/kvm: Enable Secure Memory Encryption of nested page tables
      x86: Add support to turn on Secure Memory Encryption


 Documentation/kernel-parameters.txt  |    3 
 arch/x86/Kconfig                     |    9 +
 arch/x86/include/asm/cacheflush.h    |    3 
 arch/x86/include/asm/cpufeature.h    |    1 
 arch/x86/include/asm/cpufeatures.h   |    5 
 arch/x86/include/asm/dma-mapping.h   |    5 
 arch/x86/include/asm/fixmap.h        |   16 ++
 arch/x86/include/asm/kvm_host.h      |    2 
 arch/x86/include/asm/mem_encrypt.h   |   99 ++++++++++
 arch/x86/include/asm/msr-index.h     |    2 
 arch/x86/include/asm/pgtable_types.h |   49 +++--
 arch/x86/include/asm/processor.h     |    3 
 arch/x86/include/asm/realmode.h      |   12 +
 arch/x86/include/asm/vga.h           |   13 +
 arch/x86/kernel/Makefile             |    2 
 arch/x86/kernel/asm-offsets.c        |    2 
 arch/x86/kernel/cpu/common.c         |    2 
 arch/x86/kernel/cpu/scattered.c      |    1 
 arch/x86/kernel/devicetree.c         |    6 -
 arch/x86/kernel/espfix_64.c          |    2 
 arch/x86/kernel/head64.c             |  100 +++++++++-
 arch/x86/kernel/head_64.S            |   42 +++-
 arch/x86/kernel/machine_kexec_64.c   |    2 
 arch/x86/kernel/mem_encrypt.S        |  343 ++++++++++++++++++++++++++++++++++
 arch/x86/kernel/pci-dma.c            |   11 +
 arch/x86/kernel/pci-nommu.c          |    2 
 arch/x86/kernel/pci-swiotlb.c        |    8 +
 arch/x86/kernel/setup.c              |   14 +
 arch/x86/kernel/x8664_ksyms_64.c     |    6 +
 arch/x86/kvm/mmu.c                   |    7 -
 arch/x86/kvm/vmx.c                   |    2 
 arch/x86/kvm/x86.c                   |    3 
 arch/x86/mm/Makefile                 |    1 
 arch/x86/mm/fault.c                  |    5 
 arch/x86/mm/ioremap.c                |   31 +++
 arch/x86/mm/kasan_init_64.c          |    4 
 arch/x86/mm/mem_encrypt.c            |  201 ++++++++++++++++++++
 arch/x86/mm/pageattr.c               |   78 ++++++++
 arch/x86/mm/pat.c                    |   11 +
 arch/x86/platform/efi/efi.c          |   26 +--
 arch/x86/platform/efi/efi_64.c       |    9 +
 arch/x86/platform/efi/quirks.c       |   12 +
 arch/x86/realmode/init.c             |   13 +
 arch/x86/realmode/rm/trampoline_64.S |   14 +
 drivers/firmware/efi/efi.c           |   18 +-
 drivers/firmware/efi/esrt.c          |   12 +
 drivers/iommu/amd_iommu.c            |   10 +
 include/asm-generic/early_ioremap.h  |    2 
 include/linux/efi.h                  |    3 
 include/linux/swiotlb.h              |    1 
 init/main.c                          |    6 +
 lib/swiotlb.c                        |   64 ++++++
 mm/early_ioremap.c                   |   15 +
 53 files changed, 1217 insertions(+), 96 deletions(-)
 create mode 100644 arch/x86/include/asm/mem_encrypt.h
 create mode 100644 arch/x86/kernel/mem_encrypt.S
 create mode 100644 arch/x86/mm/mem_encrypt.c

-- 
Tom Lendacky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
