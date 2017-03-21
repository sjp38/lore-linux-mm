Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE8FB6B03A4
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:32:13 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x75so51126615vke.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:32:13 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id k130si7509310vke.64.2017.03.21.12.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 12:32:12 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id x75so105320796vke.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 12:32:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan> <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 21 Mar 2017 12:31:51 -0700
Message-ID: <CALCETrWvYERYaNscyQ3Q9rBUvVdzm1do86mMccnZzHsTMEn1HQ@mail.gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 11:09 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> On 03/21/2017 08:45 PM, Andy Lutomirski wrote:
>>
>> On Tue, Mar 21, 2017 at 10:17 AM, Cyrill Gorcunov <gorcunov@gmail.com>
>> wrote:
>>>
>>> On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
>>> ...
>>>>
>>>> diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
>>>> index d6b784a5520d..d3d4d9abcaf8 100644
>>>> --- a/arch/x86/kernel/process_64.c
>>>> +++ b/arch/x86/kernel/process_64.c
>>>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>>>>               if (current->mm)
>>>>                       current->mm->context.ia32_compat = TIF_X32;
>>>>               current->personality &= ~READ_IMPLIES_EXEC;
>>>> -             /* in_compat_syscall() uses the presence of the x32
>>>> -                syscall bit flag to determine compat status */
>>>> +             /*
>>>> +              * in_compat_syscall() uses the presence of the x32
>>>> +              * syscall bit flag to determine compat status.
>>>> +              * On the bitness of syscall relies x86 mmap() code,
>>>> +              * so set x32 syscall bit right here to make
>>>> +              * in_compat_syscall() work during exec().
>>>> +              */
>>>> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>>>>               current->thread.status &= ~TS_COMPAT;
>>>
>>>
>>> Hi! I must admit I didn't follow close the overall series (so can't
>>> comment much here :) but I have a slightly unrelated question -- is
>>> there a way to figure out if task is running in x32 mode say with
>>> some ptrace or procfs sign?
>>
>>
>> You should be able to figure out of a *syscall* is x32 by simply
>> looking at bit 30 in the syscall number.  (This is unlike i386, which
>> is currently not reflected in ptrace.)
>
>
> The process could be stopped with PTRACE_SEIZE and I think, it'll not
> have x32 syscall bit at that moment.
>
> I guess the question comes from that we're releasing CRIU 3.0 with
> 32-bit C/R and some other cool stuff, but we don't support x32 yet.
> As we don't want release a thing that we aren't properly testing.
> So for a while we should error on dumping x32 applications.

I'm curious: shouldn't x32 CRIU just work?  What goes wrong?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
