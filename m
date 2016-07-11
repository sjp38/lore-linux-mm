Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFA0C6B025E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 14:40:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so32100206wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:40:18 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id o128si16279260wmo.43.2016.07.11.11.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 11:40:17 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id f65so74253397wmi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 11:40:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrXfdEbmSTs6XkZjHkAc3W_380bpde4bWQgRA5CQM0PtLA@mail.gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <578185D4.29090.242668C8@pageexec.freemail.hu> <20160710091632.GA14172@gmail.com>
 <5782398B.32731.26E46C3D@pageexec.freemail.hu> <CALCETrXfdEbmSTs6XkZjHkAc3W_380bpde4bWQgRA5CQM0PtLA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 11 Jul 2016 14:40:15 -0400
Message-ID: <CAGXu5jKO2Yihuaw7f087tdAWPQZE+nk+6bdC5VWRws3f1V1y1g@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: PaX Team <pageexec@freemail.hu>, Ingo Molnar <mingo@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux <sparclinux@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>

On Sun, Jul 10, 2016 at 8:38 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Sun, Jul 10, 2016 at 5:03 AM, PaX Team <pageexec@freemail.hu> wrote:
>> On 10 Jul 2016 at 11:16, Ingo Molnar wrote:
>>
>>> * PaX Team <pageexec@freemail.hu> wrote:
>>>
>>> > On 9 Jul 2016 at 14:27, Andy Lutomirski wrote:
>>> >
>>> > > I like the series, but I have one minor nit to pick.  The effect of this
>>> > > series is to harden usercopy, but most of the code is really about
>>> > > infrastructure to validate that a pointed-to object is valid.
>>> >
>>> > actually USERCOPY has never been about validating pointers. its sole purpose is
>>> > to validate the *size* argument of copy*user calls, a very specific form of
>>> > runtime bounds checking.
>>>
>>> What this code has been about originally is largely immaterial, unless you can
>>> formulate it into a technical argument.
>>
>> we design defense mechanisms for specific and clear purposes, starting with
>> a threat model, evaluating defense options based on various criteria, etc.
>> USERCOPY underwent this same process and taking it out of its original context
>> means that all you get in the end is cargo cult security (wouldn't be the first
>> time it has happened (ExecShield, ASLR, etc)).
>>
>> that said, i actually started that discussion but for some reason you chose
>> not to respond to that one part of my mail so let me ask it again:
>>
>>   what kind of checks are you thinking of here? and more fundamentally, against
>>   what kind of threats?
>>
>> as far as i'm concerned, a defense mechanism is only as good as its underlying
>> threat model. by validating pointers (for yet to be stated security related
>> properties) you're presumably assuming some kind of threat and unless stated
>> clearly what that threat is (unintended pointer modification through memory
>> corruption and/or other bugs?) noone can tell whether the proposed defense
>> mechanism will actually be effective in preventing exploitation. it is the
>> worst kind of defense that doesn't actually achieve its stated goals, that
>> way lies false sense of security and i hope noone here is in that business.
>
> I'm imaging security bugs that involve buffer length corruption but
> that don't call copy_to/from_user.  Hardened usercopy shuts
> expoitation down if the first use of the corrupt size is
> copy_to/from_user or similar.  I bet that a bit better coverage could
> be achieved by instrumenting more functions.
>
> To be clear: I'm not objecting to calling the overall feature hardened
> usercopy or similar.  I object to
> CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR.  That feature is *used* for
> hardened usercopy but is not, in and of itself, a usercopy thing.
> It's an object / memory range validation thing.  So we'll feel silly
> down the road if we use it for something else and the config option
> name has nothing to do with the feature.

Well, the CONFIG_HAVE* stuff is almost entirely invisible to the
end-user, and I feel like it's better to be specific about names now,
and when they change their meaning, we can change their names with it.

I intend to extend the HARDENED_USERCOPY logic in similar ways to how
it is extended in Grsecurity: parts can be used for the "is this
destined for a userspace memory buffer?" test when rejecting writing
pointers or other sensitive information during sprintf (see the
HIDESYM work in grsecurity).

But, I don't like to over-think it: right now, it is named for what it
does, and we can adjust as we need to.

>
>>> > [...] like the renaming of .data..read_only to .data..ro_after_init which also
>>> > had nothing to do with init but everything to do with objects being conceptually
>>> > read-only...
>>>
>>> .data..ro_after_init objects get written to during bootup so it's conceptually
>>> quite confusing to name it "read-only" without any clear qualifiers.
>>>
>>> That it's named consistently with its role of "read-write before init and read
>>> only after init" on the other hand is not confusing at all. Not sure what your
>>> problem is with the new name.
>>
>> the new name reflects a complete misunderstanding of the PaX feature it was based
>> on (typical case of cargo cult security). in particular, the __read_only facility
>> in PaX is part of a defense mechanism that attempts to solve a specific problem
>> (like everything else) and that problem has nothing whatsoever to do with what
>> happens before/after the kernel init process. enforcing read-ony kernel memory at
>> the end of kernel initialization is an implementation detail only and wasn't even
>> true always (and still isn't true for kernel modules for example): in the linux 2.4
>> days PaX actually enforced read-only kernel memory properties in startup_32 already
>> but i relaxed that for the 2.6+ port as the maintenance cost (finding out and
>> handling new exceptional cases) wasn't worth it.
>>
>> also naming things after their implementation is poor taste and can result in
>> even bigger problems down the line since as soon as the implementation changes,
>> you will have a flag day or have to keep a bad name. this is a lesson that the
>> REFCOUNT submission will learn too since the kernel's atomic*_t types (an
>> implementation detail) are used extensively for different purposes, instead of
>> using specialized types (kref is a good example of that). for .data..ro_after_init
>> the lesson will happen when you try to add back the remaining pieces from PaX,
>> such as module handling and not-always-const-in-the-C-sense objects and associated
>> accessors.
>
> The name is related to how the thing works.  If I understand
> correctly, in PaX, the idea is to make some things readonly and use
> pax_open_kernel(), etc to write it as needed.  This is a nifty
> mechanism, but it's *not* what .data..ro_after_init does upstream.  If
> I mark something __ro_after_init, then I can write it freely during
> boot, but I can't write it thereafter.  In contrast, if I put
> something in .rodata (using 'const', for example), then I must not
> write it *at all* unless I use special helpers (kmap, pax_open_kernel,
> etc).  So the practical effect from a programer's perspective of
> __ro_after_init is quite different from .rodata, and I think the names
> should reflect that.

I expect that if/when we add the open/close_kernel logic, we'll have a
new section and it will be named accordingly (since it, too, is not
const-in-the-C-sense, and shouldn't live in the standard .rodata
section).

> (And yes, the upstream kernel should soon have __ro_after_init working
> in modules.  And the not-always-const-in-the-C-sense objects using
> accessors will need changes to add those accessors, and we can and
> should change the annotation on the object itself at the same time.
> But if I mark something __ro_after_init, I can write it using normal C
> during init, and there's nothing wrong with that.)

-Kees


-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
