Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 982F96B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:18:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so98917238pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:18:00 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0082.outbound.protection.outlook.com. [104.47.41.82])
        by mx.google.com with ESMTPS id h29si4280615pfd.390.2017.03.16.11.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 11:17:59 -0700 (PDT)
Subject: Re: [RFC PATCH v2 32/32] x86: kvm: Pin the guest memory when SEV is
 active
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846793743.2349.8478208161427437950.stgit@brijesh-build-machine>
 <453770c9-f9d7-4806-dbae-d19876f2a22e@redhat.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <b2a3cb42-1467-823e-affd-72a0be577932@amd.com>
Date: Thu, 16 Mar 2017 13:17:47 -0500
MIME-Version: 1.0
In-Reply-To: <453770c9-f9d7-4806-dbae-d19876f2a22e@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net
Cc: brijesh.singh@amd.com



On 03/16/2017 05:38 AM, Paolo Bonzini wrote:
>
>
> On 02/03/2017 16:18, Brijesh Singh wrote:
>> The SEV memory encryption engine uses a tweak such that two identical
>> plaintexts at different location will have a different ciphertexts.
>> So swapping or moving ciphertexts of two pages will not result in
>> plaintexts being swapped. Relocating (or migrating) a physical backing pages
>> for SEV guest will require some additional steps. The current SEV key
>> management spec [1] does not provide commands to swap or migrate (move)
>> ciphertexts. For now we pin the memory allocated for the SEV guest. In
>> future when SEV key management spec provides the commands to support the
>> page migration we can update the KVM code to remove the pinning logical
>> without making any changes into userspace (qemu).
>>
>> The patch pins userspace memory when a new slot is created and unpin the
>> memory when slot is removed.
>>
>> [1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf
>
> This is not enough, because memory can be hidden temporarily from the
> guest and remapped later.  Think of a PCI BAR that is backed by RAM, or
> also SMRAM.  The pinning must be kept even in that case.
>
> You need to add a pair of KVM_MEMORY_ENCRYPT_OPs (one that doesn't map
> to a PSP operation), such as KVM_REGISTER/UNREGISTER_ENCRYPTED_RAM.  In
> QEMU you can use a RAMBlockNotifier to invoke the ioctls.
>

I was hoping to avoid adding new ioctl, but I see your point. Will add a pair of ioctl's
and use RAMBlocNotifier to invoke those ioctls.

-Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
