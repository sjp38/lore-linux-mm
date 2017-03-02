Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4F896B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:12:07 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f103so67543845ioi.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:12:07 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0045.outbound.protection.outlook.com. [104.47.32.45])
        by mx.google.com with ESMTPS id c134si9187190ioe.171.2017.03.02.07.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:12:06 -0800 (PST)
Subject: [RFC PATCH v2 00/32] x86: Secure Encrypted Virtualization (AMD)
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:12:01 -0500
Message-ID: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

This RFC series provides support for AMD's new Secure Encrypted Virtualization
(SEV) feature. This RFC is build upon Secure Memory Encryption (SME) RFCv4 [1].

SEV is an extension to the AMD-V architecture which supports running multiple
VMs under the control of a hypervisor. When enabled, SEV hardware tags all
code and data with its VM ASID which indicates which VM the data originated
from or is intended for. This tag is kept with the data at all times when
inside the SOC, and prevents that data from being used by anyone other than the
owner. While the tag protects VM data inside the SOC, AES with 128 bit
encryption protects data outside the SOC. When data leaves or enters the SOC,
it is encrypted/decrypted  respectively by hardware with a key based on the
associated tag.

SEV guest VMs have the concept of private and shared memory.  Private memory is
encrypted with the  guest-specific key, while shared memory may be encrypted
with hypervisor key.  Certain types of memory (namely instruction pages and
guest page tables) are always treated as private memory by the hardware.
For data memory, SEV guest VMs can choose which pages they would like to be
private. The choice is done using the standard CPU page tables using the C-bit,
and is fully controlled by the guest. Due to security reasons all the DMA
operations inside the  guest must be performed on shared pages (C-bit clear).
Note that since C-bit is only controllable by the guest OS when it is operating
in 64-bit or 32-bit PAE mode, in all other modes the SEV hardware forces the
C-bit to a 1.

SEV is designed to protect guest VMs from a benign but vulnerable (i.e. not
fully malicious) hypervisor. In particular, it reduces the attack surface of
guest VMs and can prevent certain types of VM-escape bugs (e.g. hypervisor
read-anywhere) from being used to steal guest data.

The RFC series also expands crypto driver (ccp.ko) to include the support for
Platform Security Processor (PSP) which is used for communicating with SEV
firmware that runs within the AMD secure processor providing a secure key
management interfaces. The hypervisor uses this interface to encrypt the
bootstrap code and perform common activities such as launching, running,
snapshotting, migrating and debugging encrypted guest.

A new ioctl (KVM_MEMORY_ENCRYPT_OP) is introduced which can be used by Qemu to
issue SEV guest life cycle commands.

The RFC series also includes patches required in guest OS to enable SEV feature.
A guest OS can check SEV support by calling KVM_FEATURE cpuid instruction.

The patch breakdown:
* [1 - 17]: guest OS specific changes when SEV is active
* [18]: already queued in kvm upstream tree but was not in tip tree hence its
  included so that build does not fail
* [19 - 21]: since CCP and PSP shares the same PCIe ID hence the patch expands
  the CCP driver by creating a high level AMD Secure Processor (SP) framework
  to allow integration of PSP device into ccp.ko.
* [22 - 32]: hypervisor changes to support memory encryption

The following links provide additional details:

AMD Memory Encryption whitepaper:
http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2013/12/AMD_Memory_Encryption_Whitepaper_v7-Public.pdf

AMD64 Architecture Programmer's Manual:
    http://support.amd.com/TechDocs/24593.pdf
    SME is section 7.10
    SEV is section 15.34

Secure Encrypted Virutualization Key Management:
http://support.amd.com/TechDocs/55766_SEV-KM API_Specification.pdf

KVM Forum Presentation:
http://www.linux-kvm.org/images/7/74/02x08A-Thomas_Lendacky-AMDs_Virtualizatoin_Memory_Encryption_Technology.pdf

[1] http://marc.info/?l=linux-kernel&m=148725974113693&w=2

---

