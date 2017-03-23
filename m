Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04EEF6B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 17:03:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c87so349862086pfl.6
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 14:02:59 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0050.outbound.protection.outlook.com. [104.47.32.50])
        by mx.google.com with ESMTPS id h29si35640pfd.390.2017.03.23.14.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Mar 2017 14:02:58 -0700 (PDT)
Subject: Re: [RFC PATCH v4 15/28] Add support to access persistent memory in
 the clear
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154521.19244.89502.stgit@tlendack-t1.amdoffice.net>
 <DF4PR84MB01694A716568EFB01F5C1C5EAB390@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <01d5f854-c8ea-61db-7e1b-1f97952bff75@amd.com>
Date: Thu, 23 Mar 2017 16:02:53 -0500
MIME-Version: 1.0
In-Reply-To: <DF4PR84MB01694A716568EFB01F5C1C5EAB390@DF4PR84MB0169.NAMPRD84.PROD.OUTLOOK.COM>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 3/17/2017 5:58 PM, Elliott, Robert (Persistent Memory) wrote:
>
>
>> -----Original Message-----
>> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
>> owner@vger.kernel.org] On Behalf Of Tom Lendacky
>> Sent: Thursday, February 16, 2017 9:45 AM
>> Subject: [RFC PATCH v4 15/28] Add support to access persistent memory in
>> the clear
>>
>> Persistent memory is expected to persist across reboots. The encryption
>> key used by SME will change across reboots which will result in corrupted
>> persistent memory.  Persistent memory is handed out by block devices
>> through memory remapping functions, so be sure not to map this memory as
>> encrypted.
>
> The system might be able to save and restore the correct encryption key for a
> region of persistent memory, in which case it does need to be mapped as
> encrypted.

If the OS could get some indication that BIOS/UEFI has saved and
restored the encryption key, then it could be mapped encrypted.

>
> This might deserve a new EFI_MEMORY_ENCRYPTED attribute bit so the
> system firmware can communicate that information to the OS (in the
> UEFI memory map and the ACPI NFIT SPA Range structures).  It wouldn't
> likely ever be added to the E820h table - ACPI 6.1 already obsoleted the
> Extended Attribute for AddressRangeNonVolatile.

An attribute bit in some form would be a nice way to inform the OS that
the persistent memory can be mapped encrypted.

>
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/mm/ioremap.c |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index b0ff6bc..c6cb921 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -498,6 +498,8 @@ static bool
>> memremap_should_map_encrypted(resource_size_t phys_addr,
>>  	case E820_TYPE_ACPI:
>>  	case E820_TYPE_NVS:
>>  	case E820_TYPE_UNUSABLE:
>> +	case E820_TYPE_PMEM:
>> +	case E820_TYPE_PRAM:
>>  		return false;
>>  	default:
>>  		break;
>
> E820_TYPE_RESERVED is also used to report persistent memory in
> some systems (patch 16 adds that for other reasons).
>
> You might want to intercept the persistent memory types in the
> efi_mem_type(phys_addr) switch statement earlier in the function
> as well.  https://lkml.org/lkml/2017/3/13/357 recently mentioned that
> "in qemu hotpluggable memory isn't put into E820," with the latest
> information only in the UEFI memory map.
>
> Persistent memory can be reported there as:
> * EfiReservedMemoryType type with the EFI_MEMORY_NV attribute
> * EfiPersistentMemory type with the EFI_MEMORY_NV attribute
>
> Even the UEFI memory map is not authoritative, though.  To really
> determine what is in these regions requires parsing the ACPI NFIT
> SPA Ranges structures.  Parts of the E820 or UEFI regions could be
> reported as volatile there and should thus be encrypted.

Thanks for the details on this. I'll take a closer look at this and
update the checks appropriately.

Thanks,
Tom

>
> ---
> Robert Elliott, HPE Persistent Memory
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
