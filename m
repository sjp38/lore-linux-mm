Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1540C6B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 14:18:37 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id w23so723854otj.6
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 11:18:37 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a25si498483otj.335.2018.03.09.11.18.35
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 11:18:36 -0800 (PST)
Date: Fri, 9 Mar 2018 19:18:24 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 14/14] khwasan: default the instrumentation mode to
 inline
Message-ID: <20180309191823.p6r7f5dlxhifxokh@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <1943a345f4fb7e8e8f19b4ece2457bccd772f0dc.1520017438.git.andreyknvl@google.com>
 <20180305145435.tfaldb334lp4obhi@lakrids.cambridge.arm.com>
 <CAAeHK+y+sAGYSsfUHk4De2QiAPEN_+_ACxCoQ7XMSkvpseoFVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+y+sAGYSsfUHk4De2QiAPEN_+_ACxCoQ7XMSkvpseoFVQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 09, 2018 at 07:06:59PM +0100, Andrey Konovalov wrote:
> On Mon, Mar 5, 2018 at 3:54 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Mar 02, 2018 at 08:44:33PM +0100, Andrey Konovalov wrote:
> >> There are two reasons to use outline instrumentation:
> >> 1. Outline instrumentation reduces the size of the kernel text, and should
> >>    be used where this size matters.
> >> 2. Outline instrumentation is less invasive and can be used for debugging
> >>    for KASAN developers, when it's not clear whether some issue is caused
> >>    by KASAN or by something else.
> >>
> >> For the rest cases inline instrumentation is preferrable, since it's
> >> faster.
> >>
> >> This patch changes the default instrumentation mode to inline.
> >> ---
> >>  lib/Kconfig.kasan | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> >> index ab34e7d7d3a7..8ea6ae26b4a3 100644
> >> --- a/lib/Kconfig.kasan
> >> +++ b/lib/Kconfig.kasan
> >> @@ -70,7 +70,7 @@ config KASAN_EXTRA
> >>  choice
> >>       prompt "Instrumentation type"
> >>       depends on KASAN
> >> -     default KASAN_OUTLINE
> >> +     default KASAN_INLINE
> >
> > Some compilers don't support KASAN_INLINE, but do support KASAN_OUTLINE.
> > IIRC that includes the latest clang release, but I could be wrong.
> >
> > If that's the case, changing the default here does not seem ideal.
> >
> 
> Hi Mark!
> 
> GCC before 5.0 doesn't support KASAN_INLINE, but AFAIU will fallback
> to outline instrumentation in this case.
> 
> Latest Clang Release doesn't support KASAN_INLINE (although current
> trunk does) and falls back to outline instrumentation.
> 
> So nothing should break, but people with newer compilers should get
> the benefits of using the inline instrumentation by default.

Ah, ok. I had assumed that they were separate compiler options, and this
would result in a build failure.

I have no strong feelings either way as to the default. I typically use
inline today unless I'm trying to debug particularly weird cases and
want to hack the shadow accesses.

Thanks,
Mark.
