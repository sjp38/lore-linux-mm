Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 860376B0394
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:13:24 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id y136so69024774iof.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:13:24 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50133.outbound.protection.outlook.com. [40.107.5.133])
        by mx.google.com with ESMTPS id w10si14864921itf.37.2017.03.21.11.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 11:13:23 -0700 (PDT)
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan>
 <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <6648805c-e0d8-5e27-9e19-602ab47937a7@virtuozzo.com>
Date: Tue, 21 Mar 2017 21:09:40 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21/2017 08:45 PM, Andy Lutomirski wrote:
> On Tue, Mar 21, 2017 at 10:17 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
>> ...
>>> diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
>>> index d6b784a5520d..d3d4d9abcaf8 100644
>>> --- a/arch/x86/kernel/process_64.c
>>> +++ b/arch/x86/kernel/process_64.c
>>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>>>               if (current->mm)
>>>                       current->mm->context.ia32_compat = TIF_X32;
>>>               current->personality &= ~READ_IMPLIES_EXEC;
>>> -             /* in_compat_syscall() uses the presence of the x32
>>> -                syscall bit flag to determine compat status */
>>> +             /*
>>> +              * in_compat_syscall() uses the presence of the x32
>>> +              * syscall bit flag to determine compat status.
>>> +              * On the bitness of syscall relies x86 mmap() code,
>>> +              * so set x32 syscall bit right here to make
>>> +              * in_compat_syscall() work during exec().
>>> +              */
>>> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>>>               current->thread.status &= ~TS_COMPAT;
>>
>> Hi! I must admit I didn't follow close the overall series (so can't
>> comment much here :) but I have a slightly unrelated question -- is
>> there a way to figure out if task is running in x32 mode say with
>> some ptrace or procfs sign?
>
> You should be able to figure out of a *syscall* is x32 by simply
> looking at bit 30 in the syscall number.  (This is unlike i386, which
> is currently not reflected in ptrace.)

The process could be stopped with PTRACE_SEIZE and I think, it'll not
have x32 syscall bit at that moment.

I guess the question comes from that we're releasing CRIU 3.0 with
32-bit C/R and some other cool stuff, but we don't support x32 yet.
As we don't want release a thing that we aren't properly testing.
So for a while we should error on dumping x32 applications.

I think, the best way for now is to check physicall address of vdso
from /proc/.../pagemap. If it's CONFIG_VDSO=n kernel, I guess we could
also add check for %ds from ptrace's register set. For x32 it's set to
__USER_DS, while for native it's 0 (looking at start_thread() and
compat_start_thread()). The application can simply change it without
any consequence - so it's not very reliable, we could only warn at
catching it, not rely on this.

>
> Do we actually have an x32 per-task mode at all?  If so, maybe we can
> just remove it on top of Dmitry's series.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
