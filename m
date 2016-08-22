Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 879646B0264
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:22:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id f6so6486695ith.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:22:19 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0081.outbound.protection.outlook.com. [104.47.37.81])
        by mx.google.com with ESMTPS id v19si143038otv.265.2016.08.22.16.22.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:22:18 -0700 (PDT)
Subject: [RFC PATCH v1 00/28] x86: Secure Encrypted Virtualization (AMD)
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:21:52 -0400
Message-ID: <147190811185.9268.8427842212955719186.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, labbott@fedoraproject.org--to=linux-efi, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, simon.guinot@sequanux.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

This RFC series provides support for AMD's new Secure Encrypted 
Virtualization (SEV) feature. This RFC is build upon Secure Memory 
Encryption (SME) RFC.

SEV is an extension to the AMD-V architecture which supports running 
multiple VMs under the control of a hypervisor. When enabled, SEV 
hardware tags all code and data with its VM ASID which indicates which 
VM the data originated from or is intended for. This tag is kept with 
the data at all times when inside the SOC, and prevents that data from 
being used by anyone other than the owner. While the tag protects VM 
data inside the SOC, AES with 128 bit encryption protects data outside 
the SOC. When data leaves or enters the SOC, it is encrypted/decrypted 
respectively by hardware with a key based on the associated tag.

SEV guest VMs have the concept of private and shared memory.  Private memory
is encrypted with the  guest-specific key, while shared memory may be encrypted
with hypervisor key.  Certain types of memory (namely instruction pages and
guest page tables) are always treated as private memory by the hardware.
For data memory, SEV guest VMs can choose which pages they would like to
be private. The choice is done using the standard CPU page tables using
the C-bit, and is fully controlled by the guest. Due to security reasons
all the DMA operations inside the  guest must be performed on shared pages
(C-bit clear).  Note that since C-bit is only controllable by the guest OS
when it is operating in 64-bit or 32-bit PAE mode, in all other modes the
SEV hardware forces the C-bit to a 1.

SEV is designed to protect guest VMs from a benign but vulnerable
(i.e. not fully malicious) hypervisor. In particular, it reduces the attack
surface of guest VMs and can prevent certain types of VM-escape bugs
(e.g. hypervisor read-anywhere) from being used to steal guest data.

The RFC series also includes a crypto driver (psp.ko) which communicates
with SEV firmware that runs within the AMD secure processor provides a
secure key management interfaces. The hypervisor uses this interface to 
enable SEV for secure guest and perform common hypervisor activities
such as launching, running, snapshotting , migrating and debugging a 
guest. A new ioctl (KVM_SEV_ISSUE_CMD) is introduced which will enable
Qemu to send commands to the SEV firmware during guest life cycle.

The RFC series also includes patches required in guest OS to enable SEV 
feature. A guest OS can check SEV support by calling KVM_FEATURE cpuid 
instruction.

The following links provide additional details:

AMD Memory Encryption whitepaper:
 
http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/AMD_Memory_Encryption_Whitepaper_v7-Public.pdf

AMD64 Architecture Programmer's Manual:
    http://support.amd.com/TechDocs/24593.pdf
    SME is section 7.10
    SEV is section 15.34

Secure Encrypted Virutualization Key Management:
http://support.amd.com/TechDocs/55766_SEV-KM API_Spec.pdf

---

