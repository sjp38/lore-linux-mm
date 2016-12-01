Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7D186B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:16:22 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so334634452pfy.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 19:16:22 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id 31si38515968pli.203.2016.11.30.19.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 19:16:21 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
	<1480445729-27130-8-git-send-email-labbott@redhat.com>
	<20161201024103.GA32438@dhcp-128-65.nay.redhat.com>
Date: Wed, 30 Nov 2016 21:13:24 -0600
In-Reply-To: <20161201024103.GA32438@dhcp-128-65.nay.redhat.com> (Dave Young's
	message of "Thu, 1 Dec 2016 10:41:03 +0800")
Message-ID: <87polc7357.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCHv4 07/10] kexec: Switch to __pa_symbol
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

Dave Young <dyoung@redhat.com> writes:

> Hi, Laura
> On 11/29/16 at 10:55am, Laura Abbott wrote:
>> 
>> __pa_symbol is the correct api to get the physical address of kernel
>> symbols. Switch to it to allow for better debug checking.
>> 
>
> I assume __pa_symbol is faster than __pa, but it still need some testing
> on all arches which support kexec.
>
> But seems long long ago there is a commit e3ebadd95cb in the commit log
> I see below from:
> "we should deprecate __pa_symbol(), and preferably __pa() too - and
>  just use "virt_to_phys()" instead, which is is more readable and has
>  nicer semantics."
>
> But maybe in modern code __pa_symbol is prefered I may miss background.
> virt_to_phys still sounds more readable now for me though.

There has been a lot of history with the various definitions.
__pa_symbol used to be x86 specific.

Now what we have is that __pa_symbol is just __pa(RELOC_HIDE(x));

Now arguably that whole reloc hide thing should happen by architectures
having a non-inline version of __pa as was done in the commit you
mention.  But at this point there appears to be nothing wrong with
changing a __pa to a __pa_symbol it might make things a tad more
reliable depending on the implementation of __pa.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


Eric

>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>> Found during review of the kernel. Untested.
>> ---
>>  kernel/kexec_core.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
>> index 5616755..e1b625e 100644
>> --- a/kernel/kexec_core.c
>> +++ b/kernel/kexec_core.c
>> @@ -1397,7 +1397,7 @@ void __weak arch_crash_save_vmcoreinfo(void)
>>  
>>  phys_addr_t __weak paddr_vmcoreinfo_note(void)
>>  {
>> -	return __pa((unsigned long)(char *)&vmcoreinfo_note);
>> +	return __pa_symbol((unsigned long)(char *)&vmcoreinfo_note);
>>  }
>>  
>>  static int __init crash_save_vmcoreinfo_init(void)
>> -- 
>> 2.7.4
>> 
>> 
>> _______________________________________________
>> kexec mailing list
>> kexec@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/kexec
>
> Thanks
> Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
