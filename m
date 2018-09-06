Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1535A6B7B3A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 19:09:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z11-v6so8434021wma.4
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 16:09:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15-v6sor4639488wrm.3.2018.09.06.16.09.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 16:09:02 -0700 (PDT)
Date: Fri, 7 Sep 2018 01:08:59 +0200
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180906230858.psedqdai3dw2cvvl@ltop.local>
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
Cc: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, eugenis@google.com, Lee.Smith@arm.com, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, cpandya@codeaurora.org

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
> 
> It's really just he "pointer to one address space" being cast to
> "pointer to another address space" that should really warn, and that
> might need that "__force" thing.
> 
> Hmm? So maybe a sparse change is better for most of that patch.

Unless I'm misunderstanding something, I don't think there is
anything to change for this specific point. Sparse don't warn
(by default) on "cast from pointer with address space to integer",
as it always been the case, I think. I think it's the good choice.

It's just that recently, I've added a new flag -Wcast-from-as [1],
defaulting to 'no', specifically to *detect* these cast because of
these tagged pointers.

Note: I tend to think more and more that __force is simply too
      strong and weaker form, like __force_as and __force_bitwise
      would be more appropriate.


-- Luc Van Oostenryck

[1] d96da358c ("stricter warning for explicit cast to ulong")
