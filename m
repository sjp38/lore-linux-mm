Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAC56B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:28:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t184so57036505pgt.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 09:28:04 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0077.outbound.protection.outlook.com. [104.47.40.77])
        by mx.google.com with ESMTPS id q9si4873752pli.125.2017.02.23.09.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 09:28:03 -0800 (PST)
Subject: Re: [RFC PATCH v4 13/28] efi: Update efi_mem_type() to return defined
 EFI mem types
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154457.19244.5369.stgit@tlendack-t1.amdoffice.net>
 <20170221120505.GQ28416@codeblueprint.co.uk>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <41d5df05-14be-ff33-a7e2-6b2f51e2605a@amd.com>
Date: Thu, 23 Feb 2017 11:27:55 -0600
MIME-Version: 1.0
In-Reply-To: <20170221120505.GQ28416@codeblueprint.co.uk>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/21/2017 6:05 AM, Matt Fleming wrote:
> On Thu, 16 Feb, at 09:44:57AM, Tom Lendacky wrote:
>> Update the efi_mem_type() to return EFI_RESERVED_TYPE instead of a
>> hardcoded 0.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/platform/efi/efi.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
>> index a15cf81..6407103 100644
>> --- a/arch/x86/platform/efi/efi.c
>> +++ b/arch/x86/platform/efi/efi.c
>> @@ -1037,7 +1037,7 @@ u32 efi_mem_type(unsigned long phys_addr)
>>  	efi_memory_desc_t *md;
>>
>>  	if (!efi_enabled(EFI_MEMMAP))
>> -		return 0;
>> +		return EFI_RESERVED_TYPE;
>>
>>  	for_each_efi_memory_desc(md) {
>>  		if ((md->phys_addr <= phys_addr) &&
>> @@ -1045,7 +1045,7 @@ u32 efi_mem_type(unsigned long phys_addr)
>>  				  (md->num_pages << EFI_PAGE_SHIFT))))
>>  			return md->type;
>>  	}
>> -	return 0;
>> +	return EFI_RESERVED_TYPE;
>>  }
>
> I see what you're getting at here, but arguably the return value in
> these cases never should have been zero to begin with (your change
> just makes that more obvious).
>
> Returning EFI_RESERVED_TYPE implies an EFI memmap entry exists for
> this address, which is misleading because it doesn't in the hunks
> you've modified above.
>
> Instead, could you look at returning a negative error value in the
> usual way we do in the Linux kernel, and update the function prototype
> to match? I don't think any callers actually require the return type
> to be u32.

I can do that, I'll change the return type to an int. For the
!efi_enabled I can return -ENOTSUPP and for when an entry isn't
found I can return -EINVAL.  Sound good?

The ia64 arch is the only other arch that defines the function. It
has just a single return 0 that I'll change to -EINVAL.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
