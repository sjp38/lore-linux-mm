Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id B066F6B0333
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 19:55:15 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id n73so30317111vke.6
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 16:55:15 -0700 (PDT)
Received: from mail-vk0-x235.google.com (mail-vk0-x235.google.com. [2607:f8b0:400c:c05::235])
        by mx.google.com with ESMTPS id p11si2848786vkd.242.2017.03.21.16.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 16:55:14 -0700 (PDT)
Received: by mail-vk0-x235.google.com with SMTP id j64so96528721vkg.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 16:55:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321180525.GC21564@uranus.lan>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com>
 <20170321171723.GB21564@uranus.lan> <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
 <20170321180525.GC21564@uranus.lan>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 21 Mar 2017 16:54:52 -0700
Message-ID: <CALCETrXTSBZEWkyiu3ZTbFnT69nT5K5dC9SFtHft-Q+rdJ2FiQ@mail.gmail.com>
Subject: Re: [Q] Figuring out task mode
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Mar 21, 2017 at 11:05 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> /I renamed the mail's subject/
>
> On Tue, Mar 21, 2017 at 10:45:57AM -0700, Andy Lutomirski wrote:
>> >> +             task_pt_regs(current)->orig_ax |= __X32_SYSCALL_BIT;
>> >>               current->thread.status &= ~TS_COMPAT;
>> >
>> > Hi! I must admit I didn't follow close the overall series (so can't
>> > comment much here :) but I have a slightly unrelated question -- is
>> > there a way to figure out if task is running in x32 mode say with
>> > some ptrace or procfs sign?
>>
>> You should be able to figure out of a *syscall* is x32 by simply
>> looking at bit 30 in the syscall number.  (This is unlike i386, which
>> is currently not reflected in ptrace.)
>
> Yes, syscall number will help but from criu perpspective (until
> Dima's patches are merged into mainlie) we need to figure out
> if we can dump x32 tasks without running parasite code inside,
> ie via plain ptrace call or some procfs output. But looks like
> it's impossible for now.
>
>> Do we actually have an x32 per-task mode at all?  If so, maybe we can
>> just remove it on top of Dmitry's series.
>
> Don't think so, x32 should be set upon exec and without Dima's series
> it is immutable I think.

What I mean is: why should the kernel care about per-task X32 state
*at all*?  On top of Dmitry's series, TIF_X32 appears to be used to
determine which vDSO to map, which mm layout to use, *and nothing
else*.  Want to write a trivial patch to get rid of it entirely?

Ideally we could get rid of mm->context.ia32_compat, too.  The only
interesting use it has is MPX, and we should probably instead track
mm->context.mpx_layout and determine *that* from the prctl() bitness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
