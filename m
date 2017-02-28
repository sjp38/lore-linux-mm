Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 120926B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 17:34:48 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x17so32914252pgi.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 14:34:48 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0047.outbound.protection.outlook.com. [104.47.40.47])
        by mx.google.com with ESMTPS id q77si2908078pfi.41.2017.02.28.14.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Feb 2017 14:34:46 -0800 (PST)
Subject: Re: [RFC PATCH v4 11/28] x86: Add support to determine the E820 type
 of an address
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154430.19244.95519.stgit@tlendack-t1.amdoffice.net>
 <20170220200955.32e2wqxgulswnr55@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e6146786-16c5-99ab-52c9-2bdd50c7d9ba@amd.com>
Date: Tue, 28 Feb 2017 16:34:39 -0600
MIME-Version: 1.0
In-Reply-To: <20170220200955.32e2wqxgulswnr55@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/20/2017 2:09 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:44:30AM -0600, Tom Lendacky wrote:
>> This patch adds support to return the E820 type associated with an address
>
> s/This patch adds/Add/
>
>> range.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/e820/api.h   |    2 ++
>>  arch/x86/include/asm/e820/types.h |    2 ++
>>  arch/x86/kernel/e820.c            |   26 +++++++++++++++++++++++---
>>  3 files changed, 27 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/e820/api.h b/arch/x86/include/asm/e820/api.h
>> index 8e0f8b8..7c1bdc9 100644
>> --- a/arch/x86/include/asm/e820/api.h
>> +++ b/arch/x86/include/asm/e820/api.h
>> @@ -38,6 +38,8 @@
>>  extern void e820__reallocate_tables(void);
>>  extern void e820__register_nosave_regions(unsigned long limit_pfn);
>>
>> +extern enum e820_type e820__get_entry_type(u64 start, u64 end);
>> +
>>  /*
>>   * Returns true iff the specified range [start,end) is completely contained inside
>>   * the ISA region.
>> diff --git a/arch/x86/include/asm/e820/types.h b/arch/x86/include/asm/e820/types.h
>> index 4adeed0..bf49591 100644
>> --- a/arch/x86/include/asm/e820/types.h
>> +++ b/arch/x86/include/asm/e820/types.h
>> @@ -7,6 +7,8 @@
>>   * These are the E820 types known to the kernel:
>>   */
>>  enum e820_type {
>> +	E820_TYPE_INVALID	= 0,
>> +
>
> Now this is strange - ACPI spec doesn't explicitly say that range type 0
> is invalid. Am I looking at the wrong place?
>
> "Table 15-312 Address Range Types12" in ACPI spec 6.
>
> If 0 is really the invalid entry, then e820_print_type() needs updating
> too. And then the invalid-entry-add should be a separate patch.

The 0 return (originally) was to indicate that an e820 entry for the
range wasn't found. This series just gave it a name.  So it's not that
the type field held a 0.  Since 0 isn't defined in the ACPI spec I don't
see an issue with creating it and I can add a comment to the effect that
this value is used for the type when an e820 entry isn't found. I could
always rename it to E820_TYPE_NOT_FOUND if that would help.

Or if we want to guard against ACPI adding a type 0 in the future, I
could make the function return an int and then return -EINVAL if an e820
entry isn't found.  This might be the better option.

Thanks,
Tom


>
>>  	E820_TYPE_RAM		= 1,
>>  	E820_TYPE_RESERVED	= 2,
>>  	E820_TYPE_ACPI		= 3,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
