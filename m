Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0826B7AC1
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 17:16:32 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h5-v6so15239962itb.3
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 14:16:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1-v6sor3950804itj.44.2018.09.06.14.16.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 14:16:31 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1535629099.git.andreyknvl@google.com> <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
In-Reply-To: <CA+55aFyW9N2tSb2bQvkthbVVyY6nt5yFeWQRLHp1zruBmb5ocw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Sep 2018 14:16:19 -0700
Message-ID: <CA+55aFy2t_MHgr_CgwbhtFkL+djaCq2qMM1G+f2DwJ0qEr1URQ@mail.gmail.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by sparse
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, eugenis@google.com, Lee.Smith@arm.com, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, cpandya@codeaurora.org

On Thu, Sep 6, 2018 at 2:13 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So for example:
>
> >  static inline compat_uptr_t ptr_to_compat(void __user *uptr)
> >  {
> > -       return (u32)(unsigned long)uptr;
> > +       return (u32)(__force unsigned long)uptr;
> >  }
>
> this actually looks correct.

Side note: I do think that while the above is correct, the rest of the
patch shows that we might be better off simply not havign the warning
for address space changes at all for the "cast a pointer to an integer
type" case.

When you cast to a non-pointer type, the address space issue simply
doesn't exist at all, so the warning makes less sense.

It's really just he "pointer to one address space" being cast to
"pointer to another address space" that should really warn, and that
might need that "__force" thing.

Hmm? So maybe a sparse change is better for most of that patch.

             Linus
