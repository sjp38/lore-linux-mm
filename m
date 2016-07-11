Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7256B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:35:02 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g18so76060756lfg.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:35:02 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id wj1si899369wjb.60.2016.07.11.11.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 11:35:00 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id i5so29783511wmg.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:35:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5782398B.32731.26E46C3D@pageexec.freemail.hu>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <578185D4.29090.242668C8@pageexec.freemail.hu> <20160710091632.GA14172@gmail.com>
 <5782398B.32731.26E46C3D@pageexec.freemail.hu>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Jul 2016 14:34:59 -0400
Message-ID: <CAGXu5jLnCNHo2uPxeQeFF8DY0QG1x2QEnzmvevDqbjZ5ey2=Aw@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PaX Team <pageexec@freemail.hu>
Cc: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux <sparclinux@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>

On Sun, Jul 10, 2016 at 8:03 AM, PaX Team <pageexec@freemail.hu> wrote:
> i note that this analysis is also missing from this USERCOPY submission except
> for stating what Kees assumed about USERCOPY (and apparently noone could be
> bothered to read the original Kconfig help of it which clearly states that the
> purpose is copy size checking, not some elaborate pointer validation, the latter
> is an implementation detail only and is necessary to be able to derive the
> underlying slab object's intended size).

I read the Kconfig text, but it's not entirely accurate. While size is
being checked, it's all nonsense without also the address, so it's
really an object checker. The original design intent may have been the
slab size checks, but it grew beyond that (both within PaX and within
Grsecurity which explicitly added the check for pointers into kernel
text).

I'm just trying to explain as fully as possible what the resulting
code does and why.

> it's not pointer validation but bounds checking: you already know which memory
> object the pointer is supposed to point to, you only check its bounds. if it was
> an attacker controlled pointer then all this would be a pointless check of course,
> trivial for an attacker to circumvent (and this is why it's not part of the
> USERCOPY design).

Agreed: but the pointer is being checked to attempt to figure out what
KIND of object is being copied. It is part of the logic. If it helps
people understand it more clearly, I can describe them as separate
steps: identify the object type, then perform bounds checking of the
size on that type.

>> > yes, more bikeshedding will surely help, [...]
>>
>> Insulting and ridiculing a reviewer who explicitly qualified his comments with
>> "one minor nit to pick" sure does not help upstream integration either.
>
> sorry Ingo, but calling a spade a spade isn't insulting, at best it's exposing
> some painful truth. you yourself used that term several times in the past, were
> you insulting and ridiculing people then?
>
> as for the ad hominem that you displayed here and later, i hope that in the
> future you will display the same professional conduct that you apparently expect
> from others.

There's a long history of misunderstanding and miscommunication
(intentional or otherwise) by everyone on these topics. I'd love it if
we can just side-step all of it, and try to stick as closely to the
technical discussions as possible. Everyone involved in these
discussions wants better security, even if we go about it in different
ways. If anyone finds themselves feeling insulted, just try to let it
go, and focus on the places where we can find productive common
ground, remembering that any fighting just distracts from the more
important issues at hand.

> i'll voice my opinion when you guys are about to screw it up (as it happened in
> the past and apparently history keeps repeating itself). if you don't want my
> opinion then don't ask for it (in that case we'll write a blog at most ;).

I am hugely interested in your involvement in these discussions:
you're by far the most knowledgeable about them. You generally give
very productive feedback, and for that I'm thankful. I prefer that to
just saying something is wrong/broken without any actionable
follow-up. :)

>> > [...] like the renaming of .data..read_only to .data..ro_after_init which also
>> > had nothing to do with init but everything to do with objects being conceptually
>> > read-only...
>>
>> .data..ro_after_init objects get written to during bootup so it's conceptually
>> quite confusing to name it "read-only" without any clear qualifiers.
>>
>> That it's named consistently with its role of "read-write before init and read
>> only after init" on the other hand is not confusing at all. Not sure what your
>> problem is with the new name.
>
> the new name reflects a complete misunderstanding of the PaX feature it was based
> on (typical case of cargo cult security). in particular, the __read_only facility
> in PaX is part of a defense mechanism that attempts to solve a specific problem
> (like everything else) and that problem has nothing whatsoever to do with what
> happens before/after the kernel init process. enforcing read-ony kernel memory at
> the end of kernel initialization is an implementation detail only and wasn't even
> true always (and still isn't true for kernel modules for example): in the linux 2.4
> days PaX actually enforced read-only kernel memory properties in startup_32 already
> but i relaxed that for the 2.6+ port as the maintenance cost (finding out and
> handling new exceptional cases) wasn't worth it.

Part of getting protections into upstream is doing them in ways that
make them palatable for incremental work. As it happened, the
read-after-init piece of the larger read-only attack surface reduction
effort was small enough to make it in. As more work is done, we can
continue to build on it.

Making rodata read-only before mark_rodata() is part of my longer goal
since other architectures (e.g. s390) already do this, and is
technically the more correct thing to do: rodata should start its life
read-only. It's a weird hack that it is delayed at all.

> also naming things after their implementation is poor taste and can result in
> even bigger problems down the line since as soon as the implementation changes,

On the surface, I don't disagree, but as upstream is a large-scale
collaborative effort, I tend to focus on what things are specifically
critical, and naming isn't one of them. :)

> you will have a flag day or have to keep a bad name. this is a lesson that the
> REFCOUNT submission will learn too since the kernel's atomic*_t types (an
> implementation detail) are used extensively for different purposes, instead of
> using specialized types (kref is a good example of that).

Right, and I think part of this is a failure of documentation and
examples. As we make progress with REFCOUNT, we can learn about the
best way to approach these kinds of larger tree-wide changes under the
constraints of the existing upstream development process.

> For .data..ro_after_init
> the lesson will happen when you try to add back the remaining pieces from PaX,
> such as module handling and not-always-const-in-the-C-sense objects and associated
> accessors.

Do you mean the rest of the KERNEXEC (hopefully I'm not confusing
implementation names) code that uses pax_open/close_kernel()? I expect
that to be a gradual addition too, and I'd love participation to get
it and the constify plugin into the kernel.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
