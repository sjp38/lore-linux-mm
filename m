Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE6586B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 08:04:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so39747899wmr.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 05:04:17 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id 201si2611556wms.49.2016.07.10.05.04.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Jul 2016 05:04:16 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Sun, 10 Jul 2016 14:03:23 +0200
MIME-Version: 1.0
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Reply-to: pageexec@freemail.hu
Message-ID: <5782398B.32731.26E46C3D@pageexec.freemail.hu>
In-reply-to: <20160710091632.GA14172@gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>, <578185D4.29090.242668C8@pageexec.freemail.hu>, <20160710091632.GA14172@gmail.com>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linuxppc-dev@lists.ozlabs.org, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>

On 10 Jul 2016 at 11:16, Ingo Molnar wrote:

> * PaX Team <pageexec@freemail.hu> wrote:
> 
> > On 9 Jul 2016 at 14:27, Andy Lutomirski wrote:
> > 
> > > I like the series, but I have one minor nit to pick.  The effect of this 
> > > series is to harden usercopy, but most of the code is really about 
> > > infrastructure to validate that a pointed-to object is valid.
> > 
> > actually USERCOPY has never been about validating pointers. its sole purpose is 
> > to validate the *size* argument of copy*user calls, a very specific form of 
> > runtime bounds checking.
> 
> What this code has been about originally is largely immaterial, unless you can 
> formulate it into a technical argument.

we design defense mechanisms for specific and clear purposes, starting with
a threat model, evaluating defense options based on various criteria, etc.
USERCOPY underwent this same process and taking it out of its original context
means that all you get in the end is cargo cult security (wouldn't be the first
time it has happened (ExecShield, ASLR, etc)).

that said, i actually started that discussion but for some reason you chose
not to respond to that one part of my mail so let me ask it again:

  what kind of checks are you thinking of here? and more fundamentally, against
  what kind of threats?

as far as i'm concerned, a defense mechanism is only as good as its underlying
threat model. by validating pointers (for yet to be stated security related
properties) you're presumably assuming some kind of threat and unless stated
clearly what that threat is (unintended pointer modification through memory
corruption and/or other bugs?) noone can tell whether the proposed defense
mechanism will actually be effective in preventing exploitation. it is the
worst kind of defense that doesn't actually achieve its stated goals, that
way lies false sense of security and i hope noone here is in that business.

