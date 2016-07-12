Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D109E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 18:56:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l89so20382029lfi.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:56:08 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id m68si3320481lfb.36.2016.07.12.15.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 15:56:05 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id b199so25363401lfe.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 15:56:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <578524E0.6080401@intel.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com> <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com> <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <5783AE8F.3@sr71.net> <CALCETrW1qLZE_cq1CvmLkdnFyKRWVZuah29xERTC7o0eZ8DbwQ@mail.gmail.com>
 <5783BFB0.70203@intel.com> <CALCETrUZeZ00sFrTEqWSB-OxkCzGQxknmPTvFe4bv5mKc3hE+Q@mail.gmail.com>
 <578524E0.6080401@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 12 Jul 2016 15:55:45 -0700
Message-ID: <CALCETrVfmYm5jzM=JWCS0NjBA4VFouren2X22w7M+gLBQF-W4w@mail.gmail.com>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, X86 ML <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, Jul 12, 2016 at 10:12 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 07/12/2016 09:32 AM, Andy Lutomirski wrote:
>> I think it's more or less impossible to get sensible behavior passing
>> pkey != 0 data to legacy functions.  If you call:
>>
>> void frob(struct foo *p);
>>
>> If frob in turn passes p to a thread, what PKRU is it supposed to use?
>
> The thread inheritance of PKRU can be nice.  It actually gives things a
> good chance of working if you can control PKRU before clone().  I'd
> describe the semantics like this:
>
>         PKRU values are inherited at the time of a clone() system
>         call.  Threads unaware of protection keys may work on
>         protection-key-protected data as long as PKRU is set up in
>         advance of the clone() and never needs to be changed inside the
>         thread.
>
>         If a thread is created before PKRU is set appropriately, the
>         thread may not be able to act on protection-key-protected data.

Given the apparent need for seccomp's TSYNC, I'm a bit nervous that
this will be restrictive to a problematic degree.

>
> Otherwise, the semantics are simpler, but they basically give threads no
> chance of ever working:
>
>         Threads unaware of protection keys and which can not manage
>         PKRU may not operate on data where a non-zero key has been
>         passed to pkey_mprotect().
>
> It isn't clear to me that one of these is substantially better than the
> other.  It's fairly easy in either case for an app that cares to get the
> behavior of the other.
>
> But, one is clearly easier to implement in the kernel. :)
>
>>>> So how is user code supposed lock down all of its threads?
>>>>
>>>> seccomp has TSYNC for this, but I don't think that PKRU allows
>>>> something like that.
>>>
>>> I'm not sure this is possible for PKRU.  Think of a simple PKRU
>>> manipulation in userspace:
>>>
>>>         pkru = rdpkru();
>>>         pkru |= PKEY_DENY_ACCESS<<key*2;
>>>         wrpkru(pkru);
>>>
>>> If we push a PKRU value into a thread between the rdpkru() and wrpkru(),
>>> we'll lose the content of that "push".  I'm not sure there's any way to
>>> guarantee this with a user-controlled register.
>>
>> We could try to insist that user code uses some vsyscall helper that
>> tracks which bits are as-yet-unassigned.  That's quite messy, though.
>
> Yeah, doable, but not without some new data going out to userspace, plus
> the vsyscall code itself.
>
>> We could also arbitrarily partition the key space into
>> initially-wide-open, initially-read-only, and initially-no-access and
>> let pkey_alloc say which kind it wants.
>
> The point is still that wrpkru destroyed the 'push' operation.  You
> always end up with a PKRU that (at least temporarily) ignored the 'push'.
>

Not with my partitioning proposal.  We'd never asynchronously modify
another thread's state -- we'd start start with a mask that gives us a
good chance of having the initial state always be useful.  To be
completely precise, the initial state would be something like:

0 = all access, 1 (PROT_EXEC) = deny read and write, 2-11: deny read
and write, 12-21: deny write, 22-31: all access

Then pkru_alloc would take a parameter giving the requested initial
state, and it would only work if a key with that initial state is
available.

If we went with the vdso approach, the API could look like:

pkru_state_t prev = pkru_push(mask, value);

...

pkru_pop(prev); // or pkru_pop(mask, prev)?

This doesn't fundamentally require the vdso, except that implementing
bitwise operations on PKRU can't be done atomically with RDPKRU /
WRPKRU.  Grr.  This also falls apart pretty badly when sigreturn
happens, so I don't think I like this approach.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
