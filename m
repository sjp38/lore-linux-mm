Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C47C6B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:07:06 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b13so5775951pgn.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:07:06 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0044.outbound.protection.outlook.com. [104.47.42.44])
        by mx.google.com with ESMTPS id q76si340859pfi.254.2017.06.14.10.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 10:07:05 -0700 (PDT)
Subject: Re: [PATCH v6 20/34] x86, mpparse: Use memremap to map the mpf and
 mpc data
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191643.28645.91679.stgit@tlendack-t1.amdoffice.net>
 <20170614160754.c4ywbf5ktqwgc4ij@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <86f31710-76d0-5fee-f4a7-8cdb4b9b9a8e@amd.com>
Date: Wed, 14 Jun 2017 12:06:54 -0500
MIME-Version: 1.0
In-Reply-To: <20170614160754.c4ywbf5ktqwgc4ij@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/14/2017 11:07 AM, Borislav Petkov wrote:
> On Wed, Jun 07, 2017 at 02:16:43PM -0500, Tom Lendacky wrote:
>> The SMP MP-table is built by UEFI and placed in memory in a decrypted
>> state. These tables are accessed using a mix of early_memremap(),
>> early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
>> to use early_memremap()/early_memunmap(). This allows for proper setting
>> of the encryption mask so that the data can be successfully accessed when
>> SME is active.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/kernel/mpparse.c |   98 ++++++++++++++++++++++++++++++++-------------
>>   1 file changed, 70 insertions(+), 28 deletions(-)
> 
> ...
> 
>> @@ -515,6 +516,12 @@ void __init default_get_smp_config(unsigned int early)
>>   	if (acpi_lapic && acpi_ioapic)
>>   		return;
>>   
>> +	mpf = early_memremap(mpf_base, sizeof(*mpf));
>> +	if (!mpf) {
>> +		pr_err("MPTABLE: mpf early_memremap() failed\n");
> 
> If you're going to introduce new prefixes then add:

This isn't new...  there are a number of messages issued in this file
with that prefix, so I was just following convention.  Changing the
prefix could be a follow-on patch.

> 
> #undef pr_fmt
> #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> 
> at the beginning of the file so that they all say "mpparse:" instead.
> 
> And pls make that message more user-friendly: "Error mapping MP table"
> or so.

Can do.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
