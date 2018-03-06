Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 605DF6B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:31:19 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 204so10302itu.6
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:31:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q192sor6272580itc.131.2018.03.06.10.31.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 10:31:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305143246.o7bass2rhbksneqb@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <226055ec7c1a01dd8211ca9a8b34c07162be37fa.1520017438.git.andreyknvl@google.com>
 <20180305143246.o7bass2rhbksneqb@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 6 Mar 2018 19:31:16 +0100
Message-ID: <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com>
Subject: Re: [RFC PATCH 07/14] khwasan: add tag related helper functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Mar 5, 2018 at 3:32 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 02, 2018 at 08:44:26PM +0100, Andrey Konovalov wrote:
>> +static DEFINE_PER_CPU(u32, prng_state);
>> +
>> +void khwasan_init(void)
>> +{
>> +     int cpu;
>> +
>> +     for_each_possible_cpu(cpu) {
>> +             per_cpu(prng_state, cpu) = get_random_u32();
>> +     }
>> +     WRITE_ONCE(khwasan_enabled, 1);
>> +}
>> +
>> +static inline u8 khwasan_random_tag(void)
>> +{
>> +     u32 state = this_cpu_read(prng_state);
>> +
>> +     state = 1664525 * state + 1013904223;
>> +     this_cpu_write(prng_state, state);
>> +
>> +     return (u8)state;
>> +}
>
> Have you considered preemption here? Is the assumption that it happens
> sufficiently rarely that cross-contaminating the prng state isn't a
> problem?

Hi Mark!

Yes, I have. If a preemption happens between this_cpu_read and
this_cpu_write, the only side effect is that we'll give a few
allocated in different contexts objects the same tag. Sine KHWASAN is
meant to be used a probabilistic bug-detection debug feature, this
doesn't seem to have serious negative impact.

I'll add a comment about this though.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
