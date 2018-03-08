Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8EE46B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 04:10:07 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e10so2725820pff.3
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 01:10:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r82sor4603388pfg.60.2018.03.08.01.10.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 01:10:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803071215050.6373@nuc-kabylake>
References: <cover.1520017438.git.andreyknvl@google.com> <226055ec7c1a01dd8211ca9a8b34c07162be37fa.1520017438.git.andreyknvl@google.com>
 <20180305143246.o7bass2rhbksneqb@lakrids.cambridge.arm.com>
 <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com> <alpine.DEB.2.20.1803071215050.6373@nuc-kabylake>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 8 Mar 2018 10:09:43 +0100
Message-ID: <CACT4Y+Yqm+fa-LaVom+61HBpy_oRiKj2VED=5+R-6PySjs+_3g@mail.gmail.com>
Subject: Re: [RFC PATCH 07/14] khwasan: add tag related helper functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Wed, Mar 7, 2018 at 7:16 PM, Christopher Lameter <cl@linux.com> wrote:
>
> On Tue, 6 Mar 2018, Andrey Konovalov wrote:
>
>> >> +     u32 state = this_cpu_read(prng_state);
>> >> +
>> >> +     state = 1664525 * state + 1013904223;
>> >> +     this_cpu_write(prng_state, state);
>> >
>> > Have you considered preemption here? Is the assumption that it happens
>> > sufficiently rarely that cross-contaminating the prng state isn't a
>> > problem?
>>
>> Hi Mark!
>>
>> Yes, I have. If a preemption happens between this_cpu_read and
>> this_cpu_write, the only side effect is that we'll give a few
>> allocated in different contexts objects the same tag. Sine KHWASAN is
>> meant to be used a probabilistic bug-detection debug feature, this
>> doesn't seem to have serious negative impact.
>>
>> I'll add a comment about this though.
>
> You could use this_cpu_cmpxchg here to make it a bit better but it
> probably does not matter.

Hi,

The non-atomic RMW sequence is not just "doesn't seem to have serious
negative impact", it in fact has positive effect.
Ideally the tags use strong randomness to prevent any attempts to
predict them during explicit exploit attempts. But strong randomness
is expensive, and we did an intentional trade-off to use a PRNG (may
potentially be revised in future, but for now we don't have enough
info to do it). In this context, interrupts that randomly skew PRNG at
unpredictable points do only good. cmpxchg would also lead to skewing,
but non-atomic sequence allows more non-determinism (and maybe a dash
less expensive?). This probably deserves a comment, though.
