Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDBAF6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:30:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r126so50951345oib.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:30:09 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0084.outbound.protection.outlook.com. [104.47.38.84])
        by mx.google.com with ESMTPS id 81si1617217ote.43.2016.09.14.07.29.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 07:29:49 -0700 (PDT)
Subject: Re: [RFC PATCH v2 19/20] x86: Access the setup data through debugfs
 un-encrypted
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223859.29880.60652.stgit@tlendack-t1.amdoffice.net>
 <20160912165944.rpqbwxz2biathnt3@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4a357b9b-7d53-5bd6-81db-9d8cc63a6c72@amd.com>
Date: Wed, 14 Sep 2016 09:29:41 -0500
MIME-Version: 1.0
In-Reply-To: <20160912165944.rpqbwxz2biathnt3@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 11:59 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:59PM -0500, Tom Lendacky wrote:
>> Since the setup data is in memory in the clear, it must be accessed as
>> un-encrypted.  Always use ioremap (similar to sysfs setup data support)
>> to map the data.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/kdebugfs.c |   30 +++++++++++-------------------
>>  1 file changed, 11 insertions(+), 19 deletions(-)
>>
>> diff --git a/arch/x86/kernel/kdebugfs.c b/arch/x86/kernel/kdebugfs.c
>> index bdb83e4..a58a82e 100644
>> --- a/arch/x86/kernel/kdebugfs.c
>> +++ b/arch/x86/kernel/kdebugfs.c
>> @@ -48,17 +48,13 @@ static ssize_t setup_data_read(struct file *file, char __user *user_buf,
>>  
>>  	pa = node->paddr + sizeof(struct setup_data) + pos;
>>  	pg = pfn_to_page((pa + count - 1) >> PAGE_SHIFT);
>> -	if (PageHighMem(pg)) {
> 
> Why is it ok to get rid of the PageHighMem() check?

Since the change is to perform the ioremap call no matter what the check
for PageHighMem() wasn't needed anymore.

> 
> Btw, we did talk earlier in the thread about making __va() clear the SME
> mask and then you won't really need to change stuff here. Or?

This is still required because just using the __va() would still cause
the mapping created to have the encryption bit set. The ioremap call
will result in the mapping not having the encryption bit set.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
