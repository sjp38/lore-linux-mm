Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 550DA6B0292
	for <linux-mm@kvack.org>; Tue, 30 May 2017 11:46:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e131so100807473pfh.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 08:46:35 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0084.outbound.protection.outlook.com. [104.47.36.84])
        by mx.google.com with ESMTPS id p23si44782887pli.56.2017.05.30.08.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 08:46:34 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
 <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <097e89ec-45a4-3a54-d005-9e7dc436436e@amd.com>
Date: Tue, 30 May 2017 10:46:22 -0500
MIME-Version: 1.0
In-Reply-To: <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/19/2017 6:30 AM, Borislav Petkov wrote:
> On Fri, Apr 21, 2017 at 01:56:13PM -0500, Tom Lendacky wrote:
>> On 4/18/2017 4:22 PM, Tom Lendacky wrote:
>>> Add support to check if SME has been enabled and if memory encryption
>>> should be activated (checking of command line option based on the
>>> configuration of the default state).  If memory encryption is to be
>>> activated, then the encryption mask is set and the kernel is encrypted
>>> "in place."
>>>
>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>> ---
>>>   arch/x86/kernel/head_64.S |    1 +
>>>   arch/x86/mm/mem_encrypt.c |   83 +++++++++++++++++++++++++++++++++++++++++++--
>>>   2 files changed, 80 insertions(+), 4 deletions(-)
>>>
>>
>> ...
>>
>>>
>>> -unsigned long __init sme_enable(void)
>>> +unsigned long __init sme_enable(struct boot_params *bp)
>>>   {
>>> +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
>>> +	unsigned int eax, ebx, ecx, edx;
>>> +	unsigned long me_mask;
>>> +	bool active_by_default;
>>> +	char buffer[16];
>>
>> So it turns out that when KASLR is enabled (CONFIG_RAMDOMIZE_BASE=y)
>> the stack-protector support causes issues with this function because
> 
> What issues?

The stack protection support makes use of the gs segment register and
at this point not everything is setup properly to allow it to work,
so it segfaults.

Thanks,
Tom

> 
>> it is called so early. I can get past it by adding:
>>
>> CFLAGS_mem_encrypt.o := $(nostackp)
>>
>> in the arch/x86/mm/Makefile, but that obviously eliminates the support
>> for the whole file.  Would it be better to split out the sme_enable()
>> and other boot routines into a separate file or just apply the
>> $(nostackp) to the whole file?
> 
> Josh might have a better idea here... CCed.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
