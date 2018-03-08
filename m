Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7F06B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 06:21:15 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 45so2999945otf.1
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 03:21:15 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i2si6009181ote.527.2018.03.08.03.21.12
        for <linux-mm@kvack.org>;
        Thu, 08 Mar 2018 03:21:13 -0800 (PST)
Date: Thu, 8 Mar 2018 11:20:58 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 07/14] khwasan: add tag related helper functions
Message-ID: <20180308112057.dsxhm3s2yzrld5yq@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <226055ec7c1a01dd8211ca9a8b34c07162be37fa.1520017438.git.andreyknvl@google.com>
 <20180305143246.o7bass2rhbksneqb@lakrids.cambridge.arm.com>
 <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Tue, Mar 06, 2018 at 07:31:16PM +0100, Andrey Konovalov wrote:
> On Mon, Mar 5, 2018 at 3:32 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Mar 02, 2018 at 08:44:26PM +0100, Andrey Konovalov wrote:
> >> +static DEFINE_PER_CPU(u32, prng_state);
> >> +
> >> +void khwasan_init(void)
> >> +{
> >> +     int cpu;
> >> +
> >> +     for_each_possible_cpu(cpu) {
> >> +             per_cpu(prng_state, cpu) = get_random_u32();
> >> +     }
> >> +     WRITE_ONCE(khwasan_enabled, 1);
> >> +}
> >> +
> >> +static inline u8 khwasan_random_tag(void)
> >> +{
> >> +     u32 state = this_cpu_read(prng_state);
> >> +
> >> +     state = 1664525 * state + 1013904223;
> >> +     this_cpu_write(prng_state, state);
> >> +
> >> +     return (u8)state;
> >> +}
> >
> > Have you considered preemption here? Is the assumption that it happens
> > sufficiently rarely that cross-contaminating the prng state isn't a
> > problem?
> 
> Hi Mark!
> 
> Yes, I have. If a preemption happens between this_cpu_read and
> this_cpu_write, the only side effect is that we'll give a few
> allocated in different contexts objects the same tag. Sine KHWASAN is
> meant to be used a probabilistic bug-detection debug feature, this
> doesn't seem to have serious negative impact.

Sure, just wanted to check that was the intent.

> I'll add a comment about this though.

That would be great!

Thanks,
Mark.
