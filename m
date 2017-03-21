Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFFCF6B0038
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 16:07:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c87so269630773pfl.6
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:07:45 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0096.outbound.protection.outlook.com. [104.47.0.96])
        by mx.google.com with ESMTPS id z17si22376745pgi.387.2017.03.21.13.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 13:07:44 -0700 (PDT)
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
 <CALCETrWvYERYaNscyQ3Q9rBUvVdzm1do86mMccnZzHsTMEn1HQ@mail.gmail.com>
 <3ff42889-4ba3-15e5-0e77-b3bd1db7619f@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <63abd72b-11fd-0249-0a6f-83d4d2aa8bb3@virtuozzo.com>
Date: Tue, 21 Mar 2017 23:04:00 +0300
MIME-Version: 1.0
In-Reply-To: <3ff42889-4ba3-15e5-0e77-b3bd1db7619f@virtuozzo.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 10:42 PM, Dmitry Safonov wrote:
> On 03/21/2017 10:31 PM, Andy Lutomirski wrote:
>> On Tue, Mar 21, 2017 at 11:09 AM, Dmitry Safonov
>> <dsafonov@virtuozzo.com> wrote:
>>> On 03/21/2017 08:45 PM, Andy Lutomirski wrote:
>>>>
>>>> On Tue, Mar 21, 2017 at 10:17 AM, Cyrill Gorcunov <gorcunov@gmail.com>
>>>> wrote:
>>>>>
>>>>> On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
>>>>> ...
>>>>>>
>>>>>> diff --git a/arch/x86/kernel/process_64.c
>>>>>> b/arch/x86/kernel/process_64.c
>>>>>> index d6b784a5520d..d3d4d9abcaf8 100644
>>>>>> --- a/arch/x86/kernel/process_64.c
>>>>>> +++ b/arch/x86/kernel/process_64.c
>>>>>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>>>>>>               if (current->mm)
>>>>>>                       current->mm->context.ia32_compat = TIF_X32;
>>>>>>               current->personality &= ~READ_IMPLIES_EXEC;
>>>>>> -             /* in_compat_syscall() uses the presence of the x32
>>>>>> -                syscall bit flag to determine compat status */
>>>>>> +             /*
>>>>>> +              * in_compat_syscall() uses the presence of the x32
>>>>>> +              * syscall bit flag to determine compat status.
>>>>>> +              * On the bitness of syscall relies x86 mmap() code,
>>>>>> +              * so set x32 syscall bit right here to make
>>>>>> +              * in_compat_syscall() work during exec().
>>>>>> +              */
>>>>>> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>>>>>>               current->thread.status &= ~TS_COMPAT;
>>>>>
>>>>>
>>>>> Hi! I must admit I didn't follow close the overall series (so can't
>>>>> comment much here :) but I have a slightly unrelated question -- is
>>>>> there a way to figure out if task is running in x32 mode say with
>>>>> some ptrace or procfs sign?
>>>>
>>>>
>>>> You should be able to figure out of a *syscall* is x32 by simply
>>>> looking at bit 30 in the syscall number.  (This is unlike i386, which
>>>> is currently not reflected in ptrace.)
>>>
>>>
>>> The process could be stopped with PTRACE_SEIZE and I think, it'll not
>>> have x32 syscall bit at that moment.
>>>
>>> I guess the question comes from that we're releasing CRIU 3.0 with
>>> 32-bit C/R and some other cool stuff, but we don't support x32 yet.
>>> As we don't want release a thing that we aren't properly testing.
>>> So for a while we should error on dumping x32 applications.
>>
>> I'm curious: shouldn't x32 CRIU just work?  What goes wrong?
>
> I also think, it should be quite easy to add, as we have arch_prctl()
> for vdso and etc.
> But there are things, which will not work if we just dump application
> as 64-bit.
>
> For example, what comes to mind: sys_get_robust_list(), it has different
> pointers for 64-bit or for x32/ia32 applications: robust_list
> and compat_robust_list. So during C/R we should sometimes call
> compatible syscalls for x32 applications to dump/restore, as for futex
> list e.g., native will return NULL or empty list.

Maybe we should just save both pointers with CRIU for simplicity.
Which will add additional syscall for most applications that define only
one of compat/native lists.

I think, there are some other things like that, but it's end of the day
and nothing crosses my mind.

Anyway, I wouldn't want release anything without adding it to regular
tests, so that would need also some time to do. And a funny thing: there
are many folks which runs 32-bit containers on x86_64 to save memory,
but they use ia32, not x32. Maybe because of envoironment which is
easier to get (for x32 there are no templates for example). Maybe just
because.

So, yet I haven't saw any request for x32 C/R while for ia32 there is
crowded room. And quite many people for arm/arm64 where kernel doesn't
support yet vdso mremap() and CRIU doesn't run test for them regulary
yet.

But well, x32 still should be quite easy to add, say, for the next
release after ia32 C/R not sure if it'll be planned though.


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