i note that this analysis is also missing from this USERCOPY submission except
for stating what Kees assumed about USERCOPY (and apparently noone could be
bothered to read the original Kconfig help of it which clearly states that the
purpose is copy size checking, not some elaborate pointer validation, the latter
is an implementation detail only and is necessary to be able to derive the
underlying slab object's intended size).

> There are a number of cheap tests we can do and there are a number of ways how a 
> 'pointer' can be validated runtime, without any 'size' information:
> 
>  - for example if a pointer points into a red zone straight away then we know it's
>    bogus.

it's not pointer validation but bounds checking: you already know which memory
object the pointer is supposed to point to, you only check its bounds. if it was
an attacker controlled pointer then all this would be a pointless check of course,
trivial for an attacker to circumvent (and this is why it's not part of the
USERCOPY design).

>  - or if a kernel pointer is points outside the valid kernel virtual memory range
>    we know it's bogus as well.

accesses outside of valid virtual memory will cause a page fault ('oops' in linux
terms), there's no need to explicitly check for that.

> So while only doing a bounds check might have been the original purpose of the 
> patch set, Andy's point is that it might make sense to treat this facility as a 
> more generic 'object validation' code of (pointer,size) object and not limit it to 
> 'runtime bounds checking'.

FYI, 'runtime bounds checking' is a terminus technicus and it is about validating
both the pointer and underlying object's size. that's the reason i called USERCOPY
a 'very specific form' of it only since it doesn't validate each part equally well
(or well enough at all, even the size check is not as precise as it could be).

as for what does or doesn't make sense, first you'll have to define a threat
model and evaluate everything else based on that. since noone has solved the
general bounds checking problem with acceptable properties (mostly performance
impact, but also memory overhead, etc), i'm all ears to hear what you guys have
come up with.

> That kind of extended purpose behind a facility should be reflected in the naming.
> Confusing names are often the source of misunderstandings and bugs.

definitely, but before you bikeshed on naming, you should figure out what and why
you want to do, whether it's even feasible, meaningful, useful, etc. answering the
opening question and digging into the details is the first step of any design
process, not its naming.

> The 9-patch series as submitted here is neither just 'bounds checking' nor just 
> pure 'pointer checking', it's about validating that a (pointer,size) range of 
> memory passed to a (user) memory copy function is fully within a valid object the 
> kernel might know about (in an fast to check fashion).
> 
> This necessary means:
> 
>  - the start of the range points to a valid object to begin with (if known)
> 
>  - the range itself does not point beyond the end of the object (if known)
> 
>  - even if the kernel does not know anything about the pointed to object it can 
>    do a pointer check (for example is it pointing inside kernel virtual memory) 
>    and do a bounds check on the size.
> 
> Do you disagree with that?

as i explained above, you're confusing implementation with design: USERCOPY is
about size checking, not pointer validation. if you want to do the latter as well,
you'll have to first define a threat model, etc. so the answer is 'it depends'
but as the current implementation stands, it's circumventible if an attacker
can control the pointer (which has to be assumed otherwise there's no reason
to validate the pointer, right?).

> > > Might it make sense to call the infrastructure part something else?
> > 
> > yes, more bikeshedding will surely help, [...]
> 
> Insulting and ridiculing a reviewer who explicitly qualified his comments with 
> "one minor nit to pick" sure does not help upstream integration either.

sorry Ingo, but calling a spade a spade isn't insulting, at best it's exposing
some painful truth. you yourself used that term several times in the past, were
you insulting and ridiculing people then?

as for the ad hominem that you displayed here and later, i hope that in the
future you will display the same professional conduct that you apparently expect
from others.

> (Unless the goal is to prevent upstream integration.)

not sure how a properly licensed patch can be prevented from such integration
(as long as you comply with the license, e.g., acknowledge our copyright), but
i'll voice my opinion when you guys are about to screw it up (as it happened in
the past and apparently history keeps repeating itself). if you don't want my
opinion then don't ask for it (in that case we'll write a blog at most ;).

> > [...] like the renaming of .data..read_only to .data..ro_after_init which also 
> > had nothing to do with init but everything to do with objects being conceptually 
> > read-only...
> 
> .data..ro_after_init objects get written to during bootup so it's conceptually 
> quite confusing to name it "read-only" without any clear qualifiers.
> 
> That it's named consistently with its role of "read-write before init and read 
> only after init" on the other hand is not confusing at all. Not sure what your 
> problem is with the new name.

the new name reflects a complete misunderstanding of the PaX feature it was based
on (typical case of cargo cult security). in particular, the __read_only facility
in PaX is part of a defense mechanism that attempts to solve a specific problem
(like everything else) and that problem has nothing whatsoever to do with what
happens before/after the kernel init process. enforcing read-ony kernel memory at
the end of kernel initialization is an implementation detail only and wasn't even
true always (and still isn't true for kernel modules for example): in the linux 2.4
days PaX actually enforced read-only kernel memory properties in startup_32 already
but i relaxed that for the 2.6+ port as the maintenance cost (finding out and
handling new exceptional cases) wasn't worth it.

also naming things after their implementation is poor taste and can result in
even bigger problems down the line since as soon as the implementation changes,
you will have a flag day or have to keep a bad name. this is a lesson that the
REFCOUNT submission will learn too since the kernel's atomic*_t types (an
implementation detail) are used extensively for different purposes, instead of
using specialized types (kref is a good example of that). for .data..ro_after_init
the lesson will happen when you try to add back the remaining pieces from PaX,
such as module handling and not-always-const-in-the-C-sense objects and associated
accessors.

cheers,
 PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
