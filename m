Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B28C06B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 14:10:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so61374336wma.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:10:21 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id v129si4729641wme.91.2016.07.14.11.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 11:10:19 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id o80so123410451wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:10:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160714054842.6zal5rqawpgew26r@treble>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-2-git-send-email-keescook@chromium.org> <CALCETrVDJDjdoh7yvOPd=_5twQnzQRhe8G2KLaRw-NnA1Uf__g@mail.gmail.com>
 <CAGXu5jLPZiRJx8n3_7GW2bufiuUgE9=c6dQcNxDRPHMU72sD9g@mail.gmail.com> <20160714054842.6zal5rqawpgew26r@treble>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 14 Jul 2016 11:10:18 -0700
Message-ID: <CAGXu5jLv_pMRqdaM72D_FTQzxoGxgcEqxpvUzqwgjOmZ8D-zSw@mail.gmail.com>
Subject: Re: [PATCH v2 01/11] mm: Implement stack frame object validation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, X86 ML <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Jul 13, 2016 at 10:48 PM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> On Wed, Jul 13, 2016 at 03:04:26PM -0700, Kees Cook wrote:
>> On Wed, Jul 13, 2016 at 3:01 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> > On Wed, Jul 13, 2016 at 2:55 PM, Kees Cook <keescook@chromium.org> wrote:
>> >> This creates per-architecture function arch_within_stack_frames() that
>> >> should validate if a given object is contained by a kernel stack frame.
>> >> Initial implementation is on x86.
>> >>
>> >> This is based on code from PaX.
>> >>
>> >
>> > This, along with Josh's livepatch work, are two examples of unwinders
>> > that matter for correctness instead of just debugging.  ISTM this
>> > should just use Josh's code directly once it's been written.
>>
>> Do you have URL for Josh's code? I'd love to see what happening there.
>
> The code is actually going to be 100% different next time around, but
> FWIW, here's the last attempt:
>
>   https://lkml.kernel.org/r/4d34d452bf8f85c7d6d5f93db1d3eeb4cba335c7.1461875890.git.jpoimboe@redhat.com
>
> In the meantime I've realized the need to rewrite the x86 core stack
> walking code to something much more manageable so we don't need all
> these unwinders everywhere.  I'll probably post the patches in the next
> week or so.  I'll add you to the CC list.

Awesome!

> With the new interface I think you'll be able to do something like:
>
>         struct unwind_state;
>
>         unwind_start(&state, current, NULL, NULL);
>         unwind_next_frame(&state);
>         oldframe = unwind_get_stack_pointer(&state);
>
>         unwind_next_frame(&state);
>         frame = unwind_get_stack_pointer(&state);
>
>         do {
>                 if (obj + len <= frame)
>                         return blah;
>                 oldframe = frame;
>                 frame = unwind_get_stack_pointer(&state);
>
>         } while (unwind_next_frame(&state);
>
> And then at the end there'll be some (still TBD) way to query whether it
> reached the last syscall pt_regs frame, or if it instead encountered a
> bogus frame pointer along the way and had to bail early.

Sounds good to me. Will there be any frame size information available?
Right now, the unwinder from PaX just drops 2 pointers (saved frame,
saved ip) from the delta of frame address to find the size of the
actual stack area used by the function. If I could shave things like
padding and possible stack canaries off the size too, that would be
great.

Since I'm aiming the hardened usercopy series for 4.8, I figure I'll
just leave this unwinder in for now, and once yours lands, I can rip
it out again.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
