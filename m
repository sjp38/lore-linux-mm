Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 533C96B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:06:13 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s125so4393858iod.3
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:06:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x198sor3288114itb.17.2018.03.16.12.06.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 12:06:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFKCwrheE=uDnrS5sH585CgciLg-o7uUsp45TNmF10cuUUR2GA@mail.gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
 <CAAeHK+wGHsFeDP_QMQRzWGTFg10bxfJPxx-_7Ja-_uTP8GJtCA@mail.gmail.com>
 <7f8e8f46-791e-7e8f-551b-f93aa64bcf6e@virtuozzo.com> <CAAeHK+xNjYOAhLBogYYfXi+KiFf9SDYGoaV6og=aRmuB7rhvHg@mail.gmail.com>
 <CAFKCwriP6KY6PaHheZi9gLVebKp-rLa-gATSSE3R-fhrRYex3A@mail.gmail.com>
 <CAAeHK+y8FD7bOOX9p-Vk_dA5geA2S3_T0vwedfQiiHEf3MYdCw@mail.gmail.com> <CAFKCwrheE=uDnrS5sH585CgciLg-o7uUsp45TNmF10cuUUR2GA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 16 Mar 2018 20:06:09 +0100
Message-ID: <CAAeHK+zrLtgDKPb96uMSgYPPPYRiUAttvJsvr0jUHjBDHWk6MQ@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 16, 2018 at 7:45 PM, Evgenii Stepanov <eugenis@google.com> wrote:
> On Fri, Mar 16, 2018 at 11:24 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> Right, by redzones in this case I meant the metadata that is stored
>> right after the object (which includes alloc and free stack handles
>> and perhaps some other allocator stuff).
>
> Oh, I did not realize we have free (as in beer, not as in
> use-after-free) redzones between allocations. Yes, reserving a color
> sounds
> like a good idea.

OK, I'll do that then.

>
>>
>>> As for use-after-free, to catch it with
>>> 100% probability one would need infinite memory for the quarantine.

As for the second part of Andrey's suggestion (as far as I understand
it): reserve a color for freed objects. Without quarantine, this
should give us a precise
use-after-free-but-without-someone-else-allocating-the-same-object
detection. What do you think about that?

>>> It
>>> is possible to guarantee 100% detection of linear buffer overflow by
>>> giving live adjacent chunks distinct tags.

I'll add that to the TODO list as well.
