Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8F96B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 18:06:44 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id a88so11548188uaa.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 15:06:44 -0800 (PST)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id n133si3844126vka.51.2017.02.09.15.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 15:06:43 -0800 (PST)
Received: by mail-ua0-x235.google.com with SMTP id 96so15296071uaq.3
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 15:06:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-2-dsafonov@virtuozzo.com>
 <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 9 Feb 2017 15:06:22 -0800
Message-ID: <CALCETrVUXCsNsvy_xTzok9Jd6tpNtOTiyDsz9MWgYTo1V1LMtw@mail.gmail.com>
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native versions
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Feb 9, 2017 at 5:55 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Jan 30, 2017 at 03:04:28PM +0300, Dmitry Safonov wrote:
>> I need those arch_{native,compat}_rnd() to compute separately
>> random factor for mmap() in compat syscalls for 64-bit binaries
>> and vice-versa for native syscall in 32-bit compat binaries.
>> They will be used in the following patches.
>>
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>>  arch/x86/mm/mmap.c | 25 ++++++++++++++++---------
>>  1 file changed, 16 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
>> index d2dc0438d654..42063e787717 100644
>> --- a/arch/x86/mm/mmap.c
>> +++ b/arch/x86/mm/mmap.c
>> @@ -65,20 +65,27 @@ static int mmap_is_legacy(void)
>>       return sysctl_legacy_va_layout;
>>  }
>>
>> -unsigned long arch_mmap_rnd(void)
>> +#ifdef CONFIG_COMPAT
>> +static unsigned long arch_compat_rnd(void)
>>  {
>> -     unsigned long rnd;
>> +     return (get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1))
>> +             << PAGE_SHIFT;
>> +}
>> +#endif
>>
>> -     if (mmap_is_ia32())
>> +static unsigned long arch_native_rnd(void)
>> +{
>> +     return (get_random_long() & ((1UL << mmap_rnd_bits) - 1)) << PAGE_SHIFT;
>> +}
>> +
>> +unsigned long arch_mmap_rnd(void)
>> +{
>>  #ifdef CONFIG_COMPAT
>> -             rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
>> -#else
>> -             rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
>> +     if (mmap_is_ia32())
>> +             return arch_compat_rnd();
>>  #endif
>
> I can't say that I'm thrilled about the ifdeffery this is adding.
>
> But I can't think of a cleaner approach at a quick glance, though -
> that's generic and arch-specific code intertwined muck. Sad face.

I can, but it could be considerably more churn: get rid of the
compat/native split and do a 32-bit/64-bit split instead.

>
> --
> Regards/Gruss,
>     Boris.
>
> Good mailing practices for 400: avoid top-posting and trim the reply.



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