Based on the feedbacks, we have started adding the SEV guest support in OVMF
BIOS. This series has been tested using EDK2/OVMF BIOS, the initial EDK2 patches
has been submmited on edk2 mailing list for discussion.

TODO:
 - add support for migration commands
 - update QEMU RFC's to SEV spec 0.14
 - investigate virtio and vfio support for SEV guest
 - investigate SMM support for SEV guest
 - add support for nested virtualization

Changes since v1:
 - update to newer SEV key management API spec (0.12 -> 0.14)
 - expand the CCP driver and integrate the PSP interface support
 - remove the usage of SEV ref_count and release the SEV FW resources in
   kvm_x86_ops->vm_destroy
 - acquire the kvm->lock before executing the SEV commands and release on exit.
 - rename ioctl from KVM_SEV_ISSUE_CMD to KVM_MEMORY_ENCRYPT_OP
 - extend KVM_MEMORY_ENCRYPT_OP ioctl to require file descriptor for the SEV
   device. A program without access to /dev/sev will not be able to issue SEV
   commands
 - update vmcb on succesful LAUNCH_FINISH to indicate that SEV is active
 - serveral fixes based on Paolo's review feedbacks
 - add APIs to support sharing the guest physical address with hypervisor
 - update kvm pvclock driver to use the shared buffer when SEV is active
 - pin the SEV guest memory

Brijesh Singh (18):
      x86: mm: Provide support to use memblock when spliting large pages
      x86: Add support for changing memory encryption attribute in early boot
      x86: kvm: Provide support to create Guest and HV shared per-CPU variables
      x86: kvmclock: Clear encryption attribute when SEV is active
      crypto: ccp: Introduce the AMD Secure Processor device
      crypto: ccp: Add Platform Security Processor (PSP) interface support
      crypto: ccp: Add Secure Encrypted Virtualization (SEV) interface support
      kvm: svm: prepare to reserve asid for SEV guest
      kvm: introduce KVM_MEMORY_ENCRYPT_OP ioctl
      kvm: x86: prepare for SEV guest management API support
      kvm: svm: Add support for SEV LAUNCH_START command
      kvm: svm: Add support for SEV LAUNCH_UPDATE_DATA command
      kvm: svm: Add support for SEV LAUNCH_FINISH command
      kvm: svm: Add support for SEV GUEST_STATUS command
      kvm: svm: Add support for SEV DEBUG_DECRYPT command
      kvm: svm: Add support for SEV DEBUG_ENCRYPT command
      kvm: svm: Add support for SEV LAUNCH_MEASURE command
      x86: kvm: Pin the guest memory when SEV is active

