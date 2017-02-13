Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81F5C6B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:16:41 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d13so133346546oib.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 03:16:41 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0124.outbound.protection.outlook.com. [104.47.2.124])
        by mx.google.com with ESMTPS id p192si3279106itb.96.2017.02.13.03.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 03:16:40 -0800 (PST)
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native
 versions
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
 <20170130120432.6716-2-dsafonov@virtuozzo.com>
 <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
 <alpine.DEB.2.20.1702102057330.4042@nanos>
 <CAJwJo6b5oSbcDjE+L=wwS_cdYnimAR+mD5BTyuHQtb8zUQX4fA@mail.gmail.com>
 <alpine.DEB.2.20.1702110919370.3734@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <3a275384-0c4a-5334-f31b-5fadda9d8ee9@virtuozzo.com>
Date: Mon, 13 Feb 2017 14:12:55 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1702110919370.3734@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, open list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, linux-mm@kvack.org

On 02/11/2017 11:23 AM, Thomas Gleixner wrote:
> On Sat, 11 Feb 2017, Dmitry Safonov wrote:
>
>> 2017-02-10 23:10 GMT+03:00 Thomas Gleixner <tglx@linutronix.de>:
>>> On Thu, 9 Feb 2017, Borislav Petkov wrote:
>>>> I can't say that I'm thrilled about the ifdeffery this is adding.
>>>>
>>>> But I can't think of a cleaner approach at a quick glance, though -
>>>> that's generic and arch-specific code intertwined muck. Sad face.
>>>
>>> It's trivial enough to do ....
>>>
>>> Thanks,
>>>
>>>         tglx
>>>
>>> ---
>>>  arch/x86/mm/mmap.c |   22 ++++++++++------------
>>>  1 file changed, 10 insertions(+), 12 deletions(-)
>>>
>>> --- a/arch/x86/mm/mmap.c
>>> +++ b/arch/x86/mm/mmap.c
>>> @@ -55,6 +55,10 @@ static unsigned long stack_maxrandom_siz
>>>  #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
>>>  #define MAX_GAP (TASK_SIZE/6*5)
>>>
>>> +#ifndef CONFIG_COMPAT
>>> +# define mmap_rnd_compat_bits  mmap_rnd_bits
>>> +#endif
>>> +
>>
>> >From my POV, I can't say that it's clearer to shadow mmap_compat_bits
>> like that then to have two functions with native/compat names.
>> But if you insist, I'll resend patches set with your version.
>
> You can make that
>
> #ifdef CONFIG_64BIT
> # define mmap32_rnd_bits  mmap_compat_rnd_bits
> # define mmap64_rnd_bits  mmap_rnd_bits
> #else
> # define mmap32_rnd_bits  mmap_rnd_bits
> # define mmap64_rnd_bits  mmap_rnd_bits
> #endif
>
> and use that. That's still way more readable than the unholy ifdef mess.

Ok, will send this version in v5.
Ping me if you mind me using your SOB for this patch.

>
> Thanks,
>
> 	tglx
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
