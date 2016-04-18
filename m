Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 022A86B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:37:28 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id b8so167558583igv.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:37:27 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id e10si16216542oih.69.2016.04.18.08.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 08:37:26 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id r78so52487960oie.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 08:37:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5714C299.5060307@virtuozzo.com>
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460729545-5666-1-git-send-email-dsafonov@virtuozzo.com> <CALCETrXQHuSKejXtsGnpm455Z39TVn6jsaUd_T_F=b3Rtmki5Q@mail.gmail.com>
 <5714C299.5060307@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 18 Apr 2016 08:37:06 -0700
Message-ID: <CALCETrXYWBqeyeX5ZZBhsNGhdEY6FNWmVM85NWJm8VOnEOFuLw@mail.gmail.com>
Subject: Re: [PATCHv4 1/2] x86/vdso: add mremap hook to vm_special_mapping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On Apr 18, 2016 4:19 AM, "Dmitry Safonov" <dsafonov@virtuozzo.com> wrote:
>
> On 04/15/2016 07:58 PM, Andy Lutomirski wrote:
>>
>> A couple minor things:
>>
>>   - You're looking at both new_vma->vm_mm and current->mm.  Is there a
>> reason for that?  If they're different, I'd be quite surprised, but
>> maybe it would make sense to check.
>
>
> Ok, will add a check.
>
>
>>   - On second thought, the is_ia32_task() check is a little weird given
>> that you're planning on making the vdso image type.  It might make
>> sense to change that to in_ia32_syscall() && image == &vdso_image_32.
>
>
> Yes, we might be there remapping vdso_image_64 through int80, where
> we shouldn't change landing. Thanks, will add a check.
>
>
>> Other than that, looks good to me.
>>
>> You could add a really simple test case to selftests/x86:
>>
>> mremap(the vdso, somewhere else);
>> asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (0));
>>
>> That'll segfault if this fails and it'll work and return 0 if it works.
>
>
> Will add - for now I have tested this with kind the same program.
>
>
>> FWIW, there's one respect in which this code could be problematic down
>> the road: if syscalls ever start needing the vvar page, then this gets
>> awkward because you can't remap both at once.  Also, this is
>> fundamentally racy if multiple threads try to use it (but there's
>> nothing whatsoever the kernel could do about that).  In general, once
>> the call to change and relocate the vdso gets written, CRIU should
>> probably prefer to use it over mremap.
>
>
> Yes, but from my point of view, for the other reasons:
> - on restore stage of CRIU, restorer maps VMAs that were dumped
> on dump stage.
> - this is done in one thread, as other threads may need those VMAs
> to funciton.
> - one of vmas, being restored is vDSO (which also was dumped), so
> there is image for this blob.
>
> So, ideally, I even would not need such API to remap blobs
> from 64 to 32 (or backwards).

If I'm understanding you right, this won't work reliably.  The kernel
makes no promise that one kernel's vdso is compatible with another
kernel.  In fact, the internal interfaces have changed several times
and are changing again in 4.6.

You also need to put vvar at the correct offset from the text, and
vvar can't be dumped and restores at all, since the whole point is
that it changes at runtime.

> This is ideally for other applications
> that switches their mode. For CRIU *ideally* I do not need it, as
> I have this vma's image dumped before - I only need remap to
> fix contex.vdso pointer for proper landing and I'm doing it in
> one thread.
>
> But, in the practice, one may migrate application from one
> kernel to another. And for different kernel versions, there may
> be different vDSO entries. For now (before compatible C/R)
> we have checked if vDSO differ and if so, examine this different
> vDSO symbols and add jump trampolines on places where
> were entries in previous vDSO to a new one.
> So, this is also true for 32-bit vDSO blob. That's why I need
> this API for CRIU.

Understood.

I like the mremap support regardless of whether CRIU ends up using it long-term.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
