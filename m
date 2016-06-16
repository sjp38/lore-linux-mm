Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2C36B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:38:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y77so52596531qkb.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:38:40 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0064.outbound.protection.outlook.com. [157.56.111.64])
        by mx.google.com with ESMTPS id e9si26736012qgd.66.2016.06.16.07.38.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 07:38:39 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160608111844.GV2658@codeblueprint.co.uk> <5759B67A.4000800@amd.com>
 <20160613135110.GC2658@codeblueprint.co.uk> <57615561.4090502@amd.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5762B9E7.80903@amd.com>
Date: Thu, 16 Jun 2016 09:38:31 -0500
MIME-Version: 1.0
In-Reply-To: <57615561.4090502@amd.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 06/15/2016 08:17 AM, Tom Lendacky wrote:
> On 06/13/2016 08:51 AM, Matt Fleming wrote:
>> On Thu, 09 Jun, at 01:33:30PM, Tom Lendacky wrote:
>>>

[...]

>>
>>> I'll look further into this, but I saw that this area of virtual memory
>>> was mapped un-encrypted and after freeing the boot services the
>>> mappings were somehow reused as un-encrypted for DMA which assumes
>>> (unless using swiotlb) encrypted. This resulted in DMA data being
>>> transferred in as encrypted and then accessed un-encrypted.
>>
>> That the mappings were re-used isn't a surprise.
>>
>> efi_free_boot_services() lifts the reservation that was put in place
>> during efi_reserve_boot_services() and releases the pages to the
>> kernel's memory allocators.
>>
>> What is surprising is that they were marked unencrypted at all.
>> There's nothing special about these pages as far as the __va() region
>> is concerned.
> 
> Right, let me keep looking into this to see if I can pin down what
> was (or is) happening.

Ok, I think this was happening before the commit to build our own
EFI page table structures:

commit 67a9108ed ("x86/efi: Build our own page table structures")

Before this commit the boot services ended up mapped into the kernel
page table entries as un-encrypted during efi_map_regions() and I needed
to change those entries back to encrypted. With your change above,
this appears to no longer be needed.

Thanks,
Tom

> 
> Thanks,
> Tom
> 
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
