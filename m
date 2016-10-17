Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA7966B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 09:51:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e203so81130730itc.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 06:51:44 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0042.outbound.protection.outlook.com. [104.47.38.42])
        by mx.google.com with ESMTPS id z193si6287315itb.64.2016.10.17.06.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 06:51:44 -0700 (PDT)
Subject: Re: [RFC PATCH v1 00/28] x86: Secure Encrypted Virtualization (AMD)
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <d8f5b59e-5450-6bf6-c01e-084e612a4fed@redhat.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <7c1c7a4a-02cd-fa9b-5f4e-065db2042e15@amd.com>
Date: Mon, 17 Oct 2016 08:51:33 -0500
MIME-Version: 1.0
In-Reply-To: <d8f5b59e-5450-6bf6-c01e-084e612a4fed@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com
Cc: brijesh.singh@amd.com

Hi Paolo,

Thanks for reviews. I will incorporate your feedbacks in v2.

On 10/13/2016 06:19 AM, Paolo Bonzini wrote:
>
>
> On 23/08/2016 01:23, Brijesh Singh wrote:
>> TODO:
>> - send qemu/seabios RFC's on respective mailing list
>> - integrate the psp driver with CCP driver (they share the PCI id's)
>> - add SEV guest migration command support
>> - add SEV snapshotting command support
>> - determine how to do ioremap of physical memory with mem encryption enabled
>>   (e.g acpi tables)
>
> The would be encrypted, right?  Similar to the EFI data in patch 9.

Yes.

>
>> - determine how to share the guest memory with hypervisor for to support
>>   pvclock driver
>
> Is it enough if the guest makes that page unencrypted?
>

Yes that should be enough. If guest can mark a page as unencrypted then 
hypervisor should be able to read and write to that particular page.

Tom's patches have introduced API (set_memory_dec) to mark memory as 
unencrypted but pvclock drv runs very early during boot (when irq was 
disabled). Because of this we are not able to use set_memory_dec() to 
mark the page as unencrypted. Will need to come up with method for 
handling these cases.

> I reviewed the KVM host-side patches and they are pretty
> straightforward, so the comments on each patch suffice.
>
> Thanks,
>
> Paolo
>
>> Brijesh Singh (11):
>>       crypto: add AMD Platform Security Processor driver
>>       KVM: SVM: prepare to reserve asid for SEV guest
>>       KVM: SVM: prepare for SEV guest management API support
>>       KVM: introduce KVM_SEV_ISSUE_CMD ioctl
>>       KVM: SVM: add SEV launch start command
>>       KVM: SVM: add SEV launch update command
>>       KVM: SVM: add SEV_LAUNCH_FINISH command
>>       KVM: SVM: add KVM_SEV_GUEST_STATUS command
>>       KVM: SVM: add KVM_SEV_DEBUG_DECRYPT command
>>       KVM: SVM: add KVM_SEV_DEBUG_ENCRYPT command
>>       KVM: SVM: add command to query SEV API version
>>
>> Tom Lendacky (17):
>>       kvm: svm: Add support for additional SVM NPF error codes
>>       kvm: svm: Add kvm_fast_pio_in support
>>       kvm: svm: Use the hardware provided GPA instead of page walk
>>       x86: Secure Encrypted Virtualization (SEV) support
>>       KVM: SVM: prepare for new bit definition in nested_ctl
>>       KVM: SVM: Add SEV feature definitions to KVM
>>       x86: Do not encrypt memory areas if SEV is enabled
>>       Access BOOT related data encrypted with SEV active
>>       x86/efi: Access EFI data as encrypted when SEV is active
>>       x86: Change early_ioremap to early_memremap for BOOT data
>>       x86: Don't decrypt trampoline area if SEV is active
>>       x86: DMA support for SEV memory encryption
>>       iommu/amd: AMD IOMMU support for SEV
>>       x86: Don't set the SME MSR bit when SEV is active
>>       x86: Unroll string I/O when SEV is active
>>       x86: Add support to determine if running with SEV enabled
>>       KVM: SVM: Enable SEV by setting the SEV_ENABLE cpu feature
>>
>>
>>  arch/x86/boot/compressed/Makefile      |    2
>>  arch/x86/boot/compressed/head_64.S     |   19 +
>>  arch/x86/boot/compressed/mem_encrypt.S |  123 ++++
>>  arch/x86/include/asm/io.h              |   26 +
>>  arch/x86/include/asm/kvm_emulate.h     |    3
>>  arch/x86/include/asm/kvm_host.h        |   27 +
>>  arch/x86/include/asm/mem_encrypt.h     |    3
>>  arch/x86/include/asm/svm.h             |    3
>>  arch/x86/include/uapi/asm/hyperv.h     |    4
>>  arch/x86/include/uapi/asm/kvm_para.h   |    4
>>  arch/x86/kernel/acpi/boot.c            |    4
>>  arch/x86/kernel/head64.c               |    4
>>  arch/x86/kernel/mem_encrypt.S          |   44 ++
>>  arch/x86/kernel/mpparse.c              |   10
>>  arch/x86/kernel/setup.c                |    7
>>  arch/x86/kernel/x8664_ksyms_64.c       |    1
>>  arch/x86/kvm/cpuid.c                   |    4
>>  arch/x86/kvm/mmu.c                     |   20 +
>>  arch/x86/kvm/svm.c                     |  906 ++++++++++++++++++++++++++++++++
>>  arch/x86/kvm/x86.c                     |   73 +++
>>  arch/x86/mm/ioremap.c                  |    7
>>  arch/x86/mm/mem_encrypt.c              |   50 ++
>>  arch/x86/platform/efi/efi_64.c         |   14
>>  arch/x86/realmode/init.c               |   11
>>  drivers/crypto/Kconfig                 |   11
>>  drivers/crypto/Makefile                |    1
>>  drivers/crypto/psp/Kconfig             |    8
>>  drivers/crypto/psp/Makefile            |    3
>>  drivers/crypto/psp/psp-dev.c           |  220 ++++++++
>>  drivers/crypto/psp/psp-dev.h           |   95 +++
>>  drivers/crypto/psp/psp-ops.c           |  454 ++++++++++++++++
>>  drivers/crypto/psp/psp-pci.c           |  376 +++++++++++++
>>  drivers/sfi/sfi_core.c                 |    6
>>  include/linux/ccp-psp.h                |  833 +++++++++++++++++++++++++++++
>>  include/uapi/linux/Kbuild              |    1
>>  include/uapi/linux/ccp-psp.h           |  182 ++++++
>>  include/uapi/linux/kvm.h               |  125 ++++
>>  37 files changed, 3643 insertions(+), 41 deletions(-)
>>  create mode 100644 arch/x86/boot/compressed/mem_encrypt.S
>>  create mode 100644 drivers/crypto/psp/Kconfig
>>  create mode 100644 drivers/crypto/psp/Makefile
>>  create mode 100644 drivers/crypto/psp/psp-dev.c
>>  create mode 100644 drivers/crypto/psp/psp-dev.h
>>  create mode 100644 drivers/crypto/psp/psp-ops.c
>>  create mode 100644 drivers/crypto/psp/psp-pci.c
>>  create mode 100644 include/linux/ccp-psp.h
>>  create mode 100644 include/uapi/linux/ccp-psp.h
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
