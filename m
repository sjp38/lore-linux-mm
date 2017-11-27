Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05B9C6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:37:22 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id a67so17193123vkf.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 10:37:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 19sor9597897uae.264.2017.11.27.10.37.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 10:37:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <07d101b3-d17a-7781-f05e-96738e6d6848@linux.intel.com>
References: <20171126231403.657575796@linutronix.de> <20171126232414.313869499@linutronix.de>
 <07d101b3-d17a-7781-f05e-96738e6d6848@linux.intel.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 27 Nov 2017 10:37:19 -0800
Message-ID: <CAGXu5jKyx1T+NZGgPUUPt_-MqZe3-zrpFbAVFzsWbW=aD-D6_Q@mail.gmail.com>
Subject: Re: [patch V2 1/5] x86/kaiser: Respect disabled CPU features
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 10:11 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>> --- a/arch/x86/include/asm/pgtable_64.h
>> +++ b/arch/x86/include/asm/pgtable_64.h
>> @@ -222,7 +222,8 @@ static inline pgd_t kaiser_set_shadow_pg
>>                        * wrong CR3 value, userspace will crash
>>                        * instead of running.
>>                        */
>> -                     pgd.pgd |= _PAGE_NX;
>> +                     if (__supported_pte_mask & _PAGE_NX)
>> +                             pgd.pgd |= _PAGE_NX;
>>               }
>
> Thanks for catching that.  It's definitely a bug.  Although,
> practically, it's hard to hit, right?  I think everything 64-bit
> supports NX unless the hypervisor disabled it or something.

There was a very narrow window where x86_64 machines were made without
NX. :( This is reflected in x86_report_nx(), though maybe we should
add a "OMG, why?" when 64-bit but no NX. ;)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