TODO:
- send qemu/seabios RFC's on respective mailing list
- integrate the psp driver with CCP driver (they share the PCI id's)
- add SEV guest migration command support
- add SEV snapshotting command support
- determine how to do ioremap of physical memory with mem encryption enabled
  (e.g acpi tables)
- determine how to share the guest memory with hypervisor for to support
  pvclock driver

Brijesh Singh (11):
      crypto: add AMD Platform Security Processor driver
      KVM: SVM: prepare to reserve asid for SEV guest
      KVM: SVM: prepare for SEV guest management API support
      KVM: introduce KVM_SEV_ISSUE_CMD ioctl
      KVM: SVM: add SEV launch start command
      KVM: SVM: add SEV launch update command
      KVM: SVM: add SEV_LAUNCH_FINISH command
      KVM: SVM: add KVM_SEV_GUEST_STATUS command
      KVM: SVM: add KVM_SEV_DEBUG_DECRYPT command
      KVM: SVM: add KVM_SEV_DEBUG_ENCRYPT command
      KVM: SVM: add command to query SEV API version

Tom Lendacky (17):
      kvm: svm: Add support for additional SVM NPF error codes
      kvm: svm: Add kvm_fast_pio_in support
      kvm: svm: Use the hardware provided GPA instead of page walk
      x86: Secure Encrypted Virtualization (SEV) support
      KVM: SVM: prepare for new bit definition in nested_ctl
      KVM: SVM: Add SEV feature definitions to KVM
      x86: Do not encrypt memory areas if SEV is enabled
      Access BOOT related data encrypted with SEV active
      x86/efi: Access EFI data as encrypted when SEV is active
      x86: Change early_ioremap to early_memremap for BOOT data
      x86: Don't decrypt trampoline area if SEV is active
      x86: DMA support for SEV memory encryption
      iommu/amd: AMD IOMMU support for SEV
      x86: Don't set the SME MSR bit when SEV is active
      x86: Unroll string I/O when SEV is active
      x86: Add support to determine if running with SEV enabled
      KVM: SVM: Enable SEV by setting the SEV_ENABLE cpu feature


 arch/x86/boot/compressed/Makefile      |    2 
 arch/x86/boot/compressed/head_64.S     |   19 +
 arch/x86/boot/compressed/mem_encrypt.S |  123 ++++
 arch/x86/include/asm/io.h              |   26 +
 arch/x86/include/asm/kvm_emulate.h     |    3 
 arch/x86/include/asm/kvm_host.h        |   27 +
 arch/x86/include/asm/mem_encrypt.h     |    3 
 arch/x86/include/asm/svm.h             |    3 
 arch/x86/include/uapi/asm/hyperv.h     |    4 
 arch/x86/include/uapi/asm/kvm_para.h   |    4 
 arch/x86/kernel/acpi/boot.c            |    4 
 arch/x86/kernel/head64.c               |    4 
 arch/x86/kernel/mem_encrypt.S          |   44 ++
 arch/x86/kernel/mpparse.c              |   10 
 arch/x86/kernel/setup.c                |    7 
 arch/x86/kernel/x8664_ksyms_64.c       |    1 
 arch/x86/kvm/cpuid.c                   |    4 
 arch/x86/kvm/mmu.c                     |   20 +
 arch/x86/kvm/svm.c                     |  906 ++++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c                     |   73 +++
 arch/x86/mm/ioremap.c                  |    7 
 arch/x86/mm/mem_encrypt.c              |   50 ++
 arch/x86/platform/efi/efi_64.c         |   14 
 arch/x86/realmode/init.c               |   11 
 drivers/crypto/Kconfig                 |   11 
 drivers/crypto/Makefile                |    1 
 drivers/crypto/psp/Kconfig             |    8 
 drivers/crypto/psp/Makefile            |    3 
 drivers/crypto/psp/psp-dev.c           |  220 ++++++++
 drivers/crypto/psp/psp-dev.h           |   95 +++
 drivers/crypto/psp/psp-ops.c           |  454 ++++++++++++++++
 drivers/crypto/psp/psp-pci.c           |  376 +++++++++++++
 drivers/sfi/sfi_core.c                 |    6 
 include/linux/ccp-psp.h                |  833 +++++++++++++++++++++++++++++
 include/uapi/linux/Kbuild              |    1 
 include/uapi/linux/ccp-psp.h           |  182 ++++++
 include/uapi/linux/kvm.h               |  125 ++++
 37 files changed, 3643 insertions(+), 41 deletions(-)
 create mode 100644 arch/x86/boot/compressed/mem_encrypt.S
 create mode 100644 drivers/crypto/psp/Kconfig
 create mode 100644 drivers/crypto/psp/Makefile
 create mode 100644 drivers/crypto/psp/psp-dev.c
 create mode 100644 drivers/crypto/psp/psp-dev.h
 create mode 100644 drivers/crypto/psp/psp-ops.c
 create mode 100644 drivers/crypto/psp/psp-pci.c
 create mode 100644 include/linux/ccp-psp.h
 create mode 100644 include/uapi/linux/ccp-psp.h

-- 

Brijesh Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
