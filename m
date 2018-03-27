Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A29BD6B000D
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 16:01:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id e15so41821wrj.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 13:01:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l2sor744092wmh.8.2018.03.27.13.01.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 13:01:55 -0700 (PDT)
Date: Tue, 27 Mar 2018 22:01:50 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH v2 11/15] khwasan, mm: perform untagged pointers
 comparison in krealloc
Message-ID: <20180327200150.cadizr7wsfjnfta7@gmail.com>
References: <cover.1521828273.git.andreyknvl@google.com>
 <6eb08c160ae23eb890bd937ddf8346ba211df09f.1521828274.git.andreyknvl@google.com>
 <20180324082947.3isostkpsjraefqt@gmail.com>
 <CAAeHK+xUBOt0hh-r5JhjVFcjYDOOyjUKGeN8OxSfnMpOnaWvFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xUBOt0hh-r5JhjVFcjYDOOyjUKGeN8OxSfnMpOnaWvFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>


* Andrey Konovalov <andreyknvl@google.com> wrote:

> On Sat, Mar 24, 2018 at 9:29 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> >> The krealloc function checks where the same buffer was reused or a new one
> >> allocated by comparing kernel pointers. KHWASAN changes memory tag on the
> >> krealloc'ed chunk of memory and therefore also changes the pointer tag of
> >> the returned pointer. Therefore we need to perform comparison on untagged
> >> (with tags reset) pointers to check whether it's the same memory region or
> >> not.
> >>
> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >> ---
> >>  mm/slab_common.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/slab_common.c b/mm/slab_common.c
> >> index a33e61315ca6..5911f2194cf7 100644
> >> --- a/mm/slab_common.c
> >> +++ b/mm/slab_common.c
> >> @@ -1494,7 +1494,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
> >>       }
> >>
> >>       ret = __do_krealloc(p, new_size, flags);
> >> -     if (ret && p != ret)
> >> +     if (ret && khwasan_reset_tag(p) != khwasan_reset_tag(ret))
> >>               kfree(p);
> >
> > Small nit:
> >
> > If 'reset' here means an all zeroes tag (upper byte) then khwasan_clear_tag()
> > might be a slightly easier to read primitive?
> 
> 'Reset' means to set the upper byte to the value that is native for
> kernel pointers, and that is 0xFF. So it sets the tag to all ones, not
> all zeroes. I can still rename it to khwasan_clear_tag(), if you think
> that makes sense in this case as well.

Ok, if it's not 0 then I agree that 'reset' is the better name. 'clear' would in 
fact be actively confusing.

Thanks,

	Ingo
