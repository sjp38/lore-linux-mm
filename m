Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDCD46B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:17:34 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id y82so35679503oig.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:17:34 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0060.outbound.protection.outlook.com. [65.55.169.60])
        by mx.google.com with ESMTPS id j50si17741796otd.247.2016.06.15.06.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 15 Jun 2016 06:17:33 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160608111844.GV2658@codeblueprint.co.uk> <5759B67A.4000800@amd.com>
 <20160613135110.GC2658@codeblueprint.co.uk>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <57615561.4090502@amd.com>
Date: Wed, 15 Jun 2016 08:17:21 -0500
MIME-Version: 1.0
In-Reply-To: <20160613135110.GC2658@codeblueprint.co.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 06/13/2016 08:51 AM, Matt Fleming wrote:
> On Thu, 09 Jun, at 01:33:30PM, Tom Lendacky wrote:
>>
>> I was trying to play it safe here, but as you say, the firmware should
>> be using our page tables so we can get rid of this call. The problem
>> will actually be if we transition to a 32-bit efi. The encryption bit
>> will be lost in cr3 and so the pgd table will have to be un-encrypted.
>> The entries in the pgd can have the encryption bit set so I would only
>> need to worry about the pgd itself. I'll have to update the
>> efi_alloc_page_tables routine.
>  
> Interesting, I hadn't expected 32-bit EFI to be an option for
> platforms with the SME technology. I'd assumed we could just ignore
> that.

We may be able to do that.

> 
> Are you saying that the encryption bit isn't supported in 32-bit
> compatibility mode? We don't do a "full" switch to 32-bit protected
> mode when in mixed mode, just load a 32-bit code segment descriptor.
> The page tables are not modified at all.

The encryption bit is supported in 32-bit compatibility mode and since
we're not doing the "full" switch the cr3 register will remain as a
64-bit register so we can leave the pgd table encrypted.

> 
>> The encryption bit in the cr3 register will indicate if the pgd table
>> is encrypted or not. Based on my comment above about the pgd having
>> to be un-encrypted in case we have to transition to 32-bit efi, this
>> can be removed.
>  
> I'm not (yet) sure that the pgd needs to be unencrypted for 32-bit EFI
> when running a 64-bit kernel. In the AMD Programmer's Manual, Section
> 7.10.3 Operating Modes seems to indicate that running encrypted should
> work fine.
> 
>> I'll look into this a bit more. From looking at it I don't want the
>> _PAGE_ENC bit set for the memmap unless it gets re-allocated (which
>> I missed in these patches). Let me see what I can do with this.
>  
> I don't understand your comment about re-allocating the memmap.
> 
> The kernel builds its own EFI memory map at runtime, initially based
> on the memory map provided by the firmware. We always allocate a new
> memory map.

Sorry, I mis-interpreted the efi_map_regions function/loop and see
that the memmap is always allocated by the kernel.

> 
> In efi_setup_page_tables() we're building our own page tables, which
> should be encrypted, and mapping EFI regions described by the memmap
> into those page tables.
> 
> So unless we're mapping an MMIO region (in which case _PAGE_PCD is set
> in @flags for kernel_map_pages_in_pgd()) I would expect _PAGE_ENC to
> be set.
> 
>> I'll look further into this, but I saw that this area of virtual memory
>> was mapped un-encrypted and after freeing the boot services the
>> mappings were somehow reused as un-encrypted for DMA which assumes
>> (unless using swiotlb) encrypted. This resulted in DMA data being
>> transferred in as encrypted and then accessed un-encrypted.
> 
> That the mappings were re-used isn't a surprise.
> 
> efi_free_boot_services() lifts the reservation that was put in place
> during efi_reserve_boot_services() and releases the pages to the
> kernel's memory allocators.
> 
> What is surprising is that they were marked unencrypted at all.
> There's nothing special about these pages as far as the __va() region
> is concerned.

Right, let me keep looking into this to see if I can pin down what
was (or is) happening.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
