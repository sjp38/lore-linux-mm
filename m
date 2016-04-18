Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA35A6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 07:19:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so232553886pab.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 04:19:56 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0119.outbound.protection.outlook.com. [157.56.112.119])
        by mx.google.com with ESMTPS id m86si1798137pfj.88.2016.04.18.04.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 04:19:55 -0700 (PDT)
Subject: Re: [PATCHv4 1/2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460729545-5666-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrXQHuSKejXtsGnpm455Z39TVn6jsaUd_T_F=b3Rtmki5Q@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5714C299.5060307@virtuozzo.com>
Date: Mon, 18 Apr 2016 14:18:49 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrXQHuSKejXtsGnpm455Z39TVn6jsaUd_T_F=b3Rtmki5Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 04/15/2016 07:58 PM, Andy Lutomirski wrote:
> A couple minor things:
>
>   - You're looking at both new_vma->vm_mm and current->mm.  Is there a
> reason for that?  If they're different, I'd be quite surprised, but
> maybe it would make sense to check.

Ok, will add a check.

>   - On second thought, the is_ia32_task() check is a little weird given
> that you're planning on making the vdso image type.  It might make
> sense to change that to in_ia32_syscall() && image == &vdso_image_32.

Yes, we might be there remapping vdso_image_64 through int80, where
we shouldn't change landing. Thanks, will add a check.

> Other than that, looks good to me.
>
> You could add a really simple test case to selftests/x86:
>
> mremap(the vdso, somewhere else);
> asm volatile ("int $0x80" : : "a" (__NR_exit), "b" (0));
>
> That'll segfault if this fails and it'll work and return 0 if it works.

Will add - for now I have tested this with kind the same program.

> FWIW, there's one respect in which this code could be problematic down
> the road: if syscalls ever start needing the vvar page, then this gets
> awkward because you can't remap both at once.  Also, this is
> fundamentally racy if multiple threads try to use it (but there's
> nothing whatsoever the kernel could do about that).  In general, once
> the call to change and relocate the vdso gets written, CRIU should
> probably prefer to use it over mremap.

Yes, but from my point of view, for the other reasons:
- on restore stage of CRIU, restorer maps VMAs that were dumped
on dump stage.
- this is done in one thread, as other threads may need those VMAs
to funciton.
- one of vmas, being restored is vDSO (which also was dumped), so
there is image for this blob.

So, ideally, I even would not need such API to remap blobs
from 64 to 32 (or backwards). This is ideally for other applications
that switches their mode. For CRIU *ideally* I do not need it, as
I have this vma's image dumped before - I only need remap to
fix contex.vdso pointer for proper landing and I'm doing it in
one thread.

But, in the practice, one may migrate application from one
kernel to another. And for different kernel versions, there may
be different vDSO entries. For now (before compatible C/R)
we have checked if vDSO differ and if so, examine this different
vDSO symbols and add jump trampolines on places where
were entries in previous vDSO to a new one.
So, this is also true for 32-bit vDSO blob. That's why I need
this API for CRIU.

-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
