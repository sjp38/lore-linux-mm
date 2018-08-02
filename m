Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5D46B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 09:52:12 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t138-v6so1965178oih.5
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 06:52:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h140-v6si1323255oib.457.2018.08.02.06.52.10
        for <linux-mm@kvack.org>;
        Thu, 02 Aug 2018 06:52:11 -0700 (PDT)
Date: Thu, 2 Aug 2018 14:52:02 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180802135201.qjweapbskllthvhu@armageddon.cambridge.arm.com>
References: <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com>
 <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
 <20180703173608.GF27243@arm.com>
 <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
 <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
 <20180801163538.GA10800@arm.com>
 <CACT4Y+aZtph5qDsLzTDEgpQRz4_Vtg1DD-cB18qooi6D0bexDg@mail.gmail.com>
 <20180802111031.yx3x6y5d5q6drq52@armageddon.cambridge.arm.com>
 <CACT4Y+b0gkSQHUG67MbYZUTA_aZWs7EmJ2eUzOEPWdt9==ysdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+b0gkSQHUG67MbYZUTA_aZWs7EmJ2eUzOEPWdt9==ysdg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

(trimming the quoted text a bit)

On Thu, Aug 02, 2018 at 01:36:25PM +0200, Dmitry Vyukov wrote:
> On Thu, Aug 2, 2018 at 1:10 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Wed, Aug 01, 2018 at 06:52:09PM +0200, Dmitry Vyukov wrote:
> >> On Wed, Aug 1, 2018 at 6:35 PM, Will Deacon <will.deacon@arm.com> wrote:
> >> > I'd really like to enable pointer tagging in the kernel, I'm just still
> >> > failing to see how we can do it in a controlled manner where we can reason
> >> > about the semantic changes using something other than a best-effort,
> >> > case-by-case basis which is likely to be fragile and error-prone.
> >> > Unfortunately, if that's all we have, then this gets relegated to a
> >> > debug feature, which sort of defeats the point in my opinion.
> >>
> >> Well, in some cases there is no other way as resorting to dynamic testing.
> >> How do we ensure that kernel does not dereference NULL pointers, does
> >> not access objects after free or out of bounds?
> >
> > We should not confuse software bugs (like NULL pointer dereference) with
> > unexpected software behaviour introduced by khwasan where pointers no
> > longer represent only an address range (e.g. calling find_vmap_area())
> > but rather an address and a tag.
[...]
> > However, not untagging a pointer when converting to long may have
> > side-effects in some cases and I consider these bugs introduced by the
> > khwasan support rather than bugs in the original kernel code. Ideally
> > we'd need some tooling on top of khwasan to detect such shortcomings but
> > I'm not sure we can do this statically, as Andrey already mentioned. For
> > __user pointers, things are slightly better as we can detect the
> > conversion either with sparse (modified) or some LLVM changes.
[...]
> For example, LOCKDEP has the same problem. Previously correct code can
> become incorrect and require finer-grained lock class annotations.
> KMEMLEAK has the same problem: previously correct code that hides a
> pointer may now need changes to unhide the pointer.

It's not actually the same. Take the kmemleak example as I'm familiar
with, previously correct code _continues_ to run correctly in the
presence of kmemleak. The annotation or unhiding is only necessary to
reduce the kmemleak false positives. With khwasan, OTOH, an explicit
untagging is necessary so that the code functions correctly again.

IOW, kmemleak only monitors the behaviour of the original code while
khwasan changes such behaviour by tagging the pointers.

> If somebody has a practical idea how to detect these statically, let's
> do it. Otherwise let's go with the traditional solution to this --
> dynamic testing. The patch series show that the problem is not a
> disaster and we won't need to change just every line of kernel code.

It's indeed not a disaster but we had to do this exercise to find out
whether there are better ways of detecting where untagging is necessary.

If you want to enable khwasan in "production" and since enabling it
could potentially change the behaviour of existing code paths, the
run-time validation space doubles as we'd need to get the same code
coverage with and without the feature being enabled. I wouldn't say it's
a blocker for khwasan, more like something to be aware of.

The awareness is a bit of a problem as the normal programmer would have
to pay more attention to conversions between pointer and long. Given
that this is an arm64-only feature, we have a risk of khwasan-triggered
bugs being introduced in generic code in the future (hence the
suggestion of some static checker, if possible).

-- 
Catalin
