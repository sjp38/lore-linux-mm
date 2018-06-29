Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8506A6B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:04:33 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x18-v6so1883302oie.7
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 04:04:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b39-v6si2643465otj.146.2018.06.29.04.04.31
        for <linux-mm@kvack.org>;
        Fri, 29 Jun 2018 04:04:31 -0700 (PDT)
Date: Fri, 29 Jun 2018 12:04:22 +0100
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180629110419.GC26019@e103592.cambridge.arm.com>
References: <cover.1530018818.git.andreyknvl@google.com>
 <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jun 28, 2018 at 08:56:41PM +0200, Andrey Konovalov wrote:
> On Thu, Jun 28, 2018 at 12:51 PM, Dave Martin <Dave.Martin@arm.com> wrote:
> > On Tue, Jun 26, 2018 at 03:15:10PM +0200, Andrey Konovalov wrote:
> >> 1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
> >>    tags in the top byte of each kernel pointer.
> >
> > [...]
> >
> > This is a change from the current situation, so the kernel may be
> > making implicit assumptions about the top byte of kernel addresses.
> >
> > Randomising the top bits may cause things like address conversions and
> > pointer arithmetic to break.
> >
> > For example, (q - p) will not produce the expected result if q and p
> > have different tags.
> 
> If q and p have different tags, that means they come from different
> allocations. I don't think it would make sense to calculate pointer
> difference in this case.

It's not strictly valid to subtract pointers from different allocations
in C, but it's hard to prove statically that two pointers are guaranteed
to point into the same allocation.

It's likely that we're getting away with it in some places today.

> > Conversions, such as between pointer and pfn, may also go wrong if not
> > appropriately masked.
> >
> > There are also potential pointer comparison and aliasing issues if
> > the tag bits are ever stripped or modified.
> >
> >
> > What was your approach to tracking down all the points in the code
> > where we have a potential issue?
> 
> I've been fuzzing the kernel built with KWHASAN with syzkaller. This
> gives a decent coverage and I was able to find some places where
> fixups were required this way. Right now the fuzzer is running without
> issues. It doesn't prove that all such places are fixed, but I don't
> know a better way to test this.

Can sparse be hacked to identify pointer subtractions where the pointers
are cannot be statically proved to point into the same allocation?

Maybe the number of hits for this wouldn't be outrageously high, though
I expect there would be a fair number.

Tracking pointers that have been cast to integer types is harder.
Ideally we'd want to do that, to flag up potentially problematic
masking and other similar hacks.

Cheers
---Dave