Tom Lendacky (14):
      x86: Add the Secure Encrypted Virtualization CPU feature
      x86: Secure Encrypted Virtualization (SEV) support
      KVM: SVM: prepare for new bit definition in nested_ctl
      KVM: SVM: Add SEV feature definitions to KVM
      x86: Use encrypted access of BOOT related data with SEV
      x86/pci: Use memremap when walking setup data
      x86/efi: Access EFI data as encrypted when SEV is active
      x86: Use PAGE_KERNEL protection for ioremap of memory page
      x86: Change early_ioremap to early_memremap for BOOT data
      x86: DMA support for SEV memory encryption
      x86: Unroll string I/O when SEV is active
      x86: Add early boot support when running with SEV active
      KVM: SVM: Enable SEV by setting the SEV_ENABLE CPU feature
      kvm: svm: Use the hardware provided GPA instead of page walk



 arch/x86/boot/compressed/Makefile      |    2 
 arch/x86/boot/compressed/head_64.S     |   16 
 arch/x86/boot/compressed/mem_encrypt.S |   75 ++
 arch/x86/include/asm/cpufeatures.h     |    1 
 arch/x86/include/asm/io.h              |   26 +
 arch/x86/include/asm/kvm_emulate.h     |    1 
 arch/x86/include/asm/kvm_host.h        |   19 +
 arch/x86/include/asm/mem_encrypt.h     |   29 +
 arch/x86/include/asm/msr-index.h       |    2 
 arch/x86/include/asm/svm.h             |    3 
 arch/x86/include/uapi/asm/hyperv.h     |    4 
 arch/x86/include/uapi/asm/kvm_para.h   |    4 
 arch/x86/kernel/acpi/boot.c            |    4 
 arch/x86/kernel/cpu/amd.c              |   22 +
 arch/x86/kernel/cpu/scattered.c        |    1 
 arch/x86/kernel/kvm.c                  |   43 +
 arch/x86/kernel/kvmclock.c             |   65 ++
 arch/x86/kernel/mem_encrypt_init.c     |   24 +
 arch/x86/kernel/mpparse.c              |   10 
 arch/x86/kvm/cpuid.c                   |    4 
 arch/x86/kvm/emulate.c                 |   20 -
 arch/x86/kvm/svm.c                     | 1051 ++++++++++++++++++++++++++++++++
 arch/x86/kvm/x86.c                     |   60 ++
 arch/x86/mm/ioremap.c                  |   44 +
 arch/x86/mm/mem_encrypt.c              |  143 ++++
 arch/x86/mm/pageattr.c                 |   51 +-
 arch/x86/pci/common.c                  |    4 
 arch/x86/platform/efi/efi_64.c         |   15 
 drivers/crypto/Kconfig                 |   10 
 drivers/crypto/ccp/Kconfig             |   55 +-
 drivers/crypto/ccp/Makefile            |   10 
 drivers/crypto/ccp/ccp-dev-v3.c        |   86 +--
 drivers/crypto/ccp/ccp-dev-v5.c        |   73 +-
 drivers/crypto/ccp/ccp-dev.c           |  137 ++--
 drivers/crypto/ccp/ccp-dev.h           |   35 -
 drivers/crypto/ccp/psp-dev.c           |  211 ++++++
 drivers/crypto/ccp/psp-dev.h           |  102 +++
 drivers/crypto/ccp/sev-dev.c           |  348 +++++++++++
 drivers/crypto/ccp/sev-dev.h           |   67 ++
 drivers/crypto/ccp/sev-ops.c           |  324 ++++++++++
 drivers/crypto/ccp/sp-dev.c            |  324 ++++++++++
 drivers/crypto/ccp/sp-dev.h            |  172 +++++
 drivers/crypto/ccp/sp-pci.c            |  328 ++++++++++
 drivers/crypto/ccp/sp-platform.c       |  268 ++++++++
 drivers/sfi/sfi_core.c                 |    6 
 include/asm-generic/vmlinux.lds.h      |    3 
 include/linux/ccp.h                    |    3 
 include/linux/mem_encrypt.h            |    6 
 include/linux/mm.h                     |    1 
 include/linux/percpu-defs.h            |    9 
 include/linux/psp-sev.h                |  672 ++++++++++++++++++++
 include/uapi/linux/Kbuild              |    1 
 include/uapi/linux/kvm.h               |  100 +++
 include/uapi/linux/psp-sev.h           |  123 ++++
 kernel/resource.c                      |   40 +
 55 files changed, 4991 insertions(+), 266 deletions(-)
 create mode 100644 arch/x86/boot/compressed/mem_encrypt.S
 create mode 100644 drivers/crypto/ccp/psp-dev.c
 create mode 100644 drivers/crypto/ccp/psp-dev.h
 create mode 100644 drivers/crypto/ccp/sev-dev.c
 create mode 100644 drivers/crypto/ccp/sev-dev.h
 create mode 100644 drivers/crypto/ccp/sev-ops.c
 create mode 100644 drivers/crypto/ccp/sp-dev.c
 create mode 100644 drivers/crypto/ccp/sp-dev.h
 create mode 100644 drivers/crypto/ccp/sp-pci.c
 create mode 100644 drivers/crypto/ccp/sp-platform.c
 create mode 100644 include/linux/psp-sev.h
 create mode 100644 include/uapi/linux/psp-sev.h


--
Brijesh Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
