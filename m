Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E48ED6B037E
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:46:19 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r69so16548358vke.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:46:19 -0700 (PDT)
Received: from mail-vk0-x22e.google.com (mail-vk0-x22e.google.com. [2607:f8b0:400c:c05::22e])
        by mx.google.com with ESMTPS id a4si951401vkh.76.2017.03.21.10.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 10:46:18 -0700 (PDT)
Received: by mail-vk0-x22e.google.com with SMTP id j64so87763849vkg.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:46:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321171723.GB21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com> <20170321171723.GB21564@uranus.lan>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 21 Mar 2017 10:45:57 -0700
Message-ID: <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 10:17 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
> ...
>> diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
>> index d6b784a5520d..d3d4d9abcaf8 100644
>> --- a/arch/x86/kernel/process_64.c
>> +++ b/arch/x86/kernel/process_64.c
>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>>               if (current->mm)
>>                       current->mm->context.ia32_compat = TIF_X32;
>>               current->personality &= ~READ_IMPLIES_EXEC;
>> -             /* in_compat_syscall() uses the presence of the x32
>> -                syscall bit flag to determine compat status */
>> +             /*
>> +              * in_compat_syscall() uses the presence of the x32
>> +              * syscall bit flag to determine compat status.
>> +              * On the bitness of syscall relies x86 mmap() code,
>> +              * so set x32 syscall bit right here to make
>> +              * in_compat_syscall() work during exec().
>> +              */
>> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>>               current->thread.status &= ~TS_COMPAT;
>
> Hi! I must admit I didn't follow close the overall series (so can't
> comment much here :) but I have a slightly unrelated question -- is
> there a way to figure out if task is running in x32 mode say with
> some ptrace or procfs sign?

You should be able to figure out of a *syscall* is x32 by simply
looking at bit 30 in the syscall number.  (This is unlike i386, which
is currently not reflected in ptrace.)

Do we actually have an x32 per-task mode at all?  If so, maybe we can
just remove it on top of Dmitry's series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
