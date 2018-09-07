Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE45D6B7F03
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 11:26:22 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w185-v6so17296195oig.19
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 08:26:22 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c81-v6si5873445oif.174.2018.09.07.08.26.08
        for <linux-mm@kvack.org>;
        Fri, 07 Sep 2018 08:26:08 -0700 (PDT)
Date: Fri, 7 Sep 2018 16:26:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180907152600.myidisza5o4kdmvf@armageddon.cambridge.arm.com>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
 <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, cpandya@codeaurora.org, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Jacob.Bramley@arm.com, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, eugenis@google.com, Kees Cook <keescook@chromium.org>, Ruben.Ayrapetyan@arm.com, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, linux-mm <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lee.Smith@arm.com, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Sep 06, 2018 at 02:16:19PM -0700, Linus Torvalds wrote:
> On Thu, Sep 6, 2018 at 2:13 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So for example:
> >
> > >  static inline compat_uptr_t ptr_to_compat(void __user *uptr)
> > >  {
> > > -       return (u32)(unsigned long)uptr;
> > > +       return (u32)(__force unsigned long)uptr;
> > >  }
> >
> > this actually looks correct.
> 
> Side note: I do think that while the above is correct, the rest of the
> patch shows that we might be better off simply not havign the warning
> for address space changes at all for the "cast a pointer to an integer
> type" case.
> 
> When you cast to a non-pointer type, the address space issue simply
> doesn't exist at all, so the warning makes less sense.

That's actually a new (potential) issue introduced by these patches. The
arm64 architecture has a feature called Top Byte Ignore (TBI, a.k.a.
tagged pointers) where the top 8-bit of a 64-bit pointer can be set to
anything and the hardware automatically ignores it when dereferencing.
The arm64 user/kernel ABI currently mandates that any pointer passed
from user space to the kernel must have the top byte 0.

This patchset is proposing to relax the ABI so that user pointers with a
non-zero top byte can be actually passed via kernel syscalls. It
basically moves the responsibility to remove the pointer tag (where
needed) from user to the kernel (and for some good reasons, user space
can't always do it given the way hwasan is implemented in LLVM).

The downside is that now a tagged user pointer may not represent just a
virtual address but address|tag, so things like access_ok() or
find_extended_vma() need to untag (clear the top byte of) the pointer
before use. Note that copy_from_user() etc. can safely dereference a
tagged user pointer as the tag is automatically ignored by the hardware.

The arm64 maintainers asked for a more reliable approach to identifying
existing and new cases where such explicit untagging is required and one
of the proposals was a sparse option. Based on some observations, it
seems that untagging is needed when a pointer is cast to a long and the
pointer tag information can be dropped. With the sparse patch, there are
lots of warnings where we actually can preserve the tag (e.g. compat
user pointers should be ignored since the top 32-bit are always 0), so
Andrey is trying to mask such warnings out so that we can detect new
potential issues as the kernel evolves.

So it's not about casting to another pointer; it's rather about no
longer using the value as a user pointer but as an actual (untyped,
untagged) virtual address.

There may be better options to address this but I haven't seen any
concrete proposal so far. Or we could simply consider that we've found
all places where it matters and not bother with any static analysis
tools (but for the time being it's still worth investigating whether we
can do better than this).

> It's really just he "pointer to one address space" being cast to
> "pointer to another address space" that should really warn, and that
> might need that "__force" thing.

I think sparse already warns if changing the address space of a pointer.

-- 
Catalin
